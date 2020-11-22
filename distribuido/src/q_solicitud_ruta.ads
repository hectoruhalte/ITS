--------------------------------------------------------------------------------------------------------------------------------------------
--
--      Fichero:        q_solicitud_ruta.ads
--
--      Autor:          Hector Uhalte Bilbao
--
--      Fecha:          22/9/2020
--
--------------------------------------------------------------------------------------------------------------------------------------------

-- Paquete para definir el tipo para solicitar una ruta al servidor.
-- Este paquete sera usado tanto por el vehiculo (para formar una peticion), como por el servidor, para encolar la peticion del vehiculo.

with Q_TIPOS_BASICOS;

package Q_SOLICITUD_RUTA is
   
   pragma Pure;

   type T_SOLICITUD_RUTA is private;
   
   procedure P_CREAR_SOLICITUD_RUTA (V_MATRICULA : in String;
                                     V_ORIGEN : in Q_TIPOS_BASICOS.T_POSICION_UTM;
                                     V_DESTINO : in Q_TIPOS_BASICOS.T_POSICION_UTM;
                                     V_SOLICITUD_RUTA : out T_SOLICITUD_RUTA);
   
   function F_OBTENER_MATRICULA (V_SOLICITUD_RUTA : in T_SOLICITUD_RUTA) return String;
   
   function F_OBTENER_ORIGEN (V_SOLICITUD_RUTA : in T_SOLICITUD_RUTA) return Q_TIPOS_BASICOS.T_POSICION_UTM;
   
   function F_OBTENER_DESTINO (V_SOLICITUD_RUTA : in T_SOLICITUD_RUTA) return Q_TIPOS_BASICOS.T_POSICION_UTM;
   
   private
   
   type T_SOLICITUD_RUTA is record
      
      -- Matricula del vehiculo solicitante.
      R_MATRICULA : String (1..8);
      
      R_ORIGEN : Q_TIPOS_BASICOS.T_POSICION_UTM;
      
      R_DESTINO : Q_TIPOS_BASICOS.T_POSICION_UTM;
      
   end record;

end Q_SOLICITUD_RUTA;
---------------------
