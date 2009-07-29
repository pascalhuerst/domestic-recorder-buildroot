#ifndef __P0_GENERATOR_H__
#define __P0_GENERATOR_H__


#define TYPE_P0_GENERATOR            (p0_generator_get_type ())
#define P0_GENERATOR(obj)            (G_TYPE_CHECK_INSTANCE_CAST ((obj), TYPE_P0_GENERATOR, P0Generator))
#define P0_GENERATOR_CLASS(klass)    (G_TYPE_CHECK_CLASS_CAST ((klass), TYPE_P0_GENERATOR, P0GeneratorClass))
#define IS_P0_GENERATOR(obj)         (G_TYPE_CHECK_INSTANCE_TYPE ((obj), TYPE_P0_GENERATOR))
#define IS_P0_GENERATOR_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), TYPE_P0_GENERATOR))
#define P0_GENERATOR_GET_CLASS(obj)  (G_TYPE_INSTANCE_GET_CLASS ((obj), TYPE_P0_GENERATOR, P0GeneratorClass))


typedef struct _P0GeneratorClass P0GeneratorClass;

struct _P0GeneratorClass
{
        GObjectClass parent_class;
};


GType         p0_generator_get_type  (void) G_GNUC_CONST;

P0Generator * p0_generator_new       (GUPnPDevice *device,
                                      P0Feedback  *feedback);


#endif  /*  __P0_GENERATOR_H__  */
