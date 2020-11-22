--------------------------------------------------------------------------------------------------------------------------------------------
--
--      Fichero:        q_conexion.ads
--
--      Autor:          Hector Uhalte Bilbao
--
--      Fecha:          24/3/2020
--      
--------------------------------------------------------------------------------------------------------------------------------------------

with Q_TIPOS_BASICOS;

-- Paquete para presentar el tipo T_CONEXION entre tramos.

package Q_CONEXION is
   
   pragma Pure;

	type T_CONEXION is private;

	procedure P_INICIALIZAR_CONEXION (V_CONEXION : in out T_CONEXION);

	procedure P_PONER_TRAMO_ID (V_TRAMO_ID : in Natural;
				    V_CONEXION : in out T_CONEXION);

	procedure P_PONER_CARRIL_ACTUAL (V_CARRIL_ACTUAL : in Natural;
					 V_CONEXION : in out T_CONEXION);

	procedure P_PONER_CARRIL_SIGUIENTE (V_CARRIL_SIGUIENTE : in Natural;
					    V_CONEXION : in out T_CONEXION);

	procedure P_PONER_RESTRICCION_VELOCIDAD (V_RESTRICCION_VELOCIDAD : in Q_TIPOS_BASICOS.T_VELOCIDAD;
						 V_CONEXION : in out T_CONEXION);

	-- Funcion necesaria para instanciar el paquete Q_GENERICO_LISTA para crear listas de segmentos.
        function "=" (V_CONEXION_1 : in T_CONEXION;
                      V_CONEXION_2 : in T_CONEXION) return Boolean;

	function F_OBTENER_TRAMO_ID (V_CONEXION : in T_CONEXION) return Natural;

	private

		type T_CONEXION is record

			-- Id del tramo al que se conecta el tramo al que pertenece la conexion.
			R_TRAMO_ID : Natural;

			-- Carril del tramo al que pertenece la conexion
			R_CARRIL_ACTUAL : Natural;

			-- Carril del tramo al que se que conecta el tramo al que pertenece la conexion.
			R_CARRIL_SIGUIENTE : Natural;

			-- Restricion fisica de la velocidad del coche en la conexion entre los dos tramos
			R_RESTRICCION_VELOCIDAD : Q_TIPOS_BASICOS.T_VELOCIDAD;

		end record;

end Q_CONEXION;
---------------
