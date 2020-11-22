--------------------------------------------------------------------------------------------------------------------------------------------
--
--      Fichero:        q_vehiculo.ads
--
--      Autor:          Hector Uhalte Bilbao
--
--      Fecha:          15/9/2017
--      
--------------------------------------------------------------------------------------------------------------------------------------------

with Q_TIPOS_BASICOS;
with Ada.Characters.Latin_1;

-- Este paquete presenta el tipo T_VEHICULO, donde se van a definir todos los atributos propios de un vehiculo.

package Q_VEHICULO is

   X_NUMERO_BASTIDOR_ERRONEO : Exception;
   X_MATRICULA_ERRONEA : Exception;
   X_NOMBRE_MARCA_EXCESIVAMENTE_LARGO : Exception;
   X_NOMBRE_MODELO_EXCESIVAMENTE_LARGO : Exception;

   type T_VEHICULO is private;

   function F_OBTENER_LONGITUD_NUMERO_BASTIDOR return Integer;

   function F_OBTENER_NUMERO_BASTIDOR (V_VEHICULO : in T_VEHICULO) return String;

   function F_OBTENER_MATRICULA (V_VEHICULO : in T_VEHICULO) return String;

   function F_OBTENER_NOMBRE_MARCA (V_VEHICULO : in T_VEHICULO) return String;

   function F_OBTENER_NOMBRE_MODELO (V_VEHICULO : in T_VEHICULO) return String;

   function F_OBTENER_VELOCIDAD_MAXIMA (V_VEHICULO : in T_VEHICULO) return Q_TIPOS_BASICOS.T_VELOCIDAD;

   procedure P_PONER_VELOCIDAD (V_VEHICULO : in out T_VEHICULO;
                                V_VELOCIDAD : in Integer);

   procedure P_PONER_POSICION (V_VEHICULO : in out T_VEHICULO;
                               V_POSICION : in Q_TIPOS_BASICOS.T_POSICION_UTM);

   function "=" (V_VEHICULO_1 : in T_VEHICULO;
                 V_VEHICULO_2 : in T_VEHICULO) return Boolean;

   function F_OBTENER_LONGITUD_VEHICULO (V_VEHICULO : in T_VEHICULO) return Float;

   function F_OBTENER_ALTURA_VEHICULO (V_VEHICULO : in T_VEHICULO) return Float;

   function F_OBTENER_LONGITUD_MAXIMA_NOMBRE_MARCA_MODELO return Integer;

   function F_OBTENER_CONSUMO_URBANO (V_VEHICULO : in T_VEHICULO) return Float;

   function F_OBTENER_CONSUMO_CARRETERA (V_VEHICULO : in T_VEHICULO) return Float;

   function F_OBTENER_MARCA_VACIA return String;

   function F_OBTENER_MODELO_VACIO return String;
   
   function F_OBTENER_LONGITUD_MATRICULA return Natural;

private

   -- ISO 3779
   C_LONGITUD_NUMERO_BASTIDOR : constant Integer := 17;

   -- Modelo matricula espanola "1234 ABC"
   C_LONGITUD_MATRICULA : constant Integer := 8;

   C_LONGITUD_MAXIMA_NOMBRE_MARCA_MODELO : constant Integer := 16;

   -- Longitud maxima de un vehiculo 20 metros.
   C_LONGITUD_MAXIMA_VEHICULO : constant Float := 20.0;

   C_ALTURA_MAXIMA_VEHICULO : constant Float := 5.0;

   -- Consumo maximo de un vehiculo expresado en l/100 Km.
   C_CONSUMO_MAXIMO : constant Float := 100.0;

   -- Strings vacios para los nombres de la marca y el modelo.
   C_MARCA_VACIA, C_MODELO_VACIO : constant String (1 .. C_LONGITUD_MAXIMA_NOMBRE_MARCA_MODELO) 
     := (others => ADA.CHARACTERS.Latin_1.NUL);

   type T_MATRICULA is record

      R_NUMEROS : String (1..5);

      R_LETRAS : String (1..3);

   end record;

   type T_DIMENSIONES_VEHICULO is record

      -- Dato obtenido por adaptacion
      R_LONGITUD : Float range 0.0 .. C_LONGITUD_MAXIMA_VEHICULO := 0.0;

      -- Dato obtenido por adaptacion
      R_ALTURA : Float range 0.0 .. C_ALTURA_MAXIMA_VEHICULO := 0.0;

   end record;

   -- Para vehiculos de combustible. Para electricos habra otra medida
   type T_CONSUMO is record
		
      -- Dato obtenido por adaptacion
      R_URBANO : Float range 0.0 .. C_CONSUMO_MAXIMO;

      -- Dato obtenido por adaptacion
      R_CARRETERA : Float range 0.0 .. C_CONSUMO_MAXIMO;

   end record;

   type T_VEHICULO is record
			
      R_NUMERO_BASTIDOR : String (1 .. C_LONGITUD_NUMERO_BASTIDOR);

      R_MATRICULA : String (1 .. C_LONGITUD_MATRICULA);

      R_NOMBRE_MARCA : String (1 .. C_LONGITUD_MAXIMA_NOMBRE_MARCA_MODELO) := C_MARCA_VACIA;

      R_NOMBRE_MODELO : String (1 .. C_LONGITUD_MAXIMA_NOMBRE_MARCA_MODELO) := C_MODELO_VACIO;

      R_VELOCIDAD : Q_TIPOS_BASICOS.T_VELOCIDAD := 0;

      -- Dato obtenido por adaptacion.
      R_VELOCIDAD_MAXIMA : Q_TIPOS_BASICOS.T_VELOCIDAD := Q_TIPOS_BASICOS.C_MAXIMA_VELOCIDAD_POSIBLE;

      R_POSICION : Q_TIPOS_BASICOS.T_POSICION_UTM;

      R_DIMENSIONES : T_DIMENSIONES_VEHICULO;

      R_CONSUMO : T_CONSUMO;	

   end record;

end Q_VEHICULO;
---------------
