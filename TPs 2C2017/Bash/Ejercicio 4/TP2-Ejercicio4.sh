#!/bin/bash

#####     MENU AYUDA     #####
if test "$1" = "-h" -o "$1" = "-?" -o "$1" = "-help"
then
	echo
	echo "* AYUDA *"
	echo -e "Este script permite controlar para un viaje y una hoja de ruta expresados como archivos .csv si los horarios en cada ciudad fueron cumplidos o no "
	echo -e ", en caso de no ser cumplido deberá informarse por pantalla si se atrasó o adelantó, en que ciudad/es y por cuánto tiempo. "
	echo -e "De cumplirse todos los horarios deberá informarse también por pantalla que el viaje cumplió el horario para todas las ciudades.\n"
	echo "MODO DE USO"
	echo -e "./TP2-Ejercicio4.sh T09_07_08_retiro_tucuman.csv retiro_tucuman.csv \n"
	echo -e "./TP2-Ejercicio4.sh -r <directorio> \n"
	echo "PARAMETROS"
	echo -e "-r <directorio> : recorre todos los archivos .csv del directorio y muestra por pantalla un resumen para cada tren(cantidad de viajes, montos y pasajeros)."
	echo -e "-h, -?, -help : muestra la ayuda del script"
echo "ACLARACIONES:LOS ARCHIVOS DEBEN SER CONSISTENTES CON LOS DATOS DE LA CONSIGNA YA QUE SINO DARA INCONSISTENCIAS EN EL RESULTADO DEL SCRIPT, LOS DIAS DEBEN DIFERENCIAR NO MAS DE UN DIAS ENTRE EL ARCHIVO DE RUTAS Y EL ARCHIVO DE VIAJE PARA CADA CIUDAD"

	echo
	exit 1
fi

##### ERROR EN LA CANTIDAD DE PARAMETROS #####
if [ "$#" -ne 2 ]
then
	echo
	echo "* ERROR: La cantidad de parametros es incorrecta *"
	echo "* Escriba "$0" -h, -?, -help para ver la ayuda *"
	echo
	exit 1
fi
##### ERROR EN LA EXISTENCIA DEL DIRECTORIO CON -r #####
if [ "$1" == "-r" ] && [ ! -d "$2" ]
then
	echo
	echo "* ERROR: El directorio pasado como parametro no existe *"
	echo
	exit 1
fi
##### ERROR EN LA EXISTENCIA DE LOS ARCHIVOS CSV #####
if [ "$1" != "-r" ]
then
	if [ ! -f "$1" ] || [ ! -s "$1" ] 
	then
		echo
		echo "* ERROR: El archivo $1 no existe, o esta vacio. *"
		echo
		exit 1
	fi
	if [ ! -f "$2" ] || [ ! -s "$2" ] 
	then
		echo
		echo "* ERROR: El archivo $2 no existe, o esta vacio. *"
		echo
		exit 1
	fi
fi

#####ERROR NO SON ARCHIVOS CSV###################

if [ "$1" != "-r" ]
then
if [ `echo $1 | awk -F"." '{print $NF}'` != "csv" ] || [ `echo $2 | awk -F"." '{print $NF}'` != "csv" ]
then
 echo "ERROR: el o los archivos no tienen formato csv"
 exit 1
fi
fi



if [ "$1" != "-r" ]
 then 

archivo1=(`echo $(basename "$1") | cut -d "_" -f 4,5 `) 
archivo2=(`echo $(basename "$2") | cut -d "_" -f 1,2 `)

#echo $archivo1 $archivo2

if [ "$archivo1" != "$archivo2" ] 
then
echo "ERROR El orden de los parametros estan mal escritos o al reves"
exit 
fi
fi

##### PROCESO CON EL PARAMETRO -r #####
IFS="
"
if [ "$1" == "-r" ]
then

	declare -a dataviajes=()
	declare -a datapasajeros=()
	declare -a datatotal=()
	declare -a datatren=()
	pepe=0

	lista=$(find "$2" -type f -name "T*.csv")
	
	
	#for pep in ${lista[*]}
#do
#	echo $pep
#done
	for archivo in ${lista[*]}
	do
	
	if [ -s "$archivo" ]
	then
	pepe=$((pepe + 1))	

	dato=$(awk -f script1.awk $archivo)
	
	tren=$(echo $dato | cut  -d "," -f 1 )
	#cantviajes=$(echo $dato | cut -d "," -f 2 )
	cantpasajeros=$(echo $dato | cut -d "," -f 3 )
	montototal=$(echo $dato | cut -d "," -f 4 )
	
	

	variable=$(echo ${tren:0:1})

	if [ $variable == "0" ]
	then
        
	variable=$(echo ${tren:1:1})

	else
	variable=$(echo ${tren:0:2})

	fi

	datatren[$variable]=$tren
	let dataviajes[$variable]+=1
	let datapasajeros[$variable]+=$cantpasajeros
	let datamonto[$variable]+=$montototal
	
	#echo "${datatren[$variable]} ${dataviajes[$variable]} ${datapasajeros[$variable]} ${datamonto[$variable]}"
	
	fi


done

	if [ $pepe -ne 0 ]
	then
	echo -e "Resumen"
	for i in ${!dataviajes[*]}
	do
	echo "tren: ${datatren[$i]}"
	echo "viajes: ${dataviajes[$i]}"
	echo "pasajeros: ${datapasajeros[$i]}"
	echo "tren: ${datamonto[$i]}"
	echo
	done
	else
	echo "NO HAY ARCHIVOS DE FORMATO CORRESPONDIENTE EN LA CARPETA $2"
	fi




	exit 0
else
	notren=$(echo $(basename $1) | cut -d "_" -f 1 )
	tren=$(echo ${notren:1:2})
	awk -v tren="$tren" -f script2.awk "$1" "$2"
	exit 0	
fi


