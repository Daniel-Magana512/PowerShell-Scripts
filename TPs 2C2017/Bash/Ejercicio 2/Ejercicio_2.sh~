#!/bin/bash

# [CORRECCION] Cambio -eq por == , y verifico que la cantidad de parametros sea solo 1
if [[ ($1 == "-?" || $1 == "-h" || $1 == "-help") && $# -eq 1 ]]
then
	echo "	
	Descripcion:
	El script toma los datos de los usuarios que se desean crear en el sistema y evalua si pueden ser creados o no.
	En los casos que sea posible se les asignara un nombre de usuario en base a su apellido y nombres.
	Durante la ejecucion se actualizara un archivo .log indicando si la operacion de crear un determinado usuario fue exitosa o no.

	Parametros: 
	Path de un archivo de texto con los datos de los usuarios existentes en el sitema.
	Path de un archivo de texto con los datos de los usuarios que se desean crear en el sistema.
	
	Ejemplo:
	./Ejercicio_2.sh users_actuales.txt users_a_crear_txt
	"

	exit 1
fi

# Valido que la cantidad de parametros enviados sea de 2
if [[ $# -ne 2 ]]
then
	echo "La cantidad de parametros ingresada no es igual a 2, se requiere de dos parametros que son el archivo con los usuarios actuales y el archivo con los usuarios a crear..."
	exit 1
fi

# Valido el path del archivo 1
if [[ ! -e "$1" ]]
then
	echo "El path del archivo 1 no es valido"
	exit 1
fi

# Valido el path del archivo 2
if [[ ! -e "$2" ]]
then
	echo "El path del archivo 2 no es valido"
	exit 1
fi

# Valido que el archivo 1 sea de texto plano
if ! file --mime-type "$1" | grep -q text/plain$;
then
	echo "El archivo 1 no es de texto"
fi

# Valido que el archivo 2 sea de texto plano
if ! file --mime-type "$2" | grep -q text/plain$;
then
	echo "El archivo 2 no es de texto"
fi

# Valido que el archivo 1 no este vacio
if [[ ! -s "$1" ]]
then
	echo "El archivo 1 esta vacio"
	exit 1
fi

# Valido que el archivo 2 no este vacio
if [[ ! -s "$2" ]]
then
	echo "El archivo 2 esta vacio"
	exit 1
fi

# Archivo con el log de los usuarios.
file="usuarios.log"

# Array donde voy a almacenar los nombres de los usuarios ya existentes.
declare -a array_users

# [CORRECCION] Array donde voy a almacenar los DNI de los usuarios ya existentes.
declare -a array_dnis

# Para indexar dicho array.
pos_array=0

# Indice que indica hasta que letra del nombre voy a tomar para crear el usuario.
i=1

# Cantidad maxima de caracteres admitidos en el nombre de usuario.
max_caracteres=16

# Flag para indicar si no se pudo crear un usuario.
hubo_error=false

# [CORRECCION] Flag para indicar si el DNI esta repetido.
dni_repetido=false

# Si el log de los usuarios no existe, lo creo.
if [[ ! -f "$file" ]]
then
	touch "$file"
fi

# [CORRECCION] Aca guardo los DNI y nombres de usuario existentes en el array.
while IFS='' read -r line1 || [[ -n "$line1" ]];
do
	dni=${line1%%;*}
	user_viejo=${line1#*;}
	array_dnis[pos_array]=$dni
	array_users[pos_array]=${user_viejo%%;*}
	pos_array=$pos_array+1

done < "$1"

# Aca genero los nuevos usuarios (si es posible).
while IFS='' read -r line2 || [[ -n "$line2" ]];
do
	# Guardo la fecha y hora
	fecha=$(date)

	# Guardo el DNI
	dni=${line2%%;*}

	# [CORRECCION] Recorro el Array de dnis para ver si ya existe un usuario con ese mismo DNI.
	for (( index=0; index<${#array_dnis[@]}; index++ ))
	do
		# Si el DNI ya existe
		if [[ $dni == ${array_dnis[$index]} ]]
		then
			echo "$fecha::ERROR::$dni::DNI repetido." >> $file

			# Corto el ciclo y marco que el DNI esta repetido.
			index=${#array_dnis[@]}
			dni_repetido=true
		fi
	done
	
	# [CORRECCION] Si no se encontro que el DNI esta repetido, intento dar de alta al usuario.
	if [[ $dni_repetido == false ]]
	then
		# Guardo la linea desde el primer ';' sin incluirlo.
		cadena=${line2#*;}

		# Guardo la cadena desde el primer ';' sin incluirlo.
		nombres_original=${cadena#*;}

		# Trim de los espacios
		nombres=${nombres_original// }

		# Guardo la cadena desde el primer ';' hacia el comienzo.
		apellido=${cadena%;*}

		# Si llego al maximo de caracteres con mi apellido.
		if [[ ${#apellido} -ge "$max_caracteres" ]]
		then
			echo "$fecha::ERROR::$dni::Maximo de caracteres excedido por apellido demasiado largo." >> $file
		
		else
			# Concateno el caracter de nombres desde la posicion 0 hasta i, con el apellido.
			user_name=${nombres:0:$i}${apellido}

			# Paso todo a minusculas.
			user_nuevo=${user_name,,}
	
			# Recorro el array de users para ver si el usuario que cree ya existe.
			for (( index=0; index<${#array_users[@]}; index++ ))
			do
				# Si el usuario esta repetido.
				if [[ $user_nuevo == ${array_users[$index]} ]]
				then
					# Reseteo el index para recorrer el array desde el comienzo.
					index=0

					# Incremento mi indice para agregar otro caracter del nombre al usuario.
					i=$((i+1))
	
					largo_apellido=${#apellido}
					largo_total=$((largo_apellido+i))

					# Si ya me quede sin caracteres en nombres por tener usuario repetido o el usuario supera el limite de caracteres.
					if [[ $i -gt ${#nombres} || $largo_total -gt "$max_caracteres" ]]
					then
						# Corto el ciclo y marco que se produjo un error.
						index=${#array_users[@]}
						hubo_error=true
					else
						# Concateno el caracter de nombres desde la posicion 0 hasta i, con el apellido.
						user_name=${nombres:0:$i}${apellido}

						# Paso todo a minusculas.
						user_nuevo=${user_name,,}
					fi
				fi
			done

			# Escribo en el log. Si no hubo error, escribo tambien en el archivo de usuarios actuales.
			if [[ $hubo_error == false ]]
			then
				echo "$dni;$user_nuevo;$apellido;$nombres_original" >> $1
				echo "$fecha::OK::$dni::$user_nuevo" >> $file
				array_dnis[${#array_dnis[@]}]=$dni
			else
				echo "$fecha::ERROR::$dni::Me quede sin caracteres para escribir un usuario repetido." >> $file
			fi
	
			# Reinicio el flag de errores y el indice de los nombres.
			hubo_error=false
			i=1
		fi
	fi
done < "$2"



