/* gcc -Wall -o progress_fb progress_fb.c */

#include <stdlib.h>
#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>
#include <sys/types.h>
#include <sys/mman.h>

#define FB_W		(480)
#define FB_H		(272)
#define FB_DEPTH	(sizeof(short))
#define FB_SIZE		(FB_W * FB_H * FB_DEPTH)

static void *fb_mem = NULL;

static int fb_open(void)
{
	int fd = open("/dev/fb0", O_RDWR);
	if (fd < 0)
		return fd;

	fb_mem = mmap(NULL, FB_SIZE, PROT_WRITE, MAP_SHARED, fd, 0);
	if (fb_mem == (void *) -1)
		return -1;

	return fd;
}

static inline void fb_set_pixel(int x, int y, int v)
{
	unsigned short *m = fb_mem;

	if (x >= FB_W || y >= FB_H || x < 0 || y < 0)
		return;

	m[((y * FB_W) + x)] = v;
}

static inline void fb_set_row(int x, int w, int y, int v)
{
	unsigned short *m = fb_mem;

	if (y < 0 || y >= FB_H)
		return;

	if (x < 0) {
		w -= x;
		x = 0;
	} else if (x >= FB_W) {
		return;
	}

	if (w < 0)
		return;

	if (x + w >= FB_W)
		w = FB_W - x;

	m += (y * FB_W) + x;

	while (w--)
		*m++ = v;
}

static void draw_bar(int percent, int x, int y, int w, int h, int color)
{
	int cx, cy;

	if (percent == 0)
		return;

	for (cy = y; cy < y + ((h * percent + 50) / 100); cy++)
		fb_set_row(cx, w, cy, color);
}

int main(int argc, char **argv)
{
	int x, y, w, h, color, fd;
	char buf[1024];

	if (argc < 6) {
		printf("Usage: %s <x> <y> <w> <h> <color>\n", argv[0]);
		printf("\t<x>, <y>, <w>, <h>	The coordinates for the percent bar\n");
		printf("\t<color>		\tThe color to paint with, in hex, %dbit\n", FB_DEPTH * 8);
		return 1;
	}

	x = strtol(argv[1], NULL, 10);
	y = strtol(argv[2], NULL, 10);
	w = strtol(argv[3], NULL, 10);
	h = strtol(argv[4], NULL, 10);
	color = strtol(argv[5], NULL, 16);

	fd = fb_open();
	if (fd < 0)
		return 2;

	while (fgets(buf, sizeof(buf), stdin)) {
		int percent = strtol(buf, NULL, 10);
		draw_bar(percent, x, y, w, h, color);
	}

	close (fd);

	return 0;
}

