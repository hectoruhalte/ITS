--------------------------------------------------------------------------------------------------------------------------------------------
--
--      Fichero:        q_trayecto-q_acciones.ads
--
--      Autor:          Hector Uhalte Bilbao
--
--      Fecha:          1/7/2019
--
--------------------------------------------------------------------------------------------------------------------------------------------

package Q_TRAYECTO.Q_ACCIONES is

	procedure P_VISUALIZAR_CABECERA_ESTATICA_TRAYECTO;

	procedure P_VISUALIZAR_PARTE_ESTATICA_TRAYECTO (V_TRAYECTO : in T_TRAYECTO);

	procedure P_VISUALIZAR_CABECERA_DINAMICA_TRAYECTO;

	procedure P_VISUALIZAR_PARTE_DINAMICA_TRAYECTO (V_TRAYECTO : in T_TRAYECTO);

	procedure P_ACTUALIZAR_TRAYECTO (V_TRAYECTO : in out T_TRAYECTO);

end Q_TRAYECTO.Q_ACCIONES;
--------------------------
