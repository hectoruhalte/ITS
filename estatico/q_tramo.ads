--------------------------------------------------------------------------------------------------------------------------------------------
--
--      Fichero:        q_tramo.ads
--
--      Autor:          Hector Uhalte Bilbao
--
--      Fecha:          2/10/2017
--      
--------------------------------------------------------------------------------------------------------------------------------------------

with Q_GENERICO_LISTA;
with Q_SEGMENTO;
with Q_TIPOS_BASICOS;
with Ada.Characters.Latin_1;

-- Este paquete presenta el tipo T_TRAMO, donde se van a definir todos los atributos propios de los tramos de carretera.
-- Va a servir para el simulador. No va a ver definiciones "raras". Los tramos de carretera se van a usar como hasta ahora.
-- Se incluira la carga, porque si se podra balancear el trafico en tiempo real, pero no se podran usar carriles en sentido contrario.
-- Solo esto ya es una mejora del sistema actual, pero se queda a medio camino.
-- Se definira otro paquete para los tramos que incluira todas las mejoras.

package Q_TRAMO is

	package Q_LISTA_SEGMENTOS is new Q_GENERICO_LISTA (T_ELEMENTO => Q_SEGMENTO.T_SEGMENTO,
							   "=" => Q_SEGMENTO."=",
							   V_MAXIMO_NUMERO_ELEMENTOS => Q_SEGMENTO.F_OBTENER_NUMERO_MAXIMO_SEGMENTOS);

	-- Funcion necesaria para instanciar el paquete Q_GENERICO_LISTA para crear listas de conexiones.
        function F_IGUALDAD_CONEXIONES (V_INTEGER_1 : in Integer;
                      			V_INTEGER_2 : in Integer) return Boolean;

	-- Constante para definir el numero maximo de conexiones entre tramos.
        C_NUMERO_MAXIMO_CONEXIONES : constant Integer := 8;

	package Q_LISTA_CONEXIONES is new Q_GENERICO_LISTA (T_ELEMENTO => Integer,
							    "=" => F_IGUALDAD_CONEXIONES,
	 						    V_MAXIMO_NUMERO_ELEMENTOS => C_NUMERO_MAXIMO_CONEXIONES);

	type T_ARRAY_SEGMENTOS is array (1 .. Q_SEGMENTO.F_OBTENER_NUMERO_MAXIMO_SEGMENTOS) of Q_SEGMENTO.T_SEGMENTO;

	type T_ARRAY_CONEXIONES is array (1 .. C_NUMERO_MAXIMO_CONEXIONES) of Positive;

	type T_TRAMO is private;

	-- Funcion necesaria para instanciar el paquete Q_GENERICO_LISTA para crear listas de tramos.
	function "=" (V_TRAMO_1 : T_TRAMO;
		      V_TRAMO_2 : T_TRAMO) return Boolean;

	function F_OBTENER_NUMERO_MAXIMO_TRAMOS return Integer;

	function F_OBTENER_LONGITUD_MAXIMA_NOMBRE_TRAMO return Integer;

	function F_OBTENER_NOMBRE_TRAMO_VACIO return String;
	
	function F_OBTENER_ALTURA_MAXIMA return Float;

	procedure P_INICIALIZAR_TRAMO (V_TRAMO : in out T_TRAMO);

	function F_OBTENER_ID (V_TRAMO : in T_TRAMO) return Integer;

	procedure P_PONER_ID (V_ID : in Integer;
			      V_TRAMO : in out T_TRAMO);

	function F_OBTENER_NOMBRE (V_TRAMO : in T_TRAMO) return String;

	procedure P_PONER_NOMBRE (V_NOMBRE : in String;
			          V_TRAMO : in out T_TRAMO);

	function F_OBTENER_ORIGEN (V_TRAMO : in T_TRAMO) return Q_TIPOS_BASICOS.T_POSICION_UTM;

	procedure P_PONER_ORIGEN (V_ORIGEN : in Q_TIPOS_BASICOS.T_POSICION_UTM;
				  V_TRAMO : in out T_TRAMO);

	function F_OBTENER_FINAL (V_TRAMO : in T_TRAMO) return Q_TIPOS_BASICOS.T_POSICION_UTM;

	procedure P_PONER_FINAL (V_FINAL : in Q_TIPOS_BASICOS.T_POSICION_UTM;
				 V_TRAMO : in out T_TRAMO);

	function F_OBTENER_ALTURA (V_TRAMO : in T_TRAMO) return Float;

	procedure P_PONER_ALTURA (V_ALTURA : in Float;
				  V_TRAMO : in out T_TRAMO);

	function F_OBTENER_VELOCIDAD_MAXIMA (V_TRAMO : in T_TRAMO) return Q_TIPOS_BASICOS.T_VELOCIDAD;

	procedure P_PONER_VELOCIDAD_MAXIMA (V_VELOCIDAD_MAXIMA : in Q_TIPOS_BASICOS.T_VELOCIDAD;
					    V_TRAMO : in out T_TRAMO);

	function F_OBTENER_LISTA_SEGMENTOS (V_TRAMO : in T_TRAMO) return Q_LISTA_SEGMENTOS.T_LISTA;

	procedure P_PONER_LISTA_SEGMENTOS (V_NUMERO_SEGMENTOS : in Integer;
					   V_ARRAY_SEGMENTOS : in T_ARRAY_SEGMENTOS;
					   V_TRAMO : in out T_TRAMO);

	function F_OBTENER_LISTA_CONEXIONES (V_TRAMO : in T_TRAMO) return Q_LISTA_CONEXIONES.T_LISTA;

	procedure P_PONER_LISTA_CONEXIONES (V_NUMERO_CONEXIONES : in Integer;
					    V_ARRAY_CONEXIONES : in T_ARRAY_CONEXIONES;
					    V_TRAMO : in out T_TRAMO);

	function F_OBTENER_TIEMPO_TRAMO (V_TRAMO : in T_TRAMO) return Integer;

	procedure P_PONER_TIEMPO_TRAMO (V_TIEMPO_TRAMO : in Integer;
					V_TRAMO : in out T_TRAMO);

	function F_OBTENER_DISTANCIA_TRAMO (V_TRAMO : in T_TRAMO) return Integer;

	procedure P_PONER_DISTANCIA_TRAMO (V_DISTANCIA : in Integer;
					   V_TRAMO : in out T_TRAMO);

	function F_OBTENER_CAPACIDAD_MAXIMA_TRAMO (V_TRAMO : in T_TRAMO) return Integer;

	procedure P_PONER_CAPACIDAD_MAXIMA_TRAMO (V_CAPACIDAD_MAXIMA : in Integer;
					          V_TRAMO : in out T_TRAMO);

	function F_OBTENER_CAPACIDAD_NOMINAL_TRAMO (V_TRAMO : in T_TRAMO) return Integer;

        procedure P_PONER_CAPACIDAD_NOMINAL_TRAMO (V_CAPACIDAD_NOMINAL : in Integer;
                                                   V_TRAMO : in out T_TRAMO);

	function F_OBTENER_CARGA_TRAFICO (V_TRAMO : in T_TRAMO) return Float;

	procedure P_PONER_CARGA_TRAFICO (V_CARGA_TRAFICO : in Float;
					 V_TRAMO : in out T_TRAMO);

	function F_OBTENER_DISPONIBILIDAD (V_TRAMO : in T_TRAMO) return Boolean;

	procedure P_PONER_DISPONIBILIDAD (V_DISPONIBILIDAD : in Boolean;
				          V_TRAMO : in out T_TRAMO);

	private

		-- Constante para definir el numero maximo de tramos.
        	C_NUMERO_MAXIMO_TRAMOS : constant Integer := 512;
	
		-- Constante para definir la longitud maxima del nombre del tramo.
		C_LONGITUD_MAXIMA_NOMBRE_TRAMO : constant Natural := 32;
		
		-- Constante para definir el valo maxima a dar a la altura de un tramo.
		-- Cuando el tramo tenga una altura de 10.0 significara que no esta limitado en altura.
		C_ALTURA_MAXIMA : constant Float := 10.0;

		-- Strings vacios para el nombre del tramo.
                C_NOMBRE_TRAMO_VACIO : constant String (1 .. C_LONGITUD_MAXIMA_NOMBRE_TRAMO) := (others => ADA.CHARACTERS.Latin_1.SPACE);

		type T_TRAMO is record

			-- Id de cada tramo para su identificacion univoca.
			-- Dato obtenido por adaptacion.
			R_ID : Integer range 0 .. C_NUMERO_MAXIMO_TRAMOS := 1;

			-- Nombre del tramo
			R_NOMBRE : String (1 .. C_LONGITUD_MAXIMA_NOMBRE_TRAMO);

			-- Posicion de origen del tramo.
			-- Dato obtenido por adaptacion.
			R_ORIGEN : Q_TIPOS_BASICOS.T_POSICION_UTM;

			-- Posicion de final del tramo.
			-- Dato obtenido por adaptacion.
			R_FINAL : Q_TIPOS_BASICOS.T_POSICION_UTM;
			
			-- Limite de altura del tramo. Pensado para tramos con pasos por los que pasen puentes, o tramos tunel.
			-- Solo vehiculos con altura inferior a este valor podran circular por el tramo.
			-- Una altura igual al maximo posible se interpretara como que no hay limite de altura para ningun vehiculo.
			-- De momento no se tiene en cuenta la anchura de carriles o segmento como limite de galibo, solo altura.
			-- Dato obtenido por adaptacion.
			R_ALTURA : Float range 0.0 .. C_ALTURA_MAXIMA := 0.0;

			-- Velocidad del tramo. Por cada tramo solo puede haber una velocidad. Si hay diferentes velocidades => diferentes
			-- tramos
			-- Dato obtenido por adaptacion.
			R_VELOCIDAD_MAXIMA : Q_TIPOS_BASICOS.T_VELOCIDAD := 0;

			-- Dato obtenido por adaptacion.
			R_SEGMENTOS : Q_LISTA_SEGMENTOS.T_LISTA;

			-- Conexiones entre un tramo y otros.
			-- Dato obtenido por adaptacion.
			R_CONEXIONES : Q_LISTA_CONEXIONES.T_LISTA;

			-- Factor para el calculo de trayectorias. Dependiendo de la longitud y de la velocidad del tramo.
                        -- Se puede ver como el tiempo que se tarda a la velocidad maxima permitida en circular por dicho tramo.
                        -- Expresado en segundos. Maximo valor 1 hora.
                        R_TIEMPO_TRAMO : Integer range 0 .. 3600;

			-- Factor para el calculo de trayectorias. Expresado en metros.
			R_DISTANCIA_TRAMO : Integer range 0 .. 1000;

			-- Capacidad del maxima del tramo. Numero de segmentos del tramo x numero carriles.
			R_CAPACIDAD_MAXIMA : Integer range 0 .. 1000;

			-- Capacidad del tramo. Cuantos vehiculos caben en el tramo circulando a velocidad maxima.
			R_CAPACIDAD_NOMINAL : Integer range 0 .. 1000;

                        -- Carga de trafico que soporta el tramo por minuto ... hora .... Expresado en porcentaje.
                        -- Este dato se actualizara en tiempo real.
                        -- Para dicho calculo hay que tener en cuenta dos aspectos:
			--
			-- 1.- La velocidad media de los vehiculos en el tramo en un momento dado. 
			--
			--     	Si la velocidad media de los coches es igual o superior a la velocidad maxima => Carga es 0.
			-- 	Concepto de tren. No me importa el numero de vehiculos que haya en el tramo si todos van a al menos la
			--	velocidad maxima.
			--
			--	Si la velocidad media de los vehiculos no es igual a la velocidad maxima => Carga > 0.
			--	Entonces si es relevante el numero de vehiculos que haya en el tramo => Pocos vehiculos => Carga relativa 
			--	baja. Muchos vehiculos (el maximo sera la capacidad maxima) => Carga relativa mas alta.
			--
			--	Carga = (Vel media / Vel maxima) / (Capacidad nominal / Num vehiculos)
			--
			-- 2.- Para el calculo de la carga en un tiempo futuro se tendra solo en cuenta el numero de vehiculos que pasen
			-- 	por el tramo durante un periodo de tiempo en relacion a la capcidad nominal.
			--
			--	Carga = (Num vehiculos / (Periodo de tiempo (seg) * Numero de vehiculos / seg))
			--		Numero de vehiculos / seg = Velocidad maxima (m/s) / Distancia seguridad * num_min_carriles 
			R_CARGA_TRAFICO : Float range 0.0 .. 1.0;
			
			-- Para saber un tramo esta abierto o no a la circulacion.
                        -- Si esta cerrado, no haria falta bajar al nivel de los segmentos para saber si hay alguno no disponible para 
			-- dar el tramo por cerrado.
                        -- Por defecto estara disponible 
			R_DISPONIBLE : Boolean := True;

		end record;

end Q_TRAMO;
------------
