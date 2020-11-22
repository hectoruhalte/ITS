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

package body Q_TIPOS_REMOTOS is

   -----------------------------------------------------------
   procedure P_NOTIFICAR_REGISTRO (V_TERMINAL_VEHICULO : access T_TERMINAL_VEHICULO;
                                   V_MATRICULA : in String) is

   begin

      Ada.Text_Io.Put_Line (" Ariadna ha registrado el vehiculo : " & V_MATRICULA(V_MATRICULA'First..V_MATRICULA'First+7));
      Ada.Text_IO.Put_Line (" --");

   end;
   -----------------------------------------------------------

end Q_TIPOS_REMOTOS;
--------------------------------------------------------------------------------------------------------------------------------------------
