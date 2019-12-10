--------------------------------------------------------------------------------------------------------------------------------------------
--
--      Fichero:        q_libreria_manejo_eventos.adb
--
--      Autor:          Hector Uhalte Bilbao
--
--      Fecha:          1/8/2018
--      
--------------------------------------------------------------------------------------------------------------------------------------------

with Gtk.Main;
--
with Gtk.Box;
with Gtk.Label;
with Gtk.Widget; use Gtk.Widget; --Este use se usa para hacer la comparacion con el widget nulo.
with Gtk.Scrolled_Window;
with Gtk.Tree_View;
with Gtk.List_Store;
with Glib;
with Gtk.Cell_Renderer_Text;
with Gtk.Tree_View_Column;
with Gtk.Tree_Model;
with Q_VEHICULO.Q_ACCIONES;
with Gtk.Container;

package body Q_LIBRERIA_MANEJO_EVENTOS is

	-----------------------------------------------------------------------------------------------
	-- Procedimiento para destruir la ventana principal mediante un boton de la aplicacion
	-----------------------------------------------------------------------------------------------
	procedure P_DESTRUIR_VENTANA_PRINCIPAL (V_BOTON : access Gtk.Button.Gtk_Button_Record'Class) is

		pragma Unreferenced (V_BOTON);

	begin

		Gtk.Main.Main_Quit;

	end P_DESTRUIR_VENTANA_PRINCIPAL;
	-----------------------------------------------------------------------------------------------

	---------------------------------------------------------------------------------------
	-- Procedimiento para agregar un vehiculo a la lista de vehiculos
	---------------------------------------------------------------------------------------
	procedure P_AGREGAR_VEHICULO (V_MODELO_DATOS : in out Gtk.List_Store.Gtk_List_Store) is

		V_VEHICULO : Q_VEHICULO.T_VEHICULO;

		-- Iterador para recorrer el modelo.
                V_ITERADOR : Gtk.Tree_Model.Gtk_Tree_Iter;

	begin

		-- Generar vehiculo aleatorio.
                Q_VEHICULO.Q_ACCIONES.P_GENERAR_VEHICULO (V_VEHICULO);

		-- Añadir una fila.
                Gtk.List_Store.Append (List_Store => V_MODELO_DATOS,
                                       Iter => V_ITERADOR);

		Gtk.List_Store.Set (Tree_Store => V_MODELO_DATOS,
                                    Iter => V_ITERADOR,
                                    Column => 0,
                                    Value => Q_VEHICULO.F_OBTENER_MATRICULA (V_VEHICULO));

               	Gtk.List_Store.Set (Tree_Store => V_MODELO_DATOS,
                                    Iter => V_ITERADOR,
                                    Column => 1,
                                    Value => 
					Q_VEHICULO.F_OBTENER_NOMBRE_MARCA (V_VEHICULO)(1..10) & " " & 
					Q_VEHICULO.F_OBTENER_NOMBRE_MODELO (V_VEHICULO)(1..7));

		if Integer(Gtk.List_Store.N_Children (V_MODELO_DATOS)) mod 2 = 0 then

			-- Siguiente fila par. Color de fondo negro
			Gtk.List_Store.Set (Tree_Store => V_MODELO_DATOS,
                                    	    Iter => V_ITERADOR,
                                    	    Column => 2,
                                    	    Value => "#000000");

		else

			-- Siguiente fila impar. Color de fondo azul oscuro
			Gtk.List_Store.Set (Tree_Store => V_MODELO_DATOS,
                                    	    Iter => V_ITERADOR,
                                    	    Column => 2,
                                            Value => "#06243D");

		end if;

	end P_AGREGAR_VEHICULO;
	-----------------------

	---------------------------------------------------------------------------
	-- Procedimiento para generar la lista de vehiculos y los widgets asociados
	---------------------------------------------------------------------------
	procedure P_GENERAR_VEHICULO (V_BOTON : access Gtk.Button.Gtk_Button_Record'Class;
                                      V_DATOS_USUARIO : in T_REGISTRO_USUARIO) is

		pragma Unreferenced (V_BOTON);

		-- Caja nula
                V_WIDGET_NULO : Gtk.Widget.Gtk_Widget := Gtk.Widget.Gtk_Widget'(null);

		V_CAJA_TITULO_VEHICULOS, V_CAJA_VACIA, V_CAJA_TITULO_VEHICULOS_SUBRAYADO, V_CAJA_TITULO_MATRICULA_MODELO,
		V_CAJA_TITULO_MATRICULA, V_CAJA_TITULO_MODELO : Gtk.Box.Gtk_Box;

		V_LABEL_TITULO_VEHICULOS, V_LABEL_TITULO_MATRICULA, V_LABEL_TITULO_MODELO : Gtk.Label.Gtk_Label;

		-- Caja scroll
                V_CAJA_SCROLL : Gtk.Scrolled_Window.Gtk_Scrolled_Window;

		-- Crear el Tree View.
                V_TREE_VIEW : Gtk.Tree_View.Gtk_Tree_View;

		-- Renderer de texto
                V_RENDERER_TEXTO : Gtk.Cell_Renderer_Text.Gtk_Cell_Renderer_Text;

		-- Columnas
                V_COLUMNA_MATRICULA, V_COLUMNA_MODELO, V_COLUMNA_COLOR : Gtk.Tree_View_Column.Gtk_Tree_View_Column;

		-- Columna ID
                V_COLUMNA_ID : Glib.Gint;

		V_MODELO_DATOS_AUX : Gtk.List_Store.Gtk_List_Store;

	begin

		-- Hacer que la etiqueta de vehiculos solo aparezca al apretar el boton de generar vehiculo por primera vez.
                if Gtk.Box.Get_Child (Box => V_DATOS_USUARIO.R_CAJA,
                                      Num => 0) = V_WIDGET_NULO then

			Gtk.Box.Gtk_New_Hbox (Box => V_CAJA_TITULO_VEHICULOS,
                                              Homogeneous => False,
                                              Spacing => 0);

			Gtk.Box.Set_Name (Widget => V_CAJA_TITULO_VEHICULOS,
                                          Name => "cajaTituloVehiculos");

                        Gtk.Box.Set_Size_Request (Widget => V_CAJA_TITULO_VEHICULOS,
                                                  Height => 30);

                        Gtk.Label.Gtk_New (Label => V_LABEL_TITULO_VEHICULOS,
                                           Str => "VEHICULOS");

			Gtk.Label.Set_Name (Widget => V_LABEL_TITULO_VEHICULOS,
                                            Name => "labelTituloVehiculos");

                        Gtk.Label.Set_Size_Request (Widget => V_LABEL_TITULO_VEHICULOS,
                                                    Width => 100);

                        Gtk.Box.Gtk_New_Hbox (Box => V_CAJA_VACIA,
                                              Homogeneous => True,
                                              Spacing => 0);

			Gtk.Box.Set_Size_Request (Widget => V_CAJA_VACIA,
                                                  Width => 10);

			Gtk.Box.Gtk_New_Hbox (Box => V_CAJA_TITULO_VEHICULOS_SUBRAYADO,
                                              Homogeneous => True,
                                              Spacing => 0);

                        Gtk.Box.Set_Name (Widget => V_CAJA_TITULO_VEHICULOS_SUBRAYADO,
                                          Name => "cajaTituloVehiculosSubrayado");

                        Gtk.Box.Set_Size_Request (Widget => V_CAJA_TITULO_VEHICULOS_SUBRAYADO,
                                                  Width => 350);

			Gtk.Box.Gtk_New_Hbox (Box => V_CAJA_TITULO_MATRICULA_MODELO,
                                              Homogeneous => False,
                                              Spacing => 0);

                        Gtk.Box.Set_Name (Widget => V_CAJA_TITULO_MATRICULA_MODELO,
                                          Name => "cajaTituloMatriculaModelo");

                        Gtk.Box.Set_Size_Request (Widget => V_CAJA_TITULO_MATRICULA_MODELO,
                                                  Height => 30);

			Gtk.Box.Gtk_New_Hbox (Box => V_CAJA_TITULO_MATRICULA,
                                              Homogeneous => True,
                                              Spacing => 0);

                        Gtk.Box.Set_Name (Widget => V_CAJA_TITULO_MATRICULA,
                                          Name => "cajaTituloMatricula");

                        Gtk.Box.Gtk_New_Hbox (Box => V_CAJA_TITULO_MODELO,
                                              Homogeneous => True,
                                              Spacing => 0);
			
			Gtk.Box.Set_Name (Widget => V_CAJA_TITULO_MODELO,
                                          Name => "cajaTituloModelo");

                        Gtk.Box.Set_Size_Request (Widget => V_CAJA_TITULO_MODELO,
                                                  Width => 100);

                        Gtk.Label.Gtk_New (Label => V_LABEL_TITULO_MATRICULA,
                                           Str => "MATRICULA");

			Gtk.Label.Set_Size_Request (Widget => V_LABEL_TITULO_MATRICULA,
                                                    Width => 40);

                        Gtk.Label.Set_Name (Widget => V_LABEL_TITULO_MATRICULA,
                                            Name => "labelTituloMatricula");

                        Gtk.Label.Gtk_New (Label => V_LABEL_TITULO_MODELO,
                                           Str => "MODELO");

			Gtk.Label.Set_Size_Request (Widget => V_LABEL_TITULO_MODELO,
                                                    Width => 160);

                        Gtk.Label.Set_Name (Widget => V_LABEL_TITULO_MODELO,
                                            Name => "labelTituloModelo");

                        Gtk.Scrolled_Window.Gtk_New (V_CAJA_SCROLL);

			Gtk.Scrolled_Window.Set_Size_Request (Widget => V_CAJA_SCROLL,
                                                              Height => 650);

                        Gtk.Scrolled_Window.Set_Name (Widget => V_CAJA_SCROLL,
                                                      Name => "cajaScroll");

                        Gtk.Scrolled_Window.Set_Border_Width (Container => V_CAJA_SCROLL,
                                                              Border_Width => 5);

			V_MODELO_DATOS_AUX := V_DATOS_USUARIO.R_MODELO_DATOS;

			P_AGREGAR_VEHICULO (V_MODELO_DATOS_AUX);

			-- Crear el widget Tree View con el modelo Gtk.List_Store.
                	Gtk.Tree_View.Gtk_New (Tree_View => V_TREE_VIEW,
                                       	       Model => V_MODELO_DATOS_AUX);

			-- Añadir columnas.
                	-- Usar un renderer de texto para cada columna.
                	Gtk.Cell_Renderer_Text.Gtk_New (V_RENDERER_TEXTO);

                	Gtk.Tree_View_Column.Gtk_New (V_COLUMNA_MATRICULA);
                	Gtk.Tree_View_Column.Gtk_New (V_COLUMNA_MODELO);
			Gtk.Tree_View_Column.Gtk_New (V_COLUMNA_COLOR);

			Gtk.Tree_View_Column.Set_Expand (Tree_Column => V_COLUMNA_MATRICULA,
                                                 	 Expand => True);

                	Gtk.Tree_View_Column.Set_Expand (Tree_Column => V_COLUMNA_MODELO,
                         	                         Expand => True);

                	Gtk.Tree_View_Column.Set_Fixed_Width (Tree_Column => V_COLUMNA_MATRICULA,
                        	                              Fixed_Width => 8); -- 8 Caracteres es la longitud del string para la matricula

                	Gtk.Tree_View_Column.Set_Fixed_Width (Tree_Column => V_COLUMNA_MODELO,
                        	                              Fixed_Width => 18); -- 18 String maximo para marca y modelo.

                	Gtk.Cell_Renderer_Text.Set_Alignment (Cell => V_RENDERER_TEXTO,
                        	                              Xalign => 0.5,
                                	                      Yalign => 0.5);

                	Gtk.Tree_View_Column.Pack_Start (Cell_Layout => V_COLUMNA_MATRICULA,
                        	                         Cell => V_RENDERER_TEXTO,
                                	                 Expand =>  True);

                	Gtk.Tree_View_Column.Pack_Start (Cell_Layout => V_COLUMNA_MODELO,
                        	                         Cell => V_RENDERER_TEXTO,
                                	                 Expand => True);

			-- Añadir atributos.
                	Gtk.Tree_View_Column.Add_Attribute (Cell_Layout => V_COLUMNA_MATRICULA,
                        	                            Cell => V_RENDERER_TEXTO,
                                	                    Attribute => "text",
                                        	            Column => 0);

			Gtk.Tree_View_Column.Add_Attribute (Cell_Layout => V_COLUMNA_MATRICULA,
							    Cell => V_RENDERER_TEXTO,
							    Attribute => "background",
							    Column => 2);

                	Gtk.Tree_View_Column.Add_Attribute (Cell_Layout => V_COLUMNA_MODELO,
                        	                            Cell => V_RENDERER_TEXTO,
                                	                    Attribute => "text",
                                        	            Column => 1);

			Gtk.Tree_View_Column.Add_Attribute (Cell_Layout => V_COLUMNA_MODELO,
							    Cell => V_RENDERER_TEXTO,
							    Attribute => "background",
							    Column => 2);

                	-- Añadir las columnas al tree_view.
                	V_COLUMNA_ID := Gtk.Tree_View.Append_Column (Tree_View => V_TREE_VIEW,
                        	                                     Column => V_COLUMNA_MATRICULA);

                	V_COLUMNA_ID := Gtk.Tree_View.Append_Column (Tree_View => V_TREE_VIEW,
                        	                                     Column => V_COLUMNA_MODELO);

			V_COLUMNA_ID := Gtk.Tree_View.Append_Column (Tree_View => V_TREE_VIEW,
								     Column => V_COLUMNA_COLOR);

			Gtk.Tree_View.Set_Headers_Visible (Tree_View => V_TREE_VIEW,
                                                           Headers_Visible => False);

                        Gtk.Tree_View.Set_Name (Widget => V_TREE_VIEW,
                                                Name => "matrizVehiculos");

                        -- De momento no queremos hacer nada con los vehiculos creados.
                        Gtk.Tree_View.Set_Sensitive (Widget => V_TREE_VIEW,
                                                     Sensitive => False);

                        Gtk.Scrolled_Window.Add (Container => V_CAJA_SCROLL,
                                                 Widget => V_TREE_VIEW);

			-- Packing.

                        Gtk.Box.Pack_Start (In_Box => V_CAJA_TITULO_VEHICULOS,
                                            Child => V_CAJA_VACIA,
                                            Expand => False,
                                            Fill => False,
                                            Padding => 0);

                        Gtk.Box.Pack_Start (In_Box => V_CAJA_TITULO_VEHICULOS,
                                            Child => V_LABEL_TITULO_VEHICULOS,
                                            Expand => False,
                                            Fill => False,
                                            Padding => 0);

                        Gtk.Box.Pack_Start (In_Box => V_CAJA_TITULO_VEHICULOS,
                                            Child => V_CAJA_TITULO_VEHICULOS_SUBRAYADO,
                                            Expand => False,
                                            Fill => False,
                                            Padding => 0);

                        Gtk.Box.Pack_Start (In_Box => V_CAJA_TITULO_MATRICULA,
                                            Child => V_LABEL_TITULO_MATRICULA,
                                            Expand => False,
                                            Fill => False,
                                            Padding => 0);

                        Gtk.Box.Pack_Start (In_Box => V_CAJA_TITULO_MODELO,
                                            Child => V_LABEL_TITULO_MODELO,
                                            Expand => False,
                                            Fill => False,
                                            Padding => 0);

			Gtk.Box.Pack_Start (In_Box => V_CAJA_TITULO_MATRICULA_MODELO,
                                            Child => V_CAJA_TITULO_MATRICULA,
                                            Expand => False,
                                            Fill => False,
                                            Padding => 85);

                        Gtk.Box.Pack_Start (In_Box => V_CAJA_TITULO_MATRICULA_MODELO,
                                            Child => V_CAJA_TITULO_MODELO,
                                            Expand => False,
                                            Fill => False,
                                            Padding => 40);

                        Gtk.Box.Pack_Start (In_Box => V_DATOS_USUARIO.R_CAJA,
                                            Child => V_CAJA_TITULO_VEHICULOS,
                                            Expand => False,
                                            Fill => False,
                                            Padding => 10);

                        Gtk.Box.Pack_Start (In_Box => V_DATOS_USUARIO.R_CAJA,
                                            Child => V_CAJA_TITULO_MATRICULA_MODELO,
                                            Expand => False,
                                            Fill => False,
                                            Padding => 0);

                        Gtk.Box.Pack_Start (In_Box => V_DATOS_USUARIO.R_CAJA,
                                            Child => V_CAJA_SCROLL,
                                            Expand => False,
                                            Fill => False,
                                            Padding => 0);

                        Gtk.Box.Show_All (V_DATOS_USUARIO.R_CAJA);

                        Gtk.Box.Queue_Draw (V_DATOS_USUARIO.R_CAJA);

		else

			V_MODELO_DATOS_AUX := V_DATOS_USUARIO.R_MODELO_DATOS;

			P_AGREGAR_VEHICULO (V_MODELO_DATOS_AUX);

		end if;

	end P_GENERAR_VEHICULO;
	----------------------------------------------------------------------------

	-------------------------------------------------------------
	procedure P_BORRAR_VEHICULOS (V_BOTON : access Gtk.Button.Gtk_Button_Record'Class;
				      V_DATOS_USUARIO : in T_REGISTRO_USUARIO) is

		-- Lista de hijos.
		V_LISTA_HIJOS : Gtk.Widget.Widget_List.Glist := Gtk.Box.Get_Children (V_DATOS_USUARIO.R_CAJA);

	begin

		-- Destruir los widget hijos de la Caja izquierda.
		for I in 0 .. Integer(Gtk.Widget.Widget_List.Length (V_LISTA_HIJOS)) - 1 loop
			
			Gtk.Widget.Destroy (Gtk.Widget.Widget_List.Nth_Data (List => V_LISTA_HIJOS,
	 								     N => Glib.Guint(I)));

		end loop;

		Gtk.List_Store.Clear (V_DATOS_USUARIO.R_MODELO_DATOS);

	end P_BORRAR_VEHICULOS;
	-------------------------------------------------------------

end Q_LIBRERIA_MANEJO_EVENTOS;
--------------------------------------------------------------------------------------------------------------------------------------------
