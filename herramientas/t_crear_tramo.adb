--------------------------------------------------------------------------------------------------------------------------------------------
--
--      Fichero:        t_crear_tramo.adb
--
--      Autor:          Hector Uhalte Bilbao
--
--      Fecha:          13/2/2019
--      
--------------------------------------------------------------------------------------------------------------------------------------------

with Ada.Text_Io;
with Ada.Integer_Text_Io;
with Ada.Characters.Latin_1;
with Q_TIPOS_BASICOS;
with Ada.Float_Text_Io;
with Ada.Numerics.Generic_Elementary_Functions;

procedure t_crear_tramo is
	
	V_ID, V_AUX_X, V_AUX_Y, V_ALTURA, V_VELOCIDAD_MAXIMA, V_DELTA_X, V_DELTA_Y, J : Integer := 0;

	V_NOMBRE_TRAMO : String (1..32);
	V_ES_DOBLE_SENTIDO : String (1..5);
	V_LONGITUD_NOMBRE, V_LONGITUD_DOBLE_SENTIDO_NOMBRE : Natural := 0;

	V_LATITUD_ORIGEN, V_LATITUD_FIN : Q_TIPOS_BASICOS.T_LATITUD := 0.0000000;
	V_LONGITUD_ORIGEN, V_LONGITUD_FIN : Q_TIPOS_BASICOS.T_LONGITUD := 0.0000000;

	V_POSICION_ORIGEN_LAT_LON, V_POSICION_FIN_LAT_LON : Q_TIPOS_BASICOS.T_POSICION_LAT_LON;
	V_POSICION_ORIGEN_UTM, V_POSICION_FIN_UTM : Q_TIPOS_BASICOS.T_POSICION_UTM;

	V_POSICION_ORIGEN_X, V_POSICION_FIN_X, V_POSICION_ORIGEN_Y, V_POSICION_FIN_Y, V_NUMERO_CARRILES : Integer := 0;

	package Q_MATH is new ADA.NUMERICS.GENERIC_ELEMENTARY_FUNCTIONS (Float_Type => Float);

	V_FICHERO_LATITUDES, V_FICHERO_LONGITUDES : Ada.Text_Io.File_Type;

	V_LINEA_LATITUD, V_LINEA_LONGITUD, V_INCREMENTO_X, V_INCREMENTO_Y : Float;

	type T_ARRAY_POSICIONES_LAT_LON is array (1 .. 512) of Q_TIPOS_BASICOS.T_POSICION_LAT_LON;

	type T_ARRAY_POSICIONES_UTM is array (1 .. 512) of Q_TIPOS_BASICOS.T_POSICION_UTM;

	V_ARRAY_POSICIONES_LAT_LON, V_ARRAY_POSICIONES_LAT_LON_AUX : T_ARRAY_POSICIONES_LAT_LON;

	V_ARRAY_POSICIONES_UTM, V_ARRAY_POSICIONES_UTM_AUX : T_ARRAY_POSICIONES_UTM;

	V_INDICE_POSICION, V_POSICION_PUNTO_MAS_CERCANO : Natural := 0;

	V_DISTANCIA_AUXILIAR, V_DISTANCIA_A_DESTINO : Integer := 1_000;

	V_DISTANCIA : Integer := 0;

	V_ANGULO : Float := 0.0;

begin

	Ada.Text_Io.Put ("Id del tramo :- ");
	Ada.Integer_Text_Io.Get (V_ID); Ada.Text_Io.Skip_Line;

	Ada.Text_Io.Put ("Nombre del tramo :- ");
	Ada.Text_Io.Get_Line (Item => V_NOMBRE_TRAMO,
			      Last => V_LONGITUD_NOMBRE);

	Ada.Text_Io.Put ("Latitud del punto de origen del tramo :- ");
	Ada.Float_Text_Io.Get (V_LATITUD_ORIGEN); Ada.Text_Io.Skip_Line;

	Ada.Text_Io.Put ("Longitud del punto de origen del tramo :- ");
        Ada.Float_Text_Io.Get (V_LONGITUD_ORIGEN); Ada.Text_Io.Skip_Line;

	Ada.Text_Io.Put ("Latitud del punto de fin del tramo :- ");
        Ada.Float_Text_Io.Get (V_LATITUD_FIN); Ada.Text_Io.Skip_Line;

        Ada.Text_Io.Put ("Longitud del punto de fin del tramo :- ");
        Ada.Float_Text_Io.Get (V_LONGITUD_FIN); Ada.Text_Io.Skip_Line;

	Ada.Text_Io.Put ("Altura del tramo (m):- ");
	Ada.Integer_Text_Io.Get (V_ALTURA); Ada.Text_Io.Skip_Line;

	Ada.Text_Io.Put ("Velocidad maxima del tramo (Km/h):- ");
	Ada.Integer_Text_Io.Get (V_VELOCIDAD_MAXIMA); Ada.Text_Io.Skip_Line;

	Ada.Text_Io.Put ("Doble sentido en el tramo? (true o false):- ");
	Ada.Text_Io.Get_Line (Item => V_ES_DOBLE_SENTIDO,
			      Last => V_LONGITUD_DOBLE_SENTIDO_NOMBRE);

	Ada.Text_Io.Put ("Numero de carriles en el tramo:- ");
	Ada.Integer_Text_Io.Get (V_NUMERO_CARRILES); Ada.Text_Io.Skip_Line;

	-- Vamos a ver si mejora el algoritmo usando no uno de entre ocho angulos, sino el angulo entre el punto origen y final del tramo

	V_POSICION_ORIGEN_X := 
		Q_TIPOS_BASICOS.F_OBTENER_COORDENADA_X 
			(Q_TIPOS_BASICOS.F_TRANSFORMAR_LAT_LON_A_UTM 
				(Q_TIPOS_BASICOS.F_OBTENER_POSICION_LAT_LON (V_LATITUD => V_LATITUD_ORIGEN,
									     V_LONGITUD => V_LONGITUD_ORIGEN)));

	V_POSICION_ORIGEN_Y :=
                Q_TIPOS_BASICOS.F_OBTENER_COORDENADA_Y
                        (Q_TIPOS_BASICOS.F_TRANSFORMAR_LAT_LON_A_UTM 
                                (Q_TIPOS_BASICOS.F_OBTENER_POSICION_LAT_LON (V_LATITUD => V_LATITUD_ORIGEN,
                                                                             V_LONGITUD => V_LONGITUD_ORIGEN)));

	V_POSICION_FIN_X :=
                Q_TIPOS_BASICOS.F_OBTENER_COORDENADA_X
                        (Q_TIPOS_BASICOS.F_TRANSFORMAR_LAT_LON_A_UTM
                                (Q_TIPOS_BASICOS.F_OBTENER_POSICION_LAT_LON (V_LATITUD => V_LATITUD_FIN,
                                                                             V_LONGITUD => V_LONGITUD_FIN)));

        V_POSICION_FIN_Y :=
                Q_TIPOS_BASICOS.F_OBTENER_COORDENADA_Y
                        (Q_TIPOS_BASICOS.F_TRANSFORMAR_LAT_LON_A_UTM
                                (Q_TIPOS_BASICOS.F_OBTENER_POSICION_LAT_LON (V_LATITUD => V_LATITUD_FIN,
                                                                             V_LONGITUD => V_LONGITUD_FIN)));

	V_DELTA_X := V_POSICION_FIN_X - V_POSICION_ORIGEN_X;

	V_DELTA_Y := V_POSICION_FIN_Y - V_POSICION_ORIGEN_Y;

	begin

	V_ANGULO := Q_MATH.Arctan (Float(V_DELTA_Y)/Float(V_DELTA_X));

	-- Cuadrante I    : Correcto
        -- Cuadrante II   Delta X negativo y Delta Y positivo : No Correcto (Hay que sumarle pi)
        -- Cuadrante III  Delta X negativo y Delta Y negativo : No Correcto (Hay que sumarle pi)
        -- Cuadrante IIII : Correcto

	if V_DELTA_X < 0 then

		if V_DELTA_Y > 0 then
		
			-- Cuadrante II
			V_ANGULO := V_ANGULO + Ada.Numerics.Pi;

		elsif V_DELTA_Y < 0 then
	
			-- Cuadrante III
			V_ANGULO := V_ANGULO - Ada.Numerics.Pi;

		end if;

	end if;

	exception

		when Constraint_Error =>
		
			-- El angulo es pi/2 o -pi/2 dependiendo de si Delta_Y es positivo o negativo.

			if V_DELTA_Y > 0 then

				V_ANGULO := Ada.Numerics.Pi / 2.0;

			elsif V_DELTA_Y < 0 then

				V_ANGULO := -Ada.Numerics.Pi / 2.0;

			elsif V_DELTA_X = 0 then

				-- Nunca deberiamos entrar aqui
				Ada.Text_Io.Put_Line ("V_DELTA_X = V_DELTA_Y = 0");

			end if;

	end;

	Ada.Text_Io.Put_Line ("Delta X : " & Integer'Image(V_DELTA_X));
	Ada.Text_Io.Put_Line ("Delta Y : " & Integer'Image(V_DELTA_Y));

	-- Abrir ficheros de puntos para leer.
	Ada.Text_Io.Open (File => V_FICHERO_LATITUDES,
			  Mode => Ada.Text_Io.In_File,
			  Name => "latitudes");

	Ada.Text_Io.Open (File => V_FICHERO_LONGITUDES,
                          Mode => Ada.Text_Io.In_File,
                          Name => "longitudes");

	Ada.Text_Io.Put_Line ("El fallo no esta en los ficheros de latitudes y longitudes");

	while not Ada.Text_Io.End_Of_File (V_FICHERO_LATITUDES) loop

		Ada.Float_Text_Io.Get (V_FICHERO_LATITUDES,V_LINEA_LATITUD);

		Ada.Float_Text_Io.Get (V_FICHERO_LONGITUDES,V_LINEA_LONGITUD);
		
		V_INDICE_POSICION := V_INDICE_POSICION + 1;

		-- Guardar las coordenadas de los puntos en un array de posiciones lat lon y en otro las posiciones UTM
		V_ARRAY_POSICIONES_LAT_LON (V_INDICE_POSICION) := 
			Q_TIPOS_BASICOS.F_OBTENER_POSICION_LAT_LON (V_LATITUD => V_LINEA_LATITUD,
								    V_LONGITUD => V_LINEA_LONGITUD);

		V_ARRAY_POSICIONES_UTM (V_INDICE_POSICION) := 
			Q_TIPOS_BASICOS.F_TRANSFORMAR_LAT_LON_A_UTM (V_ARRAY_POSICIONES_LAT_LON (V_INDICE_POSICION));
	
	end loop;

	Ada.Text_Io.Close (V_FICHERO_LATITUDES);
        Ada.Text_Io.Close (V_FICHERO_LONGITUDES);

	V_INCREMENTO_X := 5.0 * Q_MATH.Cos (V_ANGULO);
	V_INCREMENTO_Y := 5.0 * Q_MATH.Sin (V_ANGULO);

	V_AUX_X := 
		Q_TIPOS_BASICOS.F_OBTENER_COORDENADA_X 
			(Q_TIPOS_BASICOS.F_TRANSFORMAR_LAT_LON_A_UTM 
				(Q_TIPOS_BASICOS.F_OBTENER_POSICION_LAT_LON (V_LATITUD => V_LATITUD_ORIGEN,
									     V_LONGITUD => V_LONGITUD_ORIGEN))) + Integer(V_INCREMENTO_X);

	V_AUX_Y :=
		Q_TIPOS_BASICOS.F_OBTENER_COORDENADA_Y
                        (Q_TIPOS_BASICOS.F_TRANSFORMAR_LAT_LON_A_UTM 
                                (Q_TIPOS_BASICOS.F_OBTENER_POSICION_LAT_LON (V_LATITUD => V_LATITUD_ORIGEN,
                                                                             V_LONGITUD => V_LONGITUD_ORIGEN))) + Integer(V_INCREMENTO_Y);

	-- Sacar por pantalla
        Ada.Text_Io.Put_Line (Ada.Characters.Latin_1.HT & "<its:datosTramo>");
        Ada.Text_Io.Put (Ada.Characters.Latin_1.HT & Ada.Characters.Latin_1.HT & "<its:id>");
        Ada.Integer_Text_Io.Put (Item => V_ID,
                                 Width => 0);
        Ada.Text_Io.Put_Line ("</its:id>");
        Ada.Text_Io.Put_Line (Ada.Characters.Latin_1.HT & Ada.Characters.Latin_1.HT & "<its:nombreTramo>" &
                              V_NOMBRE_TRAMO(1..V_LONGITUD_NOMBRE) & "</its:nombreTramo>");
        Ada.Text_Io.Put (Ada.Characters.Latin_1.HT & Ada.Characters.Latin_1.HT & "<its:comienzoLatitud>");
        Ada.Float_Text_Io.Put (Item => V_LATITUD_ORIGEN,
                               Aft => 7,
                               Exp => 0);
        Ada.Text_Io.Put_Line ("</its:comienzoLatitud>");
        Ada.Text_Io.Put (Ada.Characters.Latin_1.HT & Ada.Characters.Latin_1.HT & "<its:comienzoLongitud>");
        Ada.Float_Text_Io.Put (Item => V_LONGITUD_ORIGEN,
                               Aft => 7,
                               Exp => 0);
        Ada.Text_Io.Put_Line ("</its:comienzoLongitud>");
        Ada.Text_Io.Put (Ada.Characters.Latin_1.HT & Ada.Characters.Latin_1.HT & "<its:finalLatitud>");
        Ada.Float_Text_Io.Put (Item => V_LATITUD_FIN,
                               Aft => 7,
                               Exp => 0);
        Ada.Text_Io.Put_Line ("</its:finalLatitud>");
        Ada.Text_Io.Put (Ada.Characters.Latin_1.HT & Ada.Characters.Latin_1.HT & "<its:finalLongitud>");
        Ada.Float_Text_Io.Put (Item => V_LONGITUD_FIN,
                               Aft => 7,
                               Exp => 0);
        Ada.Text_Io.Put_Line ("</its:finalLongitud>");
	Ada.Text_Io.Put (Ada.Characters.Latin_1.HT & Ada.Characters.Latin_1.HT & "<its:altura>");
	Ada.Integer_Text_Io.Put (Item => V_ALTURA,
				 Width => 0);
	Ada.Text_Io.Put_Line ("</its:altura>");
	Ada.Text_Io.Put (Ada.Characters.Latin_1.HT & Ada.Characters.Latin_1.HT & "<its:velocidadMaxima>");
        Ada.Integer_Text_Io.Put (Item => V_VELOCIDAD_MAXIMA,
                                 Width => 0);
        Ada.Text_Io.Put_Line ("</its:velocidadMaxima>");
	Ada.Text_Io.Put_Line (Ada.Characters.Latin_1.HT & Ada.Characters.Latin_1.HT & "<its:listaSegmentos>");

	while V_DISTANCIA_A_DESTINO > 5 loop

		V_DISTANCIA_AUXILIAR := 1_000;

		-- Buscar que punto de entre el array de puntos esta mas cerca del punto auxiliar.
		for I in 1 .. V_INDICE_POSICION loop

			-- Calcular la distancia entre el punto auxiliar y el punto (I) del array de puntos.
			V_DISTANCIA := Q_TIPOS_BASICOS.F_OBTENER_DISTANCIA 
				(V_POSICION_1 => Q_TIPOS_BASICOS.F_OBTENER_POSICION_UTM (V_X => V_AUX_X,
											 V_Y => V_AUX_Y),								     V_POSICION_2 => V_ARRAY_POSICIONES_UTM (I));

			delay 0.038; 
		
			if V_DISTANCIA < V_DISTANCIA_AUXILIAR then

				V_DISTANCIA_AUXILIAR := V_DISTANCIA;
			
				V_POSICION_PUNTO_MAS_CERCANO := I;

			end if;

		end loop;

		-- Aqui ya tengo el punto mas cercano al punto auxiliar

		V_DELTA_X := V_POSICION_FIN_X - 
			     Q_TIPOS_BASICOS.F_OBTENER_COORDENADA_X (V_ARRAY_POSICIONES_UTM (V_POSICION_PUNTO_MAS_CERCANO));

        	V_DELTA_Y := V_POSICION_FIN_Y - 
			     Q_TIPOS_BASICOS.F_OBTENER_COORDENADA_Y (V_ARRAY_POSICIONES_UTM (V_POSICION_PUNTO_MAS_CERCANO));

		-- Aqui las deltas de X y de Y se han recalculado con respecto al ultimo punto seleccionado.
	
		begin

        	V_ANGULO := Q_MATH.Arctan (Float(V_DELTA_Y)/Float(V_DELTA_X));
		
		if V_DELTA_X < 0 then

                	if V_DELTA_Y > 0 then

                        	-- Cuadrante II
                        	V_ANGULO := V_ANGULO + Ada.Numerics.Pi;

                	elsif V_DELTA_Y < 0 then

                        	-- Cuadrante III
                        	V_ANGULO := V_ANGULO - Ada.Numerics.Pi;

                	end if;

        	end if;

		exception

                when Constraint_Error =>

                        -- El angulo es pi/2 o -pi/2 dependiendo de si Delta_Y es positivo o negativo.

                        if V_DELTA_Y > 0 then

                                V_ANGULO := Ada.Numerics.Pi / 2.0;

                        elsif V_DELTA_Y < 0 then

                                V_ANGULO := -Ada.Numerics.Pi / 2.0;

                        elsif V_DELTA_X = 0 then

                                -- Nunca deberiamos entrar aqui
                                Ada.Text_Io.Put_Line ("V_DELTA_X = V_DELTA_Y = 0");

                        end if;

		when Ada.Numerics.Argument_Error =>

			-- En principio será cuando V_DELTA_X = V_DELTA_Y = 0 => EL proximo punto es el punto final, con lo cual habremos
			-- llegado al final del tramo.
			exit;

        	end;

		-- Aqui ya tengo seguro el punto mas cercano al punto auxiliar
                -- Hay que:

                -- 1.- Sacar el punto por pantalla (XML)

		Ada.Text_Io.Put_Line (Ada.Characters.Latin_1.HT & Ada.Characters.Latin_1.HT & Ada.Characters.Latin_1.HT & "<its:segmento>");
                Ada.Text_Io.Put (Ada.Characters.Latin_1.HT & Ada.Characters.Latin_1.HT & Ada.Characters.Latin_1.HT &
                                 Ada.Characters.Latin_1.HT & "<its:posicionSegmentoLatitud>");
                Ada.Float_Text_Io.Put (Item =>
                                        Q_TIPOS_BASICOS.F_OBTENER_LATITUD (V_ARRAY_POSICIONES_LAT_LON (V_POSICION_PUNTO_MAS_CERCANO)),
                                       Aft => 7,
                                       Exp => 0);
                Ada.Text_Io.Put_Line ("</its:posicionSegmentoLatitud>");
                Ada.Text_Io.Put (Ada.Characters.Latin_1.HT & Ada.Characters.Latin_1.HT & Ada.Characters.Latin_1.HT &
                                 Ada.Characters.Latin_1.HT & "<its:posicionSegmentoLongitud>");
                Ada.Float_Text_Io.Put (Item =>
                                        Q_TIPOS_BASICOS.F_OBTENER_LONGITUD (V_ARRAY_POSICIONES_LAT_LON (V_POSICION_PUNTO_MAS_CERCANO)),
                                       Aft => 7,
                                       Exp => 0);
                Ada.Text_Io.Put_Line ("</its:posicionSegmentoLongitud>");
                Ada.Text_Io.Put_Line (Ada.Characters.Latin_1.HT & Ada.Characters.Latin_1.HT & Ada.Characters.Latin_1.HT &
                                      Ada.Characters.Latin_1.HT & "<its:dobleSentido>" & 
				      V_ES_DOBLE_SENTIDO(1..V_LONGITUD_DOBLE_SENTIDO_NOMBRE) & "</its:dobleSentido>");
		Ada.Text_Io.Put (Ada.Characters.Latin_1.HT & Ada.Characters.Latin_1.HT & Ada.Characters.Latin_1.HT &
                                 Ada.Characters.Latin_1.HT & "<its:numeroCarriles>");
		Ada.Integer_Text_Io.Put (Item => V_NUMERO_CARRILES,
                                         Width => 0);
		Ada.Text_Io.Put_Line ("</its:numeroCarriles>");
                Ada.Text_Io.Put_Line (Ada.Characters.Latin_1.HT & Ada.Characters.Latin_1.HT & Ada.Characters.Latin_1.HT &
                                      "</its:segmento>");

		-- 2.- Calcular el nuevo punto auxiliar a partir de este punto.
                -- Recalcular el angulo. 
                --      El punto origen sera ahora el punto seleccionado
                --      El punto final sera el mismo

		V_INCREMENTO_X := 5.0 * Q_MATH.Cos (V_ANGULO);
        	V_INCREMENTO_Y := 5.0 * Q_MATH.Sin (V_ANGULO);

		V_AUX_X := 
			Q_TIPOS_BASICOS.F_OBTENER_COORDENADA_X (V_ARRAY_POSICIONES_UTM (V_POSICION_PUNTO_MAS_CERCANO)) + 
			Integer (V_INCREMENTO_X);

		V_AUX_Y := 
			Q_TIPOS_BASICOS.F_OBTENER_COORDENADA_Y (V_ARRAY_POSICIONES_UTM (V_POSICION_PUNTO_MAS_CERCANO)) + 
                        Integer (V_INCREMENTO_Y);

		-- Calcular la distancia de ese punto al destino.
		V_DISTANCIA_A_DESTINO := Q_TIPOS_BASICOS.F_OBTENER_DISTANCIA 
			(V_POSICION_1 => V_ARRAY_POSICIONES_UTM (V_POSICION_PUNTO_MAS_CERCANO),
			 V_POSICION_2 => Q_TIPOS_BASICOS.F_TRANSFORMAR_LAT_LON_A_UTM 
						(Q_TIPOS_BASICOS.F_OBTENER_POSICION_LAT_LON (V_LATITUD => V_LATITUD_FIN,
											     V_LONGITUD => V_LONGITUD_FIN)));

		-- CODIGO PARA CONVERGER
		-- Eliminar del array de posiciones el punto escogido (por si la distancia entre puntos evita que el algoritmo converja).
                -- Para simplificar la herramienta hay que usar listas. Instanciar el generico con posiciones utm y lat lon.

                J := 1;

                for I in 1 .. V_INDICE_POSICION loop

                        if I /= V_POSICION_PUNTO_MAS_CERCANO then

                                V_ARRAY_POSICIONES_LAT_LON_AUX (J) := V_ARRAY_POSICIONES_LAT_LON (I);
                                V_ARRAY_POSICIONES_UTM_AUX (J) := V_ARRAY_POSICIONES_UTM (I);

                                J := J + 1;

                        end if;

                end loop;

                V_INDICE_POSICION := J - 1;

                for I in 1 .. V_INDICE_POSICION loop

                        V_ARRAY_POSICIONES_LAT_LON (I) := V_ARRAY_POSICIONES_LAT_LON_AUX (I);
                        V_ARRAY_POSICIONES_UTM (I) := V_ARRAY_POSICIONES_UTM_AUX (I);

                end loop;

                -- FIN DEL CODIGO PARA CONVERGER

		delay 0.075;
	
	end loop;

	Ada.Text_Io.Put_Line (Ada.Characters.Latin_1.HT & Ada.Characters.Latin_1.HT & "</its:listaSegmentos>");
	Ada.Text_Io.Put_Line (Ada.Characters.Latin_1.HT & "</its:datosTramo>");

end t_crear_tramo;
