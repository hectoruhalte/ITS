--------------------------------------------------------------------------------------------------------------------------------------------
--
--      Fichero:        m_prueba_tipos_basicos.adb 
--
--      Autor:          Hector Uhalte Bilbao
--
--      Fecha:          7/9/2017
--      
--------------------------------------------------------------------------------------------------------------------------------------------

with ADA.TEXT_IO;
with Q_TIPOS_BASICOS;
with Q_LOG;

procedure m_prueba_tipos_basicos is

	C_PUNTO_TANGENCIA : constant Q_TIPOS_BASICOS.T_POSICION_LAT_LON := 
		Q_TIPOS_BASICOS.F_OBTENER_POSICION_LAT_LON (V_LATITUD => 43.461245,
							    V_LONGITUD => -3.8184800);

	V_PUNTO_2 : Q_TIPOS_BASICOS.T_POSICION_LAT_LON := Q_TIPOS_BASICOS.F_OBTENER_POSICION_LAT_LON (V_LATITUD => 43.4612562,
												      V_LONGITUD => -3.8184321);

	V_POSICION : Q_TIPOS_BASICOS.T_POSICION_UTM;
	
	V_VELOCIDAD : Q_TIPOS_BASICOS.T_VELOCIDAD := Q_TIPOS_BASICOS.C_VELOCIDAD_MINIMA;
begin

	V_POSICION := Q_TIPOS_BASICOS.F_OBTENER_POSICION_UTM(V_X => 1000,
							     V_Y => 1000);

	ADA.TEXT_IO.PUT_LINE("La coordenada X = 1000 y la Y = 1000");

	--V_POSICION := Q_TIPOS_BASICOS.F_OBTENER_POSICION_UTM(V_X => 10_000_000.0,
	-- 						     V_Y => 75_000_000.0);

	V_VELOCIDAD := 120;

	ADA.TEXT_IO.PUT_LINE("La velocidad es" & Integer'Image(V_VELOCIDAD));

	ADA.TEXT_IO.PUT_LINE
		("La coordenada X UTM del punto de tangencia es : " & 
		Integer'Image(Q_TIPOS_BASICOS.F_OBTENER_COORDENADA_X(Q_TIPOS_BASICOS.F_TRANSFORMAR_LAT_LON_A_UTM(C_PUNTO_TANGENCIA))));

	Ada.Text_Io.Put_Line
		("La coordenada Y UTM del punto de tangencia es : " &
                Integer'Image(Q_TIPOS_BASICOS.F_OBTENER_COORDENADA_Y(Q_TIPOS_BASICOS.F_TRANSFORMAR_LAT_LON_A_UTM(C_PUNTO_TANGENCIA))));

	Ada.Text_Io.Put_Line
		("La distancia entre los dos puntos es : " & 
			Integer'Image(Q_TIPOS_BASICOS.F_OBTENER_DISTANCIA 
							(V_POSICION_1 => Q_TIPOS_BASICOS.F_TRANSFORMAR_LAT_LON_A_UTM(C_PUNTO_TANGENCIA),
							 V_POSICION_2 => Q_TIPOS_BASICOS.F_TRANSFORMAR_LAT_LON_A_UTM(V_PUNTO_2))) &			     " metros");

	V_POSICION := Q_TIPOS_BASICOS.F_TRANSFORMAR_LAT_LON_A_UTM (V_PUNTO_2);

	Ada.Text_Io.Put_Line
		("Coordenada X respecto a Punto tangencia del punto dado : " & 
			Integer'Image(Q_TIPOS_BASICOS.F_OBTENER_COORDENADA_X(Q_TIPOS_BASICOS.F_OBTENER_REF_X_Y(V_POSICION))));

	Ada.Text_Io.Put_Line
                ("Coordenada Y respecto a Punto tangencia del punto dado : " &
                        Integer'Image(Q_TIPOS_BASICOS.F_OBTENER_COORDENADA_Y(Q_TIPOS_BASICOS.F_OBTENER_REF_X_Y(V_POSICION))));

exception

	when Q_TIPOS_BASICOS.X_COORDENADAS_FUERA_DE_RANGO =>

		Q_LOG.P_ESCRIBIR_LOG(V_STRING => "Coordenadas fuera de rango",
				     V_NOMBRE_FICHERO => "/home/hector/ITS/log/coordenadas.log");

	when Q_TIPOS_BASICOS.X_VELOCIDAD_FUERA_DE_RANGO =>

		Q_LOG.P_ESCRIBIR_LOG (V_STRING => "Velocidad fuera de rango",
				      V_NOMBRE_FICHERO => "/home/hector/ITS/log/velocidad.log");

end m_prueba_tipos_basicos;
---------------------------
