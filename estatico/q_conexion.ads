--------------------------------------------------------------------------------------------------------------------------------------------
--
--      Fichero:        q_conexion.ads
--
--      Autor:          Hector Uhalte Bilbao
--
--      Fecha:          24/3/2020
--      
--------------------------------------------------------------------------------------------------------------------------------------------

with Q_TIPOS_BASICOS;
with Q_CARRIL;
with Q_GENERICO_LISTA;

-- Paquete para presentar el tipo T_CONEXION entre tramos.

package Q_CONEXION is
   
   type T_CONEXION is private;
   
   subtype T_CRUCE is Natural range 0 .. Q_CARRIL.F_OBTENER_NUMERO_MAXIMO_CARRILES * 2;

   type T_ARRAY_CRUCES is array (1 .. Q_CARRIL.F_OBTENER_NUMERO_MAXIMO_CARRILES * 2) of T_CRUCE;
   
   function F_IGUALDAD_CRUCES (V_CRUCE_1 : in T_CRUCE;
                               V_CRUCE_2 : in T_CRUCE) return Boolean;
   
   package Q_LISTA_CRUCES is new Q_GENERICO_LISTA (T_ELEMENTO                => T_CRUCE,
                                                   "="                       => F_IGUALDAD_CRUCES,
                                                   V_MAXIMO_NUMERO_ELEMENTOS => Q_CARRIL.F_OBTENER_NUMERO_MAXIMO_CARRILES*2);
   
   procedure P_INICIALIZAR_CONEXION (V_CONEXION : in out T_CONEXION);

   procedure P_PONER_TRAMO_ID (V_TRAMO_ID : in Natural;
                               V_CONEXION : in out T_CONEXION);

   procedure P_PONER_CARRIL_ACTUAL (V_CARRIL_ACTUAL : in Natural;
                                    V_CONEXION : in out T_CONEXION);

   procedure P_PONER_CARRIL_SIGUIENTE (V_CARRIL_SIGUIENTE : in Natural;
                                       V_CONEXION : in out T_CONEXION);

   procedure P_PONER_RESTRICCION_VELOCIDAD (V_RESTRICCION_VELOCIDAD : in Q_TIPOS_BASICOS.T_VELOCIDAD;
                                            V_CONEXION : in out T_CONEXION);

   -- Funcion necesaria para instanciar el paquete Q_GENERICO_LISTA para crear listas de segmentos.
   function "=" (V_CONEXION_1 : in T_CONEXION;
                 V_CONEXION_2 : in T_CONEXION) return Boolean;

   function F_OBTENER_TRAMO_ID (V_CONEXION : in T_CONEXION) return Natural;
   
   function F_OBTENER_CARRIL_ACTUAL (V_CONEXION : in T_CONEXION) return Natural;
   
   function F_OBTENER_CARRIL_SIGUIENTE (V_CONEXION : In T_CONEXION) return Natural;
   
   procedure P_PONER_LISTA_CRUCES (V_NUMERO_CRUCES : in Natural;
                                   V_ARRAY_CRUCES : in T_ARRAY_CRUCES;
                                   V_CONEXION : in out T_CONEXION);
   
   function F_OBTENER_LISTA_CRUCES (V_CONEXION : in T_CONEXION) return Q_LISTA_CRUCES.T_LISTA;

private
   
   type T_CONEXION is record

      -- Id del tramo al que se conecta el tramo al que pertenece la conexion.
      R_TRAMO_ID : Natural;

      -- Carril del tramo al que pertenece la conexion
      R_CARRIL_ACTUAL : Natural;

      -- Carril del tramo al que se que conecta el tramo al que pertenece la conexion.
      R_CARRIL_SIGUIENTE : Natural;
      
      -- Lista de cruces de la conexion
      R_LISTA_CRUCES : Q_LISTA_CRUCES.T_LISTA;

      -- Restricion fisica de la velocidad del coche en la conexion entre los dos tramos
      R_RESTRICCION_VELOCIDAD : Q_TIPOS_BASICOS.T_VELOCIDAD;

   end record;

end Q_CONEXION;
---------------
