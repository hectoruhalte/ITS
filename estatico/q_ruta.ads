--------------------------------------------------------------------------------------------------------------------------------------------
--
--      Fichero:        q_ruta.ads
--
--      Autor:          Hector Uhalte Bilbao
--
--      Fecha:          16/5/2018
--      
--------------------------------------------------------------------------------------------------------------------------------------------

with Q_GENERICO_LISTA;
with Q_TRAMO;

-- Paquete para desarrollar el calculo de la ruta entre dos puntos dados.

package Q_RUTA is

	package Q_LISTA_TRAMOS is new Q_GENERICO_LISTA (T_ELEMENTO => Q_TRAMO.T_TRAMO,
                                                        "=" => Q_TRAMO."=",
                                                        V_MAXIMO_NUMERO_ELEMENTOS => Q_TRAMO.F_OBTENER_NUMERO_MAXIMO_TRAMOS);

	subtype T_RUTA is Q_LISTA_TRAMOS.T_LISTA;

	-- Peso para el calculo de la ruta.
	type T_PESO is (E_TIEMPO, E_DISTANCIA);

end Q_RUTA;
-----------
