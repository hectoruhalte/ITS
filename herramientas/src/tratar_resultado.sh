#!/bin/bash
# Herramienta para obtener un fichero csv con los campos relevantes de una simulacion estatica
num_lineas=$(grep -a "SALIDA : " resultado_estatico.txt | wc -l);
strings resultado_estatico.txt | grep VEHICULO | awk '{print $3" "$4}' > matriculas; 
strings resultado_estatico.txt | grep VEHICULO | awk '{print $6}' > marcas;
strings resultado_estatico.txt | grep -A 1 VEHICULO | grep -v VEHICULO | grep -v \- > modelos;
grep -aA 2 "SALIDA :" resultado_estatico.txt | grep -v \- | grep -v SALIDA | grep -v ^$ > calle_salidas;
grep -aA 4 "SALIDA :" resultado_estatico.txt | grep "X :" | awk -F ":" '{print $2}' > salidas_x;
grep -aA 5 "SALIDA :" resultado_estatico.txt | grep "Y :" | awk -F ":" '{print $2}' > salidas_y;
grep -aA 2 "DESTINO :" resultado_estatico.txt | grep -v \- | grep -v DESTINO | grep -v ^$ > calle_destinos;
grep -aA 4 "DESTINO :" resultado_estatico.txt | grep "X :" | awk -F ":" '{print $2}' > destinos_x;
grep -aA 5 "DESTINO :" resultado_estatico.txt | grep "Y :" | awk -F ":" '{print $2}' > destinos_y;
grep -a "DISTANCIA SALIDA-DESTINO" resultado_estatico.txt | awk '{print $6}' > distancias_recta;
grep -aA 2 "DISTANCIA SALIDA-DESTINO" resultado_estatico.txt | grep -i ruta > hay_rutas;
#Cabecera
echo -n "Ruta ID,Matricula,Modelo,Calle Salida,X Salida,Y Salida,Calle Destino,X Destino,Y Destino,Distancia Linea Recta,Ruta?,Tramos,Tiempo Ruta,Distancia Ruta";
echo "";
for (( i=1; i<=$num_lineas; i++))
do
	matricula=$(awk "NR==$i" matriculas);
	marca=$(awk "NR==$i" marcas);
	modelo=$(awk "NR==$i" modelos);
	calle=$(awk "NR==$i" calle_salidas);
	salida_x=$(awk "NR==$i" salidas_x);
	salida_y=$(awk "NR==$i" salidas_y);
	calle_destino=$(awk "NR==$i" calle_destinos);
	destino_x=$(awk "NR==$i" destinos_x);
        destino_y=$(awk "NR==$i" destinos_y);
	distancia_recta=$(awk "NR==$i" distancias_recta);
	hay_ruta=$(awk "NR==$i" hay_rutas);
	if [ "$hay_ruta" == " NO ES POSIBLE ENCONTRAR UNA RUTA" ]
	then
		ruta="NO RUTA";
		tramos="-";
		tiempo_ruta="-";
		distancia_ruta="-";
	else
		# Seleccionar los tramos de la ruta
		ruta="RUTA";
		grep -aA 120 "VEHICULO : $matricula  |  $marca" resultado_estatico.txt | grep -aB 100 -m 1 "TIEMPO (s)" | grep -a ^\| | grep -av ID | awk -F "|" '{print $2}' > tramos_ruta;
		while read tramo
		do
			echo -n "$tramo " >> tramos_file;
		done < tramos_ruta
		tramos=$(cat tramos_file);
		rm tramos_file;
		tiempo_ruta=$(grep -aA 125 "VEHICULO : $matricula  |  $marca" resultado_estatico.txt | grep -a "TIEMPO (s)" | awk '{print $NF}');
		distancia_ruta=$(grep -aA 125 "VEHICULO : $matricula  |  $marca" resultado_estatico.txt | grep -a "DISTANCIA RUTA (m)" | awk '{print $NF}');
	fi
	echo "$i,$matricula,$marca $modelo,$calle,$salida_x,$salida_y,$calle_destino,$destino_x,$destino_y,$distancia_recta,$ruta,$tramos,$tiempo_ruta,$distancia_ruta";
done
rm matriculas marcas modelos calle_salidas salidas_x salidas_y calle_destinos destinos_x destinos_y distancias_recta hay_rutas tramos_ruta;
