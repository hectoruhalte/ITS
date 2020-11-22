--------------------------------------------------------------------------------------------------------------------------------------------
--
--      Fichero:        q_tipos_remotos.ads
--
--      Autor:          Hector Uhalte Bilbao
--
--      Fecha:          26/8/2020
--
--------------------------------------------------------------------------------------------------------------------------------------------

-- Paquete para definir tipos remotos e implementar los tipos y procedimientos abstractos.

with Q_TERMINAL;

package Q_TIPOS_REMOTOS is

   pragma Remote_Types;
   
   type T_TERMINAL_VEHICULO is new Q_TERMINAL.T_TERMINAL with null record;
   
   procedure P_NOTIFICAR_REGISTRO (V_TERMINAL_VEHICULO : access T_TERMINAL_VEHICULO;
                                   V_MATRICULA : in String);

end Q_TIPOS_REMOTOS;
--------------------
