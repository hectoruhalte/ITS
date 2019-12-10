-------------------------------------------------------------------------------------------------------------------------------------------
--
--      Fichero:        m_visualizar_adaptacion_tramos.adb
--
--      Autor:          Hector Uhalte Bilbao
--
--      Fecha:          20/1/2018
--      
--------------------------------------------------------------------------------------------------------------------------------------------

with Q_ADAPTACION_TRAMO;

procedure m_visualizar_adaptacion_tramos is

begin

	Q_ADAPTACION_TRAMO.P_CARGAR_ADAPTACION;

	Q_ADAPTACION_TRAMO.P_VISUALIZAR;

end m_visualizar_adaptacion_tramos;
-------------------------------------------------------------------------------------------------------------------------------------------
