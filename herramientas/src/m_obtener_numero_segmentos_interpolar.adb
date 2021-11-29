-------------------------------------------------------------------------------------------------------------------------------------------
--
--      Fichero:        m_obtener_numero_segmentos_interpolar.adb
--
--      Autor:          Hector Uhalte Bilbao
--
--      Fecha:          13/10/2021
--
-------------------------------------------------------------------------------------------------------------------------------------------

with Q_TIPOS_BASICOS;
with GNAT.Command_Line;
with Ada.Text_IO;

procedure m_obtener_numero_segmentos_interpolar is

   V_POSICION_LAT_LON_1, V_POSICION_LAT_LON_2 : Q_TIPOS_BASICOS.T_POSICION_LAT_LON;
   
   V_POSICION_UTM_1, V_POSICION_UTM_2 : Q_TIPOS_BASICOS.T_POSICION_UTM;
   
   V_DISTANCIA, V_NUMERO_SEGMENTOS_INTERPOLAR : Natural := 0;

begin
   
   V_POSICION_LAT_LON_1 := Q_TIPOS_BASICOS.F_OBTENER_POSICION_LAT_LON (V_LATITUD  => Float'Value(GNAT.Command_Line.Get_Argument),
                                                                       V_LONGITUD => Float'Value(GNAT.Command_Line.Get_Argument));
   
   V_POSICION_LAT_LON_2 := Q_TIPOS_BASICOS.F_OBTENER_POSICION_LAT_LON (V_LATITUD  => Float'Value(GNAT.Command_Line.Get_Argument),
                                                                       V_LONGITUD => Float'Value(GNAT.Command_Line.Get_Argument));
   
   V_POSICION_UTM_1 := Q_TIPOS_BASICOS.F_TRANSFORMAR_LAT_LON_A_UTM (V_POSICION_LAT_LON_1);
   
   V_POSICION_UTM_2 := Q_TIPOS_BASICOS.F_TRANSFORMAR_LAT_LON_A_UTM (V_POSICION_LAT_LON_2);
   
   V_DISTANCIA := Q_TIPOS_BASICOS.F_OBTENER_DISTANCIA (V_POSICION_1 => V_POSICION_UTM_1,
                                                       V_POSICION_2 => V_POSICION_UTM_2);
   
   V_NUMERO_SEGMENTOS_INTERPOLAR := Natural(Float(V_DISTANCIA) / 5.0) - 1;
   
   Ada.Text_IO.Put_Line (Natural'Image(V_DISTANCIA) & " " & Natural'Image(V_NUMERO_SEGMENTOS_INTERPOLAR));
   
end m_obtener_numero_segmentos_interpolar;
-------------------------------------------------------------------------------------------------------------------------------------------
