#include <errno.h>
#include <fcntl.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdio.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>

#define GPIO(bank,n)  ((bank) * 32 + n)
#define N_ELEMENTS(a) (sizeof(a) / sizeof(a[0]))

struct test_gpio {
	int gpio;
	int connected_to;
	int pull;
};

enum {
	pull_up = 0,
	pull_down,
};

/*
 * This test assumes a test jig board that is connected to the 20-pin headers
 * on the baseboard. Each relevant I/O pin is electrically connected to a 2nd
 * one.
 *
 * The code walks the array of GPIOs and activates each one of them as output
 * while keeping the others as inputs. All other pins are measured and the
 * result is compared to the expected state.
 *
 * Note that some pins have pull-ups on the S800 module, while others have
 * pull-downs. Hence, the pinctrl matrix configures the internal pull
 * configuration to the same setup, and the .pull member of struct test_gpio
 * denotes which value to expect.
 */

static struct test_gpio test_gpio[] = {
	/* Front board */
	{ .gpio = GPIO(0, 5),	.connected_to = GPIO(1, 14),	.pull = pull_up },	/* SPI0_CS0 */
	{ .gpio = GPIO(0, 3),	.connected_to = GPIO(1, 15),	.pull = pull_up },	/* SPI0_D0 */
	{ .gpio = GPIO(0, 4),	.connected_to = GPIO(0, 11),	.pull = pull_up },	/* SPI0_D1 */
	{ .gpio = GPIO(2, 16),	.connected_to = GPIO(2, 17),	.pull = pull_up },
	{ .gpio = GPIO(0, 2),	.connected_to = GPIO(1, 12),	.pull = pull_up },	/* SPI0_SCLK */
	{ .gpio = GPIO(0, 6),	.connected_to = GPIO(1, 13),	.pull = pull_up },
	{ .gpio = GPIO(2, 17),	.connected_to = GPIO(2, 16),	.pull = pull_up },
	{ .gpio = GPIO(0, 11),	.connected_to = GPIO(0, 4),	.pull = pull_up },
	{ .gpio = GPIO(1, 12),	.connected_to = GPIO(0, 2),	.pull = pull_up },
	{ .gpio = GPIO(1, 15),	.connected_to = GPIO(0, 3),	.pull = pull_up },
	{ .gpio = GPIO(1, 14),	.connected_to = GPIO(0, 5),	.pull = pull_up },
	{ .gpio = GPIO(1, 13),	.connected_to = GPIO(0, 6),	.pull = pull_up },

	/* Amplifier board */
	{ .gpio = GPIO(1, 20),	.connected_to = GPIO(3, 15),	.pull = pull_up },
	{ .gpio = GPIO(1, 19),	.connected_to = GPIO(3, 14),	.pull = pull_up },
	{ .gpio = GPIO(1, 16),	.connected_to = GPIO(0, 9),	.pull = pull_up },
	{ .gpio = GPIO(0, 12),	.connected_to = GPIO(0, 8),	.pull = pull_up },	/* I2C2_SDA */
	{ .gpio = GPIO(0, 13),	.connected_to = GPIO(3, 16),	.pull = pull_up },	/* I2C2_SCL */
	{ .gpio = GPIO(0, 9),	.connected_to = GPIO(1, 16),	.pull = pull_up },	/* I2S_DATA_OUT3 */
	{ .gpio = GPIO(0, 8),	.connected_to = GPIO(0, 12),	.pull = pull_up },	/* I2S_DATA_OUT2 */
	//{ .gpio = GPIO(0, 10),	.connected_to = GPIO(3, 21),	.pull = pull_down },	/* I2S_DATA_OUT1 */
	{ .gpio = GPIO(3, 16),	.connected_to = GPIO(0, 13),	.pull = pull_up },	/* I2S_DATA_OUT0 */
	{ .gpio = GPIO(3, 15),	.connected_to = GPIO(1, 20),	.pull = pull_up },	/* I2S_WCLK_OUT */
	{ .gpio = GPIO(3, 14),	.connected_to = GPIO(1, 19),	.pull = pull_up },	/* I2S_BCLK_OUT */
	//{ .gpio = GPIO(3, 21),	.connected_to = GPIO(0, 10),	.pull = pull_down },	/* I2S_MCLK_OUT */
};

#define N_GPIO N_ELEMENTS(test_gpio)

static int regulator = GPIO(1, 18);

static int gpio_export(int gpio)
{
	char tmp[10];
	int fd, ret;

	fd = open("/sys/class/gpio/export", O_WRONLY);
	if (fd < 0)
		return -errno;

	snprintf(tmp, sizeof(tmp), "%d\n", gpio);
	ret = write(fd, tmp, strlen(tmp));

	close(fd);
	if (ret != strlen(tmp))
		return -errno;

	return 0;
}

static int gpio_set_output(int gpio, bool out)
{
	char tmp[40];
	int fd, ret;

	snprintf(tmp, sizeof(tmp), "/sys/class/gpio/gpio%d/direction", gpio);

	fd = open(tmp, O_WRONLY);
	if (fd < 0)
		return -errno;

	snprintf(tmp, sizeof(tmp), "%s\n", out ? "out" : "in");
	ret = write(fd, tmp, strlen(tmp));

	close(fd);
	if (ret != strlen(tmp))
		return -errno;

	return 0;
}

static int gpio_get_value(int gpio)
{
	char tmp[40];
	int fd, ret;

	snprintf(tmp, sizeof(tmp), "/sys/class/gpio/gpio%d/value", gpio);

	fd = open(tmp, O_RDONLY);
	if (fd < 0)
		return -errno;

	ret = read(fd, tmp, 1);
	close(fd);

	if (ret < 0)
		return -errno;

	return tmp[0] == '0' ? 0 : 1;
}

static int gpio_set_value(int gpio, bool value)
{
	char tmp[40];
	int fd, ret;

	snprintf(tmp, sizeof(tmp), "/sys/class/gpio/gpio%d/value", gpio);

	fd = open(tmp, O_WRONLY);
	if (fd < 0)
		return -errno;

	snprintf(tmp, sizeof(tmp), "%d\n", value ? 1 : 0);
	ret = write(fd, tmp, strlen(tmp));

	close(fd);
	if (ret != strlen(tmp))
		return -errno;

	return 0;
}

int main(void)
{
	int i, j, error = 0;
	bool verbose = true;

	for (i = 0; i < N_GPIO; i++)
		gpio_export(test_gpio[i].gpio);

	gpio_export(regulator);

	gpio_set_output(regulator, true);
	gpio_set_value(regulator, 1);

	for (i = 0; i < N_GPIO; i++) {
		if (verbose)
			printf("Testing GPIO%d_%d ... ",
				test_gpio[i].gpio / 32,
				test_gpio[i].gpio % 32);

		for (j = 0; j < N_GPIO; j++) {
			if (i == j) {
				gpio_set_output(test_gpio[j].gpio, true);
				gpio_set_value(test_gpio[j].gpio, test_gpio[j].pull);
			} else {
				gpio_set_value(test_gpio[j].gpio, !test_gpio[j].pull);
				gpio_set_output(test_gpio[j].gpio, false);
			}
		}

		for (j = 0; j < N_GPIO; j++) {
			int expected;

			if (i == j)
				continue;

			/*
			 * At this point, all but one pin are configured to input. That one
			 * pin is configured to drive against its pull resistor.
			 *
			 * All input pins must remain unchanged, and their value must
			 * correspond to the connected pull resistor; except for the one
			 * that is hard-wired to the GPIO under test. This one must
			 * show exactly the opposite.
			 */

			if (test_gpio[i].connected_to == test_gpio[j].gpio)
				expected = test_gpio[j].pull;
			else
				expected = !test_gpio[j].pull;

			if (gpio_get_value(test_gpio[j].gpio) != expected) {
				printf("Oops! GPIO%d_%d expected to be %s, but is %s\n",
					test_gpio[j].gpio / 32,
					test_gpio[j].gpio % 32,
					expected ? "high" : "low",
					expected ? "low" : "high");
				error++;
			}
		}

		printf("%d errors\n", error);

		if (error > 0)
			break;
	}

	return error;
}
