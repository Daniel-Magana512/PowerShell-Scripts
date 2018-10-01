#include <stdio.h>
#include <stdlib.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <unistd.h>
#include <semaphore.h>
#include <fcntl.h>
#include <string.h>
#include <signal.h>
#include <pthread.h>
#include <sys/types.h>

int cantshmid;
key_t cantclave=33;
int *puntero;

int shmid;
char* shmmensaje;
key_t key=37659307;

char name[140]; //nombre de usuario

char nombre[500];
char mensaje[300];
char punto[4]=": ";

sem_t *x;
sem_t *y;
sem_t *w;
sem_t *z;
sem_t *h;
sem_t *g;

pthread_t leer,escribir;
int datoescribir,datoleer;  //para controlar los datos devueltos por los hilos

void * hilo_leer();
void * hilo_escribir();
void desconectar();   //funcion para liberar recursos

void terminar(int sig); //funcion para control + c


int main(int argc,char* argv[])
{

    if(argc!=2)
    {
    printf("cantidad de parametros invalidos\n");
    return 0;
    }
    /////////////////////memoria para controlar la cantidad de clientes///////////////////////////////77
    if((cantshmid = shmget(cantclave,sizeof(int)*2,IPC_CREAT | 0666))<0)
    {
        printf("\nerror al pedir la creacion del segmento");
        return -1;
    }

    if((puntero=(shmat(cantshmid,NULL,0)))==NULL)
    {
        printf("\nerror al querer acceder al segmento de memoria compartida");
    }

    if(!puntero[1])
    {
        printf("Error:el servidor aun no ha sido abierto...\n");
        return 0;
    }

    ////memoria para el deposito y recoleccion de mensajes//////////////////77
    if((shmid = shmget(key,sizeof(char)*500,IPC_CREAT | 0666))<0)
    {
        printf("error al pedir la creacion del segmento al querer ver la cantidad de clientes\n");
        return -1;
    }

    if((shmmensaje=(shmat(shmid,NULL,0)))==(char *) -1)
    {
        printf("error al querer acceder al segmento de memoria compartida\n");
    }

    //uso de semaforos //
     x=sem_open("/x",0);
     y=sem_open("/y",0);
     w=sem_open("/w",0);
     z=sem_open("/z",0);
     h=sem_open("/h",0);
     g=sem_open("/g",0);


    //guardo el nombre de usuario
    strcpy(name,argv[1]);


    //para parar la creacion de clientes que se quieran conectar luego de sobrepasado el limite de los mismos///
     if(puntero[0]>=puntero[1])
    {
        printf("error: ya se alcanzó el límite máximo de usuarios en el servidor...\n");
        exit(0);
    }


    //para que figure como cliente
    sem_wait(x);
        puntero[0]++;//aumento en uno la cantidad de clientes
    sem_post(y);

 /////////////////////////////////////////


    sem_wait(h);//para indicar que ya estan todos los usuarios y arrancar con el chat


    printf("********Conectado al servidor********\n\n");


    signal(SIGINT,terminar);

    pthread_create(&leer,NULL,&hilo_leer,NULL);
    pthread_create(&escribir,NULL,&hilo_escribir,NULL);

    //pthread_join(escribir,NULL);
    pthread_join(leer,NULL);

    //segun el valor modificado por los hilos cuando acabe muestro los diferentes mensajes//
    if(datoescribir==-1)
    {
        printf("\n***servidor cerrado***\n");
    }
    if(datoescribir==1)
    {
        printf("\n***servidor cerrado por falta de usuarios***\n");
    }
    if(datoescribir==0)
    {
        printf("\n***Vuelva pronto***\n");
    }

    desconectar();

    return 0;
}


void* hilo_escribir()
{
     while(1)
     {
       // printf("Ingrese mensaje:\n");
        strcpy(nombre,name);
        strcat(nombre,punto);
        fgets(mensaje,299,stdin);
        fflush(stdin);
        sem_wait(z);

	if(puntero[1]==-1)
        {
         datoescribir=-1;
         pthread_exit(0);
        }
        else
        {
          if(strncmp(mensaje,"QUIT",4)==0)
          {
                    char mensaje[70]=" se ha desconectado...";
                    strcat(name,mensaje);
                    strcpy(shmmensaje,name);
                    puntero[0]--;
                    datoescribir=0;
                    pthread_kill(leer,SIGKILL);
                    sem_post(w);//puede leer

                    pthread_exit(0);
                 }
                else
                {
                    strcat(nombre,mensaje);
                    strcpy(shmmensaje,nombre);
                    sem_post(w);
                }
            }
        }

}


void *hilo_leer()
{
     while(1)
     {
        sem_wait(g);//puede leer

        if(puntero[1]==-1)
        {
            datoescribir=-1;
            puntero[0]--;
            pthread_exit(0);
        }

        if(puntero[0]<2)
        {
           datoescribir=1;
           pthread_exit(0);
        }


        if(strncmp(shmmensaje,name,strlen(name)-1)!=0)
        {
            printf("%s",shmmensaje);
        }

        sleep(2);
    }

}

void desconectar()
{
            puntero[0]--;
            sem_close(x);
            sem_close(y);
            sem_close(w);
            sem_close(z);
            sem_close(h);
            sem_close(g);
            shmdt(puntero);
            shmdt(shmmensaje);
}


void terminar(int sig)
{
        puntero[0]--;
        pthread_kill(leer,SIGKILL);
        pthread_kill(escribir,SIGKILL);

        sem_close(x);
        sem_close(y);
        sem_close(w);
        sem_close(z);
        sem_close(h);
        sem_close(g);
        shmdt(puntero);
        shmdt(shmmensaje);
        exit(0);
}
