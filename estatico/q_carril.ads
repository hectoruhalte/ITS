--------------------------------------------------------------------------------------------------------------------------------------------
--
--      Fichero:        q_carril.ads
--
--      Autor:          Hector Uhalte Bilbao
--
--      Fecha:          1/2/2018
--      
--------------------------------------------------------------------------------------------------------------------------------------------

-- Paquete para presentar el tipo T_CARRIL

package Q_CARRIL is

	type T_CARRIL is private;

	-- Funcion necesaria para instanciar el paquete Q_GENERICO_LISTA para crear listas de carriles.
	function "=" (V_CARRIL_1 : in T_CARRIL;
		      V_CARRIL_2 : in T_CARRIL) return Boolean;

	function F_OBTENER_NUMERO_MAXIMO_CARRILES return Integer;

	function F_ESTA_CARRIL_OCUPADO (V_CARRIL : in T_CARRIL) return Boolean;

	procedure P_PONER_CARRIL_OCUPADO (V_OCUPADO : in Boolean;
					  V_CARRIL : in out T_CARRIL);

	function F_ESTA_CARRIL_DISPONIBLE (V_CARRIL : in T_CARRIL) return Boolean;

	procedure P_PONER_CARRIL_DISPONIBLE (V_DISPONIBLE : in Boolean;
					     V_CARRIL : in out T_CARRIL);

	private

		-- Constante para definir el numero maximo de carriles por segmento.    
                C_NUMERO_MAXIMO_CARRILES : constant Integer := 10;

		-- Tipo para almacenar los carriles de un segmento.
                type T_CARRIL is record

                        -- En el carril voy a guardar si esta ocupado o no, si hay un vehiculo en ese carril.
                        -- Ocupado=True, Libre=False. Por defecto estara libre. Util para saber exactamente donde estan los vehiculos 
                        R_OCUPADO : Boolean := False;

                        -- Para saber si un carril esta abierto o no a la circulacion.
                        -- Por defecto estara disponible.
                        R_DISPONIBLE : Boolean := True;

                end record;

end Q_CARRIL;
-------------
