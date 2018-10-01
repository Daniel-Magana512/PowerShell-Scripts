#!/bin/bash
#Ante la duda invocar como:
#							bash ./launcher.txt
#							bash ./launcher.txt -h
#							bash ./launcher.txt -f log.txt
echo "Demon PID: " $$

trap '	if [[ $# -ge 1 ]]; then
			date | tee -a "$1";
			free -m | awk '"'"'NR==2{printf "\nPorcentaje de memoria libre: "$3*100/$2"%%\n"}'"'"' | tee -a "$1";
			df --total | awk '"'"'$1 ~ /^total$/{print "Porcentaje de disco libre: " $5 "\n"}'"'"' | tee -a "$1";
		fi
		if [[ $# -lt 1 ]]; then
			free -m | awk '"'"'NR==2{printf "\nPorcentaje de memoria libre: "$3*100/$2"%%\n"}'"'"'
			df --total | awk '"'"'$1 ~ /^total$/{print "Porcentaje de disco libre: " $5 "\n"}'"'"'
		fi
' SIGUSR1

trap '	if [[ $# -ge 1 ]]; then
			date | tee -a "$1";
			ps aux c --sort -rss | head -n 11 | awk '"'"'BEGIN{printf "Proceso \t PID \t Memoria \t Estado \t Inicio \t Usuario"}; NR>1{print $11 "\t" $2 "\t" $6 "\t" $8 "\t" $9 "\t" $1}'"'"' | column -t | tee -a "$1" ;
		fi
		if [[ $# -lt 1 ]]; then
			ps aux c --sort -rss | head -n 11 | awk '"'"'BEGIN{printf "Proceso \t PID \t Memoria \t Estado \t Inicio \t Usuario"}; NR>1{print $11 "\t" $2 "\t" $6 "\t" $8 "\t" $9 "\t" $1}'"'"' | column -t 
		fi

' SIGUSR2

trap 'echo "Cerrando programa..."; exit' SIGTERM

trap '' SIGINT

while [[ true ]]; do
	sleep 1
done






