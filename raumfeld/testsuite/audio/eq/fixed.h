
#if !defined(FIXED_HEADERS_INCLUDED)
#define FIXED_HEADERS_INCLUDED

#include "common.h"

#if _USE_INTEGER == 1


#define _E			CONV(2.7182818)
#define _I_LN_10	CONV(0.4342944824)
#define _I_LN_2		CONV(1.4426950408)
#define _LN_2		CONV(0.693147180559)
#define _LD_E		CONV(1.4426950408889)

#define _ORDER		6
#define _BASE		CONV(1.0)
#define _LOGBASE	CONV(0);//CONV(-0.693147180)
#define _MIN_zINT32	0x80000000;
#define _MAX_zINT32	0x7fffffff;



 zINT32 fixlog10 (zINT32 x);

 zINT32 fixln (zINT32 x);

 zINT32 fixexp( zINT32 x);


zINT32 fixmul(zINT32 x, zINT32 y);

zINT32 fixlgh(zINT32 w, zINT32 x);

zINT32 fixmac2(zINT32 x1, zINT32 y1, zINT32 x2, zINT32 y2);

zINT32 fixmac3(zINT32 x1, zINT32 y1, zINT32 x2, zINT32 y2, zINT32 x3, zINT32 y3);

#endif

#endif
