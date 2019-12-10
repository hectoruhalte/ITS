--------------------------------------------------------------------------------------------------------------------------------------------
--
--      Fichero:        q_restriccion.ads
--
--      Autor:          Hector Uhalte Bilbao
--
--      Fecha:          10/7/2019
--
--------------------------------------------------------------------------------------------------------------------------------------------

with Q_TIPOS_BASICOS;

package Q_RESTRICCION is

	type T_SENAL is (E_NULA, E_SEMAFORO, E_STOP, E_CEDA_PASO, E_PASO_CEBRA);

	type T_RESTRICCION is private;

	procedure P_PONER_RESTRICCION (V_VELOCIDAD : in Q_TIPOS_BASICOS.T_VELOCIDAD;
				       V_SENAL : in T_SENAL;
				       V_RESTRICCION : out T_RESTRICCION);

	function F_OBTENER_RESTRICCION_VELOCIDAD (V_RESTRICCION : in T_RESTRICCION) return Q_TIPOS_BASICOS.T_VELOCIDAD;

	function F_OBTENER_RESTRICCION_SENAL (V_RESTRICCION : in T_RESTRICCION) return T_SENAL;

	private

		type T_RESTRICCION is record

			R_RESTRICCION_VELOCIDAD : Q_TIPOS_BASICOS.T_VELOCIDAD;

			R_RESTRICCION_SENAL : T_SENAL;

		end record;

end Q_RESTRICCION;
------------------
