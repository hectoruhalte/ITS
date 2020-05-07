-------------------------------------------------------------------------------------------------------------------------------------------
--
--      Fichero:        q_adaptacion_tramo.adb
--
--      Autor:          Hector Uhalte Bilbao
--
--      Fecha:          15/1/2018
--      
-------------------------------------------------------------------------------------------------------------------------------------------

with Input_Sources.File;
with Dom.Readers;
with Sax.Readers;
with Dom.Core;
with Dom.Core.Documents;
with Dom.Core.Nodes;
with Ada.Sequential_Io;
with Ada.Text_Io;
with Ada.Characters.Latin_1;
with Ada.Float_Text_Io;
--
with Q_CONEXION;

package body Q_ADAPTACION_TRAMO is

	C_FICHERO_XML : constant String := "/home/hector/eclipse-workspace/ITS/tramos.xml";

	C_FICHERO_LOG_ADAPTACION : constant String := "/home/hector/ITS/log/log_adaptation_file";

	---------------------------------------------------------------------------
        function F_SON_CARRILES_IGUALES (V_CARRIL_1 : in Natural;
                                         V_CARRIL_2 : in Natural) return Boolean is

        begin

                return V_CARRIL_1 = V_CARRIL_2;

        end F_SON_CARRILES_IGUALES;
        ----------------------------------------------------------------------------


	--------------------------------
	procedure P_CARGAR_ADAPTACION is

		package Q_TRAMO_IO is new Ada.Sequential_IO(T_TRAMO_ADAPTACION);

		V_FICHERO_TRAMO : Q_TRAMO_IO.File_Type;

		-- Descriptor de fichero.
                V_DESCRIPTOR_FICHERO_XML : Input_Sources.File.File_Input;

		-- Lector XML. Para usarlo en el parser de DOM
                V_LECTOR_XML : Dom.Readers.Tree_Reader;

		V_DOCUMENTO_XML : Dom.Core.Document;

		V_LISTA_TRAMOS, V_LISTA_DATOS, V_LISTA_SEGMENTOS, V_LISTA_SEGMENTO_DATOS, V_LISTA_CONEXIONES, V_LISTA_CONEXION_DATOS : 
			Dom.Core.Node_List;
	
		V_TRAMO, V_DATO, V_SEGMENTO, V_SEGMENTO_DATO, V_CONEXION, V_CONEXION_DATO : Dom.Core.Node;

		V_TRAMO_ADAPTACION : T_TRAMO_ADAPTACION;

		V_SEGMENTO_ADAPTACION : T_SEGMENTO_ADAPTACION;

		V_CONEXION_ADAPTACION : T_CONEXION_ADAPTACION;

		V_SEGMENTO_ADAPTACION_REGISTRO : T_SEGMENTO_ADAPTACION_REGISTRO;

		V_CONEXION_ADAPTACION_REGISTRO : T_CONEXION_ADAPTACION_REGISTRO;

		V_NOMBRE_TRAMO : String (1 .. Q_TRAMO.F_OBTENER_LONGITUD_MAXIMA_NOMBRE_TRAMO) := Q_TRAMO.F_OBTENER_NOMBRE_TRAMO_VACIO;

		-- String para almacener el "True" o el "False" de la etiqueta <its:dobleSentido>.
		V_DOBLE_SENTIDO : String (1 .. 5) := (others => ADA.CHARACTERS.Latin_1.NUL);

		V_COMIENZO_LATITUD, V_FINAL_LATITUD, V_SEGMENTO_LATITUD : Q_TIPOS_BASICOS.T_LATITUD := 0.0;

		V_COMIENZO_LONGITUD, V_FINAL_LONGITUD, V_SEGMENTO_LONGITUD : Q_TIPOS_BASICOS.T_LATITUD := 0.0; 

	begin

		-- Crear o sobreescribir el fichero binario de adaptacion para los tramos.
		Q_TRAMO_IO.Create (File => V_FICHERO_TRAMO,
                                   Name => "/home/hector/ITS/adaptacion/tramos.bin");

		-- Abrir el descriptor del fichero log de la adaptacion.
		Input_Sources.File.Set_Public_Id (Input => V_DESCRIPTOR_FICHERO_XML,
                                                  Id => C_FICHERO_LOG_ADAPTACION);

		-- Abrir el fichero tramos.xml
		Input_Sources.File.Open (Filename => C_FICHERO_XML,
                                         Input => V_DESCRIPTOR_FICHERO_XML);

		-- Estos "Set.Feature" habra que cambiarlos cuando se implemente los namespaces, y el chequeo de esquemas.
                Dom.Readers.Set_Feature (Parser => V_LECTOR_XML,
                                         Name => Sax.Readers.Validation_Feature,
                                         Value => False);

                Dom.Readers.Set_Feature (Parser => V_LECTOR_XML,
                                         Name => Sax.Readers.Namespace_Feature,
                                         Value => False);

		-- Traduccion del tramos.xml en V_LECTOR_XML
                Dom.Readers.Parse (Parser => V_LECTOR_XML,
                                   Input => V_DESCRIPTOR_FICHERO_XML);

		Input_Sources.File.Close (V_DESCRIPTOR_FICHERO_XML);

		V_DOCUMENTO_XML := Dom.Readers.Get_Tree (V_LECTOR_XML);

		-- Obtener la lista de tramos adaptados.
                V_LISTA_TRAMOS := Dom.Core.Documents.Get_Elements_By_Tag_Name (Doc => V_DOCUMENTO_XML,
                                                                               Tag_Name => "its:datosTramo");

		-- Recorrer la lista de tramos adaptados.
                for I in 0 .. Dom.Core.Nodes.Length(V_LISTA_TRAMOS) -1 loop

			V_TRAMO := Dom.Core.Nodes.Item (List => V_LISTA_TRAMOS,
                                                        Index => I);

			V_LISTA_DATOS := Dom.Core.Nodes.Child_Nodes (V_TRAMO);

			for J in 0 .. Dom.Core.Nodes.Length(V_LISTA_DATOS) -1 loop

				V_DATO := Dom.Core.Nodes.Item (List => V_LISTA_DATOS,
                                                               Index => J);

				if Dom.Core.Nodes.Node_Name(V_DATO) = "its:id" then

					-- Obtener el id				
					V_TRAMO_ADAPTACION.R_ID := 
						Integer'Value(Dom.Core.Nodes.Node_Value(Dom.Core.Nodes.First_Child(V_DATO)));

				end if;			

				if Dom.Core.Nodes.Node_Name(V_DATO) = "its:nombreTramo" then

					V_NOMBRE_TRAMO := Q_TRAMO.F_OBTENER_NOMBRE_TRAMO_VACIO;

					-- Obtener el nombre del tramo
					V_NOMBRE_TRAMO 
						(V_NOMBRE_TRAMO'First .. 
						Dom.Core.Nodes.Node_Value(Dom.Core.Nodes.First_Child(V_DATO))'Length) := 
							Dom.Core.Nodes.Node_Value(Dom.Core.Nodes.First_Child(V_DATO));

					V_TRAMO_ADAPTACION.R_NOMBRE_TRAMO := V_NOMBRE_TRAMO;

				end if;

				if Dom.Core.Nodes.Node_Name(V_DATO) = "its:comienzoLatitud" then

					V_COMIENZO_LATITUD := Float'Value(Dom.Core.Nodes.Node_Value(Dom.Core.Nodes.First_Child(V_DATO)));

				end if;

				if Dom.Core.Nodes.Node_Name(V_DATO) = "its:comienzoLongitud" then

                                        V_COMIENZO_LONGITUD := Float'Value(Dom.Core.Nodes.Node_Value(Dom.Core.Nodes.First_Child(V_DATO)));

                                end if;

				V_TRAMO_ADAPTACION.R_COMIENZO := 
					Q_TIPOS_BASICOS.F_OBTENER_POSICION_LAT_LON (V_LATITUD => V_COMIENZO_LATITUD,
										    V_LONGITUD => V_COMIENZO_LONGITUD);

				if Dom.Core.Nodes.Node_Name(V_DATO) = "its:finalLatitud" then

					V_FINAL_LATITUD := Float'Value(Dom.Core.Nodes.Node_Value(Dom.Core.Nodes.First_Child(V_DATO)));

				end if;

				if Dom.Core.Nodes.Node_Name(V_DATO) = "its:finalLongitud" then

					V_FINAL_LONGITUD := Float'Value(Dom.Core.Nodes.Node_Value(Dom.Core.Nodes.First_Child(V_DATO)));

				end if;

				V_TRAMO_ADAPTACION.R_FINAL :=
					Q_TIPOS_BASICOS.F_OBTENER_POSICION_LAT_LON (V_LATITUD => V_FINAL_LATITUD,
                                                                                    V_LONGITUD => V_FINAL_LONGITUD);

				if Dom.Core.Nodes.Node_Name(V_DATO) = "its:altura" then

					V_TRAMO_ADAPTACION.R_ALTURA := 
						Float'Value(Dom.Core.Nodes.Node_Value(Dom.Core.Nodes.First_Child(V_DATO)));

				end if;

				if Dom.Core.Nodes.Node_Name(V_DATO) = "its:velocidadMaxima" then

					V_TRAMO_ADAPTACION.R_VELOCIDAD_MAXIMA := 
						Integer'Value(Dom.Core.Nodes.Node_Value(Dom.Core.Nodes.First_Child(V_DATO)));

				end if;

				if Dom.Core.Nodes.Node_Name(V_DATO) = "its:listaSegmentos" then

					V_LISTA_SEGMENTOS := Dom.Core.Nodes.Child_Nodes (V_DATO);

					for K in 0 .. Dom.Core.Nodes.Length(V_LISTA_SEGMENTOS) - 1 loop

						V_SEGMENTO := Dom.Core.Nodes.Item (List => V_LISTA_SEGMENTOS,
                                                                                   Index => K);

						if Dom.Core.Nodes.Node_Name(V_SEGMENTO) = "its:segmento" then

							V_LISTA_SEGMENTO_DATOS := Dom.Core.Nodes.Child_Nodes (V_SEGMENTO);
		
							for L in 0 .. Dom.Core.Nodes.Length(V_LISTA_SEGMENTO_DATOS) - 1 loop

								V_SEGMENTO_DATO := Dom.Core.Nodes.Item (List => V_LISTA_SEGMENTO_DATOS,
													Index => L);

								if Dom.Core.Nodes.Node_Name(V_SEGMENTO_DATO) = 
								   "its:posicionSegmentoLatitud" then

									V_SEGMENTO_LATITUD := 
										Float'Value
											(Dom.Core.Nodes.Node_Value
												(Dom.Core.Nodes.First_Child
													(V_SEGMENTO_DATO)));

								end if;

								if Dom.Core.Nodes.Node_Name(V_SEGMENTO_DATO) =
                                                                   "its:posicionSegmentoLongitud" then

                                                                        V_SEGMENTO_LONGITUD :=
                                                                                Float'Value
                                                                                        (Dom.Core.Nodes.Node_Value
                                                                                                (Dom.Core.Nodes.First_Child
                                                                                                        (V_SEGMENTO_DATO)));

                                                                end if;

								if Dom.Core.Nodes.Node_Name(V_SEGMENTO_DATO) = "its:dobleSentido" then

									V_DOBLE_SENTIDO 
										(V_DOBLE_SENTIDO'First ..
                                                                                 Dom.Core.Nodes.Node_Value
											(Dom.Core.Nodes.First_Child
												(V_SEGMENTO_DATO))'Length) :=
                                                        				Dom.Core.Nodes.Node_Value
												(Dom.Core.Nodes.First_Child
													(V_SEGMENTO_DATO));

									if V_DOBLE_SENTIDO (1..4) = "true" then

										V_SEGMENTO_ADAPTACION.R_DOBLE_SENTIDO := True;

									elsif V_DOBLE_SENTIDO (1..5) = "false" then

										V_SEGMENTO_ADAPTACION.R_DOBLE_SENTIDO := False;

									end if;							
	
								end if;

								if Dom.Core.Nodes.Node_Name(V_SEGMENTO_DATO) = "its:numeroCarriles" then

									V_SEGMENTO_ADAPTACION.R_NUMERO_CARRILES := 
										Integer'Value
											(Dom.Core.Nodes.Node_Value
												(Dom.Core.Nodes.First_Child
													(V_SEGMENTO_DATO)));

								end if;

							end loop;

							V_SEGMENTO_ADAPTACION.R_POSICION := Q_TIPOS_BASICOS.F_OBTENER_POSICION_LAT_LON 
                                                        					(V_LATITUD => V_SEGMENTO_LATITUD,
                                                                				 V_LONGITUD => V_SEGMENTO_LONGITUD);

							-- Añadir segmento al array.
							V_SEGMENTO_ADAPTACION_REGISTRO.R_NUMERO_SEGMENTOS := 
								V_SEGMENTO_ADAPTACION_REGISTRO.R_NUMERO_SEGMENTOS + 1;

							V_SEGMENTO_ADAPTACION_REGISTRO.
								R_SEGMENTOS_ADAPTACION_ARRAY 
								(V_SEGMENTO_ADAPTACION_REGISTRO.R_NUMERO_SEGMENTOS) := 
									V_SEGMENTO_ADAPTACION;

						end if;

					end loop;

					V_TRAMO_ADAPTACION.R_LISTA_SEGMENTOS := V_SEGMENTO_ADAPTACION_REGISTRO;

					V_SEGMENTO_ADAPTACION_REGISTRO.R_NUMERO_SEGMENTOS := 0;

				end if;

				if Dom.Core.Nodes.Node_Name(V_DATO) = "its:listaConexiones" then

					-- CAMBIO EN EL TIPO CONEXIONES

					V_LISTA_CONEXIONES := Dom.Core.Nodes.Child_Nodes (V_DATO);

                                        for K in 0 .. Dom.Core.Nodes.Length(V_LISTA_CONEXIONES) - 1 loop

                                        	V_CONEXION := Dom.Core.Nodes.Item (List => V_LISTA_CONEXIONES,
                                                                                   Index => K);

                                               	if Dom.Core.Nodes.Node_Name(V_CONEXION) = "its:conexion" then

							V_LISTA_CONEXION_DATOS := Dom.Core.Nodes.Child_Nodes (V_CONEXION);

							for L in 0 .. Dom.Core.Nodes.Length (V_LISTA_CONEXION_DATOS) - 1 loop

								V_CONEXION_DATO := Dom.Core.Nodes.Item (List => V_LISTA_CONEXION_DATOS,
													Index => L);

								if Dom.Core.Nodes.Node_Name (V_CONEXION_DATO) = "its:tramoId" then

									V_CONEXION_ADAPTACION.R_CONEXION_A_TRAMO := 
										Natural'Value
											(Dom.Core.Nodes.Node_Value
												(Dom.Core.Nodes.First_Child 
													(V_CONEXION_DATO)));

								end if;

								if Dom.Core.Nodes.Node_Name (V_CONEXION_DATO) = "its:carrilActual" then

									V_CONEXION_ADAPTACION.R_CARRIL_ACTUAL :=
										Natural'Value
                                                                                        (Dom.Core.Nodes.Node_Value
                                                                                                (Dom.Core.Nodes.First_Child 
                                                                                                        (V_CONEXION_DATO)));

								end if;

								if Dom.Core.Nodes.Node_Name (V_CONEXION_DATO) = "its:carrilSiguiente" then

									V_CONEXION_ADAPTACION.R_CARRIL_SIGUIENTE :=
										Natural'Value
                                                                                        (Dom.Core.Nodes.Node_Value
                                                                                                (Dom.Core.Nodes.First_Child
                                                                                                        (V_CONEXION_DATO)));

								end if;

								if Dom.Core.Nodes.Node_Name (V_CONEXION_DATO) = "its:restriccionVelocidad"
								then

									V_CONEXION_ADAPTACION.R_RESTRICCION_VELOCIDAD :=
										Q_TIPOS_BASICOS.T_VELOCIDAD'Value
											(Dom.Core.Nodes.Node_Value
                                                                                                (Dom.Core.Nodes.First_Child
                                                                                                        (V_CONEXION_DATO)));

								end if;

							end loop;

							-- Añadir la conexion al array.
							V_CONEXION_ADAPTACION_REGISTRO.R_NUMERO_CONEXIONES := 
								V_CONEXION_ADAPTACION_REGISTRO.R_NUMERO_CONEXIONES + 1;

							V_CONEXION_ADAPTACION_REGISTRO.
								R_CONEXIONES_ADAPTACION_ARRAY 
								(V_CONEXION_ADAPTACION_REGISTRO.R_NUMERO_CONEXIONES) := 
									V_CONEXION_ADAPTACION;                                              

						end if;

                                        end loop;

                                        V_TRAMO_ADAPTACION.R_LISTA_CONEXIONES := V_CONEXION_ADAPTACION_REGISTRO;

					V_CONEXION_ADAPTACION_REGISTRO.R_NUMERO_CONEXIONES := 0;

                        	end if;

			end loop;

			-- Guardar el V_TRAMO_ADAPTACION en un fichero binario tramos.bin
                	Q_TRAMO_IO.Write (File => V_FICHERO_TRAMO,
                                     	  Item => V_TRAMO_ADAPTACION);	
	
		end loop;

		Dom.Core.Free (V_LISTA_TRAMOS);

                Dom.Readers.Free (V_LECTOR_XML);

		-- Cerrar el fichero tramos.bin
		Q_TRAMO_IO.Close (V_FICHERO_TRAMO);

	end P_CARGAR_ADAPTACION;
	--------------------------------

	----------------------------------------------------------------------------------------------
	procedure P_LEER_ADAPTACION (V_TRAMO_ADAPTACION_REGISTRO : out T_TRAMO_ADAPTACION_REGISTRO) is

		package Q_TRAMO_IO is new Ada.Sequential_IO(T_TRAMO_ADAPTACION);

		V_FICHERO_TRAMO : Q_TRAMO_IO.File_Type;

		V_TRAMO_ADAPTACION : T_TRAMO_ADAPTACION;

                I : Integer := 0;

	begin

		Q_TRAMO_IO.Open (File => V_FICHERO_TRAMO,
                                 Mode => Q_TRAMO_IO.In_File,
                                 Name => "/home/hector/ITS/adaptacion/tramos.bin");

		-- Crear un array con los tramos adaptados.
		-- Veremos si un array es suficiente (1_000_000 de tramos como maximo)
                -- Leer el fichero binario de adaptacion

                while not Q_TRAMO_IO.End_Of_File(V_FICHERO_TRAMO) loop

                        I := I + 1;

                        Q_TRAMO_IO.Read (File => V_FICHERO_TRAMO,
                                         Item => V_TRAMO_ADAPTACION);

                        V_TRAMO_ADAPTACION_REGISTRO.R_TRAMO_ADAPTACION_ARRAY (I) := V_TRAMO_ADAPTACION;

                end loop;

                V_TRAMO_ADAPTACION_REGISTRO.R_NUMERO_TRAMOS := I;

                Q_TRAMO_IO.Close (V_FICHERO_TRAMO);

	end P_LEER_ADAPTACION;
	----------------------------------------------------------------------------------------------

	---------------------------------------------------------------------------------
	procedure P_GENERAR_LISTA_TRAMOS (V_LISTA_TRAMOS : out Q_LISTA_TRAMOS.T_LISTA) is

		V_TRAMO_ADAPTACION_REGISTRO : T_TRAMO_ADAPTACION_REGISTRO;

		V_TRAMO_ADAPTACION : T_TRAMO_ADAPTACION;

		V_TRAMO : Q_TRAMO.T_TRAMO;

		V_SEGMENTO_ADAPTACION : T_SEGMENTO_ADAPTACION;

		V_SEGMENTO : Q_SEGMENTO.T_SEGMENTO;

		V_ARRAY_SEGMENTOS : Q_TRAMO.T_ARRAY_SEGMENTOS;

		V_DISTANCIA_SEGURIDAD : Integer := 0;

		-- Variable para contar el numero de vehiculos que fisicamente caben en el tramo.
		V_CAPACIDAD_VEHICULOS : Integer := 0;

		--
		V_CONEXION_ADAPTACION : T_CONEXION_ADAPTACION;

		V_CONEXION : Q_CONEXION.T_CONEXION;

		V_ARRAY_CONEXIONES : Q_TRAMO.T_ARRAY_CONEXIONES;

	begin

		Q_LISTA_TRAMOS.P_INICIALIZAR_LISTA (V_LISTA_TRAMOS);

		P_LEER_ADAPTACION (V_TRAMO_ADAPTACION_REGISTRO);

		for I in 1 .. V_TRAMO_ADAPTACION_REGISTRO.R_NUMERO_TRAMOS loop

			V_TRAMO_ADAPTACION := V_TRAMO_ADAPTACION_REGISTRO.R_TRAMO_ADAPTACION_ARRAY (I);

			Q_TRAMO.P_PONER_ID (V_ID => V_TRAMO_ADAPTACION.R_ID,
					    V_TRAMO => V_TRAMO);

			Q_TRAMO.P_PONER_NOMBRE (V_NOMBRE => V_TRAMO_ADAPTACION.R_NOMBRE_TRAMO,
						V_TRAMO => V_TRAMO);

			Q_TRAMO.P_PONER_ORIGEN (V_ORIGEN => Q_TIPOS_BASICOS.F_TRANSFORMAR_LAT_LON_A_UTM (V_TRAMO_ADAPTACION.R_COMIENZO),
						V_TRAMO => V_TRAMO);

			Q_TRAMO.P_PONER_FINAL (V_FINAL => Q_TIPOS_BASICOS.F_TRANSFORMAR_LAT_LON_A_UTM (V_TRAMO_ADAPTACION.R_FINAL),
					       V_TRAMO => V_TRAMO);

			Q_TRAMO.P_PONER_ALTURA (V_ALTURA => V_TRAMO_ADAPTACION.R_ALTURA,
						V_TRAMO => V_TRAMO);

			Q_TRAMO.P_PONER_VELOCIDAD_MAXIMA (V_VELOCIDAD_MAXIMA => V_TRAMO_ADAPTACION.R_VELOCIDAD_MAXIMA,
							  V_TRAMO => V_TRAMO);

			-- Obtener el array con los segmentos para el tramo.
			for J in 1 .. V_TRAMO_ADAPTACION.R_LISTA_SEGMENTOS.R_NUMERO_SEGMENTOS loop

				Q_SEGMENTO.P_INICIALIZAR_SEGMENTO (V_SEGMENTO);

				V_SEGMENTO_ADAPTACION := V_TRAMO_ADAPTACION.R_LISTA_SEGMENTOS.R_SEGMENTOS_ADAPTACION_ARRAY (J);

				Q_SEGMENTO.P_PONER_POSICION 
					(V_POSICION => Q_TIPOS_BASICOS.F_TRANSFORMAR_LAT_LON_A_UTM (V_SEGMENTO_ADAPTACION.R_POSICION),
					 V_SEGMENTO => V_SEGMENTO);

				Q_SEGMENTO.P_PONER_LISTA_CARRILES (V_NUMERO_CARRILES => V_SEGMENTO_ADAPTACION.R_NUMERO_CARRILES,
								   V_SEGMENTO => V_SEGMENTO);
	
				V_CAPACIDAD_VEHICULOS := V_CAPACIDAD_VEHICULOS + V_SEGMENTO_ADAPTACION.R_NUMERO_CARRILES;

				Q_SEGMENTO.P_PONER_DOBLE_SENTIDO (V_DOBLE_SENTIDO => V_SEGMENTO_ADAPTACION.R_DOBLE_SENTIDO,
								  V_SEGMENTO => V_SEGMENTO);

				-- Por defecto al crear la lista de segmentos todos estaran por defecto disponibles.
				Q_SEGMENTO.P_PONER_DISPONIBLE (V_DISPONIBLE => True,
							       V_SEGMENTO => V_SEGMENTO);

				V_ARRAY_SEGMENTOS (J) := V_SEGMENTO;

			end loop;

			-- Obtener el array con las conexiones para el tramo.
			for J in 1 .. V_TRAMO_ADAPTACION.R_LISTA_CONEXIONES.R_NUMERO_CONEXIONES loop

				Q_CONEXION.P_INICIALIZAR_CONEXION (V_CONEXION);

				V_CONEXION_ADAPTACION := V_TRAMO_ADAPTACION.R_LISTA_CONEXIONES.R_CONEXIONES_ADAPTACION_ARRAY (J);

				Q_CONEXION.P_PONER_TRAMO_ID (V_TRAMO_ID => V_CONEXION_ADAPTACION.R_CONEXION_A_TRAMO,
							     V_CONEXION => V_CONEXION);

				Q_CONEXION.P_PONER_CARRIL_ACTUAL (V_CARRIL_ACTUAL => V_CONEXION_ADAPTACION.R_CARRIL_ACTUAL,
								  V_CONEXION => V_CONEXION);

				Q_CONEXION.P_PONER_CARRIL_SIGUIENTE (V_CARRIL_SIGUIENTE => V_CONEXION_ADAPTACION.R_CARRIL_SIGUIENTE,
								     V_CONEXION => V_CONEXION);

				Q_CONEXION.P_PONER_RESTRICCION_VELOCIDAD 
					(V_RESTRICCION_VELOCIDAD => V_CONEXION_ADAPTACION.R_RESTRICCION_VELOCIDAD,
					 V_CONEXION => V_CONEXION);

				V_ARRAY_CONEXIONES (J) := V_CONEXION;

			end loop;

			-- Con la lista de segmentos ya creada, añadirla al tramo.
			Q_TRAMO.P_PONER_LISTA_SEGMENTOS (V_NUMERO_SEGMENTOS => V_TRAMO_ADAPTACION.R_LISTA_SEGMENTOS.R_NUMERO_SEGMENTOS,
							 V_ARRAY_SEGMENTOS => V_ARRAY_SEGMENTOS,
							 V_TRAMO => V_TRAMO);

			-- Añadir el array con las conexiones al tramo.
			Q_TRAMO.P_PONER_LISTA_CONEXIONES (V_NUMERO_CONEXIONES => V_TRAMO_ADAPTACION.R_LISTA_CONEXIONES.R_NUMERO_CONEXIONES,
							  V_ARRAY_CONEXIONES => V_ARRAY_CONEXIONES,
							  V_TRAMO => V_TRAMO);

			-- Calcular la distncia del tramo. Numero de segmentos * 5 metros de media.
			Q_TRAMO.P_PONER_DISTANCIA_TRAMO (V_DISTANCIA => V_TRAMO_ADAPTACION.R_LISTA_SEGMENTOS.R_NUMERO_SEGMENTOS * 5,
							 V_TRAMO => V_TRAMO);

			-- Calcular el tiempo tramo. Tiempo minimo para recorrer el tramo. 
			-- 3600 * Distancia (m) / 1000 *Velocidad maxima (Km/h)
			Q_TRAMO.P_PONER_TIEMPO_TRAMO 
				(V_TIEMPO_TRAMO => 
					(3600 * Q_TRAMO.F_OBTENER_DISTANCIA_TRAMO (V_TRAMO)) / 
					(1000 * Q_TRAMO.F_OBTENER_VELOCIDAD_MAXIMA (V_TRAMO)),
				 V_TRAMO => V_TRAMO);

			Q_TRAMO.P_PONER_CAPACIDAD_MAXIMA_TRAMO (V_CAPACIDAD_MAXIMA => V_CAPACIDAD_VEHICULOS,
							        V_TRAMO => V_TRAMO);

			-- Calcular la capacidad del tramo.
			-- 1.- Obtener la velocidad maxima del tramo.
			-- 2.- Realizar la operacion modulo 10.
			-- 3.- El numero resultante elevado al cuadrado es la distancia de seguridad.
			-- 4.- Esa distancia + 5 metros (longitud de un vehiculo) es lo que ocupa cada vehiculo a velocidad maxima.
			-- 5.- Numero de segmentos por carriles * 5, dividido por la distancia que ocupa cada vehiculo nos da la capacidad.
			Q_TRAMO.P_PONER_CAPACIDAD_NOMINAL_TRAMO 
				(V_CAPACIDAD_NOMINAL => 
					Integer
						(Float'Rounding
							(Float((V_CAPACIDAD_VEHICULOS * 5)) / 
							 Float(((V_TRAMO_ADAPTACION.R_VELOCIDAD_MAXIMA / 10)**2 +5)))),
				 V_TRAMO => V_TRAMO);

			-- Inicializar variable con el numero maximo de vehiculos.
			V_CAPACIDAD_VEHICULOS := 0;

			-- Por defecto los tramos no tendran carga de trafico.
			Q_TRAMO.P_PONER_CARGA_TRAFICO (V_CARGA_TRAFICO => 0.0,
						       V_TRAMO => V_TRAMO);

			-- Por defecto los tramos estaran disponibles.
			Q_TRAMO.P_PONER_DISPONIBILIDAD (V_DISPONIBILIDAD => True,
							V_TRAMO => V_TRAMO);

			-- Con el tramo ya completo añadir el tramo a la lista de tramos.
			Q_LISTA_TRAMOS.P_INSERTAR_ELEMENTO (V_ELEMENTO => V_TRAMO,
							    V_LISTA => V_LISTA_TRAMOS);			

		end loop;

	end P_GENERAR_LISTA_TRAMOS;
	----------------------------------------------------------------------------------

	-------------------------
	procedure P_VISUALIZAR is

		V_TRAMO_ADAPTACION_REGISTRO : T_TRAMO_ADAPTACION_REGISTRO;

                V_TRAMO_ADAPTACION : T_TRAMO_ADAPTACION;

		V_SEGMENTO_ADAPTACION : T_SEGMENTO_ADAPTACION;

		V_CONEXION_ADAPTACION : T_CONEXION_ADAPTACION;

		V_TRAMO_COMIENZO, V_TRAMO_FINAL, V_SEGMENTO_POSICION : Q_TIPOS_BASICOS.T_POSICION_UTM;

	begin

		P_LEER_ADAPTACION (V_TRAMO_ADAPTACION_REGISTRO);

		for I in 1 .. V_TRAMO_ADAPTACION_REGISTRO.R_NUMERO_TRAMOS loop

			V_TRAMO_ADAPTACION := V_TRAMO_ADAPTACION_REGISTRO.R_TRAMO_ADAPTACION_ARRAY(I);

			Ada.Text_Io.Put_Line (" Id  => " & Integer'Image(V_TRAMO_ADAPTACION.R_ID));

			Ada.Text_Io.Put_Line 
				(Ada.Characters.Latin_1.HT & " Nombre           => " & 
				V_TRAMO_ADAPTACION.R_NOMBRE_TRAMO (1 .. V_TRAMO_ADAPTACION.R_NOMBRE_TRAMO'Length));

			-- Transformar las coordenadas esféricas a UTM para la visualizacion
			V_TRAMO_COMIENZO := Q_TIPOS_BASICOS.F_TRANSFORMAR_LAT_LON_A_UTM (V_TRAMO_ADAPTACION.R_COMIENZO);

			Ada.Text_Io.Put_Line (Ada.Characters.Latin_1.HT & " Comienzo         => ");

			Ada.Text_Io.Put (Ada.Characters.Latin_1.HT & Ada.Characters.Latin_1.HT & Ada.Characters.Latin_1.HT & " X => ");

			Ada.Text_Io.Put_Line (Integer'Image(Q_TIPOS_BASICOS.F_OBTENER_COORDENADA_X(V_TRAMO_COMIENZO)));

                        Ada.Text_Io.Put (Ada.Characters.Latin_1.HT & Ada.Characters.Latin_1.HT & Ada.Characters.Latin_1.HT & " Y => ");             
                        Ada.Text_Io.Put_Line (Integer'Image(Q_TIPOS_BASICOS.F_OBTENER_COORDENADA_Y(V_TRAMO_COMIENZO)));		

			-- Transformar las coordenadas esféricas a UTM para la visualizacion
                        V_TRAMO_FINAL := Q_TIPOS_BASICOS.F_TRANSFORMAR_LAT_LON_A_UTM (V_TRAMO_ADAPTACION.R_FINAL);
			
			Ada.Text_Io.Put_Line (Ada.Characters.Latin_1.HT & " Final            => ");

                        Ada.Text_Io.Put (Ada.Characters.Latin_1.HT & Ada.Characters.Latin_1.HT & Ada.Characters.Latin_1.HT & " X => ");

                        Ada.Text_Io.Put_Line (Integer'Image(Q_TIPOS_BASICOS.F_OBTENER_COORDENADA_X(V_TRAMO_FINAL)));

                        Ada.Text_Io.Put (Ada.Characters.Latin_1.HT & Ada.Characters.Latin_1.HT & Ada.Characters.Latin_1.HT & " Y => ");

                        Ada.Text_Io.Put_Line (Integer'Image(Q_TIPOS_BASICOS.F_OBTENER_COORDENADA_Y(V_TRAMO_FINAL)));

			Ada.Text_Io.Put (Ada.Characters.Latin_1.HT & " Altura           => ");

			Ada.Float_Text_Io.Put (Item => V_TRAMO_ADAPTACION.R_ALTURA,
                                               Fore => 1,
                                               Aft => 2,
                                               Exp => 0);

                        Ada.Text_Io.Put_Line ("");

			Ada.Text_Io.Put (Ada.Characters.Latin_1.HT & " Velocidad Maxima => ");
	
			Ada.Text_Io.Put_Line (Integer'Image(V_TRAMO_ADAPTACION.R_VELOCIDAD_MAXIMA));

			Ada.Text_Io.Put_Line (Ada.Characters.Latin_1.HT & " Lista segmentos  => ");

			-- Recorrer la lista de segmentos.
			for J in 1 .. V_TRAMO_ADAPTACION.R_LISTA_SEGMENTOS.R_NUMERO_SEGMENTOS loop

				Ada.Text_Io.Put_Line (Ada.Characters.Latin_1.HT & Ada.Characters.Latin_1.HT & " Segmento => ");

				Ada.Text_Io.Put_Line (Ada.Characters.Latin_1.HT & Ada.Characters.Latin_1.HT & Ada.Characters.Latin_1.HT &
							" Posicion => ");

				V_SEGMENTO_ADAPTACION := V_TRAMO_ADAPTACION.R_LISTA_SEGMENTOS.R_SEGMENTOS_ADAPTACION_ARRAY (J);

				V_SEGMENTO_POSICION := Q_TIPOS_BASICOS.F_TRANSFORMAR_LAT_LON_A_UTM (V_SEGMENTO_ADAPTACION.R_POSICION);

				Ada.Text_Io.Put (Ada.Characters.Latin_1.HT & Ada.Characters.Latin_1.HT & Ada.Characters.Latin_1.HT &
							Ada.Characters.Latin_1.HT & " X => ");

				Ada.Text_Io.Put_Line (Integer'Image(Q_TIPOS_BASICOS.F_OBTENER_COORDENADA_X(V_SEGMENTO_POSICION))); 

				Ada.Text_Io.Put (Ada.Characters.Latin_1.HT & Ada.Characters.Latin_1.HT & Ada.Characters.Latin_1.HT &
                                                        Ada.Characters.Latin_1.HT & " Y => ");

                                Ada.Text_Io.Put_Line (Integer'Image(Q_TIPOS_BASICOS.F_OBTENER_COORDENADA_Y(V_SEGMENTO_POSICION)));

				Ada.Text_Io.Put (Ada.Characters.Latin_1.HT & Ada.Characters.Latin_1.HT & Ada.Characters.Latin_1.HT & 
							" Doble sentido   => ");

				Ada.Text_Io.Put_Line (Boolean'Image(V_SEGMENTO_ADAPTACION.R_DOBLE_SENTIDO));

				Ada.Text_Io.Put (Ada.Characters.Latin_1.HT & Ada.Characters.Latin_1.HT & Ada.Characters.Latin_1.HT & 
							" Numero carriles => ");

				Ada.Text_Io.Put_Line (Integer'Image(V_SEGMENTO_ADAPTACION.R_NUMERO_CARRILES));

			end loop;

			Ada.Text_Io.Put_Line (Ada.Characters.Latin_1.HT & " Lista conexiones  => ");

			-- Recorrer la lista de conexiones.

			for J in 1 .. V_TRAMO_ADAPTACION.R_LISTA_CONEXIONES.R_NUMERO_CONEXIONES loop
	
				V_CONEXION_ADAPTACION := V_TRAMO_ADAPTACION.R_LISTA_CONEXIONES.R_CONEXIONES_ADAPTACION_ARRAY (J);

				Ada.Text_Io.Put_Line (Ada.Characters.Latin_1.HT & Ada.Characters.Latin_1.HT & " Conexion => ");

				Ada.Text_Io.Put (Ada.Characters.Latin_1.HT & Ada.Characters.Latin_1.HT & Ada.Characters.Latin_1.HT & 
							" Tramo Id              => ");

				Ada.Text_Io.Put_Line (Natural'Image(V_CONEXION_ADAPTACION.R_CONEXION_A_TRAMO));

				Ada.Text_Io.Put (Ada.Characters.Latin_1.HT & Ada.Characters.Latin_1.HT & Ada.Characters.Latin_1.HT &
                                                        " Carril Actual         => ");

				Ada.Text_Io.Put_Line (Natural'Image(V_CONEXION_ADAPTACION.R_CARRIL_ACTUAL));

				Ada.Text_Io.Put (Ada.Characters.Latin_1.HT & Ada.Characters.Latin_1.HT & Ada.Characters.Latin_1.HT &
                                                        " Carril Siguiente      => ");

				Ada.Text_Io.Put_Line (Natural'Image(V_CONEXION_ADAPTACION.R_CARRIL_SIGUIENTE));

				Ada.Text_Io.Put (Ada.Characters.Latin_1.HT & Ada.Characters.Latin_1.HT & Ada.Characters.Latin_1.HT &
                                                        " Restriccion Velocidad => ");

				Ada.Text_Io.Put_Line (Integer'Image(V_CONEXION_ADAPTACION.R_RESTRICCION_VELOCIDAD));		

			end loop;
				
			Ada.Text_Io.Put_Line ("--");

		end loop;

	end P_VISUALIZAR;
	-------------------------

	-----------------------------------------------------------------------------------------------------------------------
	function F_OBTENER_RESTRICCION_VELOCIDAD_ENTRE_TRAMOS (V_TRAMO_ID_1 : in Natural;
							       V_TRAMO_ID_2 : in Natural;
							       V_CARRIL_ACTUAL : in Natural;
							       V_CARRIL_SIGUIENTE : in Natural) return Q_TIPOS_BASICOS.T_VELOCIDAD is

		package Q_TRAMO_IO is new Ada.Sequential_IO(T_TRAMO_ADAPTACION);

                V_FICHERO_TRAMO : Q_TRAMO_IO.File_Type;

		V_TRAMO_ADAPTACION : T_TRAMO_ADAPTACION;

	begin

		Q_TRAMO_IO.Open (File => V_FICHERO_TRAMO,
                                 Mode => Q_TRAMO_IO.In_File,
                                 Name => "/home/hector/ITS/adaptacion/tramos.bin");

		for I in 1 .. V_TRAMO_ID_1 loop

			Q_TRAMO_IO.Read (File => V_FICHERO_TRAMO,
                                         Item => V_TRAMO_ADAPTACION);

		end loop;

		Q_TRAMO_IO.Close (V_FICHERO_TRAMO);

		-- Ya tenemos el tramo origen.
		-- Recorrer las conexiones para obtener la restriccion entre los tramos dados.
		for I in 1 .. V_TRAMO_ADAPTACION.R_LISTA_CONEXIONES.R_NUMERO_CONEXIONES loop

			if V_TRAMO_ID_2 = V_TRAMO_ADAPTACION.R_LISTA_CONEXIONES.R_CONEXIONES_ADAPTACION_ARRAY(I).R_CONEXION_A_TRAMO and
			   V_CARRIL_ACTUAL = V_TRAMO_ADAPTACION.R_LISTA_CONEXIONES.R_CONEXIONES_ADAPTACION_ARRAY(I).R_CARRIL_ACTUAL and
			   V_CARRIL_SIGUIENTE = V_TRAMO_ADAPTACION.R_LISTA_CONEXIONES.R_CONEXIONES_ADAPTACION_ARRAY(I).R_CARRIL_SIGUIENTE
			then

				return V_TRAMO_ADAPTACION.R_LISTA_CONEXIONES.R_CONEXIONES_ADAPTACION_ARRAY(I).R_RESTRICCION_VELOCIDAD;

			end if;

		end loop;

		-- Elevar excepcion.
		raise X_TRAMO_DESTINO_NO_ENCONTRADO;

	end F_OBTENER_RESTRICCION_VELOCIDAD_ENTRE_TRAMOS;
	-----------------------------------------------------------------------------------------------------------------------

	--------------------------------------------------------------------------------------------------------------
	procedure P_OBTENER_CARRILES_ENTRE_TRAMOS (V_TRAMO_ID_1 : in Natural;
						   V_TRAMO_ID_2 : in Natural;
						   V_LISTA_CARRILES_TRAMO_ACTUAL : out Q_LISTA_CARRILES.T_LISTA;
						   V_LISTA_CARRILES_TRAMO_SIGUIENTE : out Q_LISTA_CARRILES.T_LISTA) is

		package Q_TRAMO_IO is new Ada.Sequential_IO (T_TRAMO_ADAPTACION);

                V_FICHERO_TRAMO : Q_TRAMO_IO.File_Type;

                V_TRAMO_ADAPTACION : T_TRAMO_ADAPTACION;

		V_CARRIL_AUX, V_CARRIL_SIGUIENTE_AUX : Natural := 0;

	begin

		Q_LISTA_CARRILES.P_INICIALIZAR_LISTA (V_LISTA_CARRILES_TRAMO_ACTUAL);

		Q_LISTA_CARRILES.P_INICIALIZAR_LISTA (V_LISTA_CARRILES_TRAMO_SIGUIENTE);

		Q_TRAMO_IO.Open (File => V_FICHERO_TRAMO,
                                 Mode => Q_TRAMO_IO.In_File,
                                 Name => "/home/hector/ITS/adaptacion/tramos.bin");

		for I in 1 .. V_TRAMO_ID_1 loop

                        Q_TRAMO_IO.Read (File => V_FICHERO_TRAMO,
                                         Item => V_TRAMO_ADAPTACION);

                end loop;

		Q_TRAMO_IO.Close (V_FICHERO_TRAMO);

		-- Recorrer las conexiones del tramo de adaptacion, buscando aquellas con tramo destino = V_TRAMO_ID_2
		for I in 1 .. V_TRAMO_ADAPTACION.R_LISTA_CONEXIONES.R_NUMERO_CONEXIONES loop

			if V_TRAMO_ADAPTACION.R_LISTA_CONEXIONES.R_CONEXIONES_ADAPTACION_ARRAY(I).R_CONEXION_A_TRAMO = V_TRAMO_ID_2 then

				V_CARRIL_AUX := V_TRAMO_ADAPTACION.R_LISTA_CONEXIONES.R_CONEXIONES_ADAPTACION_ARRAY(I).R_CARRIL_ACTUAL;

				V_CARRIL_SIGUIENTE_AUX := 
					V_TRAMO_ADAPTACION.R_LISTA_CONEXIONES.R_CONEXIONES_ADAPTACION_ARRAY(I).R_CARRIL_SIGUIENTE;
				
				-- Ya tenemos un carril del tramo actual. Comprobar que ese carril no esta ya en la lista.
				if not Q_LISTA_CARRILES.F_ESTA_ELEMENTO_EN_LISTA (V_ELEMENTO => V_CARRIL_AUX,
										  V_LISTA => V_LISTA_CARRILES_TRAMO_ACTUAL) then 
		
					Q_LISTA_CARRILES.P_INSERTAR_ELEMENTO (V_ELEMENTO => V_CARRIL_AUX,
					 	 			      V_LISTA => V_LISTA_CARRILES_TRAMO_ACTUAL);

				end if;

				-- Ya tenemos un carril del siguiente tramo. Comprobar que ese carril no estar ya en la lista.
				if not Q_LISTA_CARRILES.F_ESTA_ELEMENTO_EN_LISTA (V_ELEMENTO => V_CARRIL_SIGUIENTE_AUX,
										  V_LISTA => V_LISTA_CARRILES_TRAMO_SIGUIENTE) then

					Q_LISTA_CARRILES.P_INSERTAR_ELEMENTO (V_ELEMENTO => V_CARRIL_SIGUIENTE_AUX,
									      V_LISTA => V_LISTA_CARRILES_TRAMO_SIGUIENTE);

				end if;

			end if;

		end loop;

	end P_OBTENER_CARRILES_ENTRE_TRAMOS;
	--------------------------------------------------------------------------------------------------------------

	--------------------------------------------------------------------------------------
	function F_OBTENER_CARRIL_CONEXION (V_TRAMO_ORIGEN_ID : in Natural;
					    V_TRAMO_DESTINO_ID : in Natural;
					    V_CARRIL_SIGUIENTE : in Natural) return Natural is

		package Q_TRAMO_IO is new Ada.Sequential_IO (T_TRAMO_ADAPTACION);

                V_FICHERO_TRAMO : Q_TRAMO_IO.File_Type;

                V_TRAMO_ADAPTACION : T_TRAMO_ADAPTACION;

	begin

		Q_TRAMO_IO.Open (File => V_FICHERO_TRAMO,
                                 Mode => Q_TRAMO_IO.In_File,
                                 Name => "/home/hector/ITS/adaptacion/tramos.bin");

                for I in 1 .. V_TRAMO_ORIGEN_ID loop

                        Q_TRAMO_IO.Read (File => V_FICHERO_TRAMO,
                                         Item => V_TRAMO_ADAPTACION);

                end loop;

                Q_TRAMO_IO.Close (V_FICHERO_TRAMO);

		for I in 1 .. V_TRAMO_ADAPTACION.R_LISTA_CONEXIONES.R_NUMERO_CONEXIONES loop

			-- Buscar en el array de conexiones la conexion entre tramo origen y destino que tenga como carril siguiente el
			-- dado a la funcion.
			if V_TRAMO_ADAPTACION.R_LISTA_CONEXIONES.R_CONEXIONES_ADAPTACION_ARRAY(I).R_CONEXION_A_TRAMO = V_TRAMO_DESTINO_ID 
			and V_TRAMO_ADAPTACION.R_LISTA_CONEXIONES.R_CONEXIONES_ADAPTACION_ARRAY(I).R_CARRIL_SIGUIENTE = V_CARRIL_SIGUIENTE 
			then

				return V_TRAMO_ADAPTACION.R_LISTA_CONEXIONES.R_CONEXIONES_ADAPTACION_ARRAY(I).R_CARRIL_ACTUAL;

			end if;

		end loop;

		raise X_CONEXION_NO_ENCONTRADA;

	end F_OBTENER_CARRIL_CONEXION;
	--------------------------------------------------------------------------------------

	---------------------------------------------------------------------------------------
        function F_OBTENER_SIGUIENTE_CARRIL (V_TRAMO_ORIGEN_ID : in Natural;
                                             V_TRAMO_SIGUIENTE_ID : in Natural;
                                             V_CARRIL_ANTERIOR : in Natural) return Natural is

                package Q_TRAMO_IO is new Ada.Sequential_IO (T_TRAMO_ADAPTACION);

                V_FICHERO_TRAMO : Q_TRAMO_IO.File_Type;

                V_TRAMO_ADAPTACION : T_TRAMO_ADAPTACION;

        begin

                Q_TRAMO_IO.Open (File => V_FICHERO_TRAMO,
                                 Mode => Q_TRAMO_IO.In_File,
                                 Name => "/home/hector/ITS/adaptacion/tramos.bin");

                for I in 1 .. V_TRAMO_ORIGEN_ID loop

                        Q_TRAMO_IO.Read (File => V_FICHERO_TRAMO,
                                         Item => V_TRAMO_ADAPTACION);

                end loop;

                Q_TRAMO_IO.Close (V_FICHERO_TRAMO);

                for I in 1 .. V_TRAMO_ADAPTACION.R_LISTA_CONEXIONES.R_NUMERO_CONEXIONES loop

                        -- Buscar en el array de conexiones la conexion entre tramo origen y destino que tenga como carril siguiente el
                        -- dado a la funcion.
                        if V_TRAMO_ADAPTACION.R_LISTA_CONEXIONES.R_CONEXIONES_ADAPTACION_ARRAY(I).R_CONEXION_A_TRAMO = V_TRAMO_SIGUIENTE_ID
                        and V_TRAMO_ADAPTACION.R_LISTA_CONEXIONES.R_CONEXIONES_ADAPTACION_ARRAY(I).R_CARRIL_ACTUAL = V_CARRIL_ANTERIOR
                        then

                                return V_TRAMO_ADAPTACION.R_LISTA_CONEXIONES.R_CONEXIONES_ADAPTACION_ARRAY(I).R_CARRIL_SIGUIENTE;

			end if;

                end loop;

                raise X_CONEXION_NO_ENCONTRADA;

        end F_OBTENER_SIGUIENTE_CARRIL;
        ---------------------------------------------------------------------------------------

	----------------------------------------------------------------------------------------------------------
	function F_OBTENER_SIGUIENTE_CARRIL_ALTERNATIVO (V_TRAMO_ORIGEN_ID : in Natural;
							 V_TRAMO_SIGUIENTE_ID : in Natural;
							 V_CARRIL_ACTUAL : in Natural;
							 V_CARRIL_SIGUIENTE_OPTIMO : in Natural) return Natural is

		package Q_TRAMO_IO is new Ada.Sequential_IO (T_TRAMO_ADAPTACION);

                V_FICHERO_TRAMO : Q_TRAMO_IO.File_Type;

                V_TRAMO_ADAPTACION : T_TRAMO_ADAPTACION;

		V_DISTANCIA, V_DISTANCIA_MINIMA : Natural := 1000;

		V_CARRIL_CONEXION_ALTERNATIVO : Natural := 1;

	begin

		Q_TRAMO_IO.Open (File => V_FICHERO_TRAMO,
                                 Mode => Q_TRAMO_IO.In_File,
                                 Name => "/home/hector/ITS/adaptacion/tramos.bin");

                for I in 1 .. V_TRAMO_ORIGEN_ID loop

                        Q_TRAMO_IO.Read (File => V_FICHERO_TRAMO,
                                         Item => V_TRAMO_ADAPTACION);

                end loop;

                Q_TRAMO_IO.Close (V_FICHERO_TRAMO);

		for I in 1 .. V_TRAMO_ADAPTACION.R_LISTA_CONEXIONES.R_NUMERO_CONEXIONES loop

			if V_TRAMO_ADAPTACION.R_LISTA_CONEXIONES.R_CONEXIONES_ADAPTACION_ARRAY(I).R_CONEXION_A_TRAMO = V_TRAMO_SIGUIENTE_ID
			and V_TRAMO_ADAPTACION.R_LISTA_CONEXIONES.R_CONEXIONES_ADAPTACION_ARRAY(I).R_CARRIL_ACTUAL = V_CARRIL_ACTUAL then

				-- Tenemos una conexion candidata.
				V_DISTANCIA := 
					abs 
					(V_TRAMO_ADAPTACION.R_LISTA_CONEXIONES.R_CONEXIONES_ADAPTACION_ARRAY(I).R_CARRIL_SIGUIENTE - 
					 V_CARRIL_SIGUIENTE_OPTIMO);

				if V_DISTANCIA < V_DISTANCIA_MINIMA then

					V_DISTANCIA_MINIMA := V_DISTANCIA;
					
					V_CARRIL_CONEXION_ALTERNATIVO := 
						V_TRAMO_ADAPTACION.R_LISTA_CONEXIONES.R_CONEXIONES_ADAPTACION_ARRAY(I).R_CARRIL_SIGUIENTE;

				end if;

				-- Por definicion la distancia minima sera 1. Y ademas salvo algún caso no contemplado la solucion sera 
				-- unica.
				exit when V_DISTANCIA_MINIMA = 1;

			end if;

		end loop;

		return V_CARRIL_CONEXION_ALTERNATIVO;

	end F_OBTENER_SIGUIENTE_CARRIL_ALTERNATIVO;
	----------------------------------------------------------------------------------------------------------

	------------------------------------------------------------------------------
	function F_EXISTE_CONEXION (V_TRAMO_ORIGEN_ID : in Natural;
				    V_TRAMO_SIGUIENTE_ID : in Natural;
				    V_CARRIL_ORIGEN : in Natural;
				    V_CARRIL_SIGUIENTE : in Natural) return Boolean is

		package Q_TRAMO_IO is new Ada.Sequential_IO (T_TRAMO_ADAPTACION);

                V_FICHERO_TRAMO : Q_TRAMO_IO.File_Type;

                V_TRAMO_ADAPTACION : T_TRAMO_ADAPTACION;

		V_EXISTE_CONEXION : Boolean := False;

	begin

		Q_TRAMO_IO.Open (File => V_FICHERO_TRAMO,
                                 Mode => Q_TRAMO_IO.In_File,
                                 Name => "/home/hector/ITS/adaptacion/tramos.bin");

                for I in 1 .. V_TRAMO_ORIGEN_ID loop

                        Q_TRAMO_IO.Read (File => V_FICHERO_TRAMO,
                                         Item => V_TRAMO_ADAPTACION);

                end loop;

                Q_TRAMO_IO.Close (V_FICHERO_TRAMO);

                for I in 1 .. V_TRAMO_ADAPTACION.R_LISTA_CONEXIONES.R_NUMERO_CONEXIONES loop

			if V_TRAMO_ADAPTACION.R_LISTA_CONEXIONES.R_CONEXIONES_ADAPTACION_ARRAY(I).R_CONEXION_A_TRAMO = V_TRAMO_SIGUIENTE_ID
			and V_TRAMO_ADAPTACION.R_LISTA_CONEXIONES.R_CONEXIONES_ADAPTACION_ARRAY(I).R_CARRIL_ACTUAL = V_CARRIL_ORIGEN 
			and V_TRAMO_ADAPTACION.R_LISTA_CONEXIONES.R_CONEXIONES_ADAPTACION_ARRAY(I).R_CARRIL_SIGUIENTE = V_CARRIL_SIGUIENTE
			then

				V_EXISTE_CONEXION := True;

				exit;

			end if;

		end loop;

		return V_EXISTE_CONEXION;

	end F_EXISTE_CONEXION;
	------------------------------------------------------------------------------

end Q_ADAPTACION_TRAMO;
-------------------------------------------------------------------------------------------------------------------------------------------
