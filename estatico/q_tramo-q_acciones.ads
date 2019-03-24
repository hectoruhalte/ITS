--------------------------------------------------------------------------------------------------------------------------------------------
--
--      Fichero:        q_tramo-q_acciones.ads
--
--      Autor:          Hector Uhalte Bilbao
--
--      Fecha:          7/2/2018
--      
--------------------------------------------------------------------------------------------------------------------------------------------

with Q_ADAPTACION_TRAMO;

package Q_TRAMO.Q_ACCIONES is

	-- Funcion para obtener puntos aleatoriamente.
	-- Pensado para obtener rutas de manera aleatoria.
	function F_OBTENER_PUNTO_ALEATORIO 
			(V_LISTA_TRAMOS : in Q_ADAPTACION_TRAMO.Q_LISTA_TRAMOS.T_LISTA) return Q_TIPOS_BASICOS.T_POSICION_UTM;

	-- Procedimiento para obtener un segmento aleatorio (se devuelve el nombre del tramo y la posicion del segmento).
	procedure P_OBTENER_SEGMENTO_ALEATORIO (V_LISTA_TRAMOS : in Q_ADAPTACION_TRAMO.Q_LISTA_TRAMOS.T_LISTA;
						V_NOMBRE_TRAMO : out String;
						V_POSICION_SEGMENTO : out Q_TIPOS_BASICOS.T_POSICION_UTM);

	-- Procedimiento que dada una posicion cualquiera (no necesariamente parte de un tramo), devuelva la posicion del segmento más 
	-- cercano y el tramo al que pertenece
	procedure P_OBTENER_TRAMO_MAS_CERCANO_A_POSICION (V_POSICION : in Q_TIPOS_BASICOS.T_POSICION_UTM;
							  V_POSICION_SEGMENTO : out Q_TIPOS_BASICOS.T_POSICION_UTM;
							  V_DISTANCIA_A_SEGMENTO : out Integer;
							  V_TRAMO : out T_TRAMO); 

	procedure P_VISUALIZAR_CABECERA_TRAMO;

	procedure P_VISUALIZAR_TRAMO (V_LISTA_TRAMOS : in Q_ADAPTACION_TRAMO.Q_LISTA_TRAMOS.T_LISTA;
				      V_ID : in Integer);

end Q_TRAMO.Q_ACCIONES;
-----------------------
