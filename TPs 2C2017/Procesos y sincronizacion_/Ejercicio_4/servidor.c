#include <netdb.h>		
#include <stdio.h>	
#include <string.h>		
#include <sys/socket.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdlib.h>
#include <ctype.h>
#include <iostream>
#include <map>
#include <string>


struct sockaddr_in sa;

void setServer(int socket_id,int port,int max_queue)
{
	bzero((char *) &sa, sizeof(struct sockaddr_in));
 	sa.sin_family 		= AF_INET;
 	sa.sin_port 		= htons(port);
	sa.sin_addr.s_addr= INADDR_ANY;
 	bind(socket_id,(struct sockaddr *)&sa,sizeof(struct sockaddr_in));    
 	listen(socket_id,max_queue);
};

int main(int argc, char *argv[])
{
	socklen_t cl=sizeof(struct sockaddr_in);
	struct sockaddr_in ca;
 	int server_socket;
 	int client_socket;
 	int max_si;
	char buffer[256];
	char bufferSend[256];


	std::map<int,std::string> ClientsMap; // ID_socket y Nickname

	

	if(argc < 2){ // CANT_MAX_CLIENTES y PUERTO
		printf("Deben pasarse 2 parametros exactamente. La cantidad de clientes maxima y el puerto por el cual se realizara la conexion separados por un espacio.\n");
		sleep(5);
		exit(1);
	}

	//AGREGAR VERIFICACION QUE LOS 2 PARAMETROS SEAN INT

	fd_set SocketsImportantes;
	fd_set SocketsImportantesCopia;
	int Max_Clientes = atoi(argv[1]);
	int socketCliente[Max_Clientes];

	
	if((server_socket=socket(AF_INET,SOCK_STREAM,0)) ==-1)	
		return 1;

	int puerto = atoi(argv[2]);
	setServer(server_socket,puerto,Max_Clientes);


	FD_ZERO (&SocketsImportantes); 
	FD_SET (server_socket, &SocketsImportantes);
	max_si = server_socket;

	for (int i=0; i<Max_Clientes; i++){ //se aceptan todos los clientes antes de iniciar la sala de chat
		printf("Esperando por %d clientes.\n", (Max_Clientes-i));
		client_socket=accept(server_socket,(struct sockaddr *) &ca, &cl);
		if(client_socket == -1){
			printf("Error al aceptar socket. Terminando servidor.\n");
			sleep(5);
			exit(1);
		}
		bzero(buffer,256);
		recv(client_socket,buffer,256,0); //justo despues de conectarse el cliente debe enviar un mensaje para conocer su nickname
		std::string str_nickname = buffer;
		printf("Se conecto: %s\n", buffer);
		ClientsMap.insert ( std::pair<int,std::string>(client_socket,str_nickname) ); 
	    FD_SET (client_socket, &SocketsImportantes);
	    if(client_socket > max_si){
        	max_si = client_socket;
	    }
	}

	//genero una copia de SocketsImportantes porque al hacer SELECT, estos se alteran... 
	SocketsImportantesCopia = SocketsImportantes;


	//inicia la sala de chat
	//Vigilo los sockets
	while (true){
		if(ClientsMap.size() < 2){
			printf("Hay menos de 2 personas para hablar.\n");
			
			//le aviso al ultimo cliente que el servidor cerrara
			std::map<int,std::string>::iterator it=ClientsMap.begin();
			std::string cierre = "";
			cierre.append("Solo queda usted. Se cerrara el servidor.\n");
			strcpy (bufferSend, cierre.c_str() );
			send(it->first,bufferSend,256,0);
			sleep(2);
			printf("Cerrando servidor...\n");
			//cierro el server
			close(server_socket);
			sleep(1);
			exit(0);
		}
		//cargo nuevamenet SocketsImportantes con su copia que pudo haber eliminado/agregado un cliente en la iteracion anterior
		//fd_set SocketsImportantes = SocketsImportantesCopia;
		SocketsImportantes = SocketsImportantesCopia;
		//genero una copia de SocketsImportantes porque al hacer SELECT, estos se alteran... (no deberia hace falta pero por las dudas...)
		//fd_set SocketsImportantesCopia = SocketsImportantes;
		SocketsImportantesCopia = SocketsImportantes;

		bzero(buffer,256);
		select (max_si+1, &SocketsImportantes, NULL, NULL, NULL);
	
		
	
		/* Se tratan los clientes */ 
		for (std::map<int,std::string>::iterator it=ClientsMap.begin(); it!=ClientsMap.end(); ++it)
		{ 
		    if (FD_ISSET (it->first, &SocketsImportantes)) 
		    {
		    	int chkMensaje = recv(it->first, buffer, 256, 0);		    	
				printf("El recv devolvio: %d\n", chkMensaje); 
				// por las dudas primero verifico que el cliente no haya terminado
		        if (chkMensaje == -1 || chkMensaje == 0) // intento detectar si el cliente termino bien (0) o mal (-1). No deberia importar... 
		        {
		        	// Hay un error en la lectura. Posiblemente el cliente ha cerrado la conexión. Hacer aquí el tratamiento. En el ejemplo, se cierra el socket y se elimina del array de ClientsMap
		        	printf("El cliente termino. Borrandolo...\n");
		        	FD_CLR (it->first, &SocketsImportantesCopia); //pagina web recomendada por catedra decia FD_CLEAR, el resto del internet decia FD_CLR...
		        	FD_CLR (it->first, &SocketsImportantes); //debo eliminarlo de esta lista ya que no debe esperar al prox SELECT para eliminarlo de la iteracion
		        	close(it->first);
		        	ClientsMap.erase(it);
		        	
		        }
		        //luego si se que el cliente no termino entonces me fijo si hay mensajes
		        if (chkMensaje > 0) // != -1
		        {
		        	if ( (strcmp(buffer, "FIN")) != 0 )
		        	{
		            	//TRATAMIENTO RECIVI MENSAJE BIEN // Envia mensaje a todos menos a quien envio el mensaje
		            	std::string s = "";
		            	s.append(it->second);
		            	s.append(": ");
		            	s.append(buffer);
		            	s.append("\n");
		            	strcpy (bufferSend, s.c_str() ); //deberia tener &buffer
	
			            	for (std::map<int,std::string>::iterator itSend=ClientsMap.begin(); itSend!=ClientsMap.end(); ++itSend){
			            		if(itSend->first != it->first){
			            			send(itSend->first,bufferSend,256,0);
			            		}
		            	}
		            }
		            if ( (strcmp(buffer, "FIN")) == 0)
		            {
		            	printf("El cliente quiere desconectarse.\n");
		            	//le mando un mensaje al cliente para dejarle saber que sabemos que quiere desconectarse
		            	std::string bye = "";
		            	bye.append("Gracias. Vuelva pronto...\n");
		            	strcpy (bufferSend, bye.c_str() );
		            	send(it->first,bufferSend,256,0);
		        		FD_CLR (it->first, &SocketsImportantesCopia); //pagina web recomendada por catedra decia FD_CLEAR, el resto del internet decia FD_CLR...
		        		FD_CLR (it->first, &SocketsImportantes); //debo eliminarlo de esta lista ya que no debe esperar al prox SELECT para eliminarlo de la iteracion
		        		close(it->first);
		        		ClientsMap.erase(it);
		            }
		        }
		    } 
		} 
		
		/* Se trata el socket servidor */ 
		if (FD_ISSET (server_socket, &SocketsImportantes)) 
		{ 
		    client_socket=accept(server_socket,(struct sockaddr *) &ca, &cl);
			if(client_socket == -1){
				printf("Error al aceptar socket. Terminando servidor.\n");
				sleep(5);
				exit(1);
			}
			bzero(buffer,256);
			recv(client_socket,buffer,256,0); //justo espues de connectarse el cliente debe enviar un mensaje para confirmar su nickname
			std::string str_nickname = buffer;
			ClientsMap.insert ( std::pair<int,std::string>(client_socket,str_nickname) ); 
		    FD_SET (client_socket, &SocketsImportantesCopia);
		    if(client_socket > max_si){
		    	max_si = client_socket;
		    }                
		}		
	}
 	return 0; 
};

