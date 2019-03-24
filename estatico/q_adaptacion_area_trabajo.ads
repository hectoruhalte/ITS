--------------------------------------------------------------------------------------------------------------------------------------------
--
--      Fichero:        q_adaptacion_area_trabajo.ads
--
--      Autor:          Hector Uhalte Bilbao
--
--      Fecha:          8/3/2018
--      
--------------------------------------------------------------------------------------------------------------------------------------------

with Q_TIPOS_BASICOS;

package Q_ADAPTACION_AREA_TRABAJO is

	type T_AREA_TRABAJO_ADAPTACION is private;

	-- Procedimiento para escribir el fichero "area_trabajo.bin". area_trabajo.xml -> area_trabajo.bin
        procedure P_CARGAR_ADAPTACION;

	function F_OBTENER_PUNTO_TANGENCIA return Q_TIPOS_BASICOS.T_POSICION_LAT_LON;

	function F_OBTENER_LATITUD_MINIMA return Q_TIPOS_BASICOS.T_LATITUD;

	function F_OBTENER_LATITUD_MAXIMA return Q_TIPOS_BASICOS.T_LATITUD;

	function F_OBTENER_LONGITUD_MINIMA return Q_TIPOS_BASICOS.T_LONGITUD;

	function F_OBTENER_LONGITUD_MAXIMA return Q_TIPOS_BASICOS.T_LONGITUD;

	procedure P_VISUALIZAR;

	private

		type T_AREA_TRABAJO_ADAPTACION is record

			R_PUNTO_TANGENCIA : Q_TIPOS_BASICOS.T_POSICION_LAT_LON;

			R_RADIO_TIERRA : Integer;

			R_LATITUD_MINIMA : Q_TIPOS_BASICOS.T_LATITUD;

			R_LATITUD_MAXIMA : Q_TIPOS_BASICOS.T_LATITUD;

			R_LONGITUD_MINIMA : Q_TIPOS_BASICOS.T_LONGITUD;

			R_LONGITUD_MAXIMA : Q_TIPOS_BASICOS.T_LONGITUD;

		end record;

end Q_ADAPTACION_AREA_TRABAJO;
-------------------------------------------------------------------------------------------------------------------------------------------
