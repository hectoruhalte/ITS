--------------------------------------------------------------------------------------------------------------------------------------------
--
--      Fichero:        q_trayecto-q_acciones.ads
--
--      Autor:          Hector Uhalte Bilbao
--
--      Fecha:          1/7/2019
--
--------------------------------------------------------------------------------------------------------------------------------------------

with Q_ADAPTACION_TRAMO;

package Q_TRAYECTO.Q_ACCIONES is

	procedure P_VISUALIZAR_CABECERA_ESTATICA_TRAYECTO;

   	procedure P_VISUALIZAR_PARTE_ESTATICA_TRAYECTO (V_TRAYECTO : in T_TRAYECTO;
        	                                        V_LISTA_TRAMOS_ADAPTACION : in Q_ADAPTACION_TRAMO.Q_LISTA_TRAMOS.T_LISTA);

	procedure P_VISUALIZAR_CABECERA_DINAMICA_TRAYECTO;

   	procedure P_VISUALIZAR_PARTE_DINAMICA_TRAYECTO (V_TRAYECTO : in T_TRAYECTO;
                                                        V_LISTA_TRAMOS_ADAPTACION : in Q_ADAPTACION_TRAMO.Q_LISTA_TRAMOS.T_LISTA);

	procedure P_ACTUALIZAR_TRAYECTO (V_TRAYECTO : in out T_TRAYECTO);

end Q_TRAYECTO.Q_ACCIONES;
--------------------------
