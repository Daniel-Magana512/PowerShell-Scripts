<#
    .Synopsis
    Sumatoria
    .Description
    Suma de N números que se ingresan desde la línea de comandos
    .parameter value
    Cantidad N de números que van a ser sumados
    .Inputs
    N números que van a ser sumados
    .Outputs
    .Examples
    Sumar-Numeros -it 3
    Ingrese el 1° número a sumar: 3
    Ingrese el 2° número a sumar: 5
    Ingrese el 3° número a sumar: 7
    Suma: 15
#>
function Sumar-Numeros()
{
    [CmdletBinding()]
    param(
        [parameter(mandatory=$true)]
        [int]$it
    )

    $total = 0
    for ($i=0, $i -lt $it, $i++) {
        $numero = Read-Host "Ingrese el ($i+1)° número a sumar: "
        $total+=$numero
    }
    
    Write-Host "Suma: $total"
}