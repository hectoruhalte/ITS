--------------------------------------------------------------------------------------------------------------------------------------------
--
--      Fichero:        q_generico_lista.adb
--
--      Autor:          Hector Uhalte Bilbao
--
--      Fecha:          18/9/2017
--      
--------------------------------------------------------------------------------------------------------------------------------------------

package body Q_GENERICO_LISTA is

	--------------------------------------------------------------------
	function F_ESTA_VACIA_LISTA (V_LISTA : in T_LISTA) return Boolean is
	
		V_ESTA_VACIA_LISTA : Boolean := False;

	begin
		
		if (V_LISTA.R_CELDA_INICIAL = null) then

			V_ESTA_VACIA_LISTA := True;
			
		end if;
			
		return V_ESTA_VACIA_LISTA;	

	end F_ESTA_VACIA_LISTA;
	--------------------------------------------------------------------

	-----------------------------------------------------------
	-- Procedimiento para inicializar, o vaciar la lista
	-- El puntero de la celda inicial apuntara a null.
	-----------------------------------------------------------
	procedure P_INICIALIZAR_LISTA (V_LISTA : in out T_LISTA) is

	begin

		V_LISTA.R_CELDA_INICIAL := null;

		V_LISTA.R_NUMERO_ELEMENTOS := 0;

	end P_INICIALIZAR_LISTA;
	-----------------------------------------------------------

	-----------------------------------------------------------
	-- Procedimiento para insertar un elemento, al principio
	-- de la lista
	-----------------------------------------------------------
	procedure P_INSERTAR_ELEMENTO (V_ELEMENTO : in T_ELEMENTO;
				       V_LISTA : in out T_LISTA) is

		V_PUNTERO : T_PUNTERO_A_CELDA := new T_CELDA'(R_ELEMENTO => V_ELEMENTO,
							      R_PUNTERO_A_CELDA => V_LISTA.R_CELDA_INICIAL);
	
	begin

		if V_LISTA.R_NUMERO_ELEMENTOS <= V_MAXIMO_NUMERO_ELEMENTOS then

			V_LISTA.R_CELDA_INICIAL := V_PUNTERO;
			V_LISTA.R_NUMERO_ELEMENTOS := V_LISTA.R_NUMERO_ELEMENTOS + 1;

		else

			raise X_LISTA_LLENA;

		end if;

	end P_INSERTAR_ELEMENTO;
	-----------------------------------------------------------
		
	-----------------------------------------------------------
	-- Procedimiento para eliminar un elemento de la lista
	-----------------------------------------------------------
	procedure P_ELIMINAR_ELEMENTO (V_ELEMENTO : in T_ELEMENTO;
				       V_LISTA : in out T_LISTA) is

		-- Variable para contener el puntero para recorrer la lista
		-- Se inicializa el puntero a la primera celda.
		V_PUNTERO : T_PUNTERO_A_CELDA := V_LISTA.R_CELDA_INICIAL;

	begin

		-- Comprobar que la lista no esta vacia
		if F_ESTA_VACIA_LISTA(V_LISTA) then
			
			-- Elevar una excepcion. No se puede eliminar un elemento de la lista, si esta vacia.
			raise X_NO_SE_PUEDE_ELIMINAR_ELEMENTO_LISTA_ESTA_VACIA;

		else
	
			-- Que pasa si quiero borrar el primer elemento de la lista?
			-- Habra que cambiar la celda inicial
			-- Mientras el Elemento este en la primera posicion, eliminar ese elemento
			while V_ELEMENTO = V_PUNTERO.R_ELEMENTO loop

				V_LISTA.R_CELDA_INICIAL := V_PUNTERO.R_PUNTERO_A_CELDA;
				
				V_PUNTERO := V_LISTA.R_CELDA_INICIAL;

				V_LISTA.R_NUMERO_ELEMENTOS := V_LISTA.R_NUMERO_ELEMENTOS - 1;

				exit when V_LISTA.R_NUMERO_ELEMENTOS = 0;

			end loop;

			-- Una vez que seguro no hay que eliminar el primer elemento.
                       	-- Recorrer la lista. Si no se encuentra el elemento no se hace nada.			
			
			while (V_PUNTERO /= null and then V_PUNTERO.R_PUNTERO_A_CELDA /=null) loop

				-- Comprobar si el elemento a borrar es el siguiente.
				if V_ELEMENTO = V_PUNTERO.R_PUNTERO_A_CELDA.R_ELEMENTO then

					-- Si lo es, cambio el puntero al puntero del elemento a borrar 
					-- (que apunta al siguiente de la lista)
					V_PUNTERO.R_PUNTERO_A_CELDA := V_PUNTERO.R_PUNTERO_A_CELDA.R_PUNTERO_A_CELDA;

					-- Reducir el numero de elementos.
                                        V_LISTA.R_NUMERO_ELEMENTOS := V_LISTA.R_NUMERO_ELEMENTOS - 1;

					-- Opcional. De momento seguimos buscando, por si hay mas elementos en la lista.
					-- exit;

				else
					-- Seguir buscando
					V_PUNTERO := V_PUNTERO.R_PUNTERO_A_CELDA;
						
				end if;				

			end loop;

		end if;

	end P_ELIMINAR_ELEMENTO;
	-----------------------------------------------------------

	---------------------------------------------------------------------
	-- Funcion para devolver el numero de elementos que componen la lista
	---------------------------------------------------------------------
	function F_CUANTOS_ELEMENTOS (V_LISTA : in T_LISTA) return Natural is

	begin

		return V_LISTA.R_NUMERO_ELEMENTOS;

	end F_CUANTOS_ELEMENTOS;
	---------------------------------------------------------------------

	------------------------------------------------------------------------------
        function F_CUANTOS_ELEMENTOS_PUNTEROS (V_LISTA : in T_LISTA) return Integer is

                V_PUNTERO : T_PUNTERO_A_CELDA := V_LISTA.R_CELDA_INICIAL;
                V_CONTADOR : Integer := 0;

        begin

                while V_PUNTERO /= null loop

                        V_PUNTERO := V_PUNTERO.R_PUNTERO_A_CELDA;
                        V_CONTADOR := V_CONTADOR + 1;

                end loop;

                return V_CONTADOR;

        end F_CUANTOS_ELEMENTOS_PUNTEROS;
        ------------------------------------------------------------------------------

	-------------------------------------------------------------------------
	function F_ENCONTRAR_ELEMENTO (V_ELEMENTO : in T_ELEMENTO;
				       V_LISTA : in T_LISTA) return T_ELEMENTO is

		-- Variable para contener el puntero para recorrer la lista
                -- Se inicializa el puntero a la primera celda.
                V_PUNTERO : T_PUNTERO_A_CELDA := V_LISTA.R_CELDA_INICIAL;
	
	begin

		-- Comprobar que la lista no esta vacia
                if F_ESTA_VACIA_LISTA(V_LISTA) then

                        -- Elevar una excepcion. No se puede eliminar un elemento de la lista, si esta vacia.
                        raise X_NO_SE_PUEDE_BUSCAR_ELEMENTO_LISTA_ESTA_VACIA;

                else

			while (V_PUNTERO /= null) loop

				if V_ELEMENTO = V_PUNTERO.R_ELEMENTO then

					-- Elemento encontrado.
					return V_PUNTERO.R_ELEMENTO;

				end if;

				-- Elemento no encontrado => Seguir buscando.
				V_PUNTERO := V_PUNTERO.R_PUNTERO_A_CELDA;

			end loop;

			--Al finalizar el recorrido por la lista, si llegamos a este punto es que no se ha encontrado el elemento.
			raise X_ELEMENTO_NO_ENCONTRADO;

		end if;

	end F_ENCONTRAR_ELEMENTO;
	-------------------------------------------------------------------------

	------------------------------------------------------------------------
	function F_DEVOLVER_ELEMENTO (V_POSICION : in Natural;
				      V_LISTA : in T_LISTA) return T_ELEMENTO is

		V_PUNTERO : T_PUNTERO_A_CELDA := V_LISTA.R_CELDA_INICIAL;
	
	begin

		--Si la lista esta vacia o la posicion es mayor que el numero de elementos. Elevar excepcion
		if F_ESTA_VACIA_LISTA(V_LISTA) then

			raise X_NO_SE_PUEDE_DEVOLVER_ELEMENTO_LISTA_VACIA; 

		elsif V_POSICION > V_LISTA.R_NUMERO_ELEMENTOS then

			raise X_POSICION_MAYOR_NUMERO_ELEMENTOS;			

		else

			for I in 1 .. V_POSICION-1 loop

				V_PUNTERO := V_PUNTERO.R_PUNTERO_A_CELDA;

			end loop;

			return V_PUNTERO.R_ELEMENTO;

		end if;

	end F_DEVOLVER_ELEMENTO;
	------------------------------------------------------------------------

	---------------------------------------------------------------------
	function F_POSICION_ELEMENTO (V_ELEMENTO : in T_ELEMENTO;
				      V_LISTA : in T_LISTA) return Natural is

		V_POSICION : Natural := 1;

		-- Variable para contener el puntero para recorrer la lista
                -- Se inicializa el puntero a la primera celda.
                V_PUNTERO : T_PUNTERO_A_CELDA := V_LISTA.R_CELDA_INICIAL;

	begin

		-- Comprobar que la lista no esta vacia
                if F_ESTA_VACIA_LISTA(V_LISTA) then

                        -- Elevar una excepcion. No se puede eliminar un elemento de la lista, si esta vacia.
                        raise X_NO_SE_PUEDE_BUSCAR_ELEMENTO_LISTA_ESTA_VACIA;

                else

                        while (V_PUNTERO /= null) loop

                                if V_ELEMENTO = V_PUNTERO.R_ELEMENTO then

                                        -- Elemento encontrado. Devolver posicion
                                        return V_POSICION;

                                end if;

                                -- Elemento no encontrado => Seguir buscando.
                                V_PUNTERO := V_PUNTERO.R_PUNTERO_A_CELDA;

				V_POSICION := V_POSICION + 1;

                        end loop;

                        --Al finalizar el recorrido por la lista, si llegamos a este punto es que no se ha encontrado el elemento.
                        raise X_ELEMENTO_NO_ENCONTRADO;

                end if;

	end F_POSICION_ELEMENTO;
	---------------------------------------------------------------------

	--------------------------------------------------------------------------
	function F_ESTA_ELEMENTO_EN_LISTA (V_ELEMENTO : in T_ELEMENTO;
					   V_LISTA : in T_LISTA) return Boolean is

		V_ELEMENTO_AUX : T_ELEMENTO;

	begin

		V_ELEMENTO_AUX := F_ENCONTRAR_ELEMENTO (V_ELEMENTO => V_ELEMENTO,
							V_LISTA => V_LISTA);

		return True;

	exception

		when X_NO_SE_PUEDE_BUSCAR_ELEMENTO_LISTA_ESTA_VACIA | X_ELEMENTO_NO_ENCONTRADO =>

			return False;

	end F_ESTA_ELEMENTO_EN_LISTA;
	--------------------------------------------------------------------------

end Q_GENERICO_LISTA;
--------------------------------------------------------------------------------------------------------------------------------------------
