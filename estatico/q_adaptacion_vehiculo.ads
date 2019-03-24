--------------------------------------------------------------------------------------------------------------------------------------------
--
--      Fichero:        q_adaptacion_vehiculo.ads
--
--      Autor:          Hector Uhalte Bilbao
--
--      Fecha:          20/11/2017
--      
--------------------------------------------------------------------------------------------------------------------------------------------

with Q_VEHICULO;
with Q_TIPOS_BASICOS;

package Q_ADAPTACION_VEHICULO is

	type T_VEHICULO_ADAPTACION is private;

	-- Procedimiento para escribir el fichero "vehiculos.bin". vehiculos.xml -> vehiculos.bin
	procedure P_CARGAR_ADAPTACION;

	function F_EXISTE_MARCA (V_NOMBRE_MARCA : in String) return Boolean;

	function F_EXISTE_MODELO (V_NOMBRE_MARCA : in String;
                                  V_NOMBRE_MODELO : in String) return Boolean;

	function F_OBTENER_VELOCIDAD_MAXIMA (V_NOMBRE_MARCA : in String;
					     V_NOMBRE_MODELO : in String) return Integer;

	function F_OBTENER_LONGITUD (V_NOMBRE_MARCA : in String;
				     V_NOMBRE_MODELO : in String) return Float;

	function F_OBTENER_ALTURA (V_NOMBRE_MARCA : in String;
				   V_NOMBRE_MODELO : in String) return Float;

	function F_OBTENER_CONSUMO_URBANO (V_NOMBRE_MARCA : in String;
                                   	   V_NOMBRE_MODELO : in String) return Float;

	function F_OBTENER_CONSUMO_CARRETERA (V_NOMBRE_MARCA : in String;
                                              V_NOMBRE_MODELO : in String) return Float;

	-- Procedimiento para obtener un vehiculo aleatorio. Pensado para simulacion
        procedure P_OBTENER_MARCA_MODELO_ALEATORIO (V_NOMBRE_MARCA : out String;
                                                    V_NOMBRE_MODELO : out String);

	-- Procedimiento para visualizar el fichero "vehiculos.bin"
	procedure P_VISUALIZAR;

	private

		C_NUMERO_MAXIMO_VEHICULOS_ADAPTACION : constant Integer := 1000;

		type T_CARACTERISTICAS is record

			R_VELOCIDAD_MAXIMA : Q_TIPOS_BASICOS.T_VELOCIDAD := Q_TIPOS_BASICOS.C_MAXIMA_VELOCIDAD_POSIBLE;

			R_LONGITUD : Float := 0.0;

			R_ALTURA : Float := 0.0;

			R_CONSUMO_URBANO : Float := 100.0;
	
			R_CONSUMO_CARRETERA : Float := 100.0;

		end record;

		type T_VEHICULO_ADAPTACION is record

			R_NOMBRE_MARCA : String (1 .. Q_VEHICULO.F_OBTENER_LONGITUD_MAXIMA_NOMBRE_MARCA_MODELO):= 
				Q_VEHICULO.F_OBTENER_MARCA_VACIA;

			R_NOMBRE_MODELO : String (1 .. Q_VEHICULO.F_OBTENER_LONGITUD_MAXIMA_NOMBRE_MARCA_MODELO):= 
                                Q_VEHICULO.F_OBTENER_MODELO_VACIO;

			R_CARACTERISTICAS : T_CARACTERISTICAS;

		end record;

		type T_VEHICULO_ADAPTACION_ARRAY is array (1 .. C_NUMERO_MAXIMO_VEHICULOS_ADAPTACION) of T_VEHICULO_ADAPTACION;

		type T_VEHICULO_ADAPTACION_REGISTRO is record

			R_NUMERO_VEHICULOS : Integer range 0 .. C_NUMERO_MAXIMO_VEHICULOS_ADAPTACION;

			R_VEHICULO_ADAPTACION_ARRAY : T_VEHICULO_ADAPTACION_ARRAY;

		end record;

end Q_ADAPTACION_VEHICULO;
-------------------------------------------------------------------------------------------------------------------------------------------
