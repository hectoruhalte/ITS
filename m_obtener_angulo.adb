-------------------------------------------------------------------------------------------------------------------------------------------
--
--      Fichero:        m_obtener_angulo.adb
--
--      Autor:          Hector Uhalte Bilbao
--
--      Fecha:          7/10/2021
--
-------------------------------------------------------------------------------------------------------------------------------------------

with Ada.Numerics.Generic_Elementary_Functions;
with GNAT.Command_Line;
with Ada.Text_IO;

procedure m_obtener_angulo is

   package Q_MATH is new ADA.NUMERICS.GENERIC_ELEMENTARY_FUNCTIONS (Float_Type => Float);
   
   V_X_1, V_X_2, V_Y_1, V_Y_2, V_DELTA_X, V_DELTA_Y : Integer := 0;
   V_DISTANCIA, V_ANGULO : Float := 0.0;
   
begin
   
   V_X_1 := Integer'Value(GNAT.Command_Line.Get_Argument);
   V_Y_1 := Integer'Value(GNAT.Command_Line.Get_Argument);
   V_X_2 := Integer'Value(GNAT.Command_Line.Get_Argument);
   V_Y_2 := Integer'Value(GNAT.Command_Line.Get_Argument);
   
   V_DELTA_X := V_X_2 - V_X_1;
   V_DELTA_Y := V_Y_2 - V_Y_1;
   
   V_DISTANCIA := Q_MATH.Sqrt (Float(V_DELTA_X**2) + Float(V_DELTA_Y**2));
   
   V_ANGULO := Q_MATH.Arctan (Y => Float(V_DELTA_Y) / V_DISTANCIA,
                              X => Float(V_DELTA_X) / V_DISTANCIA);
   
   Ada.Text_IO.Put_Line (Float'Image(V_ANGULO));
   
end m_obtener_angulo;
-------------------------------------------------------------------------------------------------------------------------------------------
