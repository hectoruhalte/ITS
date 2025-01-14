--------------------------------------------------------------------------------------------------------------------------------------------
--
--      Fichero:        THESEUS_DINAMICO.adb
--
--      Autor:          Hector Uhalte Bilbao
--
--      Fecha:          1/7/2019
--
--------------------------------------------------------------------------------------------------------------------------------------------

with Q_VEHICULO.Q_ACCIONES;
with Q_TRAMO.Q_ACCIONES;
with Q_ADAPTACION_TRAMO;
with Q_TIPOS_BASICOS;
with Ada.Text_Io;
with Ada.Characters.Latin_1;
with Q_AREA_TRABAJO;
with Q_RUTA.Q_DIJKSTRA;
with Ada.Calendar;
with Ada.Integer_Text_IO;
with Ada.Sequential_IO;

-- Ejecutable para realizar la funci�n del cliente (veh�culo).
--
-- 1�- Establecer el veh�culo (de entre los veh�culos incluidos en la adaptaci�n).
--
-- 2�- Establecer el punto de origen del trayecto.
--
-- 3�- Establecer el punto final del trayecto.
--
-- 4�- Calcular la ruta y en caso de que exista, mostrarla.

with Q_PROGRESION;
with Q_TRAYECTO.Q_ACCIONES;

-- Parte Dinamica
--
-- Una vez que existe la ruta, crear el trayecto.

procedure theseus_dinamico is

   V_VEHICULO : Q_VEHICULO.T_VEHICULO;

   V_TRAMO_ORIGEN, V_TRAMO_DESTINO : Q_TRAMO.T_TRAMO;

   V_LISTA_TRAMOS : Q_ADAPTACION_TRAMO.Q_LISTA_TRAMOS.T_LISTA;

   V_POSICION_INICIAL, V_POSICION_DESTINO, V_POSICION_ALEATORIA, V_POSICION_SEGMENTO_MAS_CERCANO : Q_TIPOS_BASICOS.T_POSICION_UTM;

   V_DISTANCIA_MINIMA : Integer := 1_000_000;

   V_RUTA : Q_RUTA.T_RUTA;

   V_COSTE_TIEMPO, V_COSTE_DISTANCIA : Integer := 0;

   V_COMIENZO, V_FINAL : Integer := 0;

   V_TRAYECTO : Q_TRAYECTO.T_TRAYECTO;

   -- Trabajo con escenario
   package Q_POSICION_IO is new Ada.Sequential_IO (Q_TIPOS_BASICOS.T_POSICION_UTM);

   V_FICHERO_SALIDAS, V_FICHERO_DESTINOS : Q_POSICION_IO.File_Type;

   V_TRAYECTO_ID : Integer := 0;

begin

   -- Obtener el registro de tramos (numero de tramos + array de tramos) de la adaptacion.
   Q_ADAPTACION_TRAMO.P_GENERAR_LISTA_TRAMOS (V_LISTA_TRAMOS);

   Q_POSICION_IO.Open (File => V_FICHERO_SALIDAS,
                       Mode => Q_POSICION_IO.In_File,
                       Name => "../../herramientas/escenarios/Salidas_2021_6_1");

   Q_POSICION_IO.Open (File => V_FICHERO_DESTINOS,
                       Mode => Q_POSICION_IO.In_File,
                       Name => "../../herramientas/escenarios/Destinos_2021_6_1");

   -- Recorrer el escenario
   while not Q_POSICION_IO.End_Of_File (V_FICHERO_SALIDAS) loop

      V_TRAYECTO_ID := V_TRAYECTO_ID + 1;
      Ada.Text_Io.Put_Line (" N� TRAYECTO : " & Integer'Image(V_TRAYECTO_ID));

      -- Generar un veh�culo.
      Q_VEHICULO.Q_ACCIONES.P_GENERAR_VEHICULO (V_VEHICULO);

      Ada.Text_Io.Put_Line ("");
      Ada.Text_Io.Put (" VEHICULO : ");
      Q_VEHICULO.Q_ACCIONES.P_MOSTRAR_VEHICULO (V_VEHICULO);
      Ada.Text_Io.Put_Line ("");

      Q_POSICION_IO.Read (File => V_FICHERO_SALIDAS,
                          Item => V_POSICION_ALEATORIA);
      -- Obtener una posiciona aleatoria dentro del area de trabajo.
      --V_POSICION_ALEATORIA := Q_AREA_TRABAJO.F_OBTENER_COORDENADAS_ALEATORIAS;
      --V_POSICION_ALEATORIA := Q_TIPOS_BASICOS.F_OBTENER_POSICION_UTM (V_X => 433138,
      --                                                                V_Y => 4811858);

      -- Obtener el segmento mas cercano a esa posicion de salida dada.
      Q_TRAMO.Q_ACCIONES.P_OBTENER_TRAMO_MAS_CERCANO_A_POSICION (V_LISTA_TRAMOS         => V_LISTA_TRAMOS,
                                                                 V_POSICION             => V_POSICION_ALEATORIA,
                                                                 V_POSICION_SEGMENTO    => V_POSICION_INICIAL,
                                                                 V_DISTANCIA_A_SEGMENTO => V_DISTANCIA_MINIMA,
                                                              V_TRAMO                => V_TRAMO_ORIGEN);

      -- Mostrar la posicion del segmento mas cercano.
      Ada.Text_Io.Put_Line (" SALIDA : ");
      Ada.Text_Io.Put_Line ("");
      Ada.Text_Io.Put_Line (Ada.Characters.Latin_1.HT & Q_TRAMO.F_OBTENER_NOMBRE (V_TRAMO_ORIGEN));
      Ada.Text_Io.Put_Line ("");
      Ada.Text_Io.Put_Line (Ada.Characters.Latin_1.HT & "X : " &
                              Integer'Image(Q_TIPOS_BASICOS.F_OBTENER_COORDENADA_X (V_POSICION_INICIAL)));
      Ada.Text_Io.Put_Line (Ada.Characters.Latin_1.HT & "Y : " &
                              Integer'Image(Q_TIPOS_BASICOS.F_OBTENER_COORDENADA_Y (V_POSICION_INICIAL)));
      Ada.Text_Io.Put_Line ("");

      Q_POSICION_IO.Read (File => V_FICHERO_DESTINOS,
                          Item => V_POSICION_ALEATORIA);
      -- Obtener una posiciona aleatoria dentro del area de trabajo.
      --V_POSICION_ALEATORIA := Q_AREA_TRABAJO.F_OBTENER_COORDENADAS_ALEATORIAS;
      --V_POSICION_ALEATORIA := Q_TIPOS_BASICOS.F_OBTENER_POSICION_UTM (V_X => 434714,
      --                                                                V_Y => 4812260);

      -- Obtener el segmento mas cercano a esa posicion de destino dada.
      Q_TRAMO.Q_ACCIONES.P_OBTENER_TRAMO_MAS_CERCANO_A_POSICION (V_LISTA_TRAMOS         => V_LISTA_TRAMOS,
                                                                 V_POSICION             => V_POSICION_ALEATORIA,
                                                                 V_POSICION_SEGMENTO    => V_POSICION_DESTINO,
                                                                 V_DISTANCIA_A_SEGMENTO => V_DISTANCIA_MINIMA,
                                                                 V_TRAMO                => V_TRAMO_DESTINO);

      -- Mostrar la posicion del segmento mas cercano.
      Ada.Text_Io.Put_Line (" DESTINO : ");
      Ada.Text_Io.Put_Line ("");
      Ada.Text_Io.Put_Line (Ada.Characters.Latin_1.HT & Q_TRAMO.F_OBTENER_NOMBRE (V_TRAMO_DESTINO));
      Ada.Text_Io.Put_Line ("");
      Ada.Text_Io.Put_Line (Ada.Characters.Latin_1.HT & "X : " &
                              Integer'Image(Q_TIPOS_BASICOS.F_OBTENER_COORDENADA_X (V_POSICION_DESTINO)));
      Ada.Text_Io.Put_Line (Ada.Characters.Latin_1.HT & "Y : " &
                              Integer'Image(Q_TIPOS_BASICOS.F_OBTENER_COORDENADA_Y (V_POSICION_DESTINO)));
      Ada.Text_Io.Put_Line ("");

      Ada.Text_Io.Put_Line
        (" DISTANCIA SALIDA-DESTINO (linea recta) : " &
           Integer'Image(Q_TIPOS_BASICOS.F_OBTENER_DISTANCIA (V_POSICION_1 => V_POSICION_INICIAL,
                                                              V_POSICION_2 => V_POSICION_DESTINO)) & " metros");

      Ada.Text_Io.Put_Line ("");

      if not Q_TIPOS_BASICOS."=" (V_POSICION_1 => V_POSICION_INICIAL,
                                  V_POSICION_2 => V_POSICION_DESTINO) then

         begin

            -- Calculo de la ruta. Inicializar listas auxiliares.
            V_COMIENZO := (Integer(ADA.CALENDAR.Seconds(ADA.CALENDAR.CLOCK)));

            -- Cargar mapas
            Q_RUTA.Q_DIJKSTRA.P_GENERAR_ADAPTACION;

            Q_RUTA.Q_DIJKSTRA.P_OBTENER_RUTA (V_POSICION_ORIGEN => V_POSICION_INICIAL,
                                              V_POSICION_FINAL => V_POSICION_DESTINO,
                                              V_RUTA => V_RUTA,
                                              V_COSTE_TIEMPO => V_COSTE_TIEMPO,
                                              V_COSTE_DISTANCIA => V_COSTE_DISTANCIA);

            V_FINAL := (Integer(ADA.CALENDAR.Seconds(ADA.CALENDAR.CLOCK)));

            Ada.Text_Io.Put_Line
              (Ada.Characters.Latin_1.HT & "Se ha tardado : " & Integer'Image(V_FINAL - V_COMIENZO) &
                 " segundos en encontrar la ruta");

            Ada.Text_Io.Put_Line ("");

            -- Visualizar la ruta:
            Ada.Text_Io.Put_Line (" RUTA : ");

            Ada.Text_Io.Put_Line ("");

            Q_TRAMO.Q_ACCIONES.P_VISUALIZAR_CABECERA_TRAMO;

            for I in 1 .. Q_RUTA.Q_LISTA_TRAMOS.F_CUANTOS_ELEMENTOS (V_RUTA) loop

               Q_TRAMO.Q_ACCIONES.P_VISUALIZAR_TRAMO
                 (V_LISTA_TRAMOS => V_LISTA_TRAMOS,
                  V_ID => Q_TRAMO.F_OBTENER_ID (Q_RUTA.Q_LISTA_TRAMOS.F_DEVOLVER_ELEMENTO (V_POSICION => I,
                                                                                           V_LISTA => V_RUTA)));
            end loop;

            -- Visualizar coste de la ruta en tiempo y distancia.

            Ada.Text_Io.Put_Line ("");

            Ada.Text_Io.Put_Line (Ada.Characters.Latin_1.HT & "TIEMPO (s) : " & Integer'Image(V_COSTE_TIEMPO));

            Ada.Text_Io.Put_Line ("");

            Ada.Text_Io.Put_Line (Ada.Characters.Latin_1.HT & "DISTANCIA RUTA (m) : " & Integer'Image(V_COSTE_DISTANCIA));

            Ada.Text_Io.Put_Line ("");

            -- Crear el trayecto.
            Q_TRAYECTO.P_CREAR_TRAYECTO (V_VEHICULO => V_VEHICULO,
                                         V_POSICION_ORIGEN => V_POSICION_INICIAL,
                                         V_POSICION_FINAL => V_POSICION_DESTINO,
                                         V_DURACION => V_COSTE_TIEMPO,
                                         V_DISTANCIA => V_COSTE_DISTANCIA,
                                         V_RUTA => V_RUTA,
                                         V_TRAYECTO => V_TRAYECTO);

            Q_TRAYECTO.Q_ACCIONES.P_VISUALIZAR_CABECERA_ESTATICA_TRAYECTO;
            Q_TRAYECTO.Q_ACCIONES.P_VISUALIZAR_PARTE_ESTATICA_TRAYECTO (V_TRAYECTO                => V_TRAYECTO,
                                                                        V_LISTA_TRAMOS_ADAPTACION => V_LISTA_TRAMOS);
            Q_TRAYECTO.Q_ACCIONES.P_VISUALIZAR_CABECERA_DINAMICA_TRAYECTO;
            Q_TRAYECTO.Q_ACCIONES.P_VISUALIZAR_PARTE_DINAMICA_TRAYECTO (V_TRAYECTO                => V_TRAYECTO,
                                                                        V_LISTA_TRAMOS_ADAPTACION => V_LISTA_TRAMOS);

            -- Actualizar trayecto. => Mover vehiculo.
            loop

               Q_TRAYECTO.Q_ACCIONES.P_ACTUALIZAR_TRAYECTO (V_TRAYECTO);

               Q_TRAYECTO.Q_ACCIONES.P_VISUALIZAR_CABECERA_DINAMICA_TRAYECTO;

               Q_TRAYECTO.Q_ACCIONES.P_VISUALIZAR_PARTE_DINAMICA_TRAYECTO (V_TRAYECTO                => V_TRAYECTO,
                                                                           V_LISTA_TRAMOS_ADAPTACION => V_LISTA_TRAMOS);

               exit when Q_TRAYECTO.F_ESTA_TRAYECTO_TERMINADO (V_TRAYECTO);

               delay 1.0;

            end loop;

            Ada.Text_Io.Put_Line ("");

            Ada.Text_IO.Put_Line
              (Ada.Characters.Latin_1.HT & "TIEMPO TOTAL (s) : " & Integer'Image(Q_TRAYECTO.F_OBTENER_TIEMPO_TRANSCURRIDO(V_TRAYECTO)));

            Ada.Text_IO.Put_Line ("");

            Ada.Text_IO.Put (Ada.Characters.Latin_1.HT & "DISTANCIA TOTAL (m) : ");

            Ada.Integer_Text_Io.Put (Item => Integer(Float'Rounding(Q_TRAYECTO.F_OBTENER_DISTANCIA_RECORRIDA (V_TRAYECTO))),
                                     Width => 4);

            Ada.Text_IO.Put_Line ("");
            Ada.Text_IO.Put_Line ("");

         exception

            when Q_RUTA.X_RUTA_NO_ENCONTRADA =>

               Ada.Text_Io.Put_Line (" NO ES POSIBLE ENCONTRAR UNA RUTA");

               Ada.Text_Io.Put_Line ("");

         end;

      end if;

   end loop;

end theseus_dinamico;
--------------------------------------------------------------------------------------------------------------------------------------------
