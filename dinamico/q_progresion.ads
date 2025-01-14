--------------------------------------------------------------------------------------------------------------------------------------------
--
--      Fichero:        q_progresion.ads
--
--      Autor:          Hector Uhalte Bilbao
--
--      Fecha:          10/7/2019
--      
--------------------------------------------------------------------------------------------------------------------------------------------

with Q_TIPOS_BASICOS;
with Q_RUTA;
with Q_RESTRICCION;
with Q_GENERICO_LISTA;
with Q_TRAMO;
with Q_SEGMENTO;
with Q_ADAPTACION_TRAMO;
with Q_CONEXION;

-- Paquete para definir la progresion para un trayecto. Estara compuesto por una lista de elementos de progresion.
-- Cada elemento de progresion estara compuesto por una posicion (del segmento) y una restriccion.

package Q_PROGRESION is

   type T_ELEMENTO_PROGRESION is private;

   type T_PROGRESION is private;

   type T_ELEMENTO_PROGRESION_CARRILES is private;

   type T_PROGRESION_CARRILES is private;

   type T_ELEMENTO_PROGRESION_CARRILES_OPTIMO is private;

   type T_PROGRESION_CARRILES_OPTIMO is private;

   type T_LISTA_TRAMOS_GLORIETA is private;
   
   --
   type T_ELEMENTO_SENTIDO_CIRCULACION is private;
   
   type T_LISTA_SENTIDO_CIRCULACION is private;

   procedure P_GENERAR_PROGRESION (V_POSICION_INICIAL : in Q_TIPOS_BASICOS.T_POSICION_UTM;
                                   V_POSICION_FINAL : in Q_TIPOS_BASICOS.T_POSICION_UTM;
                                   V_RUTA : in Q_RUTA.T_RUTA;
                                   V_PROGRESION : out T_PROGRESION;
                                   V_PROGRESION_CARRILES_OPTIMO : out T_PROGRESION_CARRILES_OPTIMO;
                                   V_LISTA_TRAMOS_GLORIETA :out T_LISTA_TRAMOS_GLORIETA);

   procedure P_VISUALIZAR_PROGRESION (V_PROGRESION : in T_PROGRESION);

   function F_OBTENER_ELEMENTO_ACTUAL_PROGRESION (V_PROGRESION : in T_PROGRESION) return T_ELEMENTO_PROGRESION;

   function F_OBTENER_RESTRICCION (V_ELEMENTO_PROGRESION : in T_ELEMENTO_PROGRESION) return Q_RESTRICCION.T_RESTRICCION;

   function F_OBTENER_ID_TRAMO_ACTUAL (V_ELEMENTO_PROGRESION : in T_ELEMENTO_PROGRESION) return Integer;

   function F_OBTENER_POSICION (V_ELEMENTO_PROGRESION : in T_ELEMENTO_PROGRESION) return Q_TIPOS_BASICOS.T_POSICION_UTM;

   procedure P_ELIMINAR_ELEMENTO_ACTUAL_PROGRESION (V_PROGRESION : in out T_PROGRESION);

   function F_ESTA_PROGRESION_ACABADA (V_PROGRESION : in T_PROGRESION) return Boolean;

   function F_CUANTOS_ELEMENTOS_PROGRESION (V_PROGRESION : in T_PROGRESION) return Natural;

   procedure P_GENERAR_PROGRESION_CARRILES (V_RUTA : in Q_RUTA.T_RUTA;
                                            V_PROGRESION_CARRILES : out T_PROGRESION_CARRILES); 

   procedure P_GENERAR_PROGRESION_CARRILES_OPTIMO (V_RUTA : in Q_RUTA.T_RUTA;
                                                   V_PROGRESION_CARRILES_OPTIMO : out T_PROGRESION_CARRILES_OPTIMO;
                                                   V_LISTA_TRAMOS_GLORIETA : out T_LISTA_TRAMOS_GLORIETA);

   function F_OBTENER_CARRIL_OPTIMO (V_TRAMO_ID : in Natural;
                                     V_PROGRESION_CARRILES_OPTIMO : in T_PROGRESION_CARRILES_OPTIMO) return Natural;

   function F_ES_TRAMO_DE_GLORIETA (V_TRAMO_ID : in Natural;
                                    V_LISTA_TRAMOS_GLORIETA : in T_LISTA_TRAMOS_GLORIETA) return Boolean;
   
   --
   procedure P_GENERAR_PROGRESION_SENTIDO_CIRCULACION (V_POSICION_ORIGEN : in Q_TIPOS_BASICOS.T_POSICION_UTM;
                                                       V_POSICION_FINAL : in Q_TIPOS_BASICOS.T_POSICION_UTM;
                                                       V_RUTA : in Q_RUTA.T_RUTA;
                                                       V_PROGRESION_SENTIDO_CIRCULACION : out T_LISTA_SENTIDO_CIRCULACION);
   
   function F_OBTENER_SENTIDO_CIRCULACION (V_TRAMO_ID : in Natural;
                                           V_PROGRESION_SENTIDO_CIRCULACION : in T_LISTA_SENTIDO_CIRCULACION) return Natural;
   
   function F_OBTENER_LISTA_CRUCES (V_ELEMENTO_PROGRESION : in T_ELEMENTO_PROGRESION) return Q_CONEXION.Q_LISTA_CRUCES.T_LISTA;

private

   type T_ELEMENTO_PROGRESION is record

      R_ID_TRAMO_ACTUAL : Integer range 0 .. Q_TRAMO.F_OBTENER_NUMERO_MAXIMO_TRAMOS := 0;

      R_POSICION : Q_TIPOS_BASICOS.T_POSICION_UTM;

      R_RESTRICCION : Q_RESTRICCION.T_RESTRICCION;
      
      -- 
      R_LISTA_CRUCES : Q_CONEXION.Q_LISTA_CRUCES.T_LISTA;

   end record;

   function "=" (V_ELEMENTO_PROGRESION_1 : in T_ELEMENTO_PROGRESION;
                 V_ELEMENTO_PROGRESION_2 : in T_ELEMENTO_PROGRESION) return Boolean;

   package Q_LISTA_PROGRESION is new
     Q_GENERICO_LISTA 
       (T_ELEMENTO => T_ELEMENTO_PROGRESION,
        "=" => "=",
        V_MAXIMO_NUMERO_ELEMENTOS => 
           Q_TRAMO.F_OBTENER_NUMERO_MAXIMO_TRAMOS * Q_SEGMENTO.F_OBTENER_NUMERO_MAXIMO_SEGMENTOS);

   type T_PROGRESION is new Q_LISTA_PROGRESION.T_LISTA;

   type T_ELEMENTO_PROGRESION_CARRILES is record

      R_ID_TRAMO_ACTUAL : Integer range 0 .. Q_TRAMO.F_OBTENER_NUMERO_MAXIMO_TRAMOS := 0;

      R_LISTA_CARRILES_TRAMO_ACTUAL_CON_CONEXION_AL_PROXIMO : Q_ADAPTACION_TRAMO.Q_LISTA_CARRILES.T_LISTA;

      R_LISTA_CARRILES_CONEXION_PROXIMO_TRAMO : Q_ADAPTACION_TRAMO.Q_LISTA_CARRILES.T_LISTA;

   end record;

   function F_SON_ELEMENTOS_PROGRESION_CARRILES_IGUALES 
     (V_ELEMENTO_PROGRESION_CARRIL_1 : in T_ELEMENTO_PROGRESION_CARRILES;
      V_ELEMENTO_PROGRESION_CARRIL_2 : in T_ELEMENTO_PROGRESION_CARRILES) return Boolean;

   package Q_LISTA_PROGRESION_CARRILES is new 
     Q_GENERICO_LISTA (T_ELEMENTO => T_ELEMENTO_PROGRESION_CARRILES,
                       "=" => F_SON_ELEMENTOS_PROGRESION_CARRILES_IGUALES,
                       V_MAXIMO_NUMERO_ELEMENTOS => Q_TRAMO.F_OBTENER_NUMERO_MAXIMO_TRAMOS);
		
   type T_PROGRESION_CARRILES is new Q_LISTA_PROGRESION_CARRILES.T_LISTA;

   type T_ELEMENTO_PROGRESION_CARRILES_OPTIMO is record

      R_ID_TRAMO_ACTUAL : Integer range 0 .. Q_TRAMO.F_OBTENER_NUMERO_MAXIMO_TRAMOS := 0;

      -- Carril optimo por defecto para circular por un tramo dado.
      R_CARRIL : Natural := 1;

   end record;

   function F_SON_ELEMENTOS_PROGRESION_CARRILES_OPTIMO_IGUALES 
     (V_ELEMENTO_PROGRESION_CARRILES_OPTIMO_1 : in T_ELEMENTO_PROGRESION_CARRILES_OPTIMO;
      V_ELEMENTO_PROGRESION_CARRILES_OPTIMO_2 : in T_ELEMENTO_PROGRESION_CARRILES_OPTIMO) return Boolean;

   package Q_LISTA_PROGRESION_CARRILES_OPTIMO is new 
     Q_GENERICO_LISTA (T_ELEMENTO => T_ELEMENTO_PROGRESION_CARRILES_OPTIMO,
                       "=" => F_SON_ELEMENTOS_PROGRESION_CARRILES_OPTIMO_IGUALES,
                       V_MAXIMO_NUMERO_ELEMENTOS => Q_TRAMO.F_OBTENER_NUMERO_MAXIMO_TRAMOS);

   type T_PROGRESION_CARRILES_OPTIMO is new Q_LISTA_PROGRESION_CARRILES_OPTIMO.T_LISTA;

   package Q_LISTA_TRAMOS_GLORIETA is new 
     Q_GENERICO_LISTA (T_ELEMENTO => Natural,
                       "=" => Q_TRAMO.F_COMPARAR_TRAMOS_ID,
                       V_MAXIMO_NUMERO_ELEMENTOS => Q_TRAMO.F_OBTENER_NUMERO_MAXIMO_TRAMOS);

   type T_LISTA_TRAMOS_GLORIETA is new Q_LISTA_TRAMOS_GLORIETA.T_LISTA;

   --
   type T_ELEMENTO_SENTIDO_CIRCULACION is record
      
      R_ID_TRAMO_ACTUAL : Integer range 0 .. Q_TRAMO.F_OBTENER_NUMERO_MAXIMO_TRAMOS := 0;
      
      R_SENTIDO_ACTUAL : Natural range 1 .. 2;
      
   end record;
   
   function "=" (V_ELEMENTO_SENTIDO_CIRCULACION_1 : in T_ELEMENTO_SENTIDO_CIRCULACION;
                 V_ELEMENTO_SENTIDO_CIRCULACION_2 : in T_ELEMENTO_SENTIDO_CIRCULACION) return Boolean;
   
   package Q_LISTA_SENTIDO_CIRCULACION is new Q_GENERICO_LISTA (T_ELEMENTO                => T_ELEMENTO_SENTIDO_CIRCULACION,
                                                                "="                       => "=",
                                                                V_MAXIMO_NUMERO_ELEMENTOS => Q_TRAMO.F_OBTENER_NUMERO_MAXIMO_TRAMOS);
   
   type T_LISTA_SENTIDO_CIRCULACION is new Q_LISTA_SENTIDO_CIRCULACION.T_LISTA;
   
end Q_PROGRESION;
-----------------
