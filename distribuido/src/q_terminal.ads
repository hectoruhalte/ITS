--------------------------------------------------------------------------------------------------------------------------------------------
--
--      Fichero:        q_terminal.ads
--
--      Autor:          Hector Uhalte Bilbao
--
--      Fecha:          26/8/2020
--
--------------------------------------------------------------------------------------------------------------------------------------------

-- Paquete para definir el tipo terminal.

package Q_TERMINAL is

   pragma Pure;
   
   type T_TERMINAL is abstract tagged limited private;
   
   procedure P_NOTIFICAR_REGISTRO (V_TERMINAL_VEHICULO : access T_TERMINAL;
                                   V_MATRICULA : in String) is abstract;
   
private
   
   type T_TERMINAL is abstract tagged limited null record;

end Q_TERMINAL;
---------------
