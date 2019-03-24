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
with Ada.Text_Io;
with Ada.Characters.Latin_1;
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

		--Ada.Text_Io.Put_Line ("El tramo de coste minimo es " & Integer'Image(V_TRAMO_ID));

		return V_TRAMO_ID;

	end F_OBTENER_TRAMO_ID_COSTE_MINIMO;
	------------------------------------

	------------------
	-- Funcion que devuelve una ruta dado una lista de relaciones y un tramo de destino.
	------------------
	function F_OBTENER_RUTA (V_TRAMO_ORIGEN : in Q_TRAMO.T_TRAMO;
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

	end F_OBTENER_RUTA;
	-------------------

	------------------------------------------------------------
	-- Este procedimiento solo se llamara cuando el tramo origen
	-- y el tramo destino sean distintos.
	------------------------------------------------------------
	procedure P_CALCULAR_RUTA (V_TRAMO_ORIGEN : in Q_TRAMO.T_TRAMO;
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
				V_RUTA := F_OBTENER_RUTA (V_TRAMO_ORIGEN => V_TRAMO_ORIGEN,
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
                                V_RUTA := F_OBTENER_RUTA (V_TRAMO_ORIGEN => V_TRAMO_ORIGEN,
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
				P_CALCULAR_RUTA (V_TRAMO_ORIGEN => V_TRAMO_ORIGEN,
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

	end P_CALCULAR_RUTA;
	---------------------------------------------------------

end Q_RUTA.Q_DIJKSTRA;
--------------------------------------------------------------------------------------------------------------------------------------------
