/* gcc -o percent percent.c -Wall -static */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

int main(int argc, char **argv)
{
	int expected, r, count = 0, last_percent = -1;
	char buf[8192];

	if (argc < 2) {
		printf("Usage: %s <expected-lines>\n", argv[0]);
		return -1;
	}

	expected = strtol(argv[1], NULL, 10);

	while ((r = read(0, buf, sizeof(buf))) > 0) {
		count++;

		if (expected) {
			int percent = (count * 100) / expected;

			if (percent != last_percent) {
				printf("%d\n", percent);
				fflush(stdout);
			}

			last_percent = percent;
		}
	}

	if (!expected)
		printf("%d lines counted\n", count);

	return 0;
}

