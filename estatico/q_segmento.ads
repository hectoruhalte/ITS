--------------------------------------------------------------------------------------------------------------------------------------------
--
--      Fichero:        q_segmento.ads
--
--      Autor:          Hector Uhalte Bilbao
--
--      Fecha:          1/2/2018
--      
--------------------------------------------------------------------------------------------------------------------------------------------

with Q_GENERICO_LISTA;
with Q_CARRIL;
with Q_TIPOS_BASICOS;

-- Paquete para presentar el tipo T_SEGMENTO;

package Q_SEGMENTO is

	package Q_LISTA_CARRILES is new Q_GENERICO_LISTA (T_ELEMENTO => Q_CARRIL.T_CARRIL,
							  "=" => Q_CARRIL."=",
							  V_MAXIMO_NUMERO_ELEMENTOS => Q_CARRIL.F_OBTENER_NUMERO_MAXIMO_CARRILES);

	type T_SEGMENTO is private;

	-- Funcion necesaria para instanciar el paquete Q_GENERICO_LISTA para crear listas de segmentos.
	function "=" (V_SEGMENTO_1 : in T_SEGMENTO;
		      V_SEGMENTO_2 : in T_SEGMENTO) return Boolean;

	function F_OBTENER_NUMERO_MAXIMO_SEGMENTOS return Integer;

	procedure P_INICIALIZAR_SEGMENTO (V_SEGMENTO : in out T_SEGMENTO);

	function F_OBTENER_POSICION (V_SEGMENTO : in T_SEGMENTO) return Q_TIPOS_BASICOS.T_POSICION_UTM;

	procedure P_PONER_POSICION (V_POSICION : in Q_TIPOS_BASICOS.T_POSICION_UTM;
				    V_SEGMENTO : in out T_SEGMENTO);

	function F_OBTENER_LISTA_CARRILES (V_SEGMENTO : in T_SEGMENTO) return Q_LISTA_CARRILES.T_LISTA;

	procedure P_PONER_LISTA_CARRILES (V_NUMERO_CARRILES : in Integer;
					  V_SEGMENTO : in out T_SEGMENTO);

	function F_OBTENER_DOBLE_SENTIDO (V_SEGMENTO : in T_SEGMENTO) return Boolean;

	procedure P_PONER_DOBLE_SENTIDO (V_DOBLE_SENTIDO : in Boolean;
					 V_SEGMENTO : in out T_SEGMENTO);

	function F_OBTENER_DISPONIBLE (V_SEGMENTO : in T_SEGMENTO) return Boolean;

	procedure P_PONER_DISPONIBLE (V_DISPONIBLE : in Boolean;
				      V_SEGMENTO : in out T_SEGMENTO);

	private

		-- Constante para definir el numero maximo de segmentos en un tramo.
                C_NUMERO_MAXIMO_SEGMENTOS : constant Integer := 200;

		-- Cada segmento estara compuesto por desde 1 hasta un numero maximo de segmentos, cada uno de los cuales tendra n carriles.
                type T_SEGMENTO is record

                        -- Posicion del segemento. X-Y. Pensado para los mapas.
                        -- Dato obtenido por adaptacion
                        R_POSICION : Q_TIPOS_BASICOS.T_POSICION_UTM;

                        -- La lista de carriles del segmento se rellenara con el numero de carriles definidos en adaptacion
                        R_CARRILES : Q_LISTA_CARRILES.T_LISTA;

                        -- Pensado para tramos de carretera en el que se pueda adelantar usando un carril de sentido contrario.
                        -- Si es true, habra al menos un carril adyacente a este segmento que pertenece a otro tramo que se puede usar.
                        -- Dato obtenido por adaptacion.
                        R_DOBLE_SENTIDO : Boolean := False;

                        -- Para saber si un segmento de un tramo esta abierto o no a la circulacion.
                        -- Si esta cerrado, no haria falta bajar al nivel de los carriles para saber si todos estan no disponibles y por
                        -- tanto cerrar el segmento.
                        -- Por defecto estara disponible
                        R_DISPONIBLE: Boolean := True;

                end record;

end Q_SEGMENTO;
---------------
