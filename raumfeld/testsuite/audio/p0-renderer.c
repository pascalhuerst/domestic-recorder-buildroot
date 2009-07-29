/*
 * P0Renderer:
 *
 * This class implements the UPnP root device for the renderer
 */

#include <string.h>

#include <raumfeld/dlna.h>
#include <raumfeld/setup.h>

#include <libxml/parser.h>
#include <libxml/tree.h>
#include <libxml/xpath.h>
#include <libxml/xpathInternals.h>

#include <libsoup/soup.h>

#include "p0-renderer-types.h"
#include "p0-control.h"
#include "p0-generator.h"
#include "p0-manager.h"
#include "p0-renderer.h"
#include "p0-transport.h"


struct _P0Renderer
{
        GObject          parent_instance;

        GUPnPRootDevice *device;
        gchar 	    	*udn;

        P0Transport     *av_transport;
        P0Control       *rendering_control;
        P0Manager       *connection_manager;
        P0Generator     *feld_generator;
};


static void p0_renderer_finalize              (GObject           *object);
static void p0_renderer_set_udn               (P0Renderer        *renderer,
                                               const char        *udn);
static void p0_renderer_bend_description_file (SoupServer        *server,
                                               SoupMessage       *msg,
                                               const char        *path,
                                               GHashTable        *query,
                                               SoupClientContext *client,
                                               gpointer           user_data);


/* rendering control        */

G_DEFINE_TYPE (P0Renderer, p0_renderer, G_TYPE_OBJECT)


//
static void
p0_renderer_class_init (P0RendererClass *klass)
{
        GObjectClass *object_class = G_OBJECT_CLASS (klass);

        object_class->finalize = p0_renderer_finalize;
}

static void
p0_renderer_init (P0Renderer *renderer)
{
        renderer->udn = NULL;
}

static void
p0_renderer_finalize (GObject *object)
{
        P0Renderer *renderer = P0_RENDERER (object);

        gupnp_root_device_set_available (renderer->device, FALSE);

        g_object_unref (renderer->av_transport);
        g_object_unref (renderer->rendering_control);
        g_object_unref (renderer->connection_manager);
        g_object_unref (renderer->feld_generator);

        g_object_unref (renderer->device);

        g_free (renderer->udn);

        G_OBJECT_CLASS (p0_renderer_parent_class)->finalize (object);
}


P0Renderer*
p0_renderer_new (GUPnPContext *context,
                 const gchar  *udn,
                 const gchar  *time_service,
                 P0Feedback   *feedback)
{
        P0Renderer  *renderer;
        GUPnPDevice *device;
        SoupServer  *server;

        g_return_val_if_fail (GUPNP_IS_CONTEXT (context), NULL);

        renderer = g_object_new (TYPE_P0_RENDERER, NULL);

        /* setup the xml files for webserver */
        gupnp_context_host_path (context,
                                 "xml/description.xml",
                                 "/Description.xml");
        gupnp_context_host_path (context,
                                 "xml/connectmanager.xml",
                                 "/ConnectionManager/desc.xml");
        gupnp_context_host_path (context,
                                 "xml/avtransport.xml",
                                 "/AVTransport/desc.xml");
        gupnp_context_host_path (context,
                                 "xml/rendercontrol.xml",
                                 "/RenderingControl/desc.xml");
        gupnp_context_host_path (context,
                                 "xml/feldgenerator.xml",
                                 "/RaumfeldGenerator/desc.xml");

        gupnp_context_host_path (context,
                                 RAUMFELD_DATA_DIR "/icons/raumfeld-32.png",
                                 "/icons/raumfeld-32.png");
        gupnp_context_host_path (context,
                                 RAUMFELD_DATA_DIR "/icons/raumfeld-48.png",
                                 "/icons/raumfeld-48.png");

        // the UDN may have been passed on the command-line
        p0_renderer_set_udn (renderer,
                             udn ? udn : setup_udn_get ("media-renderer"));

        server = gupnp_context_get_server (context);
        soup_server_add_handler (server, "/Description.xml",
                                 p0_renderer_bend_description_file,
                                 renderer, NULL);

        /* Create the root device object */
        renderer->device = gupnp_root_device_new (context, "/Description.xml");

        g_assert(renderer->device != NULL);

        device = GUPNP_DEVICE (renderer->device);

        renderer->connection_manager = p0_manager_new (device);
        renderer->rendering_control  = p0_control_new (device);
        renderer->av_transport       = p0_transport_new (device, time_service);
        renderer->feld_generator     = p0_generator_new (device, feedback);

        return renderer;
}

P0Transport *
p0_renderer_get_av_transport (P0Renderer *renderer)
{
        g_return_val_if_fail (IS_P0_RENDERER (renderer), NULL);

        return renderer->av_transport;
}

P0Control *
p0_renderer_get_rendering_control (P0Renderer *renderer)
{
        g_return_val_if_fail (IS_P0_RENDERER (renderer), NULL);

        return renderer->rendering_control;
}

P0Manager *
p0_renderer_get_connection_manager (P0Renderer *renderer)
{
        g_return_val_if_fail (IS_P0_RENDERER (renderer), NULL);

        return renderer->connection_manager;
}

static void
p0_renderer_set_udn (P0Renderer *renderer,
                     const char *udn)
{
        g_return_if_fail (IS_P0_RENDERER (renderer));
        g_return_if_fail (udn != NULL);

        g_free (renderer->udn);

        if (g_str_has_prefix (udn, "uuid:"))
                renderer->udn = g_strdup(udn);
        else
                renderer->udn = g_strdup_printf("uuid:%s", udn);
}

static void
p0_renderer_bend_node (xmlXPathContextPtr  xpathCtx,
                       const gchar        *path,
                       const gchar        *value)
{
        xmlXPathObjectPtr xpathObj;
        xmlNodeSetPtr     nodes;

        xpathObj = xmlXPathEvalExpression ((xmlChar*) path, xpathCtx);
        nodes = xpathObj->nodesetval;

        if (nodes && nodes->nodeNr == 1) {
                xmlNodeSetContent (nodes->nodeTab[0], (xmlChar*) value);
        }

        xmlXPathFreeObject (xpathObj);
}

static void
p0_renderer_bend_description_file (SoupServer        *server,
                                   SoupMessage       *msg,
                                   const char        *path,
                                   GHashTable        *query,
                                   SoupClientContext *client,
                                   gpointer           user_data)
{
        P0Renderer *renderer = P0_RENDERER (user_data);

        xmlInitParser();

        xmlDoc *description_doc = xmlParseFile("./xml/description.xml");
        xmlXPathContextPtr xpathCtx = xmlXPathNewContext(description_doc);

        xmlXPathRegisterNs (xpathCtx,
                            (const xmlChar *) "devns",
                            (const xmlChar *) "urn:schemas-upnp-org:device-1-0");

        //  replacing the uuid and friendly-name
        if (renderer->udn) {
                const gchar *name = (g_str_has_prefix (renderer->udn, "uuid:")
                                     ? renderer->udn + strlen ("uuid:")
                                     : renderer->udn);

                p0_renderer_bend_node (xpathCtx,
                                       "/devns:root/devns:device/devns:UDN[1]",
                                       renderer->udn);
                p0_renderer_bend_node (xpathCtx,
                                       "/devns:root/devns:device/devns:friendlyName[1]",
                                       name);
        }

        xmlChar *mem  = NULL;
        int      size = 0;

        xmlDocDumpMemory (description_doc, &mem, &size);
        soup_message_body_append (msg->response_body,
                                  SOUP_MEMORY_COPY,
                                  mem,
                                  size);
        xmlFree (mem);

        xmlXPathFreeContext(xpathCtx);
        xmlFreeDoc(description_doc);
        xmlCleanupParser();

        soup_message_set_status(msg, 200);
}

void
p0_renderer_run (P0Renderer *renderer)
{
        GUPnPContext *context;

        g_return_if_fail (IS_P0_RENDERER (renderer));

        context =
          gupnp_device_info_get_context (GUPNP_DEVICE_INFO (renderer->device));

        g_print ("->UPnP: announcing the renderer at IP: %s:%d\n",
                 gupnp_context_get_host_ip (context),
                 gupnp_context_get_port (context));

        /* Activate the root device, so that it announces itself */
        gupnp_root_device_set_available (renderer->device, TRUE);
}
