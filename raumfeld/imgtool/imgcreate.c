#include <stdio.h>
#include <stdlib.h>
#include <getopt.h>

#include "img.h"

static void usage(const char *argv0)
{
	printf("Usage: %s [options]\n", argv0);
	printf("        -k, --kernel <kernel>        Kernel image (required)\n");
	printf("        -d, --description <kernel>   Description file (required)\n");
	printf("        -r, --rootfs <rootfs>        Rootfs image (required)\n");
	printf("        -o, --output <file>          Output file (required)\n");
	printf("        -h, --help                   This help output\n");
}

static struct option long_options[] = {
	{ "kernel",		required_argument,	0,	'k' },
	{ "description",	required_argument,	0,	'd' },
	{ "rootfs",		required_argument,	0,	'r' },
	{ "output",		required_argument,	0,	'o' },
	{ "help",		no_argument,		0,	'h' },
	{ NULL, 0, 0, 0 }
};

int main(int argc, char **argv)
{
	struct img_create_details details;

	while (1) {
		int option_index = 0;
		int c = getopt_long (argc, argv, "k:d:r:o:h",
				     long_options, &option_index);
		if (c < 0)
			break;

		switch (c) {
		case 'k':
			details.uimage = optarg;
			break;
		case 'd':
			details.description = optarg;
			break;
		case 'r':
			details.rootfs = optarg;
			break;
		case 'o':
			details.output = optarg;
			break;
		case 'h':
		default:
			usage(argv[0]);
			return -1;
		}
	}

	if (!details.uimage || !details.description || !details.rootfs || !details.output) {
		usage(argv[0]);
		return -1;
	}

	return img_create(&details);
}

