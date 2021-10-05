#!/bin/bash
###################################################
#
# Script para obtener el tramo semilla de los mapas
#
###################################################

# Estas dos variables deberian ser variables de linea de comandos.
SEMILLA="Calle del Lábaro";
MAPA="cantabria-latest.osm";

# Obtener el numero de segmentos de la via.
echo ""; 
echo "Obteniendo el numero de segmentos de la via semilla : $SEMILLA";
segmentos_semilla=$(grep -c "<tag k=\"name\" v=\"$SEMILLA\"/>" $MAPA);
echo "Segmentos de la via semilla : $segmentos_semilla";
echo "--";

# Obtener los numeros de linea en la que aparece el nombre de la semilla.
echo "Extrayendo segmentos ... ";
grep -n "<tag k=\"name\" v=\"Calle del Lábaro\"/>" $MAPA | awk -F ":" '{print $1}' > fichero_numeros_linea;
i=1
# Obtener la linea de comienzo y de final de la via de cada segmento. Como maximo 2000 nodos y 10 tags (suponemos) en cada via.
while read num_linea
do
	lineas=$(head -n $num_linea $MAPA | tail -n 2001 | grep -n "<way id=" | tail -n 1 | awk -F ":" '{print $1}');
	linea_comienzo=$(($num_linea-2001+$lineas));
	linea_final=$(head -n $(($num_linea+10)) $MAPA | grep -n "</way>" | tail -n 1 | awk -F ":" '{print $1}');
	# Extraer las vias
	head -n $linea_final $MAPA | tail -n $(($linea_final-$linea_comienzo+1)) > semilla_$i;
	let i++;	
done < fichero_numeros_linea
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
		cat semilla\_$i | grep "<nd ref" | awk -F "\"" '{print $2}' >> nodos_bruto;
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
				break;
                	fi
        	fi
		echo "El sentido del tramo semilla es descendente";
        	echo "--";
        	# Unificar nodos del tramo semilla.
        	for ((i=$segmentos_semilla;i>=1;i--))
        	do
                	cat semilla\_$i | grep "<nd ref" | awk -F "\"" '{print $2}' >> nodos_bruto;
        	done

        	# Eliminar los nodos de conexion que estaran repetidos.
        	cat nodos_bruto | uniq > nodos_tramo_semilla;
        	rm nodos_bruto;
	done
fi

# Obtener coordenadas del comienzo del tramo
echo "Obteniendo las coordenadas del origen del tramo";
nodo_comienzo=$(head -n 1 nodos_tramo_semilla);
latitud_comienzo=$(grep "<node id=\"$nodo_comienzo\"" $MAPA | awk -F "lat=\"" '{print $2}' | awk -F "\"" '{print $1}');
longitud_comienzo=$(grep "<node id=\"$nodo_comienzo\"" $MAPA | awk -F "lon=\"" '{print $2}' | awk -F "\"" '{print $1}');
echo "Coordenadas de origen obtenidas";
echo "--";

# Obtener coordenadas del final del tramo.
echo "Obteniendo las coordenadas del final del tramo";
nodo_final=$(tail -n 1 nodos_tramo_semilla);
latitud_final=$(grep "<node id=\"$nodo_final\"" $MAPA | awk -F "lat=\"" '{print $2}' | awk -F "\"" '{print $1}');
longitud_final=$(grep "<node id=\"$nodo_final\"" $MAPA | awk -F "lon=\"" '{print $2}' | awk -F "\"" '{print $1}');

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
echo -e "\t</its:datosTramo>";
echo "</its:tramoSet>";
