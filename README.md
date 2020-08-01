# SIT
Simulador real de tráfico en tiempo real
# ITS
Real Time Road Traffic Simulator

Instrucciones:

1.- Descargar GNAT desde https://www.adacore.com/community

	En Descargas tenemos el paquete: gnat-2020-20200429-x86_64-linux-bin

2.- Cambiar los permisos al paquete para hacerlo ejecutable y ejecutarlo
      Aparecerá un GUI de instalación

3.- Eliminar del nuevo entorno GNAT la biblioteca y objetos xmlada si existieran

4.- Biblioteca xmlada:

	Ir a https://github.com/AdaCore/xmlada

	Pinchar en code y descargar zip xmlada-master.zip

	Unzip xmlada-master.zip en el directorio Descargas

	Ejecutar desde Descargas/xmlada-master: ./configure –prefix=/home/[usuario]/opt/GNAT/2020

	Ejecutar desde Descargas/xmlada-master: make all install
  
  Una vez instalada la biblioteca xmlada crear el directorio /home/[usuario]/ITS
  y copiar los directorios de este repositorio dentro.
  
  Usar gprbuild (o gnatstudio) para generar los ejecutables, theseus, theseus_dinamico y las herramientas para visulizar la adaptacion y los tramos.
