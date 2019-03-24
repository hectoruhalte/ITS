--------------------------------------------------------------------------------------------------------------------------------------------
--
--      Fichero:        q_vehiculo.adb
--
--      Autor:          Hector Uhalte Bilbao
--
--      Fecha:          15/9/2017
--      
--------------------------------------------------------------------------------------------------------------------------------------------

with Ada.Text_Io;

package body Q_VEHICULO is

	-------------------------------------------------------------
	-- Funcion para obtener la longitud del numero de bastidor
	-------------------------------------------------------------
	function F_OBTENER_LONGITUD_NUMERO_BASTIDOR return Integer is

	begin

		return C_LONGITUD_NUMERO_BASTIDOR;
		
	end F_OBTENER_LONGITUD_NUMERO_BASTIDOR;
	-------------------------------------------------------------

	--------------------------------------------------------------------------------
	-- Funcion para obtener el numero de bastidor de un vehiculo
	--------------------------------------------------------------------------------
	function F_OBTENER_NUMERO_BASTIDOR (V_VEHICULO : in T_VEHICULO) return String is

	begin

		return V_VEHICULO.R_NUMERO_BASTIDOR;

	end F_OBTENER_NUMERO_BASTIDOR;
	--------------------------------------------------------------------------------

	--------------------------------------------------------------------------
        -- Funcion para obtener la matricula de un vehiculo
        --------------------------------------------------------------------------
        function F_OBTENER_MATRICULA (V_VEHICULO : in T_VEHICULO) return String is

        begin

                return V_VEHICULO.R_MATRICULA;

        end F_OBTENER_MATRICULA;
        --------------------------------------------------------------------------

	-----------------------------------------------------------------------------
        -- Funcion para obtener la marca de un vehiculo
        -----------------------------------------------------------------------------
        function F_OBTENER_NOMBRE_MARCA (V_VEHICULO : in T_VEHICULO) return String is

        begin

                return V_VEHICULO.R_NOMBRE_MARCA;

        end F_OBTENER_NOMBRE_MARCA;
        -----------------------------------------------------------------------------

        -----------------------------------------------------------------------------
        -- Funcion para obtener la marca de un vehiculo
        ------------------------------------------------------------------------------
        function F_OBTENER_NOMBRE_MODELO (V_VEHICULO : in T_VEHICULO) return String is

        begin

                return V_VEHICULO.R_NOMBRE_MODELO;

        end F_OBTENER_NOMBRE_MODELO;
        ------------------------------------------------------------------------------

	------------------------------------------------------------------------------------------------------
	function F_OBTENER_VELOCIDAD_MAXIMA (V_VEHICULO : in T_VEHICULO) return Q_TIPOS_BASICOS.T_VELOCIDAD is

	begin

		return V_VEHICULO.R_VELOCIDAD_MAXIMA;

	end F_OBTENER_VELOCIDAD_MAXIMA;
	------------------------------------------------------------------------------------------------------

	---------------------------------------------------------
	-- Procedimiento para poner la velocidad a un vehiculo.
	---------------------------------------------------------
	procedure P_PONER_VELOCIDAD (V_VEHICULO : in out T_VEHICULO;
				     V_VELOCIDAD : in Integer) is

	begin

		V_VEHICULO.R_VELOCIDAD := Q_TIPOS_BASICOS.F_PONER_VELOCIDAD(V_VELOCIDAD);

	end P_PONER_VELOCIDAD;
	---------------------------------------------------------
	
	------------------------------------------------------------------------------
        -- Procedimiento para poner la posicion a un vehiculo.
        ------------------------------------------------------------------------------
        procedure P_PONER_POSICION (V_VEHICULO : in out T_VEHICULO;
                                    V_POSICION : in Q_TIPOS_BASICOS.T_POSICION_UTM) is

        begin

                V_VEHICULO.R_POSICION := V_POSICION;

        end P_PONER_POSICION;
        -------------------------------------------------------------------------------

	-------------------------------------------------------------
	function "=" (V_VEHICULO_1 : in T_VEHICULO;
		      V_VEHICULO_2 : in T_VEHICULO) return Boolean is
	
		V_SON_IGUALES : Boolean := False;

	begin

		if (V_VEHICULO_1.R_MATRICULA = V_VEHICULO_2.R_MATRICULA) then

			V_SON_IGUALES := True;

		end if;

		return V_SON_IGUALES;

	end "=";
	-------------------------------------------------------------

	---------------------------------------------------------------------------------
	function F_OBTENER_LONGITUD_VEHICULO (V_VEHICULO : in T_VEHICULO) return Float is

	begin

		return V_VEHICULO.R_DIMENSIONES.R_LONGITUD;

	end F_OBTENER_LONGITUD_VEHICULO;
	---------------------------------------------------------------------------------

	-------------------------------------------------------------------------------
	function F_OBTENER_ALTURA_VEHICULO (V_VEHICULO : in T_VEHICULO) return Float is

	begin

		return V_VEHICULO.R_DIMENSIONES.R_ALTURA;

	end F_OBTENER_ALTURA_VEHICULO;
	-------------------------------------------------------------------------------

	------------------------------------------------------------------------
	function F_OBTENER_LONGITUD_MAXIMA_NOMBRE_MARCA_MODELO return Integer is
	
	begin

		return C_LONGITUD_MAXIMA_NOMBRE_MARCA_MODELO;

	end F_OBTENER_LONGITUD_MAXIMA_NOMBRE_MARCA_MODELO;
	------------------------------------------------------------------------

	------------------------------------------------------------------------------
	function F_OBTENER_CONSUMO_URBANO (V_VEHICULO : in T_VEHICULO) return Float is

	begin

		return V_VEHICULO.R_CONSUMO.R_URBANO;

	end F_OBTENER_CONSUMO_URBANO;
	------------------------------------------------------------------------------

	---------------------------------------------------------------------------------
        function F_OBTENER_CONSUMO_CARRETERA (V_VEHICULO : in T_VEHICULO) return Float is

        begin

                return V_VEHICULO.R_CONSUMO.R_CARRETERA;

        end F_OBTENER_CONSUMO_CARRETERA;
        ----------------------------------------------------------------------------------

	-----------------------------------------------
	function F_OBTENER_MARCA_VACIA return String is

	begin

		return C_MARCA_VACIA;

	end F_OBTENER_MARCA_VACIA;
	-----------------------------------------------

	------------------------------------------------
	function F_OBTENER_MODELO_VACIO return String is

	begin

		return C_MODELO_VACIO;

	end F_OBTENER_MODELO_VACIO;
	------------------------------------------------

end Q_VEHICULO;
--------------------------------------------------------------------------------------------------------------------------------------------
