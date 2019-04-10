with Gtk.Main;

package body Q_LIBRERIA_MANEJO_EVENTOS is

	function F_DESTRUIR_VENTANA_PRINCIPAL (Widget : access Gtk.Widget.Gtk_Widget_Record'Class;
                                               Evento : in Gdk.Event.Gdk_Event) return Boolean is

        	pragma Unreferenced (Widget);
                pragma Unreferenced (Evento);

        begin

		Gtk.Main.Main_Quit;

                return False;

        end F_DESTRUIR_VENTANA_PRINCIPAL;

end Q_LIBRERIA_MANEJO_EVENTOS;
