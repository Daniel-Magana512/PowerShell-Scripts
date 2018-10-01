#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <string.h>
#include <time.h>
#include <fcntl.h>

int main(int argc, char* argv[])
{

///valido cantidad de parametros///
if(argc != 3) {
  printf("Error en la ejecucion, la cantidad de parametros no es la correcta. \n");
  exit(1);
}

    pid_t process_id = 0;


    char nombrefifo[strlen(argv[1])+1];
    strcpy(nombrefifo,argv[1]);
    char nombrelog[strlen(argv[2])+1];
    strcpy(nombrelog,argv[2]);

    struct stat st;
    char buf[51];
    char buffer[81];
    int log;


if(strncmp(nombrefifo,nombrelog,(int)(strlen(nombrefifo)-1))==0)
{
    printf("el nombre de la fifo y el archivo log no deben ser iguales\n");
    exit(1);
}

///para saber si existe en otra instancia la fifo///
if (stat(nombrefifo, &st) == 0)
{
    printf("Ya existe fifo con el nombre indicado, por favor elija otro. \n");
    exit(1);
}

///para saber si se esta usando ya en otro instancia el archivo log///
if (stat(nombrelog, &st) == 0)
{
    printf("Ya existe archivo log con el nombre indicado, por favor elija otro. \n");
    exit(1);
}

///creo la fifo///
if (mkfifo(nombrefifo, 0777) < 0)
{
    printf("Error al crear fifo, intente nuevamente. \n ");
    exit(1);
}

///creo el archivo log///
if ( (log = open(nombrelog, O_RDWR | O_APPEND | O_CREAT, 0777) )< 0 )
{
   printf("Error al crear el archivo log, intente nuevamente. \n");
   exit(1);
}


///creacion del demonio
process_id = fork();

if (process_id < 0)
{
printf("Fallo en la creacion del demonio. \n");
exit(1);
}
if (process_id > 0)
{
printf("Proceso creado con PID %d \n", process_id);
exit(0);
}

///estoy en el demonio///

time_t tiempo;
struct tm tiem;

int r=open(nombrefifo,O_RDONLY);

while(1)
{

    //memset(buf,0,51);
    //memset(buffer,0,81);

    if(read(r,buf, sizeof(char)*50) > 0)
    {

        if(strncmp(buf,"FIN",3)==0)
        {
            close(r);
            close(log);
            unlink(nombrefifo);
            exit(0);
        }
        else
        {
           tiempo = time(NULL);
	       tiem = *localtime(&tiempo);
	       sprintf(buffer, "%d-%d-%d %d:%d:%d %s\n", tiem.tm_mday, tiem.tm_mon + 1, tiem.tm_year + 1900, tiem.tm_hour, tiem.tm_min, tiem.tm_sec, buf);
           write(log, buffer, (int)strlen(buffer));

        }
    }
    //sleep(2);

}

    return (0);
}
