#!/bin/bash
###################################################
#
# Script para obtener el tramo semilla de los mapas
#
# Hector Uhalte
#
# 2-10-2021
#
###################################################

rm Relacion_tramos_way_ids 2>&1 > /dev/null;

if [ $# -ne 1 ]
then
	echo "Introducir el nombre de la calle que será el primer tramo de los mapas tal y como se lee en openstreetmaps";
	echo "Ejemplo: ./semilla \"Calle del Lábaro\"";
	echo "";
	exit 1;
fi

# Estas dos variables deberian ser variables de linea de comandos.
SEMILLA=$1;
MAPA="cantabria-latest.osm";

# Obtener el "way" para el nombre de la calle dado.
# Como mucho hay 2000 nodos en cada tramo.
numero_linea=$(grep -m 1 -n "<tag k=\"name\" v=\"$SEMILLA\"/>" $MAPA | awk -F ":" '{print $1}');
lineas=$(head -n $numero_linea $MAPA | tail -n 2001 | grep -n "<way id=" | tail -n 1 | awk -F ":" '{print $1}');
linea_comienzo=$(($numero_linea-2001+$lineas));
linea_final=$(head -n $(($numero_linea+10)) $MAPA | grep -n "</way>" | tail -n 1 | awk -F ":" '{print $1}');
head -n $linea_final $MAPA | tail -n $(($linea_final-$linea_comienzo+1)) > semilla;
# Obtener el way_id del tramo
way_id=$(grep "<way id" semilla | awk -F "id=\"" '{print $2}' | awk -F "\"" '{print $1}');

# Obtener el numero de carriles del tramo
# Hay vias que no incluyen el numero de carriles, por defecto asignaremos 1 carril.
num_carriles=$(grep "<tag k=\"lanes\"" semilla | awk -F "v=\"" '{print $2}' | awk -F "\"" '{print $1}');
if [ -z "$num_carriles" ]
then
	num_carriles=1;	
fi

# Obtener los nodos del tramo.
grep "<nd ref=" semilla | awk -F "\"" '{print $2}' | awk -F "\"" '{print $1}' > nodos_prov;  
# Obtener el numero de nodos.
numero_nodos=$(wc -l nodos_prov | awk '{print $1}');
# Obtener el numero de carriles del tramo.
numero_carriles=$(grep "<tag k=\"lanes\"" semilla | awk -F "v=\"" '{print $2}' | awk -F "\"" '{print $1}');

# Estableciendo el nodo conexion 0.
echo "0" > nodos_conexiones;

# Dentro de los nodos quizas el primer nodo que sea una conexion con otro tramo no sea el ultimo nodo, sino uno intermedio.
# 1.- Comprobar que nodo es realmente el ultimo. Es decir el primer nodo (exceptuando el primero) que pertenezca a mas de un way.
for ((i=2;i<=$numero_nodos;i++))
do
	nodo=$(awk "NR==$i" nodos_prov);
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
			head -n $linea_final $MAPA | tail -n $(($linea_final-$linea_comienzo+1)) > way;
			# Comprobar si el way obtenido es de una tramo valido o no. Si contiene el tag name es un tramo valido.
			if [ "$(grep "<tag k=\"name\"" way)" ]
			then
				# Obtener el way para las conexiones si es distinto al way_id actual.
				# Si el way de conexion es de sentido unico y el nodo de conexion es el ultimo de esa way, entonces ese way
				# no es valido, en realidad se esta conectando al mismo nodo que el tramo actual, pero no se puede ir desde
				# el tramo actual a ese, hay que descartarlo.
				way_id_conexion=$(grep "<way id" way | awk -F "id=\"" '{print $2}' | awk -F "\"" '{print $1}');
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
						let num_ways++;
					fi
				fi
			fi
			rm way;
		done < fichero_lineas;
		rm fichero_lineas;
		if [ $num_ways -gt 0 ]
		then
			nodo_final=$nodo;
			posicion_final=$i;
			# Si el nodo final, el que se conecta con otras vias, no es el ultimo nodo del tramo semilla, eso significa que 
			# el tramo actual tambien tendra que ser conexion del tramo semilla.
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
for ((i=1;i<=$posicion_final;i++))
do
	awk "NR==$i" nodos_prov >> nodos;
done
rm nodos_prov;

# Obtener coordenadas del comienzo del tramo
echo "Obteniendo las coordenadas del origen del tramo";
nodo_comienzo=$(head -n 1 nodos | awk '{print $1}');
latitud_comienzo=$(grep "<node id=\"$nodo_comienzo\"" $MAPA | awk -F "lat=\"" '{print $2}' | awk -F "\"" '{print $1}');
longitud_comienzo=$(grep "<node id=\"$nodo_comienzo\"" $MAPA | awk -F "lon=\"" '{print $2}' | awk -F "\"" '{print $1}');
echo "Coordenadas de origen obtenidas";
echo "--";

# Obtener coordenadas del final del tramo.
echo "Obteniendo las coordenadas del final del tramo";
latitud_final=$(grep "<node id=\"$nodo_final\"" $MAPA | awk -F "lat=\"" '{print $2}' | awk -F "\"" '{print $1}');
longitud_final=$(grep "<node id=\"$nodo_final\"" $MAPA | awk -F "lon=\"" '{print $2}' | awk -F "\"" '{print $1}');
echo "Coordenadas de final obtenidas";
echo "--";

# Obtener el sentido de circulacion

# 1.- Obtener el sentido de circulacion dependiendo del angulo entre el primer y le ultimo nodo.
#     Si el tramo es de sentido unico ambos sentidos (Ascendente y Descendente al recorrer el tramo seran el mismo).
#     Si el tramo de de doble sentido, entonces el angulo obtenido (Sentido) se aplica al ascendente y el contrario al descendente.
comienzo_x=$(./m_transformar_coordenadas $latitud_comienzo $longitud_comienzo | awk '{print $1}');
comienzo_y=$(./m_transformar_coordenadas $latitud_comienzo $longitud_comienzo | awk '{print $2}');
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
if [ "$(grep "<tag k=\"oneway\"" semilla | awk -F "v=\"" '{print $2}' | awk -F "\"" '{print $1}')" == "yes" ]
then
        doble_sentido=false;
	sentido_2=$sentido_1
else
        doble_sentido=true;
fi

# Obtener la velocidad maxima del tramo
vel_max=$(grep "<tag k=\"maxspeed\"" semilla | awk -F "v=\"" '{print $2}' | awk -F "\"" '{print $1}'); 

# Obtener los nodos del tramo
numero_nodos=$(wc -l nodos | awk '{print $1}');
for((i=1;i<$numero_nodos;i++))
do
        nodo=$(awk "NR==$i" nodos | awk '{print $1}');
        nodo_siguiente=$(awk "NR==$(($i+1))" nodos | awk '{print $1}');

        # Obtener la posicion de los nodos.
        nodo_lat=$(grep "<node id=\"$nodo\"" $MAPA | awk -F "lat=\"" '{print $2}' | awk -F "\"" '{print $1}');
        nodo_lon=$(grep "<node id=\"$nodo\"" $MAPA | awk -F "lon=\"" '{print $2}' | awk -F "\"" '{print $1}');

        nodo_x=$(./m_transformar_coordenadas $nodo_lat $nodo_lon | awk '{print $1}');
        nodo_y=$(./m_transformar_coordenadas $nodo_lat $nodo_lon | awk '{print $2}');

        if [ $i -gt 1 ]
        then
                # Insertar coordenadas del nodo del mapa en la lista final de los nodos del tramo.
                echo "Real : $nodo_lat $nodo_lon" >> nodos_final_tramo_semilla;
        fi

        nodo_siguiente_lat=$(grep "<node id=\"$nodo_siguiente\"" $MAPA | awk -F "lat=\"" '{print $2}' | awk -F "\"" '{print $1}');
        nodo_siguiente_lon=$(grep "<node id=\"$nodo_siguiente\"" $MAPA | awk -F "lon=\"" '{print $2}' | awk -F "\"" '{print $1}');

        nodo_siguiente_x=$(./m_transformar_coordenadas $nodo_siguiente_lat $nodo_siguiente_lon | awk '{print $1}');
        nodo_siguiente_y=$(./m_transformar_coordenadas $nodo_siguiente_lat $nodo_siguiente_lon | awk '{print $2}');

        # Obtener distancia entre nodos y numero de nodos a interpolar
        distancia=$(./m_obtener_numero_segmentos_interpolar $nodo_lat $nodo_lon $nodo_siguiente_lat $nodo_siguiente_lon | awk '{print $1}');
        numero_nodos_interp=$(./m_obtener_numero_segmentos_interpolar $nodo_lat $nodo_lon $nodo_siguiente_lat $nodo_siguiente_lon | awk '{print $2}');
        for((j=1;j<=$numero_nodos_interp;j++))
        do
                # Obtener nodo de interpolacion.
                nodo_interp_x=$(./m_obtener_nodo_interpolacion_utm $nodo_x $nodo_y $nodo_siguiente_x $nodo_siguiente_y $j | awk '{print $1}');
		nodo_interp_y=$(./m_obtener_nodo_interpolacion_utm $nodo_x $nodo_y $nodo_siguiente_x $nodo_siguiente_y $j | awk '{print $2}');
                echo "Inte : $(./m_transformar_utm_a_lat_lon $nodo_interp_x $nodo_interp_y)" >> nodos_final_tramo_semilla;
        done
done
echo "";
echo "";


# Obtener las conexiones.
# 1.- Crear el fichero con la relacion de tramo_id y la way_id del mapa.
echo "Tramo Id : way_id #,nodo_id #" > Relacion_tramos_way_ids;
echo "1 : $way_id" >> Relacion_tramos_way_ids;
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
   	done < fichero_lineas;
fi

# Ya tenemos las way_id's de las conexiones, tanto si el tramo es de doble sentido o de sentido unico.

n=2
while read way_id
do
	nodo_conexion=$(awk "NR==$n" nodos_conexiones | awk '{print $1}');
	echo "$n : $way_id,$nodo_conexion" >> Relacion_tramos_way_ids;
	# Escribir las conexiones.
	# Hay que comprobar los carriles del tramo actual y el del tramo destino.
	# Si el numero de carriles no es el mismo => INTERVENCION MANUAL.
	# Si es el mismo asumimos cruces directos (1<->1, 2<->2, ...)
	# Obtener el numero de carriles del tramo destino
	num_carriles_destino=$(grep -A 2010 "<way id=\"$way_id\"" cantabria-latest.osm | grep -m 1 "<tag k=\"lanes\"" | awk -F "v=\"" '{print $2}' | awk -F "\"" '{print $1}');
	if [ $(($num_carriles)) -eq $(($num_carriles_destino)) ]
	then
		# El numero de carriles coincide. Tantas conexiones como cruces para el tramo destino.
		for ((i=1;i<=$num_carriles;i++))
		do
			echo -e "\t\t\t<its:conexion>" > conexion_$n;
			echo -e "\t\t\t\t<its:tramoId>$n</its:tramoId>" >> conexion_$n;
			echo -e "\t\t\t\t<its:carrilActual>$i</its:carrilActual>" >> conexion_$n;
			echo -e "\t\t\t\t<its:carrilSiguiente>$i</its:carrilSiguiente>" >> conexion_$n;
			echo -e "\t\t\t\t<its:listaCruces>" >> conexion_$n;
                	echo -e "\t\t\t\t\t<its:cruceId>$i</its:cruceId>" >> conexion_$n;
                	echo -e "\t\t\t\t</its:listaCruces>" >> conexion_$n;
			# La restriccion de velocidad se calculara automaticamente teniendo en cuenta el angulo de cruce entre los dos i
			# tramos y la velocidad maxima del tramo mas "lento". De momento a mano.
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
		# La restriccion de velocidad se calculara automaticamente teniendo en cuenta el angulo de cruce entre los dos tramos
		# y la velocidad maxima del tramo mas "lento". De momento a mano.
		echo -e "\t\t\t\t<its:restriccionVelocidad>INTERVENCION_MANUAL</its:restriccionVelocidad>" >> conexion_$n;
		echo -e "\t\t\t</its:conexion>" >> conexion_$n;
	fi 	
	echo -e "\t\t\t</its:conexion>" >> conexion_$n;
	let n++;
done < ways_id_conexiones
rm ways_id_conexiones nodos_conexiones;
numero_conexiones=$(($n-1)); 

# Sacar el tramo en formato ITS
echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>";
echo "<its:tramoSet xmlns:its=\"IntelligentTransportSystem\"";
echo -e "\txmlns:xsi=\"http://www.w3.org\/2001\/XMLSchema-instance\"";
echo -e "\txsi:schemaLocation=\"IntelligentTransportSystem Schemas/tramos.xsd\">";
echo -e "\t<its:datosTramo>";
echo -e "\t\t<its:id>1</its:id>";
echo -e "\t\t<its:nombreTramo>$SEMILLA</its:nombreTramo>";
echo -e "\t\t<its:comienzoLatitud>$latitud_comienzo</its:comienzoLatitud>";
echo -e "\t\t<its:comienzoLongitud>$longitud_comienzo</its:comienzoLongitud>";
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
done < nodos_final_tramo_semilla
echo -e "\t\t</its:listaSegmentos>";
echo -e "\t\t<its:listaConexiones>";
for ((i=2;i<=$numero_conexiones;i++))
do
        cat conexion\_$i;
	rm conexion\_$i;
done
echo -e "\t\t</its:listaConexiones>";
echo -e "\t</its:datosTramo>";
echo "</its:tramoSet>";

rm nodos semilla nodos_final_tramo_semilla;
