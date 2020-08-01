#!/bin/bash
if [ $# -ne 1 ]
then
        echo "Falta el fichero del que extraer la informacion";
        echo "Uso : mapear.sh fichero_mapas.xml";
        exit 1;
fi
./extraer_datos_mapas.sh $1;
calle=$(ls *puntos | awk '{print $NF}' | awk -F "_" '{print $1}');
echo $calle;
./crear_datos_tramo.sh "$calle";
cat *puntos | awk -F "," '{print $1}' > latitudes;
cat *puntos | awk -F "," '{print $2}' > longitudes;
