-------------------------------------------------------------------------------------------------------------------------------------------
--
--      Fichero:        q_adaptacion_vehiculo.adb
--
--      Autor:          Hector Uhalte Bilbao
--
--      Fecha:          20/11/2017
--      
-------------------------------------------------------------------------------------------------------------------------------------------

with Input_Sources.File;
with Dom.Readers;
with Sax.Readers;
with Dom.Core;
with Dom.Core.Documents;
with Dom.Core.Nodes;
with Ada.Sequential_Io;
with Ada.Numerics.Discrete_Random;
with Ada.Text_Io;
with Ada.Characters.Latin_1;
with Ada.Float_Text_Io;

package body Q_ADAPTACION_VEHICULO is

	C_FICHERO_XML : constant String := "/home/hector/eclipse-workspace/ITS/vehiculos.xml";

        C_FICHERO_LOG_ADAPTACION : constant String := "/home/hector/ITS/log/log_adaptation_file";

	--------------------------------
	-- Cargar la adaptacion en un
	-- fichero binario
	--------------------------------
	procedure P_CARGAR_ADAPTACION is

		-- Descriptor de fichero.
                V_DESCRIPTOR_FICHERO_XML : Input_Sources.File.File_Input;

		-- Lector XML. Para usarlo en el parser de DOM
                V_LECTOR_XML : Dom.Readers.Tree_Reader;

		V_DOCUMENTO_XML : Dom.Core.Document;

		V_LISTA_VEHICULOS, V_LISTA_DATOS, V_LISTA_CARACTERISTICAS : Dom.Core.Node_List;

		V_VEHICULO, V_DATO, V_CARACTERISTICA : Dom.Core.Node;

		V_VEHICULO_ADAPTACION : T_VEHICULO_ADAPTACION;

		V_NOMBRE_MARCA, V_NOMBRE_MODELO: String (1 .. Q_VEHICULO.F_OBTENER_LONGITUD_MAXIMA_NOMBRE_MARCA_MODELO):=
                                Q_VEHICULO.F_OBTENER_MARCA_VACIA;

		package Q_VEHICULO_IO is new Ada.Sequential_IO(T_VEHICULO_ADAPTACION);

		V_FICHERO_VEHICULO : Q_VEHICULO_IO.File_Type;

	begin

		Q_VEHICULO_IO.Create (File => V_FICHERO_VEHICULO,
				      Name => "/home/hector/ITS/adaptacion/vehiculos.bin");

		Input_Sources.File.Set_Public_Id (Input => V_DESCRIPTOR_FICHERO_XML,
                                                  Id => C_FICHERO_LOG_ADAPTACION);

		Input_Sources.File.Open (Filename => C_FICHERO_XML,
                                         Input => V_DESCRIPTOR_FICHERO_XML);

		-- Estos "Set.Feature" habra que cambiarlos cuando se implemente los namespaces, y el chequeo de esquemas.
                Dom.Readers.Set_Feature (Parser => V_LECTOR_XML,
                                         Name => Sax.Readers.Validation_Feature,
                                         Value => False);

                Dom.Readers.Set_Feature (Parser => V_LECTOR_XML,
                                         Name => Sax.Readers.Namespace_Feature,
                                         Value => False);

		Dom.Readers.Parse (Parser => V_LECTOR_XML,
                                   Input => V_DESCRIPTOR_FICHERO_XML);

		Input_Sources.File.Close (V_DESCRIPTOR_FICHERO_XML);

		V_DOCUMENTO_XML := Dom.Readers.Get_Tree (V_LECTOR_XML);

		-- Obtener la lista de vehiculos adaptados.
                V_LISTA_VEHICULOS := Dom.Core.Documents.Get_Elements_By_Tag_Name (Doc => V_DOCUMENTO_XML,
                                                                                  Tag_Name => "its:datosVehiculo");


		-- Recorrer la lista de vehiculos adaptados.
                for I in 0 .. Dom.Core.Nodes.Length(V_LISTA_VEHICULOS) -1 loop

			V_VEHICULO := Dom.Core.Nodes.Item (List => V_LISTA_VEHICULOS,
                                                           Index => I);

			V_LISTA_DATOS := Dom.Core.Nodes.Child_Nodes (V_VEHICULO);

			for J in 0 .. Dom.Core.Nodes.Length(V_LISTA_DATOS) -1 loop

				V_DATO := Dom.Core.Nodes.Item (List => V_LISTA_DATOS,
                                                               Index => J);

				if Dom.Core.Nodes.Node_Name(V_DATO) = "its:marcaVehiculo" then

					-- Obtener la marca
                                        V_NOMBRE_MARCA := Q_VEHICULO.F_OBTENER_MARCA_VACIA;

                                        V_NOMBRE_MARCA
                                        	(V_NOMBRE_MARCA'First ..
                                                 Dom.Core.Nodes.Node_Value(Dom.Core.Nodes.First_Child(V_DATO))'Length) :=
                                                	Dom.Core.Nodes.Node_Value(Dom.Core.Nodes.First_Child(V_DATO));

					V_VEHICULO_ADAPTACION.R_NOMBRE_MARCA (1 .. V_NOMBRE_MARCA'Length) := V_NOMBRE_MARCA;

				end if;

				if Dom.Core.Nodes.Node_Name(V_DATO) = "its:modeloVehiculo" then

                                        -- Obtener la marca
                                        V_NOMBRE_MODELO := Q_VEHICULO.F_OBTENER_MARCA_VACIA;

                                        V_NOMBRE_MODELO
                                                (V_NOMBRE_MODELO'First ..
                                                 Dom.Core.Nodes.Node_Value(Dom.Core.Nodes.First_Child(V_DATO))'Length) :=
                                                        Dom.Core.Nodes.Node_Value(Dom.Core.Nodes.First_Child(V_DATO));

                                        V_VEHICULO_ADAPTACION.R_NOMBRE_MODELO (1 .. V_NOMBRE_MODELO'Length) := V_NOMBRE_MODELO;

                                end if;

				if Dom.Core.Nodes.Node_Name(V_DATO) = "its:caracteristicasVehiculo" then

					V_LISTA_CARACTERISTICAS := Dom.Core.Nodes.Child_Nodes (V_DATO);
		
					for K in 0 .. Dom.Core.Nodes.Length(V_LISTA_CARACTERISTICAS) -1 loop

						V_CARACTERISTICA := Dom.Core.Nodes.Item (List => V_LISTA_CARACTERISTICAS,
                                                                                         Index => K);

						if Dom.Core.Nodes.Node_Name(V_CARACTERISTICA) = "its:velocidadMaxima" then

							V_VEHICULO_ADAPTACION.R_CARACTERISTICAS.R_VELOCIDAD_MAXIMA := 
								Integer'Value
                                                                        (Dom.Core.Nodes.Node_Value
                                                                                (Dom.Core.Nodes.First_Child(V_CARACTERISTICA)));
						
						end if;

						if Dom.Core.Nodes.Node_Name(V_CARACTERISTICA) = "its:longitud" then

							V_VEHICULO_ADAPTACION.R_CARACTERISTICAS.R_LONGITUD := 
								Float'Value
                                                                        (Dom.Core.Nodes.Node_Value
                                                                                (Dom.Core.Nodes.First_Child(V_CARACTERISTICA)));                                               
                                                end if;

						if Dom.Core.Nodes.Node_Name(V_CARACTERISTICA) = "its:altura" then

							V_VEHICULO_ADAPTACION.R_CARACTERISTICAS.R_ALTURA :=
								Float'Value
                                                                        (Dom.Core.Nodes.Node_Value
                                                                                (Dom.Core.Nodes.First_Child(V_CARACTERISTICA))); 
                                                
                                                end if;

						if Dom.Core.Nodes.Node_Name(V_CARACTERISTICA) = "its:consumoUrbano" then

							V_VEHICULO_ADAPTACION.R_CARACTERISTICAS.R_CONSUMO_URBANO := 
								Float'Value
                                                                        (Dom.Core.Nodes.Node_Value
                                                                                (Dom.Core.Nodes.First_Child(V_CARACTERISTICA)));

                                                end if;

                                                if Dom.Core.Nodes.Node_Name(V_CARACTERISTICA) = "its:consumoCarretera" then

							V_VEHICULO_ADAPTACION.R_CARACTERISTICAS.R_CONSUMO_CARRETERA :=
								Float'Value
                                                                        (Dom.Core.Nodes.Node_Value
                                                                                (Dom.Core.Nodes.First_Child(V_CARACTERISTICA)));
                                                
						end if;

					end loop;

				end if;

			end loop;

		-- Guardar el V_VEHICULO_ADAPTACION en un fichero binario vehiculos.bin
		Q_VEHICULO_IO.Write (File => V_FICHERO_VEHICULO,
				     Item => V_VEHICULO_ADAPTACION);

		end loop;

		Dom.Core.Free (V_LISTA_VEHICULOS);
                                                
		Dom.Readers.Free (V_LECTOR_XML);

		Q_VEHICULO_IO.Close (V_FICHERO_VEHICULO);

	end P_CARGAR_ADAPTACION;
	-------------------------------

	----------------------------------------------------------------------------------------------------
	-- Procedimiento para leer obtener los vehiculos guardados en el fichero binario de adaptacion
	-- vehiculos.bin y guardarlos en un registro.
	----------------------------------------------------------------------------------------------------
	procedure P_LEER_ADAPTACION (V_VEHICULO_ADAPTACION_REGISTRO : out T_VEHICULO_ADAPTACION_REGISTRO) is
	
		package Q_VEHICULO_IO is new Ada.Sequential_IO(T_VEHICULO_ADAPTACION);

		V_FICHERO_VEHICULO : Q_VEHICULO_IO.File_Type;

		V_VEHICULO_ADAPTACION : T_VEHICULO_ADAPTACION;

		I : Integer := 0;

	begin

		Q_VEHICULO_IO.Open (File => V_FICHERO_VEHICULO,
				    Mode => Q_VEHICULO_IO.In_File,
				    Name => "/home/hector/ITS/adaptacion/vehiculos.bin");

		-- Crear un array con los vehiculos adaptados. Como van a ser 1000 como mucho con un array es suficiente.
		-- Leer el fichero binario de adaptacion

		while not Q_VEHICULO_IO.End_Of_File(V_FICHERO_VEHICULO) loop	

			I := I + 1;	

			Q_VEHICULO_IO.Read (File => V_FICHERO_VEHICULO,
					    Item => V_VEHICULO_ADAPTACION);

			V_VEHICULO_ADAPTACION_REGISTRO.R_VEHICULO_ADAPTACION_ARRAY (I) := V_VEHICULO_ADAPTACION;
		
		end loop;

		V_VEHICULO_ADAPTACION_REGISTRO.R_NUMERO_VEHICULOS := I;

		Q_VEHICULO_IO.Close (V_FICHERO_VEHICULO);

	end P_LEER_ADAPTACION;
	----------------------

	----------------------------------------------------------------------
	function F_EXISTE_MARCA (V_NOMBRE_MARCA : in String) return Boolean is

		V_MARCA_ADAPTADA : Boolean := False;		

		V_VEHICULO_ADAPTACION_REGISTRO : T_VEHICULO_ADAPTACION_REGISTRO;

	begin

		P_LEER_ADAPTACION (V_VEHICULO_ADAPTACION_REGISTRO);

		for I in 1 .. V_VEHICULO_ADAPTACION_REGISTRO.R_NUMERO_VEHICULOS loop

			if V_VEHICULO_ADAPTACION_REGISTRO.R_VEHICULO_ADAPTACION_ARRAY(I).R_NOMBRE_MARCA (1 .. V_NOMBRE_MARCA'Length) = 
			   V_NOMBRE_MARCA then

				V_MARCA_ADAPTADA := True;
				exit;

			end if;

		end loop;

		return V_MARCA_ADAPTADA;

	end F_EXISTE_MARCA;
	----------------------------------------------------------------------

	------------------------------------------------------------------------
	function F_EXISTE_MODELO (V_NOMBRE_MARCA : in String;
				  V_NOMBRE_MODELO : in String) return Boolean is

		V_MODELO_ADAPTADO : Boolean := False;

		V_VEHICULO_ADAPTACION_REGISTRO : T_VEHICULO_ADAPTACION_REGISTRO;

	begin

		P_LEER_ADAPTACION (V_VEHICULO_ADAPTACION_REGISTRO);

		for I in 1 .. V_VEHICULO_ADAPTACION_REGISTRO.R_NUMERO_VEHICULOS loop

                        if V_VEHICULO_ADAPTACION_REGISTRO.R_VEHICULO_ADAPTACION_ARRAY(I).R_NOMBRE_MARCA (1 .. V_NOMBRE_MARCA'Length) =
                           V_NOMBRE_MARCA then

				if V_VEHICULO_ADAPTACION_REGISTRO.R_VEHICULO_ADAPTACION_ARRAY(I).R_NOMBRE_MODELO 
				   (1 .. V_NOMBRE_MODELO'Length) = V_NOMBRE_MODELO then

                                	V_MODELO_ADAPTADO := True;
                                	exit;

				end if;

                        end if;

                end loop;

		return V_MODELO_ADAPTADO;

	end F_EXISTE_MODELO;
	------------------------------------------------------------------------
	
	-----------------------------------------------------------------------------------------
	-- Funcion para obtener un vehiculo (con sus datos) a partir de la marca y el modelo
	-----------------------------------------------------------------------------------------
	function F_OBTENER_VEHICULO (V_NOMBRE_MARCA : in String;
				     V_NOMBRE_MODELO : in String) return T_VEHICULO_ADAPTACION is

		V_VEHICULO_ADAPTACION_REGISTRO : T_VEHICULO_ADAPTACION_REGISTRO;

		V_VEHICULO_ADAPTACION : T_VEHICULO_ADAPTACION;

	begin

		P_LEER_ADAPTACION (V_VEHICULO_ADAPTACION_REGISTRO);

		for I in 1 .. V_VEHICULO_ADAPTACION_REGISTRO.R_NUMERO_VEHICULOS loop

                        if V_VEHICULO_ADAPTACION_REGISTRO.R_VEHICULO_ADAPTACION_ARRAY(I).R_NOMBRE_MARCA (1 .. V_NOMBRE_MARCA'Length) =
                           V_NOMBRE_MARCA then

                                if V_VEHICULO_ADAPTACION_REGISTRO.R_VEHICULO_ADAPTACION_ARRAY(I).R_NOMBRE_MODELO
                                   (1 .. V_NOMBRE_MODELO'Length) = V_NOMBRE_MODELO then

                                        V_VEHICULO_ADAPTACION := V_VEHICULO_ADAPTACION_REGISTRO.R_VEHICULO_ADAPTACION_ARRAY(I);
                                        exit;

                                end if;

                        end if;

                end loop;

		return V_VEHICULO_ADAPTACION;

	end F_OBTENER_VEHICULO;
	------------------------------------------------------------------------------------------

	-----------------------------------------------------------------------------------
	function F_OBTENER_VELOCIDAD_MAXIMA (V_NOMBRE_MARCA : in String;
					     V_NOMBRE_MODELO : in String) return Integer is

		V_VEHICULO_ADAPTACION : T_VEHICULO_ADAPTACION;

	begin

		V_VEHICULO_ADAPTACION := F_OBTENER_VEHICULO (V_NOMBRE_MARCA => V_NOMBRE_MARCA,
							     V_NOMBRE_MODELO => V_NOMBRE_MODELO);

		return V_VEHICULO_ADAPTACION.R_CARACTERISTICAS.R_VELOCIDAD_MAXIMA;

	end F_OBTENER_VELOCIDAD_MAXIMA;
	-----------------------------------------------------------------------------------

	-------------------------------------------------------------------------
	function F_OBTENER_LONGITUD (V_NOMBRE_MARCA : in String;
				     V_NOMBRE_MODELO : in String) return Float is

		V_VEHICULO_ADAPTACION : T_VEHICULO_ADAPTACION;

	begin

		V_VEHICULO_ADAPTACION := F_OBTENER_VEHICULO (V_NOMBRE_MARCA => V_NOMBRE_MARCA,
                                                             V_NOMBRE_MODELO => V_NOMBRE_MODELO);

		return V_VEHICULO_ADAPTACION.R_CARACTERISTICAS.R_LONGITUD;

	end F_OBTENER_LONGITUD;
	-------------------------------------------------------------------------

	-----------------------------------------------------------------------
        function F_OBTENER_ALTURA (V_NOMBRE_MARCA : in String;
                                   V_NOMBRE_MODELO : in String) return Float is

                V_VEHICULO_ADAPTACION : T_VEHICULO_ADAPTACION;

        begin

                V_VEHICULO_ADAPTACION := F_OBTENER_VEHICULO (V_NOMBRE_MARCA => V_NOMBRE_MARCA,
                                                             V_NOMBRE_MODELO => V_NOMBRE_MODELO);

                return V_VEHICULO_ADAPTACION.R_CARACTERISTICAS.R_ALTURA;

        end F_OBTENER_ALTURA;
        -----------------------------------------------------------------------

	-------------------------------------------------------------------------------
        function F_OBTENER_CONSUMO_URBANO (V_NOMBRE_MARCA : in String;
                                           V_NOMBRE_MODELO : in String) return Float is

                V_VEHICULO_ADAPTACION : T_VEHICULO_ADAPTACION;

        begin

                V_VEHICULO_ADAPTACION := F_OBTENER_VEHICULO (V_NOMBRE_MARCA => V_NOMBRE_MARCA,
                                                             V_NOMBRE_MODELO => V_NOMBRE_MODELO);

                return V_VEHICULO_ADAPTACION.R_CARACTERISTICAS.R_CONSUMO_URBANO;

        end F_OBTENER_CONSUMO_URBANO;
        -------------------------------------------------------------------------------

	-----------------------------------------------------------------------
        function F_OBTENER_CONSUMO_CARRETERA (V_NOMBRE_MARCA : in String;
                                              V_NOMBRE_MODELO : in String) return Float is

                V_VEHICULO_ADAPTACION : T_VEHICULO_ADAPTACION;

        begin

                V_VEHICULO_ADAPTACION := F_OBTENER_VEHICULO (V_NOMBRE_MARCA => V_NOMBRE_MARCA,
                                                             V_NOMBRE_MODELO => V_NOMBRE_MODELO);

                return V_VEHICULO_ADAPTACION.R_CARACTERISTICAS.R_CONSUMO_CARRETERA;

        end F_OBTENER_CONSUMO_CARRETERA;
        -----------------------------------------------------------------------

	-----------------------------------------------------
	function F_OBTENER_NUMERO_VEHICULOS return Integer is
	
		V_VEHICULO_ADAPTACION_REGISTRO : T_VEHICULO_ADAPTACION_REGISTRO;

	begin

		P_LEER_ADAPTACION (V_VEHICULO_ADAPTACION_REGISTRO);

		return V_VEHICULO_ADAPTACION_REGISTRO.R_NUMERO_VEHICULOS;
	
	end F_OBTENER_NUMERO_VEHICULOS;
	-------------------------------

	----------------------------------------------------------------------------
        procedure P_OBTENER_MARCA_MODELO_ALEATORIO (V_NOMBRE_MARCA : out String;
                                                    V_NOMBRE_MODELO : out String) is
	
		subtype T_RANGO_NUMERO_VEHICULOS is Integer range 1 .. F_OBTENER_NUMERO_VEHICULOS;

                package Q_RANDOM is new Ada.Numerics.Discrete_Random (T_RANGO_NUMERO_VEHICULOS);

		V_SEMILLA : Q_RANDOM.Generator;

		V_INDICE_VEHICULO_ALEATORIO : Integer := 0;

		V_VEHICULO_ADAPTACION_REGISTRO : T_VEHICULO_ADAPTACION_REGISTRO;

	begin

		Q_RANDOM.Reset(V_SEMILLA);

		V_INDICE_VEHICULO_ALEATORIO := Q_RANDOM.Random(V_SEMILLA);

		P_LEER_ADAPTACION (V_VEHICULO_ADAPTACION_REGISTRO);

		for I in 1 .. V_VEHICULO_ADAPTACION_REGISTRO.R_NUMERO_VEHICULOS loop

			if I = V_INDICE_VEHICULO_ALEATORIO then
			
				-- Obtener la marca
                                V_NOMBRE_MARCA := Q_VEHICULO.F_OBTENER_MARCA_VACIA;

                                V_NOMBRE_MARCA 
					(V_NOMBRE_MARCA'First .. 
					 V_VEHICULO_ADAPTACION_REGISTRO.R_VEHICULO_ADAPTACION_ARRAY(I).R_NOMBRE_MARCA'Length) :=
                V_VEHICULO_ADAPTACION_REGISTRO.R_VEHICULO_ADAPTACION_ARRAY(I).R_NOMBRE_MARCA;
            

				-- Obtener el modelo
                                V_NOMBRE_MODELO := Q_VEHICULO.F_OBTENER_MODELO_VACIO;

				V_NOMBRE_MODELO 
					(V_NOMBRE_MODELO'First .. 
					 V_VEHICULO_ADAPTACION_REGISTRO.R_VEHICULO_ADAPTACION_ARRAY(I).R_NOMBRE_MODELO'Length) := 
						V_VEHICULO_ADAPTACION_REGISTRO.R_VEHICULO_ADAPTACION_ARRAY(I).R_NOMBRE_MODELO;

				exit;
			end if;

		end loop;

	end P_OBTENER_MARCA_MODELO_ALEATORIO;
	----------------------------------------------------------------------------

	-------------------------
	procedure P_VISUALIZAR is

		V_VEHICULO_ADAPTACION_REGISTRO : T_VEHICULO_ADAPTACION_REGISTRO;

		V_VEHICULO_ADAPTACION : T_VEHICULO_ADAPTACION;

	begin

		P_LEER_ADAPTACION (V_VEHICULO_ADAPTACION_REGISTRO);

		for I in 1 .. V_VEHICULO_ADAPTACION_REGISTRO.R_NUMERO_VEHICULOS loop

			V_VEHICULO_ADAPTACION := V_VEHICULO_ADAPTACION_REGISTRO.R_VEHICULO_ADAPTACION_ARRAY(I);

			Ada.Text_Io.Put_Line 
           (" Marca  => " & V_VEHICULO_ADAPTACION.R_NOMBRE_MARCA(1 .. V_VEHICULO_ADAPTACION.R_NOMBRE_MARCA'Length));

			Ada.Text_Io.Put_Line
				(" Modelo => " & V_VEHICULO_ADAPTACION.R_NOMBRE_MODELO(1 .. V_VEHICULO_ADAPTACION.R_NOMBRE_MODELO'Length));

			Ada.Text_Io.Put_Line 
				(Ada.Characters.Latin_1.HT & " Velocidad Maxima  =>" & 
					Integer'Image(V_VEHICULO_ADAPTACION.R_CARACTERISTICAS.R_VELOCIDAD_MAXIMA));

			Ada.Text_Io.Put 
				(Ada.Characters.Latin_1.HT & " Longitud          => "); 

			Ada.Float_Text_Io.Put (Item => V_VEHICULO_ADAPTACION.R_CARACTERISTICAS.R_LONGITUD, 
					       Fore => 1,
					       Aft => 3,
					       Exp => 0);

			Ada.Text_Io.Put_Line (""); 

			Ada.Text_Io.Put
                                (Ada.Characters.Latin_1.HT & " Altura            => ");

                        Ada.Float_Text_Io.Put (Item => V_VEHICULO_ADAPTACION.R_CARACTERISTICAS.R_ALTURA, 
                                               Fore => 1,
                                               Aft => 3,
                                               Exp => 0);

                        Ada.Text_Io.Put_Line ("");

			Ada.Text_Io.Put
                                (Ada.Characters.Latin_1.HT & " Consumo Urbano    => ");
                        
                        Ada.Float_Text_Io.Put (Item => V_VEHICULO_ADAPTACION.R_CARACTERISTICAS.R_CONSUMO_URBANO,   
                                               Fore => 1,
                                               Aft => 2,
                                               Exp => 0);

                        Ada.Text_Io.Put_Line ("");
	
			Ada.Text_Io.Put
                                (Ada.Characters.Latin_1.HT & " Consumo Carretera => ");

                        Ada.Float_Text_Io.Put (Item => V_VEHICULO_ADAPTACION.R_CARACTERISTICAS.R_CONSUMO_CARRETERA,
                                               Fore => 1,
                                               Aft => 2,
                                               Exp => 0);

                        Ada.Text_Io.Put_Line ("");
	
			Ada.Text_Io.Put_Line ("--");

		end loop;

	end P_VISUALIZAR;
	-------------------------

end Q_ADAPTACION_VEHICULO;
-------------------------------------------------------------------------------------------------------------------------------------------
