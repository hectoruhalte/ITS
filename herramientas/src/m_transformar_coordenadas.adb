-------------------------------------------------------------------------------------------------------------------------------------------
--
--      Fichero:        m_transformar_coordenadas.adb
--
--      Autor:          Hector Uhalte Bilbao
--
--      Fecha:          6/10/2021
--
-------------------------------------------------------------------------------------------------------------------------------------------

with Q_TIPOS_BASICOS;
with Ada.Text_IO;
with GNAT.Command_Line;

procedure m_transformar_coordenadas is
   
   V_LATITUD, V_LONGITUD : Float := 0.0;
   
   V_POSICION_LAT_LON : Q_TIPOS_BASICOS.T_POSICION_LAT_LON;
   
   V_POSICION_UTM : Q_TIPOS_BASICOS.T_POSICION_UTM;
   
begin
   
   V_LATITUD := Float'Value(GNAT.Command_Line.Get_Argument);
   V_LONGITUD := Float'Value(GNAT.Command_Line.Get_Argument);
   
   V_POSICION_LAT_LON := Q_TIPOS_BASICOS.F_OBTENER_POSICION_LAT_LON (V_LATITUD  => V_LATITUD,
                                                                     V_LONGITUD => V_LONGITUD);
   
   V_POSICION_UTM := Q_TIPOS_BASICOS.F_TRANSFORMAR_LAT_LON_A_UTM (V_POSICION_LAT_LON);
   
   Ada.Text_IO.Put_Line
     (Integer'Image(Q_TIPOS_BASICOS.F_OBTENER_COORDENADA_X(V_POSICION_UTM)) & 
      " " & Integer'Image(Q_TIPOS_BASICOS.F_OBTENER_COORDENADA_Y(V_POSICION_UTM)));
   
end m_transformar_coordenadas;
-------------------------------------------------------------------------------------------------------------------------------------------
