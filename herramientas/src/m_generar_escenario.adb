-------------------------------------------------------------------------------------------------------------------------------------------
--
--      Fichero:        m_generar_escenario.adb
--
--      Autor:          Hector Uhalte Bilbao
--
--      Fecha:          1/6/2021
--      
--------------------------------------------------------------------------------------------------------------------------------------------

with Ada.Text_IO;
with Ada.Sequential_IO;
with Q_LOG;
with Q_AREA_TRABAJO;
with Q_TIPOS_BASICOS;

procedure m_generar_escenario is
   
   V_NUMERO_RUTAS : Integer := 0;
   
   package Q_POSICION_IO is new Ada.Sequential_IO (Q_TIPOS_BASICOS.T_POSICION_UTM);
   
   V_FICHERO_SALIDAS, V_FICHERO_DESTINOS : Q_POSICION_IO.File_Type;
   
   V_POSICION_SALIDA, V_POSICION_DESTINO : Q_TIPOS_BASICOS.T_POSICION_UTM;
   
begin
  
   Ada.Text_IO.Put_Line (" -- ");
   Ada.Text_IO.Put_Line (" Programa para generar rutas dentro del area de trabajo ");
   Ada.Text_Io.Put_Line (" -- ");
   Ada.Text_IO.Put (" Numero de rutas a generar : ");
   V_NUMERO_RUTAS := Integer'Value(Ada.Text_IO.Get_Line);
   Ada.Text_IO.Put_Line (" -- ");
  
   -- Generar el fichero de salidas del escenaraio.
   Q_POSICION_IO.Create (File => V_FICHERO_SALIDAS,
                         Mode => Q_POSICION_IO.Out_File,
                         Name => "../escenarios/Salidas_" & Q_LOG.F_OBTENER_DATE_STAMP);
   
   -- Generar el fichero de destinos del escenario.
   Q_POSICION_IO.Create (File => V_FICHERO_DESTINOS,
                         Mode => Q_POSICION_IO.Out_File,
                         Name => "../escenarios/Destinos_" & Q_LOG.F_OBTENER_DATE_STAMP);
   
   for I in 1 .. V_NUMERO_RUTAS loop
      
      -- Insertar posiciones aleatorias.
      Q_POSICION_IO.Write (File => V_FICHERO_SALIDAS,
                           Item => Q_AREA_TRABAJO.F_OBTENER_COORDENADAS_ALEATORIAS);
      Q_POSICION_IO.Write (File => V_FICHERO_DESTINOS,
                           Item => Q_AREA_TRABAJO.F_OBTENER_COORDENADAS_ALEATORIAS);
      
   
   end loop;   
      
   Q_POSICION_IO.Close (V_FICHERO_SALIDAS);
   Q_POSICION_IO.Close (V_FICHERO_DESTINOS);
   
   Q_POSICION_IO.Open (File => V_FICHERO_SALIDAS,
                       Mode => Q_POSICION_IO.In_File,
                       Name => "../escenarios/Salidas_" & Q_LOG.F_OBTENER_DATE_STAMP);
   Q_POSICION_IO.Open (File => V_FICHERO_DESTINOS,
                       Mode => Q_POSICION_IO.In_File,
                       Name => "../escenarios/Destinos_" & Q_LOG.F_OBTENER_DATE_STAMP);
   -- Leer los resultados.
   for I in 1 .. V_NUMERO_RUTAS loop
   
      Q_POSICION_IO.Read (File => V_FICHERO_SALIDAS,
                          Item => V_POSICION_SALIDA);
      
      Q_POSICION_IO.Read (File => V_FICHERO_DESTINOS,
                          Item => V_POSICION_DESTINO);
      
      Ada.Text_Io.Put ("Posicion : " & Integer'Image(I) & "     ");
      Ada.Text_Io.Put ("Origen X : " & Integer'Image(Q_TIPOS_BASICOS.F_OBTENER_COORDENADA_X (V_POSICION_SALIDA)) & "    ");
      Ada.Text_Io.Put ("Y : " & Integer'Image(Q_TIPOS_BASICOS.F_OBTENER_COORDENADA_Y (V_POSICION_SALIDA)) & "    -    ");
      Ada.Text_Io.Put ("Destino X : " & Integer'Image(Q_TIPOS_BASICOS.F_OBTENER_COORDENADA_X (V_POSICION_DESTINO)) & "    ");
      Ada.Text_Io.Put ("Y : " & Integer'Image(Q_TIPOS_BASICOS.F_OBTENER_COORDENADA_Y (V_POSICION_DESTINO)));
      Ada.Text_Io.Put_Line ("");
      
   end loop;

   Q_POSICION_IO.Close (V_FICHERO_SALIDAS);
   Q_POSICION_IO.Close (V_FICHERO_DESTINOS);
   
end m_generar_escenario;
--------------------------------------------------------------------------------------------------------------------------------------------
