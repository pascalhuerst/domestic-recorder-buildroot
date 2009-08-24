/* gcc -Wall -o progress_fb progress_fb.c */

#include <stdlib.h>
#include <stdio.h>
#include <fcntl.h>
#include <poll.h>
#include <unistd.h>
#include <string.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/uio.h>
#include <sys/mman.h>

#define FB_W		(480)
#define FB_H		(272)
#define FB_DEPTH	(sizeof(short))
#define FB_SIZE		(FB_W * FB_H * FB_DEPTH)

static void *fb_mem;

static int fb_init(void)
{
	int fd = open("/dev/fb0", O_RDWR);
	if (fd < 0)
		return fd;

	fb_mem = mmap(NULL, FB_SIZE, PROT_WRITE, MAP_SHARED, fd, 0);
	if (fb_mem == (void *) -1)
		return -1;

	memset(fb_mem, 0, FB_SIZE);

	return fd;
}

static inline void fb_set_pixel(int x, int y, int v)
{
	unsigned short *m = fb_mem;

	if (x >= FB_W || y >= FB_H || x < 0 || y < 0)
		return;

	m[((y * FB_W) + x)] = v;
}

static void draw_bar(int percent, int x, int y, int w, int h, int color)
{
	int cx, cy;

	if (percent == 0)
		return;

	for (cx = x; cx < x + ((w * percent) / 100); cx++)
		for (cy = y; cy < y + h; cy++)
			fb_set_pixel(cx, cy, color);
}

int main(int argc, char **argv)
{
	int x, y, w, h, color, base_fd, fb_fd, ret;
	char *base_img, buf[1024];

	if (argc < 7) {
		printf("Usage: %s <base-img> <x> <y> <w> <h> <color>\n", argv[0]);
		printf("\t<base-img>		A raw file to be sent to the framebuffer as background image\n");
		printf("\t<x>, <y>, <w>, <h>	The coordinates for the percent bar\n");
		printf("\t<color>		\tThe color to paint with, in hex, %dbit\n", FB_DEPTH * 8);
		return 1;
	}

	base_img = argv[1];
	x = strtol(argv[2], NULL, 10);
	y = strtol(argv[3], NULL, 10);
	w = strtol(argv[4], NULL, 10);
	h = strtol(argv[5], NULL, 10);
	color = strtol(argv[6], NULL, 16);

	fb_fd = fb_init();
	if (fb_fd < 0)
		return 2;

	base_fd = open(base_img, O_RDONLY);
	if (base_fd < 0) {
		printf("Unable to open %s: ", base_img);
		perror("open");
		return 3;
	}

	while ((ret = read(base_fd, buf, sizeof(buf))))
		write(fb_fd, buf, ret);

	close(base_fd);

	while (fgets(buf, sizeof(buf), stdin)) {
		int percent = strtol(buf, NULL, 10);
		draw_bar(percent, x, y, w, h, color);
	}

	return 0;
}

