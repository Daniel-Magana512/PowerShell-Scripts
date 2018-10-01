#Trabajo Práctico Nro. 1
#Ejercicio 4
#
#Grupo:
#Escobar Fabián - 39210915
#Galvez Ezequiel - 37659307
#López Pablo - 39154213
#Tarrabe Maximiliano - 36846529
#Wawreniuk César - 28474164

####### PARAMETROS
# valido los parametros, en general
param(   [parameter( Mandatory=$true, Position=0)][ValidateScript({test-path $_  })][string]$path,
         [parameter(  Mandatory=$true, Position=1,HelpMessage="DEBE INGRESAR EL SEPARADOR")] [string]$separador,
         [parameter(  Mandatory=$false, Position=2)]
         [ValidatePattern("[T|t]")]  [char]$operacion=$NULL,
         [parameter(  Mandatory=$false, Position=3,HelpMessage="DEBE INGRESAR UN NUMERO")] [double]$escalar=$NULL,
         [parameter(ValueFromRemainingArguments=$true)] $resto=$NULL

          ) 

# valido los parametros, especificamente 
# si resto distinto a null, hay parametros de mas y debe informar y salir
$inicio_resto=$FALSE
if($resto -eq $NULL)
{
$inicio_resto=$TRUE
}

# valido operacion, puede ser T,t o un numero
$inicio_operacion=$FALSE
if(($operacion -like "T") -or($operacion -like "t"))
{
$inicio_operacion=$TRUE
}

####### FUNCIONES

# Esta funcion carga la matriz  
# a partir del archivo
Function cargar-matriz($i, $j)
{

# recorro archivo linea x linea
# para cargar elementos en matriz
	foreach($valor in get-content $i)
	{
	$vector=@()
	$vector+=($valor).split($j) 
	$script:matriz+=,$vector
	
	}	

}

# Esta funcion calcula 
# cantidad de filas y columnas de una matriz 
# devuelve true si todas las filas tienen la misma cantidad de elementos
Function carga-dimensiones($matriz, $fil, $col)
{
$pri_col=0
$j=0
$i=0
	for($i=0;$i -lt $matriz.length; $i++)
	{
		for($j=0;$j -lt $matriz[$i].length ; $j++){}
		# cargo la primera cantidad de columnas y si varia
		# la cantidad de columnas hay elementos faltantes
		if($i -eq 0)
		{
		$pri_col=$j 
		}
		else{
			# si entra aca hay filas de distintos largos
			if( $pri_col -ne $j)
			{
			write-host "FALTAN ELEMENTOS EN LA MATRIZ"
			return $FALSE
			}
		}
	}
$script:col=$pri_col
$script:fil=$i


if($pri_col -ne $i)
{
write-host "LA MATRIZ ES RECTANGULAR"
}

return $TRUE

}


# Esta funcion detrmina que todos  
# los valores de la matriz sean numericos 

Function es-numero($matriz )
{

$j=0
$i=0
	# recorro la matriz para verificar que todos 
	# los elementos sean valores numericos
	for($i=0;$i -le $matriz.length; $i++)
	{
	
		for($j=0;$j -le $matriz[$i].length ; $j++)
		{	

		$ii=$i+1
		$jj=$j+1	
		
		# esto captura la excepcion,si todos son numeros devuelve= '!'
		# sino devuelve= un cartel+ '!'
		Trap {"EL ELEMENTO DE LA FILA= $ii, COLUMNA= $jj NO ES UN NUMERO"; Continue}

			&{ 
			$num=[double]$matriz[$i][$j]+0 
			
			}

			
		}
	
	}
return "!"
}



# determina si es identidad, diagonal, nula o ninguna de las anteriores
Function determinar-tipo($matriz, $f, $c )
{

$diagonal=@()
$no_es=$FALSE 

	# recorro la matriz
	for($i=0;($i -lt $matriz.length) -and ($no_es -eq $FALSE); $i++)
	{
	
		for($j=0;($j -lt $matriz[$i].length) -and ($no_es -eq $FALSE); $j++)
		{	
			# calcula todos los elementos que no son de 
			# la diagonal principal y si algun valor es cero
			# no es identidad ni diagonal
			if(($matriz[$i][$j] -ne 0) -and ($i -ne $j))
			{
			$no_es=$TRUE
			}
			# guardo el elemento en el vecor diagonal 
			elseif($i -eq $j)
			{
			$diagonal+=$matriz[$i][$j]
			}
		}
	
	}

# una vez recorrido el vector puedo determinar su tipo
if(($f -eq 1) -and ($c -gt 1))
{
write-host "ES MATRIZ FILA"
}

if(($c -eq 1) -and ($f -gt 1))
{
write-host "ES MATRIZ COLUMNA"
}

if($no_es -eq $TRUE)
{
write-host "`n`nLA MATRIZ NO ES IDENTIDAD NI ES MATRIZ DIAGONAL"
}
elseif($no_es -eq $FALSE)
{
	# recorro el vector diagonal para determinar si es identidad
	# o matriz diagonal
	$es_identidad=$TRUE
	for($i=0;($i -lt $diagonal.length) -and ($es_identidad -eq $TRUE); $i++)
	{	
		# si algun valor es distinto a uno es diagonal
		if($diagonal[$i] -ne 1)
		{
		$es_identidad=$FALSE
		}
	}

	# recorro el vector diagonal para determinar si es matriz nula
	$es_nula=$TRUE
	for($i=0;($i -lt $diagonal.length) -and ($es_nula -eq $TRUE); $i++)
	{	
		# si algun valor es distinto a uno es diagonal
		if($diagonal[$i] -ne 0)
		{
		$es_nula=$FALSE
		}
	}
	
	# si es identidad $es_identidad=$TRUE
	if($es_identidad -eq $TRUE)
	{
	write-host "`n`nLA MATRIZ ES IDENTIDAD"
	}
	else{
	write-host "`n`nES MATRIZ DIAGONAL"
	}
	
	# si todos sus elementos son cero es matriz nula
	if($es_nula -eq $TRUE)
	{
	write-host "`nLA MATRIZ ES NULA"
	}

}


}

# le paso una matriz y obtengo su traspuesta, 
Function trasponer-matriz($matriz)
{

# la matriz que le envio no puede estar vacia
$res=New-Object "int32[][]" $matriz.length,$matriz[0].length

# creo matriz con dimensiones traspuestas
$Tres=New-Object "int32[][]" $matriz[0].length,$matriz.length



	# recorro matriz enviada por parametro y la copio 
	for($i=0;$i -lt $matriz.length ; $i++)
	{
	
		for($j=0;$j -lt $matriz[$i].length ; $j++)
		{	
		$res[$i][$j]=$matriz[$i][$j] 
		
		}
	
	}

	# traspongo la matriz
	for($i=0;$i -lt $tres.length ; $i++)
	{
	
		for($j=0;$j -lt $tres[$i].length ; $j++)
		{	
			# solo traspongo un triangulo de la matriz,
			# este es el triangulo superior
			if(($j -ge $i) -and ($j -le $res.length))
			{
			$tres[$i][$j]=$res[$j][$i]
			}
			# este es el triangulo inferior
			if(($j -le $i) -and ($i -le $res[0].length))
			{
			$tres[$i][$j]=$res[$j][$i]
			}
		}
	
	}
	
	
	

#muestro el resultado
mostrar-matriz $tres "TRASPUESTA"

}

# muestra la matriz que le envio por parametro
# mas el parametro cartel, que sirve para aclarar que muestra
Function mostrar-matriz($mat, $cartel)
{
write-host "`nLa matriz $cartel;"
for($i=0;$i -lt $mat.length; $i++)
	{
	
	write-host $mat[$i]
	}
}

# reliza el producto entre una matriz y un escalar
Function producto-escalar($mat, $num, $cartel)
{

# la matriz que le envio no puede estar vacia
$respuesta=New-Object "int32[][]" $mat.length,$mat[0].length

	# recorro matriz enviada por parametro y la copio 
	for($i=0;$i -lt $mat.length ; $i++)
	{
	
		for($j=0;$j -lt $mat[$i].length ; $j++)
		{	
		$respuesta[$i][$j]=$mat[$i][$j] 
		}
	
	}
	
	# realizo el producto con una copia de la matriz
	for($i=0;$i -lt $respuesta.length ; $i++)
	{
	
		for($j=0;$j -lt $respuesta[$i].length ; $j++)
		{	
		$respuesta[$i][$j]=[double]$respuesta[$i][$j] * [double]$num
		}
	
	}
#muestro el resultado
mostrar-matriz $respuesta $cartel
}

################## PRINCIPAL



$col=0
$fil=0
$matriz=@()
$val=""
$val1=""

# pregunto si hay parametros de mas
if($inicio_resto -eq $FALSE)
{
write-host "INGRESO PARAMETROS DE MAS, CONSULTE Get-Help"
}

else
{
# cuerpo principal, donde ejecuto las funciones
cargar-matriz $path $separador
$val=carga-dimensiones $matriz $fil $col
$val1=es-numero
$val2=$val1.length

    # le faltan elementos
    if($val -eq $FALSE)
    {
    write-host "LE FALTAN ELEMENTOS A LA MATRIZ"
    }
    # la matriz no esta conformada unicamente por numeros 
    elseif($val2 -gt 1)
    {
    write-host "$val1"
    }
    else
    {
    
        if(($fil -eq 1) -and ($col -eq 1))
        {
        write-host "ES UN ESCALAR, NO UNA MATRIZ"
        }
        else
        {
        
        mostrar-matriz $matriz "ORIGINAL"
        determinar-tipo $matriz $fil $col
        
            # realizo producto escalar
            if($escalar -ne $NULL)
            {
            producto-escalar $matriz $escalar "LA MATRIZ x $escalar es"
            }
            if($inicio_operacion -eq $TRUE)
            {
            trasponer-matriz $matriz
            }
        
        }
    }


}



<#
.SYNOPSIS
Realiza clasificacion y operaciones matriciales

.DESCRIPTION
Clasifica una matriz dependiendo su tipo, y puede trasponer la matriz y/o realizar el producto escalar, si se le envia un numero

.PARAMETER path
Directorio en el que se encuentra la matriz

.PARAMETER separador
Caracter que separa columnas en el archivo de la matriz

.PARAMETER operacion
Caracter que indica que se debe trasponer la matriz

.PARAMETER escalar
Numero por el que se realiza producto escalar por la matriz y/o su traspuesta

.PARAMETER resto
Este parametro debe ser null para que se ejecute el script, valida si se envian parametros de mas

.EXAMPLE
si ejecuta TP1-EJ6-28_8_2017 archivo separador
muestra matriz y la clasifica

.EXAMPLE
si ejecuta TP1-EJ6-28_8_2017 archivo separador T
muestra matriz, la clasifica y la traspone

.EXAMPLE
si ejecuta TP1-EJ6-28_8_2017 archivo separador T num
muestra matriz, la clasifica, la traspone y hace producto escalar entre num y la matriz original

.INPUTS
Tiene dos parametros obligatorios, un path, que indica donde esta la matriz y el caracter separador de columnas.
Ademas puede recibir un carater "T/t" que le indica que trasponga la matriz y un escalar por el cual se multiplica la matriz y/o la traspuesta. 

.OUTPUTS
Devuelve mensajes que indican el tipo de matriz, o si hubo un error 


#>