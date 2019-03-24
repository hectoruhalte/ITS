--------------------------------------------------------------------------------------------------------------------------------------------
--
--      Fichero:        q_ruta-q_dijkstra.ads
--
--      Autor:          Hector Uhalte Bilbao
--
--      Fecha:          16/5/2018
--      
--------------------------------------------------------------------------------------------------------------------------------------------

with Q_TIPOS_BASICOS;

-- Paquete para para obtener el calculo de la ruta con el algoritmo de Dijkstra.

package Q_RUTA.Q_DIJKSTRA is

	X_RUTA_NO_ENCONTRADA : Exception;

	type T_COSTE_TRAMO is record

                R_TRAMO_ID : Integer range 1 .. Q_TRAMO.F_OBTENER_NUMERO_MAXIMO_TRAMOS;

                R_COSTE_TRAMO : Integer;

        end record;

	type T_RELACION_TRAMOS is record

		R_TRAMO_ANTERIOR_ID : Integer range 1 .. Q_TRAMO.F_OBTENER_NUMERO_MAXIMO_TRAMOS;

		R_TRAMO_ID : Integer range 1 .. Q_TRAMO.F_OBTENER_NUMERO_MAXIMO_TRAMOS;

	end record;

	-- Funcion de igualdad para instanciar el paquete generico.
        function F_IGUALDAD_COSTE_TRAMOS (V_COSTE_TRAMO_1 : in T_COSTE_TRAMO;
                                          V_COSTE_TRAMO_2 : in T_COSTE_TRAMO) return Boolean;

	-- Funcion de igualdad para instanciae el paquete generico.
	function F_IGUALDAD_RELACION_TRAMOS (V_RELACION_TRAMO_1 : in T_RELACION_TRAMOS;
					     V_RELACION_TRAMO_2 : in T_RELACION_TRAMOS) return Boolean;

	-- Funcion de igualdad para instanciar el paquete generico.
        function F_IGUALDAD_ID (V_ID_1 : in Integer;
                                V_ID_2 : in Integer) return Boolean;

        package Q_LISTA_COSTE_TRAMOS is new Q_GENERICO_LISTA (T_ELEMENTO => T_COSTE_TRAMO,
                                                              "=" => F_IGUALDAD_COSTE_TRAMOS,
                                                              V_MAXIMO_NUMERO_ELEMENTOS => Q_TRAMO.F_OBTENER_NUMERO_MAXIMO_TRAMOS);

	package Q_LISTA_RELACION_TRAMOS is new Q_GENERICO_LISTA (T_ELEMENTO => T_RELACION_TRAMOS,
								 "=" => F_IGUALDAD_RELACION_TRAMOS,
								 V_MAXIMO_NUMERO_ELEMENTOS => Q_TRAMO.F_OBTENER_NUMERO_MAXIMO_TRAMOS);

        package Q_LISTA_TRAMOS_ID is new Q_GENERICO_LISTA (T_ELEMENTO => Integer,
                                                           "=" => F_IGUALDAD_ID,
                                                           V_MAXIMO_NUMERO_ELEMENTOS => Q_TRAMO.F_OBTENER_NUMERO_MAXIMO_TRAMOS);

	-- Procedimiento para calcular la ruta entre dos puntos usando el algoritmo de Dijkstra.
	procedure P_CALCULAR_RUTA (V_TRAMO_ORIGEN : in Q_TRAMO.T_TRAMO;
				   V_TRAMO_DESTINO : in Q_TRAMO.T_TRAMO;
				   V_PESO : in T_PESO;
				   V_TRAMOS_A_VISITAR : in out Q_LISTA_TRAMOS_ID.T_LISTA;
				   V_TRAMOS_A_EVITAR : in out Q_LISTA_TRAMOS_ID.T_LISTA;
				   V_COSTE_TRAMOS : in out Q_LISTA_COSTE_TRAMOS.T_LISTA;
				   V_RELACION_TRAMOS : in out Q_LISTA_RELACION_TRAMOS.T_LISTA;
				   V_RUTA : out T_RUTA;
				   V_COSTE_RUTA : out Integer);
				   
end Q_RUTA.Q_DIJKSTRA;
----------------------
