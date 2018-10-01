#!/bin/bash


if [[ $# -eq 0 ]]; then #no se ingresa parametros  #1
echo "ERROR:debe ingresar parametros,consulte la ayuda..."
exit
  else #mas de un parametro
if [[ $# -gt 1 ]]; then  #2
  echo "ERROR:la cantidad de parametros es invalida..."
exit
  else 

if [[ $# -eq 1 ]]; then # si se ingresa un parametro  #3
     if [[ $1 == "-h" || $1 == "-help" || $1 == "-?" ]]; then #4 #muestro ayuda
     echo 'Este script, al recibir como input un archivo de texto plano con los datos del torneo anual, genera dos archivos .csv .En uno de ellos se visualiza los equipos,puntos y goles ordenados de mayor a menor por puntaje y en el otro archivo los goleadores,goles y equipo ordenado por goles. Ademas las salidas seran renombradas con el nombre del archivo de input concatenado con _goleadores.csv _posiciones.csv segun el caso.

Ejemplos de ejecucion 
   ./Ejercicio5.sh Torneo_2018.txt
   ./Ejercicio5.sh "Torneo 2019"
   ./Ejercicio5.sh "Torneo 2 0 1 9"

Recordar que debe estar parado en la ruta donde se encuentra el archivo de input...
Además para no perder la consistencia de los datos, los nombres de los jugadores no se deben repetir entre distintos equipos'
exit
else

if [[ ! -f "$1" ]]; then #valido que en el directorio exista el archivo #5
   echo "ERROR:no existe el archivo ingresado por parametro en el directorio $PWD"
exit
else #valido que el archivo sea de texto plano

val_arch="$(file --mime-type -b "$1")"

if [ ! -s "$1" ] && [ $val_arch == "inode/x-empty" ];then #6
   echo "ERROR: el archivo ingresado es de texto pero esta vacio"
   exit
else
if [ $val_arch != "text/plain" ]; then #7
   echo "ERROR: el archivo ingresado no es de texto..."
exit
else # codigo para los goleadores	
######################################

titulo=`echo "$1" | awk 'BEGIN { FS = "." }{print $1"_goleadores.csv" }' `

echo "Jugador;Goles;Equipo"> "cabecera.txt" 


cat "$1" | awk 'BEGIN { FS = ":" };{

if($2 != 0)
{
  for(i=(3);i<=(2+$2);i++)  
  {
	jugador[$i]+=1;
  }
}

if($(2+$2+2) != 0)
{ 
  for(i=(2+$2+3);i<=(2+$2+2)+($(2+$2+2));i++)
	{
	jugador[$i]+=1;
	}
}

{
if($2 != 0)
{
 for(i=($2+1);i<=(2+$2);i++)  
  {
	equipo[$i]=$1;
  }
}

if($(2+$2+2) != 0)
{ 
   for(i=(2+$2+3);i<=((2+$2+2)+($(2+$2+2)));i++)
	{
	equipo[$i]=$(2+$2+1);
	}
}



}


	}
END{for (juga in jugador)

  for ( team in equipo)
  {
  if(team == juga)
{
 if(team != "1")## esto lo hago xq me crea un equipo con "1" en su nombre
 { 
  printf("%s;%s;%s\n",juga,jugador[juga],equipo[team])
  }
}
}
}' | sort -t";" -k2rn > "completo.txt"

cat "cabecera.txt" "completo.txt" > "$titulo"


###############################################

titulo2=`echo "$1" | awk 'BEGIN { FS = "." }{print $1"_posiciones.csv" }' `

echo "Equipo;Puntos;Goles a favor" > "cabecera.txt" 


cat "$1" | awk 'BEGIN { FS = ":" };{
##puntos##
if( $2 > $(2+$2+2) )
{
   puntos[$1]+=2
   puntos[$(2+$2+1)]+=0
}
else
{
  if( $2 < $(2+$2+2) )
  {
    puntos[$(2+$2+1)]+=2
    puntos[$1]+=0
  }
  else
  {
     puntos[$(2+$2+1)]+=1
     puntos[$1]+=1

  }
}

####goles a favor#####

    goles[$1]+=$2
    goles[$(2+$2+1)]+=$(2+$2+2)

}END{

for( equi in puntos )
{
   for( teams in goles )
   {

     if(teams == equi)
     {     
       printf("%s;%s;%s\n",teams,puntos[equi],goles[teams])
     }

   }
}

}' | sort -t";" -k2rn -k3rn > "completo.txt"

cat "cabecera.txt" "completo.txt" > "$titulo2"

rm -f "cabecera.txt"
rm -f "completo.txt"

#############################################
fi #7
fi #6
fi #5
fi #4
fi #3
fi #2
fi #1
