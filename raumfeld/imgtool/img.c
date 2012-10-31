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

#define NUM_FORMATS 2

#define KERNEL_SIZE_V0	(5 * 1024 * 1024)
#define SHA_OFFSET_V0	KERNEL_SIZE_V0
#define DESC_OFFSET_V0	(SHA_OFFSET_V0 + 4096)
#define IMG_OFFSET_V0	(DESC_OFFSET_V0 + 4096)
#define DESC_SIZE_V0	(IMG_OFFSET_V0 - DESC_OFFSET_V0)

#define KERNEL_SIZE_V1	(6 * 1024 * 1024)
#define DTS_OFFSET_V1	KERNEL_SIZE_V1
#define SHA_OFFSET_V1	(DTS_OFFSET_V1 + 256 * 1024)
#define DESC_OFFSET_V1	(SHA_OFFSET_V1 + 4096)
#define IMG_OFFSET_V1	(DESC_OFFSET_V1 + 4096)
#define DESC_SIZE_V1	(IMG_OFFSET_V1 - DESC_OFFSET_V1)

struct img_layout {
	unsigned int dts_offset;
	unsigned int sha_offset;
	unsigned int desc_offset;
	unsigned int img_offset;
	unsigned int desc_size;
};

static struct img_layout layouts[NUM_FORMATS] = {
	{
		.dts_offset	= 0,
		.sha_offset	= SHA_OFFSET_V0,
		.desc_offset	= DESC_OFFSET_V0,
		.img_offset	= IMG_OFFSET_V0,
		.desc_size	= DESC_SIZE_V0,
	},
	{
		.dts_offset	= DTS_OFFSET_V1,
		.sha_offset	= SHA_OFFSET_V1,
		.desc_offset	= DESC_OFFSET_V1,
		.img_offset	= IMG_OFFSET_V1,
		.desc_size	= DESC_SIZE_V1,
	},
};

static struct img_layout *layout;

#define DELIMITER	"-------------------------------------------------\n"

static sha_256_t img_checksum(int fd, size_t fsize, off_t offset)
{
	sha_256_t sha = { 0 };
	void *buf;

	buf = mmap(NULL, fsize, PROT_READ, MAP_SHARED, fd, offset);

	if (!buf) {
		perror("mmap");
		return sha;
	}

	sha = sha256((sha_byte_t *) buf, fsize);
	munmap(buf, fsize);

        return sha;
}

int img_check(int fd, unsigned int version)
{
	int ret;
	struct stat sb;
	size_t fsize;
	sha_256_t sha, img_sha;
	char *desc;

	if (version >= NUM_FORMATS) {
		printf("Unknown format %d\n", version);
		return -1;
	}

	layout = &layouts[version];
	desc = alloca(layout->desc_size);

	/* read the SHA256 from the image */
	ret = lseek(fd, layout->sha_offset, SEEK_SET);
	if (ret != layout->sha_offset) {
		perror("lseek");
		return ret;
	}

	read(fd, &img_sha, sizeof(img_sha));

	/* read the description */
	ret = lseek(fd, layout->desc_offset, SEEK_SET);
	if (ret != layout->desc_offset) {
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

	fsize = sb.st_size - layout->desc_offset;
	lseek(fd, 0, SEEK_SET);

        sha = img_checksum(fd, fsize, layout->desc_offset);

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

int img_create (const struct img_create_details *details)
{
	int fd_out;
        size_t ret;
	size_t fsize;
	sha_256_t sha;

	if (details->version >= NUM_FORMATS) {
		printf("Unknown format %d\n", details->version);
		return -1;
	}

	layout = &layouts[details->version];

	fd_out = open(details->output,
                      O_RDWR | O_CREAT,
                      S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
	if (fd_out < 0) {
		perror("open");
		return fd_out;
	}

	/* first, copy the kernel */
	printf("Copying kernel from >%s< ... ", details->uimage);
	ret = img_copy(fd_out, details->uimage);
	if (ret > layout->sha_offset) {
		printf("too big! (%ul bytes)\n", (int) ret);
		return -1;
	}

	printf("done.\n");

	/* optionally, copy the DTS image */
	if (layout->dts_offset > 0 && details->dts_image) {
		printf("Copying DTS from >%s< ... ", details->dts_image);
		lseek(fd_out, layout->dts_offset, SEEK_SET);
		ret = img_copy(fd_out, details->dts_image);
		if (ret > layout->desc_offset) {
			printf("too big! (%ul bytes)\n", (int) ret);
			return -1;
		}

		printf("done.\n");
	}

	/* continue with description */
	printf("Copying description from >%s< ... ", details->description);
	lseek(fd_out, layout->desc_offset, SEEK_SET);
	ret = img_copy(fd_out, details->description);
	if (ret > layout->img_offset) {
		printf("too big! (%ul bytes)\n", (int) ret);
		return -1;
	}

	printf("done.\n");

	/* the rootfs image */
	printf("Copying rootfs from >%s< ... ", details->rootfs);
	lseek(fd_out, layout->img_offset, SEEK_SET);
	fsize = img_copy(fd_out, details->rootfs) + layout->desc_size;
	printf("done.\n");

	/* calculate the checksum */
        sha = img_checksum (fd_out, fsize, layout->desc_offset);
	printf("SHA256 for this image: ");
	debug_print_digest(sha, 1);

	/* write it */
	lseek(fd_out, layout->sha_offset, SEEK_SET);
	write(fd_out, &sha, sizeof(sha));

	/* done */
	printf("Image %s created.\n", details->output);
	close (fd_out);

	return 0;
}

