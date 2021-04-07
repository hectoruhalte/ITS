--------------------------------------------------------------------------------------------------------------------------------------------
--
--      Fichero:        q_tabla_trayectos-q_acciones.ads
--
--      Autor:          Hector Uhalte Bilbao
--
--      Fecha:          20/11/2020
--
--------------------------------------------------------------------------------------------------------------------------------------------

with Q_ADAPTACION_TRAMO;

package Q_TABLA_TRAYECTOS.Q_ACCIONES is

   procedure P_VISUALIZAR_TABLA (V_TABLA_TRAYECTOS : in T_TABLA_TRAYECTOS;
                                 V_LISTA_TRAMOS_ADAPTACION : in Q_ADAPTACION_TRAMO.Q_LISTA_TRAMOS.T_LISTA);

   procedure P_ESCRIBIR_TABLA_FICHERO_TEXTO  (V_TABLA_TRAYECTOS : in T_TABLA_TRAYECTOS);

   procedure P_VISUALIZAR_CABECERA;

   procedure P_VISUALIZAR_TRAYECTO (V_TRAYECTO : in T_ELEMENTO_TABLA_DATOS_TRAYECTOS);

end Q_TABLA_TRAYECTOS.Q_ACCIONES;
---------------------------------
