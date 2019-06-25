--------------------------------------------------------------------------------------------------------------------------------------------
--
--      Fichero:        q_ruta-q_dijkstra.adb
--
--      Autor:          Hector Uhalte Bilbao
--
--      Fecha:          16/5/2018
--      
--------------------------------------------------------------------------------------------------------------------------------------------

with Q_TRAMO.Q_ACCIONES;
with Q_SEGMENTO;
with Q_ADAPTACION_TRAMO;

package body Q_RUTA.Q_DIJKSTRA is

	---------------------------------------------------------------------------------------
        function F_IGUALDAD_COSTE_TRAMOS (V_COSTE_TRAMO_1 : in T_COSTE_TRAMO;
                                          V_COSTE_TRAMO_2 : in T_COSTE_TRAMO) return Boolean is

        begin

                return V_COSTE_TRAMO_1.R_TRAMO_ID = V_COSTE_TRAMO_2.R_TRAMO_ID;

        end F_IGUALDAD_COSTE_TRAMOS;
        ---------------------------------------------------------------------------------------

	-------------------------------------------------------------------------------------------------
        function F_IGUALDAD_RELACION_TRAMOS (V_RELACION_TRAMO_1 : in T_RELACION_TRAMOS;
                                             V_RELACION_TRAMO_2 : in T_RELACION_TRAMOS) return Boolean is

        begin

                return V_RELACION_TRAMO_1.R_TRAMO_ID = V_RELACION_TRAMO_2.R_TRAMO_ID;

        end F_IGUALDAD_RELACION_TRAMOS;
        -------------------------------------------------------------------------------------------------

        --------------------------------------------------------------
        function F_IGUALDAD_ID (V_ID_1 : in Integer;
                                V_ID_2 : in Integer) return Boolean is

        begin

                return V_ID_1 = V_ID_2;

        end F_IGUALDAD_ID;
        --------------------------------------------------------------

	------------------------------------
	-- Funcion que dada la lista de 
	-- costes devuelve el tramo_id que 
	-- tiene coste minimo.
	-- Saltar el tramo de origen.
	------------------------------------
	function F_OBTENER_TRAMO_ID_COSTE_MINIMO (V_COSTE_TRAMOS : in Q_LISTA_COSTE_TRAMOS.T_LISTA;
					          V_TRAMO_ORIGEN : in Q_TRAMO.T_TRAMO) return Integer is

		V_TRAMO_ID : Integer := Q_TRAMO.F_OBTENER_NUMERO_MAXIMO_TRAMOS;

		V_COSTE_MINIMO : Integer := 1_000_000;

	begin

		for I in 1 .. Q_LISTA_COSTE_TRAMOS.F_CUANTOS_ELEMENTOS (V_COSTE_TRAMOS) loop

			if Q_LISTA_COSTE_TRAMOS.F_DEVOLVER_ELEMENTO (V_POSICION => I,
								     V_LISTA => V_COSTE_TRAMOS).R_COSTE_TRAMO < V_COSTE_MINIMO and 
			
			   Q_LISTA_COSTE_TRAMOS.F_DEVOLVER_ELEMENTO (V_POSICION => I,
								     V_LISTA => V_COSTE_TRAMOS).R_TRAMO_ID /= 
			   Q_TRAMO.F_OBTENER_ID (V_TRAMO_ORIGEN) then

				V_COSTE_MINIMO := Q_LISTA_COSTE_TRAMOS.F_DEVOLVER_ELEMENTO (V_POSICION => I,
                                                                     			    V_LISTA => V_COSTE_TRAMOS).R_COSTE_TRAMO;

				V_TRAMO_ID := Q_LISTA_COSTE_TRAMOS.F_DEVOLVER_ELEMENTO (V_POSICION => I,
											V_LISTA => V_COSTE_TRAMOS).R_TRAMO_ID;

			end if;

		end loop;

		return V_TRAMO_ID;

	end F_OBTENER_TRAMO_ID_COSTE_MINIMO;
	------------------------------------

	------------------
	-- Funcion que devuelve una ruta dado una lista de relaciones y un tramo de destino.
	------------------
	function F_EXTRAER_RUTA (V_TRAMO_ORIGEN : in Q_TRAMO.T_TRAMO;
				 V_TRAMO_DESTINO : in Q_TRAMO.T_TRAMO;
				 V_RELACION_TRAMOS : in Q_LISTA_RELACION_TRAMOS.T_LISTA;
				 V_TRAMOS_ADAPTACION : in Q_ADAPTACION_TRAMO.Q_LISTA_TRAMOS.T_LISTA) return T_RUTA is

		V_RUTA : T_RUTA;

		V_TRAMO_ANTERIOR_ID : Integer := 
			Q_LISTA_RELACION_TRAMOS.
				F_ENCONTRAR_ELEMENTO (V_ELEMENTO => (R_TRAMO_ANTERIOR_ID => Q_TRAMO.F_OBTENER_NUMERO_MAXIMO_TRAMOS,
								     R_TRAMO_ID => Q_TRAMO.F_OBTENER_ID (V_TRAMO_DESTINO)),
						      V_LISTA => V_RELACION_TRAMOS).R_TRAMO_ANTERIOR_ID;

		V_TRAMO_ID : Integer := Q_TRAMO.F_OBTENER_ID (V_TRAMO_DESTINO);

		V_TRAMO_AUX : Q_TRAMO.T_TRAMO;

	begin

		while V_TRAMO_ID /= V_TRAMO_ANTERIOR_ID loop

			Q_TRAMO.P_INICIALIZAR_TRAMO (V_TRAMO_AUX);

			Q_TRAMO.P_PONER_ID (V_ID => V_TRAMO_ID,
					    V_TRAMO => V_TRAMO_AUX);

			Q_LISTA_TRAMOS.
				P_INSERTAR_ELEMENTO 
					(V_ELEMENTO => 
						Q_ADAPTACION_TRAMO.Q_LISTA_TRAMOS.F_ENCONTRAR_ELEMENTO (V_ELEMENTO => V_TRAMO_AUX,
													V_LISTA => V_TRAMOS_ADAPTACION),
					 V_LISTA => V_RUTA);

			V_TRAMO_ID := V_TRAMO_ANTERIOR_ID;

			V_TRAMO_ANTERIOR_ID := 
				Q_LISTA_RELACION_TRAMOS.
					F_ENCONTRAR_ELEMENTO (V_ELEMENTO => (R_TRAMO_ANTERIOR_ID => Q_TRAMO.F_OBTENER_NUMERO_MAXIMO_TRAMOS,
									     R_TRAMO_ID => V_TRAMO_ID),
							      V_LISTA => V_RELACION_TRAMOS).R_TRAMO_ANTERIOR_ID;

		end loop;

		-- Ya hemos llegado al origen. Añadirlo a la ruta.

		Q_LISTA_TRAMOS.P_INSERTAR_ELEMENTO (V_ELEMENTO => V_TRAMO_ORIGEN,
						    V_LISTA => V_RUTA);

		return V_RUTA;

	end F_EXTRAER_RUTA;
	-------------------

	-------------------------
	-- Este procedimiento solo se llamara cuando el tramo origen
	-- y el tramo destino sean distintos.
	-------------------------
	procedure P_ALGORITMO_DIJKSTRA (V_TRAMO_ORIGEN : in Q_TRAMO.T_TRAMO;
				        V_TRAMO_DESTINO : in Q_TRAMO.T_TRAMO;
				        V_PESO : in T_PESO;
				        V_TRAMOS_A_VISITAR : in out Q_LISTA_TRAMOS_ID.T_LISTA;
                                        V_TRAMOS_A_EVITAR : in out Q_LISTA_TRAMOS_ID.T_LISTA;
                                        V_COSTE_TRAMOS : in out Q_LISTA_COSTE_TRAMOS.T_LISTA;
				        V_RELACION_TRAMOS : in out Q_LISTA_RELACION_TRAMOS.T_LISTA;
				        V_RUTA : out T_RUTA;
				        V_COSTE_RUTA : out Integer) is

		-- Variable para guardar la lista de tramos adaptados.
		V_LISTA_TRAMOS_ADAPTACION : Q_ADAPTACION_TRAMO.Q_LISTA_TRAMOS.T_LISTA;

		-- Variable para almacenar un coste de la lista de coste de tramos.
		-- Variable para almacenar el coste del tramo conexion obtenido de la lista de costes de tramos.
		V_COSTE_TRAMO_AUXILIAR, V_COSTE_TRAMO_CONEXION_ANTERIOR : T_COSTE_TRAMO;

		-- Variable para mantener el coste de un tramo, inicializado a 1_000_000;
		V_COSTE_MINIMO : Integer := 1_000_000;

		-- Variable para guardar el id del tramo de coste minimo de entre los que hay que visitar.
		V_TRAMO_COSTE_MINIMO_ID : Integer := 0;

		-- Variable para guardar el tramo (tipo T_TRAMO) que vamos a visitar.
		-- Variable para guardar el tramo de cada una de las conexiones del tramo que estamos visitando.
		V_TRAMO_VISITADO, V_TRAMO_CONEXION : Q_TRAMO.T_TRAMO;

		-- Variable para guardar la lista de conexiones del tramo de menor coste de entre los que hay que visitar.
		V_LISTA_CONEXIONES : Q_TRAMO.Q_LISTA_CONEXIONES.T_LISTA;

		-- Variable pata guardar el valor del coste del tramo de conexion.
		V_COSTE_TRAMO_CONEXION : Integer := 0;

	begin
	
		-- Cargar la lista de tramos adaptados.
                Q_ADAPTACION_TRAMO.P_GENERAR_LISTA_TRAMOS (V_LISTA_TRAMOS_ADAPTACION);

		-- Comprobar si la lista de tramos a visitar esta vacia.
		if Q_LISTA_TRAMOS_ID.F_CUANTOS_ELEMENTOS (V_TRAMOS_A_VISITAR) = 0 then

			-- La busqueda ha terminado.

			-- Comprobar si el tramo de destino esta entre la lista de coste de tramos => Hemos alcanzado la ruta.
			if Q_LISTA_COSTE_TRAMOS.
				F_ESTA_ELEMENTO_EN_LISTA (V_ELEMENTO => (R_TRAMO_ID => Q_TRAMO.F_OBTENER_ID (V_TRAMO_DESTINO),
									 R_COSTE_TRAMO => 0),
							  V_LISTA => V_COSTE_TRAMOS) then

				-- No hay mas tramos que visitar y hemos alcanzado el destino => Hay ruta

				-- Llamar a la funcion del calculo de la ruta
				V_RUTA := F_EXTRAER_RUTA (V_TRAMO_ORIGEN => V_TRAMO_ORIGEN,
							  V_TRAMO_DESTINO => V_TRAMO_DESTINO,
							  V_RELACION_TRAMOS => V_RELACION_TRAMOS,
							  V_TRAMOS_ADAPTACION => V_LISTA_TRAMOS_ADAPTACION);

				-- Obtener el coste de la ruta. Que sera el coste del tramo destino en la lista de coste de tramos.
                                V_COSTE_RUTA :=
                                        Q_LISTA_COSTE_TRAMOS.F_ENCONTRAR_ELEMENTO
						(V_ELEMENTO => (R_TRAMO_ID => Q_TRAMO.F_OBTENER_ID (V_TRAMO_DESTINO),
                                                                R_COSTE_TRAMO => 0),
                                                 V_LISTA => V_COSTE_TRAMOS).R_COSTE_TRAMO;

			else

				-- No hay tramos que visitar y no hemos alcanzado el destino => No hay ruta.
				raise X_RUTA_NO_ENCONTRADA;

			end if;
	
		else

			-- Para acortar las busquedas.
			-- Si el tramo de destino esta en la lista de costes/relaciones y su coste es el minimo, ya hemos terminado.
			if F_OBTENER_TRAMO_ID_COSTE_MINIMO (V_COSTE_TRAMOS => V_COSTE_TRAMOS,
							    V_TRAMO_ORIGEN => V_TRAMO_ORIGEN) = Q_TRAMO.F_OBTENER_ID (V_TRAMO_DESTINO) then

				-- El tramo de coste minimo es el tramo de destino => Hemos terminado, no hace falta buscar mas.
				-- Llamar a la funcion del calculo de la ruta
                                V_RUTA := F_EXTRAER_RUTA (V_TRAMO_ORIGEN => V_TRAMO_ORIGEN,
							  V_TRAMO_DESTINO => V_TRAMO_DESTINO,
                                                          V_RELACION_TRAMOS => V_RELACION_TRAMOS,
                                                          V_TRAMOS_ADAPTACION => V_LISTA_TRAMOS_ADAPTACION);

				-- Obtener el coste de la ruta. Que sera el coste del tramo destino en la lista de coste de tramos.
				V_COSTE_RUTA := 
					Q_LISTA_COSTE_TRAMOS.F_ENCONTRAR_ELEMENTO 
						(V_ELEMENTO => (R_TRAMO_ID => Q_TRAMO.F_OBTENER_ID (V_TRAMO_DESTINO),
								R_COSTE_TRAMO => 0),
						 V_LISTA => V_COSTE_TRAMOS).R_COSTE_TRAMO;

			else

				-- Hay tramos que visitar.

				for I in 1 .. Q_LISTA_TRAMOS_ID.F_CUANTOS_ELEMENTOS (V_TRAMOS_A_VISITAR) loop

					-- Obtener el tramo de coste menor de entre los tramos a visitar.
					-- Todos los tramos de la lista de tramos a visitar tienen un coste.
					V_COSTE_TRAMO_AUXILIAR := 
						Q_LISTA_COSTE_TRAMOS.
							F_ENCONTRAR_ELEMENTO
                                                		(V_ELEMENTO => 
									(R_TRAMO_ID => 
										Q_LISTA_TRAMOS_ID.
											F_DEVOLVER_ELEMENTO (V_POSICION => I,
													     V_LISTA => V_TRAMOS_A_VISITAR),
                                                                 	 R_COSTE_TRAMO => 0),
                                                 	 	 V_LISTA => V_COSTE_TRAMOS);

					if V_COSTE_TRAMO_AUXILIAR.R_COSTE_TRAMO < V_COSTE_MINIMO then

						V_COSTE_MINIMO := V_COSTE_TRAMO_AUXILIAR.R_COSTE_TRAMO;

						V_TRAMO_COSTE_MINIMO_ID := V_COSTE_TRAMO_AUXILIAR.R_TRAMO_ID;

					end if;

				end loop;

				-- Aqui ya tengo el tramo de coste menor de entre los tramos a visitar.
				-- Obtener las conexiones del tramo de coste menor de entra los tramos a visitar.
				Q_TRAMO.Q_LISTA_CONEXIONES.P_INICIALIZAR_LISTA (V_LISTA_CONEXIONES);

				Q_TRAMO.P_INICIALIZAR_TRAMO (V_TRAMO_VISITADO);

				Q_TRAMO.P_PONER_ID (V_ID => V_TRAMO_COSTE_MINIMO_ID,
					    	    V_TRAMO => V_TRAMO_VISITADO);

				begin

					-- Obtener la lista de conexiones. 
					-- TO DO : Habra que hacer una funcion en la adaptacion que devuelva el tramo dado el id.
					V_LISTA_CONEXIONES :=
                        			Q_TRAMO.F_OBTENER_LISTA_CONEXIONES
                                			(Q_ADAPTACION_TRAMO.Q_LISTA_TRAMOS.
								F_ENCONTRAR_ELEMENTO (V_ELEMENTO => V_TRAMO_VISITADO,
                                                		              	      V_LISTA => V_LISTA_TRAMOS_ADAPTACION));

				
				exception

					when Q_ADAPTACION_TRAMO.Q_LISTA_TRAMOS.X_ELEMENTO_NO_ENCONTRADO =>

                                        	-- El tramo de conexion no esta adaptato. 
                                                -- Añadirlo a la lista de tramos a evitar.
                                                Q_LISTA_TRAMOS_ID.P_INSERTAR_ELEMENTO (V_ELEMENTO => 
											Q_TRAMO.F_OBTENER_ID (V_TRAMO_VISITADO),
										       V_LISTA => V_TRAMOS_A_EVITAR);

				end;

				for I in 1 .. Q_TRAMO.Q_LISTA_CONEXIONES.F_CUANTOS_ELEMENTOS (V_LISTA_CONEXIONES) loop

					-- Comprobar que el coste de la conexion I no este incluida en los tramos a evitar.
					if not Q_LISTA_TRAMOS_ID.
							F_ESTA_ELEMENTO_EN_LISTA 
								(V_ELEMENTO => 
									Q_TRAMO.Q_LISTA_CONEXIONES.
										F_DEVOLVER_ELEMENTO (V_POSICION => I,
												     V_LISTA => V_LISTA_CONEXIONES),
						 	 	 V_LISTA => V_TRAMOS_A_EVITAR) then

						-- Calcular el coste de esas conexiones.
						Q_TRAMO.P_INICIALIZAR_TRAMO (V_TRAMO_CONEXION);

						Q_TRAMO.P_PONER_ID 
							(V_ID => Q_TRAMO.Q_LISTA_CONEXIONES.
								F_DEVOLVER_ELEMENTO (V_POSICION => I,
										     V_LISTA => V_LISTA_CONEXIONES),
						 	 V_TRAMO => V_TRAMO_CONEXION);

						begin
	
							V_TRAMO_CONEXION := 
								Q_ADAPTACION_TRAMO.Q_LISTA_TRAMOS.
									F_ENCONTRAR_ELEMENTO (V_ELEMENTO => V_TRAMO_CONEXION,
											      V_LISTA => V_LISTA_TRAMOS_ADAPTACION);

							-- Obtener el coste del tramo de la conexion.
							-- El valor sera el del coste del tramo origen (v_coste_minimo) + coste tramo 
							-- conexion (adaptacion)
							if V_PESO = E_TIEMPO then

								-- Obtener el coste del tramo de conexion.
								V_COSTE_TRAMO_CONEXION := 
									V_COSTE_MINIMO + Q_TRAMO.F_OBTENER_TIEMPO_TRAMO (V_TRAMO_CONEXION);

							elsif V_PESO = E_DISTANCIA then

								-- Obtener el coste del tramo de conexion.
                                                		V_COSTE_TRAMO_CONEXION := 
                                                        		V_COSTE_MINIMO + 
									Q_TRAMO.F_OBTENER_DISTANCIA_TRAMO (V_TRAMO_CONEXION);

							end if;

							-- Comproabar si la conexion ya estaba en la lista de coste de tramos
							-- => Ya tiene un coste asociado.
							if Q_LISTA_COSTE_TRAMOS.
								F_ESTA_ELEMENTO_EN_LISTA 
									(V_ELEMENTO => 
										(R_TRAMO_ID => Q_TRAMO.F_OBTENER_ID (V_TRAMO_CONEXION),
										 R_COSTE_TRAMO => 0),
								 	 V_LISTA => V_COSTE_TRAMOS) then
							
								-- Ya hay un coste para este tramo de conexion.
								-- Obtener el coste y compararlo con el que acabamos de calcular.
								-- Si el coste nuevo es menor que el anterior:
								-- Actualizar el coste y la lista de relacion de tramos.

								V_COSTE_TRAMO_CONEXION_ANTERIOR := 
									Q_LISTA_COSTE_TRAMOS.
										F_ENCONTRAR_ELEMENTO 
											(V_ELEMENTO => 
												(R_TRAMO_ID => 
													Q_TRAMO.F_OBTENER_ID 
														(V_TRAMO_CONEXION),
											 	 R_COSTE_TRAMO => 0),
										 	 V_LISTA => V_COSTE_TRAMOS);

								if V_COSTE_TRAMO_CONEXION_ANTERIOR.R_COSTE_TRAMO > V_COSTE_TRAMO_CONEXION 
								then

									-- El coste "nuevo" es menor que el anterior =>
									-- Hay que actualizar la lista de coste y la lista de relacion de 
									-- tramos
									-- Actualizar lista de costes =>
									-- Eliminar el coste para el tramo de conexion de la lista de costes
									Q_LISTA_COSTE_TRAMOS.
										P_ELIMINAR_ELEMENTO 
											(V_ELEMENTO => 
												(R_TRAMO_ID => 
													Q_TRAMO.F_OBTENER_ID 
														(V_TRAMO_CONEXION),
											 	 R_COSTE_TRAMO => 0),
										 	 V_LISTA => V_COSTE_TRAMOS);

									-- Insertar el coste de tramos con el nuevo valor de coste.
									Q_LISTA_COSTE_TRAMOS.
										P_INSERTAR_ELEMENTO 
											(V_ELEMENTO => 
												(R_TRAMO_ID => 
													Q_TRAMO.F_OBTENER_ID 
														(V_TRAMO_CONEXION),
										 	 	 R_COSTE_TRAMO => V_COSTE_TRAMO_CONEXION),
										 	 V_LISTA => V_COSTE_TRAMOS);

									-- Actualizar relacion de tramos
									-- Eliminar la relacion de esta conexion de la lista de relaciones.
									Q_LISTA_RELACION_TRAMOS.
										P_ELIMINAR_ELEMENTO 
											(V_ELEMENTO => 
												(R_TRAMO_ANTERIOR_ID => 
													Q_TRAMO.
													F_OBTENER_NUMERO_MAXIMO_TRAMOS,
											 	 R_TRAMO_ID => 
													Q_TRAMO.F_OBTENER_ID 
														(V_TRAMO_CONEXION)),
										 	 V_LISTA => V_RELACION_TRAMOS);

									-- Añadir la nueva relacion.
									Q_LISTA_RELACION_TRAMOS.
										P_INSERTAR_ELEMENTO 
											(V_ELEMENTO => 
												(R_TRAMO_ANTERIOR_ID => 
													Q_TRAMO.F_OBTENER_ID 
														(V_TRAMO_VISITADO),
											 	 R_TRAMO_ID => 
													Q_TRAMO.F_OBTENER_ID 
														(V_TRAMO_CONEXION)),
										 	 V_LISTA => V_RELACION_TRAMOS);								
								end if;

							else

								-- Esta conexion no tiene un coste asociado => 
								-- Tampoco esta en la lista de relacion de tramos.
								-- Luego hay que: Incluir su coste en la lista de costes e incluir su 
								-- relacion del tramo que estamos visitando en la lista de relacion de 
								-- tramos.
								Q_LISTA_COSTE_TRAMOS.
									P_INSERTAR_ELEMENTO 
										(V_ELEMENTO => 
											(R_TRAMO_ID => 
												Q_TRAMO.F_OBTENER_ID (V_TRAMO_CONEXION),
										 	 R_COSTE_TRAMO => V_COSTE_TRAMO_CONEXION),
									 	 V_LISTA => V_COSTE_TRAMOS);

								Q_LISTA_RELACION_TRAMOS.
									P_INSERTAR_ELEMENTO 
										(V_ELEMENTO => 
											(R_TRAMO_ANTERIOR_ID => 
												Q_TRAMO.F_OBTENER_ID (V_TRAMO_VISITADO),
										 	 R_TRAMO_ID => 
												Q_TRAMO.F_OBTENER_ID (V_TRAMO_CONEXION)),
									 	 V_LISTA => V_RELACION_TRAMOS);

								-- Insertar la conexion en la lista de tramos a visitar.
								Q_LISTA_TRAMOS_ID.
									P_INSERTAR_ELEMENTO 
										(V_ELEMENTO => Q_TRAMO.F_OBTENER_ID (V_TRAMO_CONEXION),
										 V_LISTA => V_TRAMOS_A_VISITAR);
							end if;

						exception

							when Q_ADAPTACION_TRAMO.Q_LISTA_TRAMOS.X_ELEMENTO_NO_ENCONTRADO =>

								-- El tramo de conexion no esta adaptato. 
								-- Añadirlo a la lista de tramos a evitar.
								Q_LISTA_TRAMOS_ID.
									P_INSERTAR_ELEMENTO 
										(V_ELEMENTO => Q_TRAMO.F_OBTENER_ID (V_TRAMO_CONEXION),
									     	 V_LISTA => V_TRAMOS_A_EVITAR);

						end;

					end if;
			
				end loop;

				-- Eliminar tramo visitado de la lista de tramos a visitar.
				Q_LISTA_TRAMOS_ID.P_ELIMINAR_ELEMENTO (V_ELEMENTO => Q_TRAMO.F_OBTENER_ID (V_TRAMO_VISITADO),
								       V_LISTA => V_TRAMOS_A_VISITAR);

				-- Llamar recursivamente al procedimiento del calculo de ruta.
				P_ALGORITMO_DIJKSTRA (V_TRAMO_ORIGEN => V_TRAMO_ORIGEN,
						      V_TRAMO_DESTINO => V_TRAMO_DESTINO,
						      V_PESO => V_PESO,
					 	      V_TRAMOS_A_VISITAR => V_TRAMOS_A_VISITAR,
					 	      V_TRAMOS_A_EVITAR => V_TRAMOS_A_EVITAR,
					 	      V_COSTE_TRAMOS => V_COSTE_TRAMOS,
					 	      V_RELACION_TRAMOS => V_RELACION_TRAMOS,
					 	      V_RUTA => V_RUTA,
					 	      V_COSTE_RUTA => V_COSTE_RUTA);

			end if;

		end if;

	end P_ALGORITMO_DIJKSTRA;
	-------------------------

	-------------------------------------------------
	procedure P_OBTENER_RUTA (V_POSICION_ORIGEN : in Q_TIPOS_BASICOS.T_POSICION_UTM;
				  V_POSICION_FINAL : in Q_TIPOS_BASICOS.T_POSICION_UTM;
				  V_RUTA : out T_RUTA;
				  V_COSTE_TIEMPO : out Integer;
				  V_COSTE_DISTANCIA : out Integer) is

		V_POSICION_INICIAL, V_POSICION_DESTINO : Q_TIPOS_BASICOS.T_POSICION_UTM;

		V_DISTANCIA_MINIMA : Integer := 1_000_000;

		V_TRAMO_ORIGEN, V_TRAMO_DESTINO, V_TRAMO_ORIGEN_BIS : Q_TRAMO.T_TRAMO;

		V_COSTE_TRAMOS : Q_LISTA_COSTE_TRAMOS.T_LISTA;

		V_TRAMOS_A_VISITAR, V_TRAMOS_A_EVITAR : Q_LISTA_TRAMOS_ID.T_LISTA;

		V_RELACION_TRAMOS : Q_LISTA_RELACION_TRAMOS.T_LISTA;

		V_SEGMENTO_ORIGEN, V_SEGMENTO_DESTINO, V_SEGMENTO : Q_SEGMENTO.T_SEGMENTO;

		V_POSICION_LISTA_SEGMENTO_ORIGEN, V_POSICION_LISTA_SEGMENTO_DESTINO : Natural;

		V_LISTA_SEGMENTOS_TRAMO_ORIGEN : Q_TRAMO.Q_LISTA_SEGMENTOS.T_LISTA;

		V_LISTA_TRAMOS : Q_ADAPTACION_TRAMO.Q_LISTA_TRAMOS.T_LISTA;

		V_RUTA_CIRCULAR_PROVISIONAL : T_RUTA;

		V_LISTA_CONEXIONES_CIRCULAR : Q_TRAMO.Q_LISTA_CONEXIONES.T_LISTA;

		V_COSTE_RUTA, V_COSTE_TIEMPO_ORIGEN, V_COSTE_DISTANCIA_ORIGEN, V_COSTE_TIEMPO_DESTINO, V_COSTE_DISTANCIA_DESTINO : 
			Integer := 0;

		V_COSTE_PROVISIONAL_RUTA_CIRCULAR : Integer := 1_000_000;

		V_TRAMO_ORIGEN_INICIO, V_TRAMO_ORIGEN_FINAL, V_TRAMO_2_INICIO, V_TRAMO_2_FINAL, V_TRAMO_DESTINO_INICIO, 
		V_TRAMO_DESTINO_FINAL : Q_TIPOS_BASICOS.T_POSICION_UTM;

	begin

		-- Obtener el segmento mas cercano a esa posicion de origen dada.
        	Q_TRAMO.Q_ACCIONES.P_OBTENER_TRAMO_MAS_CERCANO_A_POSICION (V_POSICION => V_POSICION_ORIGEN,
                                                                   	   V_POSICION_SEGMENTO => V_POSICION_INICIAL,
                                                                   	   V_DISTANCIA_A_SEGMENTO => V_DISTANCIA_MINIMA,
                                                                   	   V_TRAMO => V_TRAMO_ORIGEN);

		-- Obtener el segmento mas cercano a esa posicion final dada.
        	Q_TRAMO.Q_ACCIONES.P_OBTENER_TRAMO_MAS_CERCANO_A_POSICION (V_POSICION => V_POSICION_FINAL,
                                                                           V_POSICION_SEGMENTO => V_POSICION_DESTINO,
                                                                           V_DISTANCIA_A_SEGMENTO => V_DISTANCIA_MINIMA,
                                                                           V_TRAMO => V_TRAMO_DESTINO);

		Q_LISTA_COSTE_TRAMOS.P_INICIALIZAR_LISTA (V_COSTE_TRAMOS);

		Q_LISTA_TRAMOS_ID.P_INICIALIZAR_LISTA (V_TRAMOS_A_VISITAR);
	
		Q_LISTA_TRAMOS_ID.P_INICIALIZAR_LISTA (V_TRAMOS_A_EVITAR);

		Q_LISTA_RELACION_TRAMOS.P_INICIALIZAR_LISTA (V_RELACION_TRAMOS);

		-- Inicializar la ruta.
        	Q_LISTA_TRAMOS.P_INICIALIZAR_LISTA (V_RUTA);

		-- Comprobar si el tramo origen es el mismo que el tramo destino.
		if Q_TRAMO."=" (V_TRAMO_1 => V_TRAMO_ORIGEN,
                        	V_TRAMO_2 => V_TRAMO_DESTINO) then

			-- Si tramo origen y tramo distancia son el mismo, pero:
                	-- El tramo (segmento origen realmente) no es de doble sentido y
                	-- El segmento de salida es anterior al de llegada (hay que tener en cuenta que la lista de segmentos en los tramos
			-- esta invertida, el primer segmento en la lista es realmente el ultimo del tramo)
                	-- Entonces hay que ir a Dijkstra => Tenemos una ruta en "circulo". Se asume que no se puede circular marcha atras.
			Q_SEGMENTO.P_PONER_POSICION (V_POSICION => V_POSICION_INICIAL,
                                                     V_SEGMENTO => V_SEGMENTO_ORIGEN);

			V_POSICION_LISTA_SEGMENTO_ORIGEN := 
				Q_TRAMO.Q_LISTA_SEGMENTOS.F_POSICION_ELEMENTO 
					(V_ELEMENTO => V_SEGMENTO_ORIGEN,
                                         V_LISTA => Q_TRAMO.F_OBTENER_LISTA_SEGMENTOS (V_TRAMO_ORIGEN));

			Q_SEGMENTO.P_PONER_POSICION (V_POSICION => V_POSICION_DESTINO,
                                                     V_SEGMENTO => V_SEGMENTO_DESTINO);

                	V_POSICION_LISTA_SEGMENTO_DESTINO :=
                        	Q_TRAMO.Q_LISTA_SEGMENTOS.F_POSICION_ELEMENTO 
					(V_ELEMENTO => V_SEGMENTO_DESTINO,
                                         V_LISTA => Q_TRAMO.F_OBTENER_LISTA_SEGMENTOS (V_TRAMO_DESTINO));

			if V_POSICION_LISTA_SEGMENTO_ORIGEN >= V_POSICION_LISTA_SEGMENTO_DESTINO then

				-- No hay ruta "circular". Añadir el tramo a la ruta.
				Q_RUTA.Q_LISTA_TRAMOS.P_INSERTAR_ELEMENTO (V_ELEMENTO => V_TRAMO_ORIGEN,
                                                                           V_LISTA => V_RUTA);

				-- Calcular los costes de la ruta.
                        	V_COSTE_DISTANCIA := 5 * abs (V_POSICION_LISTA_SEGMENTO_DESTINO - V_POSICION_LISTA_SEGMENTO_ORIGEN);

                        	V_COSTE_TIEMPO := 
					Integer(Float'Rounding
						((Float(V_COSTE_DISTANCIA) / Float(Q_TRAMO.F_OBTENER_DISTANCIA_TRAMO (V_TRAMO_ORIGEN))) *
                                                  Float(Q_TRAMO.F_OBTENER_TIEMPO_TRAMO (V_TRAMO_ORIGEN))));
				
			else

				-- No realizo un "or else" porque si se cumple la condicion de que:
                        	-- Posicion segmento origen >= Posicion segmento destino => No tengo que encontrar el segmento y comprobar
				-- si es de doble sentido o no.

                        	-- Comprobar si el segmento es de doble sentido.
                        	-- Obtener la lista de segmentos del tramo.
				-- Cargar la lista de tramos adaptados.
                		Q_ADAPTACION_TRAMO.P_GENERAR_LISTA_TRAMOS (V_LISTA_TRAMOS);

				Q_TRAMO.Q_LISTA_SEGMENTOS.P_INICIALIZAR_LISTA (V_LISTA_SEGMENTOS_TRAMO_ORIGEN);

				V_LISTA_SEGMENTOS_TRAMO_ORIGEN := Q_TRAMO.F_OBTENER_LISTA_SEGMENTOS (V_TRAMO_ORIGEN);

				-- Recorrer la lista de segmentos hasta obtener el segmento de la posicion de salida.
                        	for I in 1 .. Q_TRAMO.Q_LISTA_SEGMENTOS.F_CUANTOS_ELEMENTOS (V_LISTA_SEGMENTOS_TRAMO_ORIGEN) loop
	
					V_SEGMENTO := 
						Q_TRAMO.Q_LISTA_SEGMENTOS.F_DEVOLVER_ELEMENTO (V_POSICION => I,
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
								5 * 
								abs (V_POSICION_LISTA_SEGMENTO_DESTINO - V_POSICION_LISTA_SEGMENTO_ORIGEN);

                                                	V_COSTE_TIEMPO := 
								Integer(Float'Rounding
                                                 			((Float(V_COSTE_DISTANCIA) / 
									  Float(Q_TRAMO.F_OBTENER_DISTANCIA_TRAMO (V_TRAMO_ORIGEN))) *
                                                   			  Float(Q_TRAMO.F_OBTENER_TIEMPO_TRAMO (V_TRAMO_ORIGEN))));

                                                	-- No tengo que buscar mas segmentos
                                                	exit;

						else

							-- Ruta circular
							-- Forzar a visitar el tramo de origen.
							-- Inicializar la ruta circular provisional.
                                               		Q_LISTA_TRAMOS.P_INICIALIZAR_LISTA (V_RUTA_CIRCULAR_PROVISIONAL);

							-- Añadir el coste del primer tramo a la ruta.
                                                	-- De momento desde se hara siempre por el tiempo.
                                                	Q_SEGMENTO.P_PONER_POSICION (V_POSICION => V_POSICION_INICIAL,
                                                                             	     V_SEGMENTO => V_SEGMENTO_ORIGEN);

							V_POSICION_LISTA_SEGMENTO_ORIGEN :=
                                                        	Q_TRAMO.Q_LISTA_SEGMENTOS.
                                                                	F_POSICION_ELEMENTO
                                                                        	(V_ELEMENTO => V_SEGMENTO_ORIGEN,
                                                                         	 V_LISTA => 
											Q_TRAMO.F_OBTENER_LISTA_SEGMENTOS (V_TRAMO_ORIGEN));

							V_COSTE_DISTANCIA_ORIGEN := V_POSICION_LISTA_SEGMENTO_ORIGEN * 5;

                                                	V_COSTE_TIEMPO_ORIGEN :=
                                                        	Integer(Float'Rounding
                                                                	((Float(V_COSTE_DISTANCIA_ORIGEN) /
                                                                  	  Float(Q_TRAMO.F_OBTENER_DISTANCIA_TRAMO (V_TRAMO_ORIGEN))) *
                                                                	  Float(Q_TRAMO.F_OBTENER_TIEMPO_TRAMO (V_TRAMO_ORIGEN))));

							-- Inicializar la lista de conexiones del tramo
							Q_TRAMO.Q_LISTA_CONEXIONES.P_INICIALIZAR_LISTA (V_LISTA_CONEXIONES_CIRCULAR);

							-- Obtener las conexiones del tramo origen.
                                                	V_LISTA_CONEXIONES_CIRCULAR := Q_TRAMO.F_OBTENER_LISTA_CONEXIONES (V_TRAMO_ORIGEN);
						
							for I in 1 .. Q_TRAMO.Q_LISTA_CONEXIONES.F_CUANTOS_ELEMENTOS 
									(V_LISTA_CONEXIONES_CIRCULAR) loop
								
								-- Inicializar tramo. Usando la variable V_TRAMO_ORIGEN_BIS no modificamos
								-- el tramo origen real.
                                                        	Q_TRAMO.P_INICIALIZAR_TRAMO (V_TRAMO_ORIGEN_BIS);

								-- Poner como tramo origen el de la conexion I.
                                                        	Q_TRAMO.P_PONER_ID (V_ID => Q_TRAMO.Q_LISTA_CONEXIONES.F_DEVOLVER_ELEMENTO
                                                                                        	(V_POSICION => I,
                                                                                         	 V_LISTA => V_LISTA_CONEXIONES_CIRCULAR),
                                                                            	    V_TRAMO => V_TRAMO_ORIGEN_BIS);

								-- Establecer como tramo origen el de la conexion
                                                        	Q_LISTA_TRAMOS_ID.P_INSERTAR_ELEMENTO 
									(V_ELEMENTO => Q_TRAMO.Q_LISTA_CONEXIONES.F_DEVOLVER_ELEMENTO 
											(V_POSICION => I,
                                                                                 	 V_LISTA => V_LISTA_CONEXIONES_CIRCULAR),
                                                                 	 V_LISTA => V_TRAMOS_A_VISITAR);

								-- Insertar con coste 0 este tramo en la lista de costes
                                                        	Q_LISTA_COSTE_TRAMOS.P_INSERTAR_ELEMENTO
                                                                	(V_ELEMENTO => 
										(R_TRAMO_ID => 
											Q_TRAMO.Q_LISTA_CONEXIONES.F_DEVOLVER_ELEMENTO
                                                                                        	(V_POSICION => I,
                                                                                                 V_LISTA => V_LISTA_CONEXIONES_CIRCULAR),
                                                                               	 R_COSTE_TRAMO => 0),
                                                                 	 V_LISTA => V_COSTE_TRAMOS);

								-- Insertar la relacion de tramos
                                                        	Q_LISTA_RELACION_TRAMOS.
                                                                	P_INSERTAR_ELEMENTO 
										(V_ELEMENTO => 
											(R_TRAMO_ANTERIOR_ID => 
												Q_TRAMO.Q_LISTA_CONEXIONES.
												F_DEVOLVER_ELEMENTO
                                                                                                (V_POSICION => I,
                                                                                                 V_LISTA => V_LISTA_CONEXIONES_CIRCULAR),
                                                                                         R_TRAMO_ID =>
                                                                                        	Q_TRAMO.Q_LISTA_CONEXIONES.
												F_DEVOLVER_ELEMENTO
                                                                                                (V_POSICION => I,
                                                                                                 V_LISTA => V_LISTA_CONEXIONES_CIRCULAR)),
                                                                                 V_LISTA => V_RELACION_TRAMOS);

								begin

								-- Dijkstra
								P_ALGORITMO_DIJKSTRA (V_TRAMO_ORIGEN => V_TRAMO_ORIGEN_BIS,
                                                                                      V_TRAMO_DESTINO => V_TRAMO_DESTINO,
                                                                                      V_PESO => E_TIEMPO,
                                                                                      V_TRAMOS_A_VISITAR => V_TRAMOS_A_VISITAR,
                                                                                      V_TRAMOS_A_EVITAR => V_TRAMOS_A_EVITAR,
                                                                                      V_COSTE_TRAMOS => V_COSTE_TRAMOS,
                                                                                      V_RELACION_TRAMOS => V_RELACION_TRAMOS,
                                                                                      V_RUTA => V_RUTA,
                                                                                      V_COSTE_RUTA => V_COSTE_RUTA);

								-- El problema es que el tramo origen que mete P_CALCULAR_RUTA no es el 
								-- tramo origen real, sera una de las conexiones al tramo origen.
                                                        	-- De algun modo hay que insertar el tramo origen en la ruta.

                                                        	-- Si no ha saltado la excepcion de no hay ruta es que hay una ruta posible.
                                                        	if V_COSTE_RUTA < V_COSTE_PROVISIONAL_RUTA_CIRCULAR then

                                                                	V_COSTE_PROVISIONAL_RUTA_CIRCULAR := V_COSTE_RUTA;

                                                                	V_RUTA_CIRCULAR_PROVISIONAL := V_RUTA;

                                                        	end if;

								exception

                                                                	when X_RUTA_NO_ENCONTRADA =>

                                                                		null;

                                                        	end;

							end loop;

							-- Aqui si existe, ya tenemos la ruta circular mas corta. Si existe su coste debera
							-- ser menor que 1_000_000
							if V_COSTE_PROVISIONAL_RUTA_CIRCULAR < 1_000_000 then
		
								-- Hay una ruta circular                                        
                                                        	V_RUTA := V_RUTA_CIRCULAR_PROVISIONAL;

								--V_HAY_RUTA := true;

								-- Añadir el tramo de origen a la ruta.
                                                        	Q_LISTA_TRAMOS.P_INSERTAR_ELEMENTO (V_ELEMENTO => V_TRAMO_ORIGEN,
                                                                                                    V_LISTA => V_RUTA);
								
								-- Calcular el coste real (no el total que se calcula para el ultimo tramo
								-- de la ruta en dijkstra) del ultimo tramo. Para ello se resta el coste
								-- del tramo destino del coste de la ruta.
                                                        	Q_SEGMENTO.P_PONER_POSICION (V_POSICION => V_POSICION_DESTINO,
                                                                                     	    V_SEGMENTO => V_SEGMENTO_DESTINO);
	
								V_POSICION_LISTA_SEGMENTO_DESTINO :=
                                                                	Q_TRAMO.Q_LISTA_SEGMENTOS.F_POSICION_ELEMENTO
                                                                        	(V_ELEMENTO => V_SEGMENTO_DESTINO,
                                                                         	 V_LISTA => 
											Q_TRAMO.F_OBTENER_LISTA_SEGMENTOS 
												(V_TRAMO_DESTINO));

								V_COSTE_DISTANCIA_DESTINO := V_POSICION_LISTA_SEGMENTO_DESTINO * 5;


                                                        	V_COSTE_TIEMPO_DESTINO := 
									Q_TRAMO.F_OBTENER_TIEMPO_TRAMO (V_TRAMO_DESTINO) - 
                                                                	Integer(Float'Rounding
                                                                        	((Float(V_COSTE_DISTANCIA_DESTINO) /
                                                                                	Float(Q_TRAMO.F_OBTENER_DISTANCIA_TRAMO 
												(V_TRAMO_DESTINO))) *
                                                                                  Float(Q_TRAMO.F_OBTENER_TIEMPO_TRAMO (V_TRAMO_DESTINO))));

								V_COSTE_RUTA := 0;

								-- El tramo 2 no tiene el coste incluido en la ruta
								for I in 3 ..  Q_LISTA_TRAMOS.F_CUANTOS_ELEMENTOS (V_RUTA) loop
							
									V_COSTE_RUTA := 
										V_COSTE_RUTA + 
										Q_TRAMO.F_OBTENER_TIEMPO_TRAMO 
											(Q_LISTA_TRAMOS.F_DEVOLVER_ELEMENTO 
												(V_POSICION => I,
			       									 V_LISTA => V_RUTA));
			
								end loop;

								-- Meter el coste del segundo tramo y restar el del ultimo tramo.
								V_COSTE_RUTA := 
									V_COSTE_RUTA + 
									Q_TRAMO.F_OBTENER_TIEMPO_TRAMO 
										(Q_ADAPTACION_TRAMO.Q_LISTA_TRAMOS.F_ENCONTRAR_ELEMENTO 
											(V_ELEMENTO => Q_LISTA_TRAMOS.F_DEVOLVER_ELEMENTO 
												(V_POSICION => 2,
												 V_LISTA => V_RUTA),
											 V_LISTA => V_LISTA_TRAMOS)) -
									Q_TRAMO.F_OBTENER_TIEMPO_TRAMO (V_TRAMO_DESTINO);

								-- De momento siempre el coste es el coste en tiempo
								V_COSTE_TIEMPO := 
									V_COSTE_RUTA + V_COSTE_TIEMPO_ORIGEN + V_COSTE_TIEMPO_DESTINO;
															
							else


								raise X_RUTA_NO_ENCONTRADA;

							end if;

						end if;

					end if;

				end loop;

			end if;

		else

			-- Tramo origen distinto del tramo destino => No hay ruta circular.
			-- Añadir el coste del primer tramo a la ruta.
                	-- De momento se hara siempre por el tiempo.
                	Q_SEGMENTO.P_PONER_POSICION (V_POSICION => V_POSICION_INICIAL,
                                                     V_SEGMENTO => V_SEGMENTO_ORIGEN);

			V_POSICION_LISTA_SEGMENTO_ORIGEN :=
                        	Q_TRAMO.Q_LISTA_SEGMENTOS.F_POSICION_ELEMENTO 
					(V_ELEMENTO => V_SEGMENTO_ORIGEN,
                                         V_LISTA => Q_TRAMO.F_OBTENER_LISTA_SEGMENTOS (V_TRAMO_ORIGEN));

			-- Añadir el tramo de origen a lista de tramos a visitar.
                	Q_LISTA_TRAMOS_ID.P_INSERTAR_ELEMENTO (V_ELEMENTO => Q_TRAMO.F_OBTENER_ID (V_TRAMO_ORIGEN),
                                                               V_LISTA => V_TRAMOS_A_VISITAR);

			-- Insertar el tramo de origen con un coste 0 en la lista de coste de tramos.
                	Q_LISTA_COSTE_TRAMOS.P_INSERTAR_ELEMENTO (V_ELEMENTO => (R_TRAMO_ID => Q_TRAMO.F_OBTENER_ID (V_TRAMO_ORIGEN),
                                                            			 R_COSTE_TRAMO => 0),
                                             			  V_LISTA => V_COSTE_TRAMOS);

			Q_LISTA_RELACION_TRAMOS.P_INSERTAR_ELEMENTO 
				(V_ELEMENTO => (R_TRAMO_ANTERIOR_ID => Q_TRAMO.F_OBTENER_ID (V_TRAMO_ORIGEN),
                                                R_TRAMO_ID => Q_TRAMO.F_OBTENER_ID (V_TRAMO_ORIGEN)),
                            	 V_LISTA => V_RELACION_TRAMOS);

			begin

			-- Llamar a Dijkstra.
                	P_ALGORITMO_DIJKSTRA (V_TRAMO_ORIGEN => V_TRAMO_ORIGEN,
                                              V_TRAMO_DESTINO => V_TRAMO_DESTINO,
                                              V_PESO => E_TIEMPO,
                                              V_TRAMOS_A_VISITAR => V_TRAMOS_A_VISITAR,
                                              V_TRAMOS_A_EVITAR => V_TRAMOS_A_EVITAR,
                                              V_COSTE_TRAMOS => V_COSTE_TRAMOS,
                                              V_RELACION_TRAMOS => V_RELACION_TRAMOS,
                                              V_RUTA => V_RUTA,
                                              V_COSTE_RUTA => V_COSTE_RUTA);

			-- Dependiendo de si el tramo es de doble sentido o no, el coste se calculara de una manera o de otra.
                        -- Si el tramo es de doble sentido y lo recorremos en sentido normal = sentido de tramo unico
                        -- Si el tramo es de doble sentido y lo recorremos hacia el origen => inverso al sentido de tramo unico.
			-- Comprobar si vamos hacia el origen (inverso) o hacia el destino (normal)
                        -- 1.- Obtener las coordenadas origen y final del tramo origen.
                        V_TRAMO_ORIGEN_INICIO := Q_TRAMO.F_OBTENER_ORIGEN (V_TRAMO_ORIGEN);
                        V_TRAMO_ORIGEN_FINAL := Q_TRAMO.F_OBTENER_FINAL (V_TRAMO_ORIGEN);

                        -- 2.- Conseguir el inicio y el final del siguiente tramo de la ruta
                        V_TRAMO_2_INICIO := Q_TRAMO.F_OBTENER_ORIGEN (Q_LISTA_TRAMOS.F_DEVOLVER_ELEMENTO (V_POSICION => 2,
                                                                                                          V_LISTA => V_RUTA));

                        V_TRAMO_2_FINAL := Q_TRAMO.F_OBTENER_FINAL (Q_LISTA_TRAMOS.F_DEVOLVER_ELEMENTO (V_POSICION => 2,
                                                                                                        V_LISTA => V_RUTA));

                        if not Q_SEGMENTO.F_OBTENER_DOBLE_SENTIDO
                                (Q_TRAMO.Q_LISTA_SEGMENTOS.F_DEVOLVER_ELEMENTO
                                        (V_POSICION => V_POSICION_LISTA_SEGMENTO_ORIGEN,
                                         V_LISTA => Q_TRAMO.F_OBTENER_LISTA_SEGMENTOS (V_TRAMO_ORIGEN))) or

			   (Q_TIPOS_BASICOS."=" (V_POSICION_1 => V_TRAMO_ORIGEN_FINAL,
                                                 V_POSICION_2 => V_TRAMO_2_INICIO) or
                            Q_TIPOS_BASICOS."=" (V_POSICION_1 => V_TRAMO_ORIGEN_FINAL,
                                                 V_POSICION_2 => V_TRAMO_2_FINAL))

                        then

                                -- El segmento => Tramo origen es de sentido unico o de doble sentido recorrido en sentido "normal"
				V_COSTE_DISTANCIA_ORIGEN := V_POSICION_LISTA_SEGMENTO_ORIGEN * 5;

			else

				-- El segmento => Tramo origen es de doble sentido y esta recorrido en sentido "inverso"
				V_COSTE_DISTANCIA_ORIGEN := 
                                        Q_TRAMO.F_OBTENER_DISTANCIA_TRAMO (V_TRAMO_ORIGEN) - (V_POSICION_LISTA_SEGMENTO_ORIGEN * 5);

			end if;

			V_COSTE_TIEMPO_ORIGEN := 
				Integer(Float'Rounding((Float(V_COSTE_DISTANCIA_ORIGEN) /
                                                        Float(Q_TRAMO.F_OBTENER_DISTANCIA_TRAMO (V_TRAMO_ORIGEN))) *
                                                       Float(Q_TRAMO.F_OBTENER_TIEMPO_TRAMO (V_TRAMO_ORIGEN))));

			-- Calcular el coste real (no el total que se calcula para el ultimo tramo de la ruta en dijkstra) del ultimo tramo
                	-- Para ello se resta el coste del tramo destino del coste de la ruta.
                	Q_SEGMENTO.P_PONER_POSICION (V_POSICION => V_POSICION_DESTINO,
                        	                     V_SEGMENTO => V_SEGMENTO_DESTINO);

			V_POSICION_LISTA_SEGMENTO_DESTINO :=
                        	Q_TRAMO.Q_LISTA_SEGMENTOS.F_POSICION_ELEMENTO 
					(V_ELEMENTO => V_SEGMENTO_DESTINO,
                                       	 V_LISTA => Q_TRAMO.F_OBTENER_LISTA_SEGMENTOS (V_TRAMO_DESTINO));

			-- Comprobar si vamos hacia el origen (inverso) o hacia el destino (normal)
                        -- 1.- Obtener las coordenadas origen y final del tramo destino.
			V_TRAMO_DESTINO_INICIO := Q_TRAMO.F_OBTENER_ORIGEN (V_TRAMO_DESTINO);
                        V_TRAMO_DESTINO_FINAL := Q_TRAMO.F_OBTENER_FINAL (V_TRAMO_DESTINO);

			-- 2.- Conseguir el inicio y el final del penultimo tramo de la ruta
                        V_TRAMO_2_INICIO := 
				Q_TRAMO.F_OBTENER_ORIGEN 
					(Q_LISTA_TRAMOS.F_DEVOLVER_ELEMENTO (V_POSICION => Q_LISTA_TRAMOS.F_CUANTOS_ELEMENTOS (V_RUTA) -1,
                                                                             V_LISTA => V_RUTA));

			V_TRAMO_2_FINAL := 
				Q_TRAMO.F_OBTENER_FINAL 
					(Q_LISTA_TRAMOS.F_DEVOLVER_ELEMENTO (V_POSICION => Q_LISTA_TRAMOS.F_CUANTOS_ELEMENTOS (V_RUTA) -1,
                                                                             V_LISTA => V_RUTA));

			if not Q_SEGMENTO.F_OBTENER_DOBLE_SENTIDO
                                (Q_TRAMO.Q_LISTA_SEGMENTOS.F_DEVOLVER_ELEMENTO
                                        (V_POSICION => V_POSICION_LISTA_SEGMENTO_DESTINO,
                                         V_LISTA => Q_TRAMO.F_OBTENER_LISTA_SEGMENTOS (V_TRAMO_DESTINO))) or

                           not (Q_TIPOS_BASICOS."=" (V_POSICION_1 => V_TRAMO_DESTINO_FINAL,
                                                     V_POSICION_2 => V_TRAMO_2_INICIO) or 
			        Q_TIPOS_BASICOS."=" (V_POSICION_1 => V_TRAMO_DESTINO_FINAL,
                                                     V_POSICION_2 => V_TRAMO_2_FINAL))

			then

				-- El segmento => Tramo destino es de sentido unico o de doble sentido recorrido en sentido "normal"
				V_COSTE_DISTANCIA_DESTINO := V_POSICION_LISTA_SEGMENTO_DESTINO * 5;

			else

				-- El segmento => Tramo origen es de doble sentido y esta recorrido en sentido "inverso"
				V_COSTE_DISTANCIA_DESTINO :=
                                        Q_TRAMO.F_OBTENER_DISTANCIA_TRAMO (V_TRAMO_DESTINO) - (V_POSICION_LISTA_SEGMENTO_DESTINO * 5);

			end if;

                	V_COSTE_TIEMPO_DESTINO := 
				Integer(Float'Rounding
                                                  ((Float(V_COSTE_DISTANCIA_DESTINO) / 
						    Float(Q_TRAMO.F_OBTENER_DISTANCIA_TRAMO (V_TRAMO_DESTINO))) *
                                                    Float(Q_TRAMO.F_OBTENER_TIEMPO_TRAMO (V_TRAMO_DESTINO))));

			-- En el coste de la ruta esta el tiempo del tramo destino completo.
			-- Al restar el
			V_COSTE_TIEMPO := V_COSTE_TIEMPO_ORIGEN + V_COSTE_RUTA - V_COSTE_TIEMPO_DESTINO;

			exception

				when X_RUTA_NO_ENCONTRADA =>

					raise X_RUTA_NO_ENCONTRADA;

			end;

		end if;

	end P_OBTENER_RUTA;
	-------------------------------------------------

end Q_RUTA.Q_DIJKSTRA;
--------------------------------------------------------------------------------------------------------------------------------------------
