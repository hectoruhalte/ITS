--------------------------------------------------------------------------------------------------------------------------------------------
--
--      Fichero:        q_tabla_trayectos-q_acciones.adb
--
--      Autor:          Hector Uhalte Bilbao
--
--      Fecha:          20/11/2020
--
--------------------------------------------------------------------------------------------------------------------------------------------

with Q_ADAPTACION_TRAMO;
with Q_TRAMO;
with Q_SEGMENTO;
with Ada.Text_IO;
with Ada.Integer_Text_IO;

package body Q_TABLA_TRAYECTOS.Q_ACCIONES is

   --------------------------------------------------------------------------
   procedure P_VISUALIZAR_TABLA (V_TABLA_TRAYECTOS : in T_TABLA_TRAYECTOS;
                                 V_LISTA_TRAMOS_ADAPTACION : in Q_ADAPTACION_TRAMO.Q_LISTA_TRAMOS.T_LISTA) is
      
      --V_LISTA_TRAMOS_ADAPTACION : Q_ADAPTACION_TRAMO.Q_LISTA_TRAMOS.T_LISTA;
      
      -- Segmento auxiliar para obtener el numero de carriles
      V_SEGMENTO_AUX : Q_SEGMENTO.T_SEGMENTO;

      -- Tramo aux para obtener el numero de carriles en caso de que estemos en una conexion (y por lo tanto no haya informacion de los
      -- carriles en la adaptacion)
      V_TRAMO_AUX : Q_TRAMO.T_TRAMO;
      
      V_NUMERO_CARRILES : Natural range 1 .. 3 := 1;
  
   begin
      
      --Q_ADAPTACION_TRAMO.Q_LISTA_TRAMOS.P_INICIALIZAR_LISTA (V_LISTA_TRAMOS_ADAPTACION);
      
      -- Cargar la lista de tramos adaptados.
      --Q_ADAPTACION_TRAMO.P_GENERAR_LISTA_TRAMOS (V_LISTA_TRAMOS_ADAPTACION);
      
      -- Visualizar cabecera.
      Ada.Text_Io.Put_Line 
        (" +-----------+---------------------------------+---------+---------+---------------------------------+-------------+");
      Ada.Text_Io.Put_Line 
        (" | MATRICULA |          TRAMO ACTUAL           | CARRIL  | SENTIDO |          POSICION ACTUAL        |  VELOCIDAD  |");
      Ada.Text_Io.Put_Line 
        (" +-----------+---------------------------------+---------+---------+---------------------------------+-------------+");
      
      for I in 1 .. Q_TABLA_TRAYECTOS.C_NUMERO_MAXIMO_VEHICULOS_EN_SERVIDOR loop
         
         if not V_TABLA_TRAYECTOS(I).R_SLOT_DISPONIBLE then
            
            -- Slot ocupado por un trayecto. Visualizar.
            Ada.Text_Io.Put (" | " & V_TABLA_TRAYECTOS(I).R_MATRICULA & "  | ");
            Ada.Text_Io.Put (Q_TRAMO.F_OBTENER_NOMBRE (Q_ADAPTACION_TRAMO.F_OBTENER_TRAMO (V_TABLA_TRAYECTOS(I).R_TRAMO_ID)) & "| ");
            
            -- Visualizar numero de carriles.
            Q_TRAMO.P_INICIALIZAR_TRAMO (V_TRAMO_AUX);
            Q_SEGMENTO.P_INICIALIZAR_SEGMENTO (V_SEGMENTO_AUX);

            Q_TRAMO.P_PONER_ID (V_ID => V_TABLA_TRAYECTOS(I).R_TRAMO_ID,
                                V_TRAMO => V_TRAMO_AUX);

            Q_SEGMENTO.P_PONER_POSICION (V_POSICION => V_TABLA_TRAYECTOS(I).R_POSICION,
                                         V_SEGMENTO => V_SEGMENTO_AUX);

            begin

               V_NUMERO_CARRILES :=
                 Q_SEGMENTO.Q_LISTA_CARRILES.F_CUANTOS_ELEMENTOS
                   (Q_SEGMENTO.F_OBTENER_LISTA_CARRILES
                      (Q_TRAMO.Q_LISTA_SEGMENTOS.F_ENCONTRAR_ELEMENTO
                         (V_ELEMENTO => V_SEGMENTO_AUX,
                          V_LISTA =>
                            Q_TRAMO.F_OBTENER_LISTA_SEGMENTOS
                              (Q_ADAPTACION_TRAMO.Q_LISTA_TRAMOS.F_ENCONTRAR_ELEMENTO
                                   (V_ELEMENTO => V_TRAMO_AUX,
                                    V_LISTA => V_LISTA_TRAMOS_ADAPTACION)))));
               
            exception

               -- Se ha intentado calcular el numero de carriles en una conexion.
               -- Calcular el numero de carriles usando el siguiente elemento de la progresion
               when Q_TRAMO.Q_LISTA_SEGMENTOS.X_ELEMENTO_NO_ENCONTRADO =>

                  Q_SEGMENTO.P_PONER_POSICION
                    (V_POSICION =>
                        Q_SEGMENTO.F_OBTENER_POSICION
                       (Q_TRAMO.Q_LISTA_SEGMENTOS.F_DEVOLVER_ELEMENTO
                            (V_POSICION => 1,
                             V_LISTA =>
                                Q_TRAMO.F_OBTENER_LISTA_SEGMENTOS
                               (Q_ADAPTACION_TRAMO.Q_LISTA_TRAMOS.F_ENCONTRAR_ELEMENTO
                                  (V_ELEMENTO => V_TRAMO_AUX,
                                   V_LISTA => V_LISTA_TRAMOS_ADAPTACION)))),
                     V_SEGMENTO => V_SEGMENTO_AUX);

                  V_NUMERO_CARRILES :=
                    Q_SEGMENTO.Q_LISTA_CARRILES.F_CUANTOS_ELEMENTOS
                      (Q_SEGMENTO.F_OBTENER_LISTA_CARRILES
                         (Q_TRAMO.Q_LISTA_SEGMENTOS.F_ENCONTRAR_ELEMENTO
                            (V_ELEMENTO => V_SEGMENTO_AUX,
                             V_LISTA =>
                                Q_TRAMO.F_OBTENER_LISTA_SEGMENTOS
                              (Q_ADAPTACION_TRAMO.Q_LISTA_TRAMOS.F_ENCONTRAR_ELEMENTO
                                  (V_ELEMENTO => V_TRAMO_AUX,
                                   V_LISTA => V_LISTA_TRAMOS_ADAPTACION)))));

            end;
            
            case V_NUMERO_CARRILES is

            when 1 => 

               Ada.Text_Io.Put ("  |·|  ");

            when 2 =>

               if V_TABLA_TRAYECTOS(I).R_CARRIL = 1 then

                  Ada.Text_Io.Put (" | :·| ");    

               else

                  Ada.Text_Io.Put (" |·: | ");    

               end if;

            when 3 => 

               case V_TABLA_TRAYECTOS(I).R_CARRIL is

               when 1 => 

                  Ada.Text_Io.Put ("| : :·|");

               when 2 =>

                  Ada.Text_Io.Put ("| :·: |");

               when 3 =>

                  Ada.Text_Io.Put ("|·: : |");

               end case;

            end case;
            
            Ada.Text_Io.Put (" |  ");
            
            Ada.Integer_Text_IO.Put (Item  => V_TABLA_TRAYECTOS(I).R_SENTIDO_CIRCULACION,
                                     Width => 3);
            
            Ada.Text_Io.Put ("    |");

            Ada.Text_Io.Put ("    X : ");
            Ada.Integer_Text_Io.Put (Item => Q_TIPOS_BASICOS.F_OBTENER_COORDENADA_X (V_TABLA_TRAYECTOS(I).R_POSICION),
                                     Width => 7);
            Ada.Text_Io.Put ("  Y : ");
            Ada.Integer_Text_Io.Put (Item => Q_TIPOS_BASICOS.F_OBTENER_COORDENADA_Y (V_TABLA_TRAYECTOS(I).R_POSICION),
                                     Width => 7);
            Ada.Text_Io.Put ("     |        ");

            Ada.Integer_Text_Io.Put (Item => V_TABLA_TRAYECTOS(I).R_VELOCIDAD,
                                     Width => 3);
            Ada.Text_Io.Put_Line ("  |");
            
            Ada.Text_Io.Put_Line 
              (" +-----------+---------------------------------+---------+---------+---------------------------------+-------------+");
            
         end if;
         
      end loop;
      
      --Ada.Text_Io.Put_Line 
      --  ("Longitud de la lista de tramos que acabamos de usar (antes) : " & 
      --     Natural'Image(Q_ADAPTACION_TRAMO.Q_LISTA_TRAMOS.F_CUANTOS_ELEMENTOS_PUNTEROS (V_LISTA_TRAMOS_ADAPTACION)));
      
      --Q_ADAPTACION_TRAMO.Q_LISTA_TRAMOS.P_FREE (V_LISTA_TRAMOS_ADAPTACION);
      
      --Ada.Text_Io.Put_Line 
      --  ("Longitud de la lista de tramos que acabamos de usar : " & 
      --     Natural'Image(Q_ADAPTACION_TRAMO.Q_LISTA_TRAMOS.F_CUANTOS_ELEMENTOS_PUNTEROS (V_LISTA_TRAMOS_ADAPTACION)));
      
   end P_VISUALIZAR_TABLA;
   -------------------------------------------------------------------------- 
   
   --------------------------------------------------------------------------------------
   procedure P_ESCRIBIR_TABLA_FICHERO_TEXTO (V_TABLA_TRAYECTOS : in T_TABLA_TRAYECTOS) is
      
      V_FICHERO : Ada.Text_IO.File_Type;
      
      V_LISTA_TRAMOS_ADAPTACION : Q_ADAPTACION_TRAMO.Q_LISTA_TRAMOS.T_LISTA;
      
      -- Segmento auxiliar para obtener el numero de carriles
      V_SEGMENTO_AUX : Q_SEGMENTO.T_SEGMENTO;

      -- Tramo aux para obtener el numero de carriles en caso de que estemos en una conexion (y por lo tanto no haya informacion de los
      -- carriles en la adaptacion)
      V_TRAMO_AUX : Q_TRAMO.T_TRAMO;
      
      V_NUMERO_CARRILES : Natural range 1 .. 3 := 1;
      
   begin
      
      Ada.Text_IO.Create (File => V_FICHERO,
                          Mode => Ada.Text_IO.Out_File,
                          Name => "/home/hector/ITS/distribuido/src/tabla_trayectos.txt",
                          Form => "");
      
      -- Cargar la lista de tramos adaptados.
      Q_ADAPTACION_TRAMO.P_GENERAR_LISTA_TRAMOS (V_LISTA_TRAMOS_ADAPTACION);
      
      -- Visualizar cabecera.
      Ada.Text_IO.Put_Line 
        (File => V_FICHERO,
         Item => " +-----------+---------------------------------+---------+---------------------------------+-------------+");
      Ada.Text_IO.Put_Line
        (File => V_FICHERO,
         Item => " | MATRICULA |          TRAMO ACTUAL           | CARRIL  |          POSICION ACTUAL        |  VELOCIDAD  |");
      Ada.Text_IO.Put_Line
        (File => V_FICHERO,
         Item => " +-----------+---------------------------------+---------+---------------------------------+-------------+");
      
      for I in 1 .. Q_TABLA_TRAYECTOS.C_NUMERO_MAXIMO_VEHICULOS_EN_SERVIDOR loop
         
         if not V_TABLA_TRAYECTOS(I).R_SLOT_DISPONIBLE then
            
            -- Slot ocupado por un trayecto. Visualizar.
            Ada.Text_IO.Put (File => V_FICHERO,
                             Item => " | " & V_TABLA_TRAYECTOS(I).R_MATRICULA & "  | ");
            Ada.Text_IO.Put 
              (File => V_FICHERO,
               Item => Q_TRAMO.F_OBTENER_NOMBRE (Q_ADAPTACION_TRAMO.F_OBTENER_TRAMO (V_TABLA_TRAYECTOS(I).R_TRAMO_ID)) & "| ");
            
            -- Visualizar numero de carriles.
            Q_TRAMO.P_INICIALIZAR_TRAMO (V_TRAMO_AUX);
            Q_SEGMENTO.P_INICIALIZAR_SEGMENTO (V_SEGMENTO_AUX);

            Q_TRAMO.P_PONER_ID (V_ID => V_TABLA_TRAYECTOS(I).R_TRAMO_ID,
                                V_TRAMO => V_TRAMO_AUX);

            Q_SEGMENTO.P_PONER_POSICION (V_POSICION => V_TABLA_TRAYECTOS(I).R_POSICION,
                                         V_SEGMENTO => V_SEGMENTO_AUX);

            begin

               V_NUMERO_CARRILES :=
                 Q_SEGMENTO.Q_LISTA_CARRILES.F_CUANTOS_ELEMENTOS
                   (Q_SEGMENTO.F_OBTENER_LISTA_CARRILES
                      (Q_TRAMO.Q_LISTA_SEGMENTOS.F_ENCONTRAR_ELEMENTO
                         (V_ELEMENTO => V_SEGMENTO_AUX,
                          V_LISTA =>
                            Q_TRAMO.F_OBTENER_LISTA_SEGMENTOS
                              (Q_ADAPTACION_TRAMO.Q_LISTA_TRAMOS.F_ENCONTRAR_ELEMENTO
                                   (V_ELEMENTO => V_TRAMO_AUX,
                                    V_LISTA => V_LISTA_TRAMOS_ADAPTACION)))));
               
            exception

                  -- Se ha intentado calcular el numero de carriles en una conexion.
                  -- Calcular el numero de carriles usando el siguiente elemento de la progresion
               when Q_TRAMO.Q_LISTA_SEGMENTOS.X_ELEMENTO_NO_ENCONTRADO =>

                  Q_SEGMENTO.P_PONER_POSICION
                    (V_POSICION =>
                        Q_SEGMENTO.F_OBTENER_POSICION
                       (Q_TRAMO.Q_LISTA_SEGMENTOS.F_DEVOLVER_ELEMENTO
                            (V_POSICION => 1,
                             V_LISTA =>
                                Q_TRAMO.F_OBTENER_LISTA_SEGMENTOS
                               (Q_ADAPTACION_TRAMO.Q_LISTA_TRAMOS.F_ENCONTRAR_ELEMENTO
                                  (V_ELEMENTO => V_TRAMO_AUX,
                                   V_LISTA => V_LISTA_TRAMOS_ADAPTACION)))),
                     V_SEGMENTO => V_SEGMENTO_AUX);

                  V_NUMERO_CARRILES :=
                    Q_SEGMENTO.Q_LISTA_CARRILES.F_CUANTOS_ELEMENTOS
                      (Q_SEGMENTO.F_OBTENER_LISTA_CARRILES
                         (Q_TRAMO.Q_LISTA_SEGMENTOS.F_ENCONTRAR_ELEMENTO
                            (V_ELEMENTO => V_SEGMENTO_AUX,
                             V_LISTA =>
                                Q_TRAMO.F_OBTENER_LISTA_SEGMENTOS
                               (Q_ADAPTACION_TRAMO.Q_LISTA_TRAMOS.F_ENCONTRAR_ELEMENTO
                                    (V_ELEMENTO => V_TRAMO_AUX,
                                     V_LISTA => V_LISTA_TRAMOS_ADAPTACION)))));

            end;
            
            case V_NUMERO_CARRILES is

            when 1 => 

               Ada.Text_IO.Put (File => V_FICHERO,
                                Item => "  |·|  ");

            when 2 =>

               if V_TABLA_TRAYECTOS(I).R_CARRIL = 1 then

                  Ada.Text_Io.Put (File => V_FICHERO,
                                   Item => " | :·| ");    

               else

                  Ada.Text_IO.Put (File => V_FICHERO,
                                   Item => " |·: | ");  

               end if;

            when 3 => 

               case V_TABLA_TRAYECTOS(I).R_CARRIL is

               when 1 => 

                  Ada.Text_IO.Put (File => V_FICHERO,
                                   Item => "| : :·|");

               when 2 =>

                  Ada.Text_IO.Put (File => V_FICHERO,
                                   Item => "| :·: |");

               when 3 =>

                  Ada.Text_IO.Put (File => V_FICHERO,
                                   Item => "|·: : |");

               end case;

            end case;
            
            Ada.Text_IO.Put (File => V_FICHERO,
                             Item => " |");

            Ada.Text_IO.Put (File => V_FICHERO,
                             Item => "    X : ");
            
            Ada.Integer_Text_IO.Put (File  => V_FICHERO,
                                     Item  => Q_TIPOS_BASICOS.F_OBTENER_COORDENADA_X (V_TABLA_TRAYECTOS(I).R_POSICION),
                                     Width => 7);
            
            Ada.Text_IO.Put (File => V_FICHERO,
                             Item => "  Y : ");
            
            Ada.Integer_Text_IO.Put (File  => V_FICHERO,
                                     Item  => Q_TIPOS_BASICOS.F_OBTENER_COORDENADA_Y (V_TABLA_TRAYECTOS(I).R_POSICION),
                                     Width => 7);
            
            Ada.Text_IO.Put (File => V_FICHERO,
                             Item => "     |");
            
            Ada.Integer_Text_IO.Put (File  => V_FICHERO,
                                     Item  => V_TABLA_TRAYECTOS(I).R_VELOCIDAD,
                                     Width => 3);

            Ada.Text_IO.Put_Line (File => V_FICHERO,
                                  Item => "          |");
            
            Ada.Text_IO.Put_Line 
              (File => V_FICHERO,
               Item => " +-----------+---------------------------------+---------+---------------------------------+-------------+");
            
         end if;
         
      end loop;

      Ada.Text_IO.Close (V_FICHERO);
      
   end P_ESCRIBIR_TABLA_FICHERO_TEXTO;
   --------------------------------------------------------------------------------------
   
   procedure P_VISUALIZAR_CABECERA is
      
   begin
   
      Ada.Text_Io.Put_Line (" +-----------+---------------------------------+---------+---------------------------------+-------------+");
      Ada.Text_Io.Put_Line (" | MATRICULA |          TRAMO ACTUAL           | CARRIL  |          POSICION ACTUAL        |  VELOCIDAD  |");
      Ada.Text_Io.Put_Line (" +-----------+---------------------------------+---------+---------------------------------+-------------+");
      
   end P_VISUALIZAR_CABECERA;
   
   
   procedure P_VISUALIZAR_TRAYECTO (V_TRAYECTO : in T_ELEMENTO_TABLA_DATOS_TRAYECTOS) is
      
      V_LISTA_TRAMOS_ADAPTACION : Q_ADAPTACION_TRAMO.Q_LISTA_TRAMOS.T_LISTA;
      
      -- Segmento auxiliar para obtener el numero de carriles
      V_SEGMENTO_AUX : Q_SEGMENTO.T_SEGMENTO;

      -- Tramo aux para obtener el numero de carriles en caso de que estemos en una conexion (y por lo tanto no haya informacion de los
      -- carriles en la adaptacion)
      V_TRAMO_AUX : Q_TRAMO.T_TRAMO;
      
      V_NUMERO_CARRILES : Natural range 1 .. 3 := 1;
      
   begin
      
      if not V_TRAYECTO.R_SLOT_DISPONIBLE then
      
         -- Cargar la lista de tramos adaptados.
         Q_ADAPTACION_TRAMO.P_GENERAR_LISTA_TRAMOS (V_LISTA_TRAMOS_ADAPTACION);
      
         Ada.Text_Io.Put (" | " & V_TRAYECTO.R_MATRICULA & "  | ");
         Ada.Text_Io.Put (Q_TRAMO.F_OBTENER_NOMBRE (Q_ADAPTACION_TRAMO.F_OBTENER_TRAMO (V_TRAYECTO.R_TRAMO_ID)) & "| ");
            
         -- Visualizar numero de carriles.
         Q_TRAMO.P_INICIALIZAR_TRAMO (V_TRAMO_AUX);
         Q_SEGMENTO.P_INICIALIZAR_SEGMENTO (V_SEGMENTO_AUX);

         Q_TRAMO.P_PONER_ID (V_ID => V_TRAYECTO.R_TRAMO_ID,
                             V_TRAMO => V_TRAMO_AUX);

         Q_SEGMENTO.P_PONER_POSICION (V_POSICION => V_TRAYECTO.R_POSICION,
                                      V_SEGMENTO => V_SEGMENTO_AUX);

         begin

            V_NUMERO_CARRILES :=
              Q_SEGMENTO.Q_LISTA_CARRILES.F_CUANTOS_ELEMENTOS
                (Q_SEGMENTO.F_OBTENER_LISTA_CARRILES
                   (Q_TRAMO.Q_LISTA_SEGMENTOS.F_ENCONTRAR_ELEMENTO
                      (V_ELEMENTO => V_SEGMENTO_AUX,
                       V_LISTA =>
                         Q_TRAMO.F_OBTENER_LISTA_SEGMENTOS
                           (Q_ADAPTACION_TRAMO.Q_LISTA_TRAMOS.F_ENCONTRAR_ELEMENTO
                                (V_ELEMENTO => V_TRAMO_AUX,
                                 V_LISTA => V_LISTA_TRAMOS_ADAPTACION)))));
               
         exception

               -- Se ha intentado calcular el numero de carriles en una conexion.
               -- Calcular el numero de carriles usando el siguiente elemento de la progresion
            when Q_TRAMO.Q_LISTA_SEGMENTOS.X_ELEMENTO_NO_ENCONTRADO =>

               Q_SEGMENTO.P_PONER_POSICION
                 (V_POSICION =>
                     Q_SEGMENTO.F_OBTENER_POSICION
                    (Q_TRAMO.Q_LISTA_SEGMENTOS.F_DEVOLVER_ELEMENTO
                         (V_POSICION => 1,
                          V_LISTA =>
                             Q_TRAMO.F_OBTENER_LISTA_SEGMENTOS
                            (Q_ADAPTACION_TRAMO.Q_LISTA_TRAMOS.F_ENCONTRAR_ELEMENTO
                               (V_ELEMENTO => V_TRAMO_AUX,
                                V_LISTA => V_LISTA_TRAMOS_ADAPTACION)))),
                  V_SEGMENTO => V_SEGMENTO_AUX);

               V_NUMERO_CARRILES :=
                 Q_SEGMENTO.Q_LISTA_CARRILES.F_CUANTOS_ELEMENTOS
                   (Q_SEGMENTO.F_OBTENER_LISTA_CARRILES
                      (Q_TRAMO.Q_LISTA_SEGMENTOS.F_ENCONTRAR_ELEMENTO
                         (V_ELEMENTO => V_SEGMENTO_AUX,
                          V_LISTA =>
                             Q_TRAMO.F_OBTENER_LISTA_SEGMENTOS
                            (Q_ADAPTACION_TRAMO.Q_LISTA_TRAMOS.F_ENCONTRAR_ELEMENTO
                                 (V_ELEMENTO => V_TRAMO_AUX,
                                  V_LISTA => V_LISTA_TRAMOS_ADAPTACION)))));

         end;
            
         case V_NUMERO_CARRILES is

         when 1 => 

            Ada.Text_Io.Put ("  |·|  ");

         when 2 =>

            if V_TRAYECTO.R_CARRIL = 1 then

               Ada.Text_Io.Put (" | :·| ");    

            else

               Ada.Text_Io.Put (" |·: | ");    

            end if;

         when 3 => 

            case V_TRAYECTO.R_CARRIL is

               when 1 => 

                  Ada.Text_Io.Put ("| : :·|");

               when 2 =>

                  Ada.Text_Io.Put ("| :·: |");

               when 3 =>

                  Ada.Text_Io.Put ("|·: : |");

            end case;

         end case;
            
         Ada.Text_Io.Put (" |");

         Ada.Text_Io.Put ("    X : ");
         Ada.Integer_Text_Io.Put (Item => Q_TIPOS_BASICOS.F_OBTENER_COORDENADA_X (V_TRAYECTO.R_POSICION),
                                  Width => 7);
         Ada.Text_Io.Put ("  Y : ");
         Ada.Integer_Text_Io.Put (Item => Q_TIPOS_BASICOS.F_OBTENER_COORDENADA_Y (V_TRAYECTO.R_POSICION),
                                  Width => 7);
         Ada.Text_Io.Put ("     |");

         Ada.Integer_Text_Io.Put (Item => V_TRAYECTO.R_VELOCIDAD,
                                  Width => 3);
         Ada.Text_Io.Put_Line ("          |");
            
         Ada.Text_Io.Put_Line 
           (" +-----------+---------------------------------+---------+---------------------------------+-------------+");
      
      end if;
         
   end P_VISUALIZAR_TRAYECTO;
   
   
   
end Q_TABLA_TRAYECTOS.Q_ACCIONES;
--------------------------------------------------------------------------------------------------------------------------------------------
