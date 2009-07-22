#ifndef IMG_H
#define IMG_H

int img_check(int fd);
int img_create (const char *uimage,
		const char *description,
		const char *rootfs,
		const char *output);

#endif /* IMG_H */
