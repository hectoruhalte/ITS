-------------------------------------------------------------------------------------------------------------------------------------------
--
--      Fichero:        m_transformar_utm_a_lat_lon.adb
--
--      Autor:          Hector Uhalte Bilbao
--
--      Fecha:          19/10/2021
--
-------------------------------------------------------------------------------------------------------------------------------------------

with GNAT.Command_Line;
with Q_TIPOS_BASICOS;
with Ada.Float_Text_IO;
with Ada.Text_IO;

procedure m_transformar_utm_a_lat_lon is
   
   V_X, V_Y : Integer := 0;
   
   V_POSICION_LAT_LON : Q_TIPOS_BASICOS.T_POSICION_LAT_LON;
   
begin
   
   V_X := Integer'Value(GNAT.Command_Line.Get_Argument);
   V_Y := Integer'Value(GNAT.Command_Line.Get_Argument);
   
   V_POSICION_LAT_LON := Q_TIPOS_BASICOS.F_TRANSFORMAR_UTM_A_LAT_LON (Q_TIPOS_BASICOS.F_OBTENER_POSICION_UTM (V_X => V_X,
                                                                                                              V_Y => V_Y));
   
   Ada.Float_Text_IO.Put (Item => Q_TIPOS_BASICOS.F_OBTENER_LATITUD (V_POSICION_LAT_LON),
                          Fore => 2,
                          Aft  => 7,
                          Exp  => 0);
   
   Ada.Text_IO.Put (" ");
   
   Ada.Float_Text_IO.Put (Item => Q_TIPOS_BASICOS.F_OBTENER_LONGITUD (V_POSICION_LAT_LON),
                          Fore => 1,
                          Aft  => 7,
                          Exp  => 0);
   
   Ada.Text_IO.Put_Line ("");
                                                                      
end m_transformar_utm_a_lat_lon;
-------------------------------------------------------------------------------------------------------------------------------------------
