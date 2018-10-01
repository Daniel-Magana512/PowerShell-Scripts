<#
.SYNOPSIS
Nombre del script: TP1-EJ3.ps1
Trabajo Práctico 1 - Ejercicio Nro 3

Grupo:
Escobar, Fabián       39210915
Galvez, Ezequiel      37659307
López, Pablo		  39154213
Tarrabe, Maximiliano  36846529
Wawreniuk, César	28474164

Sistemas Operativos
Comisión= 1333

Espacio en las unidades de almacenamiento del equipo

.DESCRIPTION
El script tiene dos modos de funcionamiento: Exportar-CSV e Importar-CSV

Modo de funcionamiento Exportar-CSV:

Valida que exista como parámetro una ruta donde exportará en CSV datos sobre las unidades de almacenamiento.
Si la ruta no se especifica al ejecutar el comando, la solicita.
Esos datos son: letra de la unidad de almacenamiento, capacidad total y espacio ocupado.
El nombre del archivo es "Unidades de Almacenamiento.csv".

Modo de funcionamiento Importar-CVS:

Valida que existan como parámetros una ruta desde donde importará el CSV con los datos de las unidades de almacenamiento,
y el mínimo porcentaje libre de almacenamiento recomendado para una unidad.
Si los parámetros no se especifican al ejecutar el comando, los solicita.
El nombre del archivo es "Unidades de Almacenamiento.csv".
Importa el archivo exportado y muestra en pantalla un listado que contiene:
letra de la unidad de almacenamiento, capacidad total y porcentaje libre.
Si el porcentaje libre es menor al valor pasado por parámetro, muestra ese registro en rojo.

.PARAMETER rutaArchivo
Directorio donde se encontrará el archivo CSV con los datos de las unidades de almacenamiento.

.PARAMETER minimoPorcentajeLibre
Porcentaje mínimo libre en la unidad de almacenamiento. Las unidades con valores por debajo de ese umbral se muestran en rojo.

.EXAMPLE
PS H:\> H:\TP1-EJ3.ps1 Exportar-CSV
cmdlet TP1-EJ3-ps1 en la posición 1 de la canalización de comandos
Proporcione valores para los parámetros siguientes:
rutaArchivo: H:\

.EXAMPLE
PS H:\> H:\TP1-EJ3.ps1 Importar-CSV
cmdlet TP1-EJ3.ps1 en la posición 1 de la canalización de comandos
Proporcione valores para los parámetros siguientes:
rutaArchivo: H:\
minimoPorcentajeDisponible: 25

               UNIDADES DE ALMACENAMIENTO

               Unidad:  C:               Capacidad Total:  209610338304           Porcentaje Libre:  21,2107346878661
               Unidad:  D:               Capacidad Total:  290390536192           Porcentaje Libre:  88,0651773826799
               Unidad:  E:               Capacidad Total:  0                      Porcentaje Libre:  0
               Unidad:  G:               Capacidad Total:  0                      Porcentaje Libre:  0
               Unidad:  H:               Capacidad Total:  15602286592           Porcentaje Libre:  41,1703182230586

.NOTES
No deje abierto el archivo CSV antes de correr el script pues no podrá accederlo.
No ejecute el comando Importar-CSV sin antes haber ejecutado el comando Exportar-CSV, pues no tendrá archivo CSV que importar.

.INPUTS
Para la importación:
Archivo formato CSV (Comma Separated Values) con los datos de las unidades de almacenamiento del equipo

.OUTPUTS
Para la exportación:
Archivo formato CSV (Comma Separated Values) con los datos de las unidades de almacenamiento del equipo
#>


################################################# SCRIPT #######################################################################

function Exportar-CSV() {
    #la directiva CmdLetBinding transforma la función en una especie de CmdLet,
    #proporcionando los parámetros comunes como –Verbose –Debug. 
    [CmdLetBinding()]

    #validación de existencia de parámetros
    Param(
        [Parameter(Position = 1, Mandatory=$true)][string] $rutaArchivo
    )

    #nombre del archivo csv
    $archivo = "Unidades de Almacenamiento.csv"

    #obtengo las unidades de almacenamiento
    $unidades = Get-WMIObject Win32_LogicalDisk | Select-Object -Property Name, Size, FreeSpace

    #declaro array vacío
    $exportacion = @()

    #para cada unidad de almacenamiento
    ForEach ($unidad in $unidades) {  

        #creo un nuevo objeto de Powershell
        $item = New-Object PSObject

        #coloco los atributos que necesito
    
        $item | Add-Member -MemberType NoteProperty -name "Unidad" -value $($unidad.Name)
    
        if (!$unidad.Size) {
            $item | Add-Member -MemberType NoteProperty -name "CapacidadTotal" -value $(0)
        } else {
            $item | Add-Member -MemberType NoteProperty -name "CapacidadTotal" -value $($unidad.Size)
        }

        $item | Add-Member -MemberType NoteProperty -name "EspacioOcupado" -value $($unidad.Size - $unidad.FreeSpace)

        #agrego el objeto al array
        $exportacion += $item
    }

    #exporto el array armado a un archivo  csv
    $exportacion | Export-Csv "$rutaArchivo\$archivo" -Delimiter ',' -encoding UTF8 -NoTypeInformation
}

function Importar-CSV() {
    #la directiva CmdLetBinding transforma la función en una especie de CmdLet,
    #proporcionando los parámetros comunes como –Verbose –Debug. 
    [CmdLetBinding()]

    #validación de existencia de parámetros
    Param(
        [Parameter(Position = 1, Mandatory=$true)][string] $rutaArchivo,	
        [Parameter(Position = 2, Mandatory= $true)][float] $minimoPorcentajeDisponible
    )

    #nombre del archivo csv
    $archivo = "Unidades de Almacenamiento.csv"

    #importo el archivo csv exportado
    $importacion = Import-Csv "$rutaArchivo\$archivo" -Delimiter "," -encoding UTF8

    #declaro array vacío
    $unidadesImportadas = @()

    #para cada unidad de almacenamiento importada
    ForEach ($unit in $importacion) {  

        #creo un nuevo objeto de Powershell
        $item = New-Object PSObject

        #coloco los atributos que necesito
    
        $item | Add-Member -MemberType NoteProperty -name "Unidad" -value $($unit.Unidad)
    
        $item | Add-Member -MemberType NoteProperty -name "CapacidadTotal" -value $($unit.CapacidadTotal)

        if ($unit.CapacidadTotal -eq 0) {
            $item | Add-Member -MemberType NoteProperty -name "PorcentajeLibre" -value $(0)
        } else {
            $item | Add-Member -MemberType NoteProperty -name "PorcentajeLibre" -value $(100 - $unit.EspacioOcupado/$unit.CapacidadTotal*100)
        }
    
        #agrego el objeto al array
        $unidadesImportadas += $item
    }

    #muestro el título
    Write-Host
    Write-Host "               UNIDADES DE ALMACENAMIENTO"
    Write-Host

    #para cada unidad de almacenamiento del array
    Foreach ($registro in $unidadesImportadas) {
    
        #si el porcentaje libre de la unidad es menor al valor crítico, selecciono color rojo
        if($registro.PorcentajeLibre -lt $minimoPorcentajeDisponible) {
            #aviso crítico
            $color = "Red"   
        } else {
            #todo OK
            $color = "DarkBlue"
        }

        #muestro datos de la unidad
        Write-Host "               Unidad: " $registro.Unidad -BackgroundColor $color -NoNewline
        Write-Host "               Capacidad Total: " $registro.CapacidadTotal -BackgroundColor $color -NoNewline
        if($registro.CapacidadTotal -eq 0) {
            $espaciado = "                     "
        } else {
            $espaciado = "          "
        }
        Write-Host $espaciado "Porcentaje Libre: " $registro.PorcentajeLibre -BackgroundColor $color

        #los datos se muestran de esta forma en pantalla porque el comando Write-Output,
        #que muestra los datos encolumnados automáticamente, no permite colorear la línea de comandos.
    }
}

############################################### FIN SCRIPT #####################################################################