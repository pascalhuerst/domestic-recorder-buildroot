////////////////////////////////////////////////////////////////////////////////////
// /*! \file zDbgMacros.h global debug macros  */ 
//
/////////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (c) 2002  
//	zplane.development
//	Flohrer Lerch Schwerdtfeger GbR
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
////////////////////////////////////////////////////////////////////////////////////
//  CVS INFORMATION
//
//  $RCSfile: zDbgMacros.h,v $
//  $Author: lerch $
//  $Date: 2003/11/10 15:18:24 $
//
//  $Log: zDbgMacros.h,v $
//  Revision 1.1  2003/11/10 15:18:24  lerch
//  - updated project to newer zGlobals + zErrorCodes etc.
//  - added some floating-point RBJ-filters
//
//  Revision 1.1.1.1  2003/10/13 18:09:45  lerch
//  - first roughly test version of AutoFade module
//  - API needs parameter settings
//
//  Revision 1.2  2002/11/05 19:56:21  flea
//  removed mistake in ZASSERT for Release mode
//
//  Revision 1.2  2002/11/04 19:12:45  flea
//  added a function to check a zero crossing
//  implemented a rudimentary timecode decoder
//
//  Revision 1.1.1.1  2002/10/31 12:31:33  flea
//  no message
//
//
//
////////////////////////////////////////////////////////////////////////////////////


#ifndef _ZDBGMACROS_HEADERS_INCLUDED
#define _ZDBGMACROS_HEADERS_INCLUDED

#include "assert.h"


#ifdef NDEBUG
    #define ZASSERT(exp)  ((void)0)
#else
    #define ZASSERT(exp)  assert(!(exp))
#endif

#define ZCHECKA(exp)          \
{                             \
  if( exp )                   \
  {                           \
    ZASSERT( 1 );              \
    return _UNKNOWN_ERROR;    \
  }                           \
}

#define ZCHECKAR(exp, err)     \
{                             \
  if( exp )                   \
  {                           \
    ZASSERT( 1 );              \
    return err;               \
  }                           \
}

#define ZCHECK(exp)          \
{                             \
  if( exp )                   \
  {                           \
    return _UNKNOWN_ERROR;    \
  }                           \
}

#define ZCHECKR(exp, err)     \
{                             \
  if( exp )                   \
  {                           \
    return err;               \
  }                           \
}

#endif //_ZDBGMACROS_HEADERS_INCLUDED
