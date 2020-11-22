--------------------------------------------------------------------------------------------------------------------------------------------
--
--      Fichero:        q_tipos_basicos.adb
--
--      Autor:          Hector Uhalte Bilbao
--
--      Fecha:          6/9/2017
--      
--------------------------------------------------------------------------------------------------------------------------------------------

with ADA.NUMERICS.GENERIC_ELEMENTARY_FUNCTIONS;

package body Q_TIPOS_BASICOS is

	package Q_MATH is new ADA.NUMERICS.GENERIC_ELEMENTARY_FUNCTIONS (Float_Type => Float);

	---------------------------------------------------------------------------
	-- Funcion para poner la velocidad.
	---------------------------------------------------------------------------
	function F_PONER_VELOCIDAD (V_VELOCIDAD : in Integer) return T_VELOCIDAD is

	begin

		return T_VELOCIDAD'(V_VELOCIDAD);

	exception

		when Constraint_Error =>

			raise X_VELOCIDAD_FUERA_DE_RANGO;

	end F_PONER_VELOCIDAD;
	---------------------------------------------------------------------------	

	---------------------------------------------------------------------------
	-- Funcion para obtener la posicion dadas coordenadas x,y.
	---------------------------------------------------------------------------
	function F_OBTENER_POSICION_UTM (V_X : in Integer;
				         V_Y : in Integer) return T_POSICION_UTM is

	begin
	
	-- Comprobar que las coordenada estan dentro del rango maximo. Si no, levantar contraint error.
	

		return T_POSICION_UTM'(R_X => V_X,
				       R_Y => V_Y);

	exception

		when Constraint_Error =>

			raise X_COORDENADAS_FUERA_DE_RANGO;

	end F_OBTENER_POSICION_UTM;
	--------------------------------------------------------------------------


	----------------------------------------------------------------------------------
	-- Funcion para obtener la coordenada x de una posicion dada.
	----------------------------------------------------------------------------------
	function F_OBTENER_COORDENADA_X (V_POSICION : in T_POSICION_UTM) return Integer is

	begin

		return V_POSICION.R_X;

	end F_OBTENER_COORDENADA_X;
	----------------------------------------------------------------------------------


	----------------------------------------------------------------------------------
	-- Funcion para obtener la coordenada y de una posicion dada.
	----------------------------------------------------------------------------------
        function F_OBTENER_COORDENADA_Y (V_POSICION : in T_POSICION_UTM) return Integer is

        begin

                return V_POSICION.R_Y;

        end F_OBTENER_COORDENADA_Y;
        ----------------------------------------------------------------------------------


	---------------------------------------------------------------------------------
	-- Funcion para obtener la distancia entre dos posiciones dadas
	---------------------------------------------------------------------------------
	function F_OBTENER_DISTANCIA (V_POSICION_1 : in T_POSICION_UTM;
				      V_POSICION_2 : in T_POSICION_UTM) return Integer is

	begin

		return Integer
			(Q_MATH.Sqrt(Float((V_POSICION_2.R_X - V_POSICION_1.R_X)**2) + Float((V_POSICION_2.R_Y - V_POSICION_1.R_Y)**2)));

	end F_OBTENER_DISTANCIA;
	----------------------------------------------------------------------------------

	----------------------------------------------------------------------------------------
        -- Funcion para obtener la posicion dadas coordenadas x,y.
        ----------------------------------------------------------------------------------------
        function F_OBTENER_POSICION_LAT_LON (V_LATITUD : in T_LATITUD;
                                     	     V_LONGITUD : in T_LONGITUD) return T_POSICION_LAT_LON is

        begin

                return T_POSICION_LAT_LON'(R_LATITUD => V_LATITUD,
                                  	   R_LONGITUD => V_LONGITUD);

        exception

                when Constraint_Error =>

                        raise X_COORDENADAS_FUERA_DE_RANGO;

        end F_OBTENER_POSICION_LAT_LON;
        ----------------------------------------------------------------------------------------

	-----------------------------------------------------------------------------------
	function F_OBTENER_LATITUD (V_POSICION : in T_POSICION_LAT_LON) return T_LATITUD is

	begin

		return V_POSICION.R_LATITUD;

	end F_OBTENER_LATITUD;
	-----------------------------------------------------------------------------------

	-------------------------------------------------------------------------------------
        function F_OBTENER_LONGITUD (V_POSICION : in T_POSICION_LAT_LON) return T_LONGITUD is

        begin

                return V_POSICION.R_LONGITUD;

        end F_OBTENER_LONGITUD;
        -------------------------------------------------------------------------------------

	------------------------------------
	function F_TRANSFORMAR_GRADOS_A_RADIANES (V_GRADOS : in Float) return Float is

	begin

		return V_GRADOS * Ada.Numerics.Pi / 180.0;

	end F_TRANSFORMAR_GRADOS_A_RADIANES;
	------------------------------------

	----------------------------------------------------------------------------------------------------------
	function F_TRANSFORMAR_LAT_LON_A_UTM (V_POSICION_LAT_LON : in T_POSICION_LAT_LON) return T_POSICION_UTM is

		-- Segunda Excentricidad
		C_EXC_2 : constant Float := Q_MATH.Sqrt(C_SEMIEJE_MAYOR**2 - C_SEMIEJE_MENOR**2) / C_SEMIEJE_MENOR;

		-- Radio polar curvatura.
		C_RAD_POLAR : constant Float := C_SEMIEJE_MAYOR**2 / C_SEMIEJE_MENOR;

		V_LAT_RADIANES, V_LON_RADIANES, V_LON_REF_RADIANES, V_B : Float;

		V_POSICION_UTM : T_POSICION_UTM;

		-- Coeficientes para conversion UTM
		M_6,N_6,O_6,P_6,Y_6,V_6,S_6,W_6,T_6,X_6,U_6 : Float;

	begin

		V_LAT_RADIANES := F_TRANSFORMAR_GRADOS_A_RADIANES (V_POSICION_LAT_LON.R_LATITUD);

		V_LON_RADIANES := F_TRANSFORMAR_GRADOS_A_RADIANES (V_POSICION_LAT_LON.R_LONGITUD);

		V_LON_REF_RADIANES := F_TRANSFORMAR_GRADOS_A_RADIANES (C_MERIDIANO_REFERENCIA);

		V_B := Q_MATH.Cos (V_LAT_RADIANES) * Q_MATH.Sin (V_LON_RADIANES - V_LON_REF_RADIANES);

		M_6 := 0.5 * Q_MATH.Log ((1.0 + V_B) / (1.0 - V_B));

		N_6 := (Q_MATH.Arctan(Q_MATH.Tan (V_LAT_RADIANES) / Q_MATH.Cos (V_LON_RADIANES - V_LON_REF_RADIANES)) - V_LAT_RADIANES);

		O_6 := C_K0 * (C_RAD_POLAR / Q_MATH.Sqrt (1.0 + C_EXC_2**2 * Q_MATH.Cos(V_LAT_RADIANES)**2));

		P_6 := C_EXC_2**2 * M_6**2 * Q_MATH.Cos (V_LAT_RADIANES)**2 / 2.0;

		V_6 := 0.75 * C_EXC_2**2;
	
		S_6 := V_LAT_RADIANES + Q_MATH.Sin (2.0 * V_LAT_RADIANES) / 2.0;

		W_6 := 45.0 * C_EXC_2**4 / 48.0;

		T_6 := (3.0*S_6 + Q_MATH.Sin (2.0 * V_LAT_RADIANES)*Q_MATH.Cos(V_LAT_RADIANES)**2) / 4.0;

		X_6 := 35.0 * V_6**3 / 27.0;

		U_6 := (5.0*T_6 + Q_MATH.Sin (2.0 * V_LAT_RADIANES)*Q_MATH.Cos(V_LAT_RADIANES)**4) / 3.0;

		Y_6 := C_K0 * C_RAD_POLAR * (V_LAT_RADIANES - (V_6*S_6) + (W_6*T_6) - (X_6*U_6));

		V_POSICION_UTM.R_X := Integer(M_6*O_6*(1.0 + P_6/3.0) + C_E0);

		V_POSICION_UTM.R_Y := Integer(N_6*O_6*(1.0 + P_6) + Y_6);

		return V_POSICION_UTM;  
	
	end F_TRANSFORMAR_LAT_LON_A_UTM;
	----------------------------------------------------------------------------------------------------------

	----------------------------------------------------------------------------------------
	function F_OBTENER_REF_X_Y (V_POSICION_UTM : in T_POSICION_UTM) return T_POSICION_UTM is

		-- Llamar a la adaptacion cuando este lista.
		C_PUNTO_TANGENCIA : constant T_POSICION_LAT_LON := F_OBTENER_POSICION_LAT_LON (V_LATITUD => 43.461245,
                                                            				       V_LONGITUD => -3.8184800);

		V_POSICION_PUNTO_TANGENCIA, V_REF_POSICION : T_POSICION_UTM;

	begin
	
		-- !! Llamar a la adaptacion para obtener las coordenadas del punto de tangencia.
		-- De momento Hard code.
		V_POSICION_PUNTO_TANGENCIA := F_TRANSFORMAR_LAT_LON_A_UTM (C_PUNTO_TANGENCIA);

		V_REF_POSICION.R_X := V_POSICION_UTM.R_X - V_POSICION_PUNTO_TANGENCIA.R_X;
		V_REF_POSICION.R_Y := V_POSICION_UTM.R_Y - V_POSICION_PUNTO_TANGENCIA.R_Y;

		return V_REF_POSICION;

	end F_OBTENER_REF_X_Y;
	----------------------------------------------------------------------------------------

	-----------------------------------------------------------------
        function "=" (V_POSICION_1 : in T_POSICION_UTM;
                      V_POSICION_2 : in T_POSICION_UTM) return Boolean is

        begin

                return V_POSICION_1.R_X = V_POSICION_2.R_X and V_POSICION_1.R_Y = V_POSICION_2.R_Y;

        end "=";
        -----------------------------------------------------------------

end Q_TIPOS_BASICOS;
--------------------------------------------------------------------------------------------------------------------------------------------
