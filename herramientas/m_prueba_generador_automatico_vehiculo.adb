--------------------------------------------------------------------------------------------------------------------------------------------
--
--      Fichero:        m_prueba_generador_automatico_vehiculo.adb
--
--      Autor:          Hector Uhalte Bilbao
--
--      Fecha:          20/9/2017
--      
--------------------------------------------------------------------------------------------------------------------------------------------

with ADA.TEXT_IO;
with ADA.NUMERICS.DISCRETE_RANDOM;
with ADA.CALENDAR;
with Q_VEHICULO.Q_ACCIONES;
with Q_GENERICO_LISTA;
with Q_ADAPTACION_VEHICULO;

procedure m_prueba_generador_automatico_vehiculo is

	V_VEHICULO, V_MI_VEHICULO , V_VEHICULO_ENCONTRADO : Q_VEHICULO.T_VEHICULO;

	package Q_LISTA_VEHICULOS is new Q_GENERICO_LISTA (T_ELEMENTO => Q_VEHICULO.T_VEHICULO,
                                                           "=" => Q_VEHICULO."=",
                                                           V_MAXIMO_NUMERO_ELEMENTOS => 30_000_000);

	V_LISTA_VEHICULOS : Q_LISTA_VEHICULOS.T_LISTA;

	C_NUMERO_VEHICULOS : constant Natural := 100_000;

	subtype T_RANGO_NUMEROS is Integer range 1 .. C_NUMERO_VEHICULOS;

	package RANDOM_NUMEROS is new ADA.NUMERICS.DISCRETE_RANDOM (Result_Subtype => T_RANGO_NUMEROS);

	V_SEMILLA_NUMEROS : RANDOM_NUMEROS.GENERATOR;

	V_POSICION_A_METER_MI_COCHE : Natural := 1;

	V_COMIENZO, V_FINAL : Integer := 0;

begin

	Q_ADAPTACION_VEHICULO.P_CARGAR_ADAPTACION;

	--RANDOM_NUMEROS.RESET(V_SEMILLA_NUMEROS);

	--V_POSICION_A_METER_MI_COCHE := RANDOM_NUMEROS.RANDOM(V_SEMILLA_NUMEROS);

	--Crear mi vehiculo para insertarlo en la lista.
	Q_VEHICULO.Q_ACCIONES.P_CREAR_VEHICULO (V_NUMERO_BASTIDOR => "WVWZZZ1JZ3W639383",
				     		V_MATRICULA => "6883 GZL",
				     		V_NOMBRE_MARCA => "VOLKSWAGEN",
				     		V_NOMBRE_MODELO => "GOLF",
				     		V_VEHICULO => V_MI_VEHICULO);	

	Q_LISTA_VEHICULOS.P_INICIALIZAR_LISTA (V_LISTA_VEHICULOS);

	V_COMIENZO := (Integer(ADA.CALENDAR.Seconds(ADA.CALENDAR.CLOCK)));

	for I in 1 .. C_NUMERO_VEHICULOS loop

		if I = 1000 then

			V_FINAL := (Integer(ADA.CALENDAR.Seconds(ADA.CALENDAR.CLOCK)));

			ADA.TEXT_IO.PUT_LINE 
				("Se ha tardado " & Integer'Image(V_FINAL - V_COMIENZO) & " segundos en introducir 1.000 vehiculos");

		elsif I = 10_000 then
			
			V_FINAL := (Integer(ADA.CALENDAR.Seconds(ADA.CALENDAR.CLOCK)));

                        ADA.TEXT_IO.PUT_LINE
                                ("Se ha tardado " & Integer'Image(V_FINAL - V_COMIENZO) & " segundos en introducir 10.000 vehiculos");

		elsif I = 100_000 then

			V_FINAL := (Integer(ADA.CALENDAR.Seconds(ADA.CALENDAR.CLOCK)));

                        ADA.TEXT_IO.PUT_LINE
                                ("Se ha tardado " & Integer'Image(V_FINAL - V_COMIENZO) & " segundos en introducir 100.000 vehiculos");

		elsif I = 1_000_000 then

			V_FINAL := (Integer(ADA.CALENDAR.Seconds(ADA.CALENDAR.CLOCK)));

                        ADA.TEXT_IO.PUT_LINE
                                ("Se ha tardado " & Integer'Image(V_FINAL - V_COMIENZO) & " segundos en introducir 1.000.000 vehiculos");

		elsif I = 10_000_000 then

			V_FINAL := (Integer(ADA.CALENDAR.Seconds(ADA.CALENDAR.CLOCK)));

                        ADA.TEXT_IO.PUT_LINE
                                ("Se ha tardado " & Integer'Image(V_FINAL - V_COMIENZO) & " segundos en introducir 10.000.000 vehiculos");

		elsif I = 20_000_000 then

			V_FINAL := (Integer(ADA.CALENDAR.Seconds(ADA.CALENDAR.CLOCK)));

                        ADA.TEXT_IO.PUT_LINE
                                ("Se ha tardado " & Integer'Image(V_FINAL - V_COMIENZO) & " segundos en introducir 20.000.000 vehiculos");

		end if;

		if I = V_POSICION_A_METER_MI_COCHE then

			--ADA.TEXT_IO.PUT_LINE 
			--	("Posicion en la que voy a insertar mi vehiculo : " & Natural'Image(V_POSICION_A_METER_MI_COCHE));

			Q_LISTA_VEHICULOS.P_INSERTAR_ELEMENTO (V_ELEMENTO => V_MI_VEHICULO,
							       V_LISTA => V_LISTA_VEHICULOS);
			--Quiero ver los vehiculos al meterlos en la lista
			Q_VEHICULO.Q_ACCIONES.P_MOSTRAR_VEHICULO (V_MI_VEHICULO);


		else
	
			Q_VEHICULO.Q_ACCIONES.P_GENERAR_VEHICULO (V_VEHICULO);

			Q_LISTA_VEHICULOS.P_INSERTAR_ELEMENTO (V_ELEMENTO => V_VEHICULO,
							       V_LISTA => V_LISTA_VEHICULOS);

			--Q_VEHICULO.P_MOSTRAR_VEHICULO (V_VEHICULO);

		end if;

		-- Valores aleatorios para el string dependiendo del tiempo. Por eso el delay, si no todos los valores iguales.
		delay 0.001; 

	end loop;

	ADA.TEXT_IO.PUT_LINE 
		("El numero de vehiculos en la lista es : " & 
			Integer'Image(Q_LISTA_VEHICULOS.F_CUANTOS_ELEMENTOS_PUNTEROS(V_LISTA_VEHICULOS)));

	ADA.TEXT_IO.PUT_LINE ("Vamos a buscar mi vehiculo en la lista");

	V_COMIENZO := (Integer(ADA.CALENDAR.Seconds(ADA.CALENDAR.CLOCK)));
	
	--ADA.TEXT_IO.PUT_LINE ("Comienzo : " & Integer'Image(V_COMIENZO));

	V_VEHICULO_ENCONTRADO := Q_LISTA_VEHICULOS.F_ENCONTRAR_ELEMENTO (V_ELEMENTO => V_MI_VEHICULO,
								      	 V_LISTA => V_LISTA_VEHICULOS);

	Q_VEHICULO.Q_ACCIONES.P_MOSTRAR_VEHICULO (V_VEHICULO_ENCONTRADO);

	ADA.TEXT_IO.PUT_LINE("Numero de bastidor : " & Q_VEHICULO.F_OBTENER_NUMERO_BASTIDOR(V_VEHICULO_ENCONTRADO));
	Ada.Text_Io.Put_Line("Velocidad maxima   : " & Integer'Image(Q_VEHICULO.F_OBTENER_VELOCIDAD_MAXIMA(V_VEHICULO_ENCONTRADO)));
	Ada.Text_Io.Put_Line("Consumo urbano     : " & Float'Image(Q_VEHICULO.F_OBTENER_CONSUMO_URBANO(V_VEHICULO_ENCONTRADO)));
	Ada.Text_Io.Put_Line("Consumo carretera  : " & Float'Image(Q_VEHICULO.F_OBTENER_CONSUMO_CARRETERA(V_VEHICULO_ENCONTRADO)));

	V_FINAL := (Integer(ADA.CALENDAR.Seconds(ADA.CALENDAR.CLOCK)));
	
	--ADA.TEXT_IO.PUT_LINE ("Final : " & Integer'Image(V_FINAL));

	ADA.TEXT_IO.PUT_LINE ("Se ha tardado : " & Integer'Image(V_FINAL - V_COMIENZO) & " segundos en encontrar tu vehiculo");

	-- Vamos a inicializar la lista y comprobar que esta vacia.

	--Q_LISTA_VEHICULOS.P_INICIALIZAR_LISTA (V_LISTA_VEHICULOS);

	--if Q_LISTA_VEHICULOS.F_ESTA_VACIA_LISTA (V_LISTA_VEHICULOS) then

	--	ADA.TEXT_IO.PUT_LINE ("La lista esta vacia");
		
	--else

	--	ADA.TEXT_IO.PUT_LINE ("La lista no esta vacia");		

	--end if;

	-- Eliminar mi coche de la lista.

	Q_LISTA_VEHICULOS.P_ELIMINAR_ELEMENTO (V_ELEMENTO => V_MI_VEHICULO,
					       V_LISTA => V_LISTA_VEHICULOS);

	ADA.TEXT_IO.PUT_LINE
                ("El numero de vehiculos en la lista es : " &
                        Integer'Image(Q_LISTA_VEHICULOS.F_CUANTOS_ELEMENTOS_PUNTEROS(V_LISTA_VEHICULOS)));

	-- Mostrar la lista. No deberia salir mi vehiculo.

	--for I in 1 .. Q_LISTA_VEHICULOS.F_CUANTOS_ELEMENTOS_PUNTEROS(V_LISTA_VEHICULOS) loop

	--	Q_VEHICULO.P_MOSTRAR_VEHICULO (Q_LISTA_VEHICULOS.F_DEVOLVER_ELEMENTO (V_POSICION => I,
        --                                                                 	      V_LISTA => V_LISTA_VEHICULOS));
	
	--end loop;

	-- Mostrar el vehiculo 30000
	--Q_VEHICULO.P_MOSTRAR_VEHICULO (Q_LISTA_VEHICULOS.F_DEVOLVER_ELEMENTO (V_POSICION => C_NUMERO_VEHICULOS / 2,
        --                                                                      V_LISTA => V_LISTA_VEHICULOS));

	--Ada.Text_Io.Put_Line 
	--	("Velocidad maxima : " & 
	--		Integer'Image(Q_VEHICULO.F_OBTENER_VELOCIDAD_MAXIMA
	--				(Q_LISTA_VEHICULOS.F_DEVOLVER_ELEMENTO (V_POSICION => C_NUMERO_VEHICULOS / 2,
        --                                                                        V_LISTA => V_LISTA_VEHICULOS))));
	
exception

	when Q_LISTA_VEHICULOS.X_LISTA_LLENA =>

		ADA.TEXT_IO.PUT_LINE ("No se pueden meter mas vehiculos en la lista, capacidad maxima alcanzada");

	when Q_LISTA_VEHICULOS.X_ELEMENTO_NO_ENCONTRADO =>

		ADA.TEXT_IO.PUT_LINE ("No se ha encontrado el vehiculo");	

end m_prueba_generador_automatico_vehiculo;
--------------------------------------------------------------------------------------------------------------------------------------------
