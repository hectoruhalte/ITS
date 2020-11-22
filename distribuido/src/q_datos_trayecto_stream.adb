--------------------------------------------------------------------------------------------------------------------------------------------
--
--      Fichero:        q_datos_trayecto_stream.adb
--
--      Autor:          Hector Uhalte Bilbao
--
--      Fecha:          28/10/2020
--
--------------------------------------------------------------------------------------------------------------------------------------------

package body Q_DATOS_TRAYECTO_STREAM is

   ----------------------------------------------------------------------------------------------------
   procedure P_GENERAR_DATOS_TRAYECTO_STREAM (V_TRAYECTO_ID : in Natural;
                                              V_MATRICULA : in String;
                                              V_TRAMO_ID : in Natural;
                                              V_CARRIL : in Natural;
                                              V_POSICION : in Q_TIPOS_BASICOS.T_POSICION_UTM;
                                              V_VELOCIDAD : in Q_TIPOS_BASICOS.T_VELOCIDAD;
                                              V_DATOS_TRAYECTO_STREAM : out T_DATOS_TRAYECTO_STREAM) is

   begin

      V_DATOS_TRAYECTO_STREAM.R_TRAYECTO_ID := V_TRAYECTO_ID;
      V_DATOS_TRAYECTO_STREAM.R_MATRICULA (1..8) := V_MATRICULA (V_MATRICULA'First..V_MATRICULA'First+7);
      V_DATOS_TRAYECTO_STREAM.R_TRAMO_ID := V_TRAMO_ID;
      V_DATOS_TRAYECTO_STREAM.R_CARRIL := V_CARRIL;
      V_DATOS_TRAYECTO_STREAM.R_POSICION := V_POSICION;
      V_DATOS_TRAYECTO_STREAM.R_VELOCIDAD := V_VELOCIDAD;

   end P_GENERAR_DATOS_TRAYECTO_STREAM;
   ----------------------------------------------------------------------------------------------------

   -------------------------------------------------------------------------------------------------------
   function F_OBTENER_TRAYECTO_ID (V_DATOS_TRAYECTO_STREAM : in T_DATOS_TRAYECTO_STREAM) return Natural is

   begin

      return V_DATOS_TRAYECTO_STREAM.R_TRAYECTO_ID;

   end F_OBTENER_TRAYECTO_ID;
   -------------------------------------------------------------------------------------------------------

   ----------------------------------------------------------------------------------------------------
   function F_OBTENER_MATRICULA (V_DATOS_TRAYECTO_STREAM : in T_DATOS_TRAYECTO_STREAM) return String is

   begin

      return V_DATOS_TRAYECTO_STREAM.R_MATRICULA (1..8);

   end F_OBTENER_MATRICULA;
   ----------------------------------------------------------------------------------------------------

   ----------------------------------------------------------------------------------------------------
   function F_OBTENER_TRAMO_ID (V_DATOS_TRAYECTO_STREAM : in T_DATOS_TRAYECTO_STREAM) return Natural is

   begin

      return V_DATOS_TRAYECTO_STREAM.R_TRAMO_ID;

   end F_OBTENER_TRAMO_ID;
   ----------------------------------------------------------------------------------------------------

   --------------------------------------------------------------------------------------------------
   function F_OBTENER_CARRIL (V_DATOS_TRAYECTO_STREAM : in T_DATOS_TRAYECTO_STREAM) return Natural is

   begin

      return V_DATOS_TRAYECTO_STREAM.R_CARRIL;

   end F_OBTENER_CARRIL;
   --------------------------------------------------------------------------------------------------

   ---------------------------------------------------------------------------------------------------------------------------
   function F_OBTENER_POSICION (V_DATOS_TRAYECTO_STREAM : in T_DATOS_TRAYECTO_STREAM) return Q_TIPOS_BASICOS.T_POSICION_UTM is

   begin

      return V_DATOS_TRAYECTO_STREAM.R_POSICION;

   end F_OBTENER_POSICION;
   ---------------------------------------------------------------------------------------------------------------------------

   -------------------------------------------------------------------------------------------------------------------------
   function F_OBTENER_VELOCIDAD (V_DATOS_TRAYECTO_STREAM : in T_DATOS_TRAYECTO_STREAM) return Q_TIPOS_BASICOS.T_VELOCIDAD is

   begin

      return V_DATOS_TRAYECTO_STREAM.R_VELOCIDAD;

   end F_OBTENER_VELOCIDAD;
   -------------------------------------------------------------------------------------------------------------------------

end Q_DATOS_TRAYECTO_STREAM;
--------------------------------------------------------------------------------------------------------------------------------------------
