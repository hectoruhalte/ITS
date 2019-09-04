--------------------------------------------------------------------------------------------------------------------------------------------
--
--      Fichero:        q_vehiculo-q_acciones.ads
--
--      Autor:          Hector Uhalte Bilbao
--
--      Fecha:          16/11/2017
--      
--------------------------------------------------------------------------------------------------------------------------------------------

package Q_VEHICULO.Q_ACCIONES is

	X_MARCA_NO_ADAPTADA : Exception;
	X_MODELO_NO_ADAPTADO : Exception;

	procedure P_CREAR_VEHICULO (V_NUMERO_BASTIDOR : in String;
                                    V_MATRICULA : in String;
                                    V_NOMBRE_MARCA : in String;
                                    V_NOMBRE_MODELO : in String;
                                    V_VEHICULO : out T_VEHICULO);

	-- Procedimiento para generar vehiculos aleatoriamente
	procedure P_GENERAR_VEHICULO (V_VEHICULO : out T_VEHICULO);

	procedure P_MOSTRAR_VEHICULO (V_VEHICULO : in T_VEHICULO);

	-- Procedimiento para acelerar un vehiculo.
	procedure P_ACELERAR_VEHICULO (V_VELOCIDAD_MAXIMA_TRAMO : in Q_TIPOS_BASICOS.T_VELOCIDAD;
				       V_VELOCIDAD_INICIAL : in Q_TIPOS_BASICOS.T_VELOCIDAD;
				       V_VELOCIDAD_FINAL : out Q_TIPOS_BASICOS.T_VELOCIDAD;
				       V_T : out Integer);

	-- Funcion para determinar la distancia a mover un vehiculo.
	function F_OBTENER_DISTANCIA_MOVER_VEHICULO (V_VELOCIDAD_INICIAL : in Q_TIPOS_BASICOS.T_VELOCIDAD;
					             V_VELOCIDAD_FINAL : in Q_TIPOS_BASICOS.T_VELOCIDAD;
						     V_VELOCIDAD_MAXIMA_TRAMO : in Q_TIPOS_BASICOS.T_VELOCIDAD;
						     V_T : in Integer) return Float;

end Q_VEHICULO.Q_ACCIONES;
--------------------------
