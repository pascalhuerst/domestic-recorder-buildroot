#ifndef IMG_H
#define IMG_H

int img_check(int fd);

struct img_create_details {
	const char *uimage;
	const char *description;
	const char *rootfs;
	const char *output;
};

int img_create (const struct img_create_details *details);

#endif /* IMG_H */
