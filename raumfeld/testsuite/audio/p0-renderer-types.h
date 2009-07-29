#ifndef __P0_RENDERER_TYPES_H__
#define __P0_RENDERER_TYPES_H__


/* Alsa PlayState */
typedef enum
{
  STOPPED,
  PLAYING
} PlayState;


typedef struct _P0Alsa          P0Alsa;
typedef struct _P0Control       P0Control;
typedef struct _P0DBusService   P0DBusService;
typedef struct _P0Eq            P0Eq;
typedef struct _P0Feedback      P0Feedback;
typedef struct _P0Generator     P0Generator;
typedef struct _P0Gst           P0Gst;
typedef struct _P0Input         P0Input;
typedef struct _P0Manager       P0Manager;
typedef struct _P0Mixer         P0Mixer;
typedef struct _P0Renderer      P0Renderer;
typedef struct _P0Transport     P0Transport;

#endif  /*  __P0_RENDERER_TYPES_H__  */
