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

# Obtener el way_id y el nodo de conexion
way_id_conexion=$(cat way_nodo_conexion | awk '{print $1}');
nodo_conexion=$(cat way_nodo_conexion | awk '{print $2}');

echo "";

for((i=1;i<=$1;i++))
do
	echo "Extrayendo el tramo $i";
	# Obtener las vias que contengan el nodo conexion.
	# Hay que ignorar los tramos que ya se hayan creado. 
	# Es decir ignorar las way_ids que ya esten en el fichero Relacion_tramos_way_ids y quedarnos con las "nuevas"
	grep -n "<nd ref=\"$nodo_conexion\"/>" $MAPA | awk -F ":" '{print $1}' > fichero_numeros_linea;
	j=1;
	while read num_linea
	do
		echo -n "·";
        	lineas=$(head -n $num_linea $MAPA | tail -n 2001 | grep -n "<way id=" | tail -n 1 | awk -F ":" '{print $1}');
        	linea_comienzo=$(($num_linea-2001+$lineas));
        	linea_final=$(head -n $(($num_linea+10)) $MAPA | grep -n "</way>" | tail -n 1 | awk -F ":" '{print $1}');
        	# Extraer las vias
        	head -n $linea_final $MAPA | tail -n $(($linea_final-$linea_comienzo+1)) > segmento_$j;
        	way_id=$(cat segmento\_$j | grep "way id" | awk -F "<way id=\"" '{print $2}' | awk -F "\"" '{print $1}');
		# Desechar el segmento que tenga el way_id igual al way_id_conexion.
		if [ "$way_id" == "$way_id_conexion" ]
		then
			# Eliminar el segmento. No se tendra en cuenta.
			rm segmento\_$j;
		else
			# Aqui ya tendriamos un segmento.
        		# Hay que comprobar para cada nodo a partir del nodo de conexion si se comparten o no por otros segmentos.
				
        		# Obtener la lista de nodos a partir del nodo de conexion.
			cat segmento\_$j | grep "<nd ref=" | awk -F "\"" '{print $2}' | awk -F "\"" '{print $1}' > nodos_$j;
			linea_nodo_conexion=$(grep -n $nodo_conexion nodos\_$j | awk -F ":" '{print $1}');
			tail -n $(($(wc -l nodos\_$j | awk '{print $1}')-$linea_nodo_conexion+1)) nodos\_$j > nodos_prov_$j;
			# Recorrer los nodos y comprobar en cuantas vias esta presente.
			while read nodo
			do
				if [ $(($(grep -n "<nd ref="$nodo"/>" $MAPA | awk -F ":" '{print $1}'))) -gt 1 ]
				then
					# Aparece mas de una vez. Es el nodo final del tramo.
					nodo_final=$nodo;
					echo "$nodo" >> nodos_final;
					break;
				fi
				# Si todos los nodos aparecen solo una vez, el ultimo nodo sera el final.
				echo "$nodo" >> nodos_final;
			done < nodos_prov\_$j
			# Ya tenemos el segmento, el nodo de conexion (el comienzo) y el nodo final.
			# Obtener el id y añadir el id y el way_id
			id=$(($(tail -n 1 Relacion_tramos_way_ids | awk -F ":" '{print $1}')+1));
			echo "$id:$way_id" >> Relacion_tramos_way_ids;
			nombre_tramo=$(cat segmento\_$j | grep "<tag k=\"name\"" | awk -F "v=\"" '{print $2}' | awk -F "\"" '{print $1}');
			latitud_comienzo=$(grep "<node id=\"$nodo_conexion\"" $MAPA | awk -F "lat=\"" '{print $2}' | awk -F "\"" '{print $1}');
			longitud_comienzo=$(grep "<node id=\"$nodo_conexion\"" $MAPA | awk -F "lon=\"" '{print $2}' | awk -F "\"" '{print $1}');
			nodo_final=$(tail -n 1 nodos_final | awk '{print $1}');
			latitud_final=$(grep "<node id=\"$nodo_final\"" $MAPA | awk -F "lat=\"" '{print $2}' | awk -F "\"" '{print $1}');
			longitud_final=$(grep "<node id=\"$nodo_final\"" $MAPA | awk -F "lon=\"" '{print $2}' | awk -F "\"" '{print $1}');
			# Sacar por pantalla el tramo
			echo "";
			echo -e "\t<its:datosTramo>";
			echo -e "\t\t<its:id>$id</its:id>";
			echo -e "\t\t<its:nombreTramo>$nombre_tramo</its:nombreTramo>";
			echo -e "\t\t<its:comienzoLatitud>$latitud_comienzo</its:comienzoLatitud>";
			echo -e "\t\t<its:comienzoLongitud>$longitud_comienzo</its:comienzoLongitud>";
			echo -e "\t\t<its:finalLatitud>$latitud_final</its:finalLatitud>";
			echo -e "\t\t<its:finalLongitud>$longitud_final</its:finalLongitud>";
			echo -e "\t</its:datosTramo>";
			echo ""; 
		fi
        	let j++;
	done < fichero_numeros_linea
	
	echo "";
	echo "======================";
done
