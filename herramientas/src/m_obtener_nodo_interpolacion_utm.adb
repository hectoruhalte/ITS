-------------------------------------------------------------------------------------------------------------------------------------------
--
--      Fichero:        m_obtener_nodo_interpolacion_utm.adb
--
--      Autor:          Hector Uhalte Bilbao
--
--      Fecha:          18/10/2021
--
-------------------------------------------------------------------------------------------------------------------------------------------

with Q_TIPOS_BASICOS;
with GNAT.Command_Line;
with Ada.Text_IO;

procedure m_obtener_nodo_interpolacion_utm is

   V_NODO_ORIGEN_UTM, V_NODO_FINAL_UTM : Q_TIPOS_BASICOS.T_POSICION_UTM;
   
   V_POSICION, V_DISTANCIA, V_NUMERO_INTERVALOS : Natural := 0;
   
   V_DISTANCIA_INTERVALO, V_DELTA_X, V_DELTA_Y : Float := 0.0;
   
   V_X_NODO, V_Y_NODO, V_X_NODO_FINAL, V_Y_NODO_FINAL : Integer := 0;
   
begin
   
   V_X_NODO := Integer'Value(GNAT.Command_Line.Get_Argument);
   V_Y_NODO := Integer'Value(GNAT.Command_Line.Get_Argument);
   
   V_NODO_ORIGEN_UTM := Q_TIPOS_BASICOS.F_OBTENER_POSICION_UTM (V_X => V_X_NODO,
                                                                V_Y => V_Y_NODO);
   
   V_X_NODO_FINAL := Integer'Value(GNAT.Command_Line.Get_Argument);
   V_Y_NODO_FINAL := Integer'Value(GNAT.Command_Line.Get_Argument);
   
   V_NODO_FINAL_UTM := Q_TIPOS_BASICOS.F_OBTENER_POSICION_UTM (V_X => V_X_NODO_FINAL,
                                                               V_Y => V_Y_NODO_FINAL);
   
   V_POSICION := Natural'Value(GNAT.Command_Line.Get_Argument);
   
   V_DISTANCIA := Q_TIPOS_BASICOS.F_OBTENER_DISTANCIA (V_POSICION_1 => V_NODO_ORIGEN_UTM,
                                                       V_POSICION_2 => V_NODO_FINAL_UTM);
   
   V_NUMERO_INTERVALOS := Natural(Float'Rounding(Float(V_DISTANCIA)/5.0));
   
   V_DELTA_X := 
     Float(Q_TIPOS_BASICOS.F_OBTENER_COORDENADA_X (V_NODO_FINAL_UTM) - Q_TIPOS_BASICOS.F_OBTENER_COORDENADA_X (V_NODO_ORIGEN_UTM)) / 
       Float(V_NUMERO_INTERVALOS);
   
   V_DELTA_Y := 
     Float(Q_TIPOS_BASICOS.F_OBTENER_COORDENADA_Y (V_NODO_FINAL_UTM) - Q_TIPOS_BASICOS.F_OBTENER_COORDENADA_Y (V_NODO_ORIGEN_UTM)) / 
       Float(V_NUMERO_INTERVALOS);
   
   V_X_NODO := Integer(Float'Rounding(Float(Q_TIPOS_BASICOS.F_OBTENER_COORDENADA_X (V_NODO_ORIGEN_UTM)) + Float(V_POSICION)*V_DELTA_X));
   V_Y_NODO := Integer(Float'Rounding(Float(Q_TIPOS_BASICOS.F_OBTENER_COORDENADA_Y (V_NODO_ORIGEN_UTM)) + Float(V_POSICION)*V_DELTA_Y));
   
   Ada.Text_IO.Put_Line (Integer'Image(V_X_NODO) & " " & Integer'Image(V_Y_NODO));
   
end m_obtener_nodo_interpolacion_utm;
-------------------------------------------------------------------------------------------------------------------------------------------
