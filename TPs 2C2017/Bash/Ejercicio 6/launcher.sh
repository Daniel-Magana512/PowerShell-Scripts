#!/bin/bash

if [[ $# -ge 1 ]]; then
	if [[ $1 == "-h" || $1 == "-help" || $1 == "-?" ]]; then
		echo "Este script actua como launcher de un programa en segundo plano (demonio.sh)."
		echo "Dicho demonio solo espera a que el usuario le envie señales SIGUSR 1 y 2 para respectivamente mostrar porcentajes de RAM y disco libres, o mostrar los 10 procesos que estan consumiendo la mayor cantidad de RAM."
		echo "Se puede usar el parametro -f y una ruta a un archivo para que dicha informacion tambien se envie a dicho archivo"
		exit "La señal SIGTERM termina el proceso y la señal SIGINT es ignorada."
	fi

	if [[ $1 == "-f" ]]; then
		if [[ ! -f "$2" ]]; then
			exit "Archivo no encontrado.."
		fi
	fi
fi


echo "PID padre: $$"

if [[ $# -lt 1 ]]; then
	bash ./demon.sh &
fi

if [[ $# -ge 2 ]]; then
	bash ./demon.sh "$2" &
fi


echo "Comunicarse con demonio con: 'kill -10 $!'"


	echo "padre espera por algo"