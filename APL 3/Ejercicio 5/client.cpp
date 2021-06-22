#include <iostream>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <string.h>
#include <netdb.h>

using namespace std;

void dibujarHangman(int intentos)
{

    switch (intentos)
    {

    case 0:
        cout << "                   " << endl;
        cout << "                   " << endl;
        cout << "   |------------   " << endl;
        cout << "   |           |   " << endl;
        cout << "   |           |   " << endl;
        cout << "   |           O   " << endl;
        cout << "   |          /|\\  " << endl;
        cout << "   |         / | \\ " << endl;
        cout << "   |           |   " << endl;
        cout << "   |          / \\  " << endl;
        cout << "   |         /   \\ " << endl;
        cout << "   |               " << endl;
        cout << "-------            " << endl;
        break;

    case 1:
        cout << "                   " << endl;
        cout << "                   " << endl;
        cout << "   |------------   " << endl;
        cout << "   |           |   " << endl;
        cout << "   |           |   " << endl;
        cout << "   |           O   " << endl;
        cout << "   |           |\\  " << endl;
        cout << "   |           | \\ " << endl;
        cout << "   |           |   " << endl;
        cout << "   |          / \\  " << endl;
        cout << "   |         /   \\ " << endl;
        cout << "   |               " << endl;
        cout << "-------            " << endl;
        break;

    case 2:
        cout << "                   " << endl;
        cout << "                   " << endl;
        cout << "   |------------   " << endl;
        cout << "   |           |   " << endl;
        cout << "   |           |   " << endl;
        cout << "   |           O   " << endl;
        cout << "   |           |\\  " << endl;
        cout << "   |           | \\ " << endl;
        cout << "   |           |   " << endl;
        cout << "   |            \\  " << endl;
        cout << "   |             \\ " << endl;
        cout << "   |               " << endl;
        cout << "-------            " << endl;
        break;

    case 3:
        cout << "                   " << endl;
        cout << "                   " << endl;
        cout << "   |------------   " << endl;
        cout << "   |           |   " << endl;
        cout << "   |           |   " << endl;
        cout << "   |           O   " << endl;
        cout << "   |           |\\  " << endl;
        cout << "   |           | \\ " << endl;
        cout << "   |           |   " << endl;
        cout << "   |               " << endl;
        cout << "   |               " << endl;
        cout << "   |               " << endl;
        cout << "-------            " << endl;
        break;

    case 4:
        cout << "                   " << endl;
        cout << "                   " << endl;
        cout << "   |------------   " << endl;
        cout << "   |           |   " << endl;
        cout << "   |           |   " << endl;
        cout << "   |           O   " << endl;
        cout << "   |           |   " << endl;
        cout << "   |           |   " << endl;
        cout << "   |           |   " << endl;
        cout << "   |               " << endl;
        cout << "   |               " << endl;
        cout << "   |               " << endl;
        cout << "-------            " << endl;
        break;

    case 5:
        cout << "                   " << endl;
        cout << "                   " << endl;
        cout << "   |------------   " << endl;
        cout << "   |           |   " << endl;
        cout << "   |           |   " << endl;
        cout << "   |           O   " << endl;
        cout << "   |               " << endl;
        cout << "   |               " << endl;
        cout << "   |               " << endl;
        cout << "   |               " << endl;
        cout << "   |               " << endl;
        cout << "   |               " << endl;
        cout << "-------            " << endl;
        break;

    case 6:
        cout << "                   " << endl;
        cout << "                   " << endl;
        cout << "   |------------   " << endl;
        cout << "   |           |   " << endl;
        cout << "   |           |   " << endl;
        cout << "   |               " << endl;
        cout << "   |               " << endl;
        cout << "   |               " << endl;
        cout << "   |               " << endl;
        cout << "   |               " << endl;
        cout << "   |               " << endl;
        cout << "   |               " << endl;
        cout << "-------            " << endl;
        break;
    }
}

void mostrarVector(char *vector)
{
    for (int i = 0; i < strlen(vector); i++)
    {
        cout << vector[i] << " ";
    }
    cout << endl;
}

void help(string nombreEjecutable)
{
    cout << "Modo de uso: " << nombreEjecutable << endl;
    cout << "Ejecuta el cliente del juego Hangman (Ahorcado)." << endl;
    cout << "Este juego consiste en adivinar una palabra, ingresando letras y desbloquendo las mismas para completar la palabra" << endl;
    cout << "Una vez en el juego elegir una letra a buscar la coincidencias." << endl;
}

int main(int argc, char *argv[])
{

    if (argc > 2)
    {
        char *ip;
        int fd, numbytes, puerto;
        char buf[100], buf2[100];
        puerto = atoi(argv[2]);
        ip = argv[1];

        struct hostent *he;

        struct sockaddr_in server;

        if ((he = gethostbyname(ip)) == NULL)
        {
            printf("gethostbyname() error \n");
            exit(-1);
        }

        if ((fd = socket(AF_INET, SOCK_STREAM, 0)) == -1)
        {
            printf("socket() error\n");
            exit(-1);
        }

        server.sin_family = AF_INET;
        server.sin_port = htons(puerto);
        server.sin_addr = *((struct in_addr *)he->h_addr);
        bzero(&(server.sin_zero), 8);

        socklen_t lengthSocket = sizeof(struct sockaddr);

        if (connect(fd, (struct sockaddr *)&server, lengthSocket) == -1)
        {
            printf("ERROR: Dirección de IP errónea, ó servidor no abierto. \n");
            exit(-1);
        }

        if ((numbytes = recv(fd, buf, 100, 0)) == -1)
        {
            printf("error en recv() \n");
            exit(-1);
        }

        buf[numbytes] = '\0';

        printf("Mensaje del Servidor: %s\n", buf);

        int returnStatus = 0;
        int cantIntentosRecibido = 0;
        int cantIntentos = 0;

        if ((returnStatus = read(fd, &cantIntentosRecibido, sizeof(cantIntentosRecibido))) == -1)
        {
            printf("Error recibiendo entero ( read() )  \n");
            exit(-1);
        }

        cantIntentos = ntohl(cantIntentosRecibido);

        printf("Cant de intentos recibidos: %d\n", cantIntentosRecibido);
        printf("Cant de intentos: %d\n", cantIntentos);

        char vectorGuiones[50];
        char letrasJugadas[50];
        char palabraAdivinar[50];
        char vectorGuionesRecibido[50];
        char caracter;

        int confirmacion = 1;

        if ((numbytes = recv(fd, buf2, 50, 0)) == -1)
        {
            printf("error en recv() -> vector de guiones \n");
            exit(-1);
        }

        buf2[numbytes] = '\0';

        strcpy(vectorGuiones, buf2);

        if ((numbytes = recv(fd, buf2, 50, 0)) == -1)
        {
            printf("error en recv() -> letras jugadas \n");
            exit(-1);
        }

        buf2[numbytes] = '\0';

        strcpy(letrasJugadas, buf2);

        if ((numbytes = recv(fd, buf2, 50, 0)) == -1)
        {
            printf("error en recv() -> palabra a adivinar \n");
            exit(-1);
        }

        buf2[numbytes] = '\0';

        strcpy(palabraAdivinar, buf2);

        printf("Vector de guiones: %s\n", vectorGuiones);
        printf("Letras jugadas: %s\n", letrasJugadas);
        printf("Palabra a adivinar: %s\n", palabraAdivinar);

        dibujarHangman(cantIntentos);

        printf("\n\n");

        mostrarVector(vectorGuiones);

        while (cantIntentos > 0)
        {
            printf("Ingrese una letra para adivinar la palabra\n");
            scanf("%c", &caracter);

            fflush(stdin);

            send(fd, &caracter, 1, 0);

            if ((numbytes = recv(fd, buf2, 50, 0)) == -1)
            {
                printf("error en recv() \n");
                exit(-1);
            }

            strcpy(vectorGuionesRecibido, buf2);

            if ((numbytes = recv(fd, buf2, 50, 0)) == -1)
            {
                printf("error en recv() \n");
                exit(-1);
            }

            strcpy(letrasJugadas, buf2);

            if (strcmp(vectorGuiones, vectorGuionesRecibido) == 0)
            {
                cantIntentos--;
                dibujarHangman(cantIntentos);

                printf("No has acertado ninguna letra \n Te quedan %d intentos \n\n", cantIntentos);

                mostrarVector(vectorGuiones);
            }
            else
            {
                strcpy(vectorGuiones, vectorGuionesRecibido);

                printf("Has acertado!\n Te quedan %d intentos \n\n", cantIntentos);

                mostrarVector(vectorGuiones);
            }
        }

        if (cantIntentos > 0)
        {
            printf("Ganaste!!!\n");
        }
        else
        {
            dibujarHangman(cantIntentos);
            printf("Perdiste :(\n");
        }

        printf("La palabra a adivinar era: %s \n", palabraAdivinar);

        close(fd);
    }
    else
    {
        printf("No se ingreso el ip y puerto por parametro\n");
    }

    return 0;
}
