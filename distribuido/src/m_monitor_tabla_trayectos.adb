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
with Q_ADAPTACION_TRAMO;
with Q_TABLA_TRAYECTOS.Q_ACCIONES;
with GNAT.OS_Lib;
with Ada.Characters.Latin_1;
with Q_SERVIDOR;

procedure m_monitor_tabla_trayectos is

   -- Variables para la ejecucion del comando linux clear
   V_ARGUMENTOS : GNAT.OS_Lib.Argument_List := (1 => new String'(""));
   V_ARGUMENTOS_2 : GNAT.OS_Lib.Argument_List := (1 => new String'("media/crash.mp3"));
   V_RESULTADO : Boolean := False;

   V_LISTA_TRAMOS_ADAPTACION : Q_ADAPTACION_TRAMO.Q_LISTA_TRAMOS.T_LISTA;

begin

   Ada.Text_Io.Put_Line (" Lector tabla trayectos");
   Ada.Text_IO.Put_Line ("");

   delay 2.0;

   Q_ADAPTACION_TRAMO.Q_LISTA_TRAMOS.P_INICIALIZAR_LISTA (V_LISTA_TRAMOS_ADAPTACION);

   --Cargar la lista de tramos adaptados.
   Q_ADAPTACION_TRAMO.P_GENERAR_LISTA_TRAMOS (V_LISTA_TRAMOS_ADAPTACION);

   loop

      GNAT.OS_Lib.Spawn (Program_Name => "/usr/bin/clear",
                         Args         => V_ARGUMENTOS,
                         Success      => V_RESULTADO);

      Q_TABLA_TRAYECTOS.Q_ACCIONES.P_VISUALIZAR_TABLA (V_TABLA_TRAYECTOS         => Q_TABLA_TRAYECTOS.F_OBTENER_TABLA_TRAYECTOS,
                                                       V_LISTA_TRAMOS_ADAPTACION => V_LISTA_TRAMOS_ADAPTACION);

      exit when Q_TABLA_TRAYECTOS.F_HAY_COLISION;

      delay 1.0;

   end loop;

   -- Notificar al servidor los vehiculos que han tenido una colision. Cada colision implica a 2 vehiculos.
   for I in 1 .. Q_TABLA_TRAYECTOS.F_OBTENER_NUMERO_COLISIONES*2 loop

      Q_SERVIDOR.P_NOTIFICAR_COLISION (Q_TABLA_TRAYECTOS.F_OBTENER_MATRICULA_COLISION(I));

   end loop;

   GNAT.OS_Lib.Spawn (Program_Name => "/usr/bin/mpg123",
                      Args         => V_ARGUMENTOS_2,
                      Success      => V_RESULTADO);

end m_monitor_tabla_trayectos;
--------------------------------------------------------------------------------------------------------------------------------------------
