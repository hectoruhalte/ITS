--------------------------------------------------------------------------------------------------------------------------------------------
--
--      Fichero:        q_tipos_remotos.adb
--
--      Autor:          Hector Uhalte Bilbao
--
--      Fecha:          10/9/2020
--
--------------------------------------------------------------------------------------------------------------------------------------------

with Ada.Text_IO;
with GNAT.OS_Lib;

package body Q_TIPOS_REMOTOS is

   -----------------------------------------------------------
   procedure P_NOTIFICAR_REGISTRO (V_TERMINAL_VEHICULO : access T_TERMINAL_VEHICULO;
                                   V_MATRICULA : in String) is

   begin

      Ada.Text_Io.Put_Line (" Ariadna ha registrado el vehiculo : " & V_MATRICULA(V_MATRICULA'First..V_MATRICULA'First+7));
      Ada.Text_IO.Put_Line (" --");

   end;
   -----------------------------------------------------------

   ------------------------------------------------------------------------------------
   procedure P_NOTIFICAR_COLISION (V_TERMINAL_VEHICULO : access T_TERMINAL_VEHICULO;
                                   V_ID_PROCESO : in Integer) is

   begin

      Ada.Text_Io.Put_Line (" --");
      Ada.Text_Io.Put_Line (" El vehiculo ha sufrido una colision ");
      Ada.Text_Io.Put_Line (" --");

   end P_NOTIFICAR_COLISION;
   ------------------------------------------------------------------------------------

end Q_TIPOS_REMOTOS;
--------------------------------------------------------------------------------------------------------------------------------------------
