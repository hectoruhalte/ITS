--------------------------------------------------------------------------------------------------------------------------------------------
--
--      Fichero:        q_datos_trayecto_stream.ads
--
--      Autor:          Hector Uhalte Bilbao
--
--      Fecha:          28/10/2020
--
--------------------------------------------------------------------------------------------------------------------------------------------

-- Paquete para definir el tipo de los datos que cada vehiculo va a notificar al servidor durante cada trayecto.
-- En cada actualizacion del trayecto se notificara al servidor:
-- 1.- Matricula del vehiculo.
-- 2.- Id del tramo en el que se encuentre el vehiculo.
-- 3.- Carril dentro del tramo en el que se encuentre el vehiculo.
-- 4.- Posicion UTM en la que se encuentre el vehiculo.

with Q_TIPOS_BASICOS;
with Q_CARRIL;

package Q_DATOS_TRAYECTO_STREAM is

   pragma Pure;
   
   type T_DATOS_TRAYECTO_STREAM is private;
   
   procedure P_GENERAR_DATOS_TRAYECTO_STREAM (V_TRAYECTO_ID : in Natural;
                                              V_MATRICULA : in String;
                                              V_TRAMO_ID : in Natural;
                                              V_CARRIL : in Natural;
                                              V_POSICION : in Q_TIPOS_BASICOS.T_POSICION_UTM;
                                              V_VELOCIDAD : in Q_TIPOS_BASICOS.T_VELOCIDAD;
                                              V_DATOS_TRAYECTO_STREAM : out T_DATOS_TRAYECTO_STREAM);
   
   function F_OBTENER_TRAYECTO_ID (V_DATOS_TRAYECTO_STREAM : in T_DATOS_TRAYECTO_STREAM) return Natural;
   
   function F_OBTENER_MATRICULA (V_DATOS_TRAYECTO_STREAM : in T_DATOS_TRAYECTO_STREAM) return String;
   
   function F_OBTENER_TRAMO_ID (V_DATOS_TRAYECTO_STREAM : in T_DATOS_TRAYECTO_STREAM) return Natural;
   
   function F_OBTENER_CARRIL (V_DATOS_TRAYECTO_STREAM : in T_DATOS_TRAYECTO_STREAM) return Natural;
   
   function F_OBTENER_POSICION (V_DATOS_TRAYECTO_STREAM : in T_DATOS_TRAYECTO_STREAM) return Q_TIPOS_BASICOS.T_POSICION_UTM;
   
   function F_OBTENER_VELOCIDAD (V_DATOS_TRAYECTO_STREAM : in T_DATOS_TRAYECTO_STREAM) return Q_TIPOS_BASICOS.T_VELOCIDAD;
   
private
   
   type T_DATOS_TRAYECTO_STREAM is record
      
      R_TRAYECTO_ID : Natural;
      
      R_MATRICULA : String (1..8);
      
      R_TRAMO_ID : Natural;
      
      R_CARRIL : Natural range 1 .. Q_CARRIL.F_OBTENER_NUMERO_MAXIMO_CARRILES;
      
      R_POSICION : Q_TIPOS_BASICOS.T_POSICION_UTM;
      
      R_VELOCIDAD : Q_TIPOS_BASICOS.T_VELOCIDAD;
      
   end record;

end Q_DATOS_TRAYECTO_STREAM;
----------------------------
