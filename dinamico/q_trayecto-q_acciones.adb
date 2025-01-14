-------------------------------------------------------------------------------------------------------------------------------------------
--
--      Fichero:        q_trayecto-q_acciones.adb
--
--      Autor:          Hector Uhalte Bilbao
--
--      Fecha:          1/7/2019
--      
-------------------------------------------------------------------------------------------------------------------------------------------

with Ada.Text_Io;
with Q_TRAMO;
with Ada.Integer_Text_Io;
with gnat.calendar.time_io;
with Q_VEHICULO.Q_ACCIONES;
with Q_SEGMENTO;
with Q_ADAPTACION_TRAMO;
with Q_RESTRICCION;

package body Q_TRAYECTO.Q_ACCIONES is

   ----------------------------------------------------
   procedure P_VISUALIZAR_CABECERA_ESTATICA_TRAYECTO is

   begin

      Ada.Text_Io.Put_Line (" +--------+---------------------------------+---------------------------------+-------------+" &
                              "--------------+---------------+");

      Ada.Text_Io.Put_Line (" |   ID   |             ORIGEN              |            DESTINO              | HORA SALIDA |" &
                              " DURACION (s) | DISTANCIA (m) |");

      Ada.Text_Io.Put_Line (" +--------+---------------------------------+---------------------------------+-------------+" &
                              "--------------+---------------+");

   end P_VISUALIZAR_CABECERA_ESTATICA_TRAYECTO;
   -----------------------------------------------------

   ----------------------------------------------------------------------------------------------------------------------
   procedure P_VISUALIZAR_PARTE_ESTATICA_TRAYECTO (V_TRAYECTO : in T_TRAYECTO;
                                                   V_LISTA_TRAMOS_ADAPTACION : in Q_ADAPTACION_TRAMO.Q_LISTA_TRAMOS.T_LISTA) is

      V_TRAMO_AUX : Q_TRAMO.T_TRAMO;

   begin

      Ada.Text_Io.Put (" |");

      Ada.Text_Io.Put (V_TRAYECTO.R_ID(1..8));

      -- Obtener nombre tramo origen.
      Q_TRAMO.P_INICIALIZAR_TRAMO (V_TRAMO_AUX);

      Q_TRAMO.P_PONER_ID 
        (V_ID => V_TRAYECTO.R_ID_TRAMO_ORIGEN,
         V_TRAMO => V_TRAMO_AUX);

      Ada.Text_Io.Put ("| " & 
                         Q_TRAMO.F_OBTENER_NOMBRE 
                         (Q_ADAPTACION_TRAMO.Q_LISTA_TRAMOS.F_ENCONTRAR_ELEMENTO 
                            (V_ELEMENTO => V_TRAMO_AUX,
                             V_LISTA => V_LISTA_TRAMOS_ADAPTACION)) & "| ");

      Q_TRAMO.P_PONER_ID
        (V_ID => V_TRAYECTO.R_ID_TRAMO_DESTINO,
         V_TRAMO => V_TRAMO_AUX);

      Ada.Text_Io.Put 
        (Q_TRAMO.F_OBTENER_NOMBRE 
           (Q_ADAPTACION_TRAMO.Q_LISTA_TRAMOS.F_ENCONTRAR_ELEMENTO (V_ELEMENTO => V_TRAMO_AUX,
                                                                    V_LISTA => V_LISTA_TRAMOS_ADAPTACION)) & "|    ");

      gnat.calendar.time_io.put_time (Q_TRAYECTO.F_OBTENER_HORA_SALIDA (V_TRAYECTO),"%H:%M");

      Ada.Text_Io.Put ("    |         ");

      Ada.Integer_Text_Io.Put (Item => Q_TRAYECTO.F_OBTENER_DURACION (V_TRAYECTO),
                               Width => 3);

      Ada.Text_Io.Put ("  |         ");

      Ada.Integer_Text_Io.Put (Item => Q_TRAYECTO.F_OBTENER_DISTANCIA (V_TRAYECTO),
                               Width => 4);

      Ada.Text_Io.Put_Line ("  |         ");

      Ada.Text_Io.Put_Line (" +--------+---------------------------------+---------------------------------+-------------+" &
                              "--------------+---------------+");

      Ada.Text_Io.Put_Line ("     +---------------------------------+---------+---------+---------------------------------+" &
                              "-------------+--------------+---------------+");			

   end P_VISUALIZAR_PARTE_ESTATICA_TRAYECTO;
   ----------------------------------------------------------------------------------------------------------------------

   ----------------------------------------------------
   procedure P_VISUALIZAR_CABECERA_DINAMICA_TRAYECTO is

   begin

      Ada.Text_Io.Put_Line ("     |          TRAMO ACTUAL           | CARRIL  | SENTIDO |          POSICION ACTUAL        |" &
                              "  VELOCIDAD  |  TIEMPO (s)  | DISTANCIA (m) |");
      Ada.Text_Io.Put_Line ("     +---------------------------------+---------+---------+---------------------------------+" &
                              "-------------+--------------+---------------+");

   end P_VISUALIZAR_CABECERA_DINAMICA_TRAYECTO;
   ----------------------------------------------------

   ----------------------------------------------------------------------------------------------------------------------------
   procedure P_VISUALIZAR_PARTE_DINAMICA_TRAYECTO (V_TRAYECTO : in T_TRAYECTO;
                                                   V_LISTA_TRAMOS_ADAPTACION : in Q_ADAPTACION_TRAMO.Q_LISTA_TRAMOS.T_LISTA) is

      V_TRAMO_AUX : Q_TRAMO.T_TRAMO;

      -- Segmento auxiliar para obtener el numero de carriles
      V_SEGMENTO_AUX : Q_SEGMENTO.T_SEGMENTO;

      V_NUMERO_CARRILES : Natural range 1 .. 3 := 1;

   begin

      -- Obtener nombre tramo origen.
      Q_TRAMO.P_INICIALIZAR_TRAMO (V_TRAMO_AUX);

      Q_SEGMENTO.P_INICIALIZAR_SEGMENTO (V_SEGMENTO_AUX);

      -- En progresiones muy cortas nos podemos quedar sin progresion para visualizar "la llegada". Posicion final y velocidad a 0
      if not Q_PROGRESION.F_ESTA_PROGRESION_ACABADA (V_TRAYECTO.R_PROGRESION) then

         Q_TRAMO.P_PONER_ID
           (V_ID => 
              Q_PROGRESION.F_OBTENER_ID_TRAMO_ACTUAL 
                (Q_PROGRESION.F_OBTENER_ELEMENTO_ACTUAL_PROGRESION (V_TRAYECTO.R_PROGRESION)),
            V_TRAMO => V_TRAMO_AUX);

      else

         -- La progresion esta vacia hemos llegado al final.
         Q_TRAMO.P_PONER_ID (V_ID => V_TRAYECTO.R_ID_TRAMO_DESTINO,
                             V_TRAMO => V_TRAMO_AUX);

      end if;

      Ada.Text_Io.Put 
        ("     | " & 
           Q_TRAMO.F_OBTENER_NOMBRE 
           (Q_ADAPTACION_TRAMO.Q_LISTA_TRAMOS.F_ENCONTRAR_ELEMENTO 
                (V_ELEMENTO => V_TRAMO_AUX,
                 V_LISTA => V_LISTA_TRAMOS_ADAPTACION)) & "| ");

      Q_SEGMENTO.P_PONER_POSICION (V_POSICION => V_TRAYECTO.R_POSICION_ACTUAL,
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

         if V_TRAYECTO.R_CARRIL_ACTUAL = 1 then

            Ada.Text_Io.Put (" | :·| ");    

         else

            Ada.Text_Io.Put (" |·: | ");    

         end if;

      when 3 => 

         case V_TRAYECTO.R_CARRIL_ACTUAL is

         when 1 => 

            Ada.Text_Io.Put ("| : :·|");

         when 2 =>

            Ada.Text_Io.Put ("| :·: |");

         when 3 =>

            Ada.Text_Io.Put ("|·: : |");

         end case;

      end case;       

      Ada.Text_Io.Put (" |  ");
      
      Ada.Integer_Text_IO.Put (Item  => V_TRAYECTO.R_SENTIDO_ACTUAL,
                               Width => 3);
		
      Ada.Text_Io.Put ("    |");
      
      Ada.Text_Io.Put ("    X : ");
      Ada.Integer_Text_Io.Put (Item => Q_TIPOS_BASICOS.F_OBTENER_COORDENADA_X (V_TRAYECTO.R_POSICION_ACTUAL),
                               Width => 7);
      Ada.Text_Io.Put ("  Y : ");
      Ada.Integer_Text_Io.Put (Item => Q_TIPOS_BASICOS.F_OBTENER_COORDENADA_Y (V_TRAYECTO.R_POSICION_ACTUAL),
                               Width => 7);
      Ada.Text_Io.Put ("     |        ");
      Ada.Integer_Text_Io.Put (Item => V_TRAYECTO.R_VELOCIDAD_ACTUAL,
                               Width => 3);
      Ada.Text_Io.Put ("  |         ");
      Ada.Integer_Text_Io.Put (Item => V_TRAYECTO.R_TIEMPO_TRANSCURRIDO,
                               Width => 3);
      Ada.Text_Io.Put ("  |         ");
      Ada.Integer_Text_Io.Put (Item => Integer(Float'Rounding(V_TRAYECTO.R_DISTANCIA_RECORRIDA)),
                               Width => 4);
      Ada.Text_Io.Put_Line ("  |");
		
      Ada.Text_Io.Put_Line ("     +---------------------------------+---------+---------+---------------------------------+" &
                              "-------------+--------------+---------------+");

   end P_VISUALIZAR_PARTE_DINAMICA_TRAYECTO;
   ----------------------------------------------------------------------------------------------------------------------------

   --------------------------------------------------------
   -- Procedimiento para incrementar la velocidad de un trayecto.
   -- Por el momento vamos a considerar una aceleracion 
   -- lineal de 2.5 m/s2, es decir, 9 Km/h2
   --------------------------------------------------------
   procedure P_ACELERAR (V_VELOCIDAD_ACTUAL : in Q_TIPOS_BASICOS.T_VELOCIDAD;
                         V_VELOCIDAD_OBJETIVO : in Q_TIPOS_BASICOS.T_VELOCIDAD;
                         V_TRAYECTO : in out T_TRAYECTO;
                         V_VELOCIDAD_OBJETIVO_ALCANZADA : out Boolean) is

      V_INCREMENTO_VELOCIDAD : constant Q_TIPOS_BASICOS.T_VELOCIDAD := 9;

   begin

      -- Si sumo 9 Km/h a la velocidad actual hay que comprobar que no se supere la velocidad objetivo.
      if V_VELOCIDAD_ACTUAL + V_INCREMENTO_VELOCIDAD >= V_VELOCIDAD_OBJETIVO then

         -- No se puede superar la velocidad objetivo.
         V_TRAYECTO.R_VELOCIDAD_ACTUAL := V_VELOCIDAD_OBJETIVO;
         V_VELOCIDAD_OBJETIVO_ALCANZADA := True;

      else

         -- No hemos alcanzado a la restriccion.
         V_TRAYECTO.R_VELOCIDAD_ACTUAL := V_VELOCIDAD_ACTUAL + V_INCREMENTO_VELOCIDAD;
         V_VELOCIDAD_OBJETIVO_ALCANZADA := False;

      end if;

   end P_ACELERAR;
   ---------------

   -------------------------------------------------------------------
   procedure P_ACTUALIZAR_TRAYECTO (V_TRAYECTO : in out T_TRAYECTO) is

      V_VELOCIDAD_INICIAL : Q_TIPOS_BASICOS.T_VELOCIDAD := V_TRAYECTO.R_VELOCIDAD_ACTUAL;

      V_VELOCIDAD_OBJETIVO : Q_TIPOS_BASICOS.T_VELOCIDAD := 
        Q_RESTRICCION.F_OBTENER_RESTRICCION_VELOCIDAD 
          (Q_PROGRESION.F_OBTENER_RESTRICCION 
             (Q_PROGRESION.F_OBTENER_ELEMENTO_ACTUAL_PROGRESION (V_TRAYECTO.R_PROGRESION)));

      V_VELOCIDAD_OBJETIVO_ALCANZADA : Boolean := False;

      V_DISTANCIA_RECORRIDA : Float := 0.0;

      -- Instante t en el que se alcanza la velocidad objetivo.
      V_T_VELOCIDAD_OBJETIVO : Float := 0.0;

      V_NUMERO_SEGMENTOS_A_AVANZAR : Natural := 0;

      --
      -- Las variable tramo anterior y tramo siguiente id's se van a utilizar para obtener el carril del tramo siguiente cuando 
      -- haya un cambio de tramo en el trayecto.
      V_CARRIL_OPTIMO, V_TRAMO_ID_ANTERIOR, V_TRAMO_SIGUIENTE_ID : Natural := 0;

      -- Variable para indicar si hay que corregir el tramo o no, al finalizar la actualizacion del trayecto justo al cambiar de
      -- tramo.
      V_CORREGIR_CARRIL : Boolean := False;

   begin

      -- Si el estado es pasivo pasar a activo. Se pondra en estado terminado cuando lleguemos al final y la velocidad sea 0.
      if V_TRAYECTO.R_ESTADO = E_PASIVO then

         V_TRAYECTO.R_ESTADO := E_ACTIVO;

      end if;

      -- Ojo con esto. Si la posicion actual y la final son la misma Y SI LA PROGRESION SOLO TIENE EL ELEMENTO PUNTO FINAL.
      -- Esto es asi porque se puede dar el caso de calles con dos carriles (ida y vuelta) que tengan la misma posicion para un
      -- segmento.
      if Q_TIPOS_BASICOS."=" (V_POSICION_1 => V_TRAYECTO.R_POSICION_ACTUAL,
                              V_POSICION_2 => V_TRAYECTO.R_POSICION_FINAL) and 
        Q_PROGRESION.F_CUANTOS_ELEMENTOS_PROGRESION (V_TRAYECTO.R_PROGRESION) = 1 then

         V_TRAYECTO.R_ESTADO := E_TERMINADO;

      end if;

      -- Comprobar si hay que actualizar la velocidad actual.
      -- Si la velocidad incial es menor que la velocidad objetivo de la progresion Y
      -- La distancia de seguridad es menor que la distancia a recorrer => acelerar
      if V_VELOCIDAD_INICIAL < V_VELOCIDAD_OBJETIVO then
		  
         -- Hay que acelerar.
         P_ACELERAR (V_VELOCIDAD_ACTUAL => V_VELOCIDAD_INICIAL,
                     V_VELOCIDAD_OBJETIVO => V_VELOCIDAD_OBJETIVO,
                     V_TRAYECTO => V_TRAYECTO,
                     V_VELOCIDAD_OBJETIVO_ALCANZADA => V_VELOCIDAD_OBJETIVO_ALCANZADA);

         -- En caso de que la distancia de seguridad de la nueva velocidad sea mayor que la distancia por recorrer,
         -- entonces no hay que acelerar sino frenar.
         if Integer(Float(V_TRAYECTO.R_VELOCIDAD_ACTUAL)/10.0)**2 > Integer(V_TRAYECTO.R_DISTANCIA_POR_RECORRER) then

            -- De momento frenamos en 9 Km/h la velocidad que traiamos, que no sera muy alta.
            begin 
               
               V_TRAYECTO.R_VELOCIDAD_ACTUAL := V_VELOCIDAD_INICIAL - 9;
               
            exception
                
               when Constraint_Error =>
                  
                  V_TRAYECTO.R_VELOCIDAD_ACTUAL := 0;
                  
            end;
            -- Para el calculo de la distancia recorrida.
            V_VELOCIDAD_OBJETIVO := V_VELOCIDAD_INICIAL;

         end if;

      else
         -- La nueva velocidad sera la del elemento de la progresion. Si ya hemos alcanzado el "envelope" solo hay que 
         -- seguirlo. Y si hay que frenar se cambia la velocidad a la velocidad objetivo. No se va a frenar muy bruscamente
         -- porque de esa "suavidad" ya se ha encargado la progresion.
         V_TRAYECTO.R_VELOCIDAD_ACTUAL := V_VELOCIDAD_OBJETIVO;
         V_VELOCIDAD_OBJETIVO_ALCANZADA := True;

      end if;

      -- Cambiar la posicion. Hay que estudiar las diferentes opciones para saber cuanta distancia se recorre.
      -- Opciones:
      --      1º.-    El vehiculo acelera (con un incremento de 9 Km/h) y no se alcanza la velocidad objetivo.
      --              Trapecio. La distancia recorrida (en metros) se obtiene con la integral definida de 2.5*t
      --              Entre t2 y t1 1.25*t^2.
      --      2º.-    El vehiculo acelera (con un incremento de 9 Km/h) y se alcanza la velocidad objetivo.
      --              Triangulo + Rectangulo.
      --	3º.-	El vehiculo no acelera => Velocidad inicial = velocidad objetivo. Rectangulo.
      --	4º.-	El vehiculo frena => Velocidad inicial > Velocidad objetivo. Triangulo
      if not V_VELOCIDAD_OBJETIVO_ALCANZADA then

         V_DISTANCIA_RECORRIDA :=
           Float(V_VELOCIDAD_INICIAL)/3.6 + Float(V_TRAYECTO.R_VELOCIDAD_ACTUAL - V_VELOCIDAD_INICIAL)/7.2;

      elsif V_VELOCIDAD_OBJETIVO_ALCANZADA and V_VELOCIDAD_INICIAL /= V_TRAYECTO.R_VELOCIDAD_ACTUAL then


         if V_VELOCIDAD_INICIAL < V_VELOCIDAD_OBJETIVO then

            -- Calcular el "t" en el que se alcanza la velocidad objetivo.
            V_T_VELOCIDAD_OBJETIVO := (Float(V_VELOCIDAD_OBJETIVO)/3.6 - Float(V_VELOCIDAD_INICIAL)/3.6) / 2.5;

            V_DISTANCIA_RECORRIDA := 
              V_T_VELOCIDAD_OBJETIVO * Float(V_VELOCIDAD_INICIAL)/3.6 + 
              Float(V_VELOCIDAD_OBJETIVO - V_VELOCIDAD_INICIAL) * V_T_VELOCIDAD_OBJETIVO/7.2 +
              Float(V_VELOCIDAD_OBJETIVO) * (1.0 - V_T_VELOCIDAD_OBJETIVO)/3.6;

         else

            V_DISTANCIA_RECORRIDA := 
              Float(V_VELOCIDAD_OBJETIVO)/3.6 + Float(V_VELOCIDAD_INICIAL - V_VELOCIDAD_OBJETIVO)/7.2;

         end if;

      elsif V_VELOCIDAD_INICIAL = V_VELOCIDAD_OBJETIVO then

         V_DISTANCIA_RECORRIDA := Float(V_VELOCIDAD_OBJETIVO)/3.6;

      elsif V_VELOCIDAD_INICIAL > V_VELOCIDAD_OBJETIVO then

         V_DISTANCIA_RECORRIDA := 
           Float(V_VELOCIDAD_OBJETIVO)/3.6 + Float(V_VELOCIDAD_INICIAL - V_VELOCIDAD_OBJETIVO)/7.2;

      end if;

      V_TRAYECTO.R_DISTANCIA_RECORRIDA := V_TRAYECTO.R_DISTANCIA_RECORRIDA + V_DISTANCIA_RECORRIDA;

      -- Con la distancia recorrida. Comprobar cuantos segmentos hay que avanzar el vehiculo.
      V_NUMERO_SEGMENTOS_A_AVANZAR := Natural(Float'Rounding(Float(V_DISTANCIA_RECORRIDA + V_TRAYECTO.R_ACARREO)/ 5.0));

      V_TRAYECTO.R_SEGMENTOS_AVANZADOS := V_TRAYECTO.R_SEGMENTOS_AVANZADOS + V_NUMERO_SEGMENTOS_A_AVANZAR;

      -- Actualizar acarreo.
      V_TRAYECTO.R_ACARREO := V_DISTANCIA_RECORRIDA + V_TRAYECTO.R_ACARREO - Float(V_NUMERO_SEGMENTOS_A_AVANZAR) * 5.0;

      -- Eliminar el numero de segmentos a avanzar el vehiculo de la progresion del trayecto y actualizar la posicion actual con 
      -- la del siguiente segmento.
      for I in 1 .. V_NUMERO_SEGMENTOS_A_AVANZAR loop

         -- Obtener el tramo id antes de avanzar por si hay cambio de tramo.
         V_TRAMO_ID_ANTERIOR := 
           Q_PROGRESION.F_OBTENER_ID_TRAMO_ACTUAL 
             (Q_PROGRESION.F_OBTENER_ELEMENTO_ACTUAL_PROGRESION (V_TRAYECTO.R_PROGRESION));

         -- Ya hemos avanzado al segmento siguiente. Eliminar dicho segmento de la progresion.
         Q_PROGRESION.P_ELIMINAR_ELEMENTO_ACTUAL_PROGRESION (V_TRAYECTO.R_PROGRESION);

         -- Comprobar si la lista esta vacia. En cuyo caso ya habremos llegado al final.
         if Q_PROGRESION.F_ESTA_PROGRESION_ACABADA (V_TRAYECTO.R_PROGRESION) then

            -- Cambiar estado a terminado, posicion actual a posicion final y velocidad actual a 0.
            V_TRAYECTO.R_ESTADO := E_TERMINADO;
            V_TRAYECTO.R_POSICION_ACTUAL := V_TRAYECTO.R_POSICION_FINAL;
            V_TRAYECTO.R_VELOCIDAD_ACTUAL := 0;
            exit;

         end if;
	
         V_TRAYECTO.R_POSICION_ACTUAL := 
           Q_PROGRESION.F_OBTENER_POSICION 
             (Q_PROGRESION.F_OBTENER_ELEMENTO_ACTUAL_PROGRESION (V_TRAYECTO.R_PROGRESION));
         
         -- Obtener la lista de cruces de la posicion actual.
         V_TRAYECTO.R_LISTA_CRUCES := 
           Q_PROGRESION.F_OBTENER_LISTA_CRUCES (Q_PROGRESION.F_OBTENER_ELEMENTO_ACTUAL_PROGRESION (V_TRAYECTO.R_PROGRESION));

         -- Comprobar si el el tramo de la nueva posicion es igual o no al tramo "anterior".
         -- Si no lo es:
         --	.- Obtener el carril del tramo al que hemos pasado.
         --	.- Actualizar la variable tramo anterior.
         --	.- No corregimos carril en este momento porque nos encontramos en el primer segmento del nuevo tramo
         --		y se asume que no se puede cambiar de carril en el primer segmento por definición.
         --		PERO: Dado que los tramos de las rotondas son muy cortos (incluso de un solo segmento), se puede
         --		      dar el caso de que no se puedan hacer los cambios de carril que se necesiten dentro de la
         --		      rotonda => 
         --			Solucion: Establecer una excepcion para la regla del tramo nuevo (regla pensada
         --		      	para tramos "rectos"). Se crea una lista con los tramos de la ruta que pertenezcan a las
         --			rotondas en las que se pueda cambiar de carril. Si el tramo actual es uno de los de esta
         --			lista no se aplica la regla del tramo nuevo.
         -- Si lo es:
         --	.- Al seguir en el mismo tramo.
         --	.- Comprobar el carril actual contra el optimo.
         --	.- Si no es igual, corregir
			
         V_TRAMO_SIGUIENTE_ID := 
           Q_PROGRESION.F_OBTENER_ID_TRAMO_ACTUAL 
             (Q_PROGRESION.F_OBTENER_ELEMENTO_ACTUAL_PROGRESION (V_TRAYECTO.R_PROGRESION));
			
         if V_TRAMO_ID_ANTERIOR /= V_TRAMO_SIGUIENTE_ID then
            
            V_TRAYECTO.R_TRAMO_ACTUAL_ID := V_TRAMO_SIGUIENTE_ID;
            
            -- Actualizar el sentido de circulacion.
            V_TRAYECTO.R_SENTIDO_ACTUAL := 
              Q_PROGRESION.F_OBTENER_SENTIDO_CIRCULACION (V_TRAMO_ID                       => V_TRAMO_SIGUIENTE_ID,
                                                          V_PROGRESION_SENTIDO_CIRCULACION => V_TRAYECTO.R_PROGRESION_SENTIDO_CIRCULACION);

            -- Obtener el carril nuevo.
            -- Comprobar si existe la conexion entre el carril actual y el carril optimo siguiente.
            if Q_ADAPTACION_TRAMO.F_EXISTE_CONEXION 
              (V_TRAMO_ORIGEN_ID => V_TRAMO_ID_ANTERIOR,
               V_TRAMO_SIGUIENTE_ID => V_TRAMO_SIGUIENTE_ID,
               V_CARRIL_ORIGEN => V_TRAYECTO.R_CARRIL_ACTUAL,
               V_CARRIL_SIGUIENTE => 
                 Q_PROGRESION.F_OBTENER_CARRIL_OPTIMO 
                   (V_TRAMO_ID => V_TRAMO_SIGUIENTE_ID,
                    V_PROGRESION_CARRILES_OPTIMO => V_TRAYECTO.R_PROGRESION_CARRILES_OPTIMO)) then

               -- Existe conexion desde el carril actual al carril optimo del siguiente tramo.
               V_TRAYECTO.R_CARRIL_ACTUAL := 
                 Q_PROGRESION.F_OBTENER_CARRIL_OPTIMO 
                   (V_TRAMO_ID => V_TRAMO_SIGUIENTE_ID,
                    V_PROGRESION_CARRILES_OPTIMO => V_TRAYECTO.R_PROGRESION_CARRILES_OPTIMO);

            else

               -- No existe conexion desde el carril actual al carril optimo del siguiente tramo.
               -- Habra que buscar una conexion alternativa.
               V_TRAYECTO.R_CARRIL_ACTUAL := 
                 Q_ADAPTACION_TRAMO.F_OBTENER_SIGUIENTE_CARRIL_ALTERNATIVO 
                   (V_TRAMO_ORIGEN_ID => V_TRAMO_ID_ANTERIOR,
                    V_TRAMO_SIGUIENTE_ID => V_TRAMO_SIGUIENTE_ID,
                    V_CARRIL_ACTUAL => V_TRAYECTO.R_CARRIL_ACTUAL,
                    V_CARRIL_SIGUIENTE_OPTIMO => 
                      Q_PROGRESION.F_OBTENER_CARRIL_OPTIMO 
                        (V_TRAMO_ID => V_TRAMO_SIGUIENTE_ID,
                         V_PROGRESION_CARRILES_OPTIMO => 
                           V_TRAYECTO.R_PROGRESION_CARRILES_OPTIMO));

            end if;

            V_TRAMO_ID_ANTERIOR := V_TRAMO_SIGUIENTE_ID;

            -- Estamos justo al comienzo del nuevo tramo. Corregir el carril solo si estamos dentro de una rotonda.
            if Q_PROGRESION.F_ES_TRAMO_DE_GLORIETA (V_TRAMO_ID => V_TRAMO_ID_ANTERIOR,
                                                    V_LISTA_TRAMOS_GLORIETA => V_TRAYECTO.R_TRAMOS_EN_GLORIETA) then

               V_CORREGIR_CARRIL := True;

            else
				
               V_CORREGIR_CARRIL := False;

            end if;

         else

            -- No estamos justo al comienzo del nuevo tramo. Corregir carril.
            V_CORREGIR_CARRIL := True;

         end if;
			
      end loop;

      V_CARRIL_OPTIMO := 
        Q_PROGRESION.F_OBTENER_CARRIL_OPTIMO 
          (V_TRAMO_ID => 
             Q_PROGRESION.F_OBTENER_ID_TRAMO_ACTUAL 
               (Q_PROGRESION.F_OBTENER_ELEMENTO_ACTUAL_PROGRESION (V_TRAYECTO.R_PROGRESION)),
           V_PROGRESION_CARRILES_OPTIMO => V_TRAYECTO.R_PROGRESION_CARRILES_OPTIMO);

      -- Comprobar carril. Si el carril actual es distino del optimo, habra que "intentar" cambiar de carril.
      if V_TRAYECTO.R_CARRIL_ACTUAL /= V_CARRIL_OPTIMO and V_CORREGIR_CARRIL then

         -- Cambiar de carril. El cambio no puede ser instantaneo. Por ejemplo, no se puede pasar del carril "5" al carril 1
         --  de manera "instantanea".
         -- Vamos a cambiar de carril una vez por segundo. Un carril en cada actualizacion.
         if V_TRAYECTO.R_CARRIL_ACTUAL - V_CARRIL_OPTIMO < 0 then

            -- Hay que incorporarse al carril izquierdo => Sumar una unidad al carril actual.
            V_TRAYECTO.R_CARRIL_ACTUAL := V_TRAYECTO.R_CARRIL_ACTUAL + 1;
                                
         else

            -- Hay que incorporase al carril derecho => Restar una unidad al carril actual.
            V_TRAYECTO.R_CARRIL_ACTUAL := V_TRAYECTO.R_CARRIL_ACTUAL - 1;

         end if;

      end if;

      -- Actualizar tiempo transcurrido
      V_TRAYECTO.R_TIEMPO_TRANSCURRIDO := V_TRAYECTO.R_TIEMPO_TRANSCURRIDO + 1;

      --Actualizar distancia por recorrer
      V_TRAYECTO.R_DISTANCIA_POR_RECORRER := V_TRAYECTO.R_DISTANCIA_POR_RECORRER - V_DISTANCIA_RECORRIDA;

   end P_ACTUALIZAR_TRAYECTO;
   -------------------------------------------------------------------	

end Q_TRAYECTO.Q_ACCIONES;
-------------------------------------------------------------------------------------------------------------------------------------------
