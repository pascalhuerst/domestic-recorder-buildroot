#include <stdio.h>
#include <stdlib.h>
#include <getopt.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>

#include "img.h"

static void usage(const char *argv0)
{
	printf("Usage: %s [options] <imgfile> [version]\n", argv0);
	printf("        -v, --version <number>       Layout version (optional, defaults to 0)\n");
	printf("        -h, --help                   This help output\n");
}

static struct option long_options[] = {
	{ "version",		required_argument,	0,	'v' },
	{ "help",		no_argument,		0,	'h' },
	{ NULL, 0, 0, 0 }
};

int main(int argc, char **argv)
{
	int fd, ret = 0, version = 0;
	char *imgname;

	while (1) {
		int option_index = 0;
		int c = getopt_long (argc, argv, "v:h",
				     long_options, &option_index);
		if (c < 0)
			break;

		switch (c) {
		case 'v':
			version = strtol(optarg, 0, 10);
			break;
		case 'h':
		default:
			usage(argv[0]);
			return -1;
		}
	}

	if (argc <= optind) {
		usage(argv[0]);
		return -1;
	}

	imgname = argv[optind];
	fd = open(imgname, O_RDONLY);
	if (fd < 0)
		perror("open");
	else
		ret = img_check(fd, version);

	close(fd);
	return ret;
}

