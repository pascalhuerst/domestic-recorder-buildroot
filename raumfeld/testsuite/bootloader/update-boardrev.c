#include <ctype.h>
#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>

#define BUFSIZE 	(1024 * 1024 * 2)
#define PREFIX 		"boardrev=0x"

int main (int argc, char **argv)
{
	int fd, rev, len;
	char *buf, *pos;

	if (argc < 3) {
		printf ("Usage: %s <file> <board-rev>\n", argv[0]);
		return -1;
	}

	fd = open (argv[1], O_RDWR);
	if (fd < 0) {
		perror ("open");
		return -2;
	}

	rev = strtol (argv[2], NULL, 0);

	buf = (char *) malloc (BUFSIZE);
	if (buf == NULL) {
		printf ("Unable to malloc() - OOM!?\n");
		return -3;
	}

	memset(buf, 0, BUFSIZE);
	len = read (fd, buf, BUFSIZE);

	for (pos = buf; pos < buf + len - strlen (PREFIX); pos++) {
		if (memcmp (pos, PREFIX, strlen(PREFIX)) == 0) {
			char tmp[5];

			pos += strlen (PREFIX);

			if (!isxdigit (pos[0]) ||
			    !isxdigit (pos[1]) ||
			    !isxdigit (pos[2]) ||
			    !isxdigit (pos[3])) {
				printf ("Unable to fit new rev string\n");
				return -4;
			}

			printf ("Found string at offset %d - updating\n", pos - buf);
			if (lseek (fd, pos - buf, SEEK_SET) < 0) {
				perror ("seek");
				return -5;
			}

			snprintf (tmp, sizeof(tmp), "%04x", rev);
			write (fd, tmp, sizeof(tmp));
			close (fd);

			return 0;
		}
	}

	printf ("Unable to find '%s' in %s\n", PREFIX, argv[1]);
	return -6;
}
