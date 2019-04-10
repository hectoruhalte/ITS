with Gtk.Handlers;
with Gtk.Widget;
with Gdk.Event;

package Q_LIBRERIA_MANEJO_EVENTOS is

   	package Q_MANEJADOR_EVENTO is new Gtk.Handlers.Return_Callback (Widget_Type => Gtk.Widget.Gtk_Widget_Record,
      									Return_Type => Boolean);

	function F_DESTRUIR_VENTANA_PRINCIPAL (Widget : access Gtk.Widget.Gtk_Widget_Record'Class;
					       Evento : in Gdk.Event.Gdk_Event) return Boolean;

end Q_LIBRERIA_MANEJO_EVENTOS;
