/*
 * p0-eq.c
 *
 *  Created on: Jul 1, 2009
 *      Author: mhirsch
 */


#include <glib-object.h>

#include "p0-renderer-types.h"
#include "p0-eq.h"


typedef struct
{
        zINT32 m_iSampleRate;
        zBOOL m_bBypass;
        zINT64 m_lLimit;
        ZNUM m_Filter1_FIR_Coeff[3], m_Filter1_IIR_Coeff[2], m_Filter2_FIR_Coeff[3], m_Filter2_IIR_Coeff[2], m_Filter3_FIR_Coeff[3], m_Filter3_IIR_Coeff[2];

        _EQ_Modes m_Filter1Mode, m_NewFilter1Mode, m_Filter3Mode, m_NewFilter3Mode;

        ZNUM m_Filter1MidFreq, m_NewFilter1MidFreq, m_Filter1Q, m_NewFilter1Q, m_Filter1Gain, m_NewFilter1Gain;

        ZNUM m_Filter2MidFreq, m_NewFilter2MidFreq, m_Filter2Q, m_NewFilter2Q, m_Filter2Gain, m_NewFilter2Gain;

        ZNUM m_Filter3MidFreq, m_NewFilter3MidFreq, m_Filter3Q, m_NewFilter3Q, m_Filter3Gain, m_NewFilter3Gain;

        zBOOL m_bChanged;

        ZNUM m_Filter1_FIR_Array[2][2], m_Filter1_IIR_Array[2][2], m_Filter2_FIR_Array[2][2], m_Filter2_IIR_Array[2][2], m_Filter3_FIR_Array[2][2], m_Filter3_IIR_Array[2][2];

} P0EqPrivate;

//static zINT64 m_lCounter;


enum
{
        PROP_0,
        PROP_SAMPLERATE,
        PROP_MODE,
        PROP_INPUT_FORMAT
};

#define P0_EQ_GET_PRIVATE(obj) G_TYPE_INSTANCE_GET_PRIVATE ((obj), P0_TYPE_EQ, P0EqPrivate)
#define parent_class p0_eq_parent_class

static GObject *p0_eq_constructor       (GType type, guint n_params, GObjectConstructParam *params);
static void p0_eq_finalize              (GObject *object);
static void p0_eq_get_property          (GObject *object, guint property_id, GValue *value, GParamSpec *pspec);
static void p0_eq_set_property          (GObject *object, guint property_id, const GValue *value, GParamSpec *pspec);
static void p0_eq_calc_coeffs           (P0Eq* pthis);
static void p0_eq_update_parameters     (P0Eq* pthis);

zERROR      p0_eq_set_parameters        (P0Eq *object,_EQ_Modes Filter1Mode, zFLOAT32 fFilter1MidFreq, zFLOAT32 fFilter1Q, zFLOAT32 fFilter1Gain,
                                         zFLOAT32 fFilter2MidFreq, zFLOAT32 fFilter2Q, zFLOAT32 fFilter2Gain,
                                         _EQ_Modes Filter3Mode, zFLOAT32 fFilter3MidFreq, zFLOAT32 fFilter3Q, zFLOAT32 fFilter3Gain);
zERROR      p0_eq_get_parameters        (P0Eq *object,_EQ_Modes *Filter1Mode, zFLOAT32 *fFilter1MidFreq, zFLOAT32 *fFilter1Q, zFLOAT32 *fFilter1Gain,
                                         zFLOAT32 *fFilter2MidFreq, zFLOAT32 *fFilter2Q, zFLOAT32 *fFilter2Gain,
                                         _EQ_Modes *Filter3Mode, zFLOAT32 *fFilter3MidFreq, zFLOAT32 *fFilter3Q, zFLOAT32 *fFilter3Gain);



G_DEFINE_TYPE (P0Eq, p0_eq, G_TYPE_OBJECT)
;

static void p0_eq_class_init(P0EqClass *klass)
{
        GObjectClass *object_class = G_OBJECT_CLASS (klass);
        object_class->constructor = p0_eq_constructor;
        object_class->finalize = p0_eq_finalize;
        object_class->get_property = p0_eq_get_property;
        object_class->set_property = p0_eq_set_property;

        g_object_class_install_property(object_class,
                                        PROP_SAMPLERATE,
                                        g_param_spec_int("samplerate",
                                                         NULL,
                                                         NULL,
                                                         0,
                                                         96000,
                                                         44100,
                                                         G_PARAM_READWRITE | G_PARAM_CONSTRUCT_ONLY));

        g_object_class_install_property(object_class,
                                        PROP_MODE,
                                        g_param_spec_int("mode",
                                                         NULL,
                                                         NULL,
                                                         0,
                                                         1,
                                                         0,
                                                         G_PARAM_READWRITE | G_PARAM_CONSTRUCT_ONLY));

        g_object_class_install_property(object_class,
                                        PROP_INPUT_FORMAT,
                                        g_param_spec_int("input-format",
                                                         NULL,
                                                         NULL,
                                                         0,
                                                         1,
                                                         1,
                                                         G_PARAM_READWRITE | G_PARAM_CONSTRUCT_ONLY));

        g_type_class_add_private(object_class,
                                 sizeof(P0EqPrivate));
}

static GObject *
p0_eq_constructor(GType type,
                  guint n_params,
                  GObjectConstructParam *params)
{
        GObject *object = G_OBJECT_CLASS (parent_class)->constructor(type,
                                                                     n_params,
                                                                     params);



        return object;
}

static void p0_eq_get_property(GObject *object,
                               guint property_id,
                               GValue *value,
                               GParamSpec *pspec)
{
        P0EqPrivate *priv = P0_EQ_GET_PRIVATE (object);

        switch (property_id)
        {
        case PROP_SAMPLERATE:
                g_value_set_int(value,
                                priv->m_iSampleRate);
                break;

        case PROP_MODE:
                g_value_set_int(value,
                                ZP_STEREO); /* fixme */
                break;

        case PROP_INPUT_FORMAT:
                g_value_set_int(value,
                                   ZP_TYPE_INT32); /* fixme */
                break;
        }
}

static void p0_eq_set_property(GObject *object,
                               guint property_id,
                               const GValue *value,
                               GParamSpec *pspec)
{
        P0EqPrivate *priv = P0_EQ_GET_PRIVATE (object);

        switch (property_id)
        {
        case PROP_SAMPLERATE:
                priv->m_iSampleRate = g_value_get_int(value);
                break;

        case PROP_MODE:
                /* fixme */
                break;

        case PROP_INPUT_FORMAT:
                /* fixme */
                break;
        }
}

static void p0_eq_init(P0Eq *pThis)
{
        P0EqPrivate *priv = P0_EQ_GET_PRIVATE (pThis);

        priv->m_iSampleRate = 44100;
        priv->m_lLimit = priv->m_iSampleRate * _PLAYTIME;
        priv->m_bChanged = FALSE;

        //setting default values
        priv->m_bBypass = FALSE;

        priv->m_Filter1Mode = SHELVING;
        priv->m_Filter1MidFreq = 500.0F;
        priv->m_Filter1Q = 1.0F;
        priv->m_Filter1Gain = 0.0F;

        priv->m_Filter2MidFreq = 3000.0F;
        priv->m_Filter2Q = 1.0F;
        priv->m_Filter2Gain = 0.0F;

        priv->m_Filter3Mode = SHELVING;
        priv->m_Filter3MidFreq = 9000.0F;
        priv->m_Filter3Q = 1.0F;
        priv->m_Filter3Gain = 0.0F;

}

static void p0_eq_finalize(GObject *pThis)
{
        //P0EqPrivate *priv = P0_EQ_GET_PRIVATE (pThis);
        G_OBJECT_CLASS (p0_eq_parent_class)->finalize(pThis);
}

P0Eq *
p0_eq_new(int sample_rate,
          int mode,
          int input_format)
{
        return g_object_new(P0_TYPE_EQ,
                            "samplerate",
                            sample_rate,
                            "mode",
                            mode,
                            "input-format",
                            input_format,
                            NULL);
}

gint32
p0_eq_setparams (P0Eq* pEq, EQParameters *pParameters)
{


        zINT32           iErr;

        P0EqPrivate *priv = P0_EQ_GET_PRIVATE (pEq);

        if (pParameters->fFilter1Gain > 18.0F)
        {
                pParameters->fFilter1Gain = 18.0F;
        } else
                if (pParameters->fFilter1Gain < -18.0F)
                {
                        pParameters->fFilter1Gain = -18.0F;
                }

        if (pParameters->fFilter1MidFreq > (0.5F * (ZNUM) priv->m_iSampleRate) - 0.05F * (ZNUM) priv->m_iSampleRate)
        {
                pParameters->fFilter1MidFreq = (ZNUM)(0.5F * (ZNUM) priv->m_iSampleRate) - 0.05F * (ZNUM) priv->m_iSampleRate;
        } else
                if (pParameters->fFilter1MidFreq < 10.0F)
                {
                        pParameters->fFilter1MidFreq = 10.0F;
                }

        if (pParameters->fFilter1Q > 100.0F)
        {
                pParameters->fFilter1Q = 100.0F;
        } else
                if (pParameters->fFilter1Q < 0.2F)
                {
                        pParameters->fFilter1Q = 0.2F;
                }

        if (pParameters->fFilter2Gain > 18.0F)
        {
                pParameters->fFilter2Gain = 18.0F;
        } else
                if (pParameters->fFilter2Gain < -18.0F)
                {
                        pParameters->fFilter2Gain = -18.0F;
                }

        if (pParameters->fFilter2MidFreq > (0.5F * (ZNUM) priv->m_iSampleRate) - 0.05F * (ZNUM) priv->m_iSampleRate)
        {
                pParameters->fFilter2MidFreq = (ZNUM)(0.5F * (ZNUM) priv->m_iSampleRate) - 0.05F * (ZNUM) priv->m_iSampleRate;
        } else
                if (pParameters->fFilter2MidFreq < 10.0F)
                {
                        pParameters->fFilter2MidFreq = 10.0F;
                }

        if (pParameters->fFilter2Q > 100.0F)
        {
                pParameters->fFilter2Q = 100.0F;
        } else
                if (pParameters->fFilter2Q < 0.2F)
                {
                        pParameters->fFilter2Q = 0.2F;
                }

        if (pParameters->fFilter3Gain > 18.0F)
        {
                pParameters->fFilter3Gain = 18.0F;
        } else
                if (pParameters->fFilter3Gain < -18.0F)
                {
                        pParameters->fFilter3Gain = -18.0F;
                }

        if (pParameters->fFilter3MidFreq > (0.5F * (ZNUM) priv->m_iSampleRate) - 0.05F * (ZNUM) priv->m_iSampleRate)
        {
                pParameters->fFilter3MidFreq = (ZNUM)(0.5F * (ZNUM) priv->m_iSampleRate) - 0.05F * (ZNUM) priv->m_iSampleRate;
        } else
                if (pParameters->fFilter3MidFreq < 10.0F)
                {
                        pParameters->fFilter3MidFreq = 10.0F;
                }

        if (pParameters->fFilter3Q > 100.0F)
        {
                pParameters->fFilter3Q = 100.0F;
        } else
                if (pParameters->fFilter3Q < 0.2F)
                {
                        pParameters->fFilter3Q = 0.2F;
                }


        iErr = p0_eq_set_parameters(pEq,
                        (_EQ_Modes) pParameters->Filter1Mode,
                        pParameters->fFilter1MidFreq,
                        pParameters->fFilter1Q,
                        pParameters->fFilter1Gain,
                        pParameters->fFilter2MidFreq,
                        pParameters->fFilter2Q,
                        pParameters->fFilter2Gain,
                        (_EQ_Modes) pParameters->Filter3Mode,
                        pParameters->fFilter3MidFreq,
                        pParameters->fFilter3Q,
                        pParameters->fFilter3Gain);
        return iErr;
};

gint32
p0_eq_getparams  (P0Eq* pEq,
                  EQParameters *pParameters)
{

//        P0EqPrivate     *priv = P0_EQ_GET_PRIVATE (pEq);
        zINT32           iErr;


        iErr =  p0_eq_get_parameters(pEq,
                       (_EQ_Modes*) &pParameters->Filter1Mode,
                        &pParameters->fFilter1MidFreq,
                        &pParameters->fFilter1Q,
                        &pParameters->fFilter1Gain,
                        &pParameters->fFilter2MidFreq,
                        &pParameters->fFilter2Q,
                        &pParameters->fFilter2Gain,
                        (_EQ_Modes*) &pParameters->Filter3Mode,
                        &pParameters->fFilter3MidFreq,
                        &pParameters->fFilter3Q,
                        &pParameters->fFilter3Gain);

        return iErr;
};



static void
p0_eq_calc_coeffs(P0Eq* pThis)
{
        P0EqPrivate *priv = P0_EQ_GET_PRIVATE (pThis);

#if _FILTTYPE == ZOELZER

        ZNUM    a, b, c, d, e, f,
                        K, K2, K3,
                        VK2, VQ, QINV,
                        denom, denom1, V;

        // calculate LOW-Coeffs

                // calculate constant factors
                V               =       ILOG( DIV( ABS(priv->m_Filter1Gain), CONV(20.0)) );
                K               =       TAN ( MUL( priv->m_Filter1MidFreq, _PI) );
                K2              =       MUL ( K, K );
                K3              =       SQRT( MUL(CONV(2.0), V) );
                VK2             =       MUL ( V, K2);
                VQ              =       DIV     ( V, priv->m_Filter1Q );
                QINV    =   DIV ( CONV(1.0), priv->m_Filter1Q );

                if(priv->m_Filter1Mode == SHELVING)
                {


                        if(priv->m_Filter1Gain > CONV(0.0))
                        {
                                denom   =       DIV( CONV(1.0), ADD3(CONV(1.0)  , MUL(_SQRT2, K), K2));
                                a               =       MUL (K3 , K);
                                b               =       VK2;
                                c               =       SUB (VK2, CONV(1.0));
                                d               =   SUB (K2 , CONV(1.0));
                                e               =       MUL (_SQRT2,K);
                                f               =       K2;
                        }
                        else
                        {
                                denom   =       DIV( CONV(1.0), ADD3(CONV(1.0), MUL(K3, K), VK2));
                                a               =       MUL(_SQRT2, K);
                                b               =       K2;
                                c               =       SUB(K2,  CONV(1.0));
                                d               =       SUB(VK2, CONV(1.0));
                                e               =       MUL(K3, K);
                                f               =       VK2;
                        }

                        // calculate coeffs

                                priv->m_Filter1_FIR_Coeff[0]  = MUL( ADD3(CONV(1.0), a, b     )               , denom);
                                priv->m_Filter1_FIR_Coeff[1]  = MUL( MUL (CONV(2.0), c        )               , denom);
                                priv->m_Filter1_FIR_Coeff[2]  = MUL( ADD (SUB(CONV(1.0), a), b)       , denom);

                                priv->m_Filter1_IIR_Coeff[0]  = -MUL( MUL (CONV(2.0), d)                      , denom);
                                priv->m_Filter1_IIR_Coeff[1]  = -MUL( ADD(SUB(CONV(1.0), e), f)       , denom);


                }
                else    // Parametric filter
                {


                        if(priv->m_Filter1Gain > CONV(0.0))
                        {
                                denom   =       DIV( CONV(1.0), ADD3(CONV(1.0)   , MUL(QINV, K), K2     ));
                                a               =       MUL (VQ  , K            );
                                b               =   SUB (K2      , CONV(1.0));
                                c               =   MUL (QINV, K                );

                        }
                        else
                        {

                                denom   =       DIV( CONV(1.0), ADD3(CONV(1.0), MUL(VQ  , K), K2));
                                a               =       MUL (QINV       , K             );
                                b               =   SUB (K2             , CONV(1.0)     );
                                c               =   MUL (VQ             , K             );

                        }

                        // calculate coeffs
                        priv->m_Filter1_FIR_Coeff[0]  = MUL( ADD3(CONV(1.0), a         , K2) , denom);
                        priv->m_Filter1_FIR_Coeff[1]  = MUL( MUL (CONV(2.0)            , b ) , denom);
                        priv->m_Filter1_FIR_Coeff[2]  = MUL( ADD ( SUB(CONV(1.0),a), K2) , denom);

                        priv->m_Filter1_IIR_Coeff[0]  = -MUL( MUL(CONV(2.0), b)                 , denom);
                        priv->m_Filter1_IIR_Coeff[1]  = -MUL( ADD(SUB(CONV(1.0), c), K2), denom);
                }

        // calculate MID-Coeffs

                // calculate constant factors
                V               =       ILOG( DIV( ABS(priv->m_Filter2Gain), CONV(20.0)) );
                K               =       TAN ( MUL( priv->m_Filter2MidFreq, _PI) );
                K2              =       MUL ( K, K );
                K3              =       SQRT( MUL(CONV(2.0), V) );
                VQ              =       DIV     ( V,   priv->m_Filter2Q );
                QINV    =   DIV ( CONV(1.0), priv->m_Filter2Q );

                if(priv->m_Filter2Gain > CONV(0.0))
                {

                                denom   =       DIV( CONV(1.0), ADD3(CONV(1.0)   , MUL(QINV, K), K2     ));
                                a               =       MUL (VQ  , K            );
                                b               =   SUB (K2      , CONV(1.0));
                                c               =   MUL (QINV, K                );
                }
                else
                {

                                denom   =       DIV( CONV(1.0), ADD3(CONV(1.0), MUL(VQ  , K), K2));
                                a               =       MUL (QINV       , K             );
                                b               =   SUB (K2             , CONV(1.0)     );
                                c               =   MUL (VQ             , K             );
                }

                        // calculate coeffs
                        priv->m_Filter2_FIR_Coeff[0]  = MUL( ADD3(CONV(1.0), a         , K2) , denom);
                        priv->m_Filter2_FIR_Coeff[1]  = MUL( MUL (CONV(2.0)            , b ) , denom);
                        priv->m_Filter2_FIR_Coeff[2]  = MUL( ADD ( SUB(CONV(1.0),a), K2) , denom);

                        priv->m_Filter2_IIR_Coeff[0]  = -MUL( MUL(CONV(2.0), b)                 , denom);
                        priv->m_Filter2_IIR_Coeff[1]  = -MUL( ADD(SUB(CONV(1.0), c), K2), denom);

        // calculate HIGH-Coeffs

                // calculate constant factors
                V               =       ILOG( DIV( ABS(priv->m_Filter3Gain), CONV(20.0)) );
                K               =       TAN ( MUL( priv->m_Filter3MidFreq, _PI) );
                K2              =       MUL ( K, K );
                K3              =       SQRT( MUL(CONV(2.0), V) );
                VK2             =       MUL ( K, K3);
                VQ              =       DIV     ( V, priv->m_Filter3Q );
                QINV    =   DIV ( CONV(1.0), priv->m_Filter3Q );

                if(priv->m_Filter3Mode == SHELVING)
                {

                        if(priv->m_Filter3Gain > CONV(0.0))
                        {

                                denom   =       DIV( CONV(1.0), ADD3(CONV(1.0)  , MUL(_SQRT2, K), K2));
                                denom1  =       denom;
                                a               =       V;
                                b               =       VK2;
                                c               =       SUB (K2, V);
                                d               =   SUB (K2 , CONV(1.0));
                                e               =       MUL (_SQRT2,K);
                                f               =       K2;
                        }
                        else
                        {

                                denom   =       DIV( CONV(1.0), ADD3(V, VK2, K2));
                                denom1  =       DIV( CONV(1.0), ADD3(CONV(1.0), MUL(SQRT( DIV(CONV(2.0),V)),K)  , DIV(K2, V)));
                                a               =       CONV(1.0);
                                b               =       MUL(_SQRT2,K);
                                c               =       SUB(K2,  CONV(1.0));
                                d               =       SUB(DIV(K2,V), CONV(1.0));
                                e               =       MUL(SQRT(DIV(CONV(2.0),V)), K);
                                f               =       DIV(K2, V);
                        }

                        // calculate coeffs
                                priv->m_Filter3_FIR_Coeff[0]  = MUL( ADD3(a, b, K2    )       , denom);
                                priv->m_Filter3_FIR_Coeff[1]  = MUL( MUL (CONV(2.0), c        )               , denom);
                                priv->m_Filter3_FIR_Coeff[2]  = MUL( ADD (SUB(a, b), K2)      , denom);

                                priv->m_Filter3_IIR_Coeff[0]  = -MUL( MUL (CONV(2.0), d)                      , denom1);
                                priv->m_Filter3_IIR_Coeff[1]  = -MUL( ADD(SUB(CONV(1.0), e), f)       , denom1);

                }
                else    // Parametric filter
                {


                        if(priv->m_Filter3Gain > CONV(0.0))
                        {

                                denom   =       DIV( CONV(1.0), ADD3(CONV(1.0)   , MUL(QINV, K), K2     ));
                                a               =       MUL (VQ  , K            );
                                b               =   SUB (K2      , CONV(1.0)            );
                                c               =   MUL (QINV, K                );
                        }
                        else
                        {

                                denom   =       DIV( CONV(1.0), ADD3(CONV(1.0), MUL(VQ  , K), K2));
                                a               =       MUL (QINV       , K             );
                                b               =   SUB (K2             , CONV(1.0));
                                c               =   MUL (VQ             , K             );
                        }

                        // calculate coeffs

                        priv->m_Filter3_FIR_Coeff[0]  = MUL( ADD3(CONV(1.0), a         , K2) , denom);
                        priv->m_Filter3_FIR_Coeff[1]  = MUL( MUL (CONV(2.0)            , b ) , denom);
                        priv->m_Filter3_FIR_Coeff[2]  = MUL( ADD ( SUB(CONV(1.0),a), K2) , denom);

                        priv->m_Filter3_IIR_Coeff[0]  = -MUL( MUL(CONV(2.0), b)                 , denom);
                        priv->m_Filter3_IIR_Coeff[1]  = -MUL( ADD(SUB(CONV(1.0), c), K2), denom);

                }
#elif _FILTTYPE == RBJ // does not work in fixed point


    ZNUM A, omega, sn, cs, alpha, beta;
    ZNUM a0, a1, a2, b0, b1, b2;
    // calculate LOW-Coeffs

                // calculate constant factors
        A = (ZNUM)pow(10., priv->m_Filter1Gain /40);
        omega = 2 * _PI * priv->m_Filter1MidFreq;
        sn = (ZNUM)sin(omega);
        cs = (ZNUM)cos(omega);
        alpha = sn * (ZNUM)sinh(_LN2 /priv->m_Filter1Q * omega /sn);
        beta = (ZNUM)sqrt(A + A);

        if(priv->m_Filter1Mode == SHELVING)
        {

            b0 = A * ((A + 1) - (A - 1) * cs + beta * sn);
            b1 = 2 * A * ((A - 1) - (A + 1) * cs);
            b2 = A * ((A + 1) - (A - 1) * cs - beta * sn);
            a0 = (A + 1) + (A - 1) * cs + beta * sn;
            a1 = -2 * ((A - 1) + (A + 1) * cs);
            a2 = (A + 1) + (A - 1) * cs - beta * sn;

            // calculate coeffs
            priv->m_Filter1_FIR_Coeff[0]      = DIV( b0, a0);
            priv->m_Filter1_FIR_Coeff[1]      = DIV( b1, a0);
            priv->m_Filter1_FIR_Coeff[2]      = DIV( b2, a0);

            priv->m_Filter1_IIR_Coeff[0]      = DIV( -a1, a0);
            priv->m_Filter1_IIR_Coeff[1]      = DIV( -a2, a0);


        }
                else    // Parametric filter
                {


            b0 = 1 + (alpha * A);
            b1 = -2 * cs;
            b2 = 1 - (alpha * A);
            a0 = 1 + (alpha /A);
            a1 = -2 * cs;
            a2 = 1 - (alpha /A);

                        // calculate coeffs
            priv->m_Filter1_FIR_Coeff[0]      = DIV( b0, a0);
            priv->m_Filter1_FIR_Coeff[1]      = DIV( b1, a0);
            priv->m_Filter1_FIR_Coeff[2]      = DIV( b2, a0);

            priv->m_Filter1_IIR_Coeff[0]      = DIV( -a1, a0);
            priv->m_Filter1_IIR_Coeff[1]      = DIV( -a2, a0);
        }

        // calculate MID-Coeffs

                // calculate constant factors
        A = (ZNUM)pow(10, priv->m_Filter2Gain /40);
        omega = 2 * _PI * priv->m_Filter2MidFreq;
        sn = (ZNUM)sin(omega);
        cs = (ZNUM)cos(omega);
        alpha = sn * (ZNUM)sinh(_LN2 /(priv->m_Filter2Q) * omega /sn);
        beta = (ZNUM)sqrt(A + A);

        b0 = 1 + (alpha * A);
        b1 = -2 * cs;
        b2 = 1 - (alpha * A);
        a0 = 1 + (alpha /A);
        a1 = -2 * cs;
        a2 = 1 - (alpha /A);

        // calculate coeffs
        priv->m_Filter2_FIR_Coeff[0]  = DIV( b0, a0);
        priv->m_Filter2_FIR_Coeff[1]  = DIV( b1, a0);
        priv->m_Filter2_FIR_Coeff[2]  = DIV( b2, a0);

        priv->m_Filter2_IIR_Coeff[0]  = DIV( -a1, a0);
        priv->m_Filter2_IIR_Coeff[1]  = DIV( -a2, a0);

        // calculate HIGH-Coeffs

        // calculate constant factors
        A = (ZNUM)pow(10, priv->m_Filter3Gain /40);
        omega = 2 * _PI * priv->m_Filter3MidFreq;
        sn = (ZNUM)sin(omega);
        cs = (ZNUM)cos(omega);
        alpha = sn * (ZNUM)sinh(_LN2 /priv->m_Filter3Q * omega /sn);
        beta = (ZNUM)sqrt(A + A);

                if(priv->m_Filter3Mode == SHELVING)
                {

            b0 = A * ((A + 1) + (A - 1) * cs + beta * sn);
            b1 = -2 * A * ((A - 1) + (A + 1) * cs);
            b2 = A * ((A + 1) + (A - 1) * cs - beta * sn);
            a0 = (A + 1) - (A - 1) * cs + beta * sn;
            a1 = 2 * ((A - 1) - (A + 1) * cs);
            a2 = (A + 1) - (A - 1) * cs - beta * sn;

            // calculate coeffs
            priv->m_Filter3_FIR_Coeff[0]      = DIV( b0, a0);
            priv->m_Filter3_FIR_Coeff[1]      = DIV( b1, a0);
            priv->m_Filter3_FIR_Coeff[2]      = DIV( b2, a0);

            priv->m_Filter3_IIR_Coeff[0]      = DIV( -a1, a0);
            priv->m_Filter3_IIR_Coeff[1]      = DIV( -a2, a0);

                }
                else    // Parametric filter
                {


            b0 = 1 + (alpha * A);
            b1 = -2 * cs;
            b2 = 1 - (alpha * A);
            a0 = 1 + (alpha /A);
            a1 = -2 * cs;
            a2 = 1 - (alpha /A);

            // calculate coeffs
            priv->m_Filter3_FIR_Coeff[0]      = DIV( b0, a0);
            priv->m_Filter3_FIR_Coeff[1]      = DIV( b1, a0);
            priv->m_Filter3_FIR_Coeff[2]      = DIV( b2, a0);

            priv->m_Filter3_IIR_Coeff[0]      = DIV( -a1, a0);
            priv->m_Filter3_IIR_Coeff[1]      = DIV( -a2, a0);

                }

// does not work in fixed point
// does only support presence filters in the moment
#elif _FILTTYPE == MOORER

        ZNUM a0, a1, a2, b0, b2;
        double a,A,F,xfmbw,C,tmp,alphan,alphad,asq,F2,a2plus1,ma2plus1;
        // calculate LOW-Coeffs


        if(priv->m_Filter1Mode == SHELVING)
        {


            // calculate coeffs
            priv->m_Filter1_FIR_Coeff[0]      = 0;
            priv->m_Filter1_FIR_Coeff[1]      = 0;
            priv->m_Filter1_FIR_Coeff[2]      = 0;

            priv->m_Filter1_IIR_Coeff[0]      = 0;
            priv->m_Filter1_IIR_Coeff[1]      = 0;

        }
        else    // Parametric filter
        {

            // calculate constant factors

            a = (ZNUM)tan(_PI*(priv->m_Filter1MidFreq-0.25));
            asq = a*a;
            A = (ZNUM)pow(10.0,priv->m_Filter1Gain/20.0);
            if ((priv->m_Filter1Gain < 6.0) && (priv->m_Filter1Gain > -6.0)) F = sqrt(A);
            else if (A > 1.0) F = A/sqrt(2.0);
            else F = (ZNUM)(A*sqrt(2.0));
            xfmbw = bw2angle((ZNUM)a,priv->m_Filter1MidFreq/priv->m_Filter1Q);

            C = 1.0/tan(2.0*_PI*xfmbw);
            F2 = F*F;
            tmp = A*A - F2;
            if (fabs(tmp) <= -1e38) alphad = C;
            else alphad = sqrt(C*C*(F2-1.0)/tmp);
            alphan = A*alphad;

            a2plus1 = 1.0 + asq;
            ma2plus1 = 1.0 - asq;
            a0 = (ZNUM)(a2plus1 + alphan*ma2plus1);
            a1 = (ZNUM)(4.0*a);
            a2 = (ZNUM)(a2plus1 - alphan*ma2plus1);

            b0 = (ZNUM)(a2plus1 + alphad*ma2plus1);
            b2 = (ZNUM)(a2plus1 - alphad*ma2plus1);


            // calculate coeffs
            priv->m_Filter1_FIR_Coeff[0]      = DIV( a0, b0);
            priv->m_Filter1_FIR_Coeff[1]      = DIV( a1, b0);
            priv->m_Filter1_FIR_Coeff[2]      = DIV( a2, b0);

            priv->m_Filter1_IIR_Coeff[0]      = -priv->m_Filter1_FIR_Coeff[1];
            priv->m_Filter1_IIR_Coeff[1]      = DIV( -b2, b0);

        }

        // calculate MID-Coeffs

        // calculate constant factors

        a = (ZNUM)tan(_PI*(priv->m_Filter2MidFreq-0.25));
        asq = a*a;
        A = (ZNUM)pow(10.0,priv->m_Filter2Gain/20.0);
        if ((priv->m_Filter2Gain < 6.0) && (priv->m_Filter2Gain > -6.0)) F = sqrt(A);
        else if (A > 1.0) F = A/sqrt(2.0);
        else F = (ZNUM)(A*sqrt(2.0));
        xfmbw = bw2angle((ZNUM)a,priv->m_Filter2MidFreq/priv->m_Filter2Q);

        C = 1.0/tan(2.0*_PI*xfmbw);
        F2 = F*F;
        tmp = A*A - F2;
        if (fabs(tmp) <= -1e38) alphad = C;
        else alphad = sqrt(C*C*(F2-1.0)/tmp);
        alphan = A*alphad;

        a2plus1 = 1.0 + asq;
        ma2plus1 = 1.0 - asq;
        a0 = (ZNUM)(a2plus1 + alphan*ma2plus1);
        a1 = (ZNUM)(4.0*a);
        a2 = (ZNUM)(a2plus1 - alphan*ma2plus1);

        b0 = (ZNUM)(a2plus1 + alphad*ma2plus1);
        b2 = (ZNUM)(a2plus1 - alphad*ma2plus1);


        // calculate coeffs
        priv->m_Filter2_FIR_Coeff[0]  = DIV( a0, b0);
        priv->m_Filter2_FIR_Coeff[1]  = DIV( a1, b0);
        priv->m_Filter2_FIR_Coeff[2]  = DIV( a2, b0);

        priv->m_Filter2_IIR_Coeff[0]  = -priv->m_Filter2_FIR_Coeff[1];
        priv->m_Filter2_IIR_Coeff[1]  = DIV( -b2, b0);

        // calculate HIGH-Coeffs


        if(priv->m_Filter3Mode == SHELVING)
        {

            // calculate coeffs
            priv->m_Filter1_FIR_Coeff[0]      = 0;
            priv->m_Filter1_FIR_Coeff[1]      = 0;
            priv->m_Filter1_FIR_Coeff[2]      = 0;

            priv->m_Filter1_IIR_Coeff[0]      = 0;
            priv->m_Filter1_IIR_Coeff[1]      = 0;
        }
        else    // Parametric filter
        {

            // calculate constant factors

            a = (ZNUM)tan(_PI*(priv->m_Filter3MidFreq-0.25));
            asq = a*a;
            A = (ZNUM)pow(10.0,priv->m_Filter3Gain/20.0);
            if ((priv->m_Filter3Gain < 6.0) && (priv->m_Filter3Gain > -6.0)) F = sqrt(A);
            else if (A > 1.0) F = A/sqrt(2.0);
            else F = (ZNUM)(A*sqrt(2.0));
            xfmbw = bw2angle((ZNUM)a,priv->m_Filter3MidFreq/priv->m_Filter3Q);

            C = 1.0/tan(2.0*_PI*xfmbw);
            F2 = F*F;
            tmp = A*A - F2;
            if (fabs(tmp) <= -1e38) alphad = C;
            else alphad = sqrt(C*C*(F2-1.0)/tmp);
            alphan = A*alphad;

            a2plus1 = 1.0 + asq;
            ma2plus1 = 1.0 - asq;
            a0 = (ZNUM)(a2plus1 + alphan*ma2plus1);
            a1 = (ZNUM)(4.0*a);
            a2 = (ZNUM)(a2plus1 - alphan*ma2plus1);

            b0 = (ZNUM)(a2plus1 + alphad*ma2plus1);
            b2 = (ZNUM)(a2plus1 - alphad*ma2plus1);


            // calculate coeffs
            priv->m_Filter3_FIR_Coeff[0]      = DIV( a0, b0);
            priv->m_Filter3_FIR_Coeff[1]      = DIV( a1, b0);
            priv->m_Filter3_FIR_Coeff[2]      = DIV( a2, b0);

            priv->m_Filter3_IIR_Coeff[0]      = -priv->m_Filter3_FIR_Coeff[1];
            priv->m_Filter3_IIR_Coeff[1]      = DIV( -b2, b0);


        }

#endif // #if _FILTTYPE == ?
}

static void
p0_eq_update_parameters (P0Eq* pThis)
{
        P0EqPrivate *priv = P0_EQ_GET_PRIVATE (pThis);

        if (priv->m_bChanged)
        {

                // LOW-parameters
                priv->m_Filter1Mode = priv->m_NewFilter1Mode;
                priv->m_Filter1MidFreq = priv->m_NewFilter1MidFreq;
                priv->m_Filter1Q = priv->m_NewFilter1Q;
                priv->m_Filter1Gain = priv->m_NewFilter1Gain;

                //MID-parameters
                priv->m_Filter2MidFreq = priv->m_NewFilter2MidFreq;
                priv->m_Filter2Q = priv->m_NewFilter2Q;
                priv->m_Filter2Gain = priv->m_NewFilter2Gain;

                //HIGH-parameters
                priv->m_Filter3Mode = priv->m_NewFilter3Mode;
                priv->m_Filter3MidFreq = priv->m_NewFilter3MidFreq;
                priv->m_Filter3Q = priv->m_NewFilter3Q;
                priv->m_Filter3Gain = priv->m_NewFilter3Gain;

                p0_eq_calc_coeffs(pThis);

                priv->m_bChanged = FALSE;
        }

}

gint32          p0_eq_process (P0Eq* pEq,
                               void *pBuffer,
                               gint32 iLength)
{

        P0EqPrivate *priv = P0_EQ_GET_PRIVATE (pEq);

        ZNUM currentSample, y;
        zINT32 i;
        zINT32 *psBuffer = (zINT32*) pBuffer;

        p0_eq_update_parameters(pEq);

        // filter input signal
#ifdef PROTECT
        priv->m_lCounter += iLength;

        if (priv->m_lCounter<priv->m_lLimit)
        {
#endif
        if (!priv->m_bBypass)
        {
                // LOW
                for (i = 0; i < iLength << 1; i += 2)
                {
                        currentSample = ((ZNUM) psBuffer[i]); // left channel


                        y = MAC3(currentSample,
                                 priv->m_Filter1_FIR_Coeff[0],
                                 priv->m_Filter1_FIR_Array[0][0],
                                 priv->m_Filter1_FIR_Coeff[1],
                                 priv->m_Filter1_FIR_Array[0][1],
                                 priv->m_Filter1_FIR_Coeff[2]);

                        priv->m_Filter1_FIR_Array[0][1] = priv->m_Filter1_FIR_Array[0][0];
                        priv->m_Filter1_FIR_Array[0][0] = currentSample;

                        y = ADD(y,
                                MAC2(priv->m_Filter1_IIR_Array[0][0],
                                     priv->m_Filter1_IIR_Coeff[0],
                                     priv->m_Filter1_IIR_Array[0][1],
                                     priv->m_Filter1_IIR_Coeff[1]));

                        priv->m_Filter1_IIR_Array[0][1] = priv->m_Filter1_IIR_Array[0][0];
                        priv->m_Filter1_IIR_Array[0][0] = y;

                        // save filter result
                        psBuffer[i] = (zINT32) y;

                        currentSample = ((ZNUM) psBuffer[i + 1]);// right channel


                        y = MAC3(currentSample,
                                 priv->m_Filter1_FIR_Coeff[0],
                                 priv->m_Filter1_FIR_Array[1][0],
                                 priv->m_Filter1_FIR_Coeff[1],
                                 priv->m_Filter1_FIR_Array[1][1],
                                 priv->m_Filter1_FIR_Coeff[2]);

                        priv->m_Filter1_FIR_Array[1][1] = priv->m_Filter1_FIR_Array[1][0];
                        priv->m_Filter1_FIR_Array[1][0] = currentSample;

                        y = ADD(y,
                                MAC2(priv->m_Filter1_IIR_Array[1][0],
                                     priv->m_Filter1_IIR_Coeff[0],
                                     priv->m_Filter1_IIR_Array[1][1],
                                     priv->m_Filter1_IIR_Coeff[1]));

                        priv->m_Filter1_IIR_Array[1][1] = priv->m_Filter1_IIR_Array[1][0];
                        priv->m_Filter1_IIR_Array[1][0] = y;

                        // save filter result
                        psBuffer[i + 1] = (zINT32) (y);

                        // MID

                        currentSample = ((ZNUM) psBuffer[i]); // left channel

                        y = MAC3(currentSample,
                                 priv->m_Filter2_FIR_Coeff[0],
                                 priv->m_Filter2_FIR_Array[0][0],
                                 priv->m_Filter2_FIR_Coeff[1],
                                 priv->m_Filter2_FIR_Array[0][1],
                                 priv->m_Filter2_FIR_Coeff[2]);

                        priv->m_Filter2_FIR_Array[0][1] = priv->m_Filter2_FIR_Array[0][0];
                        priv->m_Filter2_FIR_Array[0][0] = currentSample;

                        y = ADD(y,
                                MAC2(priv->m_Filter2_IIR_Array[0][0],
                                     priv->m_Filter2_IIR_Coeff[0],
                                     priv->m_Filter2_IIR_Array[0][1],
                                     priv->m_Filter2_IIR_Coeff[1]));

                        priv->m_Filter2_IIR_Array[0][1] = priv->m_Filter2_IIR_Array[0][0];
                        priv->m_Filter2_IIR_Array[0][0] = y;
                        //                priv->m_Filter2_IIR_Array[0][0] = (zINT16)y ;

                        // save filter result
                        psBuffer[i] = (zINT32) y;
                        //                psBuffer[i]   = (zINT16) y;

                        currentSample = ((ZNUM) psBuffer[i + 1]); // right channel

                        y = MAC3(currentSample,
                                 priv->m_Filter2_FIR_Coeff[0],
                                 priv->m_Filter2_FIR_Array[1][0],
                                 priv->m_Filter2_FIR_Coeff[1],
                                 priv->m_Filter2_FIR_Array[1][1],
                                 priv->m_Filter2_FIR_Coeff[2]);

                        priv->m_Filter2_FIR_Array[1][1] = priv->m_Filter2_FIR_Array[1][0];
                        priv->m_Filter2_FIR_Array[1][0] = currentSample;
                        //                priv->m_Filter2_FIR_Array[1][0]     = (zINT16)currentSample;


                        y = ADD(y,
                                MAC2(priv->m_Filter2_IIR_Array[1][0],
                                     priv->m_Filter2_IIR_Coeff[0],
                                     priv->m_Filter2_IIR_Array[1][1],
                                     priv->m_Filter2_IIR_Coeff[1]));

                        priv->m_Filter2_IIR_Array[1][1] = priv->m_Filter2_IIR_Array[1][0];
                        priv->m_Filter2_IIR_Array[1][0] = y;
                        //                priv->m_Filter2_IIR_Array[1][0] = (zINT16)y ;

                        // save filter result
                        psBuffer[i + 1] = (zINT32) y;
                        //                psBuffer[i+1] = (zINT16) y;


                        // HIGH

                        currentSample = ((ZNUM) psBuffer[i]); // left channel

                        y = MAC3(currentSample,
                                 priv->m_Filter3_FIR_Coeff[0],
                                 priv->m_Filter3_FIR_Array[0][0],
                                 priv->m_Filter3_FIR_Coeff[1],
                                 priv->m_Filter3_FIR_Array[0][1],
                                 priv->m_Filter3_FIR_Coeff[2]);

                        priv->m_Filter3_FIR_Array[0][1] = priv->m_Filter3_FIR_Array[0][0];
                        priv->m_Filter3_FIR_Array[0][0] = currentSample;

                        y = ADD(y,
                                MAC2(priv->m_Filter3_IIR_Array[0][0],
                                     priv->m_Filter3_IIR_Coeff[0],
                                     priv->m_Filter3_IIR_Array[0][1],
                                     priv->m_Filter3_IIR_Coeff[1]));

                        priv->m_Filter3_IIR_Array[0][1] = priv->m_Filter3_IIR_Array[0][0];
                        priv->m_Filter3_IIR_Array[0][0] = y;

                        // save filter result
                        psBuffer[i] = (zINT32) y;

                        currentSample = ((ZNUM) psBuffer[i + 1]);
                        ; // right channel

                        y = MAC3(currentSample,
                                 priv->m_Filter3_FIR_Coeff[0],
                                 priv->m_Filter3_FIR_Array[1][0],
                                 priv->m_Filter3_FIR_Coeff[1],
                                 priv->m_Filter3_FIR_Array[1][1],
                                 priv->m_Filter3_FIR_Coeff[2]);

                        priv->m_Filter3_FIR_Array[1][1] = priv->m_Filter3_FIR_Array[1][0];
                        priv->m_Filter3_FIR_Array[1][0] = currentSample;

                        y = ADD(y,
                                MAC2(priv->m_Filter3_IIR_Array[1][0],
                                     priv->m_Filter3_IIR_Coeff[0],
                                     priv->m_Filter3_IIR_Array[1][1],
                                     priv->m_Filter3_IIR_Coeff[1]));

                        priv->m_Filter3_IIR_Array[1][1] = priv->m_Filter3_IIR_Array[1][0];
                        priv->m_Filter3_IIR_Array[1][0] = y;

                        // save filter result
                        psBuffer[i + 1] = (zINT32) y;

                }
        } // BYPASS
#ifdef PROTECT
}
else
memset((void*)psBuffer, 0 , sizeof(zINT32)*iLength*2);
#endif
        return _NO_ERROR;

}

zERROR p0_eq_set_parameters(P0Eq *pThis, _EQ_Modes Filter1Mode, zFLOAT32 fFilter1MidFreq, zFLOAT32 fFilter1Q, zFLOAT32 fFilter1Gain,
                            zFLOAT32 fFilter2MidFreq, zFLOAT32 fFilter2Q, zFLOAT32 fFilter2Gain,
                            _EQ_Modes Filter3Mode, zFLOAT32 fFilter3MidFreq, zFLOAT32 fFilter3Q, zFLOAT32 fFilter3Gain)
{
        P0EqPrivate *priv = P0_EQ_GET_PRIVATE (pThis);


        // LOW-parameters
        priv->m_NewFilter1Mode = Filter1Mode;
        priv->m_NewFilter1MidFreq = DIV(MULIF(fFilter1MidFreq,
                                        CONV(0.001)),
                                  MULIF(priv->m_iSampleRate,
                                        CONV(0.001)));
        priv->m_NewFilter1Q = CONV(fFilter1Q);
        priv->m_NewFilter1Gain = CONV(fFilter1Gain);

        //MID-parameters
        priv->m_NewFilter2MidFreq = DIV(MULIF(fFilter2MidFreq,
                                        CONV(0.001)),
                                  MULIF(priv->m_iSampleRate,
                                        CONV(0.001)));
        priv->m_NewFilter2Q = CONV(fFilter2Q);
        priv->m_NewFilter2Gain = CONV(fFilter2Gain);

        //HIGH-parameters
        priv->m_NewFilter3Mode = Filter3Mode;
        priv->m_NewFilter3MidFreq = DIV(MULIF(fFilter3MidFreq,
                                        CONV(0.001)),
                                  MULIF(priv->m_iSampleRate,
                                        CONV(0.001)));
        priv->m_NewFilter3Q = CONV(fFilter3Q);
        priv->m_NewFilter3Gain = CONV(fFilter3Gain);

        priv->m_bChanged = TRUE;


        return _NO_ERROR;
}



zERROR  p0_eq_get_parameters(P0Eq *pThis,_EQ_Modes *Filter1Mode, zFLOAT32 *fFilter1MidFreq, zFLOAT32 *fFilter1Q, zFLOAT32 *fFilter1Gain,
                             zFLOAT32 *fFilter2MidFreq, zFLOAT32 *fFilter2Q, zFLOAT32 *fFilter2Gain,
                             _EQ_Modes *Filter3Mode, zFLOAT32 *fFilter3MidFreq, zFLOAT32 *fFilter3Q, zFLOAT32 *fFilter3Gain)
{
        P0EqPrivate *priv = P0_EQ_GET_PRIVATE (pThis);

        // LOW-parameters
        *Filter1Mode = priv->m_Filter1Mode;
        *fFilter1MidFreq = ICONV(priv->m_Filter1MidFreq);
        *fFilter1Q = ICONV(priv->m_Filter1Q);
        *fFilter1Gain = ICONV(priv->m_Filter1Gain);

        //MID-parameters
        *fFilter2MidFreq = ICONV(priv->m_Filter2MidFreq);
        *fFilter2Q = ICONV(priv->m_Filter2Q);
        *fFilter2Gain = ICONV(priv->m_Filter2Gain);

        //HIGH-parameters
        *Filter3Mode = priv->m_Filter3Mode;
        *fFilter3MidFreq = ICONV(priv->m_Filter3MidFreq);
        *fFilter3Q = ICONV(priv->m_Filter3Q);
        *fFilter3Gain = ICONV(priv->m_Filter3Gain);

        return _NO_ERROR;
}


#if _USE_INTEGER == 1

zINT32  fixlog10 (zINT32 x)
{
   return MUL (fixln(x),_I_LN_10);

}

zINT32  fixln (zINT32 x)
{

        zINT32          w, y;
        zINT32          dec;

        if (x==0)
                return _MIN_zINT32;

        for (dec=0; (x & 0x800000)==FALSE; dec++)
                x = x<<1;

        dec             = - MULIF(dec, _LN_2 );

        x               = SUB(x, _BASE);
        w               = x;

        y               = 0;
#ifdef ARM
        y = fixlgh(w,-x);
#else
        y               =       y  +  (w);
        w               =  ((- MUL(w , x))) ;


        y               =       y  +  (MUL(w, CONV(1.0/2.0)));
        w               =  ((- MUL(w , x))) ;

        y               =       y  +  (MUL(w, CONV(1.0/3.0)));
        w               =  ((- MUL(w , x))) ;

        y               =       y  +  (MUL(w, CONV(1.0/4.0)));
        w               =  ((- MUL(w , x))) ;

        y               =       y  +  (MUL(w, CONV(1.0/5.0)));
        w               =  ((- MUL(w , x))) ;

        y               =       y  +  (MUL(w, CONV(1.0/6.0)));
        w               =  ((- MUL(w , x))) ;

        y               =       y  +  (MUL(w, CONV(1.0/7.0)));
        w               =  ((- MUL(w , x))) ;

        y               =       y  +  (MUL(w, CONV(1.0/8.0)));
        w               =  ((- MUL(w , x))) ;

        y               =       y  +  (MUL(w, CONV(1.0/9.0)));

#endif

        return (zINT32)(ADD(y, dec));
}

zINT32  fixexp( zINT32 x)
{

#if 0

        zINT64 w,y;
        zINT32 n;

        for(w=CONV(1.0),y=CONV(1.0),n=1;y!=y+w; ++n)
                y += w =(w * (x / n))>>_EXPONENT;//y!=y + w

        return (zINT32) y;
#else

        zINT32 w,y;
        zINT32 n;

        x = MUL(x, _LD_E);
//      y = MUL(x, _LD_E);
        //
        n = - (zINT32)(x & 0xff800000);
        x = ADD(x, n);
        n = n >> _EXPONENT;
        n = n > 0 ? 0x800000>>n : 0x800000<<-n;
        x = MUL(x, _LN_2);

        w=CONV(1.0);
        y=CONV(1.0);
        y += w =((MUL(w , x )));
        y += w =((MUL(w , MUL(x, CONV(1.0/2.0)))));
        y += w =((MUL(w , MUL(x, CONV(1.0/3.0)))));
//      y += w =((MUL(w , MUL(x, CONV(1.0/4.0)))));
//      y += w =((MUL(w , MUL(x, CONV(1.0/5.0)))));
//      y += w =((MUL(w , MUL(x, CONV(1.0/6.0)))));
//      y += w =((MUL(w , MUL(x, CONV(1.0/7.0)))));
//      y += w =((MUL(w , MUL(x, CONV(1.0/8.0)))));
//      y += w =((MUL(w , MUL(x, CONV(1.0/9.0)))));
//      y += w =((MUL(w , MUL(x, CONV(1.0/10.0)))));


        return (zINT32) MUL(y , n);
#endif
}

/*
#ifndef ARM

__forceinline
zINT32 fixmul(zINT32 x, zINT32 y)
{
        __asm
        {
                mov eax, x
                imul y
                shrd eax, edx, _EXPONENT
        }
}

inline zINT32 fixclz(zINT32 x);

#endif
*/
#endif
