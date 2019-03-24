--------------------------------------------------------------------------------------------------------------------------------------------
--
--      Fichero:        q_adaptacion_tramo.ads
--
--      Autor:          Hector Uhalte Bilbao
--
--      Fecha:          15/1/2018
--      
--------------------------------------------------------------------------------------------------------------------------------------------

-- Este paquete se va a usar para cargar en una tabla los tramos guardados en el fichero tramos.xml

with Q_GENERICO_LISTA;
with Q_CARRIL;
with Q_SEGMENTO;
with Q_TRAMO;
with Q_TIPOS_BASICOS;

package Q_ADAPTACION_TRAMO is

	package Q_LISTA_TRAMOS is new Q_GENERICO_LISTA (T_ELEMENTO => Q_TRAMO.T_TRAMO,
							"=" => Q_TRAMO."=",
							V_MAXIMO_NUMERO_ELEMENTOS => Q_TRAMO.F_OBTENER_NUMERO_MAXIMO_TRAMOS);

	type T_SEGMENTO_ADAPTACION is private;

	type T_TRAMO_ADAPTACION is private;

	type T_TRAMO_ADAPTACION_REGISTRO is private;

	-- Procedimiento para escribir el fichero "tramos.bin". tramos.xml -> tramos.bin
	procedure P_CARGAR_ADAPTACION;

	-- Procedimiento para leer la adaptacion. Devuelve un registro (array mas numero de elementos) de los tramos guardados en tramos.bin
	-- tramos.bin -> Registro de adaptacion.
	procedure P_LEER_ADAPTACION (V_TRAMO_ADAPTACION_REGISTRO : out T_TRAMO_ADAPTACION_REGISTRO);

	-- Procedimiento para generar la lista de tramos a partir del registro de adaptacion.
	-- Registro de adaptación -> Lista de tramos (incluyendo los elementos no incluidos en la adaptacion, p ej: Carga de tráfico)
	procedure P_GENERAR_LISTA_TRAMOS (V_LISTA_TRAMOS : out Q_LISTA_TRAMOS.T_LISTA);

	-- Procedimiento para visualizar el fichero "tramos.bin"
	procedure P_VISUALIZAR;

	private

		type T_SEGMENTO_ADAPTACION is record

			R_POSICION : Q_TIPOS_BASICOS.T_POSICION_LAT_LON;

			R_DOBLE_SENTIDO : Boolean := False;

			R_NUMERO_CARRILES : Integer range 1 .. Q_CARRIL.F_OBTENER_NUMERO_MAXIMO_CARRILES := 1;

		end record;

		type T_SEGMENTOS_ADAPTACION_ARRAY is array (1 .. Q_SEGMENTO.F_OBTENER_NUMERO_MAXIMO_SEGMENTOS) of T_SEGMENTO_ADAPTACION;

		type T_SEGMENTO_ADAPTACION_REGISTRO is record

			R_NUMERO_SEGMENTOS : Integer range 0 .. Q_SEGMENTO.F_OBTENER_NUMERO_MAXIMO_SEGMENTOS := 0;

			R_SEGMENTOS_ADAPTACION_ARRAY : T_SEGMENTOS_ADAPTACION_ARRAY;

		end record;

		type T_CONEXION_ADAPTACION_REGISTRO is record

			R_NUMERO_CONEXIONES : Integer range 0 .. Q_TRAMO.C_NUMERO_MAXIMO_CONEXIONES := 0;

			R_CONEXIONES_ADAPTACION_ARRAY : Q_TRAMO.T_ARRAY_CONEXIONES;
	
		end record;
		
		type T_TRAMO_ADAPTACION is record

			-- Id del tramo adaptado. 
			R_ID : Integer range 1 .. Q_TRAMO.F_OBTENER_NUMERO_MAXIMO_TRAMOS := 1;

			-- Nombre del tramo adaptado.
			R_NOMBRE_TRAMO : 
				String (1 .. Q_TRAMO.F_OBTENER_LONGITUD_MAXIMA_NOMBRE_TRAMO) := Q_TRAMO.F_OBTENER_NOMBRE_TRAMO_VACIO;

			R_COMIENZO : Q_TIPOS_BASICOS.T_POSICION_LAT_LON;

			R_FINAL : Q_TIPOS_BASICOS.T_POSICION_LAT_LON;

			R_ALTURA : Float range 0.0 .. Q_TRAMO.F_OBTENER_ALTURA_MAXIMA;

			R_VELOCIDAD_MAXIMA : Q_TIPOS_BASICOS.T_VELOCIDAD;

			R_LISTA_SEGMENTOS : T_SEGMENTO_ADAPTACION_REGISTRO;

			R_LISTA_CONEXIONES : T_CONEXION_ADAPTACION_REGISTRO;

		end record;

		type T_TRAMO_ADAPTACION_ARRAY is array (1 .. Q_TRAMO.F_OBTENER_NUMERO_MAXIMO_TRAMOS) of T_TRAMO_ADAPTACION;

		type T_TRAMO_ADAPTACION_REGISTRO is record

                        R_NUMERO_TRAMOS : Integer range 0 .. Q_TRAMO.F_OBTENER_NUMERO_MAXIMO_TRAMOS;

                        R_TRAMO_ADAPTACION_ARRAY : T_TRAMO_ADAPTACION_ARRAY;

                end record;

end Q_ADAPTACION_TRAMO;
-----------------------
