--------------------------------------------------------------------------------------------------------------------------------------------
--
--      Fichero:        q_progresion.adb
--
--      Autor:          Hector Uhalte Bilbao
--
--      Fecha:          10/7/2019
--      
--------------------------------------------------------------------------------------------------------------------------------------------

with Ada.Text_Io;
with Ada.Characters.Latin_1;
--
with Ada.Sequential_Io;
with Q_ADAPTACION_TRAMO;

package body Q_PROGRESION is

	-----------------------------------------------------------------------------------
	function "=" (V_ELEMENTO_PROGRESION_1 : in T_ELEMENTO_PROGRESION;
		      V_ELEMENTO_PROGRESION_2 : in T_ELEMENTO_PROGRESION) return Boolean is

	begin

		return Q_TIPOS_BASICOS."=" (V_POSICION_1 => V_ELEMENTO_PROGRESION_1.R_POSICION,
					    V_POSICION_2 => V_ELEMENTO_PROGRESION_2.R_POSICION); 

	end "=";
	--------

	--------------------------------------------------------------------------------------------
        procedure P_PONER_ELEMENTO_PROGRESION (V_POSICION : in Q_TIPOS_BASICOS.T_POSICION_UTM;
                                               V_RESTRICCION : in Q_RESTRICCION.T_RESTRICCION;
                                               V_ELEMENTO_PROGRESION : out T_ELEMENTO_PROGRESION) is

        begin

                V_ELEMENTO_PROGRESION.R_POSICION := V_POSICION;
                V_ELEMENTO_PROGRESION.R_RESTRICCION := V_RESTRICCION;

        end P_PONER_ELEMENTO_PROGRESION;
        --------------------------------

	--------------------------------------------------------------------------------------
	-- Procedimiento para obtener una progresion inicial y una progresion optima de 
	-- carriles.
	-- Recorrer la ruta y por cada segmento y conexion, incluir un punto en la progresion.
	--------------------------------------------------------------------------------------
	procedure P_GENERAR_ENVELOPE_ESTATICO (V_POSICION_INICIAL : in Q_TIPOS_BASICOS.T_POSICION_UTM;
					       V_POSICION_FINAL : in Q_TIPOS_BASICOS.T_POSICION_UTM;
					       V_RUTA : in Q_RUTA.T_RUTA;
					       V_PROGRESION : out T_PROGRESION;
					       V_PROGRESION_CARRILES_OPTIMO : out T_PROGRESION_CARRILES_OPTIMO;
					       V_LISTA_TRAMOS_GLORIETA : out T_LISTA_TRAMOS_GLORIETA) is

		V_POSICION_AUX : Q_TIPOS_BASICOS.T_POSICION_UTM := V_POSICION_INICIAL;

		V_POSICION_TRAMO_ACTUAL : Natural := 1;

		V_TRAMO_ACTUAL : Q_TRAMO.T_TRAMO;

		V_SEGMENTO_INICIAL, V_SEGMENTO_FINAL : Q_SEGMENTO.T_SEGMENTO;

		V_POSICION_SEGMENTO, V_POSICION_SEGMENTO_FINAL : Natural := 0;

		V_ELEMENTO_PROGRESION : T_ELEMENTO_PROGRESION;

		V_RESTRICCION : Q_RESTRICCION.T_RESTRICCION;

		--
		V_TRAMO_SIGUIENTE_ID : Natural := 0;

	begin

		-- Inicializar progresion de tramo y de carriles.
		P_INICIALIZAR_LISTA (V_PROGRESION);

		P_INICIALIZAR_LISTA (V_PROGRESION_CARRILES_OPTIMO);

		P_GENERAR_PROGRESION_CARRILES_OPTIMO (V_RUTA => V_RUTA,
					      	      V_PROGRESION_CARRILES_OPTIMO => V_PROGRESION_CARRILES_OPTIMO,
						      V_LISTA_TRAMOS_GLORIETA => V_LISTA_TRAMOS_GLORIETA);

		Q_SEGMENTO.P_PONER_POSICION (V_POSICION => V_POSICION_INICIAL,
					     V_SEGMENTO => V_SEGMENTO_INICIAL);

		Q_SEGMENTO.P_PONER_POSICION (V_POSICION => V_POSICION_FINAL,
					     V_SEGMENTO => V_SEGMENTO_FINAL);

		-- Coger el tramo actual
                V_TRAMO_ACTUAL := Q_RUTA.Q_LISTA_TRAMOS.F_DEVOLVER_ELEMENTO (V_POSICION => V_POSICION_TRAMO_ACTUAL,
                                                                             V_LISTA => V_RUTA);

		-- Obtener la posicion del segmento inicial.
		V_POSICION_SEGMENTO := 
			Q_TRAMO.Q_LISTA_SEGMENTOS.F_POSICION_ELEMENTO (V_ELEMENTO => V_SEGMENTO_INICIAL,
								       V_LISTA => Q_TRAMO.F_OBTENER_LISTA_SEGMENTOS (V_TRAMO_ACTUAL));

		if Q_RUTA.Q_LISTA_TRAMOS.F_CUANTOS_ELEMENTOS (V_RUTA) = 1 then

			-- La ruta es de un solo tramo.
			loop

				-- Anadir el tramo actual al elemento de progresion
				V_ELEMENTO_PROGRESION.R_ID_TRAMO_ACTUAL := Q_TRAMO.F_OBTENER_ID (V_TRAMO_ACTUAL);

				-- Obtener la posicion del segmento y anadirla al elemento de progresion.
                                V_ELEMENTO_PROGRESION.R_POSICION := 
					Q_SEGMENTO.F_OBTENER_POSICION 
						(Q_TRAMO.Q_LISTA_SEGMENTOS.F_DEVOLVER_ELEMENTO 
							(V_POSICION => V_POSICION_SEGMENTO,
                                                         V_LISTA => Q_TRAMO.F_OBTENER_LISTA_SEGMENTOS (V_TRAMO_ACTUAL)));

                              	-- Anadir las restricciones.
                                Q_RESTRICCION.P_PONER_RESTRICCION (V_VELOCIDAD => Q_TRAMO.F_OBTENER_VELOCIDAD_MAXIMA (V_TRAMO_ACTUAL),
                                                 		   V_SENAL => Q_RESTRICCION.E_NULA,
                                                 		   V_RESTRICCION => V_RESTRICCION);

                                V_ELEMENTO_PROGRESION.R_RESTRICCION := V_RESTRICCION;

                                P_INSERTAR_ELEMENTO (V_ELEMENTO => V_ELEMENTO_PROGRESION,
                                                     V_LISTA => V_PROGRESION);

                                exit when Q_TIPOS_BASICOS."=" (V_POSICION_1 => V_ELEMENTO_PROGRESION.R_POSICION,
                                                               V_POSICION_2 => V_POSICION_FINAL);
			
				if Q_TRAMO.Q_LISTA_SEGMENTOS.F_POSICION_ELEMENTO 
					(V_ELEMENTO => V_SEGMENTO_INICIAL,
                                         V_LISTA => Q_TRAMO.F_OBTENER_LISTA_SEGMENTOS (V_TRAMO_ACTUAL)) >
                           	   Q_TRAMO.Q_LISTA_SEGMENTOS.F_POSICION_ELEMENTO 
					(V_ELEMENTO => V_SEGMENTO_FINAL,
                                         V_LISTA => Q_TRAMO.F_OBTENER_LISTA_SEGMENTOS (V_TRAMO_ACTUAL)) then

					-- Sentido decreciente de las posiciones.
					-- Actualizar la posicion para obtener el nuevo segmento.
                                	V_POSICION_SEGMENTO := V_POSICION_SEGMENTO - 1;	

				else

					--Sentido creciente de las posiciones.
					V_POSICION_SEGMENTO := V_POSICION_SEGMENTO + 1;

				end if;

			end loop;

		else

			-- La ruta es de mas de un tramo.
			loop

				if V_POSICION_TRAMO_ACTUAL = Q_RUTA.Q_LISTA_TRAMOS.F_CUANTOS_ELEMENTOS (V_RUTA) then				
					-- Es el ultimo tramo. La comprobacion del sentido de la progresion es igual que en el caso de rutas
                                        -- con un solo tramo.
					-- Obtener la posicion del segmento final
					V_POSICION_SEGMENTO_FINAL := 
						Q_TRAMO.Q_LISTA_SEGMENTOS.F_POSICION_ELEMENTO 
							(V_ELEMENTO => V_SEGMENTO_FINAL,
							 V_LISTA => Q_TRAMO.F_OBTENER_LISTA_SEGMENTOS (V_TRAMO_ACTUAL));

					V_ELEMENTO_PROGRESION.R_ID_TRAMO_ACTUAL := Q_TRAMO.F_OBTENER_ID (V_TRAMO_ACTUAL);
				
					-- Obtener la posicion del segmento y anadirla al elemento de progresion.
					V_ELEMENTO_PROGRESION.R_POSICION := 
						Q_SEGMENTO.F_OBTENER_POSICION 
							(Q_TRAMO.Q_LISTA_SEGMENTOS.F_DEVOLVER_ELEMENTO 
								(V_POSICION => V_POSICION_SEGMENTO,
								 V_LISTA => Q_TRAMO.F_OBTENER_LISTA_SEGMENTOS (V_TRAMO_ACTUAL)));

					-- Anadir las restricciones.
                                        Q_RESTRICCION.P_PONER_RESTRICCION
                                                (V_VELOCIDAD => Q_TRAMO.F_OBTENER_VELOCIDAD_MAXIMA (V_TRAMO_ACTUAL),
                                                 V_SENAL => Q_RESTRICCION.E_NULA,
                                                 V_RESTRICCION => V_RESTRICCION);

                                        V_ELEMENTO_PROGRESION.R_RESTRICCION := V_RESTRICCION;

                                        P_INSERTAR_ELEMENTO (V_ELEMENTO => V_ELEMENTO_PROGRESION,
                                                             V_LISTA => V_PROGRESION);

					exit when Q_TIPOS_BASICOS."=" (V_POSICION_1 => V_ELEMENTO_PROGRESION.R_POSICION,
                                                                       V_POSICION_2 => V_POSICION_FINAL);

					if V_POSICION_SEGMENTO > V_POSICION_SEGMENTO_FINAL then

						-- El ultimo tramo sera recorrido en sentido origen -> final. Indice descendiente.
						V_POSICION_SEGMENTO := V_POSICION_SEGMENTO - 1;

					else

						-- El ultimo tramo sera recorrido en sentido final -> origen. Indice creciente.
						V_POSICION_SEGMENTO := V_POSICION_SEGMENTO + 1;

					end if;

				else

					-- No es el ultimo tramo
					--
					V_ELEMENTO_PROGRESION.R_ID_TRAMO_ACTUAL := Q_TRAMO.F_OBTENER_ID (V_TRAMO_ACTUAL);

					-- Obtener la posicion del segmento y anadirla al elemento de progresion.
					V_ELEMENTO_PROGRESION.R_POSICION := 
						Q_SEGMENTO.F_OBTENER_POSICION 
							(Q_TRAMO.Q_LISTA_SEGMENTOS.F_DEVOLVER_ELEMENTO 
								(V_POSICION => V_POSICION_SEGMENTO,
						 	 	 V_LISTA => Q_TRAMO.F_OBTENER_LISTA_SEGMENTOS (V_TRAMO_ACTUAL)));

					-- Anadir las restricciones.
                        		Q_RESTRICCION.P_PONER_RESTRICCION 
						(V_VELOCIDAD => Q_TRAMO.F_OBTENER_VELOCIDAD_MAXIMA (V_TRAMO_ACTUAL),
                                                 V_SENAL => Q_RESTRICCION.E_NULA,
                                                 V_RESTRICCION => V_RESTRICCION);

                        		V_ELEMENTO_PROGRESION.R_RESTRICCION := V_RESTRICCION;

                        		P_INSERTAR_ELEMENTO (V_ELEMENTO => V_ELEMENTO_PROGRESION,
                                             	     	     V_LISTA => V_PROGRESION);

					-- Comprobar sentido del tramo en la progresion.
					if Q_TIPOS_BASICOS."=" 
						(V_POSICION_1 => Q_TRAMO.F_OBTENER_FINAL (V_TRAMO_ACTUAL),
					 	 V_POSICION_2 => 
							Q_TRAMO.F_OBTENER_ORIGEN 
								(Q_RUTA.Q_LISTA_TRAMOS.F_DEVOLVER_ELEMENTO 
									(V_POSICION => V_POSICION_TRAMO_ACTUAL + 1,
							 		 V_LISTA => V_RUTA))) or
				   	   Q_TIPOS_BASICOS."="
                                        	(V_POSICION_1 => Q_TRAMO.F_OBTENER_FINAL (V_TRAMO_ACTUAL),
                                         	 V_POSICION_2 => 
                                                	Q_TRAMO.F_OBTENER_FINAL 
                                                        	(Q_RUTA.Q_LISTA_TRAMOS.F_DEVOLVER_ELEMENTO 
                                                                	(V_POSICION => V_POSICION_TRAMO_ACTUAL + 1,
                                                                 	 V_LISTA => V_RUTA))) then

						-- Sentido en el tramo: origen -> destino. Recorrido decreciente en este tramo.
						-- Actualizar la posicion para obtener el nuevo segmento.
						
                                        	V_POSICION_SEGMENTO := V_POSICION_SEGMENTO - 1;

						if V_POSICION_SEGMENTO = 0 then

							-- Se ha llegado al final del tramo.
							V_ELEMENTO_PROGRESION.R_ID_TRAMO_ACTUAL := Q_TRAMO.F_OBTENER_ID (V_TRAMO_ACTUAL);
							-- Anadir la conexion que al ser recorrido decreciente tiene que ser el final del 
							-- tramo actual.
							V_ELEMENTO_PROGRESION.R_POSICION := Q_TRAMO.F_OBTENER_FINAL (V_TRAMO_ACTUAL);

							--
							V_TRAMO_SIGUIENTE_ID := 
								Q_TRAMO.F_OBTENER_ID 
									(Q_RUTA.Q_LISTA_TRAMOS.F_DEVOLVER_ELEMENTO 
										(V_POSICION => V_POSICION_TRAMO_ACTUAL + 1,
										 V_LISTA => V_RUTA));

							-- La velocidad maxima sera la del siguiente tramo.
							-- Obtener la restriccion de velocidad de la adaptacion.
							begin

							Q_RESTRICCION.P_PONER_RESTRICCION 
								(V_VELOCIDAD => 
									Q_ADAPTACION_TRAMO.F_OBTENER_RESTRICCION_VELOCIDAD_ENTRE_TRAMOS 
										(V_TRAMO_ID_1 => Q_TRAMO.F_OBTENER_ID (V_TRAMO_ACTUAL),
										 V_TRAMO_ID_2 => V_TRAMO_SIGUIENTE_ID,
										 V_CARRIL_ACTUAL => 
											F_OBTENER_CARRIL_OPTIMO 
												(V_TRAMO_ID => 
													Q_TRAMO.F_OBTENER_ID 
														(V_TRAMO_ACTUAL),
												 V_PROGRESION_CARRILES_OPTIMO => 
													V_PROGRESION_CARRILES_OPTIMO),
										 V_CARRIL_SIGUIENTE =>
											F_OBTENER_CARRIL_OPTIMO
												(V_TRAMO_ID => V_TRAMO_SIGUIENTE_ID,
												 V_PROGRESION_CARRILES_OPTIMO =>
													V_PROGRESION_CARRILES_OPTIMO)),
								 V_SENAL => Q_RESTRICCION.E_NULA,
								 V_RESTRICCION => V_RESTRICCION);

							exception

							-- Que pasa si hay un cambio de carril en el tramo siguiente y por lo tanto no 
							-- existe la conexion buscada entre tramos a traves de los carriles optimos.
							-- Habrá que buscar la conexion entre el tramo actual y el siguiente.

								when Q_ADAPTACION_TRAMO.X_TRAMO_DESTINO_NO_ENCONTRADO =>

								-- No se ha podido encontrar una conexion al carril siguiente optimo
								-- Habra que buscar un carril siguiente alternativo.
								Q_RESTRICCION.P_PONER_RESTRICCION 
									(V_VELOCIDAD => 
										Q_ADAPTACION_TRAMO.
										F_OBTENER_RESTRICCION_VELOCIDAD_ENTRE_TRAMOS
										(V_TRAMO_ID_1 => Q_TRAMO.F_OBTENER_ID (V_TRAMO_ACTUAL),
										 V_TRAMO_ID_2 => V_TRAMO_SIGUIENTE_ID,
										 V_CARRIL_ACTUAL => 
											F_OBTENER_CARRIL_OPTIMO 
												(V_TRAMO_ID => 
													Q_TRAMO.F_OBTENER_ID 
														(V_TRAMO_ACTUAL),
												 V_PROGRESION_CARRILES_OPTIMO =>
													V_PROGRESION_CARRILES_OPTIMO),
										 V_CARRIL_SIGUIENTE => 
											Q_ADAPTACION_TRAMO.
											F_OBTENER_SIGUIENTE_CARRIL_ALTERNATIVO
											(V_TRAMO_ORIGEN_ID => 
												Q_TRAMO.F_OBTENER_ID (V_TRAMO_ACTUAL),
											 V_TRAMO_SIGUIENTE_ID => V_TRAMO_SIGUIENTE_ID,
											 V_CARRIL_ACTUAL => 
												F_OBTENER_CARRIL_OPTIMO 
											       (V_TRAMO_ID => 
													Q_TRAMO.F_OBTENER_ID 
														(V_TRAMO_ACTUAL),
												V_PROGRESION_CARRILES_OPTIMO =>
													V_PROGRESION_CARRILES_OPTIMO),
											 V_CARRIL_SIGUIENTE_OPTIMO =>
												F_OBTENER_CARRIL_OPTIMO
                                                                                                (V_TRAMO_ID => V_TRAMO_SIGUIENTE_ID,
                                                                                                 V_PROGRESION_CARRILES_OPTIMO =>
                                                                                                        V_PROGRESION_CARRILES_OPTIMO))),
									 V_SENAL => Q_RESTRICCION.E_NULA,
                                                                 	 V_RESTRICCION => V_RESTRICCION);														
							end;

							V_ELEMENTO_PROGRESION.R_RESTRICCION := V_RESTRICCION;
			
							P_INSERTAR_ELEMENTO (V_ELEMENTO => V_ELEMENTO_PROGRESION,
									     V_LISTA => V_PROGRESION);						
							-- Cambiar el tramo.
							V_POSICION_TRAMO_ACTUAL := V_POSICION_TRAMO_ACTUAL + 1;
							V_TRAMO_ACTUAL := 
								Q_RUTA.Q_LISTA_TRAMOS.F_DEVOLVER_ELEMENTO 
									(V_POSICION => V_POSICION_TRAMO_ACTUAL,
									 V_LISTA => V_RUTA);

							-- Cambiar el segmento
							-- Hay que saber la posicion del primer segmento del nuevo tramo para actualizarla.
							-- Se tiene la conexion que se acaba de insertar en la progresion.
							-- Si esa conexion coincide con el origen del proximo tramo (ya tramo actual)
							-- entonces la progresion tendra : 
							-- sentido origen -> final. Recorrido decreciente 
							-- => posicion de segmento = numero de segmentos del tramo.
							-- sentido final -> origen. Recorrido creciente
							-- => posicion de segmento = 1.
							if Q_TIPOS_BASICOS."=" (V_POSICION_1 => V_ELEMENTO_PROGRESION.R_POSICION,
										V_POSICION_2 => Q_TRAMO.F_OBTENER_ORIGEN (V_TRAMO_ACTUAL))
							
							then

								-- Sentido origen -> final.
								V_POSICION_SEGMENTO := 
									Q_TRAMO.Q_LISTA_SEGMENTOS.F_CUANTOS_ELEMENTOS 
										(Q_TRAMO.F_OBTENER_LISTA_SEGMENTOS (V_TRAMO_ACTUAL));

							else

								-- Sentido final -> origen.
								V_POSICION_SEGMENTO := 1;

							end if;

						end if;	

					else

						-- Sentido en el tramo: destino -> origen. Recorrido creciente en este tramo.
						-- Actualizar la posicion para obtener el nuevo segmento.
                                        	V_POSICION_SEGMENTO := V_POSICION_SEGMENTO + 1;

						if V_POSICION_SEGMENTO = 
						   Q_TRAMO.Q_LISTA_SEGMENTOS.F_CUANTOS_ELEMENTOS 
							(Q_TRAMO.F_OBTENER_LISTA_SEGMENTOS (V_TRAMO_ACTUAL)) + 1 then

							-- Se ha llegado al final del tramo.
							-- Anadir la conexion que al ser recorrido crecientemente tiene que ser el origen 
							-- del tramo actual.
							V_ELEMENTO_PROGRESION.R_ID_TRAMO_ACTUAL := Q_TRAMO.F_OBTENER_ID (V_TRAMO_ACTUAL);						
							V_ELEMENTO_PROGRESION.R_POSICION := Q_TRAMO.F_OBTENER_ORIGEN (V_TRAMO_ACTUAL);

							--
                                                        V_TRAMO_SIGUIENTE_ID := 
								Q_TRAMO.F_OBTENER_ID 
									(Q_RUTA.Q_LISTA_TRAMOS.F_DEVOLVER_ELEMENTO 
										(V_POSICION => V_POSICION_TRAMO_ACTUAL + 1,
                                                                                 V_LISTA => V_RUTA));

                                                        -- La velocidad maxima sera la del siguiente tramo.
							begin

							Q_RESTRICCION.P_PONER_RESTRICCION
                                                                (V_VELOCIDAD =>
                                                                        Q_ADAPTACION_TRAMO.F_OBTENER_RESTRICCION_VELOCIDAD_ENTRE_TRAMOS
                                                                                (V_TRAMO_ID_1 => Q_TRAMO.F_OBTENER_ID (V_TRAMO_ACTUAL),
                                                                                 V_TRAMO_ID_2 => V_TRAMO_SIGUIENTE_ID,
										 V_CARRIL_ACTUAL => 
											F_OBTENER_CARRIL_OPTIMO
                                                                                                (V_TRAMO_ID =>
                                                                                                        Q_TRAMO.F_OBTENER_ID
                                                                                                                (V_TRAMO_ACTUAL),
                                                                                                 V_PROGRESION_CARRILES_OPTIMO =>
                                                                                                        V_PROGRESION_CARRILES_OPTIMO),
                                                                                 V_CARRIL_SIGUIENTE =>
                                                                                        F_OBTENER_CARRIL_OPTIMO
                                                                                                (V_TRAMO_ID => V_TRAMO_SIGUIENTE_ID,
                                                                                                 V_PROGRESION_CARRILES_OPTIMO =>
                                                                                                        V_PROGRESION_CARRILES_OPTIMO)),
                                                                 V_SENAL => Q_RESTRICCION.E_NULA,
                                                                 V_RESTRICCION => V_RESTRICCION);

							exception

							-- Que pasa si hay un cambio de carril en el tramo siguiente y por lo tanto no 
                                                        -- existe la conexion buscada entre tramos a traves de los carriles optimos.
                                                        -- Habrá que buscar la conexion entre el tramo actual y el siguiente.

								when Q_ADAPTACION_TRAMO.X_TRAMO_DESTINO_NO_ENCONTRADO =>

								-- No se ha podido encontrar una conexion al carril siguiente optimo
                                                                -- Habra que buscar un carril siguiente alternativo.

								Q_RESTRICCION.P_PONER_RESTRICCION
                                                                        (V_VELOCIDAD =>
                                                                                Q_ADAPTACION_TRAMO.
                                                                                F_OBTENER_RESTRICCION_VELOCIDAD_ENTRE_TRAMOS
                                                                                (V_TRAMO_ID_1 => Q_TRAMO.F_OBTENER_ID (V_TRAMO_ACTUAL),
                                                                                 V_TRAMO_ID_2 => V_TRAMO_SIGUIENTE_ID,
                                                                                 V_CARRIL_ACTUAL =>
                                                                                        F_OBTENER_CARRIL_OPTIMO
                                                                                                (V_TRAMO_ID =>
                                                                                                        Q_TRAMO.F_OBTENER_ID
                                                                                                                (V_TRAMO_ACTUAL),
                                                                                                 V_PROGRESION_CARRILES_OPTIMO =>
                                                                                                        V_PROGRESION_CARRILES_OPTIMO),
                                                                                 V_CARRIL_SIGUIENTE =>
                                                                                        Q_ADAPTACION_TRAMO.
                                                                                        F_OBTENER_SIGUIENTE_CARRIL_ALTERNATIVO
                                                                                        (V_TRAMO_ORIGEN_ID =>
                                                                                                Q_TRAMO.F_OBTENER_ID (V_TRAMO_ACTUAL),
                                                                                         V_TRAMO_SIGUIENTE_ID => V_TRAMO_SIGUIENTE_ID,
                                                                                         V_CARRIL_ACTUAL =>
                                                                                                F_OBTENER_CARRIL_OPTIMO
                                                                                               (V_TRAMO_ID =>
                                                                                                        Q_TRAMO.F_OBTENER_ID
                                                                                                                (V_TRAMO_ACTUAL),
                                                                                                V_PROGRESION_CARRILES_OPTIMO =>
                                                                                                        V_PROGRESION_CARRILES_OPTIMO),
                                                                                         V_CARRIL_SIGUIENTE_OPTIMO =>
                                                                                                F_OBTENER_CARRIL_OPTIMO
                                                                                                (V_TRAMO_ID => V_TRAMO_SIGUIENTE_ID,
                                                                                                 V_PROGRESION_CARRILES_OPTIMO =>
                                                                                                        V_PROGRESION_CARRILES_OPTIMO))),
                                                                         V_SENAL => Q_RESTRICCION.E_NULA,
                                                                         V_RESTRICCION => V_RESTRICCION);

							end;

                                                        V_ELEMENTO_PROGRESION.R_RESTRICCION := V_RESTRICCION;

                                                        P_INSERTAR_ELEMENTO (V_ELEMENTO => V_ELEMENTO_PROGRESION,                                                                                                         V_LISTA => V_PROGRESION);
							-- Cambiar el tramo.
                                                        V_POSICION_TRAMO_ACTUAL := V_POSICION_TRAMO_ACTUAL + 1;
                                                        V_TRAMO_ACTUAL :=
                                                                Q_RUTA.Q_LISTA_TRAMOS.F_DEVOLVER_ELEMENTO 
                                                                        (V_POSICION => V_POSICION_TRAMO_ACTUAL,
                                                                         V_LISTA => V_RUTA);

							-- Cambiar el segmento
                                                        -- Hay que saber la posicion del primer segmento del nuevo tramo para actualizarla.
                                                        -- Se tiene la conexion que se acaba de insertar en la progresion.
                                                        -- Si esa conexion coincide con el origen del proximo tramo (ya tramo actual)
                                                        -- entonces la progresion tendra : 
                                                        -- sentido origen -> final. Recorrido decreciente 
                                                        -- => posicion de segmento = numero de segmentos del tramo.
                                                        -- sentido final -> origen. Recorrido creciente
                                                        -- => posicion de segmento = 1.
                                                        if Q_TIPOS_BASICOS."=" (V_POSICION_1 => V_ELEMENTO_PROGRESION.R_POSICION,
                                                                                V_POSICION_2 => Q_TRAMO.F_OBTENER_ORIGEN (V_TRAMO_ACTUAL))

                                                        then

                                                                -- Sentido origen -> final.
                                                                V_POSICION_SEGMENTO :=
                                                                        Q_TRAMO.Q_LISTA_SEGMENTOS.F_CUANTOS_ELEMENTOS 
                                                                                (Q_TRAMO.F_OBTENER_LISTA_SEGMENTOS (V_TRAMO_ACTUAL));

                                                        else

                                                                -- Sentido final -> origen.
                                                                V_POSICION_SEGMENTO := 1;

                                                        end if;

						end if;

					end if;

				end if;

			end loop;

		end if;

	end P_GENERAR_ENVELOPE_ESTATICO;
	--------------------------------

	-------------------------------------------------------------------------------
	-- Se calcula la velocidad de frenada en funcion de la posicion: v = (I-1)*9
	-- Cuando esta velocidad de frenada sea menor, entonces se usara esa velocidad
	-- en el elemento de la progresion, si es mayor, se usara el elemento tal cual 
	-- venga en la progresion estatica.
	-------------------------------------------------------------------------------
	procedure P_GENERAR_PROGRESION_FRENADA (V_PROGRESION_ESTATICA : in T_PROGRESION;
						V_PROGRESION_DINAMICA : out T_PROGRESION;
						V_PUNTO_FRENADA_FINAL : out Natural) is

		V_ELEMENTO_PROGRESION, V_ELEMENTO_PROGRESION_AUX : T_ELEMENTO_PROGRESION;

		V_VELOCIDAD_AUX : Integer := 0;

		V_RESTRICCION_AUX : Q_RESTRICCION.T_RESTRICCION;

		V_YA_HEMOS_LLEGADO_AL_PUNTO_FRENADO : Boolean := False;

	begin

		P_INICIALIZAR_LISTA (V_PROGRESION_DINAMICA);

		-- En caso de que el trayecto conste solo de un segmento => Fijar la velocidad a 9 Km/h.
		if F_CUANTOS_ELEMENTOS (V_PROGRESION_ESTATICA) = 1 then

			V_ELEMENTO_PROGRESION := F_DEVOLVER_ELEMENTO (V_POSICION => 1,
                                                                      V_LISTA => V_PROGRESION_ESTATICA);

			V_ELEMENTO_PROGRESION_AUX.R_ID_TRAMO_ACTUAL := F_OBTENER_ID_TRAMO_ACTUAL (V_ELEMENTO_PROGRESION);

                        V_ELEMENTO_PROGRESION_AUX.R_POSICION := F_OBTENER_POSICION (V_ELEMENTO_PROGRESION);

                      	Q_RESTRICCION.P_PONER_RESTRICCION (V_VELOCIDAD => 9,
                                                           V_SENAL => 
								Q_RESTRICCION.F_OBTENER_RESTRICCION_SENAL 
									(F_OBTENER_RESTRICCION (V_ELEMENTO_PROGRESION)),
                                                           V_RESTRICCION => V_RESTRICCION_AUX);

                   	V_ELEMENTO_PROGRESION_AUX.R_RESTRICCION := V_RESTRICCION_AUX;

                        P_INSERTAR_ELEMENTO (V_ELEMENTO => V_ELEMENTO_PROGRESION_AUX,
                                  	     V_LISTA => V_PROGRESION_DINAMICA);

		else

			-- Recorrer la progresion estatica
			for I in reverse 1 .. F_CUANTOS_ELEMENTOS (V_PROGRESION_ESTATICA) loop

				-- Frenamos a 8 Km/h por segundo.
				V_VELOCIDAD_AUX := (I - 1) * 8;

				V_ELEMENTO_PROGRESION := F_DEVOLVER_ELEMENTO (V_POSICION => I,
                                	                                      V_LISTA => V_PROGRESION_ESTATICA);

				if Q_RESTRICCION.F_OBTENER_RESTRICCION_VELOCIDAD (V_ELEMENTO_PROGRESION.R_RESTRICCION) <= V_VELOCIDAD_AUX 
				then

					-- Insertar el elemento de progresion estatica tal cual.
					P_INSERTAR_ELEMENTO (V_ELEMENTO => V_ELEMENTO_PROGRESION,
                                        	             V_LISTA => V_PROGRESION_DINAMICA);

				else

					if not V_YA_HEMOS_LLEGADO_AL_PUNTO_FRENADO then

						V_PUNTO_FRENADA_FINAL := I;
						V_YA_HEMOS_LLEGADO_AL_PUNTO_FRENADO := True;

					end if;

					-- Crear un elemento de progresion con la velocidad auxiliar e insertarlo en la progresion dinamica.
					V_ELEMENTO_PROGRESION_AUX.R_ID_TRAMO_ACTUAL := F_OBTENER_ID_TRAMO_ACTUAL (V_ELEMENTO_PROGRESION);

					V_ELEMENTO_PROGRESION_AUX.R_POSICION := F_OBTENER_POSICION (V_ELEMENTO_PROGRESION);

					Q_RESTRICCION.P_PONER_RESTRICCION (V_VELOCIDAD => V_VELOCIDAD_AUX,
                                        	                           V_SENAL => 
										Q_RESTRICCION.F_OBTENER_RESTRICCION_SENAL 
											(F_OBTENER_RESTRICCION (V_ELEMENTO_PROGRESION)),
                                                                	   V_RESTRICCION => V_RESTRICCION_AUX);

					V_ELEMENTO_PROGRESION_AUX.R_RESTRICCION := V_RESTRICCION_AUX;

					P_INSERTAR_ELEMENTO (V_ELEMENTO => V_ELEMENTO_PROGRESION_AUX,
							     V_LISTA => V_PROGRESION_DINAMICA);

				end if;

			end loop;

		end if;

	end P_GENERAR_PROGRESION_FRENADA;
	---------------------------------

	---------------------------------------------------------------------------------------------------
	procedure P_GENERAR_PROGRESION (V_POSICION_INICIAL : in Q_TIPOS_BASICOS.T_POSICION_UTM;
					V_POSICION_FINAL : in Q_TIPOS_BASICOS.T_POSICION_UTM;
					V_RUTA : in Q_RUTA.T_RUTA;
					V_PROGRESION : out T_PROGRESION;
					V_PROGRESION_CARRILES_OPTIMO : out T_PROGRESION_CARRILES_OPTIMO;
					V_LISTA_TRAMOS_GLORIETA : out T_LISTA_TRAMOS_GLORIETA) is	

		V_PROGRESION_ESTATICA, V_PROGRESION_DINAMICA : T_PROGRESION;

		V_PUNTO_FRENADA_FINAL, V_LIMITE_HORIZONTE, V_HORIZONTE, V_HORIZONTE_SEGMENTOS : Natural := 0;

		V_ELEMENTO_PROGRESION, V_ELEMENTO_PROGRESION_AUX : T_ELEMENTO_PROGRESION;

		V_VELOCIDAD_ELEMENTO_PROGRESION, V_VELOCIDAD_ELEMENTO_PROGRESION_AUX, V_VELOCIDAD_FRENADO_INICIAL, V_VELOCIDAD_FRENADO : 
			Q_TIPOS_BASICOS.T_VELOCIDAD;

		V_HAY_QUE_FRENAR : Boolean;

		V_POSICION_CAMBIO : Natural := 1_000_000;

		V_RESTRICCION_AUX : Q_RESTRICCION.T_RESTRICCION;

	begin

		P_INICIALIZAR_LISTA (V_PROGRESION_ESTATICA);

		P_GENERAR_ENVELOPE_ESTATICO (V_POSICION_INICIAL => V_POSICION_INICIAL,
					     V_POSICION_FINAL => V_POSICION_FINAL,
					     V_RUTA => V_RUTA,
					     V_PROGRESION  => V_PROGRESION_ESTATICA,
					     V_PROGRESION_CARRILES_OPTIMO => V_PROGRESION_CARRILES_OPTIMO,
					     V_LISTA_TRAMOS_GLORIETA => V_LISTA_TRAMOS_GLORIETA);		

		P_INICIALIZAR_LISTA (V_PROGRESION_DINAMICA);
		
		P_GENERAR_PROGRESION_FRENADA (V_PROGRESION_ESTATICA => V_PROGRESION_ESTATICA,
                                              V_PROGRESION_DINAMICA => V_PROGRESION_DINAMICA,
                                              V_PUNTO_FRENADA_FINAL => V_PUNTO_FRENADA_FINAL);

		P_INICIALIZAR_LISTA (V_PROGRESION);

		-- La parte final de la progresion. La llegada frenando hasta 0 ya esta calculada.
		for I in reverse V_PUNTO_FRENADA_FINAL .. F_CUANTOS_ELEMENTOS (V_PROGRESION_DINAMICA) loop

			if I < V_POSICION_CAMBIO then

				V_HAY_QUE_FRENAR := False;

				V_ELEMENTO_PROGRESION := F_DEVOLVER_ELEMENTO (V_POSICION => I,
                                	                                      V_LISTA => V_PROGRESION_DINAMICA);

				--Obtener la velocidad del elemento de progresion.
               			V_VELOCIDAD_ELEMENTO_PROGRESION := 
					Q_RESTRICCION.F_OBTENER_RESTRICCION_VELOCIDAD (V_ELEMENTO_PROGRESION.R_RESTRICCION);

				-- Obtener la distancia de seguridad en base a la velocidad => horizonte.
                		V_HORIZONTE := (V_VELOCIDAD_ELEMENTO_PROGRESION / 10)**2;

                      		-- Obtener el horizonte en segmentos. Como minimo vamos a tomar un horizonte de un segmento.
                        	-- De momento para una velocidad de 50 Km / h => horizonte = 25 metros => horizonte en segmentos seria,
				-- pero tomamos 6 por simplificar.
                		V_HORIZONTE_SEGMENTOS := (V_HORIZONTE / 5) + 1;

				-- Comprobar que I - V_HORIZONTE_SEGMENTOS >= V_PUNTO_FRENADA_FINAL porque si no puede que estemos
				-- considerando una parte de la progresion que ya no hay que cambiar.
				if I - V_HORIZONTE_SEGMENTOS < V_PUNTO_FRENADA_FINAL then

					V_LIMITE_HORIZONTE := V_PUNTO_FRENADA_FINAL;

				else

					V_LIMITE_HORIZONTE := I - V_HORIZONTE_SEGMENTOS;

				end if;


				for J in reverse V_LIMITE_HORIZONTE .. I - 1 loop

					V_VELOCIDAD_ELEMENTO_PROGRESION_AUX := 
						Q_RESTRICCION.F_OBTENER_RESTRICCION_VELOCIDAD 
							(F_DEVOLVER_ELEMENTO (V_POSICION => J,
                       							      V_LISTA => V_PROGRESION_DINAMICA).R_RESTRICCION);

					-- Comprobar si la restriccion de velocidad del elemento de progresion J en la progresion estatica 
					-- es menor o no que la restriccion de velocidad del elemento I.
                                	-- Si alguna es menor => Ajustar velocidades
                                	-- Si no, anadir elemento I tal cual a la progresion dinamica.
                        		if V_VELOCIDAD_ELEMENTO_PROGRESION_AUX < V_VELOCIDAD_ELEMENTO_PROGRESION then

						-- Hay que frenar. Hay que reducir la velocidad entre el segmento I y el segmento J
                        			V_HAY_QUE_FRENAR := True;
						V_VELOCIDAD_FRENADO_INICIAL := 
							Integer
								(Float'Rounding(Float(V_VELOCIDAD_ELEMENTO_PROGRESION - 
										      V_VELOCIDAD_ELEMENTO_PROGRESION_AUX) / 
										Float(I -J)));
                     				V_VELOCIDAD_FRENADO := V_VELOCIDAD_FRENADO_INICIAL;

                        			V_POSICION_CAMBIO := J;

						-- Entre I y J hacia que disminuir la velocidad igual que en el caso de que estuvieramo 
						-- llegando al final.
                       				for K in reverse J .. I loop

							V_ELEMENTO_PROGRESION_AUX.R_ID_TRAMO_ACTUAL := 
								F_DEVOLVER_ELEMENTO (V_POSICION => K,
										     V_LISTA => V_PROGRESION_DINAMICA).R_ID_TRAMO_ACTUAL;

							V_ELEMENTO_PROGRESION_AUX.R_POSICION := 
								F_DEVOLVER_ELEMENTO (V_POSICION => K,
                      								     V_LISTA => V_PROGRESION_DINAMICA).R_POSICION;
		
							if K /= J then

								-- Comprobar que no frenamos de mas.
								if Q_RESTRICCION.F_OBTENER_RESTRICCION_VELOCIDAD 
									(F_DEVOLVER_ELEMENTO (V_POSICION => K,
											      V_LISTA => V_PROGRESION_DINAMICA).
													R_RESTRICCION) - 
								   V_VELOCIDAD_FRENADO < V_VELOCIDAD_ELEMENTO_PROGRESION_AUX then

									Q_RESTRICCION.P_PONER_RESTRICCION 
										(V_VELOCIDAD => V_VELOCIDAD_ELEMENTO_PROGRESION_AUX,
                                                                         	 V_SENAL =>
                                                                                	Q_RESTRICCION.F_OBTENER_RESTRICCION_SENAL
                                                                                        	(F_DEVOLVER_ELEMENTO
                                                                                                	(V_POSICION => K,
                                                                                                 	 V_LISTA =>
                                                                                                        	V_PROGRESION_DINAMICA).
                                                                                                                	R_RESTRICCION),
                                                                        	 V_RESTRICCION => V_RESTRICCION_AUX);

								else

                          						Q_RESTRICCION.P_PONER_RESTRICCION 
										(V_VELOCIDAD => 
											Q_RESTRICCION.F_OBTENER_RESTRICCION_VELOCIDAD 
												(F_DEVOLVER_ELEMENTO 
													(V_POSICION => K,
                          								 	 	 V_LISTA => 
														V_PROGRESION_DINAMICA).
															R_RESTRICCION) -
                          					 	 		V_VELOCIDAD_FRENADO,
                            					 	 	 V_SENAL => 
											Q_RESTRICCION.F_OBTENER_RESTRICCION_SENAL 
												(F_DEVOLVER_ELEMENTO 
													(V_POSICION => K,
                         								 	 	 V_LISTA => 
														V_PROGRESION_DINAMICA).
															R_RESTRICCION),
                     						 	 	 V_RESTRICCION => V_RESTRICCION_AUX);

								end if;

                            				else

								Q_RESTRICCION.P_PONER_RESTRICCION 
									(V_VELOCIDAD => V_VELOCIDAD_ELEMENTO_PROGRESION_AUX,
                                  				 	 V_SENAL => 
										Q_RESTRICCION.F_OBTENER_RESTRICCION_SENAL 
											(F_DEVOLVER_ELEMENTO 
												(V_POSICION => K,
                               								 	 V_LISTA => 
													V_PROGRESION_DINAMICA).
														R_RESTRICCION),
                                  				 	 V_RESTRICCION => V_RESTRICCION_AUX);

							end if;

							V_ELEMENTO_PROGRESION_AUX.R_RESTRICCION := V_RESTRICCION_AUX;

                               				P_INSERTAR_ELEMENTO (V_ELEMENTO => V_ELEMENTO_PROGRESION_AUX,
                               					     	     V_LISTA => V_PROGRESION);

                                    			V_VELOCIDAD_FRENADO := V_VELOCIDAD_FRENADO + V_VELOCIDAD_FRENADO_INICIAL;

						end loop;

						-- Ya se han cambiado todos los elementos de progresion.
						-- Salir de este loop. Se continua en el mas externo con I = V_POSICION_CAMBIO;
						exit;

					end if;

				end loop;

				-- Si al salir de este loop, de comprobar los "V_HORIZONTE_SEGMENTOS" siguientes no hay que frenar
                        	if not V_HAY_QUE_FRENAR then

                       			-- Insertar elemento de progresion I tal cual
                                	P_INSERTAR_ELEMENTO (V_ELEMENTO => V_ELEMENTO_PROGRESION,
							     V_LISTA => V_PROGRESION);

				end if;

			end if;

		end loop;

		-- Hay que introducir los elementos de la progresion dinamica a partir del punto de frenada final.
		for I in reverse 1 .. V_PUNTO_FRENADA_FINAL - 1 loop

			P_INSERTAR_ELEMENTO (V_ELEMENTO => F_DEVOLVER_ELEMENTO (V_POSICION => I,
                                                                              	V_LISTA => V_PROGRESION_DINAMICA),
					     V_LISTA => V_PROGRESION);

		end loop;

	end P_GENERAR_PROGRESION;
	--------------------------------------------------------------------------------------------------

	---------------------------------------------------------------------
	procedure P_VISUALIZAR_PROGRESION (V_PROGRESION : in T_PROGRESION) is

		V_ELEMENTO_PROGRESION : T_ELEMENTO_PROGRESION;

		package SENAL_IO is new Ada.Text_IO.Enumeration_IO(Q_RESTRICCION.T_SENAL);

	begin

		Ada.Text_Io.Put_Line (" PROGRESION ");
		Ada.Text_Io.Put_Line ("");

		for I in reverse 1 .. F_CUANTOS_ELEMENTOS (V_PROGRESION) loop

			V_ELEMENTO_PROGRESION := F_DEVOLVER_ELEMENTO (V_POSICION => I,
								      V_LISTA => V_PROGRESION);

			Ada.Text_Io.Put_Line (Ada.Characters.Latin_1.HT & " POSICION => " & 
					      Integer'Image(F_CUANTOS_ELEMENTOS (V_PROGRESION) - I + 1));
			Ada.Text_Io.Put_Line ("");
			Ada.Text_Io.Put_Line (Ada.Characters.Latin_1.HT & Ada.Characters.Latin_1.HT & " TRAMO ACTUAL => " &
                                              Integer'Image(V_ELEMENTO_PROGRESION.R_ID_TRAMO_ACTUAL));
			Ada.Text_Io.Put_Line ("");
			Ada.Text_Io.Put_Line 
				(Ada.Characters.Latin_1.HT & Ada.Characters.Latin_1.HT & " X => " & 
				 Integer'Image(Q_TIPOS_BASICOS.F_OBTENER_COORDENADA_X (V_ELEMENTO_PROGRESION.R_POSICION)));
			Ada.Text_Io.Put_Line
                                (Ada.Characters.Latin_1.HT & Ada.Characters.Latin_1.HT & " Y => " & 
                                 Integer'Image(Q_TIPOS_BASICOS.F_OBTENER_COORDENADA_Y (V_ELEMENTO_PROGRESION.R_POSICION)));
			Ada.Text_Io.Put_Line ("");
			Ada.Text_Io.Put_Line (Ada.Characters.Latin_1.HT & Ada.Characters.Latin_1.HT & " RESTRICCION => ");
			Ada.Text_Io.Put_Line ("");
			Ada.Text_Io.Put (Ada.Characters.Latin_1.HT & Ada.Characters.Latin_1.HT & Ada.Characters.Latin_1.HT & 
					 " VELOCIDAD => ");
			Ada.Text_Io.Put_Line 
				(Integer'Image (Q_RESTRICCION.F_OBTENER_RESTRICCION_VELOCIDAD (V_ELEMENTO_PROGRESION.R_RESTRICCION)));
			Ada.Text_Io.Put (Ada.Characters.Latin_1.HT & Ada.Characters.Latin_1.HT & Ada.Characters.Latin_1.HT & " SENAL => ");
                        SENAL_IO.Put (Item => Q_RESTRICCION.F_OBTENER_RESTRICCION_SENAL (V_ELEMENTO_PROGRESION.R_RESTRICCION),
				      Width => 12); Ada.Text_Io.Put_Line (""); 
                        Ada.Text_Io.Put_Line ("");

		end loop;

	end P_VISUALIZAR_PROGRESION;
	---------------------------------------------------------------------

	--------------------------------------------------------------------------------------------------------------
	function F_OBTENER_ELEMENTO_ACTUAL_PROGRESION (V_PROGRESION : in T_PROGRESION) return T_ELEMENTO_PROGRESION is

	begin

		return F_DEVOLVER_ELEMENTO (V_POSICION => F_CUANTOS_ELEMENTOS (V_PROGRESION),
					    V_LISTA => V_PROGRESION);

	end F_OBTENER_ELEMENTO_ACTUAL_PROGRESION;
	--------------------------------------------------------------------------------------------------------------

	-----------------------------------------------------------------------------------------------------------------------
	function F_OBTENER_RESTRICCION (V_ELEMENTO_PROGRESION : in T_ELEMENTO_PROGRESION) return Q_RESTRICCION.T_RESTRICCION is

	begin

		return V_ELEMENTO_PROGRESION.R_RESTRICCION;

	end F_OBTENER_RESTRICCION;
	-----------------------------------------------------------------------------------------------------------------------

	-------------------------------------------------------------------------------------------------------
	function F_OBTENER_ID_TRAMO_ACTUAL (V_ELEMENTO_PROGRESION : in T_ELEMENTO_PROGRESION) return Integer is

	begin

		return V_ELEMENTO_PROGRESION.R_ID_TRAMO_ACTUAL;

	end F_OBTENER_ID_TRAMO_ACTUAL;
	-------------------------------------------------------------------------------------------------------

	-----------------------------------------------------------------------------------------------------------------------
	function F_OBTENER_POSICION (V_ELEMENTO_PROGRESION : in T_ELEMENTO_PROGRESION) return Q_TIPOS_BASICOS.T_POSICION_UTM is

	begin

		return V_ELEMENTO_PROGRESION.R_POSICION;

	end F_OBTENER_POSICION;
	-----------------------------------------------------------------------------------------------------------------------

	---------------------------------------------------------------------------------------
	procedure P_ELIMINAR_ELEMENTO_ACTUAL_PROGRESION (V_PROGRESION : in out T_PROGRESION) is

	begin

		P_ELIMINAR_ULTIMO_ELEMENTO (V_LISTA => V_PROGRESION);

	end P_ELIMINAR_ELEMENTO_ACTUAL_PROGRESION;
	---------------------------------------------------------------------------------------

	-------------------------------------------------------------------------------------
	function F_ESTA_PROGRESION_ACABADA (V_PROGRESION : in T_PROGRESION) return Boolean is

	begin

		return F_ESTA_VACIA_LISTA (V_PROGRESION);

	end F_ESTA_PROGRESION_ACABADA;
	-------------------------------------------------------------------------------------

	------------------------------------------------------------------------------------------
	function F_CUANTOS_ELEMENTOS_PROGRESION (V_PROGRESION : in T_PROGRESION) return Natural is

	begin

		return F_CUANTOS_ELEMENTOS (V_PROGRESION);
	
	end F_CUANTOS_ELEMENTOS_PROGRESION;
	------------------------------------------------------------------------------------------

	----------------------------------------------------------------------------------------------
	function F_SON_ELEMENTOS_PROGRESION_CARRILES_IGUALES 
		(V_ELEMENTO_PROGRESION_CARRIL_1 : in T_ELEMENTO_PROGRESION_CARRILES;
		 V_ELEMENTO_PROGRESION_CARRIL_2 : in T_ELEMENTO_PROGRESION_CARRILES) return Boolean is

	begin

		return V_ELEMENTO_PROGRESION_CARRIL_1.R_ID_TRAMO_ACTUAL = V_ELEMENTO_PROGRESION_CARRIL_2.R_ID_TRAMO_ACTUAL;

	end F_SON_ELEMENTOS_PROGRESION_CARRILES_IGUALES;
	------------------------------------------------
	
	----------------------------------------------------------------------------------------------
	procedure P_GENERAR_PROGRESION_CARRILES (V_RUTA : in Q_RUTA.T_RUTA;
						 V_PROGRESION_CARRILES : out T_PROGRESION_CARRILES) is

		V_LISTA_CARRILES_TRAMO_ACTUAL, V_LISTA_CARRILES_TRAMO_SIGUIENTE : Q_ADAPTACION_TRAMO.Q_LISTA_CARRILES.T_LISTA;

	begin

		P_INICIALIZAR_LISTA (V_PROGRESION_CARRILES);

		Q_ADAPTACION_TRAMO.Q_LISTA_CARRILES.P_INICIALIZAR_LISTA (V_LISTA_CARRILES_TRAMO_ACTUAL);

		Q_ADAPTACION_TRAMO.Q_LISTA_CARRILES.P_INICIALIZAR_LISTA (V_LISTA_CARRILES_TRAMO_SIGUIENTE);

		for I in 1 .. Q_RUTA.Q_LISTA_TRAMOS.F_CUANTOS_ELEMENTOS (V_RUTA) -1 loop

			-- Obtener los carriles que conectan al siguiente tramo
			Q_ADAPTACION_TRAMO.P_OBTENER_CARRILES_ENTRE_TRAMOS 
				(V_TRAMO_ID_1 => Q_TRAMO.F_OBTENER_ID (Q_RUTA.Q_LISTA_TRAMOS.F_DEVOLVER_ELEMENTO (V_POSICION => I,
														  V_LISTA => V_RUTA)),
				 V_TRAMO_ID_2 => Q_TRAMO.F_OBTENER_ID (Q_RUTA.Q_LISTA_TRAMOS.F_DEVOLVER_ELEMENTO (V_POSICION => I + 1,
														  V_LISTA => V_RUTA)),
				 V_LISTA_CARRILES_TRAMO_ACTUAL => V_LISTA_CARRILES_TRAMO_ACTUAL,
				 V_LISTA_CARRILES_TRAMO_SIGUIENTE => V_LISTA_CARRILES_TRAMO_SIGUIENTE);

		end loop;

	end P_GENERAR_PROGRESION_CARRILES;
	----------------------------------------------------------------------------------------------

	--------------------------------------------------------------------------------------------------------------
        function F_SON_ELEMENTOS_PROGRESION_CARRILES_OPTIMO_IGUALES
                (V_ELEMENTO_PROGRESION_CARRILES_OPTIMO_1 : in T_ELEMENTO_PROGRESION_CARRILES_OPTIMO;
                 V_ELEMENTO_PROGRESION_CARRILES_OPTIMO_2 : in T_ELEMENTO_PROGRESION_CARRILES_OPTIMO) return Boolean is

        begin

                return V_ELEMENTO_PROGRESION_CARRILES_OPTIMO_1.R_ID_TRAMO_ACTUAL = 
		       V_ELEMENTO_PROGRESION_CARRILES_OPTIMO_2.R_ID_TRAMO_ACTUAL;

        end F_SON_ELEMENTOS_PROGRESION_CARRILES_OPTIMO_IGUALES;
        -------------------------------------------------------

	----------------------------------------------------------------------------------------------------------------------------
        procedure P_CORREGIR_PROGRESION_CARRIL_OPTIMO (V_INDICE_TRAMO_A_CORREGIR : in Natural;
						       V_INDICE_TRAMO_LIMITE_CORRECCION : in Natural;
                                                       V_CARRIL_A_USAR : in Natural;
                                                       V_PROGRESION_CARRILES_OPTIMO_ACTUAL : in T_PROGRESION_CARRILES_OPTIMO;
						       V_PROGRESION_CARRILES_OPTIMO_CORREGIDA : out T_PROGRESION_CARRILES_OPTIMO) is

		V_ELEMENTO_PROGRESION_CARRILES_OPTIMO_AUX : T_ELEMENTO_PROGRESION_CARRILES_OPTIMO;

		V_TRAMO_ORIGEN_ID, V_TRAMO_DESTINO_ID, V_CARRIL_SIGUIENTE : Natural;

		-- Lista de carriles entre el tramo origen y destino en caso de que haya un cambio de carril.
                V_LISTA_CARRILES_ORIGEN, V_LISTA_CARRILES_DESTINO : Q_ADAPTACION_TRAMO.Q_LISTA_CARRILES.T_LISTA;

		V_CARRIL_AUX, V_DISTANCIA_AUX, V_CARRIL_MAS_CERCANO : Natural := 0;

		V_DISTANCIA_ENTRE_CARRILES : Natural := 1000;

		V_ELEMENTO_PROGRESION_CARRILES_OPTIMO : T_ELEMENTO_PROGRESION_CARRILES_OPTIMO;

	begin

		P_INICIALIZAR_LISTA (V_PROGRESION_CARRILES_OPTIMO_CORREGIDA);

		-- Hay que recorrer la lista actual de carril optimo y copiarla y pasarla a la corregida.
		-- Una vez que se alcance el tramo a corregir, se pasa a calcular los nuevos carriles hasta el tramo limite a corregir.
		for I in reverse 1 .. F_CUANTOS_ELEMENTOS (V_PROGRESION_CARRILES_OPTIMO_ACTUAL) loop

			if I > V_INDICE_TRAMO_A_CORREGIR then

				-- Simplemente añadir el elemento de la progresion actual a la corregida.
				P_INSERTAR_ELEMENTO (V_ELEMENTO => F_DEVOLVER_ELEMENTO (V_POSICION => I,
											V_LISTA => V_PROGRESION_CARRILES_OPTIMO_ACTUAL),
						     V_LISTA => V_PROGRESION_CARRILES_OPTIMO_CORREGIDA);

			elsif I = V_INDICE_TRAMO_A_CORREGIR then

				-- Se ha llegado al tramo a corregir. Establecer el carril y el tramo.
				V_ELEMENTO_PROGRESION_CARRILES_OPTIMO_AUX.R_ID_TRAMO_ACTUAL := 
					F_DEVOLVER_ELEMENTO (V_POSICION => I,
							     V_LISTA => V_PROGRESION_CARRILES_OPTIMO_ACTUAL).R_ID_TRAMO_ACTUAL;
				V_ELEMENTO_PROGRESION_CARRILES_OPTIMO_AUX.R_CARRIL := V_CARRIL_A_USAR;

				P_INSERTAR_ELEMENTO (V_ELEMENTO => V_ELEMENTO_PROGRESION_CARRILES_OPTIMO_AUX,
						     V_LISTA => V_PROGRESION_CARRILES_OPTIMO_CORREGIDA);

				-- Ahora hay que seguir corrigiendo los tramos anteriores a este hasta el limite. Suponiendo que no sea
				-- el ultimo tramo => I = 1
				-- Se trata de, a partir del tramo actual, el carril optimo actual y el carril anterior, obtener el carril
				-- optimo del tramo anterior.
				if I > 1 then

					-- Corregir la progresion desde el tramo I-1 (el I acaba de ser corregido) hasta el limite de 
					-- correccion.
					for J in reverse V_INDICE_TRAMO_LIMITE_CORRECCION .. I-1 loop

						V_TRAMO_ORIGEN_ID := 
							F_DEVOLVER_ELEMENTO 
								(V_POSICION => J,
								 V_LISTA => V_PROGRESION_CARRILES_OPTIMO_ACTUAL).R_ID_TRAMO_ACTUAL;

						V_TRAMO_DESTINO_ID :=
							F_DEVOLVER_ELEMENTO
                                                                (V_POSICION => J+1,
                                                                 V_LISTA => V_PROGRESION_CARRILES_OPTIMO_ACTUAL).R_ID_TRAMO_ACTUAL;

						V_CARRIL_SIGUIENTE := 
							F_DEVOLVER_ELEMENTO (V_POSICION => J+1,
									     V_LISTA => V_PROGRESION_CARRILES_OPTIMO_ACTUAL).R_CARRIL;

						begin
	
							V_ELEMENTO_PROGRESION_CARRILES_OPTIMO.R_ID_TRAMO_ACTUAL := V_TRAMO_ORIGEN_ID;

							-- Hay que buscar que carril del tramo I-1 que se conecta con el carril optimo del 
							-- tramo I.
							V_ELEMENTO_PROGRESION_CARRILES_OPTIMO.R_CARRIL := 
								Q_ADAPTACION_TRAMO.F_OBTENER_CARRIL_CONEXION 
									(V_TRAMO_ORIGEN_ID => V_TRAMO_ORIGEN_ID, 
								 	 V_TRAMO_DESTINO_ID => V_TRAMO_DESTINO_ID,
								 	 V_CARRIL_SIGUIENTE => V_CARRIL_SIGUIENTE);

						exception

							-- Esta excepcion salta cuando hay un cambio de carril en el tramo "origen". 
                                        		when Q_ADAPTACION_TRAMO.X_CONEXION_NO_ENCONTRADA =>

								-- Buscar los carriles que conecten el tramo destino con el tramo origen
                                                		Q_ADAPTACION_TRAMO.P_OBTENER_CARRILES_ENTRE_TRAMOS
                                                        		(V_TRAMO_ID_1 => V_TRAMO_ORIGEN_ID,
                                                         		 V_TRAMO_ID_2 => V_TRAMO_DESTINO_ID,
                                                         		 V_LISTA_CARRILES_TRAMO_ACTUAL => V_LISTA_CARRILES_ORIGEN,
                                                         		 V_LISTA_CARRILES_TRAMO_SIGUIENTE => V_LISTA_CARRILES_DESTINO);

								-- El cambio es en el tramo origen.
                                                		-- Hay que recorrer la lista de carriles origen y buscar aquel que este 
								-- mas cerca del "carril siguiente". Si se encuentra un carril a una 
								-- "distancia" 1 ese es el adecuado.
								for K in 1 .. Q_ADAPTACION_TRAMO.Q_LISTA_CARRILES.F_CUANTOS_ELEMENTOS
                                                                		(V_LISTA_CARRILES_ORIGEN) loop

                                                        		V_CARRIL_AUX :=
                                                                		Q_ADAPTACION_TRAMO.Q_LISTA_CARRILES.F_DEVOLVER_ELEMENTO
                                                                        		(V_POSICION => K,
                                                                         		 V_LISTA => V_LISTA_CARRILES_ORIGEN);

                                                        		V_DISTANCIA_AUX := abs(V_CARRIL_SIGUIENTE - V_CARRIL_AUX);

                                                        		if V_DISTANCIA_AUX = 1 then

                                                                		V_CARRIL_MAS_CERCANO := V_CARRIL_AUX;

                                                                		exit;

                                                        		elsif V_DISTANCIA_AUX < V_DISTANCIA_ENTRE_CARRILES then

                                                                		V_DISTANCIA_ENTRE_CARRILES := V_DISTANCIA_AUX;

                                                                		V_CARRIL_MAS_CERCANO := V_CARRIL_AUX;

                                                        		end if;

                                                		end loop;

                                                		V_ELEMENTO_PROGRESION_CARRILES_OPTIMO.R_CARRIL := V_CARRIL_MAS_CERCANO;

						end;

						P_INSERTAR_ELEMENTO (V_ELEMENTO => V_ELEMENTO_PROGRESION_CARRILES_OPTIMO,
								     V_LISTA => V_PROGRESION_CARRILES_OPTIMO_CORREGIDA);

					end loop;

					-- Aqui ya se tiene toda la progresion de carril optimo corregida.
					exit;
				
				end if;

			end if;

		end loop;

	end P_CORREGIR_PROGRESION_CARRIL_OPTIMO;
	----------------------------------------

	---------------------------------------------------------------------------------------------------------
	procedure P_GENERAR_PROGRESION_CARRILES_OPTIMO (V_RUTA : in Q_RUTA.T_RUTA;
							V_PROGRESION_CARRILES_OPTIMO : out T_PROGRESION_CARRILES_OPTIMO;
							V_LISTA_TRAMOS_GLORIETA : out T_LISTA_TRAMOS_GLORIETA) is

		V_ELEMENTO_PROGRESION_CARRILES_OPTIMO : T_ELEMENTO_PROGRESION_CARRILES_OPTIMO;

		V_TRAMO_ORIGEN_ID, V_TRAMO_DESTINO_ID : Natural := 0;

		-- Lista de carriles entre el tramo origen y destino en caso de que haya un cambio de carril.
		V_LISTA_CARRILES_ORIGEN, V_LISTA_CARRILES_DESTINO : Q_ADAPTACION_TRAMO.Q_LISTA_CARRILES.T_LISTA;

		V_CARRIL_AUX, V_CARRIL_MAS_CERCANO : Natural := 0;

		V_DISTANCIA_ENTRE_CARRILES  : Natural := 1000;
		
		V_DISTANCIA_AUX : Natural := 0;

		--
		V_TRAMO_GLORIETA_ID, V_POSICION_TRAMO_ENTRADA_A_GLORIETA, V_POSICION_TRAMO_SALIDA_DE_GLORIETA : Natural := 0;

		-- Variable para contar la salida a tomar al entrar en una rotonda
                V_SALIDAS_NO_TOMADAS : Natural := 0;

		-- Variables auxiliares para guardar la lista de progresion de carriles optima al pasar por una glorieta.
                V_ELEMENTO_PROGRESION_CARRILES_OPTIMO_AUX : T_ELEMENTO_PROGRESION_CARRILES_OPTIMO;

                V_PROGRESION_CARRILES_OPTIMO_AUX : T_PROGRESION_CARRILES_OPTIMO;

		-- Variable booleana para saber si hay que rectificar carriles al circular por el interior de una rotonda.
		V_CORRECCION_POR_GLORIETA : Boolean := False;

		-- Variable para guardar el indice del tramo dentro de la progresion de carril optimo que ya no hcae falta corregir.
		-- Inicializado a 1. 
		V_INDICE_TRAMO_LIMITE_CORRECCION : Natural := 1;

		-- Variable para saber si se ha llamado al procedimiento de correccion de la progresion de carril optimo o no.
		V_PROGRESION_CORREGIDA : Boolean := False;

	begin

		P_INICIALIZAR_LISTA (V_PROGRESION_CARRILES_OPTIMO);

		P_INICIALIZAR_LISTA (V_LISTA_TRAMOS_GLORIETA);

		-- Recorremos la ruta de atras hacia adelante. El primer elemento será el id del tramo destino y el carril 1.
		-- El trayecto siempre acabará en el carril 1.
		V_ELEMENTO_PROGRESION_CARRILES_OPTIMO.R_ID_TRAMO_ACTUAL := 
			Q_TRAMO.F_OBTENER_ID 
				(Q_RUTA.Q_LISTA_TRAMOS.F_DEVOLVER_ELEMENTO 
					(V_POSICION => Q_RUTA.Q_LISTA_TRAMOS.F_CUANTOS_ELEMENTOS (V_RUTA),
				 	 V_LISTA => V_RUTA));

		V_ELEMENTO_PROGRESION_CARRILES_OPTIMO.R_CARRIL := 1;

		-- Insertar elemento en la lista.
		P_INSERTAR_ELEMENTO (V_ELEMENTO => V_ELEMENTO_PROGRESION_CARRILES_OPTIMO,
				     V_LISTA => V_PROGRESION_CARRILES_OPTIMO);

		-- Recorrer la ruta de manera inversa desde el penultimo tramo hasta el primero.
		for I in reverse 1 .. Q_RUTA.Q_LISTA_TRAMOS.F_CUANTOS_ELEMENTOS (V_RUTA) -1 loop

			V_TRAMO_ORIGEN_ID := Q_TRAMO.F_OBTENER_ID (Q_RUTA.Q_LISTA_TRAMOS.F_DEVOLVER_ELEMENTO (V_POSICION => I,
											                      V_LISTA => V_RUTA));

			V_TRAMO_DESTINO_ID := Q_TRAMO.F_OBTENER_ID (Q_RUTA.Q_LISTA_TRAMOS.F_DEVOLVER_ELEMENTO (V_POSICION => I + 1,
                                                                                                               V_LISTA => V_RUTA));

			-- Hay que buscar que carril del tramo I se conecta con el carril optimo del tramo I + 1.
			V_ELEMENTO_PROGRESION_CARRILES_OPTIMO.R_ID_TRAMO_ACTUAL := V_TRAMO_ORIGEN_ID;

			-- Loop necesario para cambiar de carril si fuera necesario
			loop
			
				begin

				V_ELEMENTO_PROGRESION_CARRILES_OPTIMO.R_CARRIL := 
					Q_ADAPTACION_TRAMO.F_OBTENER_CARRIL_CONEXION 
						(V_TRAMO_ORIGEN_ID => V_TRAMO_ORIGEN_ID,
					 	 V_TRAMO_DESTINO_ID => V_TRAMO_DESTINO_ID,
					 	 V_CARRIL_SIGUIENTE => V_ELEMENTO_PROGRESION_CARRILES_OPTIMO.R_CARRIL);
	
				exit;

				exception
				
					-- Esta excepcion salta cuando hay un cambio de carril en el tramo "siguiente". 
					when Q_ADAPTACION_TRAMO.X_CONEXION_NO_ENCONTRADA =>

						-- Buscar los carriles que conecten el tramo origen con el tramo destino
						Q_ADAPTACION_TRAMO.P_OBTENER_CARRILES_ENTRE_TRAMOS 
							(V_TRAMO_ID_1 => V_TRAMO_ORIGEN_ID,
							 V_TRAMO_ID_2 => V_TRAMO_DESTINO_ID,
							 V_LISTA_CARRILES_TRAMO_ACTUAL => V_LISTA_CARRILES_ORIGEN,
							 V_LISTA_CARRILES_TRAMO_SIGUIENTE => V_LISTA_CARRILES_DESTINO);

						-- El cambio es en el tramo destino.
						-- Hay que recorrer la lista de carriles destino y buscar aquel que este mas cerca del 
						-- "carril siguiente". Si se encuentra un carril a una "distancia" 1 ese es el adecuado.
						for J in 1 .. Q_ADAPTACION_TRAMO.Q_LISTA_CARRILES.F_CUANTOS_ELEMENTOS 
								(V_LISTA_CARRILES_DESTINO) loop

							V_CARRIL_AUX := 
								Q_ADAPTACION_TRAMO.Q_LISTA_CARRILES.F_DEVOLVER_ELEMENTO 
									(V_POSICION => J,
									 V_LISTA => V_LISTA_CARRILES_DESTINO);

							V_DISTANCIA_AUX := 
								abs(V_ELEMENTO_PROGRESION_CARRILES_OPTIMO.R_CARRIL - V_CARRIL_AUX);

							if V_DISTANCIA_AUX = 1 then

								V_CARRIL_MAS_CERCANO := V_CARRIL_AUX;

								exit;

							elsif V_DISTANCIA_AUX < V_DISTANCIA_ENTRE_CARRILES then

								V_DISTANCIA_ENTRE_CARRILES := V_DISTANCIA_AUX;

								V_CARRIL_MAS_CERCANO := V_CARRIL_AUX;
						
							end if;
	
						end loop;

						V_ELEMENTO_PROGRESION_CARRILES_OPTIMO.R_CARRIL := V_CARRIL_MAS_CERCANO;

				end;

			end loop;

			P_INSERTAR_ELEMENTO (V_ELEMENTO => V_ELEMENTO_PROGRESION_CARRILES_OPTIMO,
					     V_LISTA => V_PROGRESION_CARRILES_OPTIMO);

		end loop;

		--
		-- Comprobar las entradas a las rotondas.
                -- Comprobar las conexiones dadas entre tramos por la progresion de carriles optimo y ver si alguna conexion es la entrada
                -- a una glorieta.
                for I in 1 .. F_CUANTOS_ELEMENTOS (V_PROGRESION_CARRILES_OPTIMO) - 1 loop

			if Q_ADAPTACION_TRAMO.F_ES_ENTRADA_A_GLORIETA 
				(V_TRAMO_ORIGEN_ID => F_DEVOLVER_ELEMENTO (V_POSICION => I,
                                                                           V_LISTA => V_PROGRESION_CARRILES_OPTIMO).R_ID_TRAMO_ACTUAL,
                                 V_TRAMO_SIGUIENTE_ID => F_DEVOLVER_ELEMENTO (V_POSICION => I + 1,
                                                                              V_LISTA => V_PROGRESION_CARRILES_OPTIMO).R_ID_TRAMO_ACTUAL,
                                 V_CARRIL_ORIGEN => F_DEVOLVER_ELEMENTO (V_POSICION => I,
                                                                         V_LISTA => V_PROGRESION_CARRILES_OPTIMO).R_CARRIL,
                                 V_CARRIL_SIGUIENTE => F_DEVOLVER_ELEMENTO (V_POSICION => I + 1,
                                                                            V_LISTA => V_PROGRESION_CARRILES_OPTIMO).R_CARRIL) then

				V_TRAMO_GLORIETA_ID := F_DEVOLVER_ELEMENTO (V_POSICION => I + 1,
                                                                     	    V_LISTA => V_PROGRESION_CARRILES_OPTIMO).R_ID_TRAMO_ACTUAL;

				V_POSICION_TRAMO_ENTRADA_A_GLORIETA := I + 1;

				-- Comprobar después de la entrada de la glorieta cual es la salida
                                for J in I+1 .. F_CUANTOS_ELEMENTOS (V_PROGRESION_CARRILES_OPTIMO) - 1 loop

                                	if Q_ADAPTACION_TRAMO.F_ES_SALIDA_DE_GLORIETA 
						(V_TRAMO_ORIGEN_ID => 
							F_DEVOLVER_ELEMENTO (V_POSICION => J,
                                                                             V_LISTA => V_PROGRESION_CARRILES_OPTIMO).R_ID_TRAMO_ACTUAL,
                                                 V_TRAMO_SIGUIENTE_ID => 
							F_DEVOLVER_ELEMENTO (V_POSICION => J + 1,
                                                                             V_LISTA => V_PROGRESION_CARRILES_OPTIMO).R_ID_TRAMO_ACTUAL,
                                                 V_CARRIL_ORIGEN => F_DEVOLVER_ELEMENTO (V_POSICION => J,
                                                                                         V_LISTA => V_PROGRESION_CARRILES_OPTIMO).R_CARRIL,
                                                 V_CARRIL_SIGUIENTE => 
							F_DEVOLVER_ELEMENTO (V_POSICION => J + 1,
                                                                             V_LISTA => V_PROGRESION_CARRILES_OPTIMO).R_CARRIL) then

                           			V_POSICION_TRAMO_SALIDA_DE_GLORIETA := J;

                                                -- Una vez encontrada una salida dejamos de buscar, para dar paso a buscar la siguiente
                                                -- glorieta.
                                                exit;

                                        end if;

                                        -- Salidas de la glorieta que no tomamos.
                                        if Q_ADAPTACION_TRAMO.F_ES_TRAMO_SALIDA_DE_GLORIETA 
						(F_DEVOLVER_ELEMENTO (V_POSICION => J,
                                                                      V_LISTA => V_PROGRESION_CARRILES_OPTIMO).R_ID_TRAMO_ACTUAL) then

                                        	V_SALIDAS_NO_TOMADAS := V_SALIDAS_NO_TOMADAS + 1;

                                        end if;

					P_INSERTAR_ELEMENTO 
						(V_ELEMENTO => 
							F_DEVOLVER_ELEMENTO (V_POSICION => J+1,
								  	     V_LISTA => V_PROGRESION_CARRILES_OPTIMO).R_ID_TRAMO_ACTUAL,
						 V_LISTA => V_LISTA_TRAMOS_GLORIETA);

                                end loop;

				-- Ya estamos fuera de la glorieta.
                                -- Si la salida (= salidas_no_tomadas) es 0 o 1 => No hay que cambiar el carril optimo
                                -- Si la salida es la 2 o 3 => Habra que entrar por el carril 2, y en cuanto se pase la ultima salida que no
                                -- sea la nuestra pasar al carril derecho.
                                if V_SALIDAS_NO_TOMADAS >= 2 and V_SALIDAS_NO_TOMADAS < 4 then

					-- Entre el tramo siguiente al de entrada a la rotonda y el anterior al de salida circular por el 
                                        -- carril 2 si existe. Si no existe no hacer nada.
                                        if Q_ADAPTACION_TRAMO.F_NUMERO_CARRILES_TRAMO_GLORIETA (V_TRAMO_GLORIETA_ID) >= 2 then

						-- Circular por el carril 2 de la glorieta.
                                                P_INICIALIZAR_LISTA (V_PROGRESION_CARRILES_OPTIMO_AUX);

                                                for K in reverse 1 .. F_CUANTOS_ELEMENTOS (V_PROGRESION_CARRILES_OPTIMO) loop

							-- Que hacemos con el tramo de entrada a la rotonda?
							-- Esta en la posicion V_POSICION_TRAMO_ENTRADA_A_GLORIETA - 1.
							-- Si tiene mas de un carril deberiamos entrar a la rotonda por carril 2.
							-- Si el tramo se ensancha se pone el carril ideal para ese tramo al 2 y punto.
							-- Si el tramo no se ensancha y tiene mas de un carril habra que establecer el 
							-- 	carril ideal a 2 para el tramo de entrada y corregir desde ahi hacia atras.
                                                        if K <= V_POSICION_TRAMO_SALIDA_DE_GLORIETA -1 and
                                                           K >= V_POSICION_TRAMO_ENTRADA_A_GLORIETA then

                                                                V_ELEMENTO_PROGRESION_CARRILES_OPTIMO_AUX.R_ID_TRAMO_ACTUAL :=
                                                                        F_DEVOLVER_ELEMENTO
                                                                                (V_POSICION => K,
                                                                                 V_LISTA => V_PROGRESION_CARRILES_OPTIMO).R_ID_TRAMO_ACTUAL;

                                                                V_ELEMENTO_PROGRESION_CARRILES_OPTIMO_AUX.R_CARRIL := 2;

                                                                P_INSERTAR_ELEMENTO
                                                                        (V_ELEMENTO => V_ELEMENTO_PROGRESION_CARRILES_OPTIMO_AUX,
                                                                         V_LISTA => V_PROGRESION_CARRILES_OPTIMO_AUX);

								V_CORRECCION_POR_GLORIETA := True;

							-- Cambiar carril del tramo de entrada a la glorieta si es posible.
							elsif K = V_POSICION_TRAMO_ENTRADA_A_GLORIETA -	1 and
							      Q_ADAPTACION_TRAMO.F_NUMERO_CARRILES_ULTIMO_SEGMENTO
                                                 		(F_DEVOLVER_ELEMENTO
                                                              		(V_POSICION => K,
                                                                         V_LISTA => V_PROGRESION_CARRILES_OPTIMO).R_ID_TRAMO_ACTUAL) > 1 
							then

								if Q_ADAPTACION_TRAMO.F_SE_ENSANCHA_TRAMO 
									(F_DEVOLVER_ELEMENTO 
										(V_POSICION => K,
										 V_LISTA => V_PROGRESION_CARRILES_OPTIMO).R_ID_TRAMO_ACTUAL)
								then

									V_ELEMENTO_PROGRESION_CARRILES_OPTIMO_AUX.R_ID_TRAMO_ACTUAL :=
                                                                        	F_DEVOLVER_ELEMENTO
                                                                                	(V_POSICION => K,
                                                                                 	 V_LISTA => 
												V_PROGRESION_CARRILES_OPTIMO).
													R_ID_TRAMO_ACTUAL;

                                                                	V_ELEMENTO_PROGRESION_CARRILES_OPTIMO_AUX.R_CARRIL := 2;

                                                                	P_INSERTAR_ELEMENTO
                                                                        	(V_ELEMENTO => V_ELEMENTO_PROGRESION_CARRILES_OPTIMO_AUX,
                                                                         	 V_LISTA => V_PROGRESION_CARRILES_OPTIMO_AUX);

                                                                	V_CORRECCION_POR_GLORIETA := False;

								else

									-- Si entramos aqui es para corregir la progresion de carriles 
									-- optimo.
									-- La entrada a esta rotonda (tramo K) 
									-- habra que hacerla por el carril 2.
									-- Hay que corregir la progresion del carril optimo del tramo K al 1
									-- Y dejando claro que si hubiera una rotonda más adelante habría
									-- que corregir hasta el tramo salida de esta rotonda, lo anterior
									-- ya sería optimo.
 
									-- Copiar desde K-1 hasta 1 la progresion optima en progresion 
									-- optima aux. Asi ya tendriamos toda la progresion optima.

									for L in reverse 1 .. K loop

										P_INSERTAR_ELEMENTO
                                                                			(V_ELEMENTO =>
                                                                        			F_DEVOLVER_ELEMENTO 
													(V_POSICION => L,
                                                                                         	         V_LISTA => 
													 V_PROGRESION_CARRILES_OPTIMO),
                                                                 			 V_LISTA => V_PROGRESION_CARRILES_OPTIMO_AUX);

									end loop;

									-- Inicializar la progresion de carril optimo.
									P_INICIALIZAR_LISTA (V_PROGRESION_CARRILES_OPTIMO);

									P_CORREGIR_PROGRESION_CARRIL_OPTIMO 
										(V_INDICE_TRAMO_A_CORREGIR => K,
										 V_INDICE_TRAMO_LIMITE_CORRECCION => 
											V_INDICE_TRAMO_LIMITE_CORRECCION,
										 V_CARRIL_A_USAR => 2,
										 V_PROGRESION_CARRILES_OPTIMO_ACTUAL =>
											V_PROGRESION_CARRILES_OPTIMO_AUX,
										 V_PROGRESION_CARRILES_OPTIMO_CORREGIDA => 
											V_PROGRESION_CARRILES_OPTIMO);

									V_INDICE_TRAMO_LIMITE_CORRECCION := 
										V_POSICION_TRAMO_SALIDA_DE_GLORIETA;

									V_PROGRESION_CORREGIDA := True;

									-- Ya tenemos la progresion optima corregida por esta rotonda 
									-- (dentro y antes de entrar, hasta el principio de la progresion).
									-- Por decirlo asi, esta rotonda esta terminada.
									exit;
														
								end if;

                                                        else

                                                                P_INSERTAR_ELEMENTO
                                                                        (V_ELEMENTO =>
                                                                                F_DEVOLVER_ELEMENTO
                                                                                        (V_POSICION => K,
                                                                                         V_LISTA => V_PROGRESION_CARRILES_OPTIMO),
                                                                 	 V_LISTA => V_PROGRESION_CARRILES_OPTIMO_AUX);

                                                        end if;

                                                end loop;

						if not V_PROGRESION_CORREGIDA then

							P_INICIALIZAR_LISTA (V_PROGRESION_CARRILES_OPTIMO);

                                                	for K in reverse 1 .. F_CUANTOS_ELEMENTOS (V_PROGRESION_CARRILES_OPTIMO_AUX) loop

                                                        	P_INSERTAR_ELEMENTO
                                                                	(V_ELEMENTO =>
                                                                        	F_DEVOLVER_ELEMENTO 
											(V_POSICION => K,
                                                                                	 V_LISTA => V_PROGRESION_CARRILES_OPTIMO_AUX),
                                                                 	 V_LISTA => V_PROGRESION_CARRILES_OPTIMO);

                                                	end loop;
	
						end if;

                                        end if;

				elsif V_SALIDAS_NO_TOMADAS >= 4 then

					-- Entre el tramo siguiente al de entrada a la rotonda y el anterior al de salida circular por el 
                                        -- carril 3 si existe. Si no existe, mirar si tiene al menos 2 carriles 
                                        if Q_ADAPTACION_TRAMO.F_NUMERO_CARRILES_TRAMO_GLORIETA (V_TRAMO_GLORIETA_ID) >= 3 then

						-- Circular por el carril 3 de la glorieta.
                                                P_INICIALIZAR_LISTA (V_PROGRESION_CARRILES_OPTIMO_AUX);

						for K in reverse 1 .. F_CUANTOS_ELEMENTOS (V_PROGRESION_CARRILES_OPTIMO) loop

							if K <= V_POSICION_TRAMO_SALIDA_DE_GLORIETA -1 and
                                                           K >= V_POSICION_TRAMO_ENTRADA_A_GLORIETA then

								V_ELEMENTO_PROGRESION_CARRILES_OPTIMO_AUX.R_ID_TRAMO_ACTUAL :=
                                                                        F_DEVOLVER_ELEMENTO
                                                                                (V_POSICION => K,
                                                                                 V_LISTA => V_PROGRESION_CARRILES_OPTIMO).R_ID_TRAMO_ACTUAL;

								-- Hay que abandonar el carril 3 poco a poco => habra tramos dentro de la
								-- rotonda por los que habra que circular por el carril 2. Se puede asumir
								-- que por cada 2 tramos habra una salida. La salida anterior a la nuestra
								-- el vehiculo deberia circular por el carril 2 y no por el 3.
								-- Recordar que la posicion de salida de glorieta es la ultima dentro de la
								-- rotonda.
								if K = V_POSICION_TRAMO_SALIDA_DE_GLORIETA - 1 or 
								   K = V_POSICION_TRAMO_SALIDA_DE_GLORIETA - 2 then

									V_ELEMENTO_PROGRESION_CARRILES_OPTIMO_AUX.R_CARRIL := 2;

								else

                                                                	V_ELEMENTO_PROGRESION_CARRILES_OPTIMO_AUX.R_CARRIL := 3;

								end if;

                                                                P_INSERTAR_ELEMENTO
                                                                        (V_ELEMENTO => V_ELEMENTO_PROGRESION_CARRILES_OPTIMO_AUX,
                                                                         V_LISTA => V_PROGRESION_CARRILES_OPTIMO_AUX);

                                                                V_CORRECCION_POR_GLORIETA := True;

							elsif K = V_POSICION_TRAMO_ENTRADA_A_GLORIETA - 1 and
                                                              Q_ADAPTACION_TRAMO.F_NUMERO_CARRILES_ULTIMO_SEGMENTO
                                                                (F_DEVOLVER_ELEMENTO
                                                                        (V_POSICION => K,
                                                                         V_LISTA => V_PROGRESION_CARRILES_OPTIMO).R_ID_TRAMO_ACTUAL) > 1 
							then

								if Q_ADAPTACION_TRAMO.F_SE_ENSANCHA_TRAMO
                                                                        (F_DEVOLVER_ELEMENTO
                                                                                (V_POSICION => K,
                                                                                 V_LISTA => V_PROGRESION_CARRILES_OPTIMO).R_ID_TRAMO_ACTUAL)
								then

									V_ELEMENTO_PROGRESION_CARRILES_OPTIMO_AUX.R_ID_TRAMO_ACTUAL := 
                               							F_DEVOLVER_ELEMENTO 
											(V_POSICION => K,
                                                                                         V_LISTA => 
												V_PROGRESION_CARRILES_OPTIMO).
													R_ID_TRAMO_ACTUAL;
			
									-- Si hay al menos 3 carriles tomar el carril 3, si no el 2.
									if Q_ADAPTACION_TRAMO.F_NUMERO_CARRILES_ULTIMO_SEGMENTO
                                                                		(F_DEVOLVER_ELEMENTO
                                                                        		(V_POSICION => K,
                                                                         		 V_LISTA => 
												V_PROGRESION_CARRILES_OPTIMO).
													R_ID_TRAMO_ACTUAL) > 2 then

                                                                        	V_ELEMENTO_PROGRESION_CARRILES_OPTIMO_AUX.R_CARRIL := 3;

									else

										V_ELEMENTO_PROGRESION_CARRILES_OPTIMO_AUX.R_CARRIL := 2;
	
									end if;

                                                                        P_INSERTAR_ELEMENTO
                                                                                (V_ELEMENTO => V_ELEMENTO_PROGRESION_CARRILES_OPTIMO_AUX,
                                                                                 V_LISTA => V_PROGRESION_CARRILES_OPTIMO_AUX);

                                                                        V_CORRECCION_POR_GLORIETA := False;

								else

									-- El tramo no se ensancha. Hay que corregir el tramo de entrada.

									for L in reverse 1 .. K loop

                                                                                P_INSERTAR_ELEMENTO
                                                                                        (V_ELEMENTO =>
                                                                                                F_DEVOLVER_ELEMENTO
                                                                                                        (V_POSICION => L,
                                                                                                         V_LISTA =>
                                                                                                         V_PROGRESION_CARRILES_OPTIMO),
                                                                                         V_LISTA => V_PROGRESION_CARRILES_OPTIMO_AUX);

                                                                        end loop;

									-- Inicializar la progresion de carril optimo.
                                                                        P_INICIALIZAR_LISTA (V_PROGRESION_CARRILES_OPTIMO);

									-- Comprobar si el tramo de entrada a la rotonda tiene 3 carriles
									if Q_ADAPTACION_TRAMO.F_NUMERO_CARRILES_ULTIMO_SEGMENTO
                                                                                (F_DEVOLVER_ELEMENTO
                                                                                        (V_POSICION => K,
                                                                                         V_LISTA =>
                                                                                                V_PROGRESION_CARRILES_OPTIMO).
                                                                                                        R_ID_TRAMO_ACTUAL) = 2 then

										-- El ultimo segmento del tramo que se conecta con la 
										-- rotonda tiene 2 carriles
										P_CORREGIR_PROGRESION_CARRIL_OPTIMO
                                                                                (V_INDICE_TRAMO_A_CORREGIR => K,
                                                                                 V_INDICE_TRAMO_LIMITE_CORRECCION =>
                                                                                        V_INDICE_TRAMO_LIMITE_CORRECCION,
                                                                                 V_CARRIL_A_USAR => 2,
                                                                                 V_PROGRESION_CARRILES_OPTIMO_ACTUAL =>
                                                                                        V_PROGRESION_CARRILES_OPTIMO_AUX,
                                                                                 V_PROGRESION_CARRILES_OPTIMO_CORREGIDA =>
                                                                                        V_PROGRESION_CARRILES_OPTIMO);

									else

										-- El tramo se conecta a la rotonda con 3 carriles
										P_CORREGIR_PROGRESION_CARRIL_OPTIMO
                                                                                (V_INDICE_TRAMO_A_CORREGIR => K,
                                                                                 V_INDICE_TRAMO_LIMITE_CORRECCION =>
                                                                                        V_INDICE_TRAMO_LIMITE_CORRECCION,
                                                                                 V_CARRIL_A_USAR => 3,
                                                                                 V_PROGRESION_CARRILES_OPTIMO_ACTUAL =>
                                                                                        V_PROGRESION_CARRILES_OPTIMO_AUX,
                                                                                 V_PROGRESION_CARRILES_OPTIMO_CORREGIDA =>
                                                                                        V_PROGRESION_CARRILES_OPTIMO);

									end if;

									V_INDICE_TRAMO_LIMITE_CORRECCION := 
										V_POSICION_TRAMO_SALIDA_DE_GLORIETA;

                                                                        V_PROGRESION_CORREGIDA := True;

                                                                        -- Ya tenemos la progresion optima corregida por esta rotonda 
                                                                        -- (dentro y antes de entrar, hasta el principio de la progresion).
                                                                        -- Por decirlo asi, esta rotonda esta terminada.
                                                                        exit;

								end if;

							else

                                                                P_INSERTAR_ELEMENTO
                                                                        (V_ELEMENTO =>
                                                                                F_DEVOLVER_ELEMENTO
                                                                                        (V_POSICION => K,
                                                                                         V_LISTA => V_PROGRESION_CARRILES_OPTIMO),
                                                                 	 V_LISTA => V_PROGRESION_CARRILES_OPTIMO_AUX);

                                                        end if;

						end loop;

						if not V_PROGRESION_CORREGIDA then

                                                        P_INICIALIZAR_LISTA (V_PROGRESION_CARRILES_OPTIMO);

                                                        for K in reverse 1 .. F_CUANTOS_ELEMENTOS (V_PROGRESION_CARRILES_OPTIMO_AUX) loop

                                                                P_INSERTAR_ELEMENTO
                                                                        (V_ELEMENTO =>
                                                                                F_DEVOLVER_ELEMENTO
                                                                                        (V_POSICION => K,
                                                                                         V_LISTA => V_PROGRESION_CARRILES_OPTIMO_AUX),
                                                                         V_LISTA => V_PROGRESION_CARRILES_OPTIMO);

                                                        end loop;

                                                end if;

					-- Si no tiene tres carriles quiza tenga 2. Entonces circular por el carril 2. Si solo tiene un 
					-- carril no hacer nada.
					elsif Q_ADAPTACION_TRAMO.F_NUMERO_CARRILES_TRAMO_GLORIETA (V_TRAMO_GLORIETA_ID) = 2 then

						Ada.Text_Io.Put_Line 
							("No hay 3 carriles, pero hay 2, repetir codigo para circular por carril 2");

					end if;

					V_CORRECCION_POR_GLORIETA := True;

				end if;

			end if;

			-- Reiniciar el contador de salidas por si el en la progresion hubiera otra glorieta mas adelante.
			-- Poner la progresion corregida a false por si hiciera falta otra correccion mas adelante por otra rotonda.
                        V_SALIDAS_NO_TOMADAS := 0;
			V_PROGRESION_CORREGIDA := False;

		end loop;

		-- Aqui ya tengo: Los carriles optimos para cada tramo y los carriles optimos de las glorietas si las hubiera.
		if V_CORRECCION_POR_GLORIETA then
		
			null;

		end if;

	end P_GENERAR_PROGRESION_CARRILES_OPTIMO;
	-------------------------------------------------------------------------------------------------------------------

	-------------------------------------------------------------------------------------------------------------------
	function F_OBTENER_CARRIL_OPTIMO (V_TRAMO_ID : in Natural;
					  V_PROGRESION_CARRILES_OPTIMO : in T_PROGRESION_CARRILES_OPTIMO) return Natural is

		V_ELEMENTO_PROGRESION_CARRILES_OPTIMO_AUX : T_ELEMENTO_PROGRESION_CARRILES_OPTIMO;

	begin

		V_ELEMENTO_PROGRESION_CARRILES_OPTIMO_AUX.R_ID_TRAMO_ACTUAL := V_TRAMO_ID;

		V_ELEMENTO_PROGRESION_CARRILES_OPTIMO_AUX := 
			F_ENCONTRAR_ELEMENTO (V_ELEMENTO => V_ELEMENTO_PROGRESION_CARRILES_OPTIMO_AUX,
					      V_LISTA => V_PROGRESION_CARRILES_OPTIMO);

		return V_ELEMENTO_PROGRESION_CARRILES_OPTIMO_AUX.R_CARRIL;

	end F_OBTENER_CARRIL_OPTIMO;
	-------------------------------------------------------------------------------------------------------------------

	--------------------------------------------------------------------------------------------------------
	function F_ES_TRAMO_DE_GLORIETA (V_TRAMO_ID : in Natural;
					 V_LISTA_TRAMOS_GLORIETA : in T_LISTA_TRAMOS_GLORIETA) return Boolean is

	begin

		return F_ESTA_ELEMENTO_EN_LISTA (V_ELEMENTO => V_TRAMO_ID,
						 V_LISTA => V_LISTA_TRAMOS_GLORIETA);

	end F_ES_TRAMO_DE_GLORIETA;
	--------------------------------------------------------------------------------------------------------

end Q_PROGRESION;
--------------------------------------------------------------------------------------------------------------------------------------------
