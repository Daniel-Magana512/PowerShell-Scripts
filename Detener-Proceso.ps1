function Detener-Proceso()
{
    param(
    [Parameter(Mandatory=$true,
               ValueFromPipeline=$true,
               ValueFromPipelineByPropertyName=$true)]
    [Int[]]$id
    )

    Process {
        Foreach($proc in $id) {
            try {
                kill -id $proc
                Write-Output "El proceso $proc fue detenido exitosamente"
            }
            catch {
                Write-Warning "El proceso $proc no existe en el sistema"
            }
        }
    }
}