#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/wait.h>
#include <math.h>
#include <termios.h>

int mygetch(); /// Implementacion de getch() para emular la espera al presionado de una tecla.

int main(int argc, char *argv[])
{
    int generaciones; /// Nivel de descendencia de procesos.
    int multiplicador = 2; /// Cuantos procesos hijos genera cada padre.
    int i = 0, j = 0, k = 0;
    int cant_procesos;

    pid_t pid_hijo; /// PID del proceso hijo.
    pid_t el_papu_de_los_papus = getpid(); /// PID del proceso mas alto en la jerarquia.

    /// Ayuda
    if (argc == 2 && strcmp(argv[1], "-h") == 0) {
        printf("\nPARAMETROS (1):\n");
        printf("    - Nivel de descendencia de procesos.\n\n");
        printf("FUNCIONAMIENTO:\n");
        printf("    - El programa tomara el nivel de descendencia ingresado y generara un arbol de procesos con ese valor, informando el PID del proceso y a que nivel ");
        printf("de la jerarquia se encuentra cada uno. Adicionalmente, indicaran quien fue el proceso que los genero (su padre).\n");
        printf("    - El programa quedara pausado al terminar de dar el informe, y se debera presionar una tecla para finalizarlo.\n\n");
        printf("CONSIDERACIONES:\n");
        printf("    - El nivel de descendencia de procesos debe ser mayor a 0.\n");
        printf("EJEMPLO DE COMPILACION:\n");
        printf("    gcc -o programa main.c -lm\n\n");
        printf("EJEMPLO DE EJECUCION:\n");
        printf("    ./programa 3\n\n");
        exit(EXIT_SUCCESS);
    }

    /// Validacion de parametros.
    if (argc != 2 ) {
        printf("\nLa cantidad de parametros ingresada no es correcta\nSe requiere: nivel_de_descendencia\n");
        printf("Para recibir ayuda sobre el script ingrese -h como parametro\n\n");
        exit(EXIT_FAILURE);
    }

    /// Validacion de parametros.
    if (atoi(argv[1]) == 0) {
        printf("\nEl nivel de descendencia ingresado no es valido. Debe ser por lo menos 1.\n");
        printf("Para recibir ayuda sobre el script ingrese -h como parametro\n\n");
        exit(EXIT_FAILURE);
    }

    generaciones = atoi(argv[1]);
    cant_procesos = (int) (pow (2, generaciones) - 1);

    printf ("\n   --- ARBOL DE PROCESOS ---\n\n");

    printf("Soy el proceso con PID %d y pertenezco a la generacion %d. Soy el padre de todos.\n", getpid(), 1);

    /// Arbol de procesos.
    for (i = 1 ; i < generaciones ; i++) { /// Un ciclo para cada generacion de procesos.

        for (j = 0 ; j < multiplicador ; j++) { /// La cantidad de procesos hijos que va a generar cada proceso padre.

            pid_hijo = fork();

            if (pid_hijo == -1) { /// Controlo si hubo un error al generar proceso hijo.
                printf ("Error al generar proceso hijo en proceso padre con PID %d\n", getpid());
                exit(EXIT_FAILURE);
            }

            if (pid_hijo != 0 && getpid() != el_papu_de_los_papus) { /// Si es el padre de algun proceso, y no es el mas alto en la jerarquia.
                if (j == (multiplicador - 1)) { /// Si es la ultima iteracion del padre.
                    while ((pid_hijo = wait(NULL)) > 0) {
                        /// Espero a que terminen todos mis hijos.
                    }
                    return 0;
                }
            } else {
                if (getpid() != el_papu_de_los_papus) { /// No es el proceso padre de todos.

                    printf("Soy el proceso con PID %d y pertenezco a la generacion %d. Mi padre es %d\n", getpid(), i+1, getppid());
                    j = multiplicador;

                    if ((i + 1) == generaciones) { /// Si es un proceso de la ultima generacion (hoja del arbol de procesos), no genera procesos hijos, y me aseguro de que no termine.
                        while(1);
                    }
                }
            }
        }

        if (getpid() == el_papu_de_los_papus) {
            break;
        }
    }

    /// Aca dejo bloqueado al proceso padre de todos, esperando que se presione una tecla. Mientras tanto puedo abrir otra consola y hacer un ps o pstree para ver el arbol de procesos.
    mygetch();

    /// Mato los procesos hijos para que no queden zombies.
    for (k = (cant_procesos - 1) ; k > 0 ; k--) {
        //printf("killed %d\n", el_papu_de_los_papus + k);
        kill(el_papu_de_los_papus + k, SIGKILL);
    }
    //printf("\n");
    printf("\n    --- FIN DEL PROGRAMA ---\n\n");

    return 0;
}


int mygetch() {
    int ch;
    struct termios oldt, newt;

    tcgetattr ( STDIN_FILENO, &oldt );
    newt = oldt;
    newt.c_lflag &= ~( ICANON | ECHO );
    tcsetattr ( STDIN_FILENO, TCSANOW, &newt );
    ch = getchar();
    tcsetattr ( STDIN_FILENO, TCSANOW, &oldt );

    return ch;
}
