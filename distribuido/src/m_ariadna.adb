--------------------------------------------------------------------------------------------------------------------------------------------
--
--      Fichero:        m_ariadna.adb
--
--      Autor:          Hector Uhalte Bilbao
--
--      Fecha:          26/8/2020
--
--------------------------------------------------------------------------------------------------------------------------------------------

-- Ejecutable para realizar la función de servidor de la aplicacion districbuida.

with Ada.Text_IO;
with Q_RUTA.Q_DIJKSTRA;

procedure m_ariadna is   

begin
   
   Ada.Text_IO.Put_Line ("================================================================================");
   Ada.Text_IO.Put_Line (" .- Arrancando Ariadna  ...");
   Ada.Text_IO.Put_Line (" --");
   Ada.Text_IO.Put_Line (" .- Cargando mapas ...");
   Q_RUTA.Q_DIJKSTRA.P_GENERAR_ADAPTACION;
   Ada.Text_IO.Put_Line (" --");
   Ada.Text_IO.Put_Line (" .- Mapas cargados");
   Ada.Text_IO.Put_Line (" --");
   Ada.Text_IO.Put_Line (" .- Ariadna en servicio ...");
   Ada.Text_IO.Put_Line (" --");
   
   loop
      
      null;
      
   end loop;
   
end m_ariadna;
--------------------------------------------------------------------------------------------------------------------------------------------
