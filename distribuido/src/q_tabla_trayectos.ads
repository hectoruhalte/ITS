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
   
   type T_ELEMENTO_TABLA_DATOS_TRAYECTOS is private;
   
   type T_TABLA_TRAYECTOS is private;
   
   procedure P_CREAR_ELEMENTO_TABLA_DATOS_TRAYECTOS (V_MATRICULA : in String;
                                                     V_TRAMO_ID : in Natural;
                                                     V_CARRIL : in Natural;
                                                     V_POSICION : in Q_TIPOS_BASICOS.T_POSICION_UTM;
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
   
private
   
   type T_ELEMENTO_TABLA_DATOS_TRAYECTOS is record
      
      R_SLOT_DISPONIBLE : Boolean := True;

      R_MATRICULA : String (1..8);

      -- No se puede depender del paquete Q_TRAMO habra que sacar la constante a un paquete puro.
      R_TRAMO_ID : Natural;

      R_CARRIL : Natural range 1 .. 3 := 1;

      R_POSICION : Q_TIPOS_BASICOS.T_POSICION_UTM;

      R_VELOCIDAD : Q_TIPOS_BASICOS.T_VELOCIDAD;
      
   end record;
   
   type T_TABLA_TRAYECTOS is array (1..C_NUMERO_MAXIMO_VEHICULOS_EN_SERVIDOR) of T_ELEMENTO_TABLA_DATOS_TRAYECTOS;
   
   protected T_TABLA_TRAYECTOS_COMPARTIDA is
      
      procedure P_OBTENER_PRIMER_SLOT_LIBRE (V_PRIMER_SLOT_LIBRE : out Natural);
      
      procedure P_INSERTAR_TRAYECTO (V_SLOT : in Natural;
                                     V_DATOS_TRAYECTO : in T_ELEMENTO_TABLA_DATOS_TRAYECTOS);
      
      procedure P_ELIMINAR_TRAYECTO (V_TRAYECTO_ID : in Natural);

      procedure P_ACTUALIZAR_ELEMENTO (V_TRAYECTO_ID : in Natural;
                                       V_DATOS_TRAYECTO : in T_ELEMENTO_TABLA_DATOS_TRAYECTOS);

      function F_OBTENER_TABLA_TRAYECTOS return T_TABLA_TRAYECTOS;
      
      function F_OBTENER_NUMERO_TRAYECTOS return Natural;
      
      private
      
      R_TABLA : T_TABLA_TRAYECTOS;

      R_NUMERO_TRAYECTOS : Natural range 0 .. C_NUMERO_MAXIMO_VEHICULOS_EN_SERVIDOR := 0;
      
   end T_TABLA_TRAYECTOS_COMPARTIDA;
   
end Q_TABLA_TRAYECTOS;
----------------------
