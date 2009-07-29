/////////////////////////////////////////////////////////////////////////////////////
// /*! \file zGlobals.h global constants and macros */ 
//
/////////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (c) 2002  
//  zplane.development
//  Flohrer Lerch Schwerdtfeger GbR
//
//  CONFIDENTIALITY:
//
//      This file is the property of zplane.development.
//      It contains information that is regarded as privilege
//      and confidential by zplane.development.
//      It may not be publicly disclosed or communicated in any way without 
//      prior written authorization by zplane.development.
//      It cannot be copied, used, or modified without obtaining
//      an authorization from zplane.development.
//      If such an authorization is provided, any modified version or
//      copy of the software has to contain this header.
//
//  WARRANTIES: 
//      This software is provided as << is >>, zplane.development 
//      makes no warranty express or implied with respect to this software, 
//      its fitness for a particular purpose or its merchantability. 
//      In no case, shall zplane.development be liable for any 
//      incidental or consequential damages, including but not limited 
//      to lost profits.
//
//      zplane.development shall be under no obligation or liability in respect of 
//      any infringement of statutory monopoly or intellectual property 
//      rights of third parties by the use of elements of such software 
//      and User shall in any case be entirely responsible for the use 
//      to which he puts such elements. 
//
/////////////////////////////////////////////////////////////////////////////////////
//  CVS INFORMATION
//
//  $RCSfile: zGlobals.h,v $ 
//  $Author: lerch $ 
//  $Date: 2003/11/10 15:18:24 $ 
//  
//  $Log: zGlobals.h,v $
//  Revision 1.1  2003/11/10 15:18:24  lerch
//  - updated project to newer zGlobals + zErrorCodes etc.
//  - added some floating-point RBJ-filters
//
//  Revision 1.1.1.1  2003/10/13 18:09:45  lerch
//  - first roughly test version of AutoFade module
//  - API needs parameter settings
//
//  Revision 1.5  2002/11/05 16:52:26  flea
//  removed little error in comment
//
//  Revision 1.2  2002/11/04 19:12:46  flea
//  added a function to check a zero crossing
//  implemented a rudimentary timecode decoder
//
//  Revision 1.3  2002/10/31 17:06:17  lerch
//  reformatted/added doxygen comments
//
//  Revision 1.2  2002/10/31 13:48:57  flea
//  removed some missing #endif bug
//
//  Revision 1.1.1.1  2002/10/31 12:31:33  flea
//  no message
//
//  Revision 1.4  2002/10/25 17:15:16  lerch
//  added in many files doxygen compatible descriptions of methods, classes, etc.
//
//  Revision 1.3  2002/10/24 18:23:48  lerch
//  added SWAP()-Macro
//
//  Revision 1.2  2002/10/18 19:09:06  lerch
//  added cvs header
//
//
// 
////////////////////////////////////////////////////////////////////////////////////

#if !defined(__ZGLOBALS_HEADER_INCLUDED__)
#define __ZGLOBALS_HEADER_INCLUDED__

// include system header
#include <math.h>

// include zplane.header
#include "zTypes.h"
#include "zErrorCodes.h"
#include "zDbgMacros.h"



#if defined(_TRUE)
#undef _TRUE
#endif
#if defined(_FALSE)
#undef _FALSE
#endif
#define _TRUE	1                                                   //!< true 
#define _FALSE	!(_TRUE)                                            //!< false 

/////////////////////////////////////////////////////////////////////////////////////
// math constants
#if !defined(_EULER)
#define	_EULER					(zFLOAT)(2.7182818284590452354)     //!< euler 
#endif
#if !defined(_PI)
#define	_PI						(zFLOAT)(3.14159265358979323846)    //!< pi    
#endif
#if !defined(_PI2)
#define	_PI2    				(zFLOAT)(1.570796326794897)         //!< pi/2        
#endif
#if !defined(_PI4)
#define	_PI4    				(zFLOAT)(7.853981633974483e-001)    //!< pi/4    
#endif
#if !defined(_2PI)
#define	_2PI					(zFLOAT)(6.28318530717958647692)    //!< 2*pi 	
#endif
#if !defined(_LN10)
#define _LN10                   (zFLOAT)(2.30258509299405)          //!< ln(10)        
#endif
#if !defined(_INVLN10)
#define	_INVLN10				(zFLOAT)(0.4342944819032518)        //!< 1/ln(10) 		
#endif
#if !defined(_10INVLN10)
#define _10INVLN10              (zFLOAT)(4.342944819032518)         //!< 10/ln(10)  
#endif
#if !defined(_20INVLN10)
#define _20INVLN10              (zFLOAT)(8.685889638065035)         //!< 20/ln(10) 
#endif
#if !defined(_INVLN2)
#define	_INVLN2					(zFLOAT)(1.442695040888963)			//!< 1/ln(2) 
#endif
#if !defined(_SQRT2)
#define	_SQRT2					(zFLOAT)(1.414213562373095)         //!< sqrt(2) 
#endif   
#if !defined(_INVSQRT2)
#define	_INVSQRT2       		(zFLOAT)(7.071067811865475e-001)    //!< 1/sqrt(2) 
#endif
#if !defined(_SQRT10)
#define	_SQRT10					(zFLOAT)(3.162277660168380)         //!< sqrt(10) 
#endif
#if !defined(_SQRT3)
#define	_SQRT3					(zFLOAT)(1.732050807568877)         //!< sqrt(3) 
#endif
#if !defined(_SQRT5)
#define	_SQRT5					(zFLOAT)(2.236067977499790)         //!< sqrt(5) 
#endif
#if !defined(_SQRT4)
#define	_SQRT4					(zFLOAT)(2.0)                       //!< sqrt(4)    
#endif


/////////////////////////////////////////////////////////////////////////////////////
// programming constants
#if !defined(_FLT_MIN)
#define _FLT_MIN                1.175494351e-38F
#endif

/////////////////////////////////////////////////////////////////////////////////////
// macros

    //! returns the absolute value of a
#define ZABS(a)                 (((a) > (0)) ? (a) : -(a))
    //! find minimum of a and b
#define ZMIN(a,b)               (((a) < (b)) ? (a) : (b))
    //! find maxmimum of a and b
#define ZMAX(a,b)               (((a) > (b)) ? (a) : (b))
    //! calc sqrt(a)
#define ZSQRT(a)                (zFLOAT)(sqrt(a))
    //! calc 10^a
#define ZPOW10(a)                (zFLOAT)(exp(_LN10*(a)))
    //! swap values of a and b
#define SWAPINT(a,b)            {zINT iTmp = (a); (a) = (b); (b) = (iTmp);}



#endif // #if !defined(__ZGLOBALS_HEADER_INCLUDED__)