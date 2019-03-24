-------------------------------------------------------------------------------------------------------------------------------------------
--
--      Fichero:        q_tramo-q_acciones.adb
--
--      Autor:          Hector Uhalte Bilbao
--
--      Fecha:          7/2/2018
--      
-------------------------------------------------------------------------------------------------------------------------------------------

with Ada.Numerics.Discrete_Random;
with Q_SEGMENTO;
with Ada.Text_Io;
with Ada.Integer_Text_Io;
with Ada.Float_Text_Io;
with Ada.Strings.Fixed;

package body Q_TRAMO.Q_ACCIONES is

	----------------------------------------------------------------------------
	function F_OBTENER_NUMERO_ALEATORIO (V_RANGO : in Natural) return Natural is

		subtype T_RANGO_TRAMOS is Natural range 1 .. V_RANGO;

		package Q_RANDOM_TRAMO is new Ada.Numerics.Discrete_Random (T_RANGO_TRAMOS);

		V_SEMILLA_TRAMO : Q_RANDOM_TRAMO.Generator;

	begin

		Q_RANDOM_TRAMO.Reset (V_SEMILLA_TRAMO);

		return Q_RANDOM_TRAMO.Random (V_SEMILLA_TRAMO);

	end F_OBTENER_NUMERO_ALEATORIO;
	-------------------------------

	------------------------------------------------------------------------------------------------------------------------
	function F_OBTENER_PUNTO_ALEATORIO 
			(V_LISTA_TRAMOS : in Q_ADAPTACION_TRAMO.Q_LISTA_TRAMOS.T_LISTA) return Q_TIPOS_BASICOS.T_POSICION_UTM is

		V_TRAMO : T_TRAMO;

		V_LISTA_SEGMENTOS : Q_LISTA_SEGMENTOS.T_LISTA;

		V_SEGMENTO : Q_SEGMENTO.T_SEGMENTO;

	begin

		-- Obtener el tramo.
		V_TRAMO := Q_ADAPTACION_TRAMO.Q_LISTA_TRAMOS.F_DEVOLVER_ELEMENTO 
				(V_POSICION => 
					F_OBTENER_NUMERO_ALEATORIO (Q_ADAPTACION_TRAMO.Q_LISTA_TRAMOS.F_CUANTOS_ELEMENTOS (V_LISTA_TRAMOS)),
				 V_LISTA => V_LISTA_TRAMOS);

		-- Una vez obtenido el tramo, tenemos que obtener la lista de segmentos
		V_LISTA_SEGMENTOS := F_OBTENER_LISTA_SEGMENTOS (V_TRAMO);

		-- Obtener un segmento.
		V_SEGMENTO := Q_LISTA_SEGMENTOS.F_DEVOLVER_ELEMENTO 
				(V_POSICION => F_OBTENER_NUMERO_ALEATORIO (Q_LISTA_SEGMENTOS.F_CUANTOS_ELEMENTOS (V_LISTA_SEGMENTOS)),
				 V_LISTA => V_LISTA_SEGMENTOS);

		-- Devolver la posicion del segmento.
		return Q_SEGMENTO.F_OBTENER_POSICION (V_SEGMENTO);

	end F_OBTENER_PUNTO_ALEATORIO;
	-----------------------------------------------------------------------------------------------------------------------

	----------------------------------------------------------------------------------------------------
	procedure P_OBTENER_SEGMENTO_ALEATORIO (V_LISTA_TRAMOS : in Q_ADAPTACION_TRAMO.Q_LISTA_TRAMOS.T_LISTA;
						V_NOMBRE_TRAMO : out String;
						V_POSICION_SEGMENTO : out Q_TIPOS_BASICOS.T_POSICION_UTM) is

		V_TRAMO : T_TRAMO;

		V_LISTA_SEGMENTOS : Q_LISTA_SEGMENTOS.T_LISTA;

		V_SEGMENTO : Q_SEGMENTO.T_SEGMENTO;

	begin

		V_TRAMO := Q_ADAPTACION_TRAMO.Q_LISTA_TRAMOS.F_DEVOLVER_ELEMENTO
                                (V_POSICION =>
                                        F_OBTENER_NUMERO_ALEATORIO (Q_ADAPTACION_TRAMO.Q_LISTA_TRAMOS.F_CUANTOS_ELEMENTOS (V_LISTA_TRAMOS)),
                                 V_LISTA => V_LISTA_TRAMOS);

		-- Obtener el nombre del tramo.
		V_NOMBRE_TRAMO := F_OBTENER_NOMBRE (V_TRAMO);

		-- Una vez obtenido el tramo, tenemos que obtener la lista de segmentos
                V_LISTA_SEGMENTOS := F_OBTENER_LISTA_SEGMENTOS (V_TRAMO);

		-- Obtener un segmento.
                V_SEGMENTO := Q_LISTA_SEGMENTOS.F_DEVOLVER_ELEMENTO
                                (V_POSICION => F_OBTENER_NUMERO_ALEATORIO (Q_LISTA_SEGMENTOS.F_CUANTOS_ELEMENTOS (V_LISTA_SEGMENTOS)),
                                 V_LISTA => V_LISTA_SEGMENTOS);

		V_POSICION_SEGMENTO := Q_SEGMENTO.F_OBTENER_POSICION (V_SEGMENTO);

	end P_OBTENER_SEGMENTO_ALEATORIO;
	----------------------------------------------------------------------------------------------------

	---------------------------------------------------------------------------
	procedure P_OBTENER_TRAMO_MAS_CERCANO_A_POSICION (V_POSICION : in Q_TIPOS_BASICOS.T_POSICION_UTM;
							  V_POSICION_SEGMENTO : out Q_TIPOS_BASICOS.T_POSICION_UTM;
							  V_DISTANCIA_A_SEGMENTO : out Integer;
							  V_TRAMO : out T_TRAMO) is

		V_LISTA_TRAMOS : Q_ADAPTACION_TRAMO.Q_LISTA_TRAMOS.T_LISTA;

		V_LISTA_SEGMENTOS : Q_LISTA_SEGMENTOS.T_LISTA;

		-- Variables para manejar el tramo/segmento que estemos inspeccionando al recorrer la lista de los tramos.
		V_TRAMO_ACTUAL : T_TRAMO;
		V_SEGMENTO_ACTUAL : Q_SEGMENTO.T_SEGMENTO;

		V_DISTANCIA, V_DISTANCIA_MINIMA : Integer := 1_000_000;

	begin

		Q_ADAPTACION_TRAMO.P_GENERAR_LISTA_TRAMOS (V_LISTA_TRAMOS);

		-- Recorrer la lista de tramos

		for I in 1 .. Q_ADAPTACION_TRAMO.Q_LISTA_TRAMOS.F_CUANTOS_ELEMENTOS (V_LISTA_TRAMOS) loop

			V_TRAMO_ACTUAL := Q_ADAPTACION_TRAMO.Q_LISTA_TRAMOS.F_DEVOLVER_ELEMENTO (V_POSICION => I,
												 V_LISTA => V_LISTA_TRAMOS);

			-- Inicializar la lista de segmentos.
			Q_LISTA_SEGMENTOS.P_INICIALIZAR_LISTA (V_LISTA_SEGMENTOS);

			-- Obtener la lista de segmentos.
			V_LISTA_SEGMENTOS := F_OBTENER_LISTA_SEGMENTOS (V_TRAMO_ACTUAL);

			for J in 1 .. Q_LISTA_SEGMENTOS.F_CUANTOS_ELEMENTOS (V_LISTA_SEGMENTOS) loop

				V_SEGMENTO_ACTUAL := Q_LISTA_SEGMENTOS.F_DEVOLVER_ELEMENTO (V_POSICION => J,
											    V_LISTA => V_LISTA_SEGMENTOS);

				-- Obtener la posicion del segmento. Y calcular la distancia a la posicion dada.
				V_DISTANCIA := 
					Q_TIPOS_BASICOS.F_OBTENER_DISTANCIA 
						(V_POSICION_1 => V_POSICION,
						 V_POSICION_2 => Q_SEGMENTO.F_OBTENER_POSICION (V_SEGMENTO_ACTUAL));

				if V_DISTANCIA < V_DISTANCIA_MINIMA then

					V_DISTANCIA_MINIMA := V_DISTANCIA;
					
					-- Guardar la posicion del segmento y el tramo.
					V_POSICION_SEGMENTO := Q_SEGMENTO.F_OBTENER_POSICION (V_SEGMENTO_ACTUAL);

					V_TRAMO := V_TRAMO_ACTUAL;

				end if;

			end loop;

		end loop;

		V_DISTANCIA_A_SEGMENTO := V_DISTANCIA_MINIMA;	
	
	end P_OBTENER_TRAMO_MAS_CERCANO_A_POSICION;
	---------------------------------------------------------------------------

	----------------------------------------
	procedure P_VISUALIZAR_CABECERA_TRAMO is

	begin

		Ada.Text_Io.Put_Line 
			("+----+---------------------------------+--------------------------+--------------------------+-----+-----+-----" &
                         "--+-------+-------+---------+");

		Ada.Text_Io.Put_Line ("| ID |             NOMBRE              |          ORIGEN          |           FINAL          " & 
			"|  t  | dst | c.max | c.nom | CARGA | ABIERTO |");

		Ada.Text_Io.Put_Line
                        ("+----+---------------------------------+--------------------------+--------------------------+-----+-----+-----" &
                         "--+-------+-------+---------+");

	end P_VISUALIZAR_CABECERA_TRAMO;
	--------------------------------

	--------------------------------------------------
	procedure P_VISUALIZAR_TRAMO (V_LISTA_TRAMOS : in Q_ADAPTACION_TRAMO.Q_LISTA_TRAMOS.T_LISTA;
				      V_ID: in Integer) is

		V_TRAMO : T_TRAMO;

		V_STRING_BOOLEAN : String (1..5) := (others => ADA.CHARACTERS.Latin_1.SPACE);

	begin

		-- Obtener el tramo a visualizar.
                P_PONER_ID (V_ID => V_ID,
                            V_TRAMO => V_TRAMO);

		V_TRAMO := Q_ADAPTACION_TRAMO.Q_LISTA_TRAMOS.F_ENCONTRAR_ELEMENTO (V_ELEMENTO => V_TRAMO,
                                                                                   V_LISTA => V_LISTA_TRAMOS);

		Ada.Text_Io.Put ("| ");
		Ada.Integer_Text_Io.Put (Item => V_ID,
					 Width => 3);
		Ada.Text_Io.Put ("| " & F_OBTENER_NOMBRE (V_TRAMO) & "| ");
		Ada.Text_Io.Put ("X : ");
		Ada.Integer_Text_Io.Put (Item => Q_TIPOS_BASICOS.F_OBTENER_COORDENADA_X (F_OBTENER_ORIGEN (V_TRAMO)),
					 Width => 7);
		Ada.Text_Io.Put ("  Y : ");
		Ada.Integer_Text_Io.Put (Item => Q_TIPOS_BASICOS.F_OBTENER_COORDENADA_Y (F_OBTENER_ORIGEN (V_TRAMO)),
                                         Width => 7);
		Ada.Text_Io.Put (" | ");
		Ada.Text_Io.Put ("X : ");
                Ada.Integer_Text_Io.Put (Item => Q_TIPOS_BASICOS.F_OBTENER_COORDENADA_X (F_OBTENER_FINAL (V_TRAMO)),
                                         Width => 7);
                Ada.Text_Io.Put ("  Y : ");
                Ada.Integer_Text_Io.Put (Item => Q_TIPOS_BASICOS.F_OBTENER_COORDENADA_Y (F_OBTENER_FINAL (V_TRAMO)),
                                         Width => 7);
		Ada.Text_Io.Put (" |");
		Ada.Integer_Text_Io.Put (Item => F_OBTENER_TIEMPO_TRAMO (V_TRAMO),
					 Width => 4);
		Ada.Text_Io.Put (" |");
		Ada.Integer_Text_Io.Put (Item => F_OBTENER_DISTANCIA_TRAMO (V_TRAMO),
					 Width => 4);
		Ada.Text_Io.Put (" |");
		Ada.Integer_Text_Io.Put (Item => F_OBTENER_CAPACIDAD_MAXIMA_TRAMO (V_TRAMO),
					 Width => 6);
		Ada.Text_Io.Put (" |");
		Ada.Integer_Text_Io.Put (Item => F_OBTENER_CAPACIDAD_NOMINAL_TRAMO (V_TRAMO),
                                         Width => 6);

		Ada.Text_Io.Put (" |  ");
		Ada.Float_Text_Io.Put (Item => F_OBTENER_CARGA_TRAFICO (V_TRAMO),
                                       Fore => 1,
                                       Aft => 2,
                                       Exp => 0);
		Ada.Text_Io.Put (" |  ");
		
		Ada.Strings.Fixed.Move (Source => Boolean'Image(F_OBTENER_DISPONIBILIDAD (V_TRAMO)),
					Target => V_STRING_BOOLEAN);

		Ada.Text_Io.Put_Line (V_STRING_BOOLEAN  & "  |");
		Ada.Text_Io.Put_Line
                        ("+----+---------------------------------+--------------------------+--------------------------+-----+-----+-----" &
                         "--+-------+-------+---------+");


	end P_VISUALIZAR_TRAMO;
	--------------------------------------------------

end Q_TRAMO.Q_ACCIONES;
-------------------------------------------------------------------------------------------------------------------------------------------
