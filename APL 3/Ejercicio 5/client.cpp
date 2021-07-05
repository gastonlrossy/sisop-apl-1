/*
#####                   APL N3                  #####
#####		    Ejercicio 5 - Entrega           #####
#####				client.cpp                  #####

#####			      GRUPO Nº2                 #####
#####         Tebes, Leandro - 40.227.531       #####
#####         Rossy, Gaston L. - 40.137.778     #####
#####	      Zella, Ezequiel - 41.915.248      #####
#####       Cencic, Maximiliano - 41.292.382    #####
#####       Bonvehi, Sebastian - 40.538.404     ##### 
*/

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
#include <signal.h>

#define ERROR -1
#define OK 0
#define NOT_OK 1
#define TAM 50
#define PID_NO 64
#define BUFFER 100
#define PID_LINE 1024

using namespace std;

char addCharacter(char *playedLetters)
{
    bool isRepeated = 0;
    char character;
    do
    {

        if (isRepeated == 0)
            printf("Ingrese una letra para adivinar la palabra\n");
        if (isRepeated == 1)
            printf("La letra '%c' ya fue jugada. Ingrese otra nuevamente.\n ", character);
        fflush(stdin);
        cin >> character;
        character = tolower(character);
        isRepeated = strchr(playedLetters, toupper(character));
    } while (isRepeated == 1 || !isalpha(character));

    return character;
}

void drawHangman(int attemps)
{

    switch (attemps)
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

void showVec(char *vector)
{
    for (int i = 0; i < strlen(vector); i++)
    {
        cout << vector[i] << " ";
    }
    cout << endl;
}

void help(string exe)
{
    cout << "Modo de uso: " << exe << " [Dirección IP] [Puerto]" << endl;
    cout << "Por ejemplo: " << exe << " 192.167.0.1 8080" << endl;
    cout << "Ejecuta el cliente del juego Ahorcado." << endl;
    cout << "Este juego consiste en adivinar una palabra, ingresando letras y desbloquendo las mismas para completar la palabra. Teniendo asi una cantidad limitada de intentos." << endl;
    cout << "Una vez en el juego elegir una letra a buscar la coincidencias." << endl;
}

int notGuessedWord(char *middleDashVec)
{
    return strchr(middleDashVec, '-') != NULL;
}

int fd;

int getPID(void)
{
    char pidline[PID_LINE];
    char *pid;
    int i = 0;
    int pidno[PID_NO];

    FILE *fp = popen("pidof server.exe", "r");

    fgets(pidline, PID_LINE, fp);

    pid = strtok(pidline, " ");

    if (pid != NULL)
    {
        pidno[i] = atoi(pid);
    }

    pclose(fp);
    return pidno[i];
}

void closeClient(int sig)
{
    if (SIGINT == sig || sig == SIGUSR1)
    {
        printf("\nAbandonaste la partida.\n");

        close(fd);

        pid_t pid = getpid();

        kill(pid, SIGUSR1);

        exit(OK);
    }
}

int main(int argc, char *argv[])
{

    if (argc > 1)
    {

        if (argc == 2)
        {
            if ((strcmp(argv[1], "--help") == 0) || ((strcmp(argv[1], "-h")) == OK))
                help(argv[0]);
            else
                cout << "Parametros invalidos. Para mas ayuda ejecute: " << argv[0] << " -h o --help" << endl;

            return NOT_OK;
        }

        int attemps = 6;
        char middleDashVec[TAM];
        char playedLetters[TAM];
        char wordToGuess[TAM];
        char middleDashVecReceived[TAM];
        char character;

        int confirmation = 1;
        int sendConfirmation = 0;
        int confirmationReceived = 0;
        int returnStatus = 0;

        char *ip;
        int fd, numbytes, port;
        char buf[BUFFER], vecBuffer[BUFFER], playedLettersBuffer[BUFFER], wordToGuessBuffer[BUFFER];
        port = atoi(argv[2]);
        ip = argv[1];

        signal(SIGINT, closeClient);

        struct hostent *he;
        struct sockaddr_in server;

        if ((he = gethostbyname(ip)) == NULL)
        {
            printf("Error al obtener host.\n");
            exit(ERROR);
        }

        if ((fd = socket(AF_INET, SOCK_STREAM, 0)) == ERROR)
        {
            printf("Error en funcion socket().\n");
            exit(ERROR);
        }

        server.sin_family = AF_INET;
        server.sin_port = htons(port);

        if (inet_aton(ip, &server.sin_addr) == ERROR)
        {
            printf("Error al conectarse al servidor\n");
            exit(ERROR);
        }

        bzero(&(server.sin_zero), 8);

        socklen_t lengthSocket = sizeof(struct sockaddr);

        if (connect(fd, (struct sockaddr *)&server, sizeof(server)) == ERROR)
        {
            printf("Error: Dirección de IP errónea, ó servidor no abierto.\n");
            exit(ERROR);
        }

        if ((numbytes = recv(fd, buf, BUFFER, 0)) == ERROR)
        {
            printf("error en funcion recv()\n");
            exit(ERROR);
        }

        buf[numbytes] = '\0';

        printf("Mensaje del Servidor: %s\n", buf);

        if ((numbytes = recv(fd, vecBuffer, BUFFER, 0)) == ERROR)
        {
            printf("error en funcion recv().\n");
            exit(ERROR);
        }

        vecBuffer[numbytes] = '\0';

        sendConfirmation = htonl(confirmation);
        send(fd, &sendConfirmation, sizeof(sendConfirmation), 0);

        strcpy(middleDashVec, vecBuffer);

        if ((numbytes = recv(fd, playedLettersBuffer, BUFFER, 0)) == ERROR)
        {
            printf("error en funcion recv().\n");
            exit(ERROR);
        }

        playedLettersBuffer[numbytes] = '\0';

        strcpy(playedLetters, playedLettersBuffer);

        sendConfirmation = htonl(confirmation);
        send(fd, &sendConfirmation, sizeof(sendConfirmation), 0);

        if ((numbytes = recv(fd, wordToGuessBuffer, BUFFER, 0)) == ERROR)
        {
            printf("error en funcion recv().\n");
            exit(ERROR);
        }

        wordToGuessBuffer[numbytes] = '\0';

        sendConfirmation = htonl(confirmation);
        send(fd, &sendConfirmation, sizeof(sendConfirmation), 0);

        strcpy(wordToGuess, wordToGuessBuffer);

        drawHangman(attemps);

        showVec(middleDashVec);

        while (attemps > 0 && notGuessedWord(middleDashVec))
        {
            sendConfirmation = htonl(confirmation);
            
            send(fd, &sendConfirmation, sizeof(sendConfirmation), 0);

            if ((returnStatus = recv(fd, &confirmationReceived, sizeof(confirmationReceived), 0)) == ERROR)
            {
                printf("Error recibiendo confirmacion del caracter.\n");
                exit(ERROR);
            }

            confirmation = ntohl(confirmationReceived);

            character = addCharacter(playedLetters);

            send(fd, &character, sizeof(char), 0);

            if ((returnStatus = recv(fd, &confirmationReceived, sizeof(confirmationReceived), 0)) == ERROR)
            {
                printf("Error recibiendo confirmacion del caracter.\n");
                exit(ERROR);
            }

            confirmation = ntohl(confirmationReceived);

            if ((numbytes = recv(fd, vecBuffer, sizeof(vecBuffer), 0)) == ERROR)
            {
                printf("error en funcion recv().\n");
                exit(ERROR);
            }

            strcpy(middleDashVecReceived, vecBuffer);

            sendConfirmation = htonl(confirmation);
            send(fd, &sendConfirmation, sizeof(sendConfirmation), 0);

            if ((numbytes = recv(fd, playedLettersBuffer, sizeof(playedLettersBuffer), 0)) == ERROR)
            {
                printf("error en funcion recv().\n");
                exit(ERROR);
            }

            strcpy(playedLetters, playedLettersBuffer);

            sendConfirmation = htonl(confirmation);
            send(fd, &sendConfirmation, sizeof(sendConfirmation), 0);

            if (strcmp(middleDashVec, middleDashVecReceived) == 0)
            {
                attemps--;
                drawHangman(attemps);

                printf("No has acertado ninguna letra\nTe quedan %d intentos.\n\n", attemps);

                showVec(middleDashVec);
            }
            else
            {
                strcpy(middleDashVec, middleDashVecReceived);

                printf("Has acertado!\nTe quedan (%d) intentos\n\n", attemps);

                showVec(middleDashVec);
            }
        }

        if (attemps > 0)
        {
            printf("Ganaste! Para cuando la revancha?\n");
        }
        else
        {
            drawHangman(attemps);
            printf("Perdiste :( Esta vez gane yo!!\n");
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