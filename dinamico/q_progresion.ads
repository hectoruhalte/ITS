--------------------------------------------------------------------------------------------------------------------------------------------
--
--      Fichero:        q_progresion.ads
--
--      Autor:          Hector Uhalte Bilbao
--
--      Fecha:          10/7/2019
--      
--------------------------------------------------------------------------------------------------------------------------------------------

with Q_TIPOS_BASICOS;
with Q_RUTA;
with Q_RESTRICCION;
with Q_GENERICO_LISTA;
with Q_TRAMO;
with Q_SEGMENTO;

-- Paquete para definir la progresion para un trayecto. Estara compuesto por una lista de elementos de progresion.
-- Cada elemento de progresion estara compuesto por una posicion (del segmento) y una restriccion.

package Q_PROGRESION is

	type T_ELEMENTO_PROGRESION is private;

	type T_PROGRESION is private;

	procedure P_GENERAR_PROGRESION (V_POSICION_INICIAL : in Q_TIPOS_BASICOS.T_POSICION_UTM;
					V_POSICION_FINAL : in Q_TIPOS_BASICOS.T_POSICION_UTM;
					V_RUTA : in Q_RUTA.T_RUTA;
					V_PROGRESION : out T_PROGRESION);

	procedure P_VISUALIZAR_PROGRESION (V_PROGRESION : in T_PROGRESION);

	function F_OBTENER_ELEMENTO_ACTUAL_PROGRESION (V_PROGRESION : in T_PROGRESION) return T_ELEMENTO_PROGRESION;

	function F_OBTENER_RESTRICCION (V_ELEMENTO_PROGRESION : in T_ELEMENTO_PROGRESION) return Q_RESTRICCION.T_RESTRICCION;

	function F_OBTENER_ID_TRAMO_ACTUAL (V_ELEMENTO_PROGRESION : in T_ELEMENTO_PROGRESION) return Integer;

	function F_OBTENER_POSICION (V_ELEMENTO_PROGRESION : in T_ELEMENTO_PROGRESION) return Q_TIPOS_BASICOS.T_POSICION_UTM;

	procedure P_ELIMINAR_ELEMENTO_ACTUAL_PROGRESION (V_PROGRESION : in out T_PROGRESION);

	function F_ESTA_PROGRESION_ACABADA (V_PROGRESION : in T_PROGRESION) return Boolean;

	function F_CUANTOS_ELEMENTOS_PROGRESION (V_PROGRESION : in T_PROGRESION) return Natural;

	private

		type T_ELEMENTO_PROGRESION is record

			R_ID_TRAMO_ACTUAL : Integer range 0 .. Q_TRAMO.F_OBTENER_NUMERO_MAXIMO_TRAMOS := 1;

			R_POSICION : Q_TIPOS_BASICOS.T_POSICION_UTM;

			R_RESTRICCION : Q_RESTRICCION.T_RESTRICCION;

		end record;

		function "=" (V_ELEMENTO_PROGRESION_1 : T_ELEMENTO_PROGRESION;
                      	      V_ELEMENTO_PROGRESION_2 : T_ELEMENTO_PROGRESION) return Boolean;

        	package Q_LISTA_PROGRESION is new
                	Q_GENERICO_LISTA 
				(T_ELEMENTO => T_ELEMENTO_PROGRESION,
                                 "=" => "=",
                                 V_MAXIMO_NUMERO_ELEMENTOS => 
					Q_TRAMO.F_OBTENER_NUMERO_MAXIMO_TRAMOS * Q_SEGMENTO.F_OBTENER_NUMERO_MAXIMO_SEGMENTOS);

		type T_PROGRESION is new Q_LISTA_PROGRESION.T_LISTA; 

end Q_PROGRESION;
-----------------
