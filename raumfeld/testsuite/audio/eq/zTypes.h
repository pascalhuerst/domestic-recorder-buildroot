/////////////////////////////////////////////////////////////////////////////////////
// /*! \file zTypes.h global data typedefs */ 
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
//  $RCSfile: zTypes.h,v $ 
//  $Author: lerch $ 
//  $Date: 2003/11/10 15:18:24 $ 
//  
//  $Log: zTypes.h,v $
//  Revision 1.1  2003/11/10 15:18:24  lerch
//  - updated project to newer zGlobals + zErrorCodes etc.
//  - added some floating-point RBJ-filters
//
//  Revision 1.1.1.1  2003/10/13 18:09:45  lerch
//  - first roughly test version of AutoFade module
//  - API needs parameter settings
//
//  Revision 1.2  2002/10/31 19:47:35  flea
//  changed zBOOL from bool to int in order to be compliant to ANSI C
//
//  Revision 1.1.1.1  2002/10/31 12:31:33  flea
//  no message
//
//  Revision 1.3  2002/10/18 19:09:06  lerch
//  added cvs header
//
//
// 
////////////////////////////////////////////////////////////////////////////////////

#if !defined(__ZTYPES_HEADER_INCLUDED__)
#define __ZTYPES_HEADER_INCLUDED__


#define _SINGLE_PRECISION

#if defined(__BORLANDC__) || defined (__WATCOMC__) || defined(_MSC_VER) || defined(__ZTC__) || defined(__HIGHC__) || defined(__unix__) || defined(__unix)


  #include <inttypes.h>

    #ifdef FLOAT 
    #undef FLOAT 
    #endif
    #if defined (_SINGLE_PRECISION)
	// float with size depending on precision
	typedef	float  				zFLOAT;         /*!< float with size depending on precision */
    #else
	// float with size depending on precision
	typedef	double  			zFLOAT;         /*!< float with size depending on precision */
    #endif

    //zplane.typedefs

    // integer 8bit
	typedef char				zINT8;          /*!< integer 8 bit */
    // unsigned integer 8bit
	typedef unsigned char		zUINT8;         /*!< unsigned integer 8 bit */
    // integer 16bit
	typedef short				zINT16;         /*!< integer 16 bit */
    // unsigned integer 16bit
	typedef unsigned short		zUINT16;        /*!< unsigned integer 16 bit */
    // integer 32bit
	typedef int					zINT32;         /*!< integer 32 bit */
    // integer 64bit
	typedef int64_t				zINT64;         /*!< integer 64 bit */
    // unsigned integer 32bit
	typedef unsigned int		zUINT32;        /*!< unsigned integer 32 bit */	
    // unsigned integer 64bit
	typedef uint64_t		zUINT64;        /*!< unsigned integer 64 bit */
    // 32 bit float
	typedef float				zFLOAT32;       /*!< 32 bit float */
    // 64 bit float
	typedef double				zFLOAT64;       /*!< 64 bit float */
	// error value
	typedef zINT32				zERROR;         /*!< error value */
	// boolean type
	typedef int	        		zBOOL;          /*!< boolean type */
    // handle
	typedef zUINT32				zHANDLE;        /*!< handle */

	// void
	typedef void				zVOID;          /*!< void */

	// integer with default size
    typedef int                 zINT;           /*!< integer with default size */

#elif defined( __sun)
    typedef short               zINT16;
    typedef long                zINT32;
    typedef zINT32              zERROR;
    #error  PLEASE CHECK "zTypes.h" for correct typedefs!

#elif defined(__unix__) || defined(__unix)
    typedef short               zINT16;
    typedef long                zINT32;
    typedef zINT32              zERROR;
    #error  PLEASE CHECK "zTypes.h" for correct typedefs!

#elif defined(VMS) || defined(__VMS)
    typedef short               zINT16;
    typedef long                zINT32;
    typedef zINT32              zERROR;
    #error  PLEASE CHECK "zTypes.h" for correct typedefs!

#else
    #error  COMPILER NOT TESTED. "zTypes.h" needs to be updated
#endif

#ifndef NULL
    #define NULL    ((void *)0)
#endif

#endif  // __ZTYPES_HEADER_INCLUDED__
