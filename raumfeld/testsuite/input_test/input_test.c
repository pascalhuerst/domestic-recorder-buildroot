/* gcc -Wall -o input_dump input_dump.c */

#include <stdio.h>
#include <fcntl.h>
#include <poll.h>
#include <unistd.h>
#include <string.h>
#include <sys/types.h>
#include <sys/uio.h>
#include <linux/input.h>

#define TOUCH_XFIELDS	8
#define TOUCH_YFIELDS	3
#define TOUCH_MAX	4095

static int test_touch(int fd)
{
	int ret, x, y, i, last_x = -1, last_y = -1;
	struct input_event ev;
	int cnt[TOUCH_XFIELDS][TOUCH_YFIELDS];

	/* require to see at least one event in each 10x4 fields */

	memset(cnt, 0, sizeof(cnt));

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

		cnt[x][y]++;
		last_x = last_y = -1;


		for (i = 0; i < sizeof(cnt) / sizeof(cnt[0]); i++)
			if (cnt[i][0])
				total++;

		printf("%d\n", (total * 100) / i);
		fflush(stdout);

		if (total == i)
			break;
	}

	return 0;
}

#define ROTARY_STEPS 24

static int test_rotary(int fd)
{
	int cnt, ret, expected = 1;
	struct input_event ev;

	for (cnt = 0; cnt < ROTARY_STEPS * 2;) {
		ret = read(fd, &ev, sizeof(ev));
		if (ret < 0)
			return ret;

		if (ev.type != EV_REL || ev.code != 0 || ev.value != expected)
			continue;

		cnt++;

		/* output percentage for dialog */
		printf("%d\n", (cnt * 100) / ROTARY_STEPS/2);
		fflush(stdout);

		if (cnt == ROTARY_STEPS)
			expected *= -1;
	}

	return 0;
}

#define ABS(x) (((x) > 0) ? (x) : (-(x)))
static int test_accel(int fd, int thresh)
{
	int ret;
	struct input_event ev;

	for (;;) {
		ret = read(fd, &ev, sizeof(ev));
		if (ret < 0)
			return ret;

		if (ev.type == EV_ABS && ABS(ev.value) > thresh)
			return 0;
	}

	return 0;
}

#define ACCEL_SIMPLE_THRESH	20
#define ACCEL_FULL_THRESH	1000

static int test_accel_simple(int fd)
{
	return test_accel(fd, ACCEL_SIMPLE_THRESH);
}

static int test_accel_full(int fd)
{
	return test_accel(fd, ACCEL_FULL_THRESH);
}

static struct test_func {
	const char *name;
	const char *desc;
	const char *dev;
	int (* proc)(int fd);
} test_func[] = {
	{
		.name	= "touch",
		.desc	= "\tmulti-point touch screen test",
		.dev	= "/dev/input/event3",
		.proc	= test_touch
	},
	{
		.name	= "rotary",
		.desc	= "\trotary left/right 360° test",
		.dev	= "/dev/input/event1",
		.proc	= test_rotary
	},
	{
		.name	= "accel_simple",
		.desc	= "the knock-on-table test",
		.dev	= "/dev/input/event2",
		.proc	= test_accel_simple
	},
	{
		.name	= "accel_full",
		.desc	= "accel rotation test",
		.dev	= "/dev/input/event2",
		.proc	= test_accel_full
	},
	{ .name = NULL }
};

int main(int argc, char **argv)
{
	int ret;
	struct test_func *t;

	for (t = test_func; t->name; t++)
		if (argv[1] && strcmp(t->name, argv[1]) == 0) {
			int fd = open(t->dev, O_RDONLY);

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
		printf("\t%s\t%s\n", t->name, t->desc);
	
	return 3;
}

