--------------------------------------------------------------------------------------------------------------------------------------------
--
--      Fichero:        q_servidor.ads
--
--      Autor:          Hector Uhalte Bilbao
--
--      Fecha:          26/8/2020
--
--------------------------------------------------------------------------------------------------------------------------------------------

-- Paquete para definir tipos y procedimientos del servidor.

with Q_TERMINAL;
with Q_SOLICITUD_RUTA;
with Q_RUTA_STREAM;
with Q_DATOS_TRAYECTO_STREAM;

package Q_SERVIDOR is

   pragma Remote_Call_Interface;
   
   type T_TERMINAL_ACCESS is access all Q_TERMINAL.T_TERMINAL'Class;
   
   procedure P_REGISTRAR (V_ID_PROCESO : in Integer;
                          V_TERMINAL : T_TERMINAL_ACCESS;
                          V_MATRICULA : in String;
                          V_REGISTRADO : out Boolean);
   
   procedure P_SOLICITAR_RUTA (V_SOLICITUD_RUTA : in Q_SOLICITUD_RUTA.T_SOLICITUD_RUTA;
                               V_LONGITUD_RUTA : out Natural;
                               V_RUTA_STREAM : out Q_RUTA_STREAM.T_RUTA_STREAM;
                               V_COSTE_TIEMPO : out Integer;
                               V_COSTE_DISTANCIA : out Integer;
                               V_TRAYECTO_ID : out Natural);
   
   procedure P_INSERTAR_TRAYECTO_EN_TABLA_TRAYECTOS (V_DATOS_TRAYECTO_STREAM : in Q_DATOS_TRAYECTO_STREAM.T_DATOS_TRAYECTO_STREAM);
   
   procedure P_ACTUALIZAR_TRAYECTO (V_DATOS_TRAYECTO_STREAM : in Q_DATOS_TRAYECTO_STREAM.T_DATOS_TRAYECTO_STREAM);
   
   procedure P_ELIMINAR_TRAYECTO (V_TRAYECTO_ID : in Natural);
   
   --
   -- Procedimiento para terminar el cliente que haya tenido una colision.
   procedure P_NOTIFICAR_COLISION (V_MATRICULA : in String);

end Q_SERVIDOR;
---------------
