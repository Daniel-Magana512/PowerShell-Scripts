<#
    .Synopsis
    Cantidad de archivos en el disco D
    .Description
    Se muestra en un GridView la cantidad de archivos que hay de cada tipo según su extensión,
    en el disco D, en todos los directorios,
    ordenados de forma decreciente por cantidad.
#>

ls "D:\" -File -Recurse | Group-Object Extension | Sort-Object Count -Descending | Select-Object Name, Count | Out-GridView