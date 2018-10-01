#!/bin/bash
function validar
{
	if ! [ -f "$1" ]; then
		echo "El archivo enviado no es regular..."
		exit
	fi
	file -i "$1" | grep text/plain >> /dev/null
	
	if [ $? != 0 ]
	then
		echo  "El archivo enviado no es de texto plano..."	
		exit
	fi
}
if [ $# != 1 ]; then
	echo "La cantidad de parametros enviados no es igual a 1... Se requiere de 1 parametro..."
	exit
fi
validar $1
declare -A x
for i in `cat $1`
do
	(( x[$i]++ ))
done
y=`for i in ${!x[*]}
do
	echo $i "-" ${x["$i"]}
done | sort -rn -k3 | head -1 | cut -d"-" -f1 | tr -d ' '` 
sed -i "s/\<$y\>//g" "$1" 2>/dev/null

# a) La linea "#!/bin/bash" especifica el path al interprete que va a procesar el codigo (en este caso bash), ya que en los sistemas Unix no se hace uso de las extensiones para el manejo de los archivos, por lo que es necesario agregar esta informacion adicional.

# b) Para otorgarle permisos de ejecucion al script se utiliza el comando chmod, seguido de 3 valores N que indican el nivel de permiso para Owner, Group y Other, en ese orden, y el nombre del script. Los valores de N pueden ser:
# N=0 : No posee ningun tipo de permiso.
# N=1 : Permisos de ejecucion.
# N=2 : Permisos de escritura.
# N=3 : Permisos de ejecucion y escritura.
# N=4 : Permisos de lectura.
# N=5 : Permisos de lectura y ejecucion.
# N=6 : Permisos de lectura y escritura.
# N=7 : Todos los permisos.
# Entonces, si quisiera ejecutarlo siendo yo el Owner, bastaria con escribir cualquier valor de N que me de permisos de ejecucion, como por ejemplo chmod 744 ./Ejercicio_1.sh, chmod 540 ./Ejercicio_1.sh, etc.
# Podria escribir chmod 777 ./Ejercicio_1.sh para que todos tengan permisos totales sobre el script.

# c) La variable $1 indica el parametro enviado en la posicion 1 (es decir el primer parametro). La variable $? me devuelve el valor de ejecucion del ultimo comando. La variable $# indica la cantidad de parametros enviados. Este tipo de variables se las conoce como variables internas, a las cuales el interprete de bash asigna valores automaticamente, con el fin de facilitar el desarrollo de scripts. Otras variables de este tipo son:
# La variable $0, que me indica el nombre del script.
# La variable $@ o $*, que lista todos los parametros enviados.
# La variable $$, que me otorga el PID del proceso actual.
# La variable $!, que me otorga el PID del ultimo proceso hijo ejecutado en segundo plano.
# La variable $USER, que me indica el nombre del usuario que esta ejecutando el script
# etc.

# d) El objetivo del script es, dado un archivo de texto con una lista de palabras, eliminar las que tengan el mayor numero de repeticiones. En resumen, lo logra mediante un array asociativo que cuenta las apariciones de las palabras, ordena de mayor a menor por cantidad de apariciones y toma la palabra que queda primero y con sed elimina todas las apariciones de esa palabra del archivo.

# e) Hecho.

# f)
# file: Basicamente sirve para determinar el tipo de archivo.
# grep: Se usa para buscar dentro de un archivo lineas que coincidan con un patron dado.
# cat: Sirve para concatenar y mostrar el contenido de un archivo.
# sort: Sirve para ordenar la entrada que se le pase (archivo o entrada estandar). Tambien puede fusionar dos archivos en forma ordenada, si estos ya estan ordenados.
# head: Devuelve las primeras n lineas de un archivo dado. Por defecto, devuelve las 10 primeras.
# tr: Tiene varias funciones.
# - Puede trasladar caracteres de un arreglo de caracteres a otro, es decir, reemplaza un caracter en el arreglo por otro que se especifique en el otro arreglo.
# - Tambien elimina repeticiones de un caracter dado.
# - Puede eliminar las apariciones de un determinado caracter.
# cut: Este comando se utiliza para extraer una porcion de texto de un archivo seleccionando columnas.
# sed: Es un editor de streams (stream editor). Se utiliza para realizar transformaciones de texto basicas sobre una entrada dada. Su uso mas comun es para el reemplazo de texto.

# g) Lo que se logra es rederigir el stream de error estandar hacia /dev/null para evitar que se impriman mensajes de error en la consola. Basicamente esta tomando algo que no necesita y lo pone en el "bit-bucket".
