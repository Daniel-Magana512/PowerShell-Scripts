<#
    .Synopsis
    Servicios corriendo en el sistema
    .Description
    Se muestra en un GridView todos los servicios que están corriendo en el sistema, ordenados por nombre desplegado.
    Para cada servicio se muestra el nombre del servicio y su nombre desplegado
#>

Get-Service | Where-Object { $_.Status -eq "Running" } | Sort Displayname | Select-Object ServiceName, DisplayName | Out-GridView
