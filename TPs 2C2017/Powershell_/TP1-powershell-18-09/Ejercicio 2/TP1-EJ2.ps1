<#
.SYNOPSIS
Nombre del script: TP1-EJ2.ps1
Trabajo Práctico 1 - Ejercicio Nro 2

Grupo:
Escobar, Fabián		 39210915
Galvez, Ezequiel      37659307
López, Pablo		     39154213
Tarrabe, Maximiliano  36846529
Wawreniuk, César	28474164

Sistemas Operativos
Comisión=1333

.DESCRIPTION
El script inicia un Job el cual monitorea, mediante un evento ligado a la finalización de un timer con un determinado
intervalo de tiempo, una carpeta que contiene archivos .log que son generados por procesos batch.
En caso de encontrar un error en alguno de los archivos, informa al operador de turno mediante un mensaje de correo,
indicando las líneas de error y la hora en que se encontraron.

.PARAMETER path_logs
Ruta de acceso a la carpeta con los archivos .log a analizar.
  
.PARAMETER path_mail
Ruta de acceso al archivo .txt que contiene el mail del usuario al cual enviar el aviso.

.PARAMETER intervalo
Intervalo de tiempo que indica cada cuanto se quiere monitorear los archivos

.EXAMPLE
.\TP1-EJ2.ps1 C:\Users\Rigoberto\Desktop\batch_logs C:\Users\Thyrat\Desktop\powershell\admin_mail.txt 3000

.INPUTS
Archivo .txt con el mail del operador de turno al cual enviar el aviso
Archivos .log a revisar

#>

################################################# SCRIPT #################################################

# Se valida la existencia de parámetros
Param(
    [Parameter(Position=1, Mandatory=$true)][String] $path_logs,
    [Parameter(Position=2, Mandatory=$true)][String] $path_mail,
    [Parameter(Position=3, Mandatory=$true)][Int] $intervalo
)

# Me muevo sobre la carpeta que contiene los archivos .log
cd $path_logs

# Creo un nuevo DateTime con un valor de fecha muy bajo
$ultimo_chequeo=New-Object -Type DateTime

# Creo un nuevo Timer, y le pongo el intervalo ingresado como parámetro
$timer=New-Object -Type Timers.Timer
$timer.Interval=$intervalo
$timer.Enabled=$true

# Verifico la existencia del evento TimerEvent, si ya existe lo borro
$event_exists=Get-EventSubscriber | findstr -i TimerEvent
if($event_exists) 
{
    Unregister-Event TimerEvent
}

# Registro un nuevo evento, asociado al Timer, con el ID TimerEvent. Allí comienzo a monitorear los archivos en busca de errores y los informo.
Register-ObjectEvent -InputObject $timer -EventName Elapsed  -SourceIdentifier TimerEvent  -Action {

    # Flag para marcar que se encontraron errores en un archivo
    $hubo_error=$false

    # Creo un array de incidencias que contendrá los errores encontrados
    $incidencia_array=@()

    # Para cada archivo de extensión .log
    foreach($file in Get-ChildItem *.log)
    {
        # Si la hora del último chequeo es menor a la de modificación del archivo, lo chequeo
        if($ultimo_chequeo -lt $file.LastWriteTime)
        {
            # Para cada linea dentro del archivo
            foreach($linea in Get-Content $file)
            {
                # Si la linea indica que hubo un error, guardo la información necesaria en un objeto, y almaceno ese objeto en mi array de incidencias
                if($linea.Contains("[ERROR]"))
                {
                    $hora=Get-Date

                    $incidencia = new-object PSObject
                    $incidencia | add-member -type NoteProperty -Name Archivo -Value $file.Name
                    $incidencia | add-member -type NoteProperty -Name Hora -Value $hora
                    $incidencia | add-member -type NoteProperty -Name Linea -Value $linea

                    $incidencia_array+=$incidencia

                    # Indico que hubo, al menos, un error
                    $hubo_error=$true
                }
            }
         }

    }

    # Si se detectó al menos un error, envío un correo a la dirección de mail en $path_mail
    if($hubo_error -match $true)
    {
        # Guardo la fecha de incidencia
        $time=Get-Date
                
        # Parámetros del mensaje
        $from="powershell3895@gmail.com"
        $SMTP="smtp.gmail.com"
        $to=Get-Content $path_mail
        $subject="[ERROR NOTIFICATION]"
        $body="Se han encontrado errores en los siguientes archivos: `n`n" + ($incidencia_array | Out-String)

        # Genero mis credenciales
        $username="powershell3895@gmail.com"
        $password=ConvertTo-SecureString -String "powershell@2" -AsPlainText -Force
        $creds=New-Object System.Management.Automation.PSCredential($username,$password)

        # Envío el mensaje
        Send-MailMessage -To $to -From $from -Subject $subject -Body $body -SmtpServer $SMTP -Credential $creds -UseSsl -Port 587 -DeliveryNotificationOption Never
    }
    # Reinicio el flag de errores
    $hubo_error=$false

    # Actualizo la hora del último chequeo a la actual
    $ultimo_chequeo=Get-Date
}

# Inicio el Timer
$timer.start()
