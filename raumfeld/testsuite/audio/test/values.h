/*
 * values.h
 *
 *  Created on: Jul 2, 2009
 *      Author: mhirsch
 */

#ifndef VALUES_H_
#define VALUES_H_

#define CALIBRATION_CYCLES 2000
#define BYTESPERFRAME 4
#define SAMPLERATE 44100
#define SINUSTEST1 2500
#define SINUSTEST2 440
#define SINUSTEST3 0

#define CAPTUREPERIODFRAMES  4096
#define MINDB0 -5.8
#define MAXDB0 -4.4
//#define MINDB0 -80.0
//#define MAXDB0  0.0
#define MINDB0SILENCE -90.0
#define MAXDB0SILENCE -65.0
#define MINDB0FILTERSILENCE -90.0
#define MAXDB0FILTERSILENCE -40.0


#define TESTLENGTH 4
#define DEVICENAMEPLAYBACK "hw:0"
#define DEVICENAMECAPTURE "hw:0"


typedef struct
{
        int          Freq;
        unsigned int Amplitude;
        int          mute;
        double       minDB;
        double       maxDB;
        int          doFilter;

} test_params_t;


#endif /* VALUES_H_ */
