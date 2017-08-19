function Get-Multiplicacion()
{
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true)]
        [int]$value
    )

   Begin
   {
        $result = 1
   }
   Process
   {
        Write-Output "Resultado parcial: $result"
        
        if($value -lt 0)
        {
            $result = 0
        }
        elseif($value -le 1)
        {
            $result = 1
        }
        else
        {
            $result = $value * $result
        }                
   }
   End
   {
        Write-Output "Resultado final: $result"
   }
}