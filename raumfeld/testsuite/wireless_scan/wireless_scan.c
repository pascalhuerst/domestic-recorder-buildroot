#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

static void print_net(char *mode, char *essid, char *quality)
{
	if (!mode || !essid || !quality)
		return;

	if (strcmp(mode, "Ad-Hoc") != 0)
		return;

	// strip leading and trailing '"'
	if (*essid == '"')
		essid++;

	if (essid[strlen(essid) - 1])
		essid[strlen(essid) - 1] = '\0';

	printf("%s\t%s\n", quality, essid);
}

int main(int argc, const char **argv)
{
	char buf[1024];
	char *mode = NULL;
	char *essid = NULL;
	char *quality = NULL;

	while (fgets(buf, sizeof(buf), stdin)) {
		char *tmp, *s = buf;

		while (*s == ' ' || *s == '\t')
			s++;

		while  (s[strlen(s) - 1] == '\n' ||
			s[strlen(s) - 1] == '\r')
			s[strlen(s) - 1] = '\0';

		if (strncmp(s, "Cell ", 5) == 0) {
			print_net(mode, essid, quality);
			mode = essid = quality = NULL;
		}

		if (strncmp(s, "Mode:", 5) == 0) {
			s += 5;
			mode = strdup(s);
		}

		if (strncmp(s, "ESSID:", 6) == 0) {
			s += 6;
			essid = strdup(s);
		}

		if ((tmp = strstr(s, "Signal level="))) {
			s = tmp;
			s +=  strlen("Signal level=");
			tmp = strchr(s, ' ');
			if (tmp)
				*tmp = '\0';
			quality = strdup(s);
		}
	}

	print_net(mode, essid, quality);

	return 0;
}
