/* gcc -Wall -o input_dump input_dump.c */

#include <stdio.h>
#include <fcntl.h>
#include <poll.h>
#include <sys/types.h>
#include <sys/uio.h>
#include <unistd.h>
#include <linux/input.h>

#define DEV_NAME "/dev/input/event0"

int main(int argc, char **argv)
{
	int i, fd, ret;
	char *devname = DEV_NAME, name[256] = "Unknown";
	struct input_event ev;
	int8_t key_bitmask[(KEY_MAX+1)/8];
	int8_t valid_bitmask[(KEY_MAX+1)/8];

	if (argv[1])
		devname = argv[1];

	fd = open(devname, O_RDONLY);
	if (fd < 0) {
		printf("%s: unable to open %s\n", argv[0], argv[1]);
		perror("open");
		return fd;
	}

	if (ioctl(fd, EVIOCGNAME(sizeof(name)), name) < 0)
		printf("unable to get device name using EVIOCGNAME\n");

	if (ioctl(fd, EVIOCGBIT(EV_KEY, sizeof(valid_bitmask)), valid_bitmask) < 0)
		printf("unable to get EVIOCGBIT(EV_KEY)\n");

	if (ioctl(fd, EVIOCGKEY(sizeof(key_bitmask)), key_bitmask) < 0)
		printf("unable to get EVIOCGKEY\n");
	else {
		printf("current key state:\n");

		for (i = 0; i < KEY_MAX+1; i++)
			if (valid_bitmask[i / 8] & (1 << (i % 8)))
				printf("keycode #%d: %d\n", i, !!(key_bitmask[i / 8] & (1 << (i % 8))));

		printf("\n");
	}

	printf("opened %s (>%s<), waiting for events ...\n", devname, name);

	while((ret = read(fd, &ev, sizeof(ev))) == sizeof(ev)) {
		if (ev.type == EV_SYN)
			continue;

		printf("ev.type  = %d\n", ev.type);
		printf("ev.code  = %d\n", ev.code);
		printf("ev.value = %d\n", ev.value);
		printf("------------------------------\n");
	}

	return ret;
}

