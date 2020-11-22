--------------------------------------------------------------------------------------------------------------------------------------------
--
--      Fichero:        m_monitor_tabla_trayectos.adb
--
--      Autor:          Hector Uhalte Bilbao
--
--      Fecha:          7/11/2020
--
--------------------------------------------------------------------------------------------------------------------------------------------

-- Ejecutable para mostrar la tabla de trayectos.

with Ada.Text_IO;
with Q_TABLA_TRAYECTOS.Q_ACCIONES;

procedure m_monitor_tabla_trayectos is

begin

   Ada.Text_Io.Put_Line (" Lector tabla trayectos");
   Ada.Text_IO.Put_Line ("");

   loop

      Q_TABLA_TRAYECTOS.Q_ACCIONES.P_VISUALIZAR_TABLA (Q_TABLA_TRAYECTOS.F_OBTENER_TABLA_TRAYECTOS);

      delay 1.0;

   end loop;

end m_monitor_tabla_trayectos;
--------------------------------------------------------------------------------------------------------------------------------------------
