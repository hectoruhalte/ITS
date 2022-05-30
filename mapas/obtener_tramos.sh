#!/bin/bash
####################################################################
#
# Script para obtener los tramos del mapa a partir del tramo semilla
#
# Hector Uhalte
#
# 21-10-2021
#
####################################################################

if [ $# -ne 1 ]
then
        echo "Introducir el numero de tramos que queremos obtener aparte del tramo semilla";
        echo "Ejemplo: ./obtener_nodos.sh 1";
        echo "";
        exit 1;
fi

MAPA="cantabria-latest.osm";
lineas_mapa=$(wc -l $MAPA | awk '{print $1}');

# Loop para obtner los tramos.
for ((i=1;i<=$1;i++))
do
	# Obtener el way_id que necesitamos.
	way_id=$(grep ^$(($i+1)) Relacion_tramos_way_ids | awk '{print $3}' | awk -F "," '{print $1}');
	nodo_conexion=$(grep ^$(($i+1)) Relacion_tramos_way_ids | awk '{print $3}' | awk -F "," '{print $2}');
	
	# Como mucho hay 2000 nodos en cada tramo.
	linea_comienzo=$(grep -m 1 -n "<way id=\"$way_id\"" $MAPA | awk -F ":" '{print $1}');
	numero_lineas=$(tail -n $(($lineas_mapa-$linea_comienzo+1)) $MAPA | grep -n -m 1 "</way>" | awk -F ":" '{print $1}');
	head -n $(($linea_comienzo+numero_lineas-1)) $MAPA | tail -n $numero_lineas > way;

	# Obtener el nombre del tramo
	nombre=$(grep "<tag k=\"name\"" way | awk -F "v=\"" '{print $2}' | awk -F "\"" '{print $1}');

	# Obtener las coordenadas del comienzo del tramo
	latitud_conexion=$(grep "<node id=\"$nodo_conexion\"" $MAPA | awk -F "lat=\"" '{print $2}' | awk -F "\"" '{print $1}');
	longitud_conexion=$(grep "<node id=\"$nodo_conexion\"" $MAPA | awk -F "lon=\"" '{print $2}' | awk -F "\"" '{print $1}');

	# Obtener el numero de carriles
	num_carriles=$(grep "<tag k=\"lanes\"" way | awk -F "v=\"" '{print $2}' | awk -F "\"" '{print $1}');
	if [ -z "$num_carriles" ]
	then
        	num_carriles=1;
	fi

	# Obtener el numero de nodos del tramo.
	numero_nodos=$(grep "<nd ref" way | wc -l | awk '{print $1}');
	grep "<nd ref=" way | awk -F "\"" '{print $2}' | awk -F "\"" '{print $1}' > nodos_prov;

	# Comprobar cual es el nodo de conexion del tramo. Que nodo aparece en mas de un tramo.
	for ((j=2;j<=$numero_nodos;j++))
	do
		nodo=$(awk "NR==$j" nodos_prov);
        	# Obtener las way_ids con tag name incluida que contienen al nodos
        	num_ways=0;
		grep -n "<nd ref=\"$nodo\"/>" $MAPA | awk -F ":" '{print $1}' > fichero_lineas;

		if [ $(($(wc -l fichero_lineas | awk '{print $1}'))) -eq 1 ]
        	then
                	# El nodo solo aparece en una linea del mapa => No puede ser el ultimo nodo del tramo.
                	continue;
		else
			# El nodo aparece en mas de una linea del mapa. Obtener las way_ids.
			while read num_linea
			do
				lineas=$(head -n $num_linea $MAPA | tail -n 2001 | grep -n "<way id=" | tail -n 1 | awk -F ":" '{print $1}');
                        	linea_comienzo=$(($num_linea-2001+$lineas));
				head -n $(($num_linea+2000)) $MAPA | grep -n "</way>" |  awk -F ":" '{print $1}' > fichero_lineas_final;
				while read linea_final_prov
                        	do
                                	if [ $linea_final_prov -gt $num_linea ]
                                	then
                                        	linea_final=$linea_final_prov;
                                        	break;
                                	fi
                        	done < fichero_lineas_final
				rm fichero_lineas_final;
				head -n $linea_final $MAPA | tail -n $(($linea_final-$linea_comienzo+1)) > way_prov;

				# Comprobar si el way obtenido es de una tramo valido o no. Si contiene el tag name es un tramo valido.
				if [ "$(grep "<tag k=\"name\"" way_prov)" ] || [ "$(grep "<tag k=\"junction\" v=\"roundabout\"/>" way_prov)" ]
                        	then
					# Obtener el way para las conexiones si es distinto al way_id actual.
                                	# Si el way de conexion es de sentido unico y el nodo de conexion es el ultimo de esa way, entonces
	 				# ese way no es valido, en realidad se esta conectando al mismo nodo que el tramo actual, pero no se
					# puede ir desde el tramo actual a ese, hay que descartarlo.
                                	way_id_conexion=$(grep "<way id" way_prov | awk -F "id=\"" '{print $2}' | awk -F "\"" '{print $1}');
                                	
					# Tenemos el nodo y el way_id_conexion. Evitar repeticion de duplas way_id_conexion | nodo
                                	if [ "$(grep $way_id_conexion,$nodo Relacion_tramos_way_ids)" ]
                                	then
                                        	# Ignorar
						continue;
                                	fi

					way_sentido_unico=$(grep "<tag k=\"oneway\"" way_prov  | awk -F "v=\"" '{print $2}' | awk -F "\"" '{print $1}');
                                	nodo_ultimo=$(grep "<nd ref=" way_prov | awk -F "\"" '{print $2}' | awk -F "\"" '{print $1}' | tail -n 1);
					# Descartar tramos peatonales.
                                	peatonal=$(grep "<tag k=\"highway\"" way | awk -F "v=\"" '{print $2}' | awk -F "\"" '{print $1}');

					if [ "$way_id" != "$way_id_conexion" ]
                                	then
                                        	if [ "$way_sentido_unico" == "yes" ] && [ "$nodo_ultimo" == "$nodo" ] || [ "$peatonal" == "pedestrian" ]
                                        	then
                                                	# Esta way hay que ignorarla. No es una conexion. Pasar a la siguente.
							continue;
                                        	else
                                                	echo $way_id_conexion >> ways_id_conexiones;
                                                	echo $nodo >> nodos_conexiones;
                                                	let num_ways++;
                                        	fi
                                	fi
				fi
				rm way_prov;
			done < fichero_lineas; 
			
			rm fichero_lineas;
			if [ $num_ways -gt 0 ]
                	then
                        	nodo_final=$nodo;
                        	posicion_final=$j;
                        	# Si el nodo final, el que se conecta con otras vias, no es el ultimo nodo del tramo, eso significa
 				# que el tramo actual tambien tendra que ser conexion del tramo.
                        	if [ $posicion_final -ne $numero_nodos ]
                        	then
                                	echo $way_id >> ways_id_conexiones;
                                	echo $nodo >> nodos_conexiones;
                        	fi
                        	break;
                	fi

		fi
	done

	# Establecer los nodos definitivos
	for ((j=1;j<=$posicion_final;j++))
	do
        	awk "NR==$j" nodos_prov >> nodos;
	done
	rm nodos_prov;

	# Obtener coordenadas del final del tramo.
	latitud_final=$(grep "<node id=\"$nodo_final\"" $MAPA | awk -F "lat=\"" '{print $2}' | awk -F "\"" '{print $1}');
	longitud_final=$(grep "<node id=\"$nodo_final\"" $MAPA | awk -F "lon=\"" '{print $2}' | awk -F "\"" '{print $1}');
	
	# Establecer el sentido de circulacion

	# 1.- Obtener el sentido de circulacion dependiendo del angulo entre el primer y le ultimo nodo.
	#     Si el tramo es de sentido unico ambos sentidos (Ascendente y Descendente al recorrer el tramo seran el mismo).
	#     Si el tramo de de doble sentido, entonces el angulo obtenido (Sentido) se aplica al ascendente y el contrario al descendente.
	comienzo_x=$(./m_transformar_coordenadas $latitud_conexion $longitud_conexion | awk '{print $1}');
	comienzo_y=$(./m_transformar_coordenadas $latitud_conexion $longitud_conexion | awk '{print $2}');
	final_x=$(./m_transformar_coordenadas $latitud_final $longitud_final | awk '{print $1}');
	final_y=$(./m_transformar_coordenadas $latitud_final $longitud_final | awk '{print $2}');
	angulo=$(./m_obtener_angulo $comienzo_x $comienzo_y $final_x $final_y);

	if (( $(echo "$angulo < 2.3561945" | bc -l))) && (( $(echo "$angulo > -0.7853982" | bc -l)))
	then
        	sentido_1=1;
        	sentido_2=2;
	else
        	sentido_1=2;
        	sentido_2=1;
	fi

	# 2.- Comprobar si el tramo es de doble sentido o no.
	if [ "$(grep "<tag k=\"oneway\"" way | awk -F "v=\"" '{print $2}' | awk -F "\"" '{print $1}')" == "yes" ]
	then
        	doble_sentido=false;
        	sentido_2=$sentido_1
	else
        	doble_sentido=true;
	fi

	# Obtener la velocidad maxima del tramo
	vel_max=$(grep "<tag k=\"maxspeed\"" way | awk -F "v=\"" '{print $2}' | awk -F "\"" '{print $1}');

	# Obtener los nodos del tramo
	numero_nodos=$(wc -l nodos | awk '{print $1}');
	# Si solo hay un nodo. Tendremos que interpolar entre el nodo origen y el nodo final.
	if [ $numero_nodos -eq 1 ]
	then

		nodo=$nodo_conexion;
		nodo_siguiente=$nodo_final;

		# Obtener la posicion de los nodos.
                nodo_lat=$(grep "<node id=\"$nodo\"" $MAPA | awk -F "lat=\"" '{print $2}' | awk -F "\"" '{print $1}');
                nodo_lon=$(grep "<node id=\"$nodo\"" $MAPA | awk -F "lon=\"" '{print $2}' | awk -F "\"" '{print $1}');

                nodo_x=$(./m_transformar_coordenadas $nodo_lat $nodo_lon | awk '{print $1}');
                nodo_y=$(./m_transformar_coordenadas $nodo_lat $nodo_lon | awk '{print $2}');

		nodo_siguiente_lat=$(grep "<node id=\"$nodo_siguiente\"" $MAPA | awk -F "lat=\"" '{print $2}' | awk -F "\"" '{print $1}');
                nodo_siguiente_lon=$(grep "<node id=\"$nodo_siguiente\"" $MAPA | awk -F "lon=\"" '{print $2}' | awk -F "\"" '{print $1}');

               	nodo_siguiente_x=$(./m_transformar_coordenadas $nodo_siguiente_lat $nodo_siguiente_lon | awk '{print $1}');
                nodo_siguiente_y=$(./m_transformar_coordenadas $nodo_siguiente_lat $nodo_siguiente_lon | awk '{print $2}');

		# Obtener distancia entre nodos y numero de nodos a interpolar
                distancia=$(./m_obtener_numero_segmentos_interpolar $nodo_lat $nodo_lon $nodo_siguiente_lat $nodo_siguiente_lon | awk '{print $1}');
                numero_nodos_interp=$(./m_obtener_numero_segmentos_interpolar $nodo_lat $nodo_lon $nodo_siguiente_lat $nodo_siguiente_lon | awk '{print $2}');

		for((k=1;k<=$numero_nodos_interp;k++))
                do
                	# Obtener nodo de interpolacion.
                        nodo_interp_x=$(./m_obtener_nodo_interpolacion_utm $nodo_x $nodo_y $nodo_siguiente_x $nodo_siguiente_y $k | awk '{print $1}');
                	nodo_interp_y=$(./m_obtener_nodo_interpolacion_utm $nodo_x $nodo_y $nodo_siguiente_x $nodo_siguiente_y $k | awk '{print $2}');
                        echo "Inte : $(./m_transformar_utm_a_lat_lon $nodo_interp_x $nodo_interp_y)" >> nodos_final_tramo;
            	done

	else

		for((j=1;j<$numero_nodos;j++))
		do
			nodo=$(awk "NR==$j" nodos | awk '{print $1}');
			nodo_siguiente=$(awk "NR==$(($j+1))" nodos | awk '{print $1}');

			# Obtener la posicion de los nodos.
        		nodo_lat=$(grep "<node id=\"$nodo\"" $MAPA | awk -F "lat=\"" '{print $2}' | awk -F "\"" '{print $1}');
        		nodo_lon=$(grep "<node id=\"$nodo\"" $MAPA | awk -F "lon=\"" '{print $2}' | awk -F "\"" '{print $1}');

			nodo_x=$(./m_transformar_coordenadas $nodo_lat $nodo_lon | awk '{print $1}');
        		nodo_y=$(./m_transformar_coordenadas $nodo_lat $nodo_lon | awk '{print $2}');

			if [ $j -gt 1 ]
        		then
                		# Insertar coordenadas del nodo del mapa en la lista final de los nodos del tramo.
                		echo "Real : $nodo_lat $nodo_lon" >> nodos_final_tramo;
        		fi

			nodo_siguiente_lat=$(grep "<node id=\"$nodo_siguiente\"" $MAPA | awk -F "lat=\"" '{print $2}' | awk -F "\"" '{print $1}');
        		nodo_siguiente_lon=$(grep "<node id=\"$nodo_siguiente\"" $MAPA | awk -F "lon=\"" '{print $2}' | awk -F "\"" '{print $1}');

        		nodo_siguiente_x=$(./m_transformar_coordenadas $nodo_siguiente_lat $nodo_siguiente_lon | awk '{print $1}');
        		nodo_siguiente_y=$(./m_transformar_coordenadas $nodo_siguiente_lat $nodo_siguiente_lon | awk '{print $2}');

			# Obtener distancia entre nodos y numero de nodos a interpolar
        		distancia=$(./m_obtener_numero_segmentos_interpolar $nodo_lat $nodo_lon $nodo_siguiente_lat $nodo_siguiente_lon | awk '{print $1}');
        		numero_nodos_interp=$(./m_obtener_numero_segmentos_interpolar $nodo_lat $nodo_lon $nodo_siguiente_lat $nodo_siguiente_lon | awk '{print $2}');

        		for((k=1;k<=$numero_nodos_interp;k++))
        		do
                		# Obtener nodo de interpolacion.
                		nodo_interp_x=$(./m_obtener_nodo_interpolacion_utm $nodo_x $nodo_y $nodo_siguiente_x $nodo_siguiente_y $k | awk '{print $1}');
                		nodo_interp_y=$(./m_obtener_nodo_interpolacion_utm $nodo_x $nodo_y $nodo_siguiente_x $nodo_siguiente_y $k | awk '{print $2}');
                		echo "Inte : $(./m_transformar_utm_a_lat_lon $nodo_interp_x $nodo_interp_y)" >> nodos_final_tramo;
        		done

		done 	
	fi

	# Obtener las conexiones del tramo
	# 1.- Si el tramo es de doble sentido la conexion se hara a traves del primer y el ultimo nodo.
	#     Si el tramo de de sentido unico la conexion se hara a traves del ultimo nodo.
	if [ "$doble_sentido" == "true" ]
	then
		# Las way id de los tramos de conexion del ultimo nodo los tenemos en el fichero ways_id_conexiones.
        	# Hay que hacer lo mismo para el primer nodo.
		nodo=$(awk "NR==$1" nodos);
		grep -n "<nd ref=\"$nodo\"/>" $MAPA | awk -F ":" '{print $1}' > fichero_lineas;
		while read num_linea
		do
			lineas=$(head -n $num_linea $MAPA | tail -n 2001 | grep -n "<way id=" | tail -n 1 | awk -F ":" '{print $1}');
			linea_comienzo=$(($num_linea-2001+$lineas));
			head -n $(($num_linea+2000)) $MAPA | grep -n "</way>" |  awk -F ":" '{print $1}' > fichero_lineas_final;
			while read linea_final_prov
                	do
                        	if [ $linea_final_prov -gt $num_linea ]
                        	then
                                	linea_final=$linea_final_prov;
                                	break;
                        	fi
                	done < fichero_lineas_final
			rm fichero_lineas_final;
			head -n $linea_final $MAPA | tail -n $(($linea_final-$linea_comienzo+1)) > way;
			# Comprobar si el way obtenido es de una tramo valido o no. Si contiene el tag name es un tramo valido.
			if [ "$(grep "<tag k=\"name\"" way)" ]
                	then
                        	# Obtener el way para las conexiones si es distinto al way_id actual.
                        	# Si el way de conexion es de sentido unico y el nodo de conexion es el ultimo de esa way, entonces ese way
                        	# no es valido, en realidad se esta conectando al mismo nodo que el tramo actual, pero no se puede ir desde
                        	# el tramo actual a ese, hay que descartarlo.
                        	way_id_conexion=$(grep "<way id" way | awk -F "id=\"" '{print $2}' | awk -F "\"" '{print $1}');
                        	
				# Tenemos el nodo y el way_id_conexion. Evitar repeticion de duplas way_id_conexion | nodo
				if [ "$(grep $way_id_conexion,$nodo Relacion_tramos_way_ids)" ]
				then
					# Ignorar
					continue;
				fi

				way_sentido_unico=$(grep "<tag k=\"oneway\"" way  | awk -F "v=\"" '{print $2}' | awk -F "\"" '{print $1}');
                        	nodo_ultimo=$(grep "<nd ref=" way | awk -F "\"" '{print $2}' | awk -F "\"" '{print $1}' | tail -n 1);

                        	# Descartar tramos peatonales.
                        	peatonal=$(grep "<tag k=\"highway\"" way | awk -F "v=\"" '{print $2}' | awk -F "\"" '{print $1}');
                        	if [ "$way_id" != "$way_id_conexion" ]
                        	then
                                	if [ "$way_sentido_unico" == "yes" ] && [ "$nodo_ultimo" == "$nodo" ] || [ "$peatonal" == "pedestrian" ]
                                	then
                                        	# Esta way hay que ignorarla. No es una conexion. Pasar a la siguente.
                                        	continue;
                                	else
                                        	#cat way;
                                        	echo $way_id_conexion >> ways_id_conexiones;
                                        	echo $nodo >> nodos_conexiones;
                                	fi
                        	fi
                	fi
                	rm way;
		done < fichero_lineas
	fi

	# Ya tenemos las way_id's de las conexiones, tanto si el tramo es de doble sentido o de sentido unico.
	n=1
	while read way_id
	do
		nodo_conexion=$(awk "NR==$n" nodos_conexiones | awk '{print $1}');
		
		# Obtener el id del tramo para el fichero de Relacion tramos_way_ids.
		id=$(($(tail -n 1 Relacion_tramos_way_ids | awk '{print $1}') + 1))		
	
		echo "$id : $way_id,$nodo_conexion" >> Relacion_tramos_way_ids;
		# Escribir las conexiones.
        	# Hay que comprobar los carriles del tramo actual y el del tramo destino.
        	# Si el numero de carriles no es el mismo => INTERVENCION MANUAL.
        	# Si es el mismo asumimos cruces directos (1<->1, 2<->2, ...)
        	# Obtener el numero de carriles del tramo destino
		num_carriles_destino=$(grep -A 2010 "<way id=\"$way_id\"" cantabria-latest.osm | grep -m 1 "<tag k=\"lanes\"" | awk -F "v=\"" '{print $2}' | awk -F "\"" '{print $1}');
		if [ $(($num_carriles)) -eq $(($num_carriles_destino)) ]
		then
			# El numero de carriles coincide. Tantas conexiones como cruces para el tramo destino.
                	for ((k=1;k<=$num_carriles;k++))
                	do
                        	echo -e "\t\t\t<its:conexion>" > conexion_$n;
                        	echo -e "\t\t\t\t<its:tramoId>$n</its:tramoId>" >> conexion_$n;
                        	echo -e "\t\t\t\t<its:carrilActual>$k</its:carrilActual>" >> conexion_$n;
                        	echo -e "\t\t\t\t<its:carrilSiguiente>$k</its:carrilSiguiente>" >> conexion_$n;
                        	echo -e "\t\t\t\t<its:listaCruces>" >> conexion_$n;
                        	echo -e "\t\t\t\t\t<its:cruceId>$k</its:cruceId>" >> conexion_$n;
                        	echo -e "\t\t\t\t</its:listaCruces>" >> conexion_$n;
                       		# La restriccion de velocidad se calculara automaticamente teniendo en cuenta el angulo de cruce entre los
				# dos tramos y la velocidad maxima del tramo mas "lento". De momento a mano.
                        	echo -e "\t\t\t\t<its:restriccionVelocidad>INTERVENCION_MANUAL</its:restriccionVelocidad>" >> conexion_$n;
                        	echo -e "\t\t\t</its:conexion>" >> conexion_$n;
                	done
		else
			# El numero de carriles no coincide. => Intervencion manual.
                	echo -e "\t\t\t<its:conexion>" > conexion_$n;
                	echo -e "\t\t\t\t<its:tramoId>$n</its:tramoId>" >> conexion_$n;
                	echo -e "\t\t\t\t<its:carrilActual>INTERVENCION MANUAL</its:carrilActual>" >> conexion_$n;
                	echo -e "\t\t\t\t<its:carrilSiguiente>INTERVENCION MANUAL</its:carrilSiguiente>" >> conexion_$n;
                	echo -e "\t\t\t\t<its:listaCruces>" >> conexion_$n;
                	echo -e "\t\t\t\t\t<its:cruceId>INTERVENCION MANUAL</its:cruceId>" >> conexion_$n;
                	echo -e "\t\t\t\t</its:listaCruces>" >> conexion_$n;
                	# La restriccion de velocidad se calculara automaticamente teniendo en cuenta el angulo de cruce entre los dos 
			# tramos y la velocidad maxima del tramo mas "lento". De momento a mano.
                	echo -e "\t\t\t\t<its:restriccionVelocidad>INTERVENCION_MANUAL</its:restriccionVelocidad>" >> conexion_$n;
                	echo -e "\t\t\t</its:conexion>" >> conexion_$n;
		fi
		echo -e "\t\t\t</its:conexion>" >> conexion_$n;
        	let n++;
	done < ways_id_conexiones
	numero_conexiones=$(($n-1));

	# Mostrar el tramo
	echo -e "\t<its:datosTramo>";
	echo -e "\t\t<its:id>$(($i+1))</its:id>";
	echo -e "\t\t<its:nombreTramo>$nombre</its:nombreTramo>";
	echo -e "\t\t<its:comienzoLatitud>$latitud_conexion</its:comienzoLatitud>";
	echo -e "\t\t<its:comienzoLongitud>$longitud_conexion</its:comienzoLongitud>";
	echo -e "\t\t<its:finalLatitud>$latitud_final</its:finalLatitud>";
        echo -e "\t\t<its:finalLongitud>$longitud_final</its:finalLongitud>";
	echo -e "\t\t<its:sentidoCirculacion>";
	echo -e "\t\t\t<its:ascendente>$sentido_1</its:ascendente>";
	echo -e "\t\t\t<its:descendente>$sentido_2</its:descendente>";
	echo -e "\t\t</its:sentidoCirculacion>";
	echo -e "\t\t<its:altura>10</its:altura>";
	echo -e "\t\t<its:velocidadMaxima>$vel_max</its:velocidadMaxima>";
	echo -e "\t\t<its:listaSegmentos>";
	while read segmento
	do
        	echo -e "\t\t\t<its:segmento>";
        	echo -e "\t\t\t\t<its:posicionSegmentoLatitud>$(echo $segmento | awk '{print $3}')</its:posicionSegmentoLatitud>";
        	echo -e "\t\t\t\t<its:posicionSegmentoLongitud>$(echo $segmento | awk '{print $4}')</its:posicionSegmentoLongitud>";
        	echo -e "\t\t\t\t<its:dobleSentido>$doble_sentido</its:dobleSentido>";
        	echo -e "\t\t\t\t<its:numeroCarriles>$numero_carriles</its:numeroCarriles>";
        	echo -e "\t\t\t</its:segmento>";
	done < nodos_final_tramo
	echo -e "\t\t</its:listaSegmentos>";
	echo -e "\t\t<its:listaConexiones>";
	for ((j=1;j<=$numero_conexiones;j++))
	do
        	cat conexion\_$j;
        	rm conexion\_$j;
	done
echo -e "\t\t</its:listaConexiones>";
	echo -e "\t</its:datosTramo>";
	echo "</its:tramoSet>"
	rm way ways_id_conexiones nodos_conexiones nodos nodos_final_tramo;
done
