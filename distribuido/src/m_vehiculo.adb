--------------------------------------------------------------------------------------------------------------------------------------------
--
--      Fichero:        m_vehiculo.adb
--
--      Autor:          Hector Uhalte Bilbao
--
--      Fecha:          26/8/2020
--
--------------------------------------------------------------------------------------------------------------------------------------------

-- Ejecutable para realizar la función de cliente de la aplicacion districbuida.

-- 1.- Generar el vehiculo (matricula, etc...)
-- 2.- Conectar (registrar) el vehiculo al centro de control (Servidor)
-- 3.- Obtener los puntos de origen y destino para generar una solicitud de ruta.
-- 4.- Solicitar la ruta al servidor.
-- 5.- En caso de obtener una ruta enviar el trayecto al servidor, poner en marcha el vehiculo.

with Q_VEHICULO.Q_ACCIONES;
with Q_SERVIDOR;
with Q_TERMINAL_VEHICULO;
with Ada.Text_IO;
with Ada.Strings.Fixed;
with Q_ADAPTACION_TRAMO;
with Q_TRAMO.Q_ACCIONES;
with Q_AREA_TRABAJO;
with Q_TIPOS_BASICOS;
with Ada.Characters.Latin_1;
with Q_SOLICITUD_RUTA;
with Q_RUTA_STREAM;
with Q_RUTA;
with Q_TRAYECTO.Q_ACCIONES;
with Q_DATOS_TRAYECTO_STREAM;
with GNAT.OS_Lib;
--
with Q_CONEXION;

procedure m_vehiculo is

   C_LONGITUD_MAXIMA_NOMBRE_MARCA : Natural := 10;
   C_LONGITUD_MAXIMA_NOMBRE_MODELO : Natural := 7;

   V_ID_PROCESO : Integer;

   V_VEHICULO : Q_VEHICULO.T_VEHICULO;
   V_MATRICULA : String (1..Q_VEHICULO.F_OBTENER_LONGITUD_MATRICULA);

   V_ESTA_VEHICULO_REGISTRADO : Boolean := False;

   V_POSICION_INICIAL, V_POSICION_DESTINO : Q_TIPOS_BASICOS.T_POSICION_UTM;

   -- Distancia inicial para iniciar la busqueda del punto de un segmento mas cercano a una posicion aleatoria dada.
   V_DISTANCIA_MINIMA : Integer := 1000;

   V_TRAMO_ORIGEN, V_TRAMO_DESTINO : Q_TRAMO.T_TRAMO;

   V_SOLICITUD_RUTA : Q_SOLICITUD_RUTA.T_SOLICITUD_RUTA;

   -- Longitud de la ruta recibida del servidor.
   V_LONGITUD_RUTA : Natural := 0;

   -- Ruta stream recibida del servidor.
   V_RUTA_STREAM : Q_RUTA_STREAM.T_RUTA_STREAM;

   V_LISTA_TRAMOS_ADAPTACION : Q_ADAPTACION_TRAMO.Q_LISTA_TRAMOS.T_LISTA;

   V_RUTA : Q_RUTA.T_RUTA;

   -- Costes de las rutas.
   V_COSTE_TIEMPO, V_COSTE_DISTANCIA : Integer := 0;

   -- Variables para el trayecto
   V_TRAYECTO_ID : Natural := 0;

   V_TRAYECTO : Q_TRAYECTO.T_TRAYECTO;

   V_DATOS_TRAYECTO_STREAM : Q_DATOS_TRAYECTO_STREAM.T_DATOS_TRAYECTO_STREAM;

   V_NUMERO_CRUCES : Natural := 0;

   V_ARRAY_CRUCES_STREAM : Q_DATOS_TRAYECTO_STREAM.T_ARRAY_CRUCES_STREAM;

   --Variable para controlar el numero de intentos de calcular una ruta desde un punto de partida dado.
   V_NUMERO_INTENTOS_RUTA : Natural := 0;

   -- Variable para controlar si es necesario calcular el punto de partida para un primer trayecto.
   V_PRIMERA_VEZ : Boolean := True;

begin

   -- Obtener el registro de tramos (numero de tramos + array de tramos) de la adaptacion.
   Q_ADAPTACION_TRAMO.P_GENERAR_LISTA_TRAMOS (V_LISTA_TRAMOS_ADAPTACION);

   -- Obtener el PID de este cliente.
   V_ID_PROCESO := GNAT.OS_Lib.Pid_To_Integer(GNAT.OS_Lib.Current_Process_Id);

   -- Generar vehiculo.
   Q_VEHICULO.Q_ACCIONES.P_GENERAR_VEHICULO (V_VEHICULO);
   V_MATRICULA (1..Q_VEHICULO.F_OBTENER_LONGITUD_MATRICULA) :=
     Q_VEHICULO.F_OBTENER_MATRICULA (V_VEHICULO) (1..Q_VEHICULO.F_OBTENER_LONGITUD_MATRICULA);

   Ada.Text_Io.Put_Line ("========================================");
   Ada.Text_Io.Put_Line
     (" .- Registrando el vehiculo : " & Q_VEHICULO.F_OBTENER_MATRICULA(V_VEHICULO)(1..Q_VEHICULO.F_OBTENER_LONGITUD_MATRICULA) & " " &
        Ada.Strings.Fixed.Trim (Source => Q_VEHICULO.F_OBTENER_NOMBRE_MARCA(V_VEHICULO)(1..C_LONGITUD_MAXIMA_NOMBRE_MARCA),
                                Side   => Ada.Strings.Right) & " " &
        Ada.Strings.Fixed.Trim (Source => Q_VEHICULO.F_OBTENER_NOMBRE_MODELO(V_VEHICULO)(1..C_LONGITUD_MAXIMA_NOMBRE_MODELO),
                                Side   => Ada.Strings.Right) & " en Ariadna");
   Ada.Text_IO.Put_Line (" --");

   -- Registrar el vehiculo en el centro de control.
   while not V_ESTA_VEHICULO_REGISTRADO loop

      Q_SERVIDOR.P_REGISTRAR (V_ID_PROCESO => V_ID_PROCESO,
                              V_TERMINAL   => Q_TERMINAL_VEHICULO.V_TERMINAL_VEHICULO'Access,
                              V_MATRICULA  => Q_VEHICULO.F_OBTENER_MATRICULA(V_VEHICULO),
                              V_REGISTRADO => V_ESTA_VEHICULO_REGISTRADO);

      if not V_ESTA_VEHICULO_REGISTRADO then

         -- Sacar por la pantalla del vehiculo el mensaje de que el servidor ha llegado al limite de su capacidad y que se
         -- reintentara el registro dentro de 5 segundos.
         Ada.Text_IO.Put_Line (" --");
         Ada.Text_IO.Put_Line (" El servidor no tiene capacidad para mas vehiculos o los servicios no han sido arrancados completamente");
         Ada.Text_Io.Put_Line (" Se reintentara la conexion en 5 segundos");

         for I in 1..5 loop

            delay 1.0;
            Ada.Text_IO.Put (" -");

         end loop;
         Ada.Text_Io.Put_Line ("");

      end if;

   end loop;

   loop

      -- El vehiculo esta registrado. Generar una solicitud de ruta.
      if V_NUMERO_INTENTOS_RUTA > 5 or V_PRIMERA_VEZ then

         -- Reiniciar la cuenta
         V_NUMERO_INTENTOS_RUTA := 0;
         -- (Re)calcular el punto de salida.
         V_PRIMERA_VEZ := False;

         -- Obtener el segmento mas cercano a una posicion de salida dada.
         Q_TRAMO.Q_ACCIONES.P_OBTENER_TRAMO_MAS_CERCANO_A_POSICION
           (V_LISTA_TRAMOS         => V_LISTA_TRAMOS_ADAPTACION,
            V_POSICION             => Q_AREA_TRABAJO.F_OBTENER_COORDENADAS_ALEATORIAS,
            V_POSICION_SEGMENTO    => V_POSICION_INICIAL,
            V_DISTANCIA_A_SEGMENTO => V_DISTANCIA_MINIMA,
            V_TRAMO                => V_TRAMO_ORIGEN);

      end if;

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

      -- Obtener el segmento mas cercano a esa posicion de destino dada.
      Q_TRAMO.Q_ACCIONES.P_OBTENER_TRAMO_MAS_CERCANO_A_POSICION (V_LISTA_TRAMOS   => V_LISTA_TRAMOS_ADAPTACION,
                                                                 V_POSICION             => Q_AREA_TRABAJO.F_OBTENER_COORDENADAS_ALEATORIAS,
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

         Q_SOLICITUD_RUTA.P_CREAR_SOLICITUD_RUTA (V_MATRICULA      => V_MATRICULA (1..Q_VEHICULO.F_OBTENER_LONGITUD_MATRICULA),
                                                  V_ORIGEN         => V_POSICION_INICIAL,
                                                  V_DESTINO        => V_POSICION_DESTINO,
                                                  V_SOLICITUD_RUTA => V_SOLICITUD_RUTA);

         Q_SERVIDOR.P_SOLICITAR_RUTA (V_SOLICITUD_RUTA  => V_SOLICITUD_RUTA,
                                      V_LONGITUD_RUTA   => V_LONGITUD_RUTA,
                                      V_RUTA_STREAM     => V_RUTA_STREAM,
                                      V_COSTE_TIEMPO    => V_COSTE_TIEMPO,
                                      V_COSTE_DISTANCIA => V_COSTE_DISTANCIA,
                                      V_TRAYECTO_ID     => V_TRAYECTO_ID);

         -- Mostrar la ruta.
         if V_LONGITUD_RUTA = 0 then

            -- La ruta esta vacia => No se ha podido encontrar una ruta.
            Ada.Text_IO.Put_Line (" ARIADNA NO HA PODIDO ENCONTRAR UNA RUTA ");

            -- Incrementar el numero de intentos. Buscar otro destino
            V_NUMERO_INTENTOS_RUTA := V_NUMERO_INTENTOS_RUTA + 1;

         else

            -- Se ha obtenido una ruta valida.
            V_NUMERO_INTENTOS_RUTA := 0;

            -- Inicializar la ruta.
            Q_RUTA.Q_LISTA_TRAMOS.P_INICIALIZAR_LISTA (V_RUTA);

            for I in 1 .. V_LONGITUD_RUTA loop

               -- Generar la ruta con los tramos completos.
               Q_RUTA.Q_LISTA_TRAMOS.P_INSERTAR_ELEMENTO (V_ELEMENTO => Q_ADAPTACION_TRAMO.F_OBTENER_TRAMO (V_RUTA_STREAM(I)),
                                                          V_LISTA    => V_RUTA);

            end loop;

            -- Mostrar la ruta
            Q_TRAMO.Q_ACCIONES.P_VISUALIZAR_CABECERA_TRAMO;
            for I in 1 .. Q_RUTA.Q_LISTA_TRAMOS.F_CUANTOS_ELEMENTOS (V_RUTA) loop

               Q_TRAMO.Q_ACCIONES.P_VISUALIZAR_TRAMO
                 (V_LISTA_TRAMOS => V_LISTA_TRAMOS_ADAPTACION,
                  V_ID           => Q_TRAMO.F_OBTENER_ID(Q_RUTA.Q_LISTA_TRAMOS.F_DEVOLVER_ELEMENTO (V_POSICION => I,
                                                                                                    V_LISTA    => V_RUTA)));
            end loop;

            -- Generar el trayecto.
            Q_TRAYECTO.P_CREAR_TRAYECTO (V_VEHICULO        => V_VEHICULO,
                                         V_POSICION_ORIGEN => V_POSICION_INICIAL,
                                         V_POSICION_FINAL  => V_POSICION_DESTINO,
                                         V_DURACION        => V_COSTE_TIEMPO,
                                         V_DISTANCIA       => V_COSTE_DISTANCIA,
                                         V_RUTA            => V_RUTA,
                                         V_TRAYECTO        => V_TRAYECTO);

            -- Generar los datos del trayecto para enviarlos al servidor.

            -- Inicializar array de cruces stream.
            V_NUMERO_CRUCES := 0;
            Q_DATOS_TRAYECTO_STREAM.P_INICIALIZAR_ARRAY_CRUCES (V_ARRAY_CRUCES_STREAM);

            -- Obtener los cruces del elemento actual de la progresion.
            for I in 1 .. Q_CONEXION.Q_LISTA_CRUCES.F_CUANTOS_ELEMENTOS (Q_TRAYECTO.F_OBTENER_LISTA_CRUCES_ACTUAL (V_TRAYECTO)) loop

               Q_DATOS_TRAYECTO_STREAM.P_INSERTAR_CRUCE
                 (V_CRUCE               =>
                    Q_CONEXION.Q_LISTA_CRUCES.F_DEVOLVER_ELEMENTO (V_POSICION => I,
                                                                   V_LISTA    => Q_TRAYECTO.F_OBTENER_LISTA_CRUCES_ACTUAL (V_TRAYECTO)),
                  V_NUMERO_CRUCES       => V_NUMERO_CRUCES,
                  V_ARRAY_CRUCES_STREAM => V_ARRAY_CRUCES_STREAM);

            end loop;

            Q_DATOS_TRAYECTO_STREAM.P_GENERAR_DATOS_TRAYECTO_STREAM
              (V_TRAYECTO_ID           => V_TRAYECTO_ID,
               V_MATRICULA             => Q_VEHICULO.F_OBTENER_MATRICULA (V_VEHICULO) (1..8),
               V_TRAMO_ID              => Q_TRAYECTO.F_OBTENER_TRAMO_ACTUAL_ID (V_TRAYECTO),
               V_CARRIL                => Q_TRAYECTO.F_OBTENER_CARRIL_ACTUAL (V_TRAYECTO),
               V_SENTIDO               => Q_TRAYECTO.F_OBTENER_SENTIDO_CIRCULACION (V_TRAYECTO),
               V_NUMERO_CRUCES         => V_NUMERO_CRUCES,
               V_ARRAY_CRUCES          => V_ARRAY_CRUCES_STREAM,
               V_POSICION              => Q_TRAYECTO.F_OBTENER_POSICION_ACTUAL (V_TRAYECTO),
               V_VELOCIDAD             => Q_TRAYECTO.F_OBTENER_VELOCIDAD_ACTUAL (V_TRAYECTO),
               V_DATOS_TRAYECTO_STREAM => V_DATOS_TRAYECTO_STREAM);

            -- Insertar el trayecto en la tabla de trayectos del servidor.
            Q_SERVIDOR.P_INSERTAR_TRAYECTO_EN_TABLA_TRAYECTOS (V_DATOS_TRAYECTO_STREAM);

            Q_TRAYECTO.Q_ACCIONES.P_VISUALIZAR_CABECERA_ESTATICA_TRAYECTO;
            Q_TRAYECTO.Q_ACCIONES.P_VISUALIZAR_PARTE_ESTATICA_TRAYECTO (V_TRAYECTO                => V_TRAYECTO,
                                                                        V_LISTA_TRAMOS_ADAPTACION => V_LISTA_TRAMOS_ADAPTACION);
            Q_TRAYECTO.Q_ACCIONES.P_VISUALIZAR_CABECERA_DINAMICA_TRAYECTO;
            Q_TRAYECTO.Q_ACCIONES.P_VISUALIZAR_PARTE_DINAMICA_TRAYECTO (V_TRAYECTO                => V_TRAYECTO,
                                                                        V_LISTA_TRAMOS_ADAPTACION => V_LISTA_TRAMOS_ADAPTACION);

            -- Delay para que en la tabla de trayectos del servidor aparezca el vehiculo detenido al comenzar el trayecto.
            delay 1.0;
            -- Actualizar trayecto. => Mover vehiculo.
            loop

               Q_TRAYECTO.P_PONER_ESTADO (V_ESTADO   => Q_TRAYECTO.E_ACTIVO,
                                          V_TRAYECTO => V_TRAYECTO);

               Q_TRAYECTO.Q_ACCIONES.P_ACTUALIZAR_TRAYECTO (V_TRAYECTO);

               -- Inicializar array de cruces stream.
               V_NUMERO_CRUCES := 0;
               Q_DATOS_TRAYECTO_STREAM.P_INICIALIZAR_ARRAY_CRUCES (V_ARRAY_CRUCES_STREAM);

               -- Obtener los cruces del elemento actual de la progresion.
               for I in 1 .. Q_CONEXION.Q_LISTA_CRUCES.F_CUANTOS_ELEMENTOS (Q_TRAYECTO.F_OBTENER_LISTA_CRUCES_ACTUAL (V_TRAYECTO)) loop

                  Q_DATOS_TRAYECTO_STREAM.P_INSERTAR_CRUCE
                    (V_CRUCE               =>
                       Q_CONEXION.Q_LISTA_CRUCES.F_DEVOLVER_ELEMENTO (V_POSICION => I,
                                                                      V_LISTA    => Q_TRAYECTO.F_OBTENER_LISTA_CRUCES_ACTUAL (V_TRAYECTO)),
                     V_NUMERO_CRUCES       => V_NUMERO_CRUCES,
                     V_ARRAY_CRUCES_STREAM => V_ARRAY_CRUCES_STREAM);

            end loop;


               -- Enviar la actualizacion al servidor.
               Q_DATOS_TRAYECTO_STREAM.P_GENERAR_DATOS_TRAYECTO_STREAM
                 (V_TRAYECTO_ID           => V_TRAYECTO_ID,
                  V_MATRICULA             => Q_VEHICULO.F_OBTENER_MATRICULA (V_VEHICULO) (1..8),
                  V_TRAMO_ID              => Q_TRAYECTO.F_OBTENER_TRAMO_ACTUAL_ID (V_TRAYECTO),
                  V_CARRIL                => Q_TRAYECTO.F_OBTENER_CARRIL_ACTUAL (V_TRAYECTO),
                  V_SENTIDO               => Q_TRAYECTO.F_OBTENER_SENTIDO_CIRCULACION (V_TRAYECTO),
                  V_NUMERO_CRUCES         => V_NUMERO_CRUCES,
                  V_ARRAY_CRUCES          => V_ARRAY_CRUCES_STREAM,
                  V_POSICION              => Q_TRAYECTO.F_OBTENER_POSICION_ACTUAL (V_TRAYECTO),
                  V_VELOCIDAD             => Q_TRAYECTO.F_OBTENER_VELOCIDAD_ACTUAL (V_TRAYECTO),
                  V_DATOS_TRAYECTO_STREAM => V_DATOS_TRAYECTO_STREAM);

               Q_SERVIDOR.P_ACTUALIZAR_TRAYECTO (V_DATOS_TRAYECTO_STREAM);

               Q_TRAYECTO.Q_ACCIONES.P_VISUALIZAR_CABECERA_DINAMICA_TRAYECTO;
               Q_TRAYECTO.Q_ACCIONES.P_VISUALIZAR_PARTE_DINAMICA_TRAYECTO (V_TRAYECTO                => V_TRAYECTO,
                                                                           V_LISTA_TRAMOS_ADAPTACION => V_LISTA_TRAMOS_ADAPTACION);

               exit when Q_TRAYECTO.F_ESTA_TRAYECTO_TERMINADO (V_TRAYECTO);

               delay 1.0;

            end loop;

            Ada.Text_Io.Put_Line ("");

            -- El delay es para que en la tabla de trayectos del servidor llegue a aparecer el vehiculo detenido antes de eliminar el
            -- trayecto.
            delay 1.0;

            -- Eliminar el trayecto del servidor.
            Q_SERVIDOR.P_ELIMINAR_TRAYECTO (V_TRAYECTO_ID);

            -- Establecer el destino al que hemos llegado como punto de partida.
            V_POSICION_INICIAL := V_POSICION_DESTINO;
            V_TRAMO_ORIGEN := V_TRAMO_DESTINO;
            V_COSTE_TIEMPO := 0;
            V_COSTE_DISTANCIA := 0;

         end if;

      end if;

      delay 2.0;

   end loop;

end m_vehiculo;
-------------------------------------------------------------------------------------------------------------------------------------------
