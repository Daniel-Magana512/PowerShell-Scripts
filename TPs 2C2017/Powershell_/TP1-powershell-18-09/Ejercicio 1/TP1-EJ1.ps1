<#
.SYNOPSIS
Nombre del script: TP1-EJ1.ps1
Trabajo Practico 1 - Ejercicio 1
Grupo:
Escobar Fabián		39210915
Galvez Ezequiel     37659307
López Pablo		    39154213
Tarrabe Maximiliano 36846529
Wawreniuk César	28474164


Valida la existencia de una ruta y lista los archivos que contiene con su tamaño en bytes


.DESCRIPTION
....

.PARAMETER pathsalida
  Directorio a examinar

.EXAMPLE
.\TP1-EJ1.ps1 C:\Users\Usuario\Desktop	

.NOTES

.INPUTS

.OUTPUTS
#>


#############SCRIPT#########################################
Param($pathsalida)
$existe = Test-Path $pathsalida
if ($existe -eq $true)
{
$lista = Get-ChildItem -File
foreach ($item in $lista)
{
Write-Host “$($item.Name) $($item.Length)”
}
}
else
{
Write-Error "El path no existe"
}

############################################################

#RESPUESTAS
#a) Objetivo: Listar los archivos de un directorio (Nombre y tamaño en bytes) si es que existe."Aunque el path enviado no lo usa sino que usa el directorio actual", es decir,desde donde se ejecuta el script.Para solucionar esto abra que usar el cmd set-location con el path. Adicionalmente en caso de no existir el directorio se informa mediante un error dicha situación.
#b) Dado a la posibilidad de que el parámetro no fue definido como mandatario, y el mismo es esencial en la lógica del script: o lo hacemos mandatorio o lo definimos como param([ValidateNotNullOrEmpty()][string]$pathsalida).
    #EN CASO DE QUERER DEFINIRLO COMO MANDATORIO por ejemplo podríamos param([Parameter(Mandatory=$True,Position=1)] [ValidateNotNullOrEmpty()][string]$pathsalida).
#c) cmdlet Get-ChildItem (Alias dir, ls) con la dif de no mostrar los mensajes propios del script que validan, y para que quede con la misma salida se podría canalizar Get-ChildItem -file | select-object Name, Length

