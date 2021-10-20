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

# Obtener el numero de segmentos de la via.
echo ""; 
echo "Obteniendo el numero de segmentos de la via semilla : $SEMILLA";
segmentos_semilla=$(grep -c "<tag k=\"name\" v=\"$SEMILLA\"/>" $MAPA);
echo "Segmentos de la via semilla : $segmentos_semilla";
echo "--";

# Obtener los numeros de linea en la que aparece el nombre de la semilla.
echo "Extrayendo segmentos ... ";
grep -n "<tag k=\"name\" v=\"$SEMILLA\"/>" $MAPA | awk -F ":" '{print $1}' > fichero_numeros_linea;
i=1
# Obtener la linea de comienzo y de final de la via de cada segmento. Como maximo 2000 nodos y 10 tags (suponemos) en cada via.
echo "Tramo Id:way_id#1, way_id#2, ..., way_id#n." > Relacion_tramos_way_ids;
echo -n "1:" >> Relacion_tramos_way_ids;
while read num_linea
do
	lineas=$(head -n $num_linea $MAPA | tail -n 2001 | grep -n "<way id=" | tail -n 1 | awk -F ":" '{print $1}');
	linea_comienzo=$(($num_linea-2001+$lineas));
	linea_final=$(head -n $(($num_linea+10)) $MAPA | grep -n "</way>" | tail -n 1 | awk -F ":" '{print $1}');
	# Extraer las vias
	head -n $linea_final $MAPA | tail -n $(($linea_final-$linea_comienzo+1)) > semilla_$i;
	# Guardar la relacion de tramo id (ITS) con las way_id's del mapa original.
	# Formato => 
	# Tramo Id (ITS): $way_id#1,$way_id#2, ... , $way_id#n
	way_id=$(cat semilla\_$i | grep "way id" | awk -F "<way id=\"" '{print $2}' | awk -F "\"" '{print $1}');
	echo -n "$way_id, " >> Relacion_tramos_way_ids; 
	let i++;	
done < fichero_numeros_linea
echo "" >> Relacion_tramos_way_ids;
echo "Segmentos extraidos";
echo "--";
echo "";

# En caso de que haya mas de un segmento habra que comprobar si puede ser un solo tramo:
#	1.- Comprobar si el limite de velocidad es el mismo en los dos segmentos.
#	2.- Si lo es, entonces comprobar el orden de los segmentos (comprobar si el nodo comun del primer segmento es el primero o el 
#           ultimo. Esto establecera el orden de los segmentos.
declare -A vel_max=();
for ((i=1;i<=$segmentos_semilla;i++))
do
	vel_max[$i]=$(grep "<tag k=\"maxspeed\"" semilla\_$i | awk -F "v=\"" '{print $2}' | awk -F "\"" '{print $1}');
	if [ $i -gt 1 ]
	then
		if [ "${vel_max[$(($i-1))]}" != "${vel_max[$i]}" ]
		then
			echo "Las velocidades maximas de los segmentos no coinciden. Hace falta mas de un tramo";
			break;
			exit 1;
		fi
	fi
	# Obtener los nodos de los segmentos
	cat semilla\_$i | grep "<nd ref" | awk -F "\"" '{print $2}' > nodos\_$i;
done

declare -A nodo_primero=();
declare -A nodo_ultimo=();
# Comprobar el sentido del tramo. El ultimo nodo del primer segmento debera ser el primer nodo del segundo segmento para un sentido 1->2
# Si no, habra que comprobar que el ultimo nodo del segundo segmento es el primer nodo del primer segmento para un sentido 2->1.
sentido_ascendente=true;
for ((i=1;i<=$segmentos_semilla;i++))
do
	if [ $i -eq 1 ]
	then
		# El nodo de conexion debera ser el ultimo.
		nodo_ultimo[$i]=$(tail -n 1 nodos\_$i);
	fi
	if [ $i -gt 1 ] && [ $i -lt $segmentos_semilla ]
	then
		# Segmento intermedio habra que tomar el primer y el ultimo nodo para la conexion.
		nodo_primero[$i]=$(head -n 1 nodos\_$i);
		nodo_ultimo[$i]=$(tail -n 1 nodos\_$i);
	fi
	if [ $i -eq $segmentos_semilla ]
	then
		# Ultimo segmento. El nodo de conexion debera ser el primero.
		nodo_primero[$i]=$(head -n 1 nodos\_$i);
	fi
	if [ $i -gt 1 ]
	then
		# Comprobar conexiones y continuidad. Si hay un error salir del bucle.
		if [ "${nodo_ultimo[$(($i-1))]}" != "${nodo_primero[$i]}" ]
		then
			# Problema de continuidad.
			echo "No hay continuidad entre los segmentos $(($i-1)) y el $1";
			echo "--";
			sentido_ascendente=false;
			break;
		fi
	fi
done

if [ "$sentido_ascendente" == "true" ]
then
	echo "El sentido del tramo semilla es ascendente";
	echo "--";
	# Unificar nodos del tramo semilla.
	for ((i=1;i<=$segmentos_semilla;i++))
	do
		# Obtener numero de carriles del segmento
		carriles=$(cat semilla\_$i | grep "tag k=\"lanes\"" | awk -F "v=\"" '{print $2}' | awk -F "\"" '{print $1}');
		cat semilla\_$i | grep "<nd ref" | awk -F "\"" '{print $2}' > nodos_bruto_prov;
		while read nodo
		do
			echo "$nodo $carriles" >> nodos_bruto;
		done < nodos_bruto_prov
		rm nodos_bruto_prov;
	done
	
	# Eliminar los nodos de conexion que estaran repetidos.
	cat nodos_bruto | uniq > nodos_tramo_semilla;
	rm nodos_bruto;
else
	# Comprobar continuidad de manera descendente.
	declare -A nodo_primero=();
	declare -A nodo_ultimo=();
	for ((i=$segmentos_semilla;i>=1;i--))
	do
        	if [ $i -eq $segmentos_semilla ]
        	then
                	# El nodo de conexion debera ser el primero.
                	nodo_primero[$i]=$(head -n 1 nodos\_$i);
        	fi
        	if [ $i -gt 1 ] && [ $i -lt $segmentos_semilla ]
        	then
                	# Segmento intermedio habra que tomar el primer y el ultimo nodo para la conexion.
                	nodo_primero[$i]=$(head -n 1 nodos\_$i);
                	nodo_ultimo[$i]=$(tail -n 1 nodos\_$i);
        	fi
        	if [ $i -eq 1 ]
        	then
                	# Primer segmento. El nodo de conexion debera ser el ultimo.
                	nodo_ultimo[$i]=$(tail -n 1 nodos\_$i);
        	fi
        	if [ $i -lt $segmentos_semilla ]
        	then
                	# Comprobar conexiones y continuidad. Si hay un error salir del bucle.
                	if [ "${nodo_ultimo[$(($i-1))]}" != "${nodo_primero[$i]}" ]
                	then
                        	# Problema de continuidad.
                        	echo "No hay continuidad entre los segmentos $(($i-1)) y el $1";
                        	echo "Error de continuidad. Necesidad de intervencion manual";
                        	echo "--";
				exit 1;
                	fi
        	fi
		echo "El sentido del tramo semilla es descendente";
        	echo "--";
        	# Unificar nodos del tramo semilla.
        	for ((i=$segmentos_semilla;i>=1;i--))
        	do
                	# Obtener numero de carriles del segmento
                	carriles=$(cat semilla\_$i | grep "tag k=\"lanes\"" | awk -F "v=\"" '{print $2}' | awk -F "\"" '{print $1}');
			cat semilla\_$i | grep "<nd ref" | awk -F "\"" '{print $2}' > nodos_bruto_prov;
			while read nodo
                	do
                        	echo "$nodo $carriles" >> nodos_bruto;
                	done < nodos_bruto_prov
                	rm nodos_bruto_prov;
        	done

        	# Eliminar los nodos de conexion que estaran repetidos.
        	cat nodos_bruto | uniq > nodos_tramo_semilla;
        	rm nodos_bruto;
	done
fi

# Obtener coordenadas del comienzo del tramo
echo "Obteniendo las coordenadas del origen del tramo";
nodo_comienzo=$(head -n 1 nodos_tramo_semilla | awk '{print $1}');
latitud_comienzo=$(grep "<node id=\"$nodo_comienzo\"" $MAPA | awk -F "lat=\"" '{print $2}' | awk -F "\"" '{print $1}');
longitud_comienzo=$(grep "<node id=\"$nodo_comienzo\"" $MAPA | awk -F "lon=\"" '{print $2}' | awk -F "\"" '{print $1}');
echo "Coordenadas de origen obtenidas";
echo "--";

# Obtener coordenadas del final del tramo.
echo "Obteniendo las coordenadas del final del tramo";
nodo_final=$(tail -n 1 nodos_tramo_semilla | awk '{print $1}');
latitud_final=$(grep "<node id=\"$nodo_final\"" $MAPA | awk -F "lat=\"" '{print $2}' | awk -F "\"" '{print $1}');
longitud_final=$(grep "<node id=\"$nodo_final\"" $MAPA | awk -F "lon=\"" '{print $2}' | awk -F "\"" '{print $1}');
echo "Coordenadas de final obtenidas";
echo "--";

# Obtener sentido de circulacion.
# Para todos los segmentos del tramo semilla la etiqueta one way debera tener el mismo valor, de lo contrario deberian ser tramos distintos.
echo "Obteniendo sentido de circulacion";
declare -A sentido_unico=();
for ((i=1;i<=$segmentos_semilla;i++))
do
	sentido_unico[$i]=$(cat semilla\_$i | grep "<tag k=\"oneway\"" | awk -F "v=\"" '{print $2}' | awk -F "\"" '{print $1}');
	if [ $i -gt 1 ]
	then
		# Comparar los sentidos unicos de todos los segmentos. Todos deben tener el mismo valor.
		# Si no es asi. Intervencion manual.
		if [ "${sentido_unico[$(($i-1))]}" != "${sentido_unico[$i]}" ]
		then
			echo "Algun segmento tiene el sentido unico distinto";
			exit 1;
		fi
	fi 
done
comienzo_x=$(./m_transformar_coordenadas $latitud_comienzo $longitud_comienzo | awk '{print $1}');
comienzo_y=$(./m_transformar_coordenadas $latitud_comienzo $longitud_comienzo | awk '{print $2}');
final_x=$(./m_transformar_coordenadas $latitud_final $longitud_final | awk '{print $1}');
final_y=$(./m_transformar_coordenadas $latitud_final $longitud_final | awk '{print $2}');
angulo=$(./m_obtener_angulo $comienzo_x $comienzo_y $final_x $final_y);
if (( $(echo "$angulo < 2.3561945" | bc -l))) || (( $(echo "$angulo > 5.4977871" | bc -l)))
then
	sentido_1=1;
	sentido_2=2;
else
	sentido_1=2;
	sentido_2=1;
fi

# Comprobar si el tramo es de sentido unico o no.
if [ "${sentido_unico[1]}" == "yes" ]
then
	sentido_2=$sentido_1;
	doble_sentido=false;
else
	doble_sentido=true;
fi

echo "Sentido de circulacion establecido";
echo "--";


# Obtener los nodos del tramo semilla.
numero_nodos=$(wc -l nodos_tramo_semilla | awk '{print $1}');
for((i=1;i<$numero_nodos;i++))
do
        nodo=$(awk "NR==$i" nodos_tramo_semilla | awk '{print $1}');
        nodo_siguiente=$(awk "NR==$(($i+1))" nodos_tramo_semilla | awk '{print $1}');
	carriles=$(awk "NR==$i" nodos_tramo_semilla | awk '{print $2}');

        # Obtener la posicion de los nodos.
        nodo_lat=$(grep "<node id=\"$nodo\"" $MAPA | awk -F "lat=\"" '{print $2}' | awk -F "\"" '{print $1}');
        nodo_lon=$(grep "<node id=\"$nodo\"" $MAPA | awk -F "lon=\"" '{print $2}' | awk -F "\"" '{print $1}');

	nodo_x=$(./m_transformar_coordenadas $nodo_lat $nodo_lon | awk '{print $1}');
        nodo_y=$(./m_transformar_coordenadas $nodo_lat $nodo_lon | awk '{print $2}');

        if [ $i -gt 1 ]
        then
                # Insertar coordenadas del nodo del mapa en la lista final de los nodos del tramo.
                echo "Real : $nodo_lat $nodo_lon $carriles" >> nodos_final_tramo_semilla;
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
		echo "Inte : $(./m_transformar_utm_a_lat_lon $nodo_interp_x $nodo_interp_y) $carriles" >> nodos_final_tramo_semilla;
        done
done
echo "";
echo "";


# Conexiones:
# Buscar el nodo final del tramo en otra via. Como sabemos que es otra via? Tenemos que coger los id's de las vias de nuestro tramo semilla.
for ((i=1;i<=$segmentos_semilla;i++))
do
	grep "way id" semilla\_$i | awk -F "id=\"" '{print $2}' | awk -F "\"" '{print $1}' >> way_ids_actuales;
done

# Habra que obtener las vias en las que sale ese nodo, y comprobar que vias no son el tramo actual semilla.
# Obtener los numeros de linea en la que aparece el nodo de conexion.
echo "Extrayendo tramos de conexion ... ";
grep -n "<nd ref=\"$nodo_final\"/>" $MAPA | awk -F ":" '{print $1}' > fichero_numeros_linea;
i=1
numero_conexiones=0;
# Obtener la linea de comienzo y de final de la via de cada segmento. Como maximo 2000 nodos y 10 tags (suponemos) en cada via.
while read num_linea
do
        lineas=$(head -n $num_linea $MAPA | tail -n 2001 | grep -n "<way id=" | tail -n 1 | awk -F ":" '{print $1}');
        linea_comienzo=$(($num_linea-2001+$lineas));
        linea_final=$(head -n $(($num_linea+10)) $MAPA | grep -n "</way>" | tail -n 1 | awk -F ":" '{print $1}');
        # Extraer las vias
        head -n $linea_final $MAPA | tail -n $(($linea_final-$linea_comienzo+1)) > tramo_conexion_$i;
	# Comprobar si el way id esta o no en el fichero de way_ids_actuales.
	way_id=$(grep "<way id=" tramo_conexion\_$i | awk -F "<way id=\"" '{print $2}' | awk -F "\"" '{print $1}');
	if [ ! "$(grep $way_id way_ids_actuales)" ]
	then
		# Asignar el siguiente tramo id a la conexion.
		if [ ! "$(grep $way_id Relacion_tramos_way_ids)" ]
		then
			let numero_conexiones++;
			ultimo_id=$(tail -n 1 Relacion_tramos_way_ids | awk -F ":" '{print $1}');
			nuevo_id=$(($ultimo_id+1));
			echo -e "\t\t\t<its:conexion>" > conexion_$i;
			echo -e "\t\t\t\t<its:tramoId>$nuevo_id</its:tramoId>" >> conexion_$i;
			# Comprobar el numero de carriles en el tramo semilla (el ultimo de los segmentos) y en el tramo destino.
			carriles_semilla=$(cat semilla\_$segmentos_semilla | grep lanes | awk -F "v=\"" '{print $2}' | awk -F "\"" '{print $1}');
			carriles_siguiente=$(cat tramo_conexion\_$i | grep lanes | awk -F "v=\"" '{print $2}' | awk -F "\"" '{print $1}');
			if [ "$carriles_semilla" == 1 ] && [ "$carriles_siguiente" == 1 ]
			then
				echo -e "\t\t\t\t<its:carrilActual>1</its:carrilActual>" >> conexion_$i;
				echo -e "\t\t\t\t<its:carrilSiguiente>1</its:carrilSiguiente>" >> conexion_$i;
				echo -e "\t\t\t\t<its:listaCruces>" >> conexion_$i;
				echo -e "\t\t\t\t\t<its:cruceId>1</its:cruceId>" >> conexion_$i;
				echo -e "\t\t\t\t</its:listaCruces>" >> conexion_$i;
				# TO DO: Calculo automatico restriccion de velocidad.
				echo -e "\t\t\t\t<its:restriccionVelocidad>15</its:restriccionVelocidad>" >> conexion_$i;
			else
				echo -e "\t\t\t\tESTABLECIMIENTO MANUAL DE LA CONEXION" >> conexion_$i;
			fi
			# Si solo hay un carril en ambos, entonces conexion por defecto.
			# Si no es el caso, hay que generar mensaje de revision manual.
			# Para la restriccion de velocidad, de momento manual. Pero se puede automatizar teniendo en cuenta el angulo de los
			# dos ultimos nodos del tramo actual y los dos primeros nodos del siguiente tramo.
			echo -e "\t\t\t</its:conexion>" >> conexion_$i;
		fi
	fi
	rm tramo_conexion\_$i;
        let i++;
done < fichero_numeros_linea
rm way_ids_actuales fichero_numeros_linea;
echo "Conexiones extraidas";
echo "--";
echo "";


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
echo -e "\t\t<its:velocidadMaxima>${vel_max[1]}</its:velocidadMaxima>";
echo -e "\t\t<its:listaSegmentos>";
while read segmento
do
	echo -e "\t\t\t<its:segmento>";
	echo -e "\t\t\t\t<its:posicionSegmentoLatitud>$(echo $segmento | awk '{print $3}')</its:posicionSegmentoLatitud>";
	echo -e "\t\t\t\t<its:posicionSegmentoLongitud>$(echo $segmento | awk '{print $4}')</its:posicionSegmentoLongitud>";
	echo -e "\t\t\t\t<its:dobleSentido>$doble_sentido</its:dobleSentido>";
	echo -e "\t\t\t\t<its:numeroCarriles>$(echo $segmento | awk '{print $5}')</its:numeroCarriles>";
	echo -e "\t\t\t</its:segmento>";
done < nodos_final_tramo_semilla
echo -e "\t\t</its:listaSegmentos>";
echo -e "\t\t<its:listaConexiones>";
for ((i=1;i<=$numero_conexiones;i++))
do
	cat conexion\_$i;
done
echo -e "\t\t</its:listaConexiones>";
echo -e "\t</its:datosTramo>";
echo "</its:tramoSet>";
rm conexion* semilla_* nodos_*;
