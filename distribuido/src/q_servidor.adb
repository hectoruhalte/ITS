--------------------------------------------------------------------------------------------------------------------------------------------
--
--      Fichero:        q_servidor.adb
--
--      Autor:          Hector Uhalte Bilbao
--
--      Fecha:          26/8/2020
--
--------------------------------------------------------------------------------------------------------------------------------------------

with Ada.Text_IO;
with Q_TIPOS_REMOTOS;
with Ada.Characters.Latin_1;
with Q_TIPOS_BASICOS;
with Q_RUTA.Q_DIJKSTRA;
with Q_ADAPTACION_TRAMO;
with Q_TRAMO.Q_ACCIONES;
with Q_TABLA_TRAYECTOS;
with GNAT.OS_Lib;

package body Q_SERVIDOR is
   
   -- Constante para el limite de vehiculos registrados en el servidor.
   C_MAXIMO_NUMERO_VEHICULOS_EN_SERVIDOR : constant Integer := 2;
   
   -------------------------------------
   protected type T_CONEXION_VEHICULO is
      
      procedure P_REGISTRAR (V_ID_PROCESO : in Integer;
                             V_TERMINAL : T_TERMINAL_ACCESS;
                             V_MATRICULA : in String);
      
      function F_OBTENER_ID_PROCESO return Integer;
      
      function F_OBTENER_TERMINAL return T_TERMINAL_ACCESS;
      
      function F_OBTENER_MATRICULA return String;
      
   private
      
      R_ID_PROCESO : Integer := -1;
      
      R_TERMINAL : T_TERMINAL_ACCESS;
      
      R_MATRICULA : String (1..8);
      
   end T_CONEXION_VEHICULO;
   
   protected body T_CONEXION_VEHICULO is
      
      
      procedure P_REGISTRAR (V_ID_PROCESO : in Integer;
                             V_TERMINAL : T_TERMINAL_ACCESS;
                             V_MATRICULA : in String) is
         
      begin
         
         R_ID_PROCESO := V_ID_PROCESO;
         
         R_TERMINAL := V_TERMINAL;
         
         R_MATRICULA := V_MATRICULA;
         
      end P_REGISTRAR;
      
      
      function F_OBTENER_ID_PROCESO return Integer is
         
      begin
         
         return R_ID_PROCESO;
         
      end F_OBTENER_ID_PROCESO;
      
      
      function F_OBTENER_TERMINAL return T_TERMINAL_ACCESS is
         
      begin
         
         return R_TERMINAL;
         
      end F_OBTENER_TERMINAL;
      
      
      function F_OBTENER_MATRICULA return String is
         
      begin
         
         return R_MATRICULA;
         
      end F_OBTENER_MATRICULA;
      
      
   end T_CONEXION_VEHICULO;
   -------------------------------------
   
   V_ARRAY_CONEXIONES_VEHICULO : array (1..C_MAXIMO_NUMERO_VEHICULOS_EN_SERVIDOR) of T_CONEXION_VEHICULO;
   
   ------------------------------------------------
   protected type T_NUMERO_VEHICULOS_EN_SERVIDOR is
      
      function F_OBTENER_NUMERO_VEHICULOS_EN_SERVIDOR return Natural;
      
      procedure P_INCREMENTAR_NUMERO_VEHICULOS_EN_SERVIDOR;
      
   private
      
      R_NUMERO_VEHICULOS_EN_SERVIDOR : Natural := 0;
      
   end T_NUMERO_VEHICULOS_EN_SERVIDOR;
   
   protected body T_NUMERO_VEHICULOS_EN_SERVIDOR is
      
      function F_OBTENER_NUMERO_VEHICULOS_EN_SERVIDOR return Natural is
         
      begin
         
         return R_NUMERO_VEHICULOS_EN_SERVIDOR;
         
      end F_OBTENER_NUMERO_VEHICULOS_EN_SERVIDOR;
      
      procedure P_INCREMENTAR_NUMERO_VEHICULOS_EN_SERVIDOR is
         
      begin
         
         R_NUMERO_VEHICULOS_EN_SERVIDOR := R_NUMERO_VEHICULOS_EN_SERVIDOR + 1;
         
      end P_INCREMENTAR_NUMERO_VEHICULOS_EN_SERVIDOR;
   
   end T_NUMERO_VEHICULOS_EN_SERVIDOR;
   ------------------------------------------------
   
   V_NUMERO_VEHICULOS_EN_SERVIDOR : T_NUMERO_VEHICULOS_EN_SERVIDOR;
   
   --------------------------------------------------
   procedure P_REGISTRAR (V_ID_PROCESO : in Integer;
                          V_TERMINAL : in T_TERMINAL_ACCESS;
                          V_MATRICULA : in String;
                          V_REGISTRADO : out Boolean) is
      
      V_TERMINAL_VEHICULO : Q_TIPOS_REMOTOS.T_TERMINAL_VEHICULO;
      
   begin
      
      V_ARRAY_CONEXIONES_VEHICULO (V_NUMERO_VEHICULOS_EN_SERVIDOR.F_OBTENER_NUMERO_VEHICULOS_EN_SERVIDOR + 1).
        P_REGISTRAR (V_ID_PROCESO => V_ID_PROCESO,
                     V_TERMINAL  => V_TERMINAL,
                     V_MATRICULA => V_MATRICULA(V_MATRICULA'First..V_MATRICULA'First+7));
      
      -- Si no salta la excepcion, el registro ha tenido exito.
      V_REGISTRADO := True;
      
      V_NUMERO_VEHICULOS_EN_SERVIDOR.P_INCREMENTAR_NUMERO_VEHICULOS_EN_SERVIDOR;
      
      Ada.Text_Io.Put_Line (" Recibido el registro del vehiculo : " & 
                              V_ARRAY_CONEXIONES_VEHICULO 
                              (V_NUMERO_VEHICULOS_EN_SERVIDOR.F_OBTENER_NUMERO_VEHICULOS_EN_SERVIDOR).F_OBTENER_MATRICULA);
      Ada.Text_IO.Put_Line (" --");
      Ada.Text_IO.Put_Line ("");
  
      -- Notificar el registro del vehiculo en el servidor al cliente.
      Q_TERMINAL.P_NOTIFICAR_REGISTRO (V_TERMINAL_VEHICULO => V_TERMINAL,
                                       V_MATRICULA         => V_MATRICULA);
      
   exception
         
      when Constraint_Error =>
         
         -- El servidor no puede admitir mas vehiculos
         V_REGISTRADO := False;
      
   end P_REGISTRAR;
   --------------------------------------------------
   
   -- Tipo de tarea que va a obtener una ruta a partir de una solicitud de ruta.
   task type T_TK_PROCESAR_SOLICITUD_RUTA is
      
      entry EN_OBTENER_RUTA (V_SOLICITUD_RUTA : in Q_SOLICITUD_RUTA.T_SOLICITUD_RUTA;
                             V_RUTA : out Q_RUTA.T_RUTA;
                             V_COSTE_TIEMPO : out Integer;
                             V_COSTE_DISTANCIA : out Integer);
      
   end T_TK_PROCESAR_SOLICITUD_RUTA;
   
   task body T_TK_PROCESAR_SOLICITUD_RUTA is
      
   begin
      
      accept EN_OBTENER_RUTA (V_SOLICITUD_RUTA : in Q_SOLICITUD_RUTA.T_SOLICITUD_RUTA;
                              V_RUTA : out Q_RUTA.T_RUTA;
                              V_COSTE_TIEMPO : out Integer;
                              V_COSTE_DISTANCIA : out Integer) do
         
         -- Inicializar costes.
         V_COSTE_TIEMPO := 0;
         V_COSTE_DISTANCIA := 0;
         
         Q_RUTA.Q_DIJKSTRA.P_OBTENER_RUTA (V_POSICION_ORIGEN => Q_SOLICITUD_RUTA.F_OBTENER_ORIGEN (V_SOLICITUD_RUTA),
                                           V_POSICION_FINAL  => Q_SOLICITUD_RUTA.F_OBTENER_DESTINO (V_SOLICITUD_RUTA),
                                           V_RUTA            => V_RUTA,
                                           V_COSTE_TIEMPO    => V_COSTE_TIEMPO,
                                           V_COSTE_DISTANCIA => V_COSTE_DISTANCIA);
         
      exception
            
         when Q_RUTA.X_RUTA_NO_ENCONTRADA => 

            Q_RUTA.Q_LISTA_TRAMOS.P_INICIALIZAR_LISTA (V_RUTA);
         
      end EN_OBTENER_RUTA;
      
   end T_TK_PROCESAR_SOLICITUD_RUTA;
   ---------------------------------
   
   ---------------------------------------------------------------
   procedure P_SOLICITAR_RUTA (V_SOLICITUD_RUTA : in Q_SOLICITUD_RUTA.T_SOLICITUD_RUTA;
                               V_LONGITUD_RUTA : out Natural;
                               V_RUTA_STREAM : out Q_RUTA_STREAM.T_RUTA_STREAM;
                               V_COSTE_TIEMPO : out Integer;
                               V_COSTE_DISTANCIA : out Integer;
                               V_TRAYECTO_ID : out Natural) is
      
      V_TK_PROCESAR_SOLICITUD_RUTA : T_TK_PROCESAR_SOLICITUD_RUTA;
      
      V_RUTA : Q_RUTA.T_RUTA;
      
   begin
      
      -- Inicializar ruta.
      Q_RUTA.Q_LISTA_TRAMOS.P_INICIALIZAR_LISTA (V_RUTA);
      
      -- Llamar a la tarea que calcula la ruta.
      V_TK_PROCESAR_SOLICITUD_RUTA.EN_OBTENER_RUTA (V_SOLICITUD_RUTA  => V_SOLICITUD_RUTA,
                                                    V_RUTA            => V_RUTA,
                                                    V_COSTE_TIEMPO    => V_COSTE_TIEMPO,
                                                    V_COSTE_DISTANCIA => V_COSTE_DISTANCIA);

      -- Obtener la longitud de la ruta
      V_LONGITUD_RUTA := Q_RUTA.Q_LISTA_TRAMOS.F_CUANTOS_ELEMENTOS (V_RUTA);
      
      -- Inicializar la ruta stream
      V_RUTA_STREAM := (others => 0);
      
      -- Generar la ruta stream. En sentido inverso para ser reconstruida en el cliente de manera correcta.
      for I in reverse 1 .. Q_RUTA.Q_LISTA_TRAMOS.F_CUANTOS_ELEMENTOS (V_RUTA) loop
      
         V_RUTA_STREAM (V_LONGITUD_RUTA-I+1) := Q_TRAMO.F_OBTENER_ID (Q_RUTA.Q_LISTA_TRAMOS.F_DEVOLVER_ELEMENTO (V_POSICION => I,
                                                                                                                 V_LISTA    => V_RUTA));
         
      end loop;
      
      -- Obtener el id del trayecto en caso de que se haya podido obtener una ruta.
      if V_LONGITUD_RUTA > 0 then
         
         V_TRAYECTO_ID := Q_TABLA_TRAYECTOS.F_OBTENER_TRAYECTO_ID;
         
      else
         
         V_TRAYECTO_ID := 0;
         
      end if;
         
   end P_SOLICITAR_RUTA;
   -------------------------------------------------------------------------------
   
   -------------------------------------------------------------------------------------------------------------------
   procedure P_CREAR_TRAYECTO_TABLA_TRAYECTOS (V_DATOS_TRAYECTO_STREAM : in Q_DATOS_TRAYECTO_STREAM.T_DATOS_TRAYECTO_STREAM;
                                               V_TRAYECTO : out Q_TABLA_TRAYECTOS.T_ELEMENTO_TABLA_DATOS_TRAYECTOS) is
      
      V_ARRAY_CRUCES : Q_TABLA_TRAYECTOS.T_ARRAY_CRUCES;
      
   begin
      
      Q_TABLA_TRAYECTOS.P_INICIALIZAR_ARRAY_CRUCES (V_ARRAY_CRUCES);
      
      for I in 1 .. Q_DATOS_TRAYECTO_STREAM.F_OBTENER_NUMERO_CRUCES (V_DATOS_TRAYECTO_STREAM) loop
         
         Q_TABLA_TRAYECTOS.P_INSERTAR_CRUCE 
           (V_POSICION     => I,
            V_CRUCE        => 
              Q_DATOS_TRAYECTO_STREAM.F_OBTENER_CRUCE 
                (V_POSICION     => I,
                 V_ARRAY_CRUCES => Q_DATOS_TRAYECTO_STREAM.F_OBTENER_ARRAY_CRUCES (V_DATOS_TRAYECTO_STREAM)),
            V_ARRAY_CRUCES => V_ARRAY_CRUCES);
         
      end loop;
      
      Q_TABLA_TRAYECTOS.P_CREAR_ELEMENTO_TABLA_DATOS_TRAYECTOS 
        (V_MATRICULA                      => Q_DATOS_TRAYECTO_STREAM.F_OBTENER_MATRICULA (V_DATOS_TRAYECTO_STREAM) (1..8),
         V_TRAMO_ID                       => Q_DATOS_TRAYECTO_STREAM.F_OBTENER_TRAMO_ID (V_DATOS_TRAYECTO_STREAM),
         V_CARRIL                         => Q_DATOS_TRAYECTO_STREAM.F_OBTENER_CARRIL (V_DATOS_TRAYECTO_STREAM),
         V_SENTIDO_CIRCULACION            => Q_DATOS_TRAYECTO_STREAM.F_OBTENER_SENTIDO_CIRCULACION (V_DATOS_TRAYECTO_STREAM),
         V_POSICION                       => Q_DATOS_TRAYECTO_STREAM.F_OBTENER_POSICION (V_DATOS_TRAYECTO_STREAM),
         V_NUMERO_CRUCES                  => Q_DATOS_TRAYECTO_STREAM.F_OBTENER_NUMERO_CRUCES (V_DATOS_TRAYECTO_STREAM),
         V_ARRAY_CRUCES                   => V_ARRAY_CRUCES,
         V_VELOCIDAD                      => Q_DATOS_TRAYECTO_STREAM.F_OBTENER_VELOCIDAD (V_DATOS_TRAYECTO_STREAM),
         V_ELEMENTO_TABLA_DATOS_TRAYECTOS => V_TRAYECTO);
      
   end P_CREAR_TRAYECTO_TABLA_TRAYECTOS;
   -------------------------------------
   
   ----------------------------------------------------------------------------------------------------------------------------------
   procedure P_INSERTAR_TRAYECTO_EN_TABLA_TRAYECTOS (V_DATOS_TRAYECTO_STREAM : in Q_DATOS_TRAYECTO_STREAM.T_DATOS_TRAYECTO_STREAM) is
      
      V_TRAYECTO : Q_TABLA_TRAYECTOS.T_ELEMENTO_TABLA_DATOS_TRAYECTOS;
      
   begin
      
      P_CREAR_TRAYECTO_TABLA_TRAYECTOS (V_DATOS_TRAYECTO_STREAM => V_DATOS_TRAYECTO_STREAM,
                                        V_TRAYECTO              => V_TRAYECTO);
      
      Q_TABLA_TRAYECTOS.P_INSERTAR_TRAYECTO (V_TRAYECTO_ID => Q_DATOS_TRAYECTO_STREAM.F_OBTENER_TRAYECTO_ID (V_DATOS_TRAYECTO_STREAM),
                                             V_TRAYECTO    => V_TRAYECTO);
      
   end P_INSERTAR_TRAYECTO_EN_TABLA_TRAYECTOS;
   ----------------------------------------------------------------------------------------------------------------------------------
   
   -----------------------------------------------------------------------------------------------------------------
   procedure P_ACTUALIZAR_TRAYECTO (V_DATOS_TRAYECTO_STREAM : in Q_DATOS_TRAYECTO_STREAM.T_DATOS_TRAYECTO_STREAM) is
      
      V_TRAYECTO : Q_TABLA_TRAYECTOS.T_ELEMENTO_TABLA_DATOS_TRAYECTOS;
      
   begin
      
      P_CREAR_TRAYECTO_TABLA_TRAYECTOS (V_DATOS_TRAYECTO_STREAM => V_DATOS_TRAYECTO_STREAM,
                                        V_TRAYECTO              => V_TRAYECTO);
      
      Q_TABLA_TRAYECTOS.P_ACTUALIZAR_TRAYECTO (V_TRAYECTO_ID => Q_DATOS_TRAYECTO_STREAM.F_OBTENER_TRAYECTO_ID (V_DATOS_TRAYECTO_STREAM),
                                               V_TRAYECTO    => V_TRAYECTO);
         
   end P_ACTUALIZAR_TRAYECTO;
   -----------------------------------------------------------------------------------------------------------------
   
   -------------------------------------------------------------
   procedure P_ELIMINAR_TRAYECTO (V_TRAYECTO_ID : in Natural) is
      
   begin
      
      Q_TABLA_TRAYECTOS.P_ELIMINAR_TRAYECTO (V_TRAYECTO_ID);
      
   end P_ELIMINAR_TRAYECTO;
   -------------------------------------------------------------
   
   -----------------------------------------------------------
   procedure P_NOTIFICAR_COLISION (V_MATRICULA : in String) is
      
      C_ARGUMENTO_1 : constant String (1..3) := "-15";
      
      V_RESULTADO : Boolean := False;
      
   begin
      
      -- Obtener el terminal del vehiculo para la matricula dada
      for I in 1 .. V_ARRAY_CONEXIONES_VEHICULO'Length loop
      
         if V_ARRAY_CONEXIONES_VEHICULO(I).F_OBTENER_MATRICULA(V_MATRICULA'First..V_MATRICULA'First+7) = 
            V_MATRICULA(V_MATRICULA'First..V_MATRICULA'First+7)
         then

            Q_TERMINAL.P_NOTIFICAR_COLISION (V_TERMINAL_VEHICULO => V_ARRAY_CONEXIONES_VEHICULO(I).F_OBTENER_TERMINAL,
                                             V_ID_PROCESO        => V_ARRAY_CONEXIONES_VEHICULO(I).F_OBTENER_ID_PROCESO);
            
            -- Terminar el proceso del vehiculo
            GNAT.OS_Lib.Spawn (Program_Name => "/bin/kill",
                               Args         => (1 => new String'(C_ARGUMENTO_1),
                                                2 => new String'(Integer'Image(V_ARRAY_CONEXIONES_VEHICULO(I).F_OBTENER_ID_PROCESO))),
                               Success      => V_RESULTADO);           
            exit;
            
         end if;
         
      end loop;
      
   end P_NOTIFICAR_COLISION;
   -----------------------------------------------------------

end Q_SERVIDOR;
--------------------------------------------------------------------------------------------------------------------------------------------
