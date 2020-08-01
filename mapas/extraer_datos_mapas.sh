#!/bin/bash
if [ $# -ne 1 ]
then
	echo "Falta el fichero del que extraer la informacion";
	echo "Uso : extraer_datos_mapas.sh fichero_mapas.xml";
	exit 1;
fi
if [ ! -f $1 ]
then
	echo "$1 no encontrado";
	exit 1;
fi
pi=3.1415927;
R=6371000;
# Obtener los datos de las vias
#
#<way id=xxxxxxx
#	.............
#	<tag k="highway"
#	.............
#	<tag k="name"
#	.............
#</way>
#
# Habra que coger el contenido entre las etiquetas <way> y </way> que contengan el <tag k="highway"
# Obtenemos el numero de linea de las etiquetas <way>
echo ".- Obteniendo lineas de apertura y cierre de vias de $1";
grep -n "<way" $1 | awk -F ":" '{print $1}' > lineas_apertura;
grep -n "</way>" $1 | awk -F ":" '{print $1}' > lineas_cierre;
n=1
echo ".- Lineas de apertura y cierre obtenidas correctamente";
while read numero_linea
do
	linea_cierre=$(awk "NR==$n" lineas_cierre);
	diferencia=$(($linea_cierre - $numero_linea + 1));
	head -n $linea_cierre $1 | tail -n $diferencia > via_$n;
	let n++;
done < lineas_apertura
let n--;
rm lineas_apertura lineas_cierre;
while read linea
do
	calle=$(echo $linea | awk -F "," '{print $1}');
	for i in $(seq 1 $n)
	do
		if [[ $(grep "$calle" via_$i) && $(grep highway via_$i) ]]
		then
			#Obtener los nodos.
			grep "<nd" via_$i | awk -F "\"" '{print $2}' >> aux; 
		else
			rm via_$i;
		fi
	done
done < calles
cat aux | uniq > nodos;
# Buscar los nodos en el fichero xml y obtener las coordenadas de los nodos.
while read nodo
do
	lat=$(grep "node id=\"$nodo\"" $1 | awk -F "lat=\"" '{print $2}' | awk -F "\"" '{print $1}');
	lon=$(grep "node id=\"$nodo\"" $1 | awk -F "lon=\"" '{print $2}' | awk -F "\"" '{print $1}');
	lat_rad=$(echo "scale=7; $lat*$pi/180" | bc);
	lon_rad=$(echo "scale=7; $lon*$pi/180" | bc);
	echo -e $lat","$lon >> puntos_grados;
	echo -e $lat_rad","$lon_rad >> puntos;
done < nodos
rm aux nodos;
#rm nodos;
num_puntos=$(wc -l puntos | awk '{print $1}');
for i in $(seq 1 $(($num_puntos - 1)))
do
	awk "NR==$i" puntos_grados >> "$calle"_puntos;
	punto_1=$(awk "NR==$i" puntos);
	punto_2=$(awk "NR==$i+1" puntos);
	lat_1=$(echo $punto_1 | awk -F "," '{print $1}');
	lon_1=$(echo $punto_1 | awk -F "," '{print $2}');
	lat_2=$(echo $punto_2 | awk -F "," '{print $1}');
	lon_2=$(echo $punto_2 | awk -F "," '{print $2}');
	distancia=$(./distancia.tcl $lat_1 $lon_1 $lat_2 $lon_2);
	num_puntos_interp=$(echo "$distancia / 5.625" | bc);
	# Si la distancia entre dos puntos es mayor de 7.5 metros => Interpolar
	# Una distancia de 7.5 metros para interpolar parece dar menos segmentos por tramos de los esperados.
	# Vamos a cambiarlo a 5.0 metros. Demasiados puntos, pero mas cerca.
	# Vamos a cambiarlo a 6.25 metros.
	# Vamos a ponerlo definitivamente en 5.625
	if (( $(echo "$distancia > 5.625" | bc -l) ));
	then
		num_intervalos=$(($num_puntos_interp + 1));
		dist_horizontal=$(echo "$lon_2 - $lon_1" | bc -l);
		dist_vertical=$(echo "$lat_2 - $lat_1" | bc -l);
		m=$(echo "$dist_vertical / $dist_horizontal" | bc -l);
		dist_intervalo=$(echo "$dist_horizontal / $num_intervalos" | bc -l);
		# Inicializar longitud del punto de interpolacion
		long_interp=$lon_1;
		for j in $(seq 1 $(($num_puntos_interp)))
		do
			# Longitud del punto de interpolacion
			long_interp=$(echo "scale=7; $long_interp + $dist_intervalo" | bc -l);
			# Latitud del punto de interpolacion
			x=$(echo "scale=7; $long_interp - $lon_1" | bc -l);
			lat_interp=$(echo "scale=7; $x * $m + $lat_1" | bc -l);
			lat_interp_grados=$(echo "scale=7; $lat_interp*180/$pi" | bc -l);
			lon_interp_grados=$(echo "scale=7; $long_interp*180/$pi" | bc -l);
			echo -e $lat_interp_grados","$lon_interp_grados >> "$calle"_puntos;	
		done
	fi
done
rm puntos*;
