--------------------------------------------------------------------------------------------------------------------------------------------
--
--	Fichero:	q_log.adb
--
--	Autor:		Hector Uhalte Bilbao
--
--	Fecha:		13/9/2017
--
--------------------------------------------------------------------------------------------------------------------------------------------

with ADA.TEXT_IO;
with ADA.CALENDAR;
with ADA.STRINGS.FIXED;

package body Q_LOG is
	
	--------------------------------------------
	function F_PONER_STAMP_TIME return String is

		V_TIME : ADA.CALENDAR.TIME := ADA.CALENDAR.CLOCK;
		V_HORA : Integer := Integer(ADA.CALENDAR.Seconds(V_TIME)) / 3600;
		V_MINUTOS : Integer := (Integer(ADA.CALENDAR.Seconds(V_TIME)) - V_HORA * 3600) / 60;
		V_SEGUNDOS : Integer := Integer(ADA.CALENDAR.Seconds(V_TIME)) - V_HORA * 3600 - V_MINUTOS * 60;

	begin

		return ADA.STRINGS.FIXED.Trim(Integer'Image(ADA.CALENDAR.Year(V_TIME)), ADA.STRINGS.Left) & "/" & 
			ADA.STRINGS.FIXED.Trim(Integer'Image(ADA.CALENDAR.Month(V_TIME)), ADA.STRINGS.Left) & "/" & 
			ADA.STRINGS.FIXED.Trim(Integer'Image(ADA.CALENDAR.Day(V_TIME)), ADA.STRINGS.Left) & "-" & 
			ADA.STRINGS.FIXED.Trim(Integer'Image(V_HORA), ADA.STRINGS.Left) & ":" & 
			ADA.STRINGS.FIXED.Trim(Integer'Image(V_MINUTOS), ADA.STRINGS.Left) & ":" &
			ADA.STRINGS.FIXED.Trim(Integer'Image(V_SEGUNDOS), ADA.STRINGS.Left);

	end F_PONER_STAMP_TIME;
	-----------------------

	----------------------------------------------------------
	-- Procedimiento para escribir un string en un fichero 
	-- dado, pensado para ser usado por todos los paquetes 
	-- para escribir en ficheros log
	----------------------------------------------------------
	procedure P_ESCRIBIR_LOG (V_STRING : in String;
				  V_NOMBRE_FICHERO : in String) is

		V_FICHERO : ADA.TEXT_IO.File_Type;

	begin

		ADA.TEXT_IO.OPEN (File => V_FICHERO,
				  Mode => ADA.TEXT_IO.Append_File,
				  Name => V_NOMBRE_FICHERO,
				  Form => "");

		ADA.TEXT_IO.PUT_LINE (File => V_FICHERO,
				      Item => F_PONER_STAMP_TIME & " - " & V_STRING);
	
		ADA.TEXT_IO.CLOSE (V_FICHERO);

	exception

		when ADA.TEXT_IO.Name_Error =>

			ADA.TEXT_IO.CREATE (File => V_FICHERO,
					    Mode => ADA.TEXT_IO.Out_File,
					    Name => V_NOMBRE_FICHERO,
					    Form => "");

			ADA.TEXT_IO.PUT_LINE (File => V_FICHERO,
                                      	      Item => F_PONER_STAMP_TIME & " - " & V_STRING);

			ADA.TEXT_IO.CLOSE (V_FICHERO);

	end P_ESCRIBIR_LOG;
	-------------------------------------------------------------------

end Q_LOG;
--------------------------------------------------------------------------------------------------------------------------------------------
