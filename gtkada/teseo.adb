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

procedure teseo is

	-- Variable para la ventana principal
	V_VENTANA_PRINCIPAL : Gtk.Window.Gtk_Window;

	V_MARCO_PRINCIPAL : Gtk.Frame.Gtk_Frame;

	-- Variable para la caja principal. Hijo del marco principal.
	-- La caja contenedora sera la que contenga a las demas y tendra un marco dibujado.
	V_CAJA_PRINCIPAL, V_CAJA_IZQUIERDA, V_CAJA_DERECHA, V_CAJA_MAPA, V_CAJA_LOGO : Gtk.Box.Gtk_Box;

	V_LOGO : Gtk.Image.Gtk_Image;

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

	--Gtk.Window.Fullscreen (V_VENTANA_PRINCIPAL);

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

	Gtk.Box.Set_Size_Request (Widget => V_CAJA_DERECHA,
				  Width => 300);

	Gtk.Box.Add (Container => V_CAJA_PRINCIPAL,
		     Widget => V_CAJA_IZQUIERDA);

	Gtk.Box.Add (Container => V_CAJA_PRINCIPAL,
		     Widget => V_CAJA_DERECHA);

	Gtk.Box.Gtk_New_HBox (Box => V_CAJA_MAPA,
			      Homogeneous => True,
			      Spacing => 0);

	Gtk.Box.Gtk_New_HBox (Box => V_CAJA_LOGO,
			      Homogeneous => False,
			      Spacing => 0);

	Gtk.Box.Set_Name (Widget => V_CAJA_MAPA,
			  Name => "cajaMapa");

	Gtk.Box.Set_Name (Widget => V_CAJA_LOGO,
			  Name => "cajaLogo");

	Gtk.Image.Gtk_New (Image => V_LOGO,
			   Filename => "Dedalos_logo.png");

	Gtk.Box.Pack_End (In_Box => V_CAJA_LOGO,
			  Child => V_LOGO,
			  Expand => False,
			  Fill => False,
			  Padding => 10);
	
	Gtk.Box.Set_Size_Request (Widget => V_CAJA_MAPA,
				  Height => 625);

	Gtk.Box.Pack_Start (In_Box => V_CAJA_DERECHA,
			    Child => V_CAJA_MAPA,
			    Expand => True,
			    Fill => True,
			    Padding => 0);

	Gtk.Box.Pack_End (In_Box => V_CAJA_DERECHA,
			  Child => V_CAJA_LOGO,
			  Expand => True,
			  Fill => True,
			  Padding => 0);

	--  Here we connect the "destroy" event to a signal handler.
   	--  This event occurs when we call Gtk.Widget.Destroy on the window,
   	--  or if we return False in the "delete_event" callback.
	Q_LIBRERIA_MANEJO_EVENTOS.
		Q_MANEJADOR_EVENTO.Connect 
			(Widget => V_VENTANA_PRINCIPAL,
		         Name => "delete_event",
			 Marsh => 
				Q_LIBRERIA_MANEJO_EVENTOS.
					Q_MANEJADOR_EVENTO.To_Marshaller (Q_LIBRERIA_MANEJO_EVENTOS.F_DESTRUIR_VENTANA_PRINCIPAL'Access),
			 After => False);

	Gtkada.Style.Load_Css_File (Path => "/home/hector/ITS/gtkada/estilo.css",
				    Priority => 600);

	Gtk.Window.Show_All (V_VENTANA_PRINCIPAL);

	Gtk.Main.Main;

end teseo;
-------------------------------------------------------------------------------------------------------------------------------------------
