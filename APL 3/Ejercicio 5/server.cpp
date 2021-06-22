#include <iostream>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <string.h>
#include <vector>
#include <string>
#include <sstream>
#include <signal.h>
#include <fstream>

using namespace std;

void help(string nombreEjecutable)
{
    cout << "Modo de uso: " << nombreEjecutable << endl;
    cout << "Modo de uso opcional con archivo a leer por parametro: " << nombreEjecutable << " archivoEntrada.txt" << endl;
    cout << "Ejecuta el servidor del juego Hangman (Ahorcado)." << endl;
    cout << "Este juego consiste en adivinar una palabra, ingresando letras y desbloquendo las mismas para completar la palabra" << endl;
    cout << "Ejecute la instancia de cliente y visualice las letras ingresadas desde el servidor" << endl;
}

string archivoEntrada = "archivo.txt";

int obtenerPalabraAleatoria(char lineasTxt[100][300])
{
    char linea[300];
    int cantLineas = 0;

    FILE *pTxt = fopen("archivo.txt", "rt");
    if (!fopen)
    {
        printf("No se pudo abrir el archivo txt");
        exit(-1);
    }

    while (fgets(linea, sizeof(linea), pTxt))
    {
        strcpy(lineasTxt[cantLineas], linea);
        cantLineas++;
    }

    srand(time(NULL));
    int random = rand() % cantLineas;

    fclose(pTxt);
    return random;
}

int esLetra(int car)
{
    return (car >= 'a' && car <= 'z') || (car >= 'A' && car <= 'Z');
}

int main(int argc, char **argv)
{

    if (argc > 1)
    {
        int cantIntentos = 6;

        int fd, fd2, longitud_cliente, puerto;
        puerto = atoi(argv[1]);

        struct sockaddr_in server;
        struct sockaddr_in cliente;

        server.sin_family = AF_INET;
        server.sin_port = htons(puerto);
        server.sin_addr.s_addr = INADDR_ANY;
        bzero(&(server.sin_zero), 8);

        if ((fd = socket(AF_INET, SOCK_STREAM, 0)) < 0)
        {
            perror("Error de apertura de socket");
            exit(-1);
        }

        if (bind(fd, (struct sockaddr *)&server, sizeof(struct sockaddr)) == -1)
        {
            printf("error en bind() \n");
            exit(-1);
        }

        if (listen(fd, 5) == -1)
        {
            printf("error en listen() \n");
            exit(-1);
        }

        int puedeEntrar = 1;

        while (puedeEntrar)
        {
            longitud_cliente = sizeof(struct sockaddr_in);

            socklen_t clientLen = longitud_cliente;

            if ((fd2 = accept(fd, (struct sockaddr *)&cliente, &clientLen)) == -1)
            {
                printf("error en accept() \n");
                exit(-1);
            }

            send(fd2, "Bienvenido al servidor! \n", 26, 0);

            char lineasTxt[100][300];

            char palabraAdivinar[50];
            char vectorGuiones[50];
            char palabraActual;
            char letrasJugadas[50];
            strncpy(letrasJugadas, "", sizeof(letrasJugadas));

            char *palAux;
            int random = obtenerPalabraAleatoria(lineasTxt);

            palAux = lineasTxt[random];

            strcpy(palabraAdivinar, palAux);

            int tamanio = strlen(palabraAdivinar) - 1;

            char *vectorGuionesAux = (char *)malloc(tamanio);

            char *aux = vectorGuionesAux;
            for (int i = 0; i < tamanio; i++)
            {
                *aux = '-';
                aux++;
            }
            *aux = '\0';

            strcpy(vectorGuiones, vectorGuionesAux);

            int numeroAEnviar = cantIntentos;
            int cantIntentosAEnviar = htonl(numeroAEnviar);
            write(fd2, &cantIntentosAEnviar, sizeof(cantIntentosAEnviar));

            send(fd2, vectorGuiones, 50, 0);
            send(fd2, letrasJugadas, 50, 0);
            send(fd2, palabraAdivinar, 50, 0);

            char caracter;
            int total = 0;
            int numbytes = 0;
            char bufferCaracteres[100];
            strncpy(bufferCaracteres, "", sizeof(bufferCaracteres));

            while (cantIntentos > 0)
            {
                caracter = '\0';

                while (numbytes != 1 || !esLetra(caracter))
                {
                    numbytes = recv(fd2, &caracter, 1, 0);
                }

                printf("Numero de bytes: %d\n", numbytes);

                printf("Caracter recibido: %c\n", caracter);

                if (strchr(palabraAdivinar, caracter) != NULL && strchr(letrasJugadas, caracter) == NULL)
                {

                    char *pInicioPalabra = palabraAdivinar;
                    char *pInicioVectorGuiones = vectorGuiones;

                    printf("La palabra %c esta incluida\n", caracter);

                    char *pPalabraAdivinar = pInicioPalabra;
                    char *pVectorGuiones = pInicioVectorGuiones;

                    int length = strlen(palabraAdivinar);

                    printf("El vector de guiones es: (antes) *%s*\n", vectorGuiones);

                    for (int i = 0; i < length; i++)
                    {
                        if (toupper(caracter) == toupper(*pPalabraAdivinar))
                        {
                            *pVectorGuiones = toupper(caracter);
                        }

                        pVectorGuiones++;
                        pPalabraAdivinar++;
                    }

                    printf("El vector de guiones es: *%s*\n", vectorGuiones);

                    pPalabraAdivinar = pInicioPalabra;
                    pVectorGuiones = pInicioVectorGuiones;
                }
                else if (strchr(palabraAdivinar, caracter) == NULL)
                {
                    printf("La palabra %c NO esta incluida\n", caracter);

                    printf("El vector de guiones es: *%s*\n", vectorGuiones);

                    cantIntentos--;
                }

                caracter = toupper(caracter);

                strcat(letrasJugadas, &caracter);

                printf("Letras jugadas: %s\n", letrasJugadas);

                send(fd2, vectorGuiones, 50, 0);
                send(fd2, letrasJugadas, 50, 0);
            }

            close(fd2);

            puedeEntrar = 0;
        }

        close(fd);
    }
    else
    {
        printf("No se ingreso el puerto por parametro\n");
    }

    return 0;
}
