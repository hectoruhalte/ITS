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

end Q_VEHICULO.Q_ACCIONES;
--------------------------
