#include <iostream>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <string.h>
#include <netdb.h>

#define TAM 50
#define BUFFER 100

using namespace std;

char enterCharacter(char *lettersPlayed)
{
    bool dou;
    char character;
    do
    {
        printf("Ingrese una letra para adivinar la palabra\n");
        fflush(stdin);
        cin >> character;
        dou = strchr(lettersPlayed, toupper(character));
    } while (dou == 1);

    return character;
}

void draw(int intentos)
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
        cout << "-------            " << endl;
        break;
    }
}

void showVector(char *vector)
{
    for (int i = 0; i < strlen(vector); i++)
    {
        cout << vector[i] << " ";
    }
    cout << endl;
}

void help(string nameExe)
{
    cout << "Modo de uso: " << nameExe << " [Dirección IP] [Puerto]" << endl;
    cout << "Por ejemplo: " << nameExe << " 192.168.0.1 8080" << endl;
    cout << "Ejecuta el cliente del juego Hangman (Ahorcado)." << endl;
    cout << "Este juego consiste en adivinar una palabra, ingresando letras y desbloquendo las mismas para completar la palabra. Teniendo una cantidad limitada de jugadas" << endl;
}

int notGuessedWord(char *middleDashVector)
{
    return strchr(middleDashVector, '-') != NULL;
}

int main(int argc, char *argv[])
{
    if (argc > 1)
    {

        if (argc == 2)
        {
            if ((strcmp(argv[1], "--help") == 0) || ((strcmp(argv[1], "-h")) == 0))
                help(argv[0]);
            else
                cout << "Parametros invalidos. Para mas ayuda ejecute: " << argv[0] << " -h o --help" << endl;

            return EXIT_FAILURE;
        }

        int attemps = 6;
        char middleDashVector[TAM];
        char lettersPlayed[TAM];
        char wordToGuess[TAM];
        char middleDashVectorReceived[TAM];
        char character;

        int confirmation = 1;
        int sendConfirmation = 0;
        int receivedConfirmation = 0;
        int returnStatus = 0;

        char *ip;
        int fd, bytesNumber, port;
        char buf[BUFFER], vectorBuffer[BUFFER], lettersPlayedBuffer[BUFFER], wordToGuessBuffer[BUFFER];
        port = atoi(argv[2]);
        ip = argv[1];

        struct hostent *he;
        struct sockaddr_in server;

        if ((he = gethostbyname(ip)) == NULL)
        {
            printf("error en funcion gethostbyname()\n");
            exit(-1);
        }

        if ((fd = socket(AF_INET, SOCK_STREAM, 0)) == -1)
        {
            printf("error en funcion socket()\n");
            exit(-1);
        }

        server.sin_family = AF_INET;
        server.sin_port = htons(port);

        if (inet_aton(ip, &server.sin_addr) == -1)
        {
            printf("Error al conectarse al servidor\n");
            exit(1);
        }

        bzero(&(server.sin_zero), 8);

        socklen_t lengthSocket = sizeof(struct sockaddr);

        if (connect(fd, (struct sockaddr *)&server, sizeof(server)) == -1)
        {
            printf("ERROR: Dirección de IP errónea, ó servidor no abierto. \n");
            exit(-1);
        }

        if ((bytesNumber = recv(fd, buf, BUFFER, 0)) == -1)
        {
            printf("error en funcion recv() \n");
            exit(-1);
        }

        buf[bytesNumber] = '\0';

        printf("Mensaje del Servidor: %s\n", buf);

        if ((bytesNumber = recv(fd, vectorBuffer, BUFFER, 0)) == -1)
        {
            printf("error en funcion recv()\n");
            exit(-1);
        }

        vectorBuffer[bytesNumber] = '\0';

        sendConfirmation = htonl(confirmation);
        printf("Enviando confirmacion (%d): \n", sendConfirmation);
        send(fd, &sendConfirmation, sizeof(sendConfirmation), 0);

        strcpy(middleDashVector, vectorBuffer);

        if ((bytesNumber = recv(fd, lettersPlayedBuffer, BUFFER, 0)) == -1)
        {
            printf("error en funcion recv()\n");
            exit(-1);
        }

        lettersPlayedBuffer[bytesNumber] = '\0';

        strcpy(lettersPlayed, lettersPlayedBuffer);

        sendConfirmation = htonl(confirmation);

        printf("Enviando confirmacion (%d): \n", sendConfirmation);

        send(fd, &sendConfirmation, sizeof(sendConfirmation), 0);

        if ((bytesNumber = recv(fd, wordToGuessBuffer, BUFFER, 0)) == -1)
        {
            printf("error en funcion recv()\n");
            exit(-1);
        }

        wordToGuessBuffer[bytesNumber] = '\0';

        sendConfirmation = htonl(confirmation);

        printf("Enviando confirmacion (%d): \n", sendConfirmation);

        send(fd, &sendConfirmation, sizeof(sendConfirmation), 0);

        strcpy(wordToGuess, wordToGuessBuffer);

        printf("Guiones: %s\n", middleDashVector);
        printf("Letras jugadas: %s\n", lettersPlayed);
        printf("Palabra a adivinar: %s\n", wordToGuess);

        draw(attemps);

        printf("\n\n");

        showVector(middleDashVector);

        bool dou;

        while (attemps > 0 && notGuessedWord(middleDashVector))
        {

            sendConfirmation = htonl(confirmation);
            printf("Enviando confirmacion (%d): \n", sendConfirmation);
            send(fd, &sendConfirmation, sizeof(sendConfirmation), 0);

            if ((returnStatus = recv(fd, &receivedConfirmation, sizeof(receivedConfirmation), 0)) == -1)
            {
                printf("Error recibiendo confirmacion del caracter  \n");
                exit(-1);
            }

            confirmation = ntohl(receivedConfirmation);

            printf("La confirmacion recibida fue: %d\n", confirmation);

            character = enterCharacter(lettersPlayed);

            send(fd, &character, sizeof(char), 0);

            if ((returnStatus = recv(fd, &receivedConfirmation, sizeof(receivedConfirmation), 0)) == -1)
            {
                printf("Error recibiendo confirmacion del caracter  \n");
                exit(-1);
            }

            confirmation = ntohl(receivedConfirmation);

            printf("La confirmacion recibida es: %d\n", confirmation);

            if ((bytesNumber = recv(fd, vectorBuffer, sizeof(vectorBuffer), 0)) == -1)
            {
                printf("error en funcion recv() \n");
                exit(-1);
            }

            strcpy(middleDashVectorReceived, vectorBuffer);

            sendConfirmation = htonl(confirmation);
            printf("Enviando confirmacion (%d): \n", sendConfirmation);
            send(fd, &sendConfirmation, sizeof(sendConfirmation), 0);

            if ((bytesNumber = recv(fd, lettersPlayedBuffer, sizeof(lettersPlayedBuffer), 0)) == -1)
            {
                printf("error en funcion recv() \n");
                exit(-1);
            }

            strcpy(lettersPlayed, lettersPlayedBuffer);

            sendConfirmation = htonl(confirmation);
            printf("Enviando confirmacion (%d): \n", sendConfirmation);
            send(fd, &sendConfirmation, sizeof(sendConfirmation), 0);

            if (strcmp(middleDashVector, middleDashVectorReceived) == 0)
            {
                attemps--;
                draw(attemps);

                printf("No has acertado.\n Te quedan %d intentos \n\n", attemps);

                showVector(middleDashVector);
            }
            else
            {
                strcpy(middleDashVector, middleDashVectorReceived);

                printf("Has acertado!\n Te quedan %d intentos \n\n", attemps);

                showVector(middleDashVector);
            }
        }

        if (attemps > 0)
        {
            printf("Ganaste! Te esperamos para jugar de nuevo.\n");
        }
        else
        {
            draw(attemps);
            printf("Perdiste :(\n Te esperamos para jugar de nuevo.");
        }

        printf("La palabra a adivinar era: %s \n", wordToGuess);

        close(fd);
    }
    else
    {
        printf("Parametros invalidos. Para más ayuda ejecute: %s -h o --help\n", argv[0]);
    }

    return 0;
}