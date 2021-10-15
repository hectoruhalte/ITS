--------------------------------------------------------------------------------------------------------------------------------------------
--
--	Fichero:	q_tipos_basicos.ads
--
--	Autor:		Hector Uhalte Bilbao
--
--	Fecha:		25/8/2017
--	
--------------------------------------------------------------------------------------------------------------------------------------------

-- Este paquete presenta los tipos básicos disponibles para más de una entidad básica (Vehículo, Tramo, Trayecto)
-- Un vehículo puede tener una velocidad máxima, o una velocidad actual, de la misma manera que un trayecto puede tener una velocidad media.
--
-- Un vehículo puede estar en una posición determinada del espacio, así como un tramo tendrá un punto de origen y uno final y un trayecto 
-- un punto de partida y uno de llegada
--
-- Al definir los tipos T_VEHICULO, T_TRAMO y T_TRAYECTO, cuando usen el tipo T_VELOCIDAD, y el tipo T_POSICION, usarán los tipos definidos
-- en este paquete.


package Q_TIPOS_BASICOS is
   
   pragma Pure;

   -- Velocidad minima a 0. Podria ser negativa si consideramos marcha atras.
   C_VELOCIDAD_MINIMA : constant Integer := 0;

   -- Maxima velocidad fisica que podria alcanzar cualquier vehiculo.      
   C_MAXIMA_VELOCIDAD_POSIBLE : constant Integer := 500;

   -- Considerar velocidad negativa para la marcha atrás.
   subtype T_VELOCIDAD is Integer range C_VELOCIDAD_MINIMA .. C_MAXIMA_VELOCIDAD_POSIBLE;

   -- Tipos para definir la latitud y la longitud.
   subtype T_LATITUD is Float range -90.0 .. 90.0;

   subtype T_LONGITUD is Float range -180.0 .. 180.0;

   -- Tipo para almacenar la posición X Y	
   type T_POSICION_UTM is private;

   -- Tipo para almacenar coordenadas lat lon
   type T_POSICION_LAT_LON is private;

   X_COORDENADAS_FUERA_DE_RANGO : Exception;
   X_VELOCIDAD_FUERA_DE_RANGO : Exception;

   function F_PONER_VELOCIDAD (V_VELOCIDAD : in Integer) return T_VELOCIDAD;
	
   function F_OBTENER_POSICION_UTM (V_X : in Integer;
                                    V_Y : in Integer) return T_POSICION_UTM;

   function F_OBTENER_COORDENADA_X (V_POSICION : in T_POSICION_UTM) return Integer;

   function F_OBTENER_COORDENADA_Y (V_POSICION : in T_POSICION_UTM) return Integer;

   function F_OBTENER_DISTANCIA (V_POSICION_1 : T_POSICION_UTM;
                                 V_POSICION_2 : T_POSICION_UTM) return Integer;

   function F_OBTENER_POSICION_LAT_LON (V_LATITUD : in T_LATITUD;
                                        V_LONGITUD : in T_LONGITUD) return T_POSICION_LAT_LON;

   function F_OBTENER_LATITUD (V_POSICION : in T_POSICION_LAT_LON) return T_LATITUD;

   function F_OBTENER_LONGITUD (V_POSICION : in T_POSICION_LAT_LON) return T_LONGITUD;

   function F_TRANSFORMAR_LAT_LON_A_UTM (V_POSICION_LAT_LON : in T_POSICION_LAT_LON) return T_POSICION_UTM;
   
   function F_TRANSFORMAR_UTM_A_LAT_LON (V_POSICION_UTM : in T_POSICION_UTM) return T_POSICION_LAT_LON;

   -- Funcion para obtener coordenadas X Y con referencia en el punto de tangencia. Traslacion
   function F_OBTENER_REF_X_Y (V_POSICION_UTM : in T_POSICION_UTM) return T_POSICION_UTM;

   -- Funcion para comprobar si dos posiciones dadas son iguales o no.
   function "=" (V_POSICION_1 : T_POSICION_UTM;
                 V_POSICION_2 : T_POSICION_UTM) return Boolean;

private

   -- Valores mínimo y máximo para las coordenadas. Cada unidad equivaldrá a un metro.
   C_VALOR_MINIMO_COORDENADA : constant Integer := -5_000_000;

   C_VALOR_MAXIMO_COORDENADA : constant Integer := 5_000_000;

   -- Area de trabajo. Limite del mapa. Provisional. Podremos tener coordenadas dentro y fuera del area de trabajo.
   -- De momento el area de trabajo sera de 5000x5000 metros.
   C_LIMITE_AREA_TRABAJO : constant Integer := 5000;

   -- Meridiano de referencia para zona UTM 30
   C_MERIDIANO_REFERENCIA : constant Float := -3.0;

   -- Semieje mayor tierra modelo WGS 84 en metros
   C_SEMIEJE_MAYOR : constant Float := 6_378_137.0;

   -- Semieje menor tierra modelo WGS84 en metros
   C_SEMIEJE_MENOR : constant Float := 6_356_752.3;
   
   -- Excentricidad tierra
   C_EXC : constant Float := 0.081819191;
   
   C_EXC_2 : constant Float := 0.006739497;

   -- E0
   C_E0 : constant FLoat := 500_000.0;

   -- K0
   C_K0 : constant Float := 0.9996;
   
   -- Zonat UTM
   C_ZONA : constant Integer := 30;

   -- Posicion usada internamente en el sistema. Con referencia a las coordenadas UTM del punto de tangencia.
   type T_POSICION_UTM is record

      R_X : Integer range C_VALOR_MINIMO_COORDENADA .. C_VALOR_MAXIMO_COORDENADA := 0;

      R_Y : Integer range C_VALOR_MINIMO_COORDENADA .. C_VALOR_MAXIMO_COORDENADA := 0;

   end record;
		
   -- Posicion guardada en la adaptacion en grados decimales.
   type T_POSICION_LAT_LON is record

      R_LATITUD : T_LATITUD := 0.0;

      R_LONGITUD : T_LONGITUD := 0.0;

   end record;

end Q_TIPOS_BASICOS;
--------------------
