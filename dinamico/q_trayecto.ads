--------------------------------------------------------------------------------------------------------------------------------------------
--
--	Fichero:	q_trayecto.ads
--
--	Autor:		Hector Uhalte Bilbao
--
--	Fecha:		27/6/2019
--
--------------------------------------------------------------------------------------------------------------------------------------------

with Q_TIPOS_BASICOS;
with Ada.Calendar;
with Q_RUTA;
with Q_TRAMO;
with Q_VEHICULO;
with Q_PROGRESION;

-- Paquete para definir el tipo y las operaciones dinamicas de un trayecto, dado un vehiculo y una ruta.

package Q_TRAYECTO is

   type T_ESTADO is (E_PASIVO, E_ACTIVO, E_TERMINADO);

   type T_TRAYECTO is private;

   function F_OBTENER_ID (V_TRAYECTO : in T_TRAYECTO) return String;

   function F_OBTENER_POSICION_ORIGEN (V_TRAYECTO : in T_TRAYECTO) return Q_TIPOS_BASICOS.T_POSICION_UTM;

   function F_OBTENER_POSICION_FINAL (V_TRAYECTO : in T_TRAYECTO) return Q_TIPOS_BASICOS.T_POSICION_UTM;

   function F_OBTENER_HORA_SALIDA (V_TRAYECTO : in T_TRAYECTO) return Ada.Calendar.Time;

   function F_OBTENER_PROGRESION (V_TRAYECTO : in T_TRAYECTO) return Q_PROGRESION.T_PROGRESION;

   function F_OBTENER_DURACION (V_TRAYECTO : in T_TRAYECTO) return Integer;

   function F_OBTENER_DISTANCIA (V_TRAYECTO : in T_TRAYECTO) return Integer;

   function F_OBTENER_ESTADO (V_TRAYECTO : in T_TRAYECTO) return T_ESTADO;

   procedure P_PONER_ESTADO (V_ESTADO : in T_ESTADO;
                             V_TRAYECTO : in out T_TRAYECTO);

   function F_ESTA_TRAYECTO_TERMINADO (V_TRAYECTO : in T_TRAYECTO) return Boolean;

   function F_OBTENER_VELOCIDAD_ACTUAL (V_TRAYECTO : in T_TRAYECTO) return Q_TIPOS_BASICOS.T_VELOCIDAD;

   function F_OBTENER_POSICION_ACTUAL (V_TRAYECTO : in T_TRAYECTO) return Q_TIPOS_BASICOS.T_POSICION_UTM;

   function F_OBTENER_TIEMPO_TRANSCURRIDO (V_TRAYECTO : in T_TRAYECTO) return Integer;

   function F_OBTENER_DISTANCIA_POR_RECORRER (V_TRAYECTO : in T_TRAYECTO) return Float;
   
   function F_OBTENER_TRAMO_ACTUAL_ID (V_TRAYECTO : in T_TRAYECTO) return Natural;
   
   function F_OBTENER_CARRIL_ACTUAL (V_TRAYECTO : in T_TRAYECTO) return Natural;

   procedure P_CREAR_TRAYECTO (V_VEHICULO : in Q_VEHICULO.T_VEHICULO;
                               V_POSICION_ORIGEN : in Q_TIPOS_BASICOS.T_POSICION_UTM;
                               V_POSICION_FINAL : in Q_TIPOS_BASICOS.T_POSICION_UTM;
                               V_HORA_SALIDA : in Ada.Calendar.Time := Ada.Calendar.Clock;
                               V_DURACION : in Integer;
                               V_DISTANCIA : in Integer;
                               V_RUTA : in Q_RUTA.T_RUTA;
                               V_TRAYECTO : out T_TRAYECTO);

private

   -- Tipo para el trayecto.
   -- 4.- Distancia que queda por recorrer.
   type T_TRAYECTO is record

      -- Parte estatica

      -- ID: Se correspondera con la matricula del vehiculo.
      -- TO DO: Crear el tipo matricula dentro del vehiculo y no usar un tipo string.
      -- Hacerlo cuando funcione la progresion.
      R_ID : String (1..8);

      -- Punto de partida
      R_POSICION_ORIGEN : Q_TIPOS_BASICOS.T_POSICION_UTM;

      -- Tramo de partida
      R_ID_TRAMO_ORIGEN : Integer;

      -- Punto de llegada.
      R_POSICION_FINAL : Q_TIPOS_BASICOS.T_POSICION_UTM;

      -- Tramo de destino
      R_ID_TRAMO_DESTINO : Integer;

      -- Hora de salida.
      R_HORA_SALIDA : Ada.Calendar.Time;

      -- Duracion del trayecto.
      R_DURACION : Integer;

      -- Distancia del trayecto.
      R_DISTANCIA : Integer;

      -- Parte dinamica
			
      -- Estado del trayecto. Por defecto al crear un trayecto el estado es pasivo (el vehiculo no ha arrancado).
      R_ESTADO : T_ESTADO := E_PASIVO;

      -- Progresion que queda por recorrer.
      R_PROGRESION : Q_PROGRESION.T_PROGRESION;

      -- Progresion de carriles (a traves de que carriles se conectan los tramos de la ruta)
      R_PROGRESION_CARRILES : Q_PROGRESION.T_PROGRESION_CARRILES;

      -- Progresion de carriles optimo.
      R_PROGRESION_CARRILES_OPTIMO : Q_PROGRESION.T_PROGRESION_CARRILES_OPTIMO;

      -- Lista de tramos que pertenecen a una rotonda en la que se pueda cambiar de carril.
      R_TRAMOS_EN_GLORIETA : Q_PROGRESION.T_LISTA_TRAMOS_GLORIETA;
      
      -- Tramo actual.
      R_TRAMO_ACTUAL_ID : Integer range 0 .. Q_TRAMO.F_OBTENER_NUMERO_MAXIMO_TRAMOS := 0;

      -- Numero que identifica el carril dentro del tramo en el que se encuentra el vehiculo.
      -- Siendo 1 el carril de la derecha.
      R_CARRIL_ACTUAL : Natural range 1 .. 3 := 1;

      -- Velocidad actual del vehiculo.
      R_VELOCIDAD_ACTUAL : Q_TIPOS_BASICOS.T_VELOCIDAD;

      -- Posicion actual
      R_POSICION_ACTUAL : Q_TIPOS_BASICOS.T_POSICION_UTM;

      -- Tiempo transcurrido desde el comienzo del trayecto.
      R_TIEMPO_TRANSCURRIDO : Integer := 0;

      -- Distancia que queda por recorrer.
      R_DISTANCIA_POR_RECORRER : Float;

      R_DISTANCIA_RECORRIDA : Float := 0.0;

      R_SEGMENTOS_AVANZADOS : Natural := 0;

      -- Distancia acarreo. La diferencia entre la distancia recorrida y el numero de segmentos a avanzar.
      R_ACARREO : Float := 0.0;	

   end record;

end Q_TRAYECTO;
---------------
