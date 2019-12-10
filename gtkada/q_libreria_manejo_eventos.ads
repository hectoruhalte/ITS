--------------------------------------------------------------------------------------------------------------------------------------------
--
--      Fichero:        q_libreria_manejo_eventos.ads
--
--      Autor:          Hector Uhalte Bilbao
--
--      Fecha:          1/8/2018
--      
--------------------------------------------------------------------------------------------------------------------------------------------

with Gtk.Handlers;
with Gtk.Widget;
with Gdk.Event;
--
with Gtk.Button;
with Gtk.Box;
with Gtk.List_Store;

package Q_LIBRERIA_MANEJO_EVENTOS is

	type T_REGISTRO_USUARIO is record

		R_CAJA : Gtk.Box.Gtk_Box;

		R_MODELO_DATOS : Gtk.List_Store.Gtk_List_Store;

	end record;

	package Q_MANEJADOR_EVENTO_BOTON is new Gtk.Handlers.Callback (Widget_Type => Gtk.Button.Gtk_Button_Record);

	package Q_MANEJADOR_EVENTO_BOTON_VEHICULO is new Gtk.Handlers.User_Callback (Widget_Type => Gtk.Button.Gtk_Button_Record,
						       			             User_Type => T_REGISTRO_USUARIO);

	package Q_MANEJADOR_EVENTO_BOTON_BORRAR_VEHICULOS is new Gtk.Handlers.User_Callback (Widget_Type => Gtk.Button.Gtk_Button_Record,
											     User_Type => T_REGISTRO_USUARIO);

	procedure P_DESTRUIR_VENTANA_PRINCIPAL (V_BOTON : access Gtk.Button.Gtk_Button_Record'Class);

	procedure P_GENERAR_VEHICULO (V_BOTON : access Gtk.Button.Gtk_Button_Record'Class;
				      V_DATOS_USUARIO : in T_REGISTRO_USUARIO);

	procedure P_BORRAR_VEHICULOS (V_BOTON : access Gtk.Button.Gtk_Button_Record'Class;
				      V_DATOS_USUARIO : in T_REGISTRO_USUARIO);

end Q_LIBRERIA_MANEJO_EVENTOS;
------------------------------
