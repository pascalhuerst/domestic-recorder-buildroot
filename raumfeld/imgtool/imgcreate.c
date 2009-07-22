#include <stdio.h>
#include <stdlib.h>

#include "img.h"

static void usage(const char *argv0)
{
	printf("Usage: %s <uImage> <description> <rootfs> <output>\n", argv0);
	exit(-1);
}

int main(int argc, char **argv)
{
	char *uimage, *description, *rootfs, *output;

	if (argc < 4)
		usage(argv[0]);

	uimage = argv[1];
	description = argv[2];
	rootfs = argv[3];
	output = argv[4];

	return img_create(uimage, description, rootfs, output);
}

