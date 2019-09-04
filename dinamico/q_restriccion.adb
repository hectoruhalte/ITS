--------------------------------------------------------------------------------------------------------------------------------------------
--
--      Fichero:        q_restriccion.adb
--
--      Autor:          Hector Uhalte Bilbao
--
--      Fecha:          10/7/2019
--
--------------------------------------------------------------------------------------------------------------------------------------------

package body Q_RESTRICCION is

	--------------------------------------------------------------------
	procedure P_PONER_RESTRICCION (V_VELOCIDAD : in Q_TIPOS_BASICOS.T_VELOCIDAD;
				       V_SENAL : in T_SENAL;
				       V_RESTRICCION : out T_RESTRICCION) is

	begin

		V_RESTRICCION.R_RESTRICCION_VELOCIDAD := V_VELOCIDAD;
		V_RESTRICCION.R_RESTRICCION_SENAL := V_SENAL;

	end P_PONER_RESTRICCION;
	--------------------------------------------------------------------

	-----------------------------------------------------------------------------------------------------------------
	function F_OBTENER_RESTRICCION_VELOCIDAD (V_RESTRICCION : in T_RESTRICCION) return Q_TIPOS_BASICOS.T_VELOCIDAD is

	begin

		return V_RESTRICCION.R_RESTRICCION_VELOCIDAD;

	end F_OBTENER_RESTRICCION_VELOCIDAD;
	-----------------------------------------------------------------------------------------------------------------

	-----------------------------------------------------------------------------------------
	function F_OBTENER_RESTRICCION_SENAL (V_RESTRICCION : in T_RESTRICCION) return T_SENAL is

	begin

		return V_RESTRICCION.R_RESTRICCION_SENAL;

	end F_OBTENER_RESTRICCION_SENAL;
	-----------------------------------------------------------------------------------------


end Q_RESTRICCION;
--------------------------------------------------------------------------------------------------------------------------------------------
