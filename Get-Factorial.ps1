<#
    .Synopsis
    Factorial de un número
    .Description
    Cálculo recursivo del factorial de un número
    .Parameter Value
    Valor del que se calcula el factorial
    .Example
    Get-Factorial -value 5
    .Notes
    El factorial de un número es la multiplicación entre el número y todos los números naturales que lo anteceden.
    Por definición, el factorial de 0 es 1
#>
function Get-Factorial()
{
    param
    (
        [Parameter(Mandatory = $true)]
        [int]$value
    )

    if($value -lt 0)
    {
        $result = 0
    }
    elseif ($value -le 1)
    {
        $result = 1
    }
    else
    {
        $result = $value * (Get-Factorial ($value-1))
    }

    return $result
}

$value = Read-Host "Ingrese un número: "
$result = Get-Factorial $value
Write-Output "$value! = $result"