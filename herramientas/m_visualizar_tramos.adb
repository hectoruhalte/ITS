-------------------------------------------------------------------------------------------------------------------------------------------
--
--      Fichero:        m_visualizar_tramos.adb
--
--      Autor:          Hector Uhalte Bilbao
--
--      Fecha:          28/1/2019
--      
--------------------------------------------------------------------------------------------------------------------------------------------

with Q_TRAMO.Q_ACCIONES;
with Q_ADAPTACION_TRAMO;

procedure m_visualizar_tramos is

	V_LISTA_TRAMOS : Q_ADAPTACION_TRAMO.Q_LISTA_TRAMOS.T_LISTA;

begin 

	-- Obtener el registro de tramos (numero de tramos + array de tramos) de la adaptacion.
        Q_ADAPTACION_TRAMO.P_GENERAR_LISTA_TRAMOS (V_LISTA_TRAMOS);

	Q_TRAMO.Q_ACCIONES.P_VISUALIZAR_CABECERA_TRAMO;

        for I in 1 .. Q_ADAPTACION_TRAMO.Q_LISTA_TRAMOS.F_CUANTOS_ELEMENTOS (V_LISTA_TRAMOS) loop

        	Q_TRAMO.Q_ACCIONES.P_VISUALIZAR_TRAMO (V_LISTA_TRAMOS => V_LISTA_TRAMOS,
                                                       V_ID => I);
        end loop;

end m_visualizar_tramos;
--------------------------------------------------------------------------------------------------------------------------------------------
