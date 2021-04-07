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
                                                     V_SENTIDO_CIRCULACION : in Natural;
                                                     V_POSICION : in Q_TIPOS_BASICOS.T_POSICION_UTM;
                                                     V_NUMERO_CRUCES : in Natural;
                                                     V_ARRAY_CRUCES : in T_ARRAY_CRUCES;
                                                     V_VELOCIDAD : in Q_TIPOS_BASICOS.T_VELOCIDAD;
                                                     V_ELEMENTO_TABLA_DATOS_TRAYECTOS : out T_ELEMENTO_TABLA_DATOS_TRAYECTOS) is

   begin

      -- Al crear el trayecto ya se asume que el slot donde se inserte el trayecto estara reservado ya al obtener el trayecto id con la ruta
      V_ELEMENTO_TABLA_DATOS_TRAYECTOS.R_SLOT_DISPONIBLE := False;
      V_ELEMENTO_TABLA_DATOS_TRAYECTOS.R_MATRICULA (1..8) := V_MATRICULA (V_MATRICULA'First..V_MATRICULA'First+7);
      V_ELEMENTO_TABLA_DATOS_TRAYECTOS.R_TRAMO_ID := V_TRAMO_ID;
      V_ELEMENTO_TABLA_DATOS_TRAYECTOS.R_CARRIL := V_CARRIL;
      V_ELEMENTO_TABLA_DATOS_TRAYECTOS.R_SENTIDO_CIRCULACION := V_SENTIDO_CIRCULACION;
      V_ELEMENTO_TABLA_DATOS_TRAYECTOS.R_POSICION := V_POSICION;
      V_ELEMENTO_TABLA_DATOS_TRAYECTOS.R_NUMERO_CRUCES := V_NUMERO_CRUCES;
      V_ELEMENTO_TABLA_DATOS_TRAYECTOS.R_CRUCES := V_ARRAY_CRUCES;
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
         
         V_POSICION : Q_TIPOS_BASICOS.T_POSICION_UTM;

      begin

         R_TABLA (V_TRAYECTO_ID) := V_DATOS_TRAYECTO;
         
         -- Busqueda de colisiones.
         -- Cada vez que se actualice un trayecto comprobar si hay una colision o no.
         -- Si hay mas de un trayecto en la tabla.
         if R_NUMERO_TRAYECTOS > 1 then
         
            for I in 1 .. R_NUMERO_TRAYECTOS-1 loop
               
               V_POSICION := R_TABLA(I).R_POSICION;
               
               for J in I+1 .. R_NUMERO_TRAYECTOS loop
                  
                  -- Buscar una posible colision en tramo
                  if (Q_TIPOS_BASICOS."=" (V_POSICION_1 => V_POSICION,
                                           V_POSICION_2 => R_TABLA(J).R_POSICION))
                  then
                     
                     -- Mirar si hay colision por alcance:
                     -- Si el tramo es el mismo, el carril es el mismo y el sentido es el mismo => Colision por alcance.
                     if (R_TABLA(I).R_TRAMO_ID = R_TABLA(J).R_TRAMO_ID) and then
                       (R_TABLA(I).R_CARRIL = R_TABLA(J).R_CARRIL) and then
                       (R_TABLA(I).R_SENTIDO_CIRCULACION = R_TABLA(J).R_SENTIDO_CIRCULACION) then
                     
                        -- Colision por alcance
                        R_COLISION := True;
                        
                        -- Comprobar que no se ha contabilizado ya esta colision.
                        -- No podemos tener un numero mayor de colisiones que de vehiculos.
                        -- Si en este punto ya tenemos el numero maximo posible de colisiones es que alguna se esta contabilizando 
                        -- doblemente.
                        if R_NUMERO_COLISIONES < C_NUMERO_MAXIMO_VEHICULOS_EN_SERVIDOR-1 then
                           
                           R_NUMERO_COLISIONES := R_NUMERO_COLISIONES + 1;
                           R_TABLA_COLISIONES(R_NUMERO_COLISIONES) := R_TABLA(I).R_MATRICULA(1..8);
                           R_TABLA_COLISIONES(R_NUMERO_COLISIONES+1) := R_TABLA(J).R_MATRICULA(1..8);
                        
                        end if;
                           
                     -- Mirar si hay colision en un cruce.
                     -- Si la posicion que estamos evaluando es la de un cruce. Habra colision si algun cruce aparece en ambas listas de
                     -- cruces. Si no es un cruce, el numero de cruces estara a 0.   
                     elsif R_TABLA(I).R_NUMERO_CRUCES > 0 then
                        
                        for K in 1 .. R_TABLA(I).R_NUMERO_CRUCES loop
                        
                           for L in 1 .. R_TABLA(J).R_NUMERO_CRUCES loop
                              
                              if R_TABLA(I).R_CRUCES(K) = R_TABLA(J).R_CRUCES(L) then
                                 
                                 R_COLISION := True;
                                 
                                 if R_NUMERO_COLISIONES < C_NUMERO_MAXIMO_VEHICULOS_EN_SERVIDOR-1 then
                                 
                                    R_NUMERO_COLISIONES := R_NUMERO_COLISIONES + 1;
                                    R_TABLA_COLISIONES(R_NUMERO_COLISIONES) := R_TABLA(I).R_MATRICULA(1..8);
                                    R_TABLA_COLISIONES(R_NUMERO_COLISIONES+1) := R_TABLA(J).R_MATRICULA(1..8);
                                    exit;
                                    
                                 end if;   
                                 
                              end if;   
                              
                           end loop;
                           
                           exit when R_COLISION;
                           
                        end loop;
                        
                     end if;
                      
                  end if;
                  
               end loop;
               
               if not R_COLISION then
               
                  -- Inicializar tabla colisiones.
                  R_COLISION := False;
                  R_NUMERO_COLISIONES := 0;
                  R_TABLA_COLISIONES := (others => "        ");
                  
               end if;
               
            end loop;
            
         end if;
         
      end P_ACTUALIZAR_ELEMENTO;


      function F_OBTENER_TABLA_TRAYECTOS return T_TABLA_TRAYECTOS is

      begin

         return R_TABLA;
         
      end F_OBTENER_TABLA_TRAYECTOS;
      
      
      function F_OBTENER_NUMERO_TRAYECTOS return Natural is
         
      begin

         return R_NUMERO_TRAYECTOS;
         
      end F_OBTENER_NUMERO_TRAYECTOS;
      
      
      function F_OBTENER_TRAYECTO (V_SLOT : in Natural) return T_ELEMENTO_TABLA_DATOS_TRAYECTOS is
         
      begin
         
         return R_TABLA (V_SLOT);
         
      end F_OBTENER_TRAYECTO;
      
      
      function F_HAY_COLISION return Boolean is
         
      begin
         
         return R_COLISION;
         
      end F_HAY_COLISION;
      
      
      function F_OBTENER_TABLA_COLISIONES return T_TABLA_COLISIONES is
         
      begin
         
         return R_TABLA_COLISIONES;
         
      end F_OBTENER_TABLA_COLISIONES;
      
      
      function F_OBTENER_NUMERO_COLISIONES return Natural is
         
      begin
         
         return R_NUMERO_COLISIONES;
         
      end F_OBTENER_NUMERO_COLISIONES;
      
      
      function F_OBTENER_MATRICULA_COLISION (V_INDICE : in Natural) return String is
 
      begin
      
         return R_TABLA_COLISIONES(V_INDICE)(1..8);
         
      end F_OBTENER_MATRICULA_COLISION;
      
      
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
   
   -----------------------------------------
   function F_HAY_COLISION return Boolean is
      
   begin
      
      return T_TABLA_TRAYECTOS_COMPARTIDA.F_HAY_COLISION;
      
   end F_HAY_COLISION;
   ------------------------------------------
   
   ----------------------------------------------------------------
   function F_OBTENER_TABLA_COLISIONES return T_TABLA_COLISIONES is
      
   begin
      
      return T_TABLA_TRAYECTOS_COMPARTIDA.F_OBTENER_TABLA_COLISIONES;
      
   end F_OBTENER_TABLA_COLISIONES;
   ----------------------------------------------------------------
   
   ------------------------------------------------------
   function F_OBTENER_NUMERO_COLISIONES return Natural is
      
   begin
      
      return T_TABLA_TRAYECTOS_COMPARTIDA.F_OBTENER_NUMERO_COLISIONES;
      
   end F_OBTENER_NUMERO_COLISIONES;
   ------------------------------------------------------
   
   ------------------------------------------------------------------------------
   function F_OBTENER_MATRICULA_COLISION (V_INDICE : in Natural) return String is
      
      V_MATRICULA : String (1..8);
      
   begin
      
      V_MATRICULA := T_TABLA_TRAYECTOS_COMPARTIDA.F_OBTENER_MATRICULA_COLISION(V_INDICE);
      
      return V_MATRICULA(1..8);
      
   end F_OBTENER_MATRICULA_COLISION;
   -------------------------------------------------------------------------------
   
   --------------------------------------------------------------------------------
   procedure P_INICIALIZAR_ARRAY_CRUCES (V_ARRAY_CRUCES : in out T_ARRAY_CRUCES) is
      
   begin
      
      V_ARRAY_CRUCES := (others => 0);
      
   end P_INICIALIZAR_ARRAY_CRUCES;
   --------------------------------------------------------------------------------
   
   ----------------------------------------------------------------------
   procedure P_INSERTAR_CRUCE (V_POSICION : in Natural;
                               V_CRUCE : in Natural;
                               V_ARRAY_CRUCES : in out T_ARRAY_CRUCES) is
      
   begin
      
      V_ARRAY_CRUCES (V_POSICION) := V_CRUCE;
      
   end P_INSERTAR_CRUCE;
   ----------------------------------------------------------------------
     
end Q_TABLA_TRAYECTOS;
--------------------------------------------------------------------------------------------------------------------------------------------
