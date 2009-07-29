/*
 * p0-eq.h
 *
 *  Created on: Jul 1, 2009
 *      Author: mhirsch
 */

#ifndef P0EQ_H_
#define P0EQ_H_

#define P0_TYPE_EQ            (p0_eq_get_type ())
#define P0_EQ(obj)            (G_TYPE_CHECK_INSTANCE_CAST ((obj), P0_TYPE_EQ, P0Eq))
#define P0_EQ_CLASS(klass)    (G_TYPE_CHECK_CLASS_CAST ((klass), P0_TYPE_EQ, P0EqClass))
#define P0_IS_EQ(obj)         (G_TYPE_CHECK_INSTANCE_TYPE ((obj), P0_TYPE_EQ))
#define P0_IS_EQ_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), P0_TYPE_EQ))
#define P0_EQ_GET_CLASS(obj)  (G_TYPE_INSTANCE_GET_CLASS ((obj), P0_TYPE_EQ, P0EqClass))

typedef struct _P0EqClass P0EqClass;

#include "eq/common.h"
#include "eq/zGlobals.h"

// global operation modes
#if !defined OP_MODES_DEFINED
#define OP_MODES_DEFINED

typedef enum
{
        ZP_MONO = 0,
        ZP_STEREO
}_Op_Mode;
#endif

// global input format
#if !defined INPUT_FORMAT_DEFINED
#define INPUT_FORMAT_DEFINED
typedef enum
{
        ZP_TYPE_FLOAT32 = 0,
        ZP_TYPE_INT32
}
_Input_Format;
#endif

// the different modes for the filters
typedef enum
{
        SHELVING = 0,
        PARAMETRIC
}_EQ_Modes;

// eq parameters
//- _EQ_Modes Filter1Mode : mode for Filter 1, either parametric or low shelving
//- float fFilter1MidFreq : mid (parametric) or cutoff (shelving) frequency for Filter 1
//- float fFilter1Q       : Q for parametric Filter 1
//- float fFilter1Gain    : Gain for Filter 1 in dB
//- float fFilter2MidFreq : mid frequency for parametric Filter 2
//- float fFilter2Q       : Q for parametric Filter 2
//- float fFilter2Gain    : Gain for parametric Filter 2 in dB
//- _EQ_Modes Filter3Mode : mode for Filter 3, either parametric or high shelving
//- float fFilter3MidFreq : mid (parametric) or cutoff (shelving) frequency for Filter 3
//- float fFilter3Q       : Q for parametric Filter 3
//- float fFilter3Gain    : Gain for parametric Filter 3 in dB
typedef struct
{
        _EQ_Modes Filter1Mode;
        float fFilter1MidFreq;
        float fFilter1Q;
        float fFilter1Gain;
        float fFilter2MidFreq;
        float fFilter2Q;
        float fFilter2Gain;
        _EQ_Modes Filter3Mode;
        float fFilter3MidFreq;
        float fFilter3Q;
        float fFilter3Gain;
} EQParameters;


struct _P0EqClass
{
  GObjectClass  parent_class;
};

struct _P0Eq
{
  GObject       parent_instance;
};


GType           p0_eq_get_type   (void) G_GNUC_CONST;

P0Eq *          p0_eq_new        (int sample_rate, int mode, int input_format);

gint32          p0_eq_process    (P0Eq* pEq, void *pBuffer, gint32 iBufferLength);
gint32          p0_eq_setparams  (P0Eq* pEq, EQParameters *pParameters);
gint32          p0_eq_getparams  (P0Eq* pEq, EQParameters *pParameters);
//gint32          p0_eq_reset      (P0Eq* pEq);
//gint32          p0_eq_bypass     (P0Eq* pEq, boolean bSetBypass);



#endif /* P0EQ_H_ */
