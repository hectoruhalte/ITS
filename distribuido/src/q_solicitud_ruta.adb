--------------------------------------------------------------------------------------------------------------------------------------------
--
--      Fichero:        q_solicitud_ruta.adb
--
--      Autor:          Hector Uhalte Bilbao
--
--      Fecha:          22/9/2020
--
--------------------------------------------------------------------------------------------------------------------------------------------

package body Q_SOLICITUD_RUTA is

   -----------------------------------------------------------------------------
   procedure P_CREAR_SOLICITUD_RUTA (V_MATRICULA : in String;
                                     V_ORIGEN : in Q_TIPOS_BASICOS.T_POSICION_UTM;
                                     V_DESTINO : in Q_TIPOS_BASICOS.T_POSICION_UTM;
                                     V_SOLICITUD_RUTA : out T_SOLICITUD_RUTA) is

   begin

      V_SOLICITUD_RUTA.R_MATRICULA := V_MATRICULA(V_MATRICULA'First..V_MATRICULA'First+7);
      V_SOLICITUD_RUTA.R_ORIGEN := V_ORIGEN;
      V_SOLICITUD_RUTA.R_DESTINO := V_DESTINO;

   end P_CREAR_SOLICITUD_RUTA;
   -----------------------------------------------------------------------------

   --------------------------------------------------------------------------------------
   function F_OBTENER_MATRICULA (V_SOLICITUD_RUTA : in T_SOLICITUD_RUTA) return String is

   begin

      return V_SOLICITUD_RUTA.R_MATRICULA;

   end F_OBTENER_MATRICULA;
   --------------------------------------------------------------------------------------

   -----------------------------------------------------------------------------------------------------------
   function F_OBTENER_ORIGEN (V_SOLICITUD_RUTA : in T_SOLICITUD_RUTA) return Q_TIPOS_BASICOS.T_POSICION_UTM is

   begin

      return V_SOLICITUD_RUTA.R_ORIGEN;

   end F_OBTENER_ORIGEN;
   -----------------------------------------------------------------------------------------------------------

   ------------------------------------------------------------------------------------------------------------
   function F_OBTENER_DESTINO (V_SOLICITUD_RUTA : in T_SOLICITUD_RUTA) return Q_TIPOS_BASICOS.T_POSICION_UTM is

   begin

      return V_SOLICITUD_RUTA.R_DESTINO;

   end F_OBTENER_DESTINO;
   ------------------------------------------------------------------------------------------------------------

end Q_SOLICITUD_RUTA;
--------------------------------------------------------------------------------------------------------------------------------------------
