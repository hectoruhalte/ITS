--------------------------------------------------------------------------------------------------------------------------------------------
--
--      Fichero:        q_ruta_stream.ads
--
--      Autor:          Hector Uhalte Bilbao
--
--      Fecha:          23/10/2020
--
--------------------------------------------------------------------------------------------------------------------------------------------

-- Paquete para definir los tipos para transmitir la ruta entre el servidor y los vehiculos.

package Q_RUTA_STREAM is
   
   pragma Pure;

   C_NUMERO_MAXIMO_TRAMOS : constant Integer := 512;
   
   type T_RUTA_STREAM is array (1 .. C_NUMERO_MAXIMO_TRAMOS) of Natural;

end Q_RUTA_STREAM;
------------------
