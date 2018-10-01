<#
.SYNOPSIS
Este script permite actualizar el stock de los productos vendidos o comprados por las distintas sucursales de la empresa durante el día

.DESCRIPTION
De forma opcional se pueden enviar como parámetros la ruta donde está almacenado el archivo "StockRegistro.csv"(debe tener el nombre tal cual está escrito previamente)
(contiene todos los productos y stock actualizados) y la ruta en la cual se depositarán los archivos de las sucursales "Sucursales_XXX.txt"(debe tener el nombre tal cual está escrito previamente,
donde las letras XXX reprensentan un numero entero a elegir)."Si se elige pasar parámetros se deben pasar ambos".En caso de no elegir pasar parametros se toma el directorio por defecto.Los archivos de las sucursales deben
ser creados en un directorio distinto al elegido y llevados al mismo,cuando se realice esto, en el archivo stock se actualizará la fecha, hora y calculará el stock modificándolo del
archivo "StockRegistro.csv"
"IMPORTANTE: EL SCRIPT PODRIA NO DAR EL RESULTADO CORRECTO O DAR ERROR SI LOS ARCHIVOS DE SUCULSAL O REGISTROSTOCK ESTAN MAL CONFECCIONADOS"
"IMPORTANTE: MANTENER EL ARCHIVO DE STOCK CERRADO AL MOMENTO DE EJECUTAR EL SCRIPT SINO NO PROCESARA EL CALCULO DEL MISMO".

.PARAMETER pathStock
Especifica la ruta donde se encuentra el archivo que contiene la base de datos "StockRegistro.csv".

.PARAMETER pathSuculsal
Especifica la ruta donde se encuentran los archivos de las sucursales "Sucursales_XXX.txt"(donde las letras XXX reprensentan un numero entero para diferenciar las sucursales).

.EXAMPLE
  .\Ejercicio5.ps1 "C:\Users\Pepe\Desktop" "C:\Users\Pepe\Downloads"

.EXAMPLE
  .\Ejercicio5.ps1

.NOTES
Nombre del script: Ejercicio4.ps1
#>

<#
#Trabajo Práctico Nro. 1
#Ejercicio 4
#
#Grupo:
#Escobar Fabián - 39210915
#Galvez Ezequiel - 37659307
#López Pablo - 39154213
#Tarrabe Maximiliano - 36846529
#Wawreniuk César - 28474164
#>


Param(  [Parameter(Position = 1, Mandatory=$false)][string]$pathStock,	
   [Parameter(Position = 2, Mandatory= $false)][string] $pathSuculsal
)

$parametros=$false
$existe_path = $false

#verifico si son vacio o si las direcciones pasadas por parametros existen
 
 
if(($pathStock -ne "") -and ($pathSuculsal -ne ""))
{
    $parametros=$true
   
    if((Test-Path $pathStock) -and (Test-Path $pathSuculsal))
    {
        $existe_path=$true
    }
}



if(($pathStock) -and ($pathSuculsal -eq ""))
{
    Write-host ERROR: se necesita enviar ambos parametros o ninguno... -ForegroundColor Red
}
else
{

    if(($parametros -eq $true) -and ($existe_path -eq $false))
    {
        Write-host ERROR: uno o ambos directorios ingresados por parametros no se encuentran en el equipo... -ForegroundColor Red
    }
    else
    {
        if(($parametros -eq $false))
        {  
             $Global:dirStock=$PWD.Path
             $Global:dirSucursal=$PWD.Path
                  
             $FileSystemWatcher = New-Object System.IO.FileSystemWatcher 
             $FileSystemWatcher.Path=$Global:dirSucursal
             $FileSystemWatcher.Filter="Sucursal_*.txt"
             $FileSystemWatcher.NotifyFilter=[IO.NotifyFilters]'FileName, LastWrite'
             $FileSystemWatcher.IncludeSubdirectories=$false

             Register-ObjectEvent -InputObject $FileSystemWatcher -EventName Created -SourceIdentifier FileCreated -Action{ 
              
             $name = $Event.SourceEventArgs.FullPath  
                 
         
             if(Test-Path "$Global:dirStock/RegistroStock.csv")#verifico que el archivo aun siga en el directorio especificado
             {     

                $archivoCsv = Import-Csv "$Global:dirStock\RegistroStock.csv" -delimiter ","    
                $copia = @()
                $stock= @()             
         
                foreach($stoc in $archivoCsv)
                {
                    $a=$stoc.CodigoProducto
                    $b=$stoc.Nombreproducto
                    $c=$stoc.FechaDeActualizacion
                    $d=$Stoc.StockTotal


                    $stock+="$a,$b,$c,$d"
                }
                                            
                get-content $name | ForEach-Object -Process {#actualizo el stock con los archivos de sucursales

                $cadena=$_.split(";") 
          
                $i=0;
                $partes_stock=$($stock[$i]).Split(",");
                                                         
                while($($partes_stock[0]) -notlike ($($cadena[0])))
                {
                    $i++;
                    $partes_stock=$($stock[$i]).Split(",")
                }
                       
                $fechaHoraActual = Get-Date -UFormat "%d/%m/%Y %H:%M"
                $Stock_actual=($($partes_stock[3]) -as [int])+($($cadena[2]) -as [int])
                $stock[$i]="$($partes_stock[0]),$($partes_stock[1]),$fechaHoraActual,$Stock_actual"

             
              }

                for($i=0;$i -lt $stock.Length;$i++)
                {
                    $ExportItem = New-Object PSObject
                
                    $partes_stock=$($stock[$i]).Split(",");

                    $ExportItem | Add-Member -MemberType NoteProperty -name "CodigoProducto" -value $($partes_stock[0])
                    $ExportItem | Add-Member -MemberType NoteProperty -name "Nombreproducto" -value $($partes_stock[1])
                    $ExportItem | Add-Member -MemberType NoteProperty -name "FechaDeActualizacion" -value $($partes_stock[2])
                    $ExportItem | Add-Member -MemberType NoteProperty -name "StockTotal" -value $($partes_stock[3])

                    $copia+=$ExportItem
                }

            
                $copia | Export-Csv "$Global:dirStock\RegistroStock.csv" -delimiter ","  -encoding UTF8 -NoTypeInformation

                $sucursal=$Event.SourceEventArgs.Name

                Write-Host "archivo RegistroStock.csv actualizado en $Global:dirStock con los datos de $sucursal" -ForegroundColor Green
            
             }

             else
             {
                 Write-host "ERROR: no existe el archivo de registro de stock en el directorio $Global:dirStock... agreguelo o termine la ejecucion del programa" -ForegroundColor Red
             }
     
            }
        }
        else
        {
             $Global:dirStock=$pathStock
             $Global:dirSucursal=$pathSuculsal
                  
             $FileSystemWatcher = New-Object System.IO.FileSystemWatcher 
             $FileSystemWatcher.Path=$Global:dirSucursal
             $FileSystemWatcher.Filter="Sucursal_*.txt"
             $FileSystemWatcher.NotifyFilter=[IO.NotifyFilters]'FileName, LastWrite'
             $FileSystemWatcher.IncludeSubdirectories=$false

             Register-ObjectEvent -InputObject $FileSystemWatcher -EventName Created -SourceIdentifier FileCreated -Action{ 
              
             $name = $Event.SourceEventArgs.FullPath  
                 
             if(Test-Path "$Global:dirStock\RegistroStock.csv")#verifico que el archivo aun siga en el directorio especificado
             {     

                $archivoCsv = Import-Csv "$Global:dirStock\RegistroStock.csv" -delimiter ","    
                $copia = @()
                $stock= @()             
         
                foreach($stoc in $archivoCsv)
                {
                    $a=$stoc.CodigoProducto
                    $b=$stoc.Nombreproducto
                    $c=$stoc.FechaDeActualizacion
                    $d=$Stoc.StockTotal


                    $stock+="$a,$b,$c,$d"
                }
                                            
                get-content $name | ForEach-Object -Process {#actualizo el stock con los archivos de sucursales

                $cadena=$_.split(";") 
          
                $i=0;
                $partes_stock=$($stock[$i]).Split(",");
                                                         
                while($($partes_stock[0]) -notlike ($($cadena[0])))
                {
                    $i++;
                    $partes_stock=$($stock[$i]).Split(",")
                }
                       
                $fechaHoraActual = Get-Date -UFormat "%d/%m/%Y %H:%M"
                $Stock_actual=($($partes_stock[3]) -as [int])+($($cadena[2]) -as [int])
                $stock[$i]="$($partes_stock[0]),$($partes_stock[1]),$fechaHoraActual,$Stock_actual"

             
              }

                for($i=0;$i -lt $stock.Length;$i++)
                {
                    $ExportItem = New-Object PSObject
                
                    $partes_stock=$($stock[$i]).Split(",");

                    $ExportItem | Add-Member -MemberType NoteProperty -name "CodigoProducto" -value $($partes_stock[0])
                    $ExportItem | Add-Member -MemberType NoteProperty -name "Nombreproducto" -value $($partes_stock[1])
                    $ExportItem | Add-Member -MemberType NoteProperty -name "FechaDeActualizacion" -value $($partes_stock[2])
                    $ExportItem | Add-Member -MemberType NoteProperty -name "StockTotal" -value $($partes_stock[3])

                    $copia+=$ExportItem
                }

            
                $copia | Export-Csv "$Global:dirStock\RegistroStock.csv" -delimiter ","  -encoding UTF8 -NoTypeInformation

                $sucursal=$Event.SourceEventArgs.Name

                Write-Host "archivo RegistroStock.csv actualizado en $Global:dirStock con los datos de $sucursal" -ForegroundColor Green
            
             }

             else
             {
                 Write-host "ERROR: no existe el archivo de registro de stock en el directorio $Global:dirStock... agreguelo o termine la ejecucion del programa" -ForegroundColor Red
             }
     
            }
                  
        }
    }
}
    <#
    para finalizar con el evento usar el siguiente comando:
    Unregister-Event FileCreated              #>