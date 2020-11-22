--------------------------------------------------------------------------------------------------------------------------------------------
--
--      Fichero:        q_tabla_trayectos.adb
--
--      Autor:          Hector Uhalte Bilbao
--
--      Fecha:          29/10/2020
--
--------------------------------------------------------------------------------------------------------------------------------------------

package body Q_TABLA_TRAYECTOS is
   
   -----------------------------------------------------------------------------------------------------------------------------
   procedure P_CREAR_ELEMENTO_TABLA_DATOS_TRAYECTOS (V_MATRICULA : in String;
                                                     V_TRAMO_ID : in Natural;
                                                     V_CARRIL : in Natural;
                                                     V_POSICION : in Q_TIPOS_BASICOS.T_POSICION_UTM;
                                                     V_VELOCIDAD : in Q_TIPOS_BASICOS.T_VELOCIDAD;
                                                     V_ELEMENTO_TABLA_DATOS_TRAYECTOS : out T_ELEMENTO_TABLA_DATOS_TRAYECTOS) is

   begin

      -- Al crear el trayecto ya se asume que el slot donde se inserte el trayecto estara reservado ya al obtener el trayecto id con la ruta
      V_ELEMENTO_TABLA_DATOS_TRAYECTOS.R_SLOT_DISPONIBLE := False;
      V_ELEMENTO_TABLA_DATOS_TRAYECTOS.R_MATRICULA (1..8) := V_MATRICULA (V_MATRICULA'First..V_MATRICULA'First+7);
      V_ELEMENTO_TABLA_DATOS_TRAYECTOS.R_TRAMO_ID := V_TRAMO_ID;
      V_ELEMENTO_TABLA_DATOS_TRAYECTOS.R_CARRIL := V_CARRIL;
      V_ELEMENTO_TABLA_DATOS_TRAYECTOS.R_POSICION := V_POSICION;
      V_ELEMENTO_TABLA_DATOS_TRAYECTOS.R_VELOCIDAD := V_VELOCIDAD;

   end P_CREAR_ELEMENTO_TABLA_DATOS_TRAYECTOS;
   -----------------------------------------------------------------------------------------------------------------------------
   
   ----------------------------------------------
   protected body T_TABLA_TRAYECTOS_COMPARTIDA is

      procedure P_OBTENER_PRIMER_SLOT_LIBRE (V_PRIMER_SLOT_LIBRE : out Natural) is

         X_NO_SE_PUEDE_INSERTAR_TRAYECTO : Exception;

      begin

         -- Inicializar
         V_PRIMER_SLOT_LIBRE := 0;

         -- Buscar en la tabla el primer slot disponible.
         for I in 1 .. C_NUMERO_MAXIMO_VEHICULOS_EN_SERVIDOR loop

            if R_TABLA(I).R_SLOT_DISPONIBLE then

               V_PRIMER_SLOT_LIBRE := I;

               -- Bloquear el slot.
               R_TABLA(I).R_SLOT_DISPONIBLE := False;
               exit;

            end if;

         end loop;

         if V_PRIMER_SLOT_LIBRE = 0 then

            raise X_NO_SE_PUEDE_INSERTAR_TRAYECTO;

         end if;
         
      end P_OBTENER_PRIMER_SLOT_LIBRE;
      
      
      procedure P_INSERTAR_TRAYECTO (V_SLOT : in Natural;
                                     V_DATOS_TRAYECTO : in T_ELEMENTO_TABLA_DATOS_TRAYECTOS) is

      begin

         R_TABLA (V_SLOT) := V_DATOS_TRAYECTO;

         R_NUMERO_TRAYECTOS := R_NUMERO_TRAYECTOS + 1;

      end P_INSERTAR_TRAYECTO;


      procedure P_ELIMINAR_TRAYECTO (V_TRAYECTO_ID : in Natural) is

      begin

         R_TABLA(V_TRAYECTO_ID).R_SLOT_DISPONIBLE := True;

         R_NUMERO_TRAYECTOS := R_NUMERO_TRAYECTOS - 1;

      end P_ELIMINAR_TRAYECTO;
      
      procedure P_ACTUALIZAR_ELEMENTO (V_TRAYECTO_ID : in Natural;
                                       V_DATOS_TRAYECTO : in T_ELEMENTO_TABLA_DATOS_TRAYECTOS) is

      begin

         R_TABLA (V_TRAYECTO_ID) := V_DATOS_TRAYECTO;
         
      end P_ACTUALIZAR_ELEMENTO;


      function F_OBTENER_TABLA_TRAYECTOS return T_TABLA_TRAYECTOS is

      begin

         return R_TABLA;
         
      end F_OBTENER_TABLA_TRAYECTOS;
      
      
      function F_OBTENER_NUMERO_TRAYECTOS return Natural is
         
      begin

         return R_NUMERO_TRAYECTOS;
         
      end F_OBTENER_NUMERO_TRAYECTOS;
      
      
   end T_TABLA_TRAYECTOS_COMPARTIDA;
   ---------------------------------
   
   ------------------------------------------------
   function F_OBTENER_TRAYECTO_ID return Natural is
      
      V_TRAYECTO_ID : Natural := 0;
      
   begin
      
      T_TABLA_TRAYECTOS_COMPARTIDA.P_OBTENER_PRIMER_SLOT_LIBRE (V_TRAYECTO_ID);
      
      return V_TRAYECTO_ID;
      
   end F_OBTENER_TRAYECTO_ID;
   --------------------------
   
   -----------------------------------------------------------------------------------
   procedure P_INSERTAR_TRAYECTO (V_TRAYECTO_ID : in Natural;
                                  V_TRAYECTO : in T_ELEMENTO_TABLA_DATOS_TRAYECTOS) is

   begin
      
      T_TABLA_TRAYECTOS_COMPARTIDA.P_INSERTAR_TRAYECTO (V_SLOT           => V_TRAYECTO_ID,
                                                        V_DATOS_TRAYECTO => V_TRAYECTO);

   end P_INSERTAR_TRAYECTO;
   -----------------------------------------------------------------------------------
   
   -----------------------------------------------------
   function F_OBTENER_NUMERO_TRAYECTOS return Natural is
      
   begin
      
      return T_TABLA_TRAYECTOS_COMPARTIDA.F_OBTENER_NUMERO_TRAYECTOS;
      
   end F_OBTENER_NUMERO_TRAYECTOS;
   -------------------------------
   
   -------------------------------------------------------------------------------------
   procedure P_ACTUALIZAR_TRAYECTO (V_TRAYECTO_ID : in Natural;
                                    V_TRAYECTO : in T_ELEMENTO_TABLA_DATOS_TRAYECTOS) is

   begin

      T_TABLA_TRAYECTOS_COMPARTIDA.P_ACTUALIZAR_ELEMENTO (V_TRAYECTO_ID    => V_TRAYECTO_ID,
                                                          V_DATOS_TRAYECTO => V_TRAYECTO);

   end P_ACTUALIZAR_TRAYECTO;
   -------------------------------------------------------------------------------------
   
   -------------------------------------------------------------
   procedure P_ELIMINAR_TRAYECTO (V_TRAYECTO_ID : in Natural) is

   begin

      T_TABLA_TRAYECTOS_COMPARTIDA.P_ELIMINAR_TRAYECTO (V_TRAYECTO_ID);

   end P_ELIMINAR_TRAYECTO;
   -------------------------------------------------------------
   
   --------------------------------------------------------------
   function F_OBTENER_TABLA_TRAYECTOS return T_TABLA_TRAYECTOS is
   
   begin
      
      return T_TABLA_TRAYECTOS_COMPARTIDA.F_OBTENER_TABLA_TRAYECTOS;
      
   end F_OBTENER_TABLA_TRAYECTOS;
   ---------------------------------------------------------------
   
end Q_TABLA_TRAYECTOS;
--------------------------------------------------------------------------------------------------------------------------------------------
