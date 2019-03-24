-------------------------------------------------------------------------------------------------------------------------------------------
--
--      Fichero:        q_vehiculo-q_acciones.adb
--
--      Autor:          Hector Uhalte Bilbao
--
--      Fecha:          16/11/2017
--      
-------------------------------------------------------------------------------------------------------------------------------------------

with Q_LOG;
with Q_ADAPTACION_VEHICULO;
with Ada.Numerics.Discrete_Random;
with Ada.Text_Io;

package body Q_VEHICULO.Q_ACCIONES is

	type T_TIPO_STRING is (E_NUMEROS_Y_LETRAS, E_LETRAS, E_NUMEROS);

	----------------------------
        -- Funcion para poner el numero de bastidor a partir de un string.
        -- Comprobar que el string tiene 17 caracteres y si no, levantar una exceprion.
        ----------------------------
        function F_PONER_NUMERO_BASTIDOR (V_NUMERO_BASTIDOR : in String) return String is

        begin

                if V_NUMERO_BASTIDOR'Length = C_LONGITUD_NUMERO_BASTIDOR then

                        return V_NUMERO_BASTIDOR;

                else

                        raise X_NUMERO_BASTIDOR_ERRONEO;

                end if;

        end F_PONER_NUMERO_BASTIDOR;
        ----------------------------

	----------------------
        -- Funcion para poner la matricula en un vehiculo
        -- Comprobar que el string tiene 8 caracteres y si no, levantar una excepcion.
        ----------------------
        function F_PONER_MATRICULA (V_MATRICULA : in String) return String is

        begin

                if V_MATRICULA'Length = C_LONGITUD_MATRICULA then

                        return V_MATRICULA;

                else

                        raise X_MATRICULA_ERRONEA;

                end if;

        end F_PONER_MATRICULA;
        ----------------------

	-------------------------
        -- Funcion para poner la marca del vehiculo
        -- Comprobar que el string tiene como mucho 16 caracteres y si no, levantar una
        -- excepcion.
        -------------------------
        function F_PONER_NOMBRE_MARCA (V_NOMBRE_MARCA : in String) return String is

        begin

		-- Comprobar que la marca del vehiculo esta adaptada
                if not Q_ADAPTACION_VEHICULO.F_EXISTE_MARCA(V_NOMBRE_MARCA) then

			Q_LOG.P_ESCRIBIR_LOG (V_STRING => "La marca " & V_NOMBRE_MARCA & " no esta adaptada",
					      V_NOMBRE_FICHERO => "/home/hector/ITS/log/adaptacion_vehiculo.log");
			
                        raise X_MARCA_NO_ADAPTADA;

                elsif V_NOMBRE_MARCA'Length <= C_LONGITUD_MAXIMA_NOMBRE_MARCA_MODELO then

                        return V_NOMBRE_MARCA;

                else

                        raise X_NOMBRE_MARCA_EXCESIVAMENTE_LARGO;

                end if;

        end F_PONER_NOMBRE_MARCA;
        -------------------------

	---------------------------
        -- Funcion para poner el modelo del vehiculo
        -- Comprobar que el string tiene como mucho 16 caracteres y si no, levantar 
        -- una excepcion.
        ---------------------------
        function F_PONER_NOMBRE_MODELO (V_NOMBRE_MARCA : in String;
                                        V_NOMBRE_MODELO : in String) return String is

        begin

		-- Comprobar que el modelo este adaptado para la marca dada.
		if not Q_ADAPTACION_VEHICULO.F_EXISTE_MODELO(V_NOMBRE_MARCA => V_NOMBRE_MARCA,
							     V_NOMBRE_MODELO => V_NOMBRE_MODELO) then

			raise X_MODELO_NO_ADAPTADO;

		elsif V_NOMBRE_MODELO'Length <= C_LONGITUD_MAXIMA_NOMBRE_MARCA_MODELO then

                        return V_NOMBRE_MODELO;

                else

                        raise X_NOMBRE_MODELO_EXCESIVAMENTE_LARGO;

                end if;

        end F_PONER_NOMBRE_MODELO;
        --------------------------

	-----------------------------------------------------------
        -- Procedimiento para crear un vehiculo
        -----------------------------------------------------------
        procedure P_CREAR_VEHICULO (V_NUMERO_BASTIDOR : in String;
                                    V_MATRICULA : in String;
                                    V_NOMBRE_MARCA : in String;
                                    V_NOMBRE_MODELO : in String;
                                    V_VEHICULO : out T_VEHICULO) is

        begin

                V_VEHICULO.R_NUMERO_BASTIDOR := F_PONER_NUMERO_BASTIDOR(V_NUMERO_BASTIDOR);
                V_VEHICULO.R_MATRICULA := F_PONER_MATRICULA(V_MATRICULA);
                V_VEHICULO.R_NOMBRE_MARCA (1 .. V_NOMBRE_MARCA'Length) := F_PONER_NOMBRE_MARCA(V_NOMBRE_MARCA);
                V_VEHICULO.R_NOMBRE_MODELO (1 .. V_NOMBRE_MODELO'Length) := F_PONER_NOMBRE_MODELO(V_NOMBRE_MARCA => V_NOMBRE_MARCA,
                                                                                                  V_NOMBRE_MODELO => V_NOMBRE_MODELO);

                -- Una vez que tenemos la marca y el modelo. Se llama a la adaptacion para completar el vehiculo con los siguientes datos:
                -- Velocidad Maxima
                -- Longitud
                -- Altura
                -- Consumo Urbano
                -- Consumo Carretera

		V_VEHICULO.R_VELOCIDAD_MAXIMA := Q_ADAPTACION_VEHICULO.F_OBTENER_VELOCIDAD_MAXIMA (V_NOMBRE_MARCA => V_NOMBRE_MARCA,
												   V_NOMBRE_MODELO => V_NOMBRE_MODELO);

		V_VEHICULO.R_DIMENSIONES.R_LONGITUD := Q_ADAPTACION_VEHICULO.F_OBTENER_LONGITUD (V_NOMBRE_MARCA => V_NOMBRE_MARCA,
						  						 V_NOMBRE_MODELO => V_NOMBRE_MODELO);

		V_VEHICULO.R_DIMENSIONES.R_ALTURA := Q_ADAPTACION_VEHICULO.F_OBTENER_ALTURA (V_NOMBRE_MARCA => V_NOMBRE_MARCA,
											     V_NOMBRE_MODELO => V_NOMBRE_MODELO);

		V_VEHICULO.R_CONSUMO.R_URBANO := Q_ADAPTACION_VEHICULO.F_OBTENER_CONSUMO_URBANO (V_NOMBRE_MARCA => V_NOMBRE_MARCA,
												 V_NOMBRE_MODELO => V_NOMBRE_MODELO);

		V_VEHICULO.R_CONSUMO.R_CARRETERA := Q_ADAPTACION_VEHICULO.F_OBTENER_CONSUMO_CARRETERA (V_NOMBRE_MARCA => V_NOMBRE_MARCA,
                                                                                                       V_NOMBRE_MODELO => V_NOMBRE_MODELO);

        end P_CREAR_VEHICULO;
        -----------------------------------------------------------

	-------------------------------
        function F_GENERAR_STRING_ALEATORIO (V_LONGITUD_STRING : in Integer;
                                             V_NUMEROS_LETRAS : in  T_TIPO_STRING) return String is

                subtype T_RANGO_CARACTERES is Integer range 1 .. 36;
                subtype T_RANGO_LETRAS is Integer range 1 .. 20;
                subtype T_RANGO_NUMEROS is Integer range 1 .. 10;

                package Q_RANDOM_CARACTER is new Ada.Numerics.Discrete_Random (T_RANGO_CARACTERES);
                package Q_RANDOM_LETRAS is new Ada.Numerics.Discrete_Random (T_RANGO_LETRAS);
                package Q_RANDOM_NUMEROS is new Ada.Numerics.Discrete_Random (T_RANGO_NUMEROS);

                V_SEMILLA_CARACTER : Q_RANDOM_CARACTER.Generator;
                V_SEMILLA_LETRAS : Q_RANDOM_LETRAS.Generator;
                V_SEMILLA_NUMEROS : Q_RANDOM_NUMEROS.Generator;

                type T_CARACTERES is array (1 .. 36) of Character;
                type T_LETRAS is array (1 .. 20) of Character;
                type T_NUMEROS is array (1 .. 10) of Character;

                V_CARACTERES : T_CARACTERES := ('0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F','G','H','I','J','K','L',
                                                'M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z');

                V_LETRAS : T_LETRAS := ('B','C','D','F','G','H','J','K','L','M','N','P','R','S','T','V','W','X','Y','Z');

                V_NUMEROS : T_NUMEROS := ('0','1','2','3','4','5','6','7','8','9');

                V_STRING : String (1 .. V_LONGITUD_STRING);

        begin

                case V_NUMEROS_LETRAS is

			when E_NUMEROS_Y_LETRAS =>

                                Q_RANDOM_CARACTER.Reset(V_SEMILLA_CARACTER);

                                for I in Integer range 1 .. V_LONGITUD_STRING loop

                                        V_STRING(I) := V_CARACTERES(Q_RANDOM_CARACTER.Random(V_SEMILLA_CARACTER));

                                end loop;

                        when E_LETRAS =>

                                Q_RANDOM_LETRAS.Reset(V_SEMILLA_LETRAS);

                                for I in Integer range 1 .. V_LONGITUD_STRING loop

                                        V_STRING(I) := V_LETRAS(Q_RANDOM_LETRAS.Random(V_SEMILLA_LETRAS));

                                end loop;

                        when E_NUMEROS =>

                                Q_RANDOM_NUMEROS.Reset(V_SEMILLA_NUMEROS);

                                for I in Integer range 1 .. V_LONGITUD_STRING loop

                                        V_STRING(I) := V_NUMEROS(Q_RANDOM_NUMEROS.Random(V_SEMILLA_NUMEROS));

                                end loop;

                end case;

		return V_STRING;

        end F_GENERAR_STRING_ALEATORIO;
        -------------------------------

	------------------------------
        function F_GENERAR_NUMERO_BASTIDOR return String is

        begin

                -- Generar aleatoriamente un numero de bastidor.
                -- De momento todos los caracteres del numero de bastidor seran aleatorios.
                return F_GENERAR_STRING_ALEATORIO(V_LONGITUD_STRING => F_OBTENER_LONGITUD_NUMERO_BASTIDOR,
                                                  V_NUMEROS_LETRAS => E_NUMEROS_Y_LETRAS);

        end F_GENERAR_NUMERO_BASTIDOR;
        ------------------------------

	------------------------
        function F_GENERAR_MATRICULA return String is

        begin

                return F_GENERAR_STRING_ALEATORIO(V_LONGITUD_STRING => 4,
                                                  V_NUMEROS_LETRAS => E_NUMEROS) & " " &

                       F_GENERAR_STRING_ALEATORIO(V_LONGITUD_STRING => 3,
                                                  V_NUMEROS_LETRAS => E_LETRAS);

        end F_GENERAR_MATRICULA;
        ------------------------

	------------------------------------------------------------------------
        -- Procedimiento para genera un vehiculo automaticamente
        ------------------------------------------------------------------------
        procedure P_GENERAR_VEHICULO (V_VEHICULO : out T_VEHICULO) is

                V_NOMBRE_MARCA, V_NOMBRE_MODELO : String (1 .. F_OBTENER_LONGITUD_MAXIMA_NOMBRE_MARCA_MODELO);

        begin

                -- Obtener la marca y el modelo aleatoriamente entre los vehiculos adaptados
                Q_ADAPTACION_VEHICULO.P_OBTENER_MARCA_MODELO_ALEATORIO (V_NOMBRE_MARCA => V_NOMBRE_MARCA,
                                                                        V_NOMBRE_MODELO => V_NOMBRE_MODELO);

                Q_VEHICULO.Q_ACCIONES.P_CREAR_VEHICULO (V_NUMERO_BASTIDOR => F_GENERAR_NUMERO_BASTIDOR,
                                                        V_MATRICULA => F_GENERAR_MATRICULA,
                                                        V_NOMBRE_MARCA => V_NOMBRE_MARCA,
                                                        V_NOMBRE_MODELO => V_NOMBRE_MODELO,
                                                        V_VEHICULO => V_VEHICULO);

        end P_GENERAR_VEHICULO;
        ------------------------------------------------------------------------

	------------------------------------------------------------
        -- Procedimiento para mostrar por pantalla los datos de un 
        -- vehiculo
        ------------------------------------------------------------
        procedure P_MOSTRAR_VEHICULO (V_VEHICULO : in T_VEHICULO) is

        begin

                Ada.Text_Io.PUT_LINE (V_VEHICULO.R_MATRICULA & "  |  " & V_VEHICULO.R_NOMBRE_MARCA & " " & V_VEHICULO.R_NOMBRE_MODELO);

        end P_MOSTRAR_VEHICULO;
        ------------------------------------------------------------

end Q_VEHICULO.Q_ACCIONES;
-------------------------------------------------------------------------------------------------------------------------------------------
