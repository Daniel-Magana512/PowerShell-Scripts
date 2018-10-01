#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <sys/types.h>
#include <dirent.h>
#include <string.h>
#include <limits.h>
#include <time.h>

/// NOTA: Para resolver el ejercicio asumi que todos los archivos que se van a tratar son de texto, por lo que no se trabajan archivos que no tengan extension .txt.

/// Estructura de archivos, con el nombre del archivo y el puntero para acceder al contenido.
typedef struct {
    char nombre[100];
    FILE *stream;
} file_struct;

/// Estructura de parametros, es un "paquete" de parametros que va a usar cada thread en la rutina que van a ejecutar, lo necesito porque
/// pthread_create(...) exige como cuarto parametro un puntero a void (un unico parametro), entonces le mando esta estructura y la casteo en la funcion y recupero los parametros.
typedef struct {
    file_struct *file_vector;
    int cant_archivos;
    int n_thread;
}param_struct;

/// Funciones.
int es_archivo_de_texto(char *path);
int es_consonante(char c);
int es_vocal(char c);
file_struct** generar_matriz(int cant_archivos, int cant_threads);
void* tratar_archivos(void *parametros) ;
void imprimir_resultados(param_struct *vec_param, int cant_threads);

/// Variables globales sobre las cuales guardo la maxima y la minima cantidad de caracteres, y los nombres de los archivos con dicha cantidad.
int max_cant = 0;
int min_cant = INT_MAX;
char* file_max = NULL;
char* file_min = NULL;

/// Variables globales para el primer y ultimo archivo finalizado, y el path de salida.
int primer_esta_seteado = 0;
char* primer_file = NULL;
char* ultimo_file = NULL;
char* directorio_salida = NULL;

/// Mutex para sincronizar el uso de las variables globales mencionadas anteriormente.
pthread_mutex_t mutex_max = PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_t mutex_min = PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_t mutex_primer = PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_t mutex_ultimo = PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_t mutex_salida = PTHREAD_MUTEX_INITIALIZER;

int main(int argc, char *argv[]) {
    DIR *d; /// Puntero a directorio, el cual uso para acceder al que recibo como parametro.
    struct dirent *dir; /// Con esto leo cada archivo del directorio (o algo asi).

    int cant_threads; /// Nivel de paralelismo.
    int cant_archivos = 0; /// Cantidad de archivos de texto en el directorio.
    int cant_archivos_por_thread;
    int i = 0;
    int j = 0;
    char aux[200];

    file_struct **file_matrix = NULL; /// Una matriz de archivos, cada fila contiene los archivos que va a tratar un thread en particular.
    pthread_t *vector_threads; /// Vector de threads dinamico, ya que recibo N threads por parametro.
    param_struct parametros_actuales; /// Variable donde voy a construir un paquete de parametros.
    param_struct* vector_parametros; /// Vector en donde voy a guardar cada paquete de parametros correspondiente a cada thread.

    /// Ayuda
    if (argc == 2 && strcmp(argv[1], "-h") == 0) {
        printf("\nPARAMETROS (3):\n");
        printf("    - Un directorio de entrada\n    - Un directorio de salida\n    - Nivel de paralelismo\n\n");
        printf("FUNCIONAMIENTO:\n");
        printf("    - El programa leera los archivos de texto que se encuentren en el directorio de entrada, y los procesara repartiendolos equitativamente ");
        printf("entre los diferentes threads generados segun el nivel de paralelismo.\n");
        printf("    - El programa contara la cantidad de vocales, consonantes u otros caracteres que contenga cada archivo del directorio, y producira un archivo ");
        printf("con esta informacion sobre el directorio de salida ingresado.\n");
        printf("    - Tambien se imprimira por pantalla informacion como el primer archivo procesado o el archivo con mayor cantidad de caracteres, ademas de ");
        printf("que archivos le toco analizar a cada thread.\n\n");
        printf("CONSIDERACIONES:\n");
        printf("    - El nivel de paralelismo debe ser mayor a 0.\n");
        printf("    - El directorio de entrada no puede ser el mismo que el de salida.\n");
        printf("    - El programa solo analizara archivos de texto que posean la extension .txt de forma explicita.\n\n");
        printf("EJEMPLO DE COMPILACION:\n");
        printf("    gcc main.c -pthread -o programa\n\n");
        printf("EJEMPLO DE EJECUCION:\n");
        printf("    ./programa ./archivos_de_entrada ./archivos_de_salida 3\n\n");
        exit(EXIT_SUCCESS);
    }

    /// Validacion de parametros
    if (argc != 4 ) {
        printf("\nLa cantidad de parametros ingresada no es correcta\nSe requiere: directorio_de_entrada + directorio_de_salida + nivel_de_paralelismo\n");
        printf("Para recibir ayuda sobre el script ingrese -h como parametro\n\n");
        exit(EXIT_FAILURE);
    }

    if (atoi(argv[3]) == 0) {
        printf("\nEl nivel de paralelismo ingresado no es valido. Debe ser por lo menos 1.\n");
        printf("Para recibir ayuda sobre el script ingrese -h como parametro\n\n");
        exit(EXIT_FAILURE);
    }

    if ((d = opendir(argv[2])) == NULL) {
        printf("\n%s no es un directorio de salida valido\n", argv[2]);
        printf("Para recibir ayuda sobre el script ingrese -h como parametro\n\n");
        exit(EXIT_FAILURE);
    }

    if (strcmp(argv[1], argv[2]) == 0) {
        printf("\nEl path de entrada y el path de salida no pueden ser iguales\n");
        printf("Para recibir ayuda sobre el script ingrese -h como parametro\n\n");
        exit(EXIT_FAILURE);
    }

    closedir(d);
    cant_threads = atoi(argv[3]);
    directorio_salida = argv[2];

    printf("\n---- INICIO DE PROGRAMA ----\n");

    /// Reservo memoria para el vector de threads, una posicion por cada thread.
    vector_threads = (pthread_t*)malloc(sizeof(pthread_t) * cant_threads);
    if (!vector_threads) {
        printf("\nNo hay memoria para el vector de threads.\n\n");
        exit(EXIT_FAILURE);
    }

    /// Reservo memoria para el vector de parametros, una posicion por cada thread.
    vector_parametros = (param_struct*)malloc(sizeof(param_struct) * cant_threads);
    if (!vector_parametros) {
        printf("\nNo hay memoria para el vector de parametros.\n\n");
        exit(EXIT_FAILURE);
    }

    /// Aca cuento cuantos archivos de texto hay en el directorio.
    d = opendir(argv[1]);
    if (d) {
        while ((dir = readdir(d)) != NULL) {
            if (es_archivo_de_texto(dir->d_name)) {
                cant_archivos++;
            }
        }

        closedir(d);
    } else { /// Si no existe el directorio de entrada
        printf("\n%s no es un directorio de entrada valido\n", argv[1]);
        printf("\nPara recibir ayuda sobre el script ingrese -h como parametro\n\n");
        exit(EXIT_FAILURE);
    }

    if (cant_archivos == 0) {
        printf ("\nNo hay archivos de texto en %s\n", argv[1]);
        printf("Para recibir ayuda sobre el script ingrese -h como parametro\n\n");
        exit(EXIT_FAILURE);
    }

    /// Considero que es innecesario trabajar con mas threads que la cantidad de archivos que voy a tratar, por lo tanto uso solo la cantidad de threads necesarios.
    if (cant_threads > cant_archivos) {
        cant_threads = cant_archivos;
    }

    /// Es la cantidad de archivos que va a tratar cada thread (puede que algunos traten menos archivos).
    cant_archivos_por_thread = (int) (((cant_archivos) + (cant_threads - 1)) / cant_threads);

    /// Ya se cuantos archivos y cuantos threads tengo, entonces reservo memoria para la matriz de archivos.
    file_matrix = generar_matriz(cant_archivos, cant_threads);

    /// Aca asigno, de a uno por vez, un archivo a cada thread, guardandolos en la matriz de archivos (FILA ~ thread, COLUMNA ~ archivo).
    d = opendir(argv[1]);
    if (d) {
        while ((dir = readdir(d)) != NULL) {
            if (es_archivo_de_texto(dir->d_name)) {
                /// Genero el path del archivo para abrirlo.
                strcpy(aux, argv[1]);
                strcat(aux, "/");
                strcat(aux, dir->d_name);

                /// Guardo el nombre del archivo que va a tratar el thread j, en la posicion i.
                strcpy(file_matrix[j][i].nombre, dir->d_name);
                file_matrix[j][i].stream = fopen(aux, "r");

                if (!file_matrix[j][i].stream) {
                    printf("\nNo se pudo abrir el archivo %s\n\n", dir->d_name);
                    exit(EXIT_FAILURE);
                }

                j++;
            }
            /// Si ya le di un archivo a cada thread, vuelvo a empezar desde el primer thread (asi le voy a repartiendo un archivo a cada uno).
            if (j == cant_threads) {
                j = 0;
                i++;
            }
        }

        closedir(d);
    }

    /// Si me quedaron mas archivos en algunos threads que en otros, en los threads con menos archivos pongo una marca en el nombre del archivo indicando que no hay archivo para tratar.
    if (j != 0) {
        for (j = j ; j < cant_threads ; j++) {
            strcpy(file_matrix[j][i].nombre, "NULL");
        }
    }


    /// Aca cargo mi vector de parametros, que contiene el "paquete" de parametros para cada thread, asi paso ese paquete como un puntero a void a cada thread.
    for (i = 0 ; i < cant_threads ; i++) {
        parametros_actuales.cant_archivos = cant_archivos_por_thread; /// Es la cantidad de archivos que va a tratar cada thread.
        parametros_actuales.n_thread = (i+1); /// El numero de thread.
        parametros_actuales.file_vector = malloc(sizeof(file_struct) * parametros_actuales.cant_archivos); /// Vector de archivos a tratar, para el thread n_thread.

        for (j = 0 ; j < parametros_actuales.cant_archivos ; j++) {
            parametros_actuales.file_vector[j] = file_matrix[i][j];
        }

        vector_parametros[i] = parametros_actuales;
    }

    /// Ya tengo todo lo necesario en el vector de parametros, libero la memoria de la matriz.
    free(file_matrix);

    /// Creacion / ejecucion de threads.
    for (i = 0 ; i < cant_threads ; i++) {
        pthread_create(&vector_threads[i], NULL, tratar_archivos, &vector_parametros[i]);
    }

    for (i = 0 ; i < cant_threads ; i++) {
        pthread_join(vector_threads[i], NULL);
    }

    imprimir_resultados(vector_parametros, cant_threads);

    printf("\n---- FIN DE PROGRAMA ----\n\n");
    return 0;
}

file_struct** generar_matriz(int cant_archivos, int cant_threads) {
    int i,j;
    file_struct **matriz;
    matriz = (file_struct**)malloc(sizeof(file_struct*) * cant_threads); /// Reservo memoria para las filas.

    if(!matriz) {
        free(matriz);
        printf("No hay suficiente memoria para las filas de la matriz.");
        exit(EXIT_FAILURE);
    }

    for (i = 0 ; i < cant_threads ; i++) {
        matriz[i] = (file_struct*)malloc(sizeof(file_struct) * ((int) (((cant_archivos) + (cant_threads - 1)) / cant_threads))); /// Reservo memoria para las columnas.
        for (j = 0 ; j < ((int) (((cant_archivos) + (cant_threads - 1)) / cant_threads)) ; j++) {
            matriz[i][j].stream = (FILE*)malloc(sizeof(FILE*));
            if (!matriz[i][j].stream) {
                printf("No hay suficiente memoria para los punteros a FILE.");
                exit(EXIT_FAILURE);
            }
        }
        if (!matriz[i]) {
            free(matriz);
            printf("No hay suficiente memoria para las columnas de la matriz.");
            exit(EXIT_FAILURE);
        }
    }

    return matriz;
}

int es_archivo_de_texto(char *path) {
    int i = 0;
    while (path[i] != '.') {
        i++;
        if (path[i] == '\0') { /// Llega al final del path y no encuentra una extension.
            return 0;
        }
    }

    if (path[i+1] == 't' && path[i+2] == 'x' && path[i+3] == 't' && path[i+4] == '\0') { /// No tiene que tener nada mas despues de la extension .txt.
        return 1;
    }

    return 0;
}

int es_consonante(char c) {

    if ((c >= 'B' && c <= 'Z') && c != 'E' && c != 'I' && c != 'O' && c != 'U')
        return 1;
    if ((c >= 'b' && c <= 'z') && c != 'e' && c != 'i' && c != 'o' && c != 'u')
        return 1;

    return 0;
}

int es_vocal(char c) {
    return (c == 'a' || c == 'e' || c == 'i' || c == 'o' || c == 'u' || c == 'A' || c == 'E' || c == 'I' || c == 'O' || c == 'U') ? 1:0;
}

void* tratar_archivos(void *parametros) {

    /// Casteo mi puntero a void a mi "paquete" de parametros.
    param_struct *param = (param_struct*) parametros;

    /// Separo cada parametro.
    int cant_archivos = param->cant_archivos;
    int n_thread = param->n_thread;
    file_struct *files = param->file_vector;

    /// Variables para leer cada linea del archivo.
    int i;
    char *line = NULL;
    size_t length = 0;

    /// Para la cantidad de caracteres (por tipo, y totales).
    int cant_vocales = 0;
    int cant_consonantes = 0;
    int cant_otros = 0;
    int cant_total = 0;

    /// Para la hora de inicio y de fin (se va seteando a medida que recorro los archivos).
    time_t t = time(NULL);
    struct tm timeinfo;

    /// Para el archivo de salida.
    FILE *salida;
    char path_salida[200];
    char aux[100];

    for (i = 0 ; i < cant_archivos ; i++) {
        if (strcmp(files[i].nombre, "NULL") != 0) {
            /// Aca abro el archivo de salida que voy a generar.

            pthread_mutex_lock(&mutex_salida);
            strcpy(path_salida, directorio_salida);
            pthread_mutex_unlock(&mutex_salida);
            strcat(path_salida, "/");
            strcpy(aux, files[i].nombre);
            strcat(path_salida, aux);

            salida = fopen(path_salida, "w");
            if (!salida) {
                printf("\nError al generar archivo de salida %s, en thread #%d\n\n", files[i].nombre, n_thread);
                exit(EXIT_FAILURE);
            }

            /// Imprimo la hora de inicio.
            timeinfo = *localtime(&t);
            fprintf(salida, "Hora de inicio: %d-%d-%d %d:%d:%d\n",timeinfo.tm_mday, timeinfo.tm_mon + 1, timeinfo.tm_year + 1900, timeinfo.tm_hour, timeinfo.tm_min, timeinfo.tm_sec);

            /// Imprimo el numero de thread.
            fprintf(salida, "Numero de thread: %d\n", n_thread);

            /// Aca trato el archivo de entrada, para obtener los datos del archivo de salida.
            while (getline(&line, &length, files[i].stream) != - 1) {
                while (*line != '\n') { /// Mientras no sea fin de linea, cuento cada caracter por tipo.
                    if (es_consonante(*line)) {
                        cant_consonantes++;
                    } else {
                        if (es_vocal(*line)) {
                            cant_vocales++;
                        } else {
                            cant_otros++;
                        }
                    }
                    cant_total++;
                    line++;
                }
            }

            /// Imprimo los datos obtenidos
            fprintf(salida, "Cantidad de vocales: %d\nCantidad de consonantes: %d\nCantidad de otros caracteres: %d\n", cant_vocales, cant_consonantes, cant_otros);

            /// Imprimo la hora de finalizacion.
            timeinfo = *localtime(&t);
            fprintf(salida, "Hora de fin: %d-%d-%d %d:%d:%d\n",timeinfo.tm_mday, timeinfo.tm_mon + 1, timeinfo.tm_year + 1900, timeinfo.tm_hour, timeinfo.tm_min, timeinfo.tm_sec);

            /// Cierro el archivo de salida, y reinicio los contadores, para dar paso al siguiente archivo a tratar.
            fclose(salida);
            cant_vocales = 0;
            cant_consonantes = 0;
            cant_otros = 0;

            /// Actualizo maximos y minimos (mutex).
            pthread_mutex_lock(&mutex_max);
            pthread_mutex_lock(&mutex_min);
            if (cant_total > max_cant) {
                max_cant = cant_total;
                file_max = files[i].nombre;
            }
            if (cant_total < min_cant) {
                min_cant = cant_total;
                file_min = files[i].nombre;
            }
            pthread_mutex_unlock(&mutex_max);
            pthread_mutex_unlock(&mutex_min);
            cant_total = 0;

            /// Veo si es el primer archivo.
            pthread_mutex_lock(&mutex_primer);
            if (primer_esta_seteado == 0) {
                primer_file = files[i].nombre;
                primer_esta_seteado = 1;
            }
            pthread_mutex_unlock(&mutex_primer);

            /// Lo guardo como ultimo archivo.
            pthread_mutex_lock(&mutex_ultimo);
            ultimo_file = files[i].nombre;
            pthread_mutex_unlock(&mutex_ultimo);
        }
    }

    return NULL;
}

void imprimir_resultados(param_struct *vec_param, int cant_threads) {
    int i;
    int j;

    printf("\nARCHIVOS POR THREAD:\n\n");
    for (i = 0 ; i < cant_threads ; i++) {
        printf("THREAD #%d:\n", i+1);
        for (j = 0 ; j < vec_param[i].cant_archivos ; j++) {
            if (strcmp(vec_param[i].file_vector[j].nombre, "NULL") != 0) {
                printf("  %s\n", vec_param[i].file_vector[j].nombre);
            }

        }
        printf("\n");
    }

    printf("\nARCHIVO CON MENOR CANTIDAD DE CARACTERES: %s\n", file_min);
    printf("ARCHIVO CON MAYOR CANTIDAD DE CARACTERES: %s\n", file_max);
    printf("PRIMER ARCHIVO FINALIZADO: %s\n", primer_file);
    printf("ULTIMO ARCHIVO FINALIZADO: %s\n", ultimo_file);
}




















