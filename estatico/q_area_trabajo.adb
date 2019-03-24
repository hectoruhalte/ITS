--------------------------------------------------------------------------------------------------------------------------------------------
--
--      Fichero:        q_area_trabajo.adb
--
--      Autor:          Hector Uhalte Bilbao
--
--      Fecha:          28/4/2018
--      
--------------------------------------------------------------------------------------------------------------------------------------------

with Q_ADAPTACION_AREA_TRABAJO;
with Ada.Numerics.Discrete_Random;

package body Q_AREA_TRABAJO is

	---------------------------------------------------------
	function F_GENERAR_COORDENADA_ALEATORIA (V_MINIMO : in Integer;
						 V_MAXIMO : in Integer) return Integer is

		subtype T_RANGO_COORDENADAS is Integer range V_MINIMO .. V_MAXIMO;

		package Q_RANDOM_COORDENADAS is new Ada.Numerics.Discrete_Random (T_RANGO_COORDENADAS);

		V_SEMILLA_COORDENADAS : Q_RANDOM_COORDENADAS.Generator;

	begin

		Q_RANDOM_COORDENADAS.Reset (V_SEMILLA_COORDENADAS);

		return Q_RANDOM_COORDENADAS.Random (V_SEMILLA_COORDENADAS);

	end F_GENERAR_COORDENADA_ALEATORIA;
	---------------------------------------------------------

	----------------------------------------------------------------------------------
	function F_OBTENER_COORDENADAS_ALEATORIAS return Q_TIPOS_BASICOS.T_POSICION_UTM is

		V_ESQUINA_INFERIOR_IZQUIERDA, V_ESQUINA_SUPERIOR_DERECHA : Q_TIPOS_BASICOS.T_POSICION_UTM;

		V_X_MINIMA, V_X_MAXIMA, V_Y_MINIMA, V_Y_MAXIMA, V_X_ALEATORIA, V_Y_ALEATORIA : Integer;

	begin

		-- Obtener esquina inferior izquierda del area de trabajo => Latitud minima, Longitud minima.
		-- Obtener esquina superior derecha del area de trabajo => Latitud maxima, Longotud maxima.
		-- Convertir a coordenadas UTM.
		V_ESQUINA_INFERIOR_IZQUIERDA := Q_TIPOS_BASICOS.F_TRANSFORMAR_LAT_LON_A_UTM 
							(Q_TIPOS_BASICOS.F_OBTENER_POSICION_LAT_LON 
								(V_LATITUD => Q_ADAPTACION_AREA_TRABAJO.F_OBTENER_LATITUD_MINIMA,
								 V_LONGITUD => Q_ADAPTACION_AREA_TRABAJO.F_OBTENER_LONGITUD_MINIMA));

		V_ESQUINA_SUPERIOR_DERECHA := Q_TIPOS_BASICOS.F_TRANSFORMAR_LAT_LON_A_UTM
						(Q_TIPOS_BASICOS.F_OBTENER_POSICION_LAT_LON
							(V_LATITUD => Q_ADAPTACION_AREA_TRABAJO.F_OBTENER_LATITUD_MAXIMA,
							 V_LONGITUD => Q_ADAPTACION_AREA_TRABAJO.F_OBTENER_LONGITUD_MAXIMA));

		V_X_MINIMA := Q_TIPOS_BASICOS.F_OBTENER_COORDENADA_X (V_ESQUINA_INFERIOR_IZQUIERDA);
		
		V_X_MAXIMA := Q_TIPOS_BASICOS.F_OBTENER_COORDENADA_X (V_ESQUINA_SUPERIOR_DERECHA);

		V_Y_MINIMA := Q_TIPOS_BASICOS.F_OBTENER_COORDENADA_Y (V_ESQUINA_INFERIOR_IZQUIERDA);

		V_Y_MAXIMA := Q_TIPOS_BASICOS.F_OBTENER_COORDENADA_Y (V_ESQUINA_SUPERIOR_DERECHA);

		V_X_ALEATORIA := F_GENERAR_COORDENADA_ALEATORIA (V_MINIMO => V_X_MINIMA,
								 V_MAXIMO => V_X_MAXIMA);

		V_Y_ALEATORIA := F_GENERAR_COORDENADA_ALEATORIA (V_MINIMO => V_Y_MINIMA,
								 V_MAXIMO => V_Y_MAXIMA);

		return Q_TIPOS_BASICOS.F_OBTENER_POSICION_UTM (V_X => V_X_ALEATORIA,
							       V_Y => V_Y_ALEATORIA);						

	end F_OBTENER_COORDENADAS_ALEATORIAS;
	----------------------------------------------------------------------------------

end Q_AREA_TRABAJO;
-------------------------------------------------------------------------------------------------------------------------------------------

