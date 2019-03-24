--------------------------------------------------------------------------------------------------------------------------------------------
--
--      Fichero:        q_segmento.adb
--
--      Autor:          Hector Uhalte Bilbao
--
--      Fecha:          1/2/2018
--      
--------------------------------------------------------------------------------------------------------------------------------------------

package body Q_SEGMENTO is

	----------------------------------------------------------
	function "=" (V_SEGMENTO_1 : T_SEGMENTO;
		      V_SEGMENTO_2 : T_SEGMENTO) return Boolean is

        begin

                return (Q_TIPOS_BASICOS.F_OBTENER_COORDENADA_X(V_SEGMENTO_1.R_POSICION) =
                        Q_TIPOS_BASICOS.F_OBTENER_COORDENADA_X(V_SEGMENTO_2.R_POSICION) and

                        Q_TIPOS_BASICOS.F_OBTENER_COORDENADA_Y(V_SEGMENTO_1.R_POSICION) =
                        Q_TIPOS_BASICOS.F_OBTENER_COORDENADA_Y(V_SEGMENTO_2.R_POSICION));

	end "=";
	----------------------------------------------------------

	------------------------------------------------------------
	function F_OBTENER_NUMERO_MAXIMO_SEGMENTOS return Integer is

	begin

		return C_NUMERO_MAXIMO_SEGMENTOS;

	end F_OBTENER_NUMERO_MAXIMO_SEGMENTOS;
	------------------------------------------------------------

	--------------------------------------------------------------------
	procedure P_INICIALIZAR_SEGMENTO (V_SEGMENTO : in out T_SEGMENTO) is

		V_LISTA_CARRILES : Q_LISTA_CARRILES.T_LISTA;

	begin

		V_SEGMENTO.R_POSICION := Q_TIPOS_BASICOS.F_OBTENER_POSICION_UTM (V_X => 0,
										 V_Y => 0);

		Q_LISTA_CARRILES.P_INICIALIZAR_LISTA (V_LISTA_CARRILES);

		V_SEGMENTO.R_CARRILES := V_LISTA_CARRILES;

		V_SEGMENTO.R_DOBLE_SENTIDO := False;

		V_SEGMENTO.R_DISPONIBLE := True;

	end P_INICIALIZAR_SEGMENTO;
	--------------------------------------------------------------------

	-------------------------------------------------------------------------------------------------
	function F_OBTENER_POSICION (V_SEGMENTO : in T_SEGMENTO) return Q_TIPOS_BASICOS.T_POSICION_UTM is

	begin

		return V_SEGMENTO.R_POSICION;

	end F_OBTENER_POSICION;
	-------------------------------------------------------------------------------------------------

	--------------------------------------------------------------
	procedure P_PONER_POSICION (V_POSICION : in Q_TIPOS_BASICOS.T_POSICION_UTM;
				    V_SEGMENTO : in out T_SEGMENTO) is

	begin

		V_SEGMENTO.R_POSICION := V_POSICION;

	end P_PONER_POSICION;
	--------------------------------------------------------------

	-------------------------------------------------------------------------------------------------
	function F_OBTENER_LISTA_CARRILES (V_SEGMENTO : in T_SEGMENTO) return Q_LISTA_CARRILES.T_LISTA is

	begin

		return V_SEGMENTO.R_CARRILES;

	end F_OBTENER_LISTA_CARRILES;
	-------------------------------------------------------------------------------------------------

	--------------------------------------------------------------------
	procedure P_PONER_LISTA_CARRILES (V_NUMERO_CARRILES : in Integer;
					  V_SEGMENTO : in out T_SEGMENTO) is

		V_LISTA_CARRILES : Q_LISTA_CARRILES.T_LISTA;

		V_CARRIL : Q_CARRIL.T_CARRIL;

	begin

		Q_LISTA_CARRILES.P_INICIALIZAR_LISTA (V_LISTA_CARRILES);

		for I in 1 .. V_NUMERO_CARRILES loop

			Q_LISTA_CARRILES.P_INSERTAR_ELEMENTO (V_ELEMENTO => V_CARRIL,
							      V_LISTA => V_LISTA_CARRILES);

		end loop;

		V_SEGMENTO.R_CARRILES := V_LISTA_CARRILES;

	end P_PONER_LISTA_CARRILES;
	--------------------------------------------------------------------

	-------------------------------------------------------------------------------
	function F_OBTENER_DOBLE_SENTIDO (V_SEGMENTO : in T_SEGMENTO) return Boolean is

	begin

		return V_SEGMENTO.R_DOBLE_SENTIDO;

	end F_OBTENER_DOBLE_SENTIDO;
	-------------------------------------------------------------------------------

	-------------------------------------------------------------------
	procedure P_PONER_DOBLE_SENTIDO (V_DOBLE_SENTIDO : in Boolean;
					 V_SEGMENTO : in out T_SEGMENTO) is

	begin

		V_SEGMENTO.R_DOBLE_SENTIDO := V_DOBLE_SENTIDO;

	end P_PONER_DOBLE_SENTIDO;
	-------------------------------------------------------------------

	----------------------------------------------------------------------------
	function F_OBTENER_DISPONIBLE (V_SEGMENTO : in T_SEGMENTO) return Boolean is

	begin

		return V_SEGMENTO.R_DISPONIBLE;

	end F_OBTENER_DISPONIBLE;
	----------------------------------------------------------------------------

	----------------------------------------------------------------
	procedure P_PONER_DISPONIBLE (V_DISPONIBLE : in Boolean;
				      V_SEGMENTO : in out T_SEGMENTO) is

	begin

		V_SEGMENTO.R_DISPONIBLE := V_DISPONIBLE;

	end P_PONER_DISPONIBLE;
	----------------------------------------------------------------

end Q_SEGMENTO;
--------------------------------------------------------------------------------------------------------------------------------------------
