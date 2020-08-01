#!/bin/bash
if [ $# -ne 1 ]
then
        echo "Falta el nombre del tramo";
        echo "Uso : crear_datos_tramo.sh Lábaro";
        exit 1;
fi
echo "<its:datosTramo>";
# Obtener id del tramo
id=$(grep $1 calles | awk -F "," '{print $2}');
echo -e "\t<its:id>$id</its:id>";
# Obtener el nombre del tramo
nombre=$(grep $1 calles | awk -F "," '{print $1}');
echo -e "\t<its:nombreTramo>$nombre</its:nombreTramo>";
# Obtener comienzo del tramo
comienzo=$(awk "NR==1" "$nombre"_puntos);
latitud_comienzo=$(echo $comienzo | awk -F "," '{print $1}');
longitud_comienzo=$(echo $comienzo | awk -F "," '{print $2}');
echo -e "\t<its:comienzoLatitud>$latitud_comienzo</its:comienzoLatitud>";
echo -e "\t<its:comienzoLongitud>$longitud_comienzo</its:comienzoLongitud>";
numero_puntos=$(wc -l "$nombre"_puntos | awk '{print $1}');
final=$(awk "NR==$numero_puntos" "$nombre"_puntos);
latitud_final=$(echo $final | awk -F "," '{print $1}');
longitud_final=$(echo $final | awk -F "," '{print $2}');
echo -e "\t<its:finalLatitud>$latitud_final</its:finalLatitud>";
echo -e "\t<its:finalLongitud>$longitud_final</its:finalLongitud>";
altura=$(grep $1 calles | awk -F "," '{print $3}');
echo -e "\t<its:altura>$altura</its:altura>";
# Tenemos las vias. Obtener las velocidades. Si son distintos => Partir tramos.
ls via* > vias;
while read via
do
	grep zone:maxspeed $via | awk -F "ES:" '{print $2}' | awk -F "\"" '{print $1}' >> velocidades;
done < vias
if [ $(sort velocidades | uniq | wc -l) -eq 1 ]
then
	# Un solo tramo
	velocidad=$(sort velocidades | uniq);
else
	# Velocidades maximas distintas => Hacer tantos tramos como velocidades.
	# De momento sacamos warning => Habra que coger las vias con la misma velocidad y hacer un tramo con ellas.
	echo "Velocidades maximas distintas => Hay que hacer más tramos";
fi
# Obtener si es de un solo sentido.
while read via
do
        grep oneway $via | awk -F "v=\"" '{print $2}' | awk -F "\"" '{print $1}' >> sentidos;
done < vias
if [ $(sort sentidos | uniq | wc -l) -eq 1 ]
then
	sentido=$(sort sentidos | uniq);
	if [ "$sentido" == "yes" ]
	then
		doblesentido="false";
		carriles=1;
	else
		doblesentido="true";
	fi 
fi
echo -e "\t<its:velocidadMaxima>$velocidad</its:velocidadMaxima>";
# Obtener los puntos de los segmentos.
echo -e "\t<its:listaSegmentos>";
for i in $(seq 2 $(($numero_puntos - 1)))
do
	latitud=$(awk "NR==$i" "$nombre"_puntos | awk -F "," '{print $1}');
	longitud=$(awk "NR==$i" "$nombre"_puntos | awk -F "," '{print $2}');
	echo -e "\t\t<its:segmento>";
	echo -e "\t\t\t<its:posicionSegmentoLatitud>$latitud</its:posicionSegmentoLatitud>";
	echo -e "\t\t\t<its:posicionSegmentoLongitud>$longitud</its:posicionSegmentoLongitud>";
	echo -e "\t\t\t<its:dobleSentido>$doblesentido</its:dobleSentido>";
	echo -e "\t\t\t<its:numeroCarriles>$carriles</its:numeroCarriles>";
	echo -e "\t\t</its:segmento>"; 
done
echo -e "\t</its:listaSegmentos>";
echo "</its:datosTramo>";
rm velocidades sentidos via*;
