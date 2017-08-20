<#
    .Synopsis
    Procesos del sistema
    .Description
    Se muestra el id, nombre y horario de arranque, y tiempo total en procesador de cada proceso del sistema
#>

Get-Process | Select-Object Id, ProcessName, Starttime, TotalProcessorTime