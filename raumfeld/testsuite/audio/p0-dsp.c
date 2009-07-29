/*
 * p0-dsp.c
 *
 *  Created on: May 20, 2009
 *      Author: mhirsch
 */

#include <stdio.h>
#include "p0-dsp.h"

void p0_dsp_get_minmax(short *buffer, int num_frames, int *abs_max_left, int *abs_max_right)
{
	int i;

	*abs_max_left = *abs_max_right = 0;

	for (i = 0; i < num_frames * 2; i+=2)
	{
		short val = buffer[i] > 0 ? buffer[i] : -buffer[i];

		if(val > 0 && val > *abs_max_left)
			*abs_max_left = val;

		val = buffer[i+1] > 0 ? buffer[i] : -buffer[i];

		if(val > 0 && val > *abs_max_right)
			*abs_max_right = val;

	}

}

