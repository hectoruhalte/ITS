--------------------------------------------------------------------------------------------------------------------------------------------
--
--      Fichero:        q_trayecto.adb
--
--      Autor:          Hector Uhalte Bilbao
--
--      Fecha:          28/6/2019
--
--------------------------------------------------------------------------------------------------------------------------------------------

with Q_RESTRICCION;

with Ada.Text_Io;

package body Q_TRAYECTO is

	-------------------------------------------------------------------
	function F_OBTENER_ID (V_TRAYECTO : in T_TRAYECTO) return String is

	begin
		
		return V_TRAYECTO.R_ID;

	end F_OBTENER_ID;
	-------------------------------------------------------------------

	--------------------------------------------------------------------------------------------------------
	function F_OBTENER_POSICION_ORIGEN (V_TRAYECTO : in T_TRAYECTO) return Q_TIPOS_BASICOS.T_POSICION_UTM is

	begin

		return V_TRAYECTO.R_POSICION_ORIGEN;

	end F_OBTENER_POSICION_ORIGEN;
	--------------------------------------------------------------------------------------------------------

	-------------------------------------------------------------------------------------------------------
        function F_OBTENER_POSICION_FINAL (V_TRAYECTO : in T_TRAYECTO) return Q_TIPOS_BASICOS.T_POSICION_UTM is

        begin

                return V_TRAYECTO.R_POSICION_FINAL;

        end F_OBTENER_POSICION_FINAL;
        -------------------------------------------------------------------------------------------------------
	
	---------------------------------------------------------------------------------------
	function F_OBTENER_HORA_SALIDA (V_TRAYECTO : in T_TRAYECTO) return Ada.Calendar.Time is

	begin

		return V_TRAYECTO.R_HORA_SALIDA;

	end F_OBTENER_HORA_SALIDA;
	---------------------------------------------------------------------------------------

	----------------------------------------------------------------------------------------------
	function F_OBTENER_PROGRESION (V_TRAYECTO : in T_TRAYECTO) return Q_PROGRESION.T_PROGRESION is

	begin

		return V_TRAYECTO.R_PROGRESION;
		
	end F_OBTENER_PROGRESION;
	----------------------------------------------------------------------------------------------

	--------------------------------------------------------------------------
	function F_OBTENER_DURACION (V_TRAYECTO : in T_TRAYECTO) return Integer is

	begin

		return V_TRAYECTO.R_DURACION;

	end F_OBTENER_DURACION;
	--------------------------------------------------------------------------

	---------------------------------------------------------------------------
        function F_OBTENER_DISTANCIA (V_TRAYECTO : in T_TRAYECTO) return Integer is

        begin

                return V_TRAYECTO.R_DISTANCIA;

        end F_OBTENER_DISTANCIA;
        ---------------------------------------------------------------------------

	-------------------------------------------------------------------------
	function F_OBTENER_ESTADO (V_TRAYECTO : in T_TRAYECTO) return T_ESTADO is

	begin

		return V_TRAYECTO.R_ESTADO;

	end F_OBTENER_ESTADO;
	-------------------------------------------------------------------------

	------------------------------------------------------------
	procedure P_PONER_ESTADO (V_ESTADO : in T_ESTADO;
				  V_TRAYECTO : in out T_TRAYECTO) is

	begin

		V_TRAYECTO.R_ESTADO := V_ESTADO;

	end P_PONER_ESTADO;
	------------------------------------------------------------

	---------------------------------------------------------------------------------
	function F_ESTA_TRAYECTO_TERMINADO (V_TRAYECTO : in T_TRAYECTO) return Boolean is

	begin

		return V_TRAYECTO.R_ESTADO = E_TERMINADO;

	end F_ESTA_TRAYECTO_TERMINADO;
	---------------------------------------------------------------------------------

	------------------------------------------------------------------------------------------------------
        function F_OBTENER_VELOCIDAD_ACTUAL (V_TRAYECTO : in T_TRAYECTO) return Q_TIPOS_BASICOS.T_VELOCIDAD is

        begin

                return V_TRAYECTO.R_VELOCIDAD_ACTUAL;

        end F_OBTENER_VELOCIDAD_ACTUAL;
        ------------------------------------------------------------------------------------------------------

	--------------------------------------------------------------------------------------------------------
        function F_OBTENER_POSICION_ACTUAL (V_TRAYECTO : in T_TRAYECTO) return Q_TIPOS_BASICOS.T_POSICION_UTM is

        begin

                return V_TRAYECTO.R_POSICION_ACTUAL;

        end F_OBTENER_POSICION_ACTUAL;
        --------------------------------------------------------------------------------------------------------

	-------------------------------------------------------------------------------------
	function F_OBTENER_TIEMPO_TRANSCURRIDO (V_TRAYECTO : in T_TRAYECTO) return Integer is

	begin

		return V_TRAYECTO.R_TIEMPO_TRANSCURRIDO;

	end F_OBTENER_TIEMPO_TRANSCURRIDO;
	-------------------------------------------------------------------------------------

	----------------------------------------------------------------------------------------
	function F_OBTENER_DISTANCIA_POR_RECORRER (V_TRAYECTO : in T_TRAYECTO) return Float is

	begin

		return V_TRAYECTO.R_DISTANCIA_POR_RECORRER;

	end F_OBTENER_DISTANCIA_POR_RECORRER;
	----------------------------------------------------------------------------------------

	-----------------------------------------------------------
	procedure P_CREAR_TRAYECTO (V_VEHICULO : in Q_VEHICULO.T_VEHICULO;
				    V_POSICION_ORIGEN : in Q_TIPOS_BASICOS.T_POSICION_UTM;
                                    V_POSICION_FINAL : in Q_TIPOS_BASICOS.T_POSICION_UTM;
                                    V_HORA_SALIDA : in Ada.Calendar.Time := Ada.Calendar.Clock;
                                    V_DURACION : in Integer;
                                    V_DISTANCIA : in Integer;
				    V_RUTA : in Q_RUTA.T_RUTA;
                                    V_TRAYECTO : out T_TRAYECTO) is

	begin

		V_TRAYECTO.R_ID := Q_VEHICULO.F_OBTENER_MATRICULA (V_VEHICULO);

		V_TRAYECTO.R_POSICION_ORIGEN := V_POSICION_ORIGEN;

		V_TRAYECTO.R_ID_TRAMO_ORIGEN := Q_TRAMO.F_OBTENER_ID (Q_RUTA.Q_LISTA_TRAMOS.F_DEVOLVER_ELEMENTO (V_POSICION => 1,
														 V_LISTA => V_RUTA));

		V_TRAYECTO.R_POSICION_FINAL := V_POSICION_FINAL;

		V_TRAYECTO.R_ID_TRAMO_DESTINO := 
			Q_TRAMO.F_OBTENER_ID 
				(Q_RUTA.Q_LISTA_TRAMOS.F_DEVOLVER_ELEMENTO 
					(V_POSICION => Q_RUTA.Q_LISTA_TRAMOS.F_CUANTOS_ELEMENTOS (V_RUTA),
					 V_LISTA => V_RUTA));

		V_TRAYECTO.R_HORA_SALIDA := V_HORA_SALIDA;
		
		V_TRAYECTO.R_DURACION := V_DURACION;

		V_TRAYECTO.R_DISTANCIA := V_DISTANCIA;

		Q_PROGRESION.P_GENERAR_PROGRESION (V_POSICION_INICIAL => V_POSICION_ORIGEN,
						   V_POSICION_FINAL => V_POSICION_FINAL,
						   V_RUTA => V_RUTA,
						   V_PROGRESION => V_TRAYECTO.R_PROGRESION);
									      
		
		-- Al crear el trayecto la posicion actual sera la de origen.
		V_TRAYECTO.R_POSICION_ACTUAL := V_POSICION_ORIGEN;

		-- Al crear el trayecto (de momento de asume que siempre se parte de parado) al velocidad inicial sera 0.
		V_TRAYECTO.R_VELOCIDAD_ACTUAL := 0;

		-- Al crear el trayecto el tiempo trasncurrido se pondra a 0.
		V_TRAYECTO.R_TIEMPO_TRANSCURRIDO := 0;

		-- Al crear el trayecto se asume que la distancia por recorrer el las distancia de la ruta.
		V_TRAYECTO.R_DISTANCIA_POR_RECORRER := Float(V_DISTANCIA);	

	end P_CREAR_TRAYECTO;
	-----------------------------------------------------------

end Q_TRAYECTO;
--------------------------------------------------------------------------------------------------------------------------------------------