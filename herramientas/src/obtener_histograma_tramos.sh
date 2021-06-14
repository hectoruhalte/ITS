#!/bin/bash
cat resultado_estatico.txt | grep -a ^\| | grep -av ID | awk -F "|" '{print $2}' > resultado_tramos_histograma;
sed -i 's/ //g' resultado_tramos_histograma;
echo "--";
echo "Obteniendo histograma de tramos para los tramos del 1 al 475";
echo "--";
NUMERO_TRAMOS=475;
for (( i=1; i<=$NUMERO_TRAMOS; i++ ))
do
	veces=$(grep ^$i$ resultado_tramos_histograma | wc -l);
	echo "$i $veces";
done
