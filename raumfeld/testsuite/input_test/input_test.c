/* gcc -Wall -o input_test input_test.c */

#include <stdio.h>
#include <fcntl.h>
#include <poll.h>
#include <unistd.h>
#include <string.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/uio.h>
#include <sys/mman.h>
#include <linux/input.h>

#define FB_W		(480)
#define FB_H		(272)
#define FB_DEPTH	(sizeof(short))
#define FB_SIZE		(FB_W * FB_H * FB_DEPTH)

#define TOUCH_XFIELDS	12
#define TOUCH_YFIELDS	5
#define TOUCH_FIELDS	(TOUCH_XFIELDS * TOUCH_YFIELDS)
#define TOUCH_MAX	4095

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
	return 0;
}

static inline void fb_set_pixel(int x, int y, int v)
{
	unsigned short *m = fb_mem;

	if (x >= FB_W || y >= FB_H || x < 0 || y < 0)
		return;

	m[((y * FB_W) + x)] = v;
}

static void fb_check_field(int fx, int fy, int v)
{
	int rw = (FB_W / TOUCH_XFIELDS);
	int rh = (FB_H / TOUCH_YFIELDS);
	int rx = rw * fx;
	int ry = rh * fy;
	int x, y;

	for (x = rx; x < rx + rw; x++)
		for (y = ry; y < ry + rh; y++)
			fb_set_pixel(x, y, v ? 0xff00 : 0x00ff);
}

static int test_touch(int fd)
{
	int ret, x, y, last_x = -1, last_y = -1;
	struct input_event ev;
	int cnt[TOUCH_XFIELDS][TOUCH_YFIELDS];

	ret = fb_init();
	if (ret < 0)
		return ret;

	/* require to see at least one event in each TOUCH_XFIELDS x TOUCH_YFIELDS fields */

	memset(cnt, 0, sizeof(cnt));
	for (x = 0; x < TOUCH_XFIELDS; x++)
		for (y = 0; y < TOUCH_YFIELDS; y++)
			fb_check_field(x, y, 0);

	for (;;) {
		int total = 0;

		ret = read(fd, &ev, sizeof(ev));
		if (ret < 0)
			return ret;

		if (ev.type != EV_ABS)
			continue;

		if (ev.code == ABS_X)
			last_x = ev.value;

		if (ev.code == ABS_Y)
			last_y = ev.value;

		if (last_x == -1 || last_y == -1)
			continue;

		x = (last_x * TOUCH_XFIELDS) / TOUCH_MAX;
		y = (last_y * TOUCH_YFIELDS) / TOUCH_MAX;

		/* just paranoia */
		if (x >= TOUCH_XFIELDS || y >= TOUCH_YFIELDS)
			continue;

		fb_check_field(x, y, 1);
		cnt[x][y] = 1;
		last_x = last_y = -1;

		for (x = 0; x < TOUCH_XFIELDS; x++)
			for (y = 0; y < TOUCH_YFIELDS; y++)
				total += cnt[x][y];

		printf("%d\n", (total * 100) / TOUCH_FIELDS);
		fflush(stdout);

		if (total == TOUCH_FIELDS)
			break;
	}

	return 0;
}

#define ROTARY_STEPS 24

static int _test_rotary(int fd, int expected)
{
	int cnt, ret;
	struct input_event ev;

	for (cnt = 0; cnt < ROTARY_STEPS;) {
		ret = read(fd, &ev, sizeof(ev));
		if (ret < 0)
			return ret;

		if (ev.type != EV_REL || ev.code != 0 || ev.value != expected)
			continue;

		cnt++;
	}

	return 0;
}

static int test_rotary(int fd)
{
	_test_rotary(fd, 1);
	_test_rotary(fd, -1);
	return 0;
}

static int test_rotary_cw(int fd)
{
	_test_rotary(fd, 1);
	return 0;
}

static int test_rotary_ccw(int fd)
{
	_test_rotary(fd, -1);
	return 0;
}

#define ABS(x) (((x) > 0) ? (x) : (-(x)))
#define UNSET 0xffff

static int test_accel(int fd, int axis, int thresh)
{
	int min = UNSET, max = UNSET;
	struct input_event ev;

	for (;;) {
		int ret = read(fd, &ev, sizeof(ev));
		if (ret < 0)
			return ret;

		if (ret != sizeof(ev))
			continue;

		if (ev.type != EV_ABS || ev.code != axis)
			continue;

		if (ev.value > max || max == UNSET)
			max = ev.value;

		if (ev.value < min || min == UNSET)
			min = ev.value;

		if (ABS(max - min) > thresh)
			return 0;
	}

	return 0;
}

static int test_key(int fd, int code)
{
	struct input_event ev;
	int ret, wanted_state = 1;

	for (;;) {
		ret = read(fd, &ev, sizeof(ev));
		if (ret < 0)
			return ret;

		if (ev.type != EV_KEY || ev.code != code)
			continue;

		if (ev.value == wanted_state) {
			if (wanted_state)
				wanted_state = 0;
			else
				break;
		}
	}

	return 0;
}

#define ACCEL_SIMPLE_THRESH	10
#define ACCEL_FULL_THRESH	100

static int test_accel_simple(int fd)
{
	return test_accel(fd, ABS_Z, ACCEL_SIMPLE_THRESH);
}

static int test_accel_full(int fd)
{
	return test_accel(fd, ABS_X, ACCEL_FULL_THRESH);
}

static int test_key_1(int fd)
{
	return test_key(fd, KEY_1);
}

static int test_key_2(int fd)
{
	return test_key(fd, KEY_2);
}

static int test_key_3(int fd)
{
	return test_key(fd, KEY_3);
}

static int test_key_4(int fd)
{
	return test_key(fd, KEY_4);
}

static int test_key_setup(int fd)
{
	return test_key(fd, KEY_SETUP);
}

static int test_key_power(int fd)
{
	return test_key(fd, KEY_POWER);
}

static int test_key_volume_down(int fd)
{
	return test_key(fd, KEY_VOLUMEDOWN);
}

static int test_key_volume_up(int fd)
{
	return test_key(fd, KEY_VOLUMEUP);
}

static int test_key_f3(int fd)
{
	return test_key(fd, KEY_F3);
}

static struct test_func {
	const char *name;
	const char *desc;
	const char *dev;
	int (* proc)(int fd);
} test_func[] = {
	{
		.name	= "touch",
		.desc	= "multi-point touch screen test",
		.dev	= "eeti_ts",
		.proc	= test_touch
	},
	{
		.name	= "rotary",
		.desc	= "rotary left/right 360° test",
		.dev	= "rotary",
		.proc	= test_rotary
	},
	{
		.name	= "rotary_cw",
		.desc	= "rotary clockwise test",
		.dev	= "rotary",
		.proc	= test_rotary_cw
	},
	{
		.name	= "rotary_ccw",
		.desc	= "rotary counter-clockwise test",
		.dev	= "rotary",
		.proc	= test_rotary_ccw
	},
	{
		.name	= "accel_simple",
		.desc	= "the knock-on-table test",
		.dev	= "ST LIS3LV02DL Accelerometer",
		.proc	= test_accel_simple
	},
	{
		.name	= "accel_full",
		.desc	= "accel rotation test",
		.dev	= "ST LIS3LV02DL Accelerometer",
		.proc	= test_accel_full
	},
	{
		.name	= "key_1",
		.desc	= "button 1 test",
		.dev	= "gpio-keys",
		.proc	= test_key_1
	},
	{
		.name	= "key_2",
		.desc	= "button 2 test",
		.dev	= "gpio-keys",
		.proc	= test_key_2
	},
	{
		.name	= "key_3",
		.desc	= "button 3 test",
		.dev	= "gpio-keys",
		.proc	= test_key_3
	},
	{
		.name	= "key_4",
		.desc	= "button 4 test",
		.dev	= "gpio-keys",
		.proc	= test_key_4
	},
	{
		.name	= "key_f3",
		.desc	= "key F3 test",
		.dev	= "gpio-keys",
		.proc	= test_key_f3
	},
	{
		.name	= "key_power",
		.desc	= "power button test",
		.dev	= "gpio-keys",
		.proc	= test_key_power
	},
	{
		.name	= "key_setup",
		.desc	= "setup button test",
		.dev	= "gpio-keys",
		.proc	= test_key_setup
	},
	{
		.name	= "key_volume_down",
		.desc	= "volume down button test",
		.dev	= "gpio-keys",
		.proc	= test_key_volume_down
	},
	{
		.name	= "key_volume_up",
		.desc	= "volume up button test",
		.dev	= "gpio-keys",
		.proc	= test_key_volume_up
	},
	{ .name = NULL }
};

static int open_input_dev(const char *name)
{
	int i, fd;
	char buf[128], tmp[128];

	for (i = 0; i < 128; i++) {
		snprintf(tmp, sizeof(tmp), "/dev/input/event%d", i);
		fd = open(tmp, O_RDONLY);

		if (fd < 0) {
			if (errno == -ENOENT)
				break;
			else
				continue;
		}

		if (ioctl(fd, EVIOCGNAME(sizeof(buf) - 1), buf) < 0) {
			close(fd);
			continue;
		}

		if (strncmp(buf, name, strlen(name)) == 0)
			break;
	}

	return fd;
}

int main(int argc, char **argv)
{
	int ret;
	struct test_func *t;

	for (t = test_func; t->name; t++)
		if (argv[1] && strcmp(t->name, argv[1]) == 0) {
			int fd = open_input_dev(t->dev);

			if (fd < 0) {
				perror("open");
				return 2;
			}

			ret = t->proc(fd);
			close(fd);
			return ret;
		}

	printf("Usage: %s <testname>\n", argv[0]);
	printf("Available tests:\n");

	for (t = test_func; t->name; t++)
		printf("\t%16s\t%s\n", t->name, t->desc);

	return 3;
}

