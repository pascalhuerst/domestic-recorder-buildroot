#ifndef IMG_H
#define IMG_H

int img_check(int fd, unsigned int version);

struct img_create_details {
	unsigned int version;
	const char *uimage;
	const char *description;
	const char *rootfs;
	const char *output;
	const char *dts_image;
};

int img_create (const struct img_create_details *details);

#endif /* IMG_H */
