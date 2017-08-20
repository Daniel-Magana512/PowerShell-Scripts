<#
    .Synopsis
    Servicios del sistema
    .Description
    Servicios del sistema del sistema ordenados por nombre
#>

Get-Service | Sort-Object Name | Format-List Name, DisplayName, Status, CanStop, CanPauseAndContinue, CanShutdown, StartType
