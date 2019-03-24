--------------------------------------------------------------------------------------------------------------------------------------------
--
--      Fichero:        q_carril.adb
--
--      Autor:          Hector Uhalte Bilbao
--
--      Fecha:          1/2/2018
--      
--------------------------------------------------------------------------------------------------------------------------------------------

package body Q_CARRIL is

	---------------------------------------------------------
	function "=" (V_CARRIL_1 : in T_CARRIL;
		      V_CARRIL_2 : in T_CARRIL) return Boolean is

	begin

		-- Nunca vamos a comparar dos carriles entre si.
		return False;

	end "=";
	---------------------------------------------------------

	-----------------------------------------------------------
	function F_OBTENER_NUMERO_MAXIMO_CARRILES return Integer is

	begin

		return C_NUMERO_MAXIMO_CARRILES;

	end F_OBTENER_NUMERO_MAXIMO_CARRILES;
	-----------------------------------------------------------

	-------------------------------------------------------------------------
	function F_ESTA_CARRIL_OCUPADO (V_CARRIL : in T_CARRIL) return Boolean is

	begin
	
		return V_CARRIL.R_OCUPADO;

	end F_ESTA_CARRIL_OCUPADO;
	-------------------------------------------------------------------------

	----------------------------------------------------------------
	procedure P_PONER_CARRIL_OCUPADO (V_OCUPADO : in Boolean;
					  V_CARRIL : in out T_CARRIL) is

	begin

		V_CARRIL.R_OCUPADO := V_OCUPADO;

	end P_PONER_CARRIL_OCUPADO;
	----------------------------------------------------------------

	----------------------------------------------------------------------------
	function F_ESTA_CARRIL_DISPONIBLE (V_CARRIL : in T_CARRIL) return Boolean is

	begin

		return V_CARRIL.R_DISPONIBLE;

	end F_ESTA_CARRIL_DISPONIBLE;
	----------------------------------------------------------------------------

	-------------------------------------------------------------------
	procedure P_PONER_CARRIL_DISPONIBLE (V_DISPONIBLE : in Boolean;
					     V_CARRIL : in out T_CARRIL) is

	begin

		V_CARRIL.R_DISPONIBLE := V_DISPONIBLE;

	end P_PONER_CARRIL_DISPONIBLE;
	-------------------------------------------------------------------

end Q_CARRIL;
--------------------------------------------------------------------------------------------------------------------------------------------
