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

using namespace std;

char enterCharacter(char *playedLetters)
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

void draw(int attemps)
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

void help(string nameExe)
{
    cout << "Modo de uso: " << nameExe << " [IP] [Puerto]" << endl;
    cout << "Por ejemplo: " << nameExe << " 192.167.0.1 8080" << endl;
    cout << "Ejecuta el cliente del ahorcado." << endl;
    cout << "Este juego consiste en adivinar una palabra, ingresando letras y desbloquendo las mismas para completar la palabra. Teniendo una cantidad limitada de intentos." << endl;
}

int notGuessedWord(char *middleDashVec)
{
    return strchr(middleDashVec, '-') != NULL;
}

int fd;

int getPID(void)
{
    char pidline[1024];
    char *pid;
    int i = 0;
    int pidno[64];
    FILE *fp = popen("pidof servidor.exe", "r");
    fgets(pidline, 1024, fp);

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
        printf("\nAbandonaste la partida. \n");
        close(fd);

        int pidObtenido = getPID();

        pid_t pid = (pid_t) pidObtenido;

        kill(pid, SIGUSR1);

        exit(0);
    }
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

        int attempsCount = 6;
        char middleDashVec[50];
        char playedLetters[50];
        char wordToGuess[50];
        char middleDashVecReceived[50];
        char character;

        int confirmation = 1;
        int sendConfirmation = 0;
        int receivedConfirmation = 0;
        int returnStatus = 0;

        char *ip;
        int fd, numbytes, port;
        char buf[100], vectorBuffer[100], playedLettersBuffer[100], wordToGuessBuffer[100];
        port = atoi(argv[2]);
        ip = argv[1];

        signal(SIGINT, closeClient);

        struct hostent *he;
        struct sockaddr_in server;

        if ((he = gethostbyname(ip)) == NULL)
        {
            printf("Error al obtener nombre del host.\n");
            exit(-1);
        }

        if ((fd = socket(AF_INET, SOCK_STREAM, 0)) == -1)
        {
            printf("Error al llamar al socket.\n");
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

        if ((numbytes = recv(fd, buf, 100, 0)) == -1)
        {
            printf("error en funcion recv().\n");
            exit(-1);
        }

        buf[numbytes] = '\0';

        printf("Mensaje del Servidor: %s\n", buf);

        if ((numbytes = recv(fd, vectorBuffer, 100, 0)) == -1)
        {
            printf("error en vector de guiones.\n");
            exit(-1);
        }

        vectorBuffer[numbytes] = '\0';

        sendConfirmation = htonl(confirmation);
        send(fd, &sendConfirmation, sizeof(sendConfirmation), 0);

        strcpy(middleDashVec, vectorBuffer);

        if ((numbytes = recv(fd, playedLettersBuffer, 100, 0)) == -1)
        {
            printf("error en letras jugadas.\n");
            exit(-1);
        }

        playedLettersBuffer[numbytes] = '\0';

        strcpy(playedLetters, playedLettersBuffer);

        sendConfirmation = htonl(confirmation);
        send(fd, &sendConfirmation, sizeof(sendConfirmation), 0);

        if ((numbytes = recv(fd, wordToGuessBuffer, 100, 0)) == -1)
        {
            printf("error en palabra a adivinar.\n");
            exit(-1);
        }

        wordToGuessBuffer[numbytes] = '\0';

        sendConfirmation = htonl(confirmation);

        send(fd, &sendConfirmation, sizeof(sendConfirmation), 0);

        strcpy(wordToGuess, wordToGuessBuffer);

        draw(attempsCount);

        showVec(middleDashVec);

        bool dou;

        while (attempsCount > 0 && notGuessedWord(middleDashVec))
        {

            sendConfirmation = htonl(confirmation);
            send(fd, &sendConfirmation, sizeof(sendConfirmation), 0);

            if ((returnStatus = recv(fd, &receivedConfirmation, sizeof(receivedConfirmation), 0)) == -1)
            {
                printf("Error recibiendo confirmacion del caracter.\n");
                exit(-1);
            }

            confirmation = ntohl(receivedConfirmation);

            character = enterCharacter(playedLetters);

            send(fd, &character, sizeof(char), 0);

            if ((returnStatus = recv(fd, &receivedConfirmation, sizeof(receivedConfirmation), 0)) == -1)
            {
                printf("Error recibiendo confirmacion del caracter.\n");
                exit(-1);
            }

            confirmation = ntohl(receivedConfirmation);

            if ((numbytes = recv(fd, vectorBuffer, sizeof(vectorBuffer), 0)) == -1)
            {
                printf("error en funcion recv().\n");
                exit(-1);
            }

            strcpy(middleDashVecReceived, vectorBuffer);

            sendConfirmation = htonl(confirmation);
            send(fd, &sendConfirmation, sizeof(sendConfirmation), 0);

            if ((numbytes = recv(fd, playedLettersBuffer, sizeof(playedLettersBuffer), 0)) == -1)
            {
                printf("error en funcion recv().\n");
                exit(-1);
            }

            strcpy(playedLetters, playedLettersBuffer);

            sendConfirmation = htonl(confirmation);
            send(fd, &sendConfirmation, sizeof(sendConfirmation), 0);

            if (strcmp(middleDashVec, middleDashVecReceived) == 0)
            {
                attempsCount--;
                draw(attempsCount);

                printf("No has acertado ninguna letra\nTe quedan %d intentos\n\n", attempsCount);

                showVec(middleDashVec);
            }
            else
            {
                strcpy(middleDashVec, middleDashVecReceived);

                printf("Has acertado!\nTe quedan (%d) intentos\n\n", attempsCount);

                showVec(middleDashVec);
            }

        }

        if (attempsCount > 0)
        {
            printf("Felicidades, has ganado. Te esperamos para una buena revancha!\n");
        }
        else
        {
            draw(attempsCount);
            printf("Perdiste :(. Esta vez gane yo!\n");
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