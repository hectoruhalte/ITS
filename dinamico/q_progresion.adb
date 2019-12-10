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

package body Q_PROGRESION is

	--------------------------------------------------------------------------------
	function "=" (V_ELEMENTO_PROGRESION_1 : T_ELEMENTO_PROGRESION;
		      V_ELEMENTO_PROGRESION_2 : T_ELEMENTO_PROGRESION) return Boolean is

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

	----------------------------------------------------------------------------------------
	-- Funcion para obtener una progresion inicial.
	-- Recorrer la ruta y por cada segmento y conexion, incluir un punto en la progresion.
	----------------------------------------------------------------------------------------
	function F_GENERAR_ENVELOPE_ESTATICO (V_POSICION_INICIAL : in Q_TIPOS_BASICOS.T_POSICION_UTM;
					      V_POSICION_FINAL : in Q_TIPOS_BASICOS.T_POSICION_UTM;
					      V_RUTA : in Q_RUTA.T_RUTA) return T_PROGRESION is

		V_PROGRESION : T_PROGRESION;

		V_POSICION_AUX : Q_TIPOS_BASICOS.T_POSICION_UTM := V_POSICION_INICIAL;

		V_POSICION_TRAMO_ACTUAL : Natural := 1;

		V_TRAMO_ACTUAL : Q_TRAMO.T_TRAMO;

		V_SEGMENTO_INICIAL, V_SEGMENTO_FINAL : Q_SEGMENTO.T_SEGMENTO;

		V_POSICION_SEGMENTO, V_POSICION_SEGMENTO_FINAL : Natural := 0;

		V_ELEMENTO_PROGRESION : T_ELEMENTO_PROGRESION;

		V_RESTRICCION : Q_RESTRICCION.T_RESTRICCION;

	begin

		-- Inicializar progresion.
		P_INICIALIZAR_LISTA (V_PROGRESION);

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

							-- La velocidad maxima sera la del siguiente tramo.
							Q_RESTRICCION.P_PONER_RESTRICCION 
								(V_VELOCIDAD => 
									Q_TRAMO.F_OBTENER_VELOCIDAD_MAXIMA 
										(Q_RUTA.Q_LISTA_TRAMOS.F_DEVOLVER_ELEMENTO 
											(V_POSICION => V_POSICION_TRAMO_ACTUAL + 1,
											 V_LISTA => V_RUTA)),
								 V_SENAL => Q_RESTRICCION.E_NULA,
								 V_RESTRICCION => V_RESTRICCION);

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

                                                        -- La velocidad maxima sera la del siguiente tramo.
                                                        Q_RESTRICCION.P_PONER_RESTRICCION
                                                                (V_VELOCIDAD =>
                                                                        Q_TRAMO.F_OBTENER_VELOCIDAD_MAXIMA
                                                                                (Q_RUTA.Q_LISTA_TRAMOS.F_DEVOLVER_ELEMENTO
                                                                                        (V_POSICION => V_POSICION_TRAMO_ACTUAL + 1,
                                                                                         V_LISTA => V_RUTA)),
                                                                 V_SENAL => Q_RESTRICCION.E_NULA,
                                                                 V_RESTRICCION => V_RESTRICCION);

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

		return V_PROGRESION;

	end F_GENERAR_ENVELOPE_ESTATICO;
	--------------------------------

	------------------------------------------------------------------------------------
	-- Se calcula la velocidad de frenada en funcion de la posicion: v = (I-1)*9
	-- Cuando esta velocidad de frenada sea menor, entonces se usara esa velocidad en
	-- el elemento de la progresion, si es mayor, se usara el elemento tal cual venga
	-- en la progresion estatica.
	------------------------------------------------------------------------------------
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

	-------------------------------------------------------------------
	procedure P_GENERAR_PROGRESION (V_POSICION_INICIAL : in Q_TIPOS_BASICOS.T_POSICION_UTM;
					V_POSICION_FINAL : in Q_TIPOS_BASICOS.T_POSICION_UTM;
					V_RUTA : in Q_RUTA.T_RUTA;
					V_PROGRESION : out T_PROGRESION) is	

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

		V_PROGRESION_ESTATICA := F_GENERAR_ENVELOPE_ESTATICO (V_POSICION_INICIAL => V_POSICION_INICIAL,
								      V_POSICION_FINAL => V_POSICION_FINAL,
								      V_RUTA => V_RUTA);

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
	-------------------------------------------------------------------

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

end Q_PROGRESION;
--------------------------------------------------------------------------------------------------------------------------------------------
