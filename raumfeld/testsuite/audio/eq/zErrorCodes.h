/////////////////////////////////////////////////////////////////////////////////////
// /*! \file zErrorCodes.h global error codes */ 
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
//  $RCSfile: zErrorCodes.h,v $ 
//  $Author: lerch $ 
//  $Date: 2003/11/10 15:18:24 $ 
//  
//  $Log: zErrorCodes.h,v $
//  Revision 1.1  2003/11/10 15:18:24  lerch
//  - updated project to newer zGlobals + zErrorCodes etc.
//  - added some floating-point RBJ-filters
//
//  Revision 1.1.1.1  2003/10/13 18:09:45  lerch
//  - first roughly test version of AutoFade module
//  - API needs parameter settings
//
//  Revision 1.5  2003/02/24 10:28:03  lerch
//  - added TO_LESS_INPUT_DATA
//
//  Revision 1.4  2003/02/24 10:24:07  lerch
//  - added non-initialized instance/session (from zAAC)
//
//  Revision 1.3  2003/01/21 10:18:08  lerch
//  added _AUDIO_DEVICE_FAILED error
//
//  Revision 1.2  2002/10/31 17:06:17  lerch
//  reformatted/added doxygen comments
//
//  Revision 1.1.1.1  2002/10/31 12:31:33  flea
//  no message
//
//  Revision 1.2  2002/10/18 19:09:06  lerch
//  added cvs header
//
//
// 
////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////
// Headerfile zErrorCodes.h defines zError-Codes
// 0000000: No Error
//
// 1000000: Memory Errors
// 2000000: Math Errors
// 3000000: File Errors
// 4000000: Hardware Errors
// 5000000: Function Errors (wrong parameters etc.)
// 6000000: OS Errors
// 7000000: User Errors
//
// 9999999: Unknown Error
////////////////////////////////////////////////////////////////////
#if !defined(__ERRORCODES_HEADER_INCLUDED__)
#define __ERRORCODES_HEADER_INCLUDED__


////////////////////////////////////////////////////////////////////
// No Errors
#define     _NO_ERROR               0                           /*!< no error */

// Memory Errors
#define     _MEMORY_ERROR_BASE      1000000                     //!< all memory related errors are counted from here*/
#define     _MEM_ALLOC_FAILED       (_MEMORY_ERROR_BASE+1)      /*!< memory allocation failed */

// Math Errors
#define     _MATH_ERROR_BASE        2000000                     //!< all math related errors are counted from here*/
#define     _DIV_BY_ZERO            (_MATH_ERROR_BASE+1)        /*!< division by zero */
#define     _PRECISION_ERROR        (_MATH_ERROR_BASE+2)        /*!< unsufficient precision */

// File Errors
#define     _FILE_ERROR_BASE        3000000                     //!< all file IO related errors are counted from here*/
#define     _FILE_OPEN_ERROR        (_FILE_ERROR_BASE+1)        /*!< file could not be opened */
#define     _FILE_CLOSE_ERROR       (_FILE_ERROR_BASE+2)        /*!< file could not be closed */
#define     _FILE_READ_ERROR        (_FILE_ERROR_BASE+3)        /*!< file could not be read */
#define     _FILE_WRITE_ERROR       (_FILE_ERROR_BASE+4)        /*!< file could not be written */
#define     _END_OF_FILE_REACHED    (_FILE_ERROR_BASE+5)        /*!< end of file reached */
#define     _UNKNOWN_FILE_FORMAT    (_FILE_ERROR_BASE+6)        /*!< unknown file format */

// Hardware Errors
#define     _HARDWARE_ERROR_BASE    4000000                     //!< all hardware related errors are counted from here*/
#define     _NO_SOUND               (_HARDWARE_ERROR_BASE+1)    /*!< no sound device available */
#define     _NO_MMX                 (_HARDWARE_ERROR_BASE+2)    /*!< cpu supports no MMX */
#define     _NO_ISSE                (_HARDWARE_ERROR_BASE+3)    /*!< cpu supports no ISSE */
#define     _NO_3DNOW               (_HARDWARE_ERROR_BASE+4)    /*!< cpu supports no 3DNow */
#define     _AUDIO_DEVICE_FAILED    (_HARDWARE_ERROR_BASE+5)    /*!< opening of audio device failed */

// Function Errors
#define     _FUNCTION_ERROR_BASE    5000000                     //!< all function related errors are counted from here*/
#define     _FUNCTION_NOT_READY     (_FUNCTION_ERROR_BASE+1)    /*!< function not ready, please call later */
#define     _ILLEGAL_FUNCTION_CALL  (_FUNCTION_ERROR_BASE+2)    /*!< this function call was not allowed */
#define     _INVALID_FUNCTION_ARGS  (_FUNCTION_ERROR_BASE+3)    /*!< one or more function arguments are not valid */
#define     _INVALID_SAMPL_FREQ     (_FUNCTION_ERROR_BASE+4)    /*!< the sample frequency is not valid */
#define     _INVALID_NUM_OF_CHANNEL (_FUNCTION_ERROR_BASE+5)    /*!< number of channels is not valid */
#define     _INVALID_BITRESOLUTION  (_FUNCTION_ERROR_BASE+6)    /*!< number of bits per sample is not valid */
#define     _INVALID_TYPE           (_FUNCTION_ERROR_BASE+7)    /*!< type is not valid */
#define     _NO_BUFFER_GENERATED    (_FUNCTION_ERROR_BASE+8)    /*!< buffer was not generated */
#define     _NO_BUFFER_AVAILABLE    (_FUNCTION_ERROR_BASE+9)    /*!< no buffer is available */
#define     _NO_CONNECTION          (_FUNCTION_ERROR_BASE+10)   /*!< is not connected */
#define     _FEEDBACK               (_FUNCTION_ERROR_BASE+11)   /*!< is feedback! */
#define     _ALREADY_CONNECTED      (_FUNCTION_ERROR_BASE+12)   /*!< is already connected */
#define     _WIRING_CONFLICT        (_FUNCTION_ERROR_BASE+13)   /*!< error with wiring */   
#define     _INSTANCE_NOT_INITIALIZED (_FUNCTION_ERROR_BASE+15) /*!< illegal access to non-initialized instance */
#define     _SESSION_NOT_INITIALIZED  (_FUNCTION_ERROR_BASE+16) /*!< illegal access to non-initialized session */
#define		_TO_LESS_INPUT_DATA		(_FUNCTION_ERROR_BASE+17)   /*!< need more input data */	

// OS Errors
#define     _OS_ERROR_BASE          6000000                     //!< all os related errors are counted from here*/
#define     _THREAD_CREATION_FAILED (_OS_ERROR_BASE+1)          /*!< could not create thread */
#define     _SYSTEM_TO_SLOW         (_OS_ERROR_BASE+2)          /*!< system is too slow */

// User Errors
#define     _USER_ERROR_BASE        7000000                     //!< all user related errors are counted from here*/
#define     _MISSING_CL_ARG         (_USER_ERROR_BASE+1)        /*!< command line argument is missing */
#define     _WRONG_CL_ARG           (USER_ERROR_BASE+2)         /*!< one or more command line arguments are wrong */

// Unknown Errors
#define     _UNKNOWN_ERROR          9999999                     /*!< unknown error */

#endif // !defined(__ERRORCODES_HEADER_INCLUDED__)