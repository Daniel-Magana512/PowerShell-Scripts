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
    if(argc != 3)
    {
      printf("Error en la ejecucion, la cantidad de parametros no es la correcta. \n");
      exit(1);
    }


    char nombrefifo[strlen(argv[1])+1];
    strcpy(nombrefifo,argv[1]);
    char mensaje[strlen(argv[2])+1];
    strcpy(mensaje,argv[2]);

    struct stat st;




    if (stat(nombrefifo, &st) != 0)
    {
        printf("No existe fifo con el nombre indicado, por favor elija otro. \n");
        exit(1);
    }

    int w=open(nombrefifo,O_WRONLY);

    write(w,mensaje, sizeof(char)*50);

    close(w);


return 0;

}
