--------------------------------------------------------------------------------------------------------------------------------------------
--
--      Fichero:        THESEUS.adb
--
--      Autor:          Hector Uhalte Bilbao
--
--      Fecha:          18/1/2018
--      
--------------------------------------------------------------------------------------------------------------------------------------------

with Q_VEHICULO.Q_ACCIONES;
with Q_TRAMO.Q_ACCIONES;
with Q_ADAPTACION_TRAMO;
with Q_TIPOS_BASICOS;
with Ada.Text_Io;
with Ada.Characters.Latin_1;
with Q_AREA_TRABAJO;
with Q_SEGMENTO;
with Q_RUTA.Q_DIJKSTRA;
with ADA.CALENDAR;

-- Ejecutable para realizar la función del cliente (vehículo).
-- 
-- 1º- Establecer el vehículo (de entre los vehículos incluidos en la adaptación)
--
-- 2º- Establecer el punto de origen del trayecto.

procedure theseus is

	V_VEHICULO : Q_VEHICULO.T_VEHICULO;

	V_TRAMO_ORIGEN, V_TRAMO_ORIGEN_BIS, V_TRAMO_DESTINO : Q_TRAMO.T_TRAMO;

	V_SEGMENTO, V_SEGMENTO_ORIGEN, V_SEGMENTO_DESTINO : Q_SEGMENTO.T_SEGMENTO;

	V_LISTA_TRAMOS : Q_ADAPTACION_TRAMO.Q_LISTA_TRAMOS.T_LISTA;

	V_LISTA_SEGMENTOS_TRAMO_ORIGEN : Q_TRAMO.Q_LISTA_SEGMENTOS.T_LISTA;

	V_LISTA_CONEXIONES_CIRCULAR : Q_TRAMO.Q_LISTA_CONEXIONES.T_LISTA;

	V_POSICION_INICIAL, V_POSICION_DESTINO, V_POSICION_ALEATORIA, V_POSICION_SEGMENTO_MAS_CERCANO : Q_TIPOS_BASICOS.T_POSICION_UTM;

	V_POSICION_LISTA_SEGMENTO_ORIGEN, V_POSICION_LISTA_SEGMENTO_DESTINO : Natural;

	V_DISTANCIA_MINIMA : Integer := 1_000_000;

	V_RUTA, V_RUTA_CIRCULAR_PROVISIONAL : Q_RUTA.T_RUTA;

	V_COSTE_RUTA : Integer := 0;

	V_COSTE_PROVISIONAL_RUTA_CIRCULAR : Integer := 1_000_000;

	V_COSTE_TIEMPO, V_COSTE_DISTANCIA, V_COSTE_TIEMPO_DESTINO, V_COSTE_DISTANCIA_DESTINO : Integer := 0;

	--V_RELACION_TRAMO_ORIGEN : Q_RUTA.Q_DIJKSTRA.T_RELACION_TRAMOS;

	V_COSTE_TRAMOS : Q_RUTA.Q_DIJKSTRA.Q_LISTA_COSTE_TRAMOS.T_LISTA;

	V_RELACION_TRAMOS : Q_RUTA.Q_DIJKSTRA.Q_LISTA_RELACION_TRAMOS.T_LISTA;

	V_TRAMOS_A_VISITAR, V_TRAMOS_A_EVITAR : Q_RUTA.Q_DIJKSTRA.Q_LISTA_TRAMOS_ID.T_LISTA;

	V_COMIENZO, V_FINAL : Integer := 0;

	V_HAY_RUTA : Boolean := False;

	package Boolean_Io is new Ada.Text_Io.Enumeration_Io (Boolean);

begin
	
	-- Generar un vehículo.	
	Q_VEHICULO.Q_ACCIONES.P_GENERAR_VEHICULO (V_VEHICULO);

	Ada.Text_Io.Put_Line ("");
	Ada.Text_Io.Put (" VEHICULO : ");
	Q_VEHICULO.Q_ACCIONES.P_MOSTRAR_VEHICULO (V_VEHICULO);
	Ada.Text_Io.Put_Line ("");

	-- Obtener el registro de tramos (numero de tramos + array de tramos) de la adaptacion.
	Q_ADAPTACION_TRAMO.P_GENERAR_LISTA_TRAMOS (V_LISTA_TRAMOS);

	-- Obtener una posiciona aleatoria dentro del area de trabajo.
        V_POSICION_ALEATORIA := Q_AREA_TRABAJO.F_OBTENER_COORDENADAS_ALEATORIAS;

	-- Obtener el segmento mas cercano a esa posicion de salida dada.
        Q_TRAMO.Q_ACCIONES.P_OBTENER_TRAMO_MAS_CERCANO_A_POSICION (V_POSICION => V_POSICION_ALEATORIA,
                                                                   V_POSICION_SEGMENTO => V_POSICION_INICIAL,
                                                                   V_DISTANCIA_A_SEGMENTO => V_DISTANCIA_MINIMA,
                                                                   V_TRAMO => V_TRAMO_ORIGEN);

	-- Mostrar la posicion del segmento mas cercano.
	Ada.Text_Io.Put_Line (" SALIDA : ");
	Ada.Text_Io.Put_Line ("");
	Ada.Text_Io.Put_Line (Ada.Characters.Latin_1.HT & Q_TRAMO.F_OBTENER_NOMBRE (V_TRAMO_ORIGEN));
	Ada.Text_Io.Put_Line ("");
	Ada.Text_Io.Put_Line (Ada.Characters.Latin_1.HT & "X : " &
                Integer'Image(Q_TIPOS_BASICOS.F_OBTENER_COORDENADA_X (V_POSICION_INICIAL)));
        Ada.Text_Io.Put_Line (Ada.Characters.Latin_1.HT & "Y : " &
                Integer'Image(Q_TIPOS_BASICOS.F_OBTENER_COORDENADA_Y (V_POSICION_INICIAL)));
	Ada.Text_Io.Put_Line ("");

	-- Obtener una posiciona aleatoria dentro del area de trabajo.
        V_POSICION_ALEATORIA := Q_AREA_TRABAJO.F_OBTENER_COORDENADAS_ALEATORIAS;

	-- Obtener el segmento mas cercano a esa posicion de destino dada.
        Q_TRAMO.Q_ACCIONES.P_OBTENER_TRAMO_MAS_CERCANO_A_POSICION (V_POSICION => V_POSICION_ALEATORIA,
                                                                   V_POSICION_SEGMENTO => V_POSICION_DESTINO,
                                                                   V_DISTANCIA_A_SEGMENTO => V_DISTANCIA_MINIMA,
                                                                   V_TRAMO => V_TRAMO_DESTINO);

        -- Mostrar la posicion del segmento mas cercano.
        Ada.Text_Io.Put_Line (" DESTINO : ");
        Ada.Text_Io.Put_Line ("");
        Ada.Text_Io.Put_Line (Ada.Characters.Latin_1.HT & Q_TRAMO.F_OBTENER_NOMBRE (V_TRAMO_DESTINO));
        Ada.Text_Io.Put_Line ("");
        Ada.Text_Io.Put_Line (Ada.Characters.Latin_1.HT & "X : " &
                Integer'Image(Q_TIPOS_BASICOS.F_OBTENER_COORDENADA_X (V_POSICION_DESTINO)));
        Ada.Text_Io.Put_Line (Ada.Characters.Latin_1.HT & "Y : " &
                Integer'Image(Q_TIPOS_BASICOS.F_OBTENER_COORDENADA_Y (V_POSICION_DESTINO)));
        Ada.Text_Io.Put_Line ("");

	Ada.Text_Io.Put_Line 
		(" DISTANCIA SALIDA-DESTINO (linea recta) : " & 
			Integer'Image(Q_TIPOS_BASICOS.F_OBTENER_DISTANCIA (V_POSICION_1 => V_POSICION_INICIAL,
									   V_POSICION_2 => V_POSICION_DESTINO)) & " metros"); 

	Ada.Text_Io.Put_Line ("");

	-- Calculo de la ruta. Inicializar listas auxiliares.
	V_COMIENZO := (Integer(ADA.CALENDAR.Seconds(ADA.CALENDAR.CLOCK)));
	Q_RUTA.Q_DIJKSTRA.Q_LISTA_COSTE_TRAMOS.P_INICIALIZAR_LISTA (V_COSTE_TRAMOS);

	Q_RUTA.Q_DIJKSTRA.Q_LISTA_TRAMOS_ID.P_INICIALIZAR_LISTA (V_TRAMOS_A_VISITAR);

	Q_RUTA.Q_DIJKSTRA.Q_LISTA_TRAMOS_ID.P_INICIALIZAR_LISTA (V_TRAMOS_A_EVITAR);

	Q_RUTA.Q_DIJKSTRA.Q_LISTA_RELACION_TRAMOS.P_INICIALIZAR_LISTA (V_RELACION_TRAMOS);

	-- Inicializar la ruta.
	Q_RUTA.Q_LISTA_TRAMOS.P_INICIALIZAR_LISTA (V_RUTA);
	
	-- Comprobar si el tramo origen es el mismo que el tramo destino.
	if Q_TRAMO."=" (V_TRAMO_1 => V_TRAMO_ORIGEN,
			V_TRAMO_2 => V_TRAMO_DESTINO) then

		-- Si tramo origen y tramo distancia son el mismo, pero:
                -- El tramo (segmento origen realmente) no es de doble sentido y
                -- El segmento de salida es anterior al de llegada (hay que tener en cuenta que la lista de segmentos en los tramos esta 
                -- invertida, el primer segmento en la lista es realmente el ultimo del tramo)
                -- Entonces hay que ir a Dijkstra => Tenemos una ruta en "circulo". Se asume que no se puede circular marcha atras.
		Q_SEGMENTO.P_PONER_POSICION (V_POSICION => V_POSICION_INICIAL,
                                             V_SEGMENTO => V_SEGMENTO_ORIGEN);

                V_POSICION_LISTA_SEGMENTO_ORIGEN :=
                        Q_TRAMO.Q_LISTA_SEGMENTOS.F_POSICION_ELEMENTO (V_ELEMENTO => V_SEGMENTO_ORIGEN,
                                                                       V_LISTA => Q_TRAMO.F_OBTENER_LISTA_SEGMENTOS (V_TRAMO_ORIGEN));

                Q_SEGMENTO.P_PONER_POSICION (V_POSICION => V_POSICION_DESTINO,
                                             V_SEGMENTO => V_SEGMENTO_DESTINO);

                V_POSICION_LISTA_SEGMENTO_DESTINO :=
                        Q_TRAMO.Q_LISTA_SEGMENTOS.F_POSICION_ELEMENTO (V_ELEMENTO => V_SEGMENTO_DESTINO,
                                                                       V_LISTA => Q_TRAMO.F_OBTENER_LISTA_SEGMENTOS (V_TRAMO_DESTINO));

		if V_POSICION_LISTA_SEGMENTO_ORIGEN >= V_POSICION_LISTA_SEGMENTO_DESTINO then

			-- No hay ruta "circular". Añadir el tramo a la ruta.
                	Q_RUTA.Q_LISTA_TRAMOS.P_INSERTAR_ELEMENTO (V_ELEMENTO => V_TRAMO_ORIGEN,
                                                           	   V_LISTA => V_RUTA);

			-- Calcular los costes de la ruta.
			V_COSTE_DISTANCIA := 5 * abs (V_POSICION_LISTA_SEGMENTO_DESTINO - V_POSICION_LISTA_SEGMENTO_ORIGEN);

                	V_COSTE_TIEMPO := Integer(Float'Rounding
						 ((Float(V_COSTE_DISTANCIA) / Float(Q_TRAMO.F_OBTENER_DISTANCIA_TRAMO (V_TRAMO_ORIGEN))) *
                        		  	   Float(Q_TRAMO.F_OBTENER_TIEMPO_TRAMO (V_TRAMO_ORIGEN))));

		else

			-- No realizo un "or else" porque si se cumple la condicion de que:
			-- Posicion segmento origen >= Posicion segmento destino => No tengo que encontrar el segmento y comprobar si es
			-- de doble sentido o no.

			-- Comprobar si el segmento es de doble sentido.
			-- Obtener la lista de segmentos del tramo.
			Q_TRAMO.Q_LISTA_SEGMENTOS.P_INICIALIZAR_LISTA (V_LISTA_SEGMENTOS_TRAMO_ORIGEN);

			V_LISTA_SEGMENTOS_TRAMO_ORIGEN := Q_TRAMO.F_OBTENER_LISTA_SEGMENTOS (V_TRAMO_ORIGEN);

			-- Recorrer la lista de segmentos hasta obtener el segmento de la posicion de salida.
			for I in 1 .. Q_TRAMO.Q_LISTA_SEGMENTOS.F_CUANTOS_ELEMENTOS (V_LISTA_SEGMENTOS_TRAMO_ORIGEN) loop

				V_SEGMENTO := Q_TRAMO.Q_LISTA_SEGMENTOS.F_DEVOLVER_ELEMENTO (V_POSICION => I,
											     V_LISTA => V_LISTA_SEGMENTOS_TRAMO_ORIGEN);

				if Q_SEGMENTO."=" (V_SEGMENTO_1 => V_SEGMENTO_ORIGEN,
						   V_SEGMENTO_2 => V_SEGMENTO) then

					-- Segmento origen encontrado. Comprobar si es de doble sentido.
					-- Si lo es entonces se calcula la ruta "lineal".
					-- Si no lo es => Hay que llamar a Dijkstra.

					if Q_SEGMENTO.F_OBTENER_DOBLE_SENTIDO 
						(Q_TRAMO.Q_LISTA_SEGMENTOS.F_DEVOLVER_ELEMENTO 
							(V_POSICION => I,
							 V_LISTA => Q_TRAMO.F_OBTENER_LISTA_SEGMENTOS 
									(Q_ADAPTACION_TRAMO.Q_LISTA_TRAMOS.F_ENCONTRAR_ELEMENTO 
										(V_ELEMENTO => V_TRAMO_ORIGEN,
										 V_LISTA => V_LISTA_TRAMOS)))) then

						-- No hay ruta "circular". Añadir el tramo a la ruta.
                        			Q_RUTA.Q_LISTA_TRAMOS.P_INSERTAR_ELEMENTO (V_ELEMENTO => V_TRAMO_ORIGEN,
                                                                   			   V_LISTA => V_RUTA);

                        			-- Calcular los costes de la ruta.
                        			V_COSTE_DISTANCIA := 
							5 * abs (V_POSICION_LISTA_SEGMENTO_DESTINO - V_POSICION_LISTA_SEGMENTO_ORIGEN);

						V_COSTE_TIEMPO := Integer(Float'Rounding
                                                 ((Float(V_COSTE_DISTANCIA) / Float(Q_TRAMO.F_OBTENER_DISTANCIA_TRAMO (V_TRAMO_ORIGEN))) *
                                                   Float(Q_TRAMO.F_OBTENER_TIEMPO_TRAMO (V_TRAMO_ORIGEN))));

						-- No tengo que buscar mas segmentos
						exit;

					else

						-- Llamar a Dijkstra. Forzar a visitar el tramo de origen.
						-- TO DO : HAY QUE TRATAR ESTO DE LA RUTA CIRCULAR DENTRO DE DIJKSTRA MEJOR.
						Ada.Text_Io.Put_Line (Ada.Characters.Latin_1.HT & "RUTA CIRCULAR");

						Ada.Text_Io.Put_Line ("");

						-- Inicializar la ruta circular provisional.
						Q_RUTA.Q_LISTA_TRAMOS.P_INICIALIZAR_LISTA (V_RUTA_CIRCULAR_PROVISIONAL);

						-- RUTA CIRCULAR CAMBIO

						-- Añadir el coste del primer tramo a la ruta.
                				-- De momento desde theseus se hara siempre por el tiempo.
                				Q_SEGMENTO.P_PONER_POSICION (V_POSICION => V_POSICION_INICIAL,
                                             				     V_SEGMENTO => V_SEGMENTO_ORIGEN);

                				V_POSICION_LISTA_SEGMENTO_ORIGEN :=
                        				Q_TRAMO.Q_LISTA_SEGMENTOS.
								F_POSICION_ELEMENTO 
									(V_ELEMENTO => V_SEGMENTO_ORIGEN,
                                                                         V_LISTA => Q_TRAMO.F_OBTENER_LISTA_SEGMENTOS (V_TRAMO_ORIGEN));

                				V_COSTE_DISTANCIA := V_POSICION_LISTA_SEGMENTO_ORIGEN * 5;

                				V_COSTE_TIEMPO := 
							Integer(Float'Rounding
                                                		((Float(V_COSTE_DISTANCIA) / 
								  Float(Q_TRAMO.F_OBTENER_DISTANCIA_TRAMO (V_TRAMO_ORIGEN))) *
                                                  		Float(Q_TRAMO.F_OBTENER_TIEMPO_TRAMO (V_TRAMO_ORIGEN))));

						-- Inicializar la lista de conexiones del tramo
						Q_TRAMO.Q_LISTA_CONEXIONES.P_INICIALIZAR_LISTA (V_LISTA_CONEXIONES_CIRCULAR);

						-- Obtener las conexiones del tramo origen.
						V_LISTA_CONEXIONES_CIRCULAR := Q_TRAMO.F_OBTENER_LISTA_CONEXIONES (V_TRAMO_ORIGEN);

						for I in 1 .. Q_TRAMO.Q_LISTA_CONEXIONES.F_CUANTOS_ELEMENTOS (V_LISTA_CONEXIONES_CIRCULAR) 
						loop
							
							-- Inicializar tramo. Usando la variable V_TRAMO_ORIGEN_BIS no modificamos el
							-- tramo origen real.
							Q_TRAMO.P_INICIALIZAR_TRAMO (V_TRAMO_ORIGEN_BIS);
							
							-- Poner como tramo origen el de la conexion I.
							Q_TRAMO.P_PONER_ID (V_ID => Q_TRAMO.Q_LISTA_CONEXIONES.F_DEVOLVER_ELEMENTO
                                                                                        (V_POSICION => I,
                                                                                         V_LISTA => V_LISTA_CONEXIONES_CIRCULAR),
									    V_TRAMO => V_TRAMO_ORIGEN_BIS);


							-- Establecer como tramo origen el de la conexion
							Q_RUTA.Q_DIJKSTRA.Q_LISTA_TRAMOS_ID.P_INSERTAR_ELEMENTO 
								(V_ELEMENTO => 
									Q_TRAMO.Q_LISTA_CONEXIONES.F_DEVOLVER_ELEMENTO 
										(V_POSICION => I,
				   				 		 V_LISTA => V_LISTA_CONEXIONES_CIRCULAR),
								 V_LISTA => V_TRAMOS_A_VISITAR);

							-- Insertar con coste 0 este tramo en la lista de costes
							Q_RUTA.Q_DIJKSTRA.Q_LISTA_COSTE_TRAMOS.P_INSERTAR_ELEMENTO 
								(V_ELEMENTO => (R_TRAMO_ID => Q_TRAMO.Q_LISTA_CONEXIONES.F_DEVOLVER_ELEMENTO
												(V_POSICION => I,
										 		 V_LISTA => V_LISTA_CONEXIONES_CIRCULAR),
									       R_COSTE_TRAMO => 0),
                                             			 V_LISTA => V_COSTE_TRAMOS);

							-- Insertar la relacion de tramos
							Q_RUTA.Q_DIJKSTRA.Q_LISTA_RELACION_TRAMOS.
                        					P_INSERTAR_ELEMENTO (V_ELEMENTO => (R_TRAMO_ANTERIOR_ID => 
											Q_TRAMO.Q_LISTA_CONEXIONES.F_DEVOLVER_ELEMENTO
												(V_POSICION => I,
												 V_LISTA => V_LISTA_CONEXIONES_CIRCULAR),
												    R_TRAMO_ID =>
											Q_TRAMO.Q_LISTA_CONEXIONES.F_DEVOLVER_ELEMENTO
                                                                                                (V_POSICION => I,
                                                                                                 V_LISTA => V_LISTA_CONEXIONES_CIRCULAR)),
                                                                                     V_LISTA => V_RELACION_TRAMOS);

							begin


							-- Llamar a Dijkstra.
                					Q_RUTA.Q_DIJKSTRA.P_CALCULAR_RUTA (V_TRAMO_ORIGEN => V_TRAMO_ORIGEN_BIS,
                                                   					   V_TRAMO_DESTINO => V_TRAMO_DESTINO,
                                                   					   V_PESO => Q_RUTA.E_TIEMPO,
                                                   					   V_TRAMOS_A_VISITAR => V_TRAMOS_A_VISITAR,
                                                   					   V_TRAMOS_A_EVITAR => V_TRAMOS_A_EVITAR,
                                                   					   V_COSTE_TRAMOS => V_COSTE_TRAMOS,
                                                   					   V_RELACION_TRAMOS => V_RELACION_TRAMOS,
                                                   					   V_RUTA => V_RUTA,
                                                   					   V_COSTE_RUTA => V_COSTE_RUTA);

							-- El problema es que el tramo origen que mete P_CALCULAR_RUTA no es el tramo origen
							-- real, sera una de las conexiones al tramo origen.
							-- De algun modo hay que insertar el tramo origen en la ruta.

							-- Si no ha saltado la excepcion de no hay ruta es que hay una ruta posible.
							if V_COSTE_RUTA < V_COSTE_PROVISIONAL_RUTA_CIRCULAR then

								V_COSTE_PROVISIONAL_RUTA_CIRCULAR := V_COSTE_RUTA;

								V_RUTA_CIRCULAR_PROVISIONAL := V_RUTA;

							end if;
								

							-- Poner esto de abajo (hasta la excepcion) fuera del loop.

							-- Calcular el coste real (no el total que se calcula para el ultimo tramo de la 
							-- ruta en dijkstra) del ultimo tramo
                					-- Para ello se resta el coste del tramo destino del coste de la ruta.

							exception

								when Q_RUTA.Q_DIJKSTRA.X_RUTA_NO_ENCONTRADA =>

								null;

							end; 

						end loop;	

						-- Aqui si existe, ya tenemos la ruta circular mas corta. Si existe su coste debera ser
						-- menor que 1_000_000
						if V_COSTE_PROVISIONAL_RUTA_CIRCULAR < 1_000_000 then
						
							-- Hay una ruta circular					
							V_RUTA := V_RUTA_CIRCULAR_PROVISIONAL;
							
							V_HAY_RUTA := true;

							-- Añadir el tramo de origen a la ruta.
							Q_RUTA.Q_LISTA_TRAMOS.P_INSERTAR_ELEMENTO (V_ELEMENTO => V_TRAMO_ORIGEN,
												   V_LISTA => V_RUTA);
								
							-- Calcular el coste real (no el total que se calcula para el ultimo tramo de la 
							-- ruta en dijkstra) del ultimo tramo. Para ello se resta el coste del tramo destino
							--  del coste de la ruta.
                                                	Q_SEGMENTO.P_PONER_POSICION (V_POSICION => V_POSICION_DESTINO,
                                                                             	     V_SEGMENTO => V_SEGMENTO_DESTINO);

                                                	V_POSICION_LISTA_SEGMENTO_DESTINO :=
								Q_TRAMO.Q_LISTA_SEGMENTOS.F_POSICION_ELEMENTO
                                                                        (V_ELEMENTO => V_SEGMENTO_DESTINO,
                                                                         V_LISTA => Q_TRAMO.F_OBTENER_LISTA_SEGMENTOS (V_TRAMO_DESTINO));

                                                	V_COSTE_DISTANCIA_DESTINO := V_POSICION_LISTA_SEGMENTO_DESTINO * 5;


                                                	V_COSTE_TIEMPO_DESTINO :=
                						Integer(Float'Rounding
                                                        		((Float(V_COSTE_DISTANCIA) /
                                                                 		Float(Q_TRAMO.F_OBTENER_DISTANCIA_TRAMO (V_TRAMO_ORIGEN))) *
                                                                        	Float(Q_TRAMO.F_OBTENER_TIEMPO_TRAMO (V_TRAMO_ORIGEN))));

						else

							-- No se ha podido encontrar una ruta circular;
							Ada.Text_Io.Put_Line (Ada.Characters.Latin_1.HT & "NO SE PUEDE ENCONTRAR UNA RUTA");

							Ada.Text_Io.Put_Line ("");			

							V_HAY_RUTA := false;

						end if;

						-- FIN RUTA CIRCULAR CAMBIO
											
					end if;

				end if;	

			end loop;

		end if;
		
	else

		-- Tramo origen distinto del tramo destino => No hay ruta circular.

		-- Añadir el coste del primer tramo a la ruta.
		-- De momento desde theseus se hara siempre por el tiempo.
		Q_SEGMENTO.P_PONER_POSICION (V_POSICION => V_POSICION_INICIAL,
                                             V_SEGMENTO => V_SEGMENTO_ORIGEN);

		V_POSICION_LISTA_SEGMENTO_ORIGEN :=
                        Q_TRAMO.Q_LISTA_SEGMENTOS.F_POSICION_ELEMENTO (V_ELEMENTO => V_SEGMENTO_ORIGEN,
                                                                       V_LISTA => Q_TRAMO.F_OBTENER_LISTA_SEGMENTOS (V_TRAMO_ORIGEN));

		V_COSTE_DISTANCIA := V_POSICION_LISTA_SEGMENTO_ORIGEN * 5;

		V_COSTE_TIEMPO := Integer(Float'Rounding
                                 		((Float(V_COSTE_DISTANCIA) / Float(Q_TRAMO.F_OBTENER_DISTANCIA_TRAMO (V_TRAMO_ORIGEN))) *
                                                  Float(Q_TRAMO.F_OBTENER_TIEMPO_TRAMO (V_TRAMO_ORIGEN))));

		-- Añadir el tramo de origen a lista de tramos a visitar.
		Q_RUTA.Q_DIJKSTRA.Q_LISTA_TRAMOS_ID.P_INSERTAR_ELEMENTO (V_ELEMENTO => Q_TRAMO.F_OBTENER_ID (V_TRAMO_ORIGEN),
                                                                         V_LISTA => V_TRAMOS_A_VISITAR);

		-- Insertar el tramo de origen con un coste 0 en la lista de coste de tramos.
                Q_RUTA.Q_DIJKSTRA.Q_LISTA_COSTE_TRAMOS.
			P_INSERTAR_ELEMENTO (V_ELEMENTO => (R_TRAMO_ID => Q_TRAMO.F_OBTENER_ID (V_TRAMO_ORIGEN),
                                                            R_COSTE_TRAMO => 0),
                                             V_LISTA => V_COSTE_TRAMOS);

		Q_RUTA.Q_DIJKSTRA.Q_LISTA_RELACION_TRAMOS.
			P_INSERTAR_ELEMENTO (V_ELEMENTO => (R_TRAMO_ANTERIOR_ID => Q_TRAMO.F_OBTENER_ID (V_TRAMO_ORIGEN),
							    R_TRAMO_ID => Q_TRAMO.F_OBTENER_ID (V_TRAMO_ORIGEN)),
					     V_LISTA => V_RELACION_TRAMOS);

		begin

		-- Llamar a Dijkstra.
		Q_RUTA.Q_DIJKSTRA.P_CALCULAR_RUTA (V_TRAMO_ORIGEN => V_TRAMO_ORIGEN,
                                                   V_TRAMO_DESTINO => V_TRAMO_DESTINO,
                                                   V_PESO => Q_RUTA.E_TIEMPO,
                                                   V_TRAMOS_A_VISITAR => V_TRAMOS_A_VISITAR,
                                                   V_TRAMOS_A_EVITAR => V_TRAMOS_A_EVITAR,
                                                   V_COSTE_TRAMOS => V_COSTE_TRAMOS,
                                                   V_RELACION_TRAMOS => V_RELACION_TRAMOS,
                                                   V_RUTA => V_RUTA,
                                                   V_COSTE_RUTA => V_COSTE_RUTA);

		V_HAY_RUTA := true;

		-- Calcular el coste real (no el total que se calcula para el ultimo tramo de la ruta en dijkstra) del ultimo tramo
		-- Para ello se resta el coste del tramo destino del coste de la ruta.
		Q_SEGMENTO.P_PONER_POSICION (V_POSICION => V_POSICION_DESTINO,
                                             V_SEGMENTO => V_SEGMENTO_DESTINO);

		V_POSICION_LISTA_SEGMENTO_DESTINO :=
                        Q_TRAMO.Q_LISTA_SEGMENTOS.F_POSICION_ELEMENTO (V_ELEMENTO => V_SEGMENTO_DESTINO,
                                                                       V_LISTA => Q_TRAMO.F_OBTENER_LISTA_SEGMENTOS (V_TRAMO_DESTINO));

		V_COSTE_DISTANCIA_DESTINO := V_POSICION_LISTA_SEGMENTO_DESTINO * 5;

                V_COSTE_TIEMPO_DESTINO := Integer(Float'Rounding
                                                  ((Float(V_COSTE_DISTANCIA) / Float(Q_TRAMO.F_OBTENER_DISTANCIA_TRAMO (V_TRAMO_ORIGEN))) *
                                                    Float(Q_TRAMO.F_OBTENER_TIEMPO_TRAMO (V_TRAMO_ORIGEN))));

		exception

			when Q_RUTA.Q_DIJKSTRA.X_RUTA_NO_ENCONTRADA =>

                                -- NO ha sido posible hallar una ruta.
                                Ada.Text_Io.Put_Line (Ada.Characters.Latin_1.HT & "NO SE PUEDE ENCONTRAR UNA RUTA");

				Ada.Text_Io.Put_Line ("");

				V_HAY_RUTA := false;

		end;
		
	end if;

	if V_HAY_RUTA then

		V_FINAL := (Integer(ADA.CALENDAR.Seconds(ADA.CALENDAR.CLOCK)));

		ADA.TEXT_IO.PUT_LINE 
			(Ada.Characters.Latin_1.HT & "Se ha tardado : " & Integer'Image(V_FINAL - V_COMIENZO) & 
			" segundos en encontrar la ruta");

		-- Visualizar la ruta:
		Ada.Text_Io.Put_Line (" RUTA : ");

		Q_TRAMO.Q_ACCIONES.P_VISUALIZAR_CABECERA_TRAMO;

		for I in 1 .. Q_RUTA.Q_LISTA_TRAMOS.F_CUANTOS_ELEMENTOS (V_RUTA) loop

			Q_TRAMO.Q_ACCIONES.P_VISUALIZAR_TRAMO 
				(V_LISTA_TRAMOS => V_LISTA_TRAMOS,
			 	 V_ID => Q_TRAMO.F_OBTENER_ID (Q_RUTA.Q_LISTA_TRAMOS.F_DEVOLVER_ELEMENTO (V_POSICION => I,
												          V_LISTA => V_RUTA)));
		end loop;

		-- Visualizar coste de la ruta en tiempo y distancia.

		Ada.Text_Io.Put_Line ("");

		Ada.Text_Io.Put_Line (Ada.Characters.Latin_1.HT & "TIEMPO (s) : " & 
			Integer'Image(V_COSTE_RUTA + V_COSTE_TIEMPO - V_COSTE_TIEMPO_DESTINO));

		--Ada.Text_Io.Put_Line (Ada.Characters.Latin_1.HT & "DISTANCIA (m) : " & 
		--			Integer'Image(V_COSTE_RUTA + V_COSTE_DISTANCIA - V_COSTE_DISTANCIA_DESTINO));

		Ada.Text_Io.Put_Line ("");

	end if;

end theseus;
--------------------------------------------------------------------------------------------------------------------------------------------
