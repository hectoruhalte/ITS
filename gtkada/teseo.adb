--------------------------------------------------------------------------------------------------------------------------------------------
--
--      Fichero:        teseo.adb
--
--      Autor:          Hector Uhalte Bilbao
--
--      Fecha:          1/8/2018
--      
--------------------------------------------------------------------------------------------------------------------------------------------

-- Programa para el interfaz grafico de teseo.

with Gtk.Main; 
with Gtk.Window;
with Gtk.Enums;
with Gdk.Event;
with Gtk.Handlers;
with Q_LIBRERIA_MANEJO_EVENTOS;
with Gtkada.Style;
with Gtk.Box;
with Gtk.Widget;
with Gtk.Frame;
with Gtk.Image;

-- Añadir botones y reloj
with Gtk.Button;
with Gtk.Label;
with Ada.Calendar;
with gnat.calendar.time_io;
with Glib.Main;
with Gtk.List_Store;

procedure teseo is

	-- Variable para la ventana principal
	V_VENTANA_PRINCIPAL : Gtk.Window.Gtk_Window;

	V_MARCO_PRINCIPAL : Gtk.Frame.Gtk_Frame;

	-- Variable para la caja principal. Hijo del marco principal.
	-- La caja contenedora sera la que contenga a las demas y tendra un marco dibujado.
	V_CAJA_PRINCIPAL, V_CAJA_IZQUIERDA, V_CAJA_DERECHA, V_CAJA_MAPA, V_CAJA_INFERIOR, V_CAJA_BOTON_LOGO, V_CAJA_BOTON_LOGO_SUPERIOR,
	V_CAJA_RELOJ, V_CAJA_BOTONES, V_CAJA_BOTONES_SUPERIOR, V_CAJA_BOTONES_INFERIOR, V_CAJA_BOTON_GENERAR_VEHICULO, 
	V_CAJA_BOTON_BORRAR_VEHICULOS : Gtk.Box.Gtk_Box;

	V_LOGO : Gtk.Image.Gtk_Image;

	--
	V_BOTON_LOGO, V_BOTON_GENERAR_VEHICULO, V_BOTON_BORRAR_VEHICULOS : Gtk.Button.Gtk_Button;
	
	V_LABEL_RELOJ : Gtk.Label.Gtk_Label;

	Id     : Glib.Main.G_Source_Id;

	V_MODELO : Gtk.List_Store.Gtk_List_Store;

	V_DATOS_USUARIO : Q_LIBRERIA_MANEJO_EVENTOS.T_REGISTRO_USUARIO;

	package Q_REFRESCAR is new Glib.Main.Generic_Sources (Gtk.Label.Gtk_Label);

	---------------------------------------------------------------------------------------
	function F_ACTUALIZAR_RELOJ (V_LABEL_RELOJ : in Gtk.Label.Gtk_Label ) return Boolean is

	begin

		Gtk.Label.Set_Text (Label => V_LABEL_RELOJ,
				    Str => gnat.calendar.time_io.Image (Date => Ada.Calendar.Clock,
                                                                        Picture => "%H:%M"));

		return True;

	end F_ACTUALIZAR_RELOJ;
	-----------------------

begin

	-- Inicializar estructuras internas GtkAda.
	Gtk.Main.Init;

	-- Crear la ventana principal
	Gtk.Window.Gtk_New (Window => V_VENTANA_PRINCIPAL,
			    The_Type => Gtk.Enums.Window_Toplevel);

	-- Dar nombre al widget para ser usado en el fichero css
	Gtk.Window.Set_Name (Widget => V_VENTANA_PRINCIPAL,
			     Name => "ventanaPrincipal");

	-- Poner un titulo a la ventana.
	Gtk.Window.Set_Title (Window => V_VENTANA_PRINCIPAL,
			      Title => "Teseo");

	Gtk.Window.Set_Position (Window => V_VENTANA_PRINCIPAL,
				 Position => Gtk.Enums.Win_Pos_Center);

	Gtk.Window.Set_Default_Size (Window => V_VENTANA_PRINCIPAL,
			      	     Width => 1366,
			      	     Height => 768);

	-- Crear el marco principal
	Gtk.Frame.Gtk_New (Frame => V_MARCO_PRINCIPAL,
			   Label => "");

	-- Dar nombre al widget para ser usado en el fichero css
	Gtk.Frame.Set_Name (Widget => V_MARCO_PRINCIPAL,
			    Name => "marcoPrincipal");

	Gtk.Frame.Set_Border_Width (Container => V_MARCO_PRINCIPAL,
				    Border_Width => 5);

	Gtk.Window.Fullscreen (V_VENTANA_PRINCIPAL);

	-- Añadir el marco principal a la ventana principal
	Gtk.Window.Add (Container => V_VENTANA_PRINCIPAL,
			Widget => V_MARCO_PRINCIPAL);

	-- Crear la caja principal
	Gtk.Box.Gtk_New_HBox (Box => V_CAJA_PRINCIPAL,
			      Homogeneous => False,
			      Spacing => 1);

	-- Dar nombre al widget para ser usado en el fichero css
	Gtk.Box.Set_Name (Widget => V_CAJA_PRINCIPAL,
			  Name => "cajaPrincipal");

	-- Añadir la caja principal al marco principal
        Gtk.Frame.Add (Container => V_MARCO_PRINCIPAL,
                       Widget => V_CAJA_PRINCIPAL);

	-- Crear las cajas izquierda y derecha
	Gtk.Box.Gtk_New_VBox (Box => V_CAJA_IZQUIERDA,
			      Homogeneous => False,
			      Spacing => 1);

	Gtk.Box.Gtk_New_VBox (Box => V_CAJA_DERECHA,
			      Homogeneous => False,
			      Spacing => 3);

	Gtk.Box.Set_Name (Widget => V_CAJA_IZQUIERDA,
			  Name => "cajaIzquierda");

	Gtk.Box.Set_Name (Widget => V_CAJA_DERECHA,
			  Name => "cajaDerecha");
	
	Gtk.Box.Set_Border_Width (Container => V_CAJA_IZQUIERDA,
                                  Border_Width => 1);

	Gtk.Box.Set_Border_Width (Container => V_CAJA_DERECHA,
                                  Border_Width => 1);
	
	Gtk.Box.Set_Size_Request (Widget => V_CAJA_IZQUIERDA,
				  Width => 505);

	Gtk.Box.Set_Size_Request (Widget => V_CAJA_DERECHA,
                                  Width => 850);	

	Gtk.Box.Add (Container => V_CAJA_PRINCIPAL,
		     Widget => V_CAJA_IZQUIERDA);

	Gtk.Box.Add (Container => V_CAJA_PRINCIPAL,
		     Widget => V_CAJA_DERECHA);

	Gtk.Box.Gtk_New_HBox (Box => V_CAJA_MAPA,
			      Homogeneous => True,
			      Spacing => 0);

	Gtk.Box.Gtk_New_HBox (Box => V_CAJA_INFERIOR,
			      Homogeneous => False,
			      Spacing => 1);

	Gtk.Box.Set_Name (Widget => V_CAJA_MAPA,
			  Name => "cajaMapa");

	-- Crear la caja para el boton del logo.
	Gtk.Box.Gtk_New_VBox (Box => V_CAJA_BOTON_LOGO,
			      Homogeneous => False,
			      Spacing => 0);

	Gtk.Box.Gtk_New_HBox (Box => V_CAJA_BOTON_LOGO_SUPERIOR,
			      Homogeneous => True,
			      Spacing => 0);

	Gtk.Box.Set_Size_Request (Widget => V_CAJA_BOTON_LOGO_SUPERIOR,
                                  Height => 10);

	--Crear el boton para el logo
	Gtk.Button.Gtk_New (V_BOTON_LOGO);

	Gtk.Button.Set_Name (Widget => V_BOTON_LOGO,
                             Name => "botonLogo");

	Gtk.Image.Gtk_New (Image => V_LOGO,
			   Filename => "/home/hector/ITS/gtkada/Dedalos_logo.png");

	-- Añadir la imagen al boton
	Gtk.Button.Add (Container => V_BOTON_LOGO,
			Widget => V_LOGO);

	-- Crear la caja para el reloj.
	Gtk.Box.Gtk_New_HBox (Box => V_CAJA_RELOJ,
			      Homogeneous => False,
			      Spacing => 0);

	Gtk.Box.Set_Name (Widget => V_CAJA_RELOJ,
                          Name => "cajaReloj");

	Gtk.Label.Gtk_New (Label => V_LABEL_RELOJ,
			   Str => gnat.calendar.time_io.Image (Date => Ada.Calendar.Clock,
							       Picture => "%H:%M"));

	Gtk.Label.Set_Name (Widget => V_LABEL_RELOJ,
			    Name => "labelReloj");

	Gtk.Box.Add (Container => V_CAJA_RELOJ,
		     Widget => V_LABEL_RELOJ);

	-- Crear la caja para los botones.
	Gtk.Box.Gtk_New_VBox (Box => V_CAJA_BOTONES,
			      Homogeneous => True,
			      Spacing => 1);

	Gtk.Box.Set_Name (Widget => V_CAJA_BOTONES,
			  Name => "cajaBotones");

	Gtk.Box.Gtk_New_Hbox (Box => V_CAJA_BOTONES_SUPERIOR,
			      Homogeneous => False,
			      Spacing => 1);

	Gtk.Box.Set_Name (Widget => V_CAJA_BOTONES_SUPERIOR,
			  Name => "cajaBotonesSuperior");

	Gtk.Box.Gtk_New_Hbox (Box => V_CAJA_BOTONES_INFERIOR,
			      Homogeneous => False,
			      Spacing => 1);

	Gtk.Box.Set_Name (Widget => V_CAJA_BOTONES_INFERIOR,
			  Name => "cajaBotonesInferior");

	Gtk.Box.Gtk_New_HBox (Box => V_CAJA_BOTON_GENERAR_VEHICULO,
			      Homogeneous => True,
			      Spacing => 0);

	Gtk.Box.Set_Name (Widget => V_CAJA_BOTON_GENERAR_VEHICULO,
			  Name => "cajaBotonGenerarVehiculo");

	Gtk.Box.Gtk_New_HBox (Box => V_CAJA_BOTON_BORRAR_VEHICULOS,
			      Homogeneous => True,
			      Spacing => 0);

	Gtk.Box.Set_Name (Widget => V_CAJA_BOTON_BORRAR_VEHICULOS,
			  Name => "cajaBotonBorrarVehiculos");

	Gtk.Button.Gtk_New (Button => V_BOTON_GENERAR_VEHICULO,
			    Label => "GENERAR VEHICULO");

	Gtk.Button.Set_Name (Widget => V_BOTON_GENERAR_VEHICULO,
			     Name => "botonVehiculo");

	Gtk.Button.Gtk_New (Button => V_BOTON_BORRAR_VEHICULOS,
			    Label => "BORRAR VEHICULOS");

	Gtk.Button.Set_Name (Widget => V_BOTON_BORRAR_VEHICULOS,
			     Name => "botonBorrarVehiculos");

	-- Crear la lista de vehiculos.
	Gtk.List_Store.Gtk_New (List_Store => V_MODELO,
                                Types => (0 => Glib.GType_String,
                                          1 => Glib.GType_String,
					  2 => Glib.GType_String));

	-- Con el modelo y la caja izquierda creadas generamos el registro de datos que pasar al conector.
	V_DATOS_USUARIO.R_CAJA := V_CAJA_IZQUIERDA;
	V_DATOS_USUARIO.R_MODELO_DATOS := V_MODELO;

	-- Packing.

	Gtk.Box.Pack_Start (In_Box => V_CAJA_BOTON_LOGO,
			    Child => V_CAJA_BOTON_LOGO_SUPERIOR,
			    Expand => False,
			    Fill => False,
			    Padding => 0);

	Gtk.Box.Pack_Start (In_Box => V_CAJA_BOTON_LOGO,
                            Child => V_BOTON_LOGO,
                            Expand => False,
                            Fill => False,
                            Padding => 0);

	Gtk.Box.Pack_Start (In_Box => V_CAJA_BOTON_GENERAR_VEHICULO,
                            Child => V_BOTON_GENERAR_VEHICULO,
                            Expand => False,
                            Fill => False,
                            Padding => 0);

	Gtk.Box.Set_Size_Request (Widget => V_CAJA_BOTON_GENERAR_VEHICULO,
				  Width => 100);

	Gtk.Box.Pack_Start (In_Box => V_CAJA_BOTON_BORRAR_VEHICULOS,
			    Child => V_BOTON_BORRAR_VEHICULOS,
			    Expand => False,
			    Fill => False,
			    Padding => 0);

	Gtk.Box.Set_Size_Request (Widget => V_CAJA_BOTON_BORRAR_VEHICULOS,
				  Width => 100);

	Gtk.Box.Pack_Start (In_Box => V_CAJA_BOTONES_SUPERIOR,
			    Child => V_CAJA_BOTON_GENERAR_VEHICULO,
			    Expand => False,
			    Fill => False,
			    Padding => 0);

	Gtk.Box.Pack_Start (In_Box => V_CAJA_BOTONES_INFERIOR,
			    Child => V_CAJA_BOTON_BORRAR_VEHICULOS,
			    Expand => False,
			    Fill => False,
			    Padding => 0);

	Gtk.Box.Pack_Start (In_Box => V_CAJA_BOTONES,
			    Child => V_CAJA_BOTONES_SUPERIOR,
			    Expand => False,
			    Fill => True,
			    Padding => 1);

	Gtk.Box.Pack_End (In_Box => V_CAJA_BOTONES,
		          Child => V_CAJA_BOTONES_INFERIOR,
	        	  Expand => False,
			  Fill => True,
			  Padding => 1);

	Gtk.Box.Pack_Start (In_Box => V_CAJA_INFERIOR,
			    Child => V_CAJA_BOTONES,
			    Expand => True,
			    Fill => True,
			    Padding => 0);

	Gtk.Box.Pack_End (In_Box => V_CAJA_INFERIOR,
			  Child => V_CAJA_BOTON_LOGO,
			  Expand => False,
			  Fill => False,
			  Padding => 0);

	Gtk.Box.Set_Size_Request (Widget => V_CAJA_RELOJ,
                                  Width => 120);

	Gtk.Box.Pack_End (In_Box => V_CAJA_INFERIOR,
			  Child => V_CAJA_RELOJ,
			  Expand => False,
			  Fill => False,
			  Padding => 0);
	
	Gtk.Box.Set_Size_Request (Widget => V_CAJA_MAPA,
				  Height => 660);

	Gtk.Box.Pack_Start (In_Box => V_CAJA_DERECHA,
			    Child => V_CAJA_MAPA,
			    Expand => True,
			    Fill => True,
			    Padding => 0);

	Gtk.Box.Pack_End (In_Box => V_CAJA_DERECHA,
			  Child => V_CAJA_INFERIOR,
			  Expand => True,
			  Fill => True,
			  Padding => 0);

	Q_LIBRERIA_MANEJO_EVENTOS.
                Q_MANEJADOR_EVENTO_BOTON.Connect
                        (Widget => V_BOTON_LOGO,
                         Name => "clicked",
                         Marsh =>
                                Q_LIBRERIA_MANEJO_EVENTOS.
                                        Q_MANEJADOR_EVENTO_BOTON.To_Marshaller 
						(Q_LIBRERIA_MANEJO_EVENTOS.P_DESTRUIR_VENTANA_PRINCIPAL'Access),
                         After => False);

	Q_LIBRERIA_MANEJO_EVENTOS.
		Q_MANEJADOR_EVENTO_BOTON_VEHICULO.Connect 
			(Widget => V_BOTON_GENERAR_VEHICULO,
			 Name => "clicked",
			 Marsh => 
				Q_LIBRERIA_MANEJO_EVENTOS.
					Q_MANEJADOR_EVENTO_BOTON_VEHICULO.To_Marshaller 
						(Q_LIBRERIA_MANEJO_EVENTOS.P_GENERAR_VEHICULO'Access),
			 User_Data => V_DATOS_USUARIO,
			 After => False);

	Q_LIBRERIA_MANEJO_EVENTOS.
		Q_MANEJADOR_EVENTO_BOTON_BORRAR_VEHICULOS.Connect 
			(Widget => V_BOTON_BORRAR_VEHICULOS,
			 Name => "clicked",
			 Marsh => 
				Q_LIBRERIA_MANEJO_EVENTOS.
					Q_MANEJADOR_EVENTO_BOTON_BORRAR_VEHICULOS.To_Marshaller 
						(Q_LIBRERIA_MANEJO_EVENTOS.P_BORRAR_VEHICULOS'Access),
			 User_Data => V_CAJA_IZQUIERDA,
			 After => False);

	-- Refrescar el reloj cada segundo
        Id := Q_REFRESCAR.Timeout_Add (Interval => 1000,
                                       Func => F_ACTUALIZAR_RELOJ'Access,
                                       Data => V_LABEL_RELOJ);

	Gtkada.Style.Load_Css_File (Path => "/home/hector/ITS/gtkada/estilo.css",
				    Priority => 600);

	Gtk.Window.Show_All (V_VENTANA_PRINCIPAL);

	Gtk.Main.Main;

end teseo;
-------------------------------------------------------------------------------------------------------------------------------------------
