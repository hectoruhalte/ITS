--------------------------------------------------------------------------------------------------------------------------------------------
--
--      Fichero:        q_tramo.adb
--
--      Autor:          Hector Uhalte Bilbao
--
--      Fecha:          4/10/2017
--      
--------------------------------------------------------------------------------------------------------------------------------------------

package body Q_TRAMO is

   -------------------------------------------------------
   function "=" (V_TRAMO_1 : in T_TRAMO;
                 V_TRAMO_2 : in T_TRAMO) return Boolean is

   begin

      return V_TRAMO_1.R_ID = V_TRAMO_2.R_ID;

   end "=";
   -------------------------------------------------------

   ---------------------------------------------------------------------------
   function F_COMPARAR_TRAMOS_ID (V_TRAMO_ID_1 : in Natural;
                                  V_TRAMO_ID_2 : in Natural) return Boolean is

   begin

      return V_TRAMO_ID_1 = V_TRAMO_ID_2;

   end F_COMPARAR_TRAMOS_ID;
   ---------------------------------------------------------------------------

   ---------------------------------------------------------
   function F_OBTENER_NUMERO_MAXIMO_TRAMOS return Integer is

   begin
		
      return C_NUMERO_MAXIMO_TRAMOS;

   end F_OBTENER_NUMERO_MAXIMO_TRAMOS;
   ---------------------------------------------------------

   -----------------------------------------------------------------
   function F_OBTENER_LONGITUD_MAXIMA_NOMBRE_TRAMO return Integer is

   begin

      return C_LONGITUD_MAXIMA_NOMBRE_TRAMO;

   end F_OBTENER_LONGITUD_MAXIMA_NOMBRE_TRAMO;
   -----------------------------------------------------------------

   ------------------------------------------------------
   function F_OBTENER_NOMBRE_TRAMO_VACIO return String is

   begin

      return C_NOMBRE_TRAMO_VACIO;

   end F_OBTENER_NOMBRE_TRAMO_VACIO;
   ------------------------------------------------------

   ------------------------------------------------
   function F_OBTENER_ALTURA_MAXIMA return Float is

   begin

      return C_ALTURA_MAXIMA;

   end F_OBTENER_ALTURA_MAXIMA;
   ------------------------------------------------

   -----------------------------------------------------------
   procedure P_INICIALIZAR_TRAMO (V_TRAMO : in out T_TRAMO) is

      V_LISTA_SEGMENTOS : Q_LISTA_SEGMENTOS.T_LISTA;

      V_LISTA_CONEXIONES : Q_LISTA_CONEXIONES.T_LISTA;

   begin

      V_TRAMO.R_ID := 0;

      V_TRAMO.R_NOMBRE := F_OBTENER_NOMBRE_TRAMO_VACIO;

      V_TRAMO.R_ORIGEN := Q_TIPOS_BASICOS.F_OBTENER_POSICION_UTM (V_X => 0,
                                                                  V_Y => 0);

      V_TRAMO.R_FINAL := V_TRAMO.R_ORIGEN;

      V_TRAMO.R_ALTURA := F_OBTENER_ALTURA_MAXIMA;
      
      V_TRAMO.R_SENTIDO_CIRCULACION.R_ASCENDENTE := 1;
      V_TRAMO.R_SENTIDO_CIRCULACION.R_DESCENDENTE := 1;

      V_TRAMO.R_VELOCIDAD_MAXIMA := 0;

      Q_LISTA_SEGMENTOS.P_INICIALIZAR_LISTA (V_LISTA_SEGMENTOS);

      V_TRAMO.R_SEGMENTOS := V_LISTA_SEGMENTOS;

      Q_LISTA_CONEXIONES.P_INICIALIZAR_LISTA (V_LISTA_CONEXIONES);

      V_TRAMO.R_TIEMPO_TRAMO := 0;

      V_TRAMO.R_DISTANCIA_TRAMO := 0;

      V_TRAMO.R_CARGA_TRAFICO := 0.0;

      V_TRAMO.R_DISPONIBLE := True;

   end P_INICIALIZAR_TRAMO;
   -----------------------------------------------------------

   --------------------------------------------------------------
   function F_OBTENER_ID (V_TRAMO : in T_TRAMO) return Integer is

   begin

      return V_TRAMO.R_ID;

   end F_OBTENER_ID;
   --------------------------------------------------------------

   --------------------------------------------------
   procedure P_PONER_ID (V_ID : in Integer;
                         V_TRAMO : in out T_TRAMO) is

   begin

      V_TRAMO.R_ID := V_ID;

   end P_PONER_ID;
   --------------------------------------------------

   -----------------------------------------------------------------
   function F_OBTENER_NOMBRE (V_TRAMO : in T_TRAMO) return String is

   begin

      return V_TRAMO.R_NOMBRE;

   end F_OBTENER_NOMBRE;
   -----------------------------------------------------------------

   ------------------------------------------------------
   procedure P_PONER_NOMBRE (V_NOMBRE : in String;
                             V_TRAMO : in out T_TRAMO) is

   begin

      V_TRAMO.R_NOMBRE := V_NOMBRE(V_NOMBRE'First .. V_NOMBRE'Last);

   end P_PONER_NOMBRE;
   ------------------------------------------------------

   -----------------------------------------------------------------------------------------
   function F_OBTENER_ORIGEN (V_TRAMO : in T_TRAMO) return Q_TIPOS_BASICOS.T_POSICION_UTM is

   begin

      return V_TRAMO.R_ORIGEN;

   end F_OBTENER_ORIGEN;
   -----------------------------------------------------------------------------------------

   ------------------------------------------------------
   procedure P_PONER_ORIGEN (V_ORIGEN : in Q_TIPOS_BASICOS.T_POSICION_UTM;
                             V_TRAMO : in out T_TRAMO) is

   begin

      V_TRAMO.R_ORIGEN := V_ORIGEN;

   end P_PONER_ORIGEN;
   ------------------------------------------------------

   ----------------------------------------------------------------------------------------
   function F_OBTENER_FINAL (V_TRAMO : in T_TRAMO) return Q_TIPOS_BASICOS.T_POSICION_UTM is

   begin

      return V_TRAMO.R_FINAL;

   end F_OBTENER_FINAL;
   ----------------------------------------------------------------------------------------

   -----------------------------------------------------
   procedure P_PONER_FINAL (V_FINAL : in Q_TIPOS_BASICOS.T_POSICION_UTM;
                            V_TRAMO : in out T_TRAMO) is

   begin

      V_TRAMO.R_FINAL := V_FINAL;

   end P_PONER_FINAL;
   -----------------------------------------------------

   -------------------------------------------------------------------
   procedure P_PONER_SENTIDO_CIRCULACION (V_ASCENDENTE : in Natural;
                                          V_DESCENDENTE : in Natural;
                                          V_TRAMO : in out T_TRAMO) is
      
   begin
      
      V_TRAMO.R_SENTIDO_CIRCULACION.R_ASCENDENTE := V_ASCENDENTE;
      V_TRAMO.R_SENTIDO_CIRCULACION.R_DESCENDENTE := V_DESCENDENTE;
      
   end P_PONER_SENTIDO_CIRCULACION;
   -------------------------------------------------------------------
   
   ----------------------------------------------------------------
   function F_OBTENER_ALTURA (V_TRAMO : in T_TRAMO) return Float is

   begin

      return V_TRAMO.R_ALTURA; 

   end F_OBTENER_ALTURA;
   ----------------------------------------------------------------

   ------------------------------------------------------
   procedure P_PONER_ALTURA (V_ALTURA : in Float;
                             V_TRAMO : in out T_TRAMO) is

   begin

      V_TRAMO.R_ALTURA := V_ALTURA;

   end P_PONER_ALTURA;
   ------------------------------------------------------

   ------------------------------------------------------------------------------------------------
   function F_OBTENER_VELOCIDAD_MAXIMA (V_TRAMO : in T_TRAMO) return Q_TIPOS_BASICOS.T_VELOCIDAD is

   begin

      return V_TRAMO.R_VELOCIDAD_MAXIMA;

   end F_OBTENER_VELOCIDAD_MAXIMA;
   ------------------------------------------------------------------------------------------------

   -----------------------------------------------------------------
   procedure P_PONER_VELOCIDAD_MAXIMA (V_VELOCIDAD_MAXIMA : in Q_TIPOS_BASICOS.T_VELOCIDAD;
                                       V_TRAMO : in out T_TRAMO) is

   begin

      V_TRAMO.R_VELOCIDAD_MAXIMA := V_VELOCIDAD_MAXIMA;

   end P_PONER_VELOCIDAD_MAXIMA;
   -----------------------------------------------------------------

   ---------------------------------------------------------------------------------------------
   function F_OBTENER_LISTA_SEGMENTOS (V_TRAMO : in T_TRAMO) return Q_LISTA_SEGMENTOS.T_LISTA is

   begin

      return V_TRAMO.R_SEGMENTOS;

   end F_OBTENER_LISTA_SEGMENTOS;
   ---------------------------------------------------------------------------------------------

   ---------------------------------------------------------------
   procedure P_PONER_LISTA_SEGMENTOS (V_NUMERO_SEGMENTOS : in Natural;
                                      V_ARRAY_SEGMENTOS : in T_ARRAY_SEGMENTOS;
                                      V_TRAMO : in out T_TRAMO) is

   begin

      Q_LISTA_SEGMENTOS.P_INICIALIZAR_LISTA (V_TRAMO.R_SEGMENTOS);

      for I in 1 .. V_NUMERO_SEGMENTOS loop

         Q_LISTA_SEGMENTOS.P_INSERTAR_ELEMENTO (V_ELEMENTO => V_ARRAY_SEGMENTOS (I),
                                                V_LISTA => V_TRAMO.R_SEGMENTOS);
		
      end loop;

   end P_PONER_LISTA_SEGMENTOS;
   ---------------------------------------------------------------

   -----------------------------------------------------------------------------------------------
   function F_OBTENER_LISTA_CONEXIONES (V_TRAMO : in T_TRAMO) return Q_LISTA_CONEXIONES.T_LISTA is

   begin

      return V_TRAMO.R_CONEXIONES;

   end F_OBTENER_LISTA_CONEXIONES;
   -----------------------------------------------------------------------------------------------
	
   ----------------------------------------------------------------
   procedure P_PONER_LISTA_CONEXIONES (V_NUMERO_CONEXIONES : in Integer;
                                       V_ARRAY_CONEXIONES : in T_ARRAY_CONEXIONES;
                                       V_TRAMO : in out T_TRAMO) is

   begin

      Q_LISTA_CONEXIONES.P_INICIALIZAR_LISTA (V_TRAMO.R_CONEXIONES);

      for I in 1 .. V_NUMERO_CONEXIONES loop

         Q_LISTA_CONEXIONES.P_INSERTAR_ELEMENTO (V_ELEMENTO => V_ARRAY_CONEXIONES (I),
                                                 V_LISTA => V_TRAMO.R_CONEXIONES);

      end loop;

   end P_PONER_LISTA_CONEXIONES;
   ----------------------------------------------------------------

   ------------------------------------------------------------------------
   function F_OBTENER_TIEMPO_TRAMO (V_TRAMO : in T_TRAMO) return Integer is

   begin

      return V_TRAMO.R_TIEMPO_TRAMO;

   end F_OBTENER_TIEMPO_TRAMO;
   ------------------------------------------------------------------------

   ------------------------------------------------------------
   procedure P_PONER_TIEMPO_TRAMO (V_TIEMPO_TRAMO : in Integer;
                                   V_TRAMO : in out T_TRAMO) is

   begin

      V_TRAMO.R_TIEMPO_TRAMO := V_TIEMPO_TRAMO;

   end P_PONER_TIEMPO_TRAMO;
   ------------------------------------------------------------

   ---------------------------------------------------------------------------
   function F_OBTENER_DISTANCIA_TRAMO (V_TRAMO : in T_TRAMO) return Integer is

   begin

      return V_TRAMO.R_DISTANCIA_TRAMO;

   end F_OBTENER_DISTANCIA_TRAMO;
   ---------------------------------------------------------------------------

   ---------------------------------------------------------------
   procedure P_PONER_DISTANCIA_TRAMO (V_DISTANCIA : in Integer;
                                      V_TRAMO : in out T_TRAMO) is

   begin

      V_TRAMO.R_DISTANCIA_TRAMO := V_DISTANCIA;

   end P_PONER_DISTANCIA_TRAMO;
   ---------------------------------------------------------------

   ----------------------------------------------------------------------------------
   function F_OBTENER_CAPACIDAD_MAXIMA_TRAMO (V_TRAMO : in T_TRAMO) return Integer is

   begin

      return V_TRAMO.R_CAPACIDAD_MAXIMA;

   end F_OBTENER_CAPACIDAD_MAXIMA_TRAMO;
   ----------------------------------------------------------------------------------

   ----------------------------------------------------------------------
   procedure P_PONER_CAPACIDAD_MAXIMA_TRAMO (V_CAPACIDAD_MAXIMA : in Integer;
                                             V_TRAMO : in out T_TRAMO) is

   begin

      V_TRAMO.R_CAPACIDAD_MAXIMA := V_CAPACIDAD_MAXIMA;

   end P_PONER_CAPACIDAD_MAXIMA_TRAMO;
   ----------------------------------------------------------------------

   -----------------------------------------------------------------------------------
   function F_OBTENER_CAPACIDAD_NOMINAL_TRAMO (V_TRAMO : in T_TRAMO) return Integer is

   begin

      return V_TRAMO.R_CAPACIDAD_NOMINAL;

   end F_OBTENER_CAPACIDAD_NOMINAL_TRAMO;
   -----------------------------------------------------------------------------------

   ----------------------------------------------------------------------
   procedure P_PONER_CAPACIDAD_NOMINAL_TRAMO (V_CAPACIDAD_NOMINAL : in Integer;
                                              V_TRAMO : in out T_TRAMO) is

   begin

      V_TRAMO.R_CAPACIDAD_NOMINAL := V_CAPACIDAD_NOMINAL;

   end P_PONER_CAPACIDAD_NOMINAL_TRAMO;
   ---------------------------------------------------------------------

   -----------------------------------------------------------------------
   function F_OBTENER_CARGA_TRAFICO (V_TRAMO : in T_TRAMO) return Float is

   begin

      return V_TRAMO.R_CARGA_TRAFICO;

   end F_OBTENER_CARGA_TRAFICO;
   -----------------------------------------------------------------------

   -------------------------------------------------------------
   procedure P_PONER_CARGA_TRAFICO (V_CARGA_TRAFICO : in Float;
                                    V_TRAMO : in out T_TRAMO) is

   begin

      V_TRAMO.R_CARGA_TRAFICO := V_CARGA_TRAFICO;

   end P_PONER_CARGA_TRAFICO;
   -------------------------------------------------------------

   --------------------------------------------------------------------------
   function F_OBTENER_DISPONIBILIDAD (V_TRAMO : in T_TRAMO) return Boolean is

   begin

      return V_TRAMO.R_DISPONIBLE;

   end F_OBTENER_DISPONIBILIDAD;
   --------------------------------------------------------------------------

   --------------------------------------------------------------
   procedure P_PONER_DISPONIBILIDAD (V_DISPONIBILIDAD : in Boolean;
                                     V_TRAMO : in out T_TRAMO) is

   begin

      V_TRAMO.R_DISPONIBLE := V_DISPONIBILIDAD;

   end P_PONER_DISPONIBILIDAD;
   --------------------------------------------------------------
   
   -------------------------------------------------------------------------------------------------------------
   function F_OBTENER_LISTA_CRUCES (V_TRAMO_ACTUAL : in T_TRAMO;
                                    V_CARRIL_ACTUAL : in Natural;
                                    V_TRAMO_SIGUIENTE_ID : in Natural;
                                    V_CARRIL_SIGUIENTE : in Natural) return Q_CONEXION.Q_LISTA_CRUCES.T_LISTA is
      
      V_LISTA_CRUCES : Q_CONEXION.Q_LISTA_CRUCES.T_LISTA;
      
      V_LISTA_CONEXIONES : Q_LISTA_CONEXIONES.T_LISTA := Q_TRAMO.F_OBTENER_LISTA_CONEXIONES (V_TRAMO_ACTUAL);
      
      V_CONEXION : Q_CONEXION.T_CONEXION;
     
   begin
      
      -- Inicializar lista de cruces y conexion.
      Q_CONEXION.Q_LISTA_CRUCES.P_INICIALIZAR_LISTA (V_LISTA_CRUCES);
      Q_CONEXION.P_INICIALIZAR_CONEXION (V_CONEXION);
      
      -- Recorrer la lista de conexiones del tramo actual.
      for I in 1 .. Q_LISTA_CONEXIONES.F_CUANTOS_ELEMENTOS (V_LISTA_CONEXIONES) loop
         
         V_CONEXION := Q_LISTA_CONEXIONES.F_DEVOLVER_ELEMENTO (V_POSICION => I,
                                                               V_LISTA    => V_LISTA_CONEXIONES);
         
         if V_TRAMO_SIGUIENTE_ID = Q_CONEXION.F_OBTENER_TRAMO_ID (V_CONEXION) and
            V_CARRIL_ACTUAL = Q_CONEXION.F_OBTENER_CARRIL_ACTUAL (V_CONEXION) and
            V_CARRIL_SIGUIENTE = Q_CONEXION.F_OBTENER_CARRIL_SIGUIENTE (V_CONEXION)
         then
         
            -- Estamos en una conexion que une el tramo actual con el tramo siguiente a trav�s del carril actual con el carril siguiente.
            -- Obtener la lista de cruces.
            V_LISTA_CRUCES := Q_CONEXION.F_OBTENER_LISTA_CRUCES (V_CONEXION);
            
         end if;
         
         
      end loop;
      
      return V_LISTA_CRUCES;
      
   end F_OBTENER_LISTA_CRUCES;
   -------------------------------------------------------------------------------------------------------------

end Q_TRAMO;
--------------------------------------------------------------------------------------------------------------------------------------------
