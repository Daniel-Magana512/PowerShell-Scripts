#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <netinet/in.h>	

struct sockaddr_in sa;

void set(const char *y,int z)
{
	bzero(&(sa.sin_zero),8);
 	sa.sin_family =	AF_INET;
 	sa.sin_port = htons(z);
	sa.sin_addr.s_addr = inet_addr(y);
};

int main(int argc, char *argv[]) //argv[1] IP argv[2] PUERTO  argv[3] NICKNAME
{
	int x;
	char buffer[256];
	fd_set read_fds;
	int len;
	int puerto;
	int result;
	int max_socket;
	int bye;

	if(argc < 3){
		printf("Deben pasarse 3 parametros exactamente. La IP o Hostname, el puerto, y el nickname separados por un espacio.\n");
		sleep(5);
		exit(1);
	}



	if((x=socket(AF_INET,SOCK_STREAM,0))==-1){
		printf("Fallo al crear socket.\n");
		return 1;
	}
	puerto = atoi(argv[2]);
	set(argv[1],puerto); 
	//set("127.0.0.1",5000); //no quiere funcionar excepto con ese puerto... puede ser que use puerto usados por algo mas?
  	if(connect(x,(struct sockaddr *) &sa,sizeof(sa))==-1){
  		printf("Fallo al conectarse a servidor.\n");
		return 1;
  	}	

	bzero(buffer,256);
	send(x,argv[3],strlen(argv[3]),0); //envio un mensaje apenas me conecto asi le envio al server mi nickname

	max_socket = x;
	if(max_socket < STDIN_FILENO){
		max_socket = STDIN_FILENO;
	}

	bye=0;
	// el cliente debe quedar en un while(true) pero que permita esperar por mensajes y escribir y enviarlos.
	while (bye == 0 || ((strcmp(buffer, "Gracias. Vuelva pronto...\n")) != 0)){
		FD_ZERO(&read_fds);
		FD_SET(STDIN_FILENO, &read_fds);
		FD_SET(x, &read_fds);

		result = select(max_socket + 1, &read_fds, NULL, NULL, NULL);
		if (result == -1 )
		{
			printf("Error en select.\n");
			break;
		}
		else
		{
			if (FD_ISSET(STDIN_FILENO, &read_fds))
			{
				bzero(buffer,256);
				fgets(buffer, sizeof(buffer), stdin);
        		if ((strcmp(buffer,"FIN")) != 0 )
        		{
        			bye=1;
        		}
				len = strlen(buffer) - 1;
        		if (buffer[len] == '\n'){
        	    	buffer[len] = '\0';
        		}
        		send(x,buffer,strlen(buffer),0);
			}
			if (FD_ISSET(x, &read_fds))
			{
				bzero(buffer,256);
				recv(x,buffer,256,0);
				fflush(stdin);
				fflush(stdout);
				printf("%s", buffer);
				if ((strcmp(buffer, "Gracias. Vuelva pronto...")) == 0){
					if (bye == 1){
						printf("\n");
						exit(0);
					}
				}
				if ((strcmp(buffer, "Solo queda usted. Se cerrara el servidor.\n")) == 0){
						printf("\n");
						exit(0);					
				}
			}
		}
	}

//fuera del while, el cliente envio FIN para irse
//printf("\n");
//exit(0);
}

