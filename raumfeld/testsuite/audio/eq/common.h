#if !defined(_COMMON_HEADER_INCLUDED)
#define _COMMON_HEADER_INCLUDED

#include "math.h"
#include "zGlobals.h"

//#define PROTECT

#define _PLAYTIME		60*15

#define _USE_INTEGER	1

#if _USE_INTEGER == 1

	#define ZNUM		zINT32
#define _EXPONENT   23

#include "fixed.h"

	#define _MIN_ZNUM	0x80000000;
	#define _MAX_ZNUM	0x7fffffff;
	#define _MAX_RNG
	#define _MIN_RNG
	#define _ILN_10		(ZNUM)		CONV(0.4342944824)
	#define	_LN_10		(ZNUM)		CONV(2.3025850929)
#ifdef ARM
	#define	MUL(a,b)	(ZNUM)		fixmul(a,b)
	#define MAC2(a,b,c,d)		(ZNUM)	fixmac2(a,b,c,d)
	#define MAC3(a,b,c,d,e,f)	(ZNUM)	fixmac3(a,b,c,d,e,f)
#else
	#define	MUL(a,b)	(ZNUM)		((((zINT64)(a) * (zINT64)(b))) >> _EXPONENT)
	#define MAC2(a,b,c,d)		(ZNUM)	ADD( MUL(a,b), MUL(c,d))
	#define MAC3(a,b,c,d,e,f)	(ZNUM)	ADD3( MUL(a,b), MUL(c,d), MUL(e,f))
#endif
	#define LOG(a)		(ZNUM)		fixlog10(a)
	#define ILOG(a)		(ZNUM)		(fixexp(MUL((a),_LN_10)))

	#define MULIF(a,b)  (ZNUM)		((((((zINT64)(a))<<_EXPONENT) * (zINT64)(b))) >> _EXPONENT)
	#define	ADD(a,b)	(ZNUM)		( (a) + (b) )
	#define ADD3(a,b,c) (ZNUM)		( (a) + (b) + (c) )
	#define SUB(a,b)	(ZNUM)		( (a) - (b) )
	#define DIV(a,b)	(ZNUM)		( (((zINT64)(a))<<_EXPONENT) / ((zINT64)(b)) )
	#define TAN(a)		(ZNUM)		(CONV(tan   (ICONV(a) )))
	#define SQRT(a)		(ZNUM)		(CONV(sqrt  (ICONV(a) )))

	#define CONV(a)		(ZNUM)		((a) * (zFLOAT32)(1<<_EXPONENT))

	#define ICONV(a)	(zFLOAT32)	((a)/((zFLOAT)(1<<_EXPONENT)))
	#define EXP(a)		(ZNUM)		CONV(exp(ICONV(a)))
	#define RANGE24(a)	(ZNUM) ((a))

	#define SAT(a)		(ZNUM) ((a))

        #undef _SQRT2
        #undef _PI

	#define _SQRT2		(ZNUM) CONV(1.4142135623730950)
	#define _PI		(ZNUM) CONV(3.1415926535897932)
    #define _LN2		(ZNUM) CONV(0.69314718055994530942)

#else

	#define ZNUM zFLOAT32

	#define _ILN_10		(ZNUM)	(0.4342944824)
	#define	_LN_10		(ZNUM)	(2.3025850929)
	#define _MIN_ZNUM	-((2^31)-1);
	#define _MAX_ZNUM	(2^31)-1;
	#define _MAX_RNG	8388607.0
	#define _MIN_RNG	-8388607.0

	#define	MUL(a,b)	(ZNUM) ( (a) * (b) )
	#define SAT(a)		(a)

	#define	MULIF(a,b)	(ZNUM) ( (a) * (b) )
	#define	ADD(a,b)	(ZNUM) ( (a) + (b) )
	#define ADD3(a,b,c) (ZNUM) ( (a) + (b) + (c) )

	#define MAC2(a,b,c,d)		(ZNUM)	ADD( MUL(a,b), MUL(c,d))
	#define MAC3(a,b,c,d,e,f)	(ZNUM)	ADD3( MUL(a,b), MUL(c,d), MUL(e,f))

	#define SUB(a,b)	(ZNUM) ( (a) - (b) )
	#define DIV(a,b)	(ZNUM) ( (a) / (b) )
	#define TAN(a)		(ZNUM) tan(a)
	#define SQRT(a)		(ZNUM) sqrt(a)

	#define LOG(a)		(ZNUM) (_ILN_10 * log(a))
	#define ILOG(a)		(ZNUM) exp((a)*_LN_10)
	#define CONV(a)		(ZNUM)(a)
	#define ICONV(a)	(ZNUM)(a)
	#define EXP(a)		(ZNUM) exp(a)

	#define RANGE24(a)	(ZNUM) ((a) * (1.1920930376163765926810017443897e-7))
	#define SQRT(a)		(ZNUM) sqrt(a)
//	#define _SQRT2		(ZNUM) 1.4142135623730950
//    #define _PI			(ZNUM) 3.1415926535897932
    #define _LN2		(ZNUM) 0.69314718055994530942

#endif



//#define ABS(a)			((a) < (ZNUM)0 ? -(a) : (a))
//#define MAX(a,b)		((a) < (b) ? (b) : (a))
//#define MIN(a,b)		(((a) > (b)) ? (b) : (a))



//#define		NULL	0
//#define		FALSE	0
//#define		TRUE	1


#endif // _COMMON_HEADER_INCLUDED
