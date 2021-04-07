--------------------------------------------------------------------------------------------------------------------------------------------
--
--      Fichero:        q_tabla_trayectos.ads
--
--      Autor:          Hector Uhalte Bilbao
--
--      Fecha:          29/10/2020
--
--------------------------------------------------------------------------------------------------------------------------------------------

-- Paquete para definir la tabla con los datos de los trayectos de los vehiculos en el servidor.

with Q_TIPOS_BASICOS;

package Q_TABLA_TRAYECTOS is
   
   pragma Shared_Passive;
   
   C_NUMERO_MAXIMO_VEHICULOS_EN_SERVIDOR : constant Natural := 2;
   
   type T_ARRAY_CRUCES is private;
   
   type T_ELEMENTO_TABLA_DATOS_TRAYECTOS is private;
   
   type T_TABLA_TRAYECTOS is private;
   
   type T_TABLA_COLISIONES is private;
   
   procedure P_CREAR_ELEMENTO_TABLA_DATOS_TRAYECTOS (V_MATRICULA : in String;
                                                     V_TRAMO_ID : in Natural;
                                                     V_CARRIL : in Natural;
                                                     V_SENTIDO_CIRCULACION : in Natural;
                                                     V_POSICION : in Q_TIPOS_BASICOS.T_POSICION_UTM;
                                                     V_NUMERO_CRUCES : in Natural;
                                                     V_ARRAY_CRUCES : in T_ARRAY_CRUCES;
                                                     V_VELOCIDAD : in Q_TIPOS_BASICOS.T_VELOCIDAD;
                                                     V_ELEMENTO_TABLA_DATOS_TRAYECTOS : out T_ELEMENTO_TABLA_DATOS_TRAYECTOS);
   
   function F_OBTENER_TRAYECTO_ID return Natural;
   
   procedure P_INSERTAR_TRAYECTO (V_TRAYECTO_ID : in Natural;
                                  V_TRAYECTO : in T_ELEMENTO_TABLA_DATOS_TRAYECTOS);
   
   function F_OBTENER_NUMERO_TRAYECTOS return Natural;
   
   procedure P_ACTUALIZAR_TRAYECTO (V_TRAYECTO_ID : in Natural;
                                    V_TRAYECTO : in T_ELEMENTO_TABLA_DATOS_TRAYECTOS);
   
   procedure P_ELIMINAR_TRAYECTO (V_TRAYECTO_ID : in Natural);
   
   function F_OBTENER_TABLA_TRAYECTOS return T_TABLA_TRAYECTOS;
   
   function F_HAY_COLISION return Boolean;
   
   function F_OBTENER_TABLA_COLISIONES return T_TABLA_COLISIONES;
   
   function F_OBTENER_NUMERO_COLISIONES return Natural;
   
   function F_OBTENER_MATRICULA_COLISION (V_INDICE : in Natural) return String;
   
   procedure P_INICIALIZAR_ARRAY_CRUCES (V_ARRAY_CRUCES : in out T_ARRAY_CRUCES);
   
   procedure P_INSERTAR_CRUCE (V_POSICION : in Natural;
                               V_CRUCE : in Natural;
                               V_ARRAY_CRUCES : in out T_ARRAY_CRUCES);
   
private
   
   type T_ARRAY_CRUCES is array (1 .. 20) of Natural;
   
   type T_ELEMENTO_TABLA_DATOS_TRAYECTOS is record
      
      R_SLOT_DISPONIBLE : Boolean := True;

      R_MATRICULA : String (1..8);

      -- No se puede depender del paquete Q_TRAMO habra que sacar la constante a un paquete puro.
      R_TRAMO_ID : Natural;

      R_CARRIL : Natural range 1 .. 3 := 1;
      
      R_SENTIDO_CIRCULACION : Natural range 1 .. 2 := 1;
      
      R_NUMERO_CRUCES : Natural := 0;
      
      R_CRUCES : T_ARRAY_CRUCES;

      R_POSICION : Q_TIPOS_BASICOS.T_POSICION_UTM;

      R_VELOCIDAD : Q_TIPOS_BASICOS.T_VELOCIDAD;
      
   end record;
   
   type T_TABLA_TRAYECTOS is array (1..C_NUMERO_MAXIMO_VEHICULOS_EN_SERVIDOR) of T_ELEMENTO_TABLA_DATOS_TRAYECTOS;
   
   -- Array para guardar las matriculas de los vehiculos implicados en colisiones
   type T_TABLA_COLISIONES is array (1..C_NUMERO_MAXIMO_VEHICULOS_EN_SERVIDOR) of String(1..8);
   
   protected T_TABLA_TRAYECTOS_COMPARTIDA is
      
      procedure P_OBTENER_PRIMER_SLOT_LIBRE (V_PRIMER_SLOT_LIBRE : out Natural);
      
      procedure P_INSERTAR_TRAYECTO (V_SLOT : in Natural;
                                     V_DATOS_TRAYECTO : in T_ELEMENTO_TABLA_DATOS_TRAYECTOS);
      
      procedure P_ELIMINAR_TRAYECTO (V_TRAYECTO_ID : in Natural);

      procedure P_ACTUALIZAR_ELEMENTO (V_TRAYECTO_ID : in Natural;
                                       V_DATOS_TRAYECTO : in T_ELEMENTO_TABLA_DATOS_TRAYECTOS);

      function F_OBTENER_TABLA_TRAYECTOS return T_TABLA_TRAYECTOS;
      
      function F_OBTENER_NUMERO_TRAYECTOS return Natural;
      
      function F_OBTENER_TRAYECTO (V_SLOT : in Natural) return T_ELEMENTO_TABLA_DATOS_TRAYECTOS;
      
      function F_HAY_COLISION return Boolean;
      
      function F_OBTENER_TABLA_COLISIONES return T_TABLA_COLISIONES;
      
      function F_OBTENER_NUMERO_COLISIONES return Natural;
      
      function F_OBTENER_MATRICULA_COLISION (V_INDICE : in Natural) return String;
      
      private
      
      R_TABLA : T_TABLA_TRAYECTOS;

      R_NUMERO_TRAYECTOS : Natural range 0 .. C_NUMERO_MAXIMO_VEHICULOS_EN_SERVIDOR := 0;
      
      R_COLISION : Boolean := False;
      
      R_TABLA_COLISIONES : T_TABLA_COLISIONES;
      
      R_NUMERO_COLISIONES : Natural range 0 .. C_NUMERO_MAXIMO_VEHICULOS_EN_SERVIDOR := 0;
      
   end T_TABLA_TRAYECTOS_COMPARTIDA;
   
end Q_TABLA_TRAYECTOS;
----------------------
