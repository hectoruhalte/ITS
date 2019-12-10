-------------------------------------------------------------------------------------------------------------------------------------------
--
--      Fichero:        m_visualizar_adaptacion_area_trabajo.adb
--
--      Autor:          Hector Uhalte Bilbao
--
--      Fecha:          22/3/2018
--      
--------------------------------------------------------------------------------------------------------------------------------------------

with Q_ADAPTACION_AREA_TRABAJO;

procedure m_visualizar_adaptacion_area_trabajo is

begin

	Q_ADAPTACION_AREA_TRABAJO.P_CARGAR_ADAPTACION;

	Q_ADAPTACION_AREA_TRABAJO.P_VISUALIZAR;

end m_visualizar_adaptacion_area_trabajo;
-------------------------------------------------------------------------------------------------------------------------------------------
