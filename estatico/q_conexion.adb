--------------------------------------------------------------------------------------------------------------------------------------------
--
--      Fichero:        q_conexion.adb
--
--      Autor:          Hector Uhalte Bilbao
--
--      Fecha:          24/3/2020
--      
--------------------------------------------------------------------------------------------------------------------------------------------

package body Q_CONEXION is

	--------------------------------------------------------------------
	procedure P_INICIALIZAR_CONEXION (V_CONEXION : in out T_CONEXION) is

	begin

		V_CONEXION.R_TRAMO_ID := 0;

		V_CONEXION.R_CARRIL_ACTUAL := 0;

		V_CONEXION.R_CARRIL_SIGUIENTE := 0;

		V_CONEXION.R_RESTRICCION_VELOCIDAD := 0;		

	end P_INICIALIZAR_CONEXION;
	--------------------------------------------------------------------

	--------------------------------------------------------------
	procedure P_PONER_TRAMO_ID (V_TRAMO_ID : in Natural;
				    V_CONEXION : in out T_CONEXION) is

	begin

		V_CONEXION.R_TRAMO_ID := V_TRAMO_ID;

	end P_PONER_TRAMO_ID;
	--------------------------------------------------------------

	-------------------------------------------------------------------
	procedure P_PONER_CARRIL_ACTUAL (V_CARRIL_ACTUAL : in Natural;
					 V_CONEXION : in out T_CONEXION) is

	begin

		V_CONEXION.R_CARRIL_ACTUAL := V_CARRIL_ACTUAL;

	end P_PONER_CARRIL_ACTUAL;
	-------------------------------------------------------------------

	----------------------------------------------------------------------
	procedure P_PONER_CARRIL_SIGUIENTE (V_CARRIL_SIGUIENTE : in Natural;
					    V_CONEXION : in out T_CONEXION) is

	begin

		V_CONEXION.R_CARRIL_SIGUIENTE := V_CARRIL_SIGUIENTE;

	end P_PONER_CARRIL_SIGUIENTE;
	----------------------------------------------------------------------

	---------------------------------------------------------------------------
	procedure P_PONER_RESTRICCION_VELOCIDAD (V_RESTRICCION_VELOCIDAD : in Q_TIPOS_BASICOS.T_VELOCIDAD;
						 V_CONEXION : in out T_CONEXION) is

	begin

		V_CONEXION.R_RESTRICCION_VELOCIDAD := V_RESTRICCION_VELOCIDAD;

	end P_PONER_RESTRICCION_VELOCIDAD;
	---------------------------------------------------------------------------

	----------------------------------------------------------
        function "=" (V_CONEXION_1 : T_CONEXION;
                      V_CONEXION_2 : T_CONEXION) return Boolean is

        begin

                return (V_CONEXION_1.R_TRAMO_ID = V_CONEXION_2.R_TRAMO_ID) and
		       (V_CONEXION_1.R_CARRIL_ACTUAL = V_CONEXION_2.R_CARRIL_ACTUAL) and
		       (V_CONEXION_1.R_CARRIL_SIGUIENTE = V_CONEXION_2.R_CARRIL_SIGUIENTE);	
        
	end "=";
        ----------------------------------------------------------

	--------------------------------------------------------------------------
	function F_OBTENER_TRAMO_ID (V_CONEXION : in T_CONEXION) return Natural is

	begin

		return V_CONEXION.R_TRAMO_ID;

	end F_OBTENER_TRAMO_ID;
	--------------------------------------------------------------------------

end Q_CONEXION;
--------------------------------------------------------------------------------------------------------------------------------------------
