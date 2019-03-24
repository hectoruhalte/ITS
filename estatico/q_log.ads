--------------------------------------------------------------------------------------------------------------------------------------------
--
--      Fichero:        q_log.ads
--
--      Autor:          Hector Uhalte Bilbao
--
--      Fecha:          11/9/2017
--      
--------------------------------------------------------------------------------------------------------------------------------------------

-- Paquete para escribir en los ficheros de log

package Q_LOG is

	procedure P_ESCRIBIR_LOG (V_STRING : in String;
				  V_NOMBRE_FICHERO : in String);

end Q_LOG;
----------
