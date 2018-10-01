#!/bin/bash

####main#########

if [ $# -eq 1 ];then
	if [ $1 = "-?" ] || [ $1 = "-h" ] || [ $1 = "-help" ];then
	echo " el scritp permite alterar el contenido de las carpetas de un directorio segun los parametros ingresados...

-e elimina los directorios vacios
-a elimina archivos con el mismo contenido dejando uno de ellos
-m mueve archivos entre directorios renombrando los duplicados

EJ

./Ejercicio3.sh -a            (usa el directorio actual)
./Ejercicio3.sh -a -r           (usa el directorio actual y recursivo)
./Ejercicio3.sh -a /home/user/descargas           (usa el directorio como destino)
./Ejercicio3.sh -a -r /home/user/descargas           (usa el directorio ingresado y recursivo)
./Ejercicio3.sh -e	 			         (usa el directorio actual)
./Ejercicio3.sh -e /home/user/descargas           (usa el directorio ingresado como destino)
./Ejercicio3.sh -m /home/user/descargas           (usa el directorio ingresado como destino y el actual)
./Ejercicio3.sh -m -r /home/user/descargas           (usa el directorio ingresado como destino recursivo y el directorio actual)
./Ejercicio3.sh -m -r /home/user/descargas /home/user/escritorio   (usa el directorio descargas como destino y el directorio escritorio para sacar y mover los archivos siendo este recuriso)

ACLARACIONES DE USO

-MANTENER LOS ARCHIVOS CERRADOS AL EJECUTAR EL SCRIPT
-INTENTAR NO USAR RECURSIVIDAD ENTRE CARPETAS PADRE E HIJO
----MUY IMPORTANDO SOLO FILTRA ARCHIVOS DE TEXTO PLANO---
-LA ELIMINACION DE CARPETAS VACIAS NO SE HARA SI HAY ALGUN ARCHIVO
-----------SI SE QUIERE MOVER ARCHIVOS A UN DIRECTORIO QUE POSEE SUBDIRECTORIOS CON NOMBRES IGUALES A LOS ARCHIVOS,LOS MISMOS NO SE MOVERAN---
"
exit
fi
fi

if [ $# -lt 1 ] || [ $# -gt 4 ] ;then
   echo "ERROR: cantidad de parametros incorrectos"
   exit;
fi

###para borrar repetidos#####
if [ "$1" = "-a" ];then
  if [ $# -eq 1 ];then
    
    declare -a lista=()
    
    IFS=$"
" #salto de linea porque no me toma el "\n"	
	
    lista=$(find `pwd` -maxdepth 1 -type f)
	
	for j in ${lista[*]}
	do 
		
#	 $(file -i "$j" | grep "text/plain") >> /dev/null   #no entiendo porque solo lo hace para el primer archivo que encuentra y para los demas no
	
#	if [ $? -eq 0 ];then
#	echo $j
#	fi
	
	vector[i++]="$j"
	
	done
	
	##vector para saber si se elimina el archivo##
	
		for h in ${lista[*]}
		do
	
		control=0
	
		for j in ${lista[*]}
		do 
	
		control=$((control+1))

		done


	valor=$control

	i=0
	
	


	while [ $valor -gt $i ];
	do

		if [ "$h" != "${vector[$i]}" ];then

		
		diff -q "$h" "${vector[$i]}" > /dev/null 2>&1		

		if [ $? -eq 0 ];then
		 rm -f "${vector[$i]}"
		unset vector[$i]

		i=$((i-1));
		valor=$((valor-1));
		fi
	fi
	
	
	i=$((i+1));	

	done
	done

 	echo "ARCHIVOS DUPLICADOS ELIMINADOS..."
	exit
	
else   if [ $# -eq 2 ] && [ $2 = "-r" ]  ;then #2
	
	declare -a lista=()
    
    	IFS=$"
	" #salto de linea porque no me toma el "\n"	
	
	lista=$(find `pwd` -type f)
	
	for j in ${lista[*]}
	do 
	
	vector[i++]="$j"
	
	done
	
	##vector para saber si se elimina el archivo##
	
		for h in ${lista[*]}
		do
	
		control=0
	
		for j in ${lista[*]}
		do 
	
		control=$((control+1))

		done


		valor=$control

		i=0
	
	


		while [ $valor -gt $i ];
		do

		if [ "$h" != "${vector[$i]}" ];then

		
			diff -q "$h" "${vector[$i]}" > /dev/null 2>&1		
	
			if [ $? -eq 0 ];then
			 rm -f "${vector[$i]}"
			unset vector[$i]

			i=$((i-1));
			valor=$((valor-1));
			fi
		fi
	
	
		i=$((i+1));	

		done
		done
		echo "ARCHIVOS DUPLICADOS ELIMINADOS..."
		exit
	else  if [ $# -eq 2 ];then #3
		if [ ! -d $2 >> /dev/null ];then 
		echo "ERROR:el directorio pasado por parametro no existe..."
		exit
		fi

		declare -a lista=()
    
	    	IFS=$"
		" #salto de linea porque no me toma el "\n"	
	
		lista=$(find "$2" -maxdepth 1 -type f)
	
		for j in ${lista[*]}
		do 
	
		vector[i++]="$j"
	
		done
	
		##vector para saber si se elimina el archivo##
	
		for h in ${lista[*]}
		do
	
		control=0
	
		for j in ${lista[*]}
		do 
	
		control=$((control+1))

		done


		valor=$control

		i=0
	
	


		while [ $valor -gt $i ];
		do

		if [ "$h" != "${vector[$i]}" ];then

		
			diff -q "$h" "${vector[$i]}" > /dev/null 2>&1		
	
			if [ $? -eq 0 ];then
			 rm -f "${vector[$i]}"
			unset vector[$i]

			i=$((i-1));
			valor=$((valor-1));
			fi
		fi
	
	
		i=$((i+1));	

		done
		done
echo "ARCHIVOS DUPLICADOS ELIMINADOS..."
		exit
	else if [ $# -eq 3 ] && [ $2 = "-r" ];then #4
		if [ ! -d $3 >> /dev/null ];then
		echo "ERROR: el directorio ingresado no existe..."
		exit
		fi

		declare -a lista=()
    
	    	IFS=$"
		" #salto de linea porque no me toma el "\n"	
	
		lista=$(find "$3" -type f)
	
		for j in ${lista[*]}
		do 
	
		vector[i++]="$j"
	
		done
	
		##vector para saber si se elimina el archivo##
	
		for h in ${lista[*]}
		do
	
		control=0
	
		for j in ${lista[*]}
		do 
	
		control=$((control+1))

		done


		valor=$control

		i=0
	
	


		while [ $valor -gt $i ];
		do

		if [ "$h" != "${vector[$i]}" ];then

		
			diff -q "$h" "${vector[$i]}" > /dev/null 2>&1		
	
			if [ $? -eq 0 ];then
			 rm -f "${vector[$i]}"
			unset vector[$i]

			i=$((i-1));
			valor=$((valor-1));
			fi
		fi
	
	
		i=$((i+1));	

		done
		done
	echo "ELIMINACION DE ARCHIVOS DUPLICADOS FINALIZADA..."		
	exit
	fi #4
	fi #3
	fi #2
	fi #1
	fi

#########fin a###################


########Eliminacion de carpetas vacias ##################
if [ "$1" = "-e" ];then
  if [ $# -eq 1 ];then

	declare -a lista=()
    	
    	IFS=$"
	" #salto de linea porque no me toma el "\n"	
	
	lista=$(find `pwd` -type d)
	##tengo todas las carpetas
	#for j in ${lista[*]}
	#do 
	
	#carpetas[i++]="$j"
	
	#done
	
	##vector para saber si se elimina el archivo##
	
	for h in ${lista[*]}
	do
	

	if [ -d $h ];then
	archivos=$(find "$h" -type f)
	
	cantidad=0	

	for j in ${archivos[*]}
	do 
	
	cantidad=$((cantidad+1))

	done


	if [ $cantidad -eq 0 ];then
		
	 rmdir -p "$h" > /dev/null 2>&1
	fi
	fi
	done
	echo "CARPETAS VACIAS ELIMINAS..."
	exit
	
	else  if [ $# -eq 2 ];then
		if [ ! -d $2 ];then 

			echo "ERROR: el directorio pasado como parametro no existe..."
		exit
		fi

		declare -a lista=()
 	
	    	IFS=$"
	" #salto de linea porque no me toma el "\n"	
	
		lista=$(find "$2" -type d)
	
		for h in ${lista[*]}
		do
		if [ -d $h ];then
		archivos=$(find "$h" -type f)
	
		cantidad=0	

		for j in ${archivos[*]}
		do 
	
		cantidad=$((cantidad+1))

		done


		if [ $cantidad -eq 0 ];then
		
		 rmdir -p "$h" > /dev/null 2>&1
		fi
		fi
		done
		echo "CARPETAS VACIAS ELIMINAS..."
		exit

fi					
fi
fi



########fin e#######

######mover archivos a otro directorio##########
if [ "$1" = "-m" ];then
  if [ $# -eq 1 ];then
	echo "ERROR:PARAMETROS INCORRECTOS,CONSULTA LA AYUDA..."
	exit
  fi
  if [ $# -eq 2 ];then
	if [ ! -d $2 ];then
		echo "ERROR NO EXISTE EL DIRECTORIO $2"
	exit
	fi
	
	if [ $2 == `pwd` ];then
		echo "ERROR LOS ARCHIVOS NO SE PUEDEN PASAR EN EL MISMO DIRECTORIO..."
	exit
	fi

	declare -A lista=()
	IFS=$"
"

	lista=$(find `pwd` -maxdepth 1 -type f)
	
	#echo $lista


	for h in ${lista[*]}
	do
	archivos[i++]="$h"
	done


	for j in ${lista[*]}
	do 
	
#	archivos[i++]="$j"

	#echo $j $2
	
	existe=0;
	destino=$(find "$2" -maxdepth 1 -type f)
	#echo $destino
	
	for i in ${destino[*]}
	do 
	
	if [ $(basename $i) = $(basename $j) ];then
	  existe=1
	
	fi
	done

	if [ $existe -eq 1 ];then
	base=$(echo $(basename $j))
	path=$(echo $(dirname $j))	
	
	renombre=$(echo "$path""_""$base")	
	#echo $renombre
	mv $j $renombre
	
	
	mv -f $renombre $2
	
	else
	mv $j $2
	fi

	done
	
	echo "ARCHIVO PASADOS A $2 EXITOSAMENTE..."
	exit
		
	else 	if [ $# -eq 3 ] && [ $2 = "-r" ];then
		   if [ ! -d $3 ];then
			echo "ERROR: EL DIRECTORIO NO EXISTE"
			exit
		   fi

		if [ $3 == `pwd` ];then
		echo "ERROR LOS ARCHIVOS NO SE PUEDEN PASAR EN EL MISMO DIRECTORIO..."
	exit
	fi
			
		declare -A lista=()
		IFS=$"
"

		lista=$(find `pwd` -type f)
	
	
		for j in ${lista[*]}
		do 
	
	
		existe=0;
		destino=$(find "$3" -maxdepth 1 -type f)
	
	
		for i in ${destino[*]}
		do 
	
		if [ $(basename $i) = $(basename $j) ];then
		  existe=1
	
		fi
		done

		if [ $existe -eq 1 ];then
		base=$(echo $(basename $j))
		path=$(echo $(dirname $j))	
	
		renombre=$(echo "$path""_""$base")	
#		echo $renombre
		mv $j $renombre
	
	
		mv $renombre $3
	
		else
		mv $j $3
		fi

		done
	
		echo "ARCHIVO PASADOS A $3 EXITOSAMENTE..."
		exit
	else if [ $# -eq 3 ];then
		if [ ! -d $2 ] || [ ! -d $3 ];then
		echo " ERROR NO EXISTE ALGUNO O AMBOS DIRECTORIOS..."
		fi

		if [ $3 == $2 ];then
		echo "ERROR LOS ARCHIVOS NO SE PUEDEN PASAR EN EL MISMO DIRECTORIO..."
	exit
	fi

		declare -A lista=()
		IFS=$"
"

		lista=$(find "$3" -maxdepth 1 -type f)
	
	
		for j in ${lista[*]}
		do 
	
	
		existe=0;
		destino=$(find "$2" -maxdepth 1 -type f)
	
	
		for i in ${destino[*]}
		do 
	
		if [ $(basename $i) = $(basename $j) ];then
		  existe=1
	
		fi
		done

		if [ $existe -eq 1 ];then
		base=$(echo $(basename $j))
		path=$(echo $(dirname $j))	
	
		renombre=$(echo "$path""_""$base")	

		mv $j $renombre
		mv $renombre $2
	
		else
		mv $j $2
		fi

		done
	
		echo "ARCHIVO PASADOS A $2 EXITOSAMENTE..."
		exit	 

	else if [ $# -eq 4 ] && [ $2 = "-r" ];then
	
		if [ ! -d $3 ] || [ ! -d $4 ];then
		echo "ERROR UNO AMBOS ARCHIVOS NO EXISTE..."
		exit
		fi
		
		declare -A lista=()
		IFS=$"
"
		lista=$(find "$4" -type f)
	
	
		for j in ${lista[*]}
		do 
		
		existe=0;
		destino=$(find "$3" -maxdepth 1 -type f)
	
	
		for i in ${destino[*]}
		do 
	
		if [ $(basename $i) = $(basename $j) ];then
		  existe=1
	
		fi
		done

		if [ $existe -eq 1 ];then
		base=$(echo $(basename $j))
		path=$(echo $(dirname $j))	
	
		renombre=$(echo "$path""_""$base")	

		mv $j $renombre
	
		mv $renombre $3
	
		else
		mv $j $3
		fi

		done
	
		echo "ARCHIVO PASADOS A $3 EXITOSAMENTE..."
		exit	 


fi
fi
fi
fi
fi

echo "Error en la declaracion de los parametros,consulte la ayuda...."



