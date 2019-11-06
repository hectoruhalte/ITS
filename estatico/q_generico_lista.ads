--------------------------------------------------------------------------------------------------------------------------------------------
--
--      Fichero:        q_generico_lista.ads
--
--      Autor:          Hector Uhalte Bilbao
--
--      Fecha:          18/9/2017
--      
--------------------------------------------------------------------------------------------------------------------------------------------

-- Paquete generico para formar listas simplemente enlazadas con punteros.
-- En los paquetes genericos, no deberia aparecer ningun elemento del sistema (nada de vehiculos, tramos, trayectos ...)

generic

	-- Para instanciar este paquete generico, hara falta, en principio, pasar el tipo de elemento a guardar en las listas.
	type T_ELEMENTO is private;
	
	with function "=" (V_ELEMENTO_1 : in T_ELEMENTO;
		      	   V_ELEMENTO_2 : in T_ELEMENTO) return Boolean;

	V_MAXIMO_NUMERO_ELEMENTOS : Natural;

package Q_GENERICO_LISTA is

	X_LISTA_LLENA : Exception;
	X_NO_SE_PUEDE_ELIMINAR_ELEMENTO_LISTA_ESTA_VACIA : Exception;
	X_NO_SE_PUEDE_BUSCAR_ELEMENTO_LISTA_ESTA_VACIA : Exception;
	X_NO_SE_PUEDE_DEVOLVER_ELEMENTO_LISTA_VACIA : Exception;
	X_ELEMENTO_NO_ENCONTRADO : Exception;
	X_POSICION_MAYOR_NUMERO_ELEMENTOS : Exception;

	type T_LISTA is private;
	
	type T_PUNTERO_A_CELDA is private;

	C_PUNTERO_A_CELDA_INICIAL : constant T_PUNTERO_A_CELDA;

	function F_ESTA_VACIA_LISTA (V_LISTA : in T_LISTA) return Boolean;

	procedure P_INICIALIZAR_LISTA (V_LISTA : in out T_LISTA);

	procedure P_INSERTAR_ELEMENTO (V_ELEMENTO : in T_ELEMENTO;
				       V_LISTA : in out T_LISTA);

	procedure P_ELIMINAR_ELEMENTO (V_ELEMENTO : in T_ELEMENTO;
				       V_LISTA : in out T_LISTA);

	function F_CUANTOS_ELEMENTOS (V_LISTA : in T_LISTA) return Natural;

	function F_CUANTOS_ELEMENTOS_PUNTEROS (V_LISTA : in T_LISTA) return Integer;

	-- Se le pasara un elemento que tendra el parametro por el que realizar la busqueda, (pasado a traves de la funcion "=").
	-- Esta funcion buscara al elemento de la lista que tiene ese parametro igual al del elemento que se pasa a esta funcion.
	-- Si no encuentra ninguno, levantara una excepcion (X_ELEMENTO_NO_ENCONTRADO).
	-- Si lo encuentra lo devuelve.
	function F_ENCONTRAR_ELEMENTO (V_ELEMENTO : in T_ELEMENTO;
				       V_LISTA : in T_LISTA) return T_ELEMENTO;

	-- Funcion a la que le paso un Natural con la posicion del elemento que quiero y me devuelve el elemento.
	-- Pensado para recorrer la lista entera.
	function F_DEVOLVER_ELEMENTO (V_POSICION : in Natural;
				      V_LISTA : in T_LISTA) return T_ELEMENTO;

	-- Funcion que devuelve la posicion de un elemento dentro de la lista.
	-- Si no se encuentra el elemento, levantara una excepcion (X_ELEMENTO_NO_ENCONTRADO).
	function F_POSICION_ELEMENTO (V_ELEMENTO : in T_ELEMENTO;
				      V_LISTA : in T_LISTA) return Natural;

	-- Funcion para saber si un elemento dado esta en una lista dada.
	function F_ESTA_ELEMENTO_EN_LISTA (V_ELEMENTO : in T_ELEMENTO;
					   V_LISTA : in T_LISTA) return Boolean;

	-- Al insertar el ultimo elemento en la primera posicion. Eliminar el ultimo elemento es eliminar el primer elemento de la lista.
	procedure P_ELIMINAR_ULTIMO_ELEMENTO (V_LISTA : in out T_LISTA);

	private

		type T_CELDA;

		type T_PUNTERO_A_CELDA is access T_CELDA;

		C_PUNTERO_A_CELDA_INICIAL : constant T_PUNTERO_A_CELDA:= null;

		type T_CELDA is record

			R_ELEMENTO : T_ELEMENTO;
			R_PUNTERO_A_CELDA : T_PUNTERO_A_CELDA;
	
		end record;

		type T_LISTA is record

			-- La lista esta formada por defecto solo por el puntero a null.
			-- Cuando se inserte el primer elemento, se cambiara el contenido de este puntero de null al elemento insertado y 
			-- asi sucesivamente.
			R_CELDA_INICIAL : T_PUNTERO_A_CELDA := C_PUNTERO_A_CELDA_INICIAL;
			
			R_NUMERO_ELEMENTOS : Natural := 0;

		end record;

end Q_GENERICO_LISTA;
---------------------
