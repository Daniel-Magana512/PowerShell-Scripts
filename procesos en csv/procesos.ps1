<#
    .Synopsis
    Procesos del sistema
    .Description
    Se exportan los procesos del sistema a un archivo procesos.csv.
    Se importa el archivo procesos.csv y se muestra en pantalla
#>

Get-Process | Select-Object Id, ProcessName, Starttime, CPU | Export-Csv "D:\UNLaM\SISTEMAS OPERATIVOS\FABIAN\POWERSHELL\procesos en csv\procesos.csv" -Delimiter ','

Import-Csv "D:\UNLaM\SISTEMAS OPERATIVOS\FABIAN\POWERSHELL\procesos en csv\procesos.csv" -Delimiter ','