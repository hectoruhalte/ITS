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
                                              V_SENTIDO : in Natural;
                                              V_NUMERO_CRUCES : in Natural;
                                              V_ARRAY_CRUCES : in T_ARRAY_CRUCES_STREAM;
                                              V_POSICION : in Q_TIPOS_BASICOS.T_POSICION_UTM;
                                              V_VELOCIDAD : in Q_TIPOS_BASICOS.T_VELOCIDAD;
                                              V_DATOS_TRAYECTO_STREAM : out T_DATOS_TRAYECTO_STREAM) is

   begin

      V_DATOS_TRAYECTO_STREAM.R_TRAYECTO_ID := V_TRAYECTO_ID;
      V_DATOS_TRAYECTO_STREAM.R_MATRICULA (1..8) := V_MATRICULA (V_MATRICULA'First..V_MATRICULA'First+7);
      V_DATOS_TRAYECTO_STREAM.R_TRAMO_ID := V_TRAMO_ID;
      V_DATOS_TRAYECTO_STREAM.R_CARRIL := V_CARRIL;
      V_DATOS_TRAYECTO_STREAM.R_SENTIDO := V_SENTIDO;
      V_DATOS_TRAYECTO_STREAM.R_NUMERO_CRUCES := V_NUMERO_CRUCES;
      V_DATOS_TRAYECTO_STREAM.R_CRUCES := V_ARRAY_CRUCES;
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

   ---------------------------------------------------------------------------------------------------------------
   function F_OBTENER_SENTIDO_CIRCULACION (V_DATOS_TRAYECTO_STREAM : in T_DATOS_TRAYECTO_STREAM) return Natural is

   begin

      return V_DATOS_TRAYECTO_STREAM.R_SENTIDO;

   end F_OBTENER_SENTIDO_CIRCULACION;
   ---------------------------------------------------------------------------------------------------------------

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

   ----------------------------------------------------------------------------------------------
   procedure P_INICIALIZAR_ARRAY_CRUCES (V_ARRAY_CRUCES_STREAM : in out T_ARRAY_CRUCES_STREAM) is

   begin

      V_ARRAY_CRUCES_STREAM := (others => 0);

   end P_INICIALIZAR_ARRAY_CRUCES;
   ----------------------------------------------------------------------------------------------

   ------------------------------------------------------------------------------------
   procedure P_INSERTAR_CRUCE (V_CRUCE : in Natural;
                               V_NUMERO_CRUCES : in out Natural;
                               V_ARRAY_CRUCES_STREAM : in out T_ARRAY_CRUCES_STREAM) is

   begin

      V_ARRAY_CRUCES_STREAM (V_NUMERO_CRUCES + 1) := V_CRUCE;
      V_NUMERO_CRUCES := V_NUMERO_CRUCES + 1;

   end P_INSERTAR_CRUCE;
   ------------------------------------------------------------------------------------

   ---------------------------------------------------------------------------------------------------------
   function F_OBTENER_NUMERO_CRUCES (V_DATOS_TRAYECTO_STREAM : in T_DATOS_TRAYECTO_STREAM) return Natural is

   begin

      return V_DATOS_TRAYECTO_STREAM.R_NUMERO_CRUCES;

   end F_OBTENER_NUMERO_CRUCES;
   ---------------------------------------------------------------------------------------------------------

   ----------------------------------------------------------------------------------------------------------------------
   function F_OBTENER_ARRAY_CRUCES (V_DATOS_TRAYECTO_STREAM : in T_DATOS_TRAYECTO_STREAM) return T_ARRAY_CRUCES_STREAM is

   begin

      return V_DATOS_TRAYECTO_STREAM.R_CRUCES;

   end F_OBTENER_ARRAY_CRUCES;
   ----------------------------------------------------------------------------------------------------------------------

   --------------------------------------------------------------------------------------
   function F_OBTENER_CRUCE (V_POSICION : in Natural;
                             V_ARRAY_CRUCES : in T_ARRAY_CRUCES_STREAM) return Natural is

   begin

      return V_ARRAY_CRUCES (V_POSICION);

   end F_OBTENER_CRUCE;
   --------------------------------------------------------------------------------------

end Q_DATOS_TRAYECTO_STREAM;
--------------------------------------------------------------------------------------------------------------------------------------------
