#include <stdio.h>
#include <stdlib.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <unistd.h>
#include <semaphore.h>
#include <fcntl.h>
#include <string.h>
#include <signal.h>


void terminar(int sig);


sem_t *x,*y,*w,*z,*h,*g;

int cantprocesos;

int shmid;
char* shmmensaje;
key_t key=37659307;

int cantshmid;
key_t cantclave=33;
int *puntero;



int main(int argc,char *argv[])
{


    if(argc!=2)
    {
    printf("cantidad de parametros invalidos\n");
    return 0;
    }

cantprocesos=atoi(argv[1]);

    if(cantprocesos<2)
    {
    printf("cantidad de procesos invalida\n");
    return 0;
    }

/////////////////////////////////////////////////////////////////////////////////////////////7
//creo la seccion de memoria
if((shmid = shmget(key,sizeof(char)*500,IPC_EXCL | IPC_CREAT | 0666))<0)
{
    printf("error al pedir la creacion del segmento al querer ver la cantidad de clientes\n");
    return -1;
}

//pido un puntero al principio de esa memoria
    if((shmmensaje=(shmat(shmid,NULL,0)))==(char *) -1)
    {
        printf("error al querer acceder al segmento de memoria compartida\n");
    }
////////////////////////////////////////////////////////////////////////////////////////////////////
// pido memoria compartida para la cantidad
// de procesos activos
    if((cantshmid = shmget(cantclave,sizeof(int)*2,IPC_EXCL | IPC_CREAT | 0666))<0)
    {
        printf("error al pedir la creacion del segmento para leer el mensaje\n");
        return -1;
    }

//pido un puntero al principio de esa memoria
    if((puntero=(shmat(cantshmid,NULL,0)))==NULL)
    {
        printf("error al querer acceder al segmento de memoria compartida\n");
    }

///////////////////////////////////////////////////////////////////////////////////////////////77
////////////////memorias compartidas creadas//////////////////

    puntero[0]=0;//cantidad de clientes actuales

    puntero[1]=cantprocesos;//clientes para iniciar el servidor

    x=sem_open("/x",O_CREAT | O_EXCL,0666,1);
    y=sem_open("/y",O_CREAT | O_EXCL,0666,0);
    w=sem_open("/w",O_CREAT | O_EXCL,0666,0);
    z=sem_open("/z",O_CREAT | O_EXCL,0666,0);
    h=sem_open("/h",O_CREAT | O_EXCL,0666,0);
    g=sem_open("/g",O_CREAT | O_EXCL,0666,0);

    printf("\ncantidad de clientes activos: %d",puntero[0]);
    printf("\nesperando a los demás clientes...\n");

    while(puntero[0] < cantprocesos)
    {
        sem_wait(y);
        if(puntero[0]<puntero[1])
        {
        printf("\ncantidad de clientes activos: %d",puntero[0]);
        printf("\nesperando a los demás clientes...\n");

        }
         sem_post(x);
    }
//////////////////

    printf("\n\n********SALA DE CHAT ABIERTA*********\n\n");

    int i;

    for(i=0;i<puntero[1];i++)
     sem_post(h);//aviso de sala abierta


/////////////////////cliente activos/////////////////////////////////

    sem_post(z);


    signal(SIGINT, terminar);///señal para finalizacion abrupta

    while(puntero[0]>1)
    {
        sem_wait(w);//hay mensaje en la memoria compartida
        if(puntero[0]>1)
        {
          for(i=0;i<puntero[1];i++)
            sem_post(g);//semaforos para que los clientes lean la memoria
          sleep(1);
          sem_post(z);//se puede depositar otro mensaje
        }
    }


    printf("\n****servidor cerrado por falta de clientes*****\n");


    //libero recursos
    sem_post(g);
    sem_close(x);
    sem_close(y);
    sem_unlink("/x");
    sem_unlink("/y");

    sem_close(w);
    sem_close(z);
    sem_unlink("/w");
    sem_unlink("/z");

    sem_close(g);
    sem_close(h);
    sem_unlink("/g");
    sem_unlink("/h");

    shmdt(shmmensaje);
    shmdt(puntero);
    shmctl(shmid,IPC_RMID,NULL);
    shmctl(cantshmid,IPC_RMID,NULL);

    return 0;
}


void terminar(int sig)
{
    int i,valor;

    valor=puntero[0];

    puntero[1]=-1;

	for(i=0;i<valor;i++)
    {
	    sem_post(z);
        sem_post(g);
    }
    sleep(1);


    while(puntero[0]!=0)
    {
        printf("%d",puntero[0]);
        sleep(1);
    }

    sem_close(x);
    sem_close(y);
    sem_unlink("/x");
    sem_unlink("/y");

    sem_close(w);
    sem_close(z);
    sem_unlink("/w");
    sem_unlink("/z");

    sem_close(g);
    sem_close(h);
    sem_unlink("/g");
    sem_unlink("/h");


    //borrado de segmentos
    shmdt(shmmensaje);
    shmdt(puntero);
    shmctl(shmid,IPC_RMID,NULL);
    shmctl(cantshmid,IPC_RMID,NULL);
    exit(0);
    printf("aca");
}
