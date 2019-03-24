-------------------------------------------------------------------------------------------------------------------------------------------
--
--      Fichero:        q_adaptacion_area_trabajo.adb
--
--      Autor:          Hector Uhalte Bilbao
--
--      Fecha:          8/3/2018
--      
-------------------------------------------------------------------------------------------------------------------------------------------

with Input_Sources.File;
with Dom.Readers;
with Sax.Readers;
with Dom.Core;
with Dom.Core.Documents;
with Dom.Core.Nodes;
with Ada.Sequential_Io;
with Ada.Numerics.Discrete_Random;
with Ada.Text_Io;
with Ada.Characters.Latin_1;
with Ada.Float_Text_Io;

package body Q_ADAPTACION_AREA_TRABAJO is

	C_FICHERO_XML : constant String := "/home/hector/eclipse-workspace/ITS/areaTrabajo.xml";

        C_FICHERO_LOG_ADAPTACION : constant String := "/home/hector/ITS/log/log_adaptation_file";

	--------------------------------
	-- Cargar la adaptacion en un
	-- fichero binario
	--------------------------------
	procedure P_CARGAR_ADAPTACION is

		-- Descriptor de fichero.
                V_DESCRIPTOR_FICHERO_XML : Input_Sources.File.File_Input;

		-- Lector XML. Para usarlo en el parser de DOM
                V_LECTOR_XML : Dom.Readers.Tree_Reader;

		V_DOCUMENTO_XML : Dom.Core.Document;

		V_LISTA_DATOS, V_LISTA_RADIO_TIERRA, V_LISTA_PUNTO_TANGENCIA, V_LISTA_LIMITES, V_LISTA_COORDENADAS_TANGENCIA, 
		V_LISTA_LIMITE_NODO : Dom.Core.Node_List;

		V_PUNTO_TANGENCIA : Dom.Core.Node;

		V_DATO, V_LIMITE : Dom.Core.Node;

		V_AREA_TRABAJO_ADAPTACION : T_AREA_TRABAJO_ADAPTACION;

		V_TANGENCIA_LATITUD : Q_TIPOS_BASICOS.T_LATITUD;

		V_TANGENCIA_LONGITUD : Q_TIPOS_BASICOS.T_LONGITUD;

		package Q_AREA_TRABAJO_IO is new Ada.Sequential_IO (T_AREA_TRABAJO_ADAPTACION);

		V_FICHERO_AREA_TRABAJO : Q_AREA_TRABAJO_IO.File_Type;
		
	begin

		Q_AREA_TRABAJO_IO.Create (File => V_FICHERO_AREA_TRABAJO,
				          Name => "/home/hector/ITS/adaptacion/area_trabajo.bin");

		Input_Sources.File.Set_Public_Id (Input => V_DESCRIPTOR_FICHERO_XML,
                                                  Id => C_FICHERO_LOG_ADAPTACION);

		Input_Sources.File.Open (Filename => C_FICHERO_XML,
                                         Input => V_DESCRIPTOR_FICHERO_XML);

		-- Estos "Set.Feature" habra que cambiarlos cuando se implemente los namespaces, y el chequeo de esquemas.
                Dom.Readers.Set_Feature (Parser => V_LECTOR_XML,
                                         Name => Sax.Readers.Validation_Feature,
                                         Value => False);

                Dom.Readers.Set_Feature (Parser => V_LECTOR_XML,
                                         Name => Sax.Readers.Namespace_Feature,
                                         Value => False);

		Dom.Readers.Parse (Parser => V_LECTOR_XML,
                                   Input => V_DESCRIPTOR_FICHERO_XML);

		Input_Sources.File.Close (V_DESCRIPTOR_FICHERO_XML);

		V_DOCUMENTO_XML := Dom.Readers.Get_Tree (V_LECTOR_XML);

		-- Obtener la lista de datos del punto de tangencia
		V_LISTA_PUNTO_TANGENCIA := Dom.Core.Documents.Get_Elements_By_Tag_Name (Doc => V_DOCUMENTO_XML,
					                   		   		Tag_Name => "its:puntoTangencia");
		-- Recorrer los datos del punto de tangencia	
                for I in 0 .. Dom.Core.Nodes.Length(V_LISTA_PUNTO_TANGENCIA) -1 loop

			V_PUNTO_TANGENCIA := Dom.Core.Nodes.Item (List => V_LISTA_PUNTO_TANGENCIA,
								  Index => I);

			V_LISTA_COORDENADAS_TANGENCIA := Dom.Core.Nodes.Child_Nodes (V_PUNTO_TANGENCIA);

			for J in 0 .. Dom.Core.Nodes.Length(V_LISTA_COORDENADAS_TANGENCIA) -1 loop

				V_DATO := Dom.Core.Nodes.Item (List => V_LISTA_COORDENADAS_TANGENCIA,
                                                               Index => J);

				if Dom.Core.Nodes.Node_Name (V_DATO) = "its:latitud" then

                             		V_TANGENCIA_LATITUD := 
                                      		Float'Value(Dom.Core.Nodes.Node_Value(Dom.Core.Nodes.First_Child(V_DATO)));

                      		end if;

				if Dom.Core.Nodes.Node_Name (V_DATO) = "its:longitud" then

                                        V_TANGENCIA_LONGITUD :=
                                                Float'Value(Dom.Core.Nodes.Node_Value(Dom.Core.Nodes.First_Child(V_DATO)));

                                end if;

			end loop;

		end loop;

		V_AREA_TRABAJO_ADAPTACION.R_PUNTO_TANGENCIA := 
			Q_TIPOS_BASICOS.F_OBTENER_POSICION_LAT_LON (V_LATITUD => V_TANGENCIA_LATITUD,
                                                                    V_LONGITUD => V_TANGENCIA_LONGITUD);


		-- Obtener la lista de datos del radio de la tierra
                V_LISTA_RADIO_TIERRA := Dom.Core.Documents.Get_Elements_By_Tag_Name (Doc => V_DOCUMENTO_XML,
                                                                                     Tag_Name => "its:radioTierra");

		-- Recorrer los datos del punto de tangencia    
                for I in 0 .. Dom.Core.Nodes.Length(V_LISTA_RADIO_TIERRA) -1 loop

			V_DATO := Dom.Core.Nodes.Item (List => V_LISTA_RADIO_TIERRA,
                                                       Index => I);

			V_AREA_TRABAJO_ADAPTACION.R_RADIO_TIERRA := 
				Integer'Value(Dom.Core.Nodes.Node_Value(Dom.Core.Nodes.First_Child(V_DATO)));

		end loop;

		-- Obtener la lista de datos del punto de tangencia
                V_LISTA_LIMITES := Dom.Core.Documents.Get_Elements_By_Tag_Name (Doc => V_DOCUMENTO_XML,
                                                                                        Tag_Name => "its:areaTrabajo");
                -- Recorrer los datos del punto de tangencia    
                for I in 0 .. Dom.Core.Nodes.Length(V_LISTA_LIMITES) -1 loop

                        V_LIMITE := Dom.Core.Nodes.Item (List => V_LISTA_LIMITES,
                                                         Index => I);

                        V_LISTA_LIMITE_NODO := Dom.Core.Nodes.Child_Nodes (V_LIMITE);

                        for J in 0 .. Dom.Core.Nodes.Length(V_LISTA_LIMITE_NODO) -1 loop

                                V_DATO := Dom.Core.Nodes.Item (List => V_LISTA_LIMITE_NODO,
                                                               Index => J);

                                if Dom.Core.Nodes.Node_Name (V_DATO) = "its:minimaLatitud" then

                                        V_AREA_TRABAJO_ADAPTACION.R_LATITUD_MINIMA :=
                                                Float'Value(Dom.Core.Nodes.Node_Value(Dom.Core.Nodes.First_Child(V_DATO)));

                                end if;

                                if Dom.Core.Nodes.Node_Name (V_DATO) = "its:maximaLatitud" then

                                        V_AREA_TRABAJO_ADAPTACION.R_LATITUD_MAXIMA :=
                                                Float'Value(Dom.Core.Nodes.Node_Value(Dom.Core.Nodes.First_Child(V_DATO)));

                                end if;

				if Dom.Core.Nodes.Node_Name (V_DATO) = "its:minimaLongitud" then

                                        V_AREA_TRABAJO_ADAPTACION.R_LONGITUD_MINIMA :=
                                                Float'Value(Dom.Core.Nodes.Node_Value(Dom.Core.Nodes.First_Child(V_DATO)));

                                end if;

                                if Dom.Core.Nodes.Node_Name (V_DATO) = "its:maximaLongitud" then

                                        V_AREA_TRABAJO_ADAPTACION.R_LONGITUD_MAXIMA :=
                                                Float'Value(Dom.Core.Nodes.Node_Value(Dom.Core.Nodes.First_Child(V_DATO)));

                                end if;

                        end loop;

                end loop;

		-- Guardar el V_AREA_TRABAJO_ADAPTACION en un fichero binario area_trabajo.bin
		Q_AREA_TRABAJO_IO.Write (File => V_FICHERO_AREA_TRABAJO,
				         Item => V_AREA_TRABAJO_ADAPTACION);

		Dom.Core.Free (V_LISTA_DATOS);
                                                
		Dom.Readers.Free (V_LECTOR_XML);

		Q_AREA_TRABAJO_IO.Close (V_FICHERO_AREA_TRABAJO);

	end P_CARGAR_ADAPTACION;
	-------------------------------

	------------------------------------------------------------------------------------------
	procedure P_LEER_ADAPTACION (V_AREA_TRABAJO_ADAPTACION : out T_AREA_TRABAJO_ADAPTACION) is

		package Q_AREA_TRABAJO_IO is new Ada.Sequential_IO (T_AREA_TRABAJO_ADAPTACION);

                V_FICHERO_AREA_TRABAJO : Q_AREA_TRABAJO_IO.File_Type;

                I : Integer := 0;

	begin

		Q_AREA_TRABAJO_IO.Open (File => V_FICHERO_AREA_TRABAJO,
                                    Mode => Q_AREA_TRABAJO_IO.In_File,
                                    Name => "/home/hector/ITS/adaptacion/area_trabajo.bin");

                -- Leer el fichero binario de adaptacion
                while not Q_AREA_TRABAJO_IO.End_Of_File (V_FICHERO_AREA_TRABAJO) loop

                        Q_AREA_TRABAJO_IO.Read (File => V_FICHERO_AREA_TRABAJO,
                                                Item => V_AREA_TRABAJO_ADAPTACION);

                end loop;

                Q_AREA_TRABAJO_IO.Close (V_FICHERO_AREA_TRABAJO);

	end P_LEER_ADAPTACION;
	----------------------

	-------------------------------------------------------------------------------
        function F_OBTENER_PUNTO_TANGENCIA return Q_TIPOS_BASICOS.T_POSICION_LAT_LON is

		V_AREA_TRABAJO_ADAPTACION : T_AREA_TRABAJO_ADAPTACION;

        begin

		P_LEER_ADAPTACION (V_AREA_TRABAJO_ADAPTACION);

		return V_AREA_TRABAJO_ADAPTACION.R_PUNTO_TANGENCIA;

        end F_OBTENER_PUNTO_TANGENCIA;
        -------------------------------------------------------------------------------

	---------------------------------------------------------------------
	function F_OBTENER_LATITUD_MINIMA return Q_TIPOS_BASICOS.T_LATITUD is

		V_AREA_TRABAJO_ADAPTACION : T_AREA_TRABAJO_ADAPTACION;

	begin

		P_LEER_ADAPTACION (V_AREA_TRABAJO_ADAPTACION);

		return V_AREA_TRABAJO_ADAPTACION.R_LATITUD_MINIMA;

	end F_OBTENER_LATITUD_MINIMA;
	---------------------------------------------------------------------

	---------------------------------------------------------------------
        function F_OBTENER_LATITUD_MAXIMA return Q_TIPOS_BASICOS.T_LATITUD is

                V_AREA_TRABAJO_ADAPTACION : T_AREA_TRABAJO_ADAPTACION;

        begin

                P_LEER_ADAPTACION (V_AREA_TRABAJO_ADAPTACION);

                return V_AREA_TRABAJO_ADAPTACION.R_LATITUD_MAXIMA;

        end F_OBTENER_LATITUD_MAXIMA;
        ---------------------------------------------------------------------

	-----------------------------------------------------------------------
        function F_OBTENER_LONGITUD_MINIMA return Q_TIPOS_BASICOS.T_LONGITUD is

                V_AREA_TRABAJO_ADAPTACION : T_AREA_TRABAJO_ADAPTACION;

        begin

                P_LEER_ADAPTACION (V_AREA_TRABAJO_ADAPTACION);

                return V_AREA_TRABAJO_ADAPTACION.R_LONGITUD_MINIMA;

        end F_OBTENER_LONGITUD_MINIMA;
        -----------------------------------------------------------------------

        -----------------------------------------------------------------------
        function F_OBTENER_LONGITUD_MAXIMA return Q_TIPOS_BASICOS.T_LONGITUD is

                V_AREA_TRABAJO_ADAPTACION : T_AREA_TRABAJO_ADAPTACION;

        begin

                P_LEER_ADAPTACION (V_AREA_TRABAJO_ADAPTACION);

                return V_AREA_TRABAJO_ADAPTACION.R_LONGITUD_MAXIMA;

        end F_OBTENER_LONGITUD_MAXIMA;
        -----------------------------------------------------------------------

	-------------------------
	procedure P_VISUALIZAR is

		V_AREA_TRABAJO_ADAPTACION : T_AREA_TRABAJO_ADAPTACION;

		V_TANGENCIA_UTM : Q_TIPOS_BASICOS.T_POSICION_UTM;

	begin

		P_LEER_ADAPTACION (V_AREA_TRABAJO_ADAPTACION);

		V_TANGENCIA_UTM := Q_TIPOS_BASICOS.F_TRANSFORMAR_LAT_LON_A_UTM (V_AREA_TRABAJO_ADAPTACION.R_PUNTO_TANGENCIA);

		Ada.Text_Io.Put_Line (" Punto Tangencia  => ");

		Ada.Text_Io.Put (Ada.Characters.Latin_1.HT & " X => ");

		Ada.Text_Io.Put_Line (Integer'Image(Q_TIPOS_BASICOS.F_OBTENER_COORDENADA_X (V_TANGENCIA_UTM)));

		Ada.Text_Io.Put (Ada.Characters.Latin_1.HT & " Y => ");

		Ada.Text_Io.Put_Line (Integer'Image(Q_TIPOS_BASICOS.F_OBTENER_COORDENADA_Y (V_TANGENCIA_UTM)));

		Ada.Text_Io.Put_Line (" Radio Tierra => " & Integer'Image(V_AREA_TRABAJO_ADAPTACION.R_RADIO_TIERRA));

		Ada.Text_Io.Put_Line (" Area Trabajo => ");

		Ada.Text_Io.Put_Line (Ada.Characters.Latin_1.HT & " X Minima => " & 
					Integer'Image(Q_TIPOS_BASICOS.F_OBTENER_COORDENADA_X 
						(Q_TIPOS_BASICOS.F_TRANSFORMAR_LAT_LON_A_UTM 
							(Q_TIPOS_BASICOS.F_OBTENER_POSICION_LAT_LON 
								(V_LATITUD => V_AREA_TRABAJO_ADAPTACION.R_LATITUD_MINIMA,
					       		 	 V_LONGITUD => V_AREA_TRABAJO_ADAPTACION.R_LONGITUD_MINIMA)))));

		Ada.Text_Io.Put_Line (Ada.Characters.Latin_1.HT & " X Maxima => " &
                                        Integer'Image (Q_TIPOS_BASICOS.F_OBTENER_COORDENADA_X 
						(Q_TIPOS_BASICOS.F_TRANSFORMAR_LAT_LON_A_UTM 
                                                	(Q_TIPOS_BASICOS.F_OBTENER_POSICION_LAT_LON 
                                                        	(V_LATITUD => V_AREA_TRABAJO_ADAPTACION.R_LATITUD_MAXIMA,
                                                         	 V_LONGITUD => V_AREA_TRABAJO_ADAPTACION.R_LONGITUD_MAXIMA)))));

		Ada.Text_Io.Put_Line (Ada.Characters.Latin_1.HT & " Y Minima => " &
                                        Integer'Image(Q_TIPOS_BASICOS.F_OBTENER_COORDENADA_Y
                                                (Q_TIPOS_BASICOS.F_TRANSFORMAR_LAT_LON_A_UTM
                                                        (Q_TIPOS_BASICOS.F_OBTENER_POSICION_LAT_LON
                                                                (V_LATITUD => V_AREA_TRABAJO_ADAPTACION.R_LATITUD_MINIMA,
                                                                 V_LONGITUD => V_AREA_TRABAJO_ADAPTACION.R_LONGITUD_MINIMA)))));

                Ada.Text_Io.Put_Line (Ada.Characters.Latin_1.HT & " Y Maxima => " &
                                        Integer'Image (Q_TIPOS_BASICOS.F_OBTENER_COORDENADA_Y
                                                (Q_TIPOS_BASICOS.F_TRANSFORMAR_LAT_LON_A_UTM
                                                        (Q_TIPOS_BASICOS.F_OBTENER_POSICION_LAT_LON
                                                                (V_LATITUD => V_AREA_TRABAJO_ADAPTACION.R_LATITUD_MAXIMA,
                                                                 V_LONGITUD => V_AREA_TRABAJO_ADAPTACION.R_LONGITUD_MAXIMA)))));
	
	end P_VISUALIZAR;
	-------------------------

end Q_ADAPTACION_AREA_TRABAJO;
-------------------------------------------------------------------------------------------------------------------------------------------
