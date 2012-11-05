#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>

#include "img.h"

static void usage(const char *argv0)
{
	printf("Usage: %s <imgfile> [version]\n", argv0);
	exit(-1);
}

int main(int argc, char **argv)
{
	int fd, ret = 0, version = 0;
	char *imgname;

	if (argc < 2)
		usage(argv[0]);

	if (argc > 2)
		version = strtol(argv[2], NULL, 10);

	imgname = argv[1];
	fd = open(imgname, O_RDONLY);
	if (fd < 0)
		perror("open");
	else
		ret = img_check(fd, version);

	close(fd);
	return ret;
}

