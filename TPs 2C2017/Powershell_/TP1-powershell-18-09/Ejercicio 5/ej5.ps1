<#
.SYNOPSIS
"Gotta type fast" es un juego que mide los tiempos al tipear palabras.

.DESCRIPTION
Se debe indicar cuantas palabras se desean, y opcionalmente se pueden escoger listas de palabras alternativas. Además se puede indicar un archivo en donde guardar las mejores puntuaciones.

.PARAMETER CantPalabrasDeseadas
Debe ser un número entero entre 2 y 10.

.PARAMETER RutaAlArchivoDePalabras
Debe ser una ruta absoluta o relativa a un archivo "*.txt" existente que contenga una palabra por línea. En caso de no existir el archivo usará el archivo "palabras.txt" que se encuentra por defecto en la misma carpeta que el script.

.PARAMETER RutaAlArchivoMejoresTiempos
Debe ser una ruta absoluta o relativa a un archivo "*.txt" que puede o no existir previamente. Si existe lee los mejores tiempos existentes, y si no existe rea al archivo.

.EXAMPLE
 ".\ej5.ps1 3

.EXAMPLE
 .\ej5.ps1 3 '.\Carpeta con palabras\ingles.txt' 

.EXAMPLE
 .\ej5.ps1 3 '.\Carpeta con palabras\ingles.txt' .\hihi.txt

#>



<#
Trabajo Práctico Nro. 1
Ejercicio 5

Grupo:
Escobar Fabián - 39210915
Galvez Ezequiel - 37659307
López Pablo - 39154213
Tarrabe Maximiliano - 36846529
Wawreniuk César - 28474164
#>



PARAM(
[Parameter(Mandatory=$TRUE)][int]$CantPalabrasDeseadas,
[Parameter(Mandatory=$FALSE)]$RutaAlArchivoDePalabras,
[Parameter(Mandatory=$FALSE)]$RutaAlArchivoMejoresTiempos
)

cd "$PSScriptRoot"

if($PSBoundParameters.Count -eq 0){
    Write-Host "Debe al menos ingresar el número de palabras deseadas"
    Pause(5)
    Exit
}

$vecpalabras=@()
if($PSBoundParameters.Count -eq 1){
    $vecpalabras=@(Get-Content ".\palabras.txt")
}

if(($CantPalabrasDeseadas -lt 2) -or ($CantPalabrasDeseadas -gt 10)){
    Write-Host "Debe seleecionar entre 2 y 10 palabras para jugar"
    Pause(5)
    Exit
}


if($PSBoundParameters.Count -ge 2){
    if((Test-Path $RutaAlArchivoDePalabras -PathType Leaf) -and ([IO.Path]::GetExtension($RutaAlArchivoDePalabras) -like "*.txt")){
    $vecpalabras=@(Get-Content $RutaAlArchivoDePalabras)
    if(($vecpalabras.Length) -lt $CantPalabrasDeseadas){
        Write-Host "No hay suficientes palabras."
        Write-Host "Seleccione un maximo de" $vecpalabras.Length "palabras"
        Pause(10)
        Exit
        }
    }
    else{
        Write-Host "Archivo erroneo o inexistente. Se ha usará el archivo por default."
        $vecpalabras=@(Get-Content ".\palabras.txt")
    }
}



$PalabrasRandom=@(Get-Random -InputObject $vecpalabras -Count $CantPalabrasDeseadas)


$TiempoTotal=0
$CantTeclas=0
$CantTeclasCorrectas=0
$VecTiempos=@{}
$PalabrasRandom | ForEach-Object{
    Write-Host $_
    $sw = [system.diagnostics.stopwatch]::startNew()
    $typed=Read-Host
    $CantTeclas+=$typed.Length
    while($typed -ne $_){
        $typed=Read-Host
        $CantTeclas+=$typed.Length
    }
    $sw.stop()
    $VecTiempos.add($_,$sw.Elapsed.TotalSeconds)
    $TiempoTotal+=$sw.Elapsed
    $CantTeclasCorrectas+=$_.ToString().Length
}


Write-Host "Fin del juego`n`nESTADISTICAS`n(Los tiempos se muestran en segundos)"
$VecTiempos | Format-Table -Property @{Name = "Palabra"; Expression = {$_.Name}},@{Name = "Tiempo (en segundos)"; Expression = {$_.Value}}


Write-Host "`nTIEMPO TOTAL: "
$($TiempoTotal.TotalSeconds)

Write-Host "`nTiempo promedio por palabra:"
$TiempoPromedio=$TiempoTotal.TotalSeconds/$CantPalabrasDeseadas
$TiempoPromedio

Write-Host "`nTeclas por segundo (incluye intentos fallidos):"
$CantTeclas/$TiempoTotal.TotalSeconds
Write-Host "`nTeclas por segundo correctas:"
$CantTeclasCorrectas/$TiempoTotal.TotalSeconds



if($PSBoundParameters.Count -ge 3){

    if( -not ([IO.Path]::GetExtension($RutaAlArchivoMejoresTiempos) -like "*.txt")){
        Write-Host "Para guardar puntajes debió seleccionar un archivo .txt"
        Pause(5)
        Exit
    }
    else{
        if( -not (Test-Path $RutaAlArchivoMejoresTiempos -PathType Leaf)){
            Write-Host "Nuevo puntaje alto. Ingrese su nombre:"
            $user=Read-Host
            while($user -like "*☺*"){
                Write-Host "Los nombres no pueden incluir el caracter ☺.`nIngrese otro nombre:"
                $user=Read-Host
            }
            $hiscore="$($user)☺$($TiempoTotal.TotalSeconds)"
            $hiscore > "$RutaAlArchivoMejoresTiempos"
        }
        else{
            $MejoresTimes
            $MejoresTiempos=@{}
            $VecHiScores=@()
            $VecHiScores=@(Get-Content $RutaAlArchivoMejoresTiempos)
            $VecHiScores | ForEach-Object{
                $separado=@()
                $separado=$_.ToString().Split("☺")
                $MejoresTiempos.Add($separado[0],[double]$separado[1])
            }
            
                  
    
    
            if((($MejoresTiempos.Count -ge 5) -and ($($TiempoTotal.TotalSeconds) -lt (($MejoresTiempos.Values | Measure-Object -Maximum).Maximum) )) -or ($MejoresTiempos.Count -lt 5)){
                Write-Host "`nNuevo puntaje alto. Ingrese su nombre:"
                $user=Read-Host
                $flagpasa=0
                while($flagpasa -eq 0){
                    $flagpasa=1
                    if($MejoresTiempos.ContainsKey($user)){
                        $flagpasa=0
                        Write-Host "Nombre ya existente."
                    }
                    if($user -like "*☺*"){
                        $flagpasa=0
                        Write-Host "Los nombres no pueden incluir el caracter ☺."
                    }
                    if($flagpasa -eq 0){
                        Write-Host "Ingrese otro nombre:"
                        $user=Read-Host                
                    }
                }
    
                
                $MejoresTiempos.Add($($user),[double]$($TiempoTotal.TotalSeconds))
            }
            
            
            $MejoresTimes = ($MejoresTiempos.GetEnumerator() | sort -Property Value)
            Clear-Content $RutaAlArchivoMejoresTiempos
            Write-Host "MEJORES PUNTAJES HISTORICOS:"
            $MejoresTimes | Format-Table -Property @{Name = "Jugador"; Expression = {$_.Name}},@{Name = "Tiempo (en segundos)"; Expression = {$_.Value}} | Select-Object -First 7
    
            $limite=[math]::min( $MejoresTiempos.Count , 5 )
    
            for($i=0; $i -lt $limite; $i++){
                $appendice="$($MejoresTimes.Key[$i])☺$($MejoresTimes.Value[$i])"
                $appendice >> "$RutaAlArchivoMejoresTiempos"
            }
                    
        }
    }
}


