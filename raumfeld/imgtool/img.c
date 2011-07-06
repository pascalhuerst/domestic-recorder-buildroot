/* 
 * img tool suite
 *
 * (c) 2009 Daniel Mack
 *
 * BSD license
 */

#include <fcntl.h>
#include <unistd.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/errno.h>

#include "img.h"
#include "sha256.h"

#define SHA_OFFSET	(5 * 1024 * 1000)
#define DESC_OFFSET	(SHA_OFFSET + 4096)
#define IMG_OFFSET	(DESC_OFFSET + 4096)
#define DESC_SIZE	(IMG_OFFSET - DESC_OFFSET)

#define DELIMITER	"-------------------------------------------------\n"


static sha_256_t img_checksum(int fd, size_t fsize, off_t offset)
{
	sha_256_t sha = { 0 };
	void *buf;

	buf = mmap(NULL, fsize, PROT_READ, MAP_PRIVATE, fd, offset);

	if (!buf) {
		perror("mmap");
		return sha;
	}

	sha = sha256((sha_byte_t *) buf, fsize);
	munmap(buf, fsize);

        return sha;
}

int img_check(int fd)
{
	int ret;
	struct stat sb;
	size_t fsize;
	sha_256_t sha, img_sha;
	char desc[DESC_SIZE];

	/* read the SHA256 from the image */
	ret = lseek(fd, SHA_OFFSET, SEEK_SET);
	if (ret != SHA_OFFSET) {
		perror("lseek");
		return ret;
	}

	read(fd, &img_sha, sizeof(img_sha));

	/* read the description */
	ret = lseek(fd, DESC_OFFSET, SEEK_SET);
	if (ret != DESC_OFFSET) {
		perror("lseek");
		return ret;
	}

	read(fd, desc, sizeof(desc));

	/* calculate the SHA256 checksum from the file */
	ret = fstat(fd, &sb);
	if (ret < 0) {
		perror("fstat");
		return ret;
	}

	fsize = sb.st_size - DESC_OFFSET;
	lseek(fd, 0, SEEK_SET);

        sha = img_checksum(fd, fsize, DESC_OFFSET);

	/* compare given SHA256 with calculated one */
	if (memcmp(&sha, &img_sha, sizeof(sha)) < 0) {
		printf(" (!!!) SHA256 mismatch!\n");
		printf("       image:		");
		debug_print_digest(img_sha, 1);
		printf("       calculated:	");
		debug_print_digest(sha, 1);
		return -2;
	}

	printf("Checksum ok: ");
	debug_print_digest(sha, 1);
	printf("Description:\n");
	printf(DELIMITER);
	printf("%s\n", desc);
	printf(DELIMITER);

	return 0;
}

static size_t img_copy(int out, const char *fname)
{
        int fd;
        size_t ret, off = 0;
	char buf[1024 * 10];

	fd = open(fname, O_RDONLY);
	if (fd < 0) {
		printf("unable to open %s: %s\n", fname, strerror(errno));
		return fd;
	}

	while ((ret = read(fd, buf, sizeof(buf)))) {
		off += ret;
		write(out, buf, ret);
	}

	close(fd);
	return off;
}

int img_create (const char *kernel,
		const char *description,
		const char *rootfs,
		const char *output)
{
	int fd_out;
        size_t ret;
	size_t fsize;
	sha_256_t sha;

	fd_out = open(output,
                      O_RDWR | O_CREAT,
                      S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
	if (fd_out < 0) {
		perror("open");
		return fd_out;
	}

	/* first, copy the kernel */
	printf("Copying kernel from >%s< ... ", kernel);
	ret = img_copy(fd_out, kernel);
	if (ret > SHA_OFFSET) {
		printf("too big! (%ul bytes)\n", ret);
		return -1;
	}

	printf("done.\n");

	/* continue with description */
	printf("Copying description from >%s< ... ", description);
	lseek(fd_out, DESC_OFFSET, SEEK_SET);
	ret = img_copy(fd_out, description);
	if (ret > IMG_OFFSET) {
		printf("too big! (%ul bytes)\n", ret);
		return -1;
	}

	printf("done.\n");

	/* the rootfs image */
	printf("Copying rootfs from >%s< ... ", rootfs);
	lseek(fd_out, IMG_OFFSET, SEEK_SET);
	fsize = img_copy(fd_out, rootfs) + DESC_SIZE;
	printf("done.\n");

	/* calculate the checksum */
        sha = img_checksum (fd_out, fsize, DESC_OFFSET);
	printf("SHA256 for this image: ");
	debug_print_digest(sha, 1);

	/* write it */
	lseek(fd_out, SHA_OFFSET, SEEK_SET);
	write(fd_out, &sha, sizeof(sha));

	/* done */
	printf("Image %s created.\n", output);
	close (fd_out);

	return 0;
}

