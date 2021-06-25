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

#define FIL 100
#define COL 300
#define VEC 50
#define ERROR -1

using namespace std;

char *mi_strcat(char *s1, const char *s2)
{
    char *p = s1;

    while (*s1)
    {
        s1++;
    }

    while (*s2)
    {
        *s1 = *s2;
        s1++;
        s2++;
    }

    *s1 = '\0';

    return p;
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
    cout << "Modo de uso: " << nameExe << " [Puerto]" << endl;
    cout << "Por ejemplo: " << nameExe << " " << 8080 << endl;
    cout << "Ejecuta el servidor del ahorcado." << endl;
    cout << "Este juego consiste en adivinar una palabra, ingresando letras y desbloquendo las mismas para completar la palabra. Teniendo una cantidad limitada de intentos." << endl;
}

string archivoEntrada = "archivo.txt";

int obtenerPalabraAleatoria(char txtLines[FIL][COL])
{
    char line[COL];
    int linesCount = 0;

    FILE *pTxt = fopen("archivo.txt", "rt");
    if (!fopen)
    {
        printf("No se pudo abrir el archivo txt");
        exit(ERROR);
    }

    while (fgets(line, sizeof(line), pTxt))
    {
        strcpy(txtLines[linesCount], line);
        linesCount++;
    }

    srand(time(NULL));
    int random = rand() % linesCount;

    fclose(pTxt);
    return random;
}

int notGuessedWord(char *middleDashVec)
{
    return strchr(middleDashVec, '-') != NULL;
}

int fd, fd2;

void closeServer(int sig)
{
    if (SIGUSR1 == sig)
    {
        printf("\nServidor finalizado!\n");
        close(fd2);
        close(fd);
        exit(0);
    }
}

int main(int argc, char **argv)
{

    if (argc > 1)
    {

        if (argc == 2)
        {
            if ((strcmp(argv[1], "--help") == 0) || ((strcmp(argv[1], "-h")) == 0))
            {
                help(argv[0]);
                return EXIT_SUCCESS;
            }
        }

        signal(SIGINT, SIG_IGN);
        signal(SIGUSR1, closeServer);

        int attemps = 6;
        char txtLines[FIL][COL];

        char wordToGuess[VEC];
        char middleDashVec[VEC];
        char playedLetters[VEC];

        int fd, fd2, clientSize, port;
        port = atoi(argv[1]);

        struct sockaddr_in server;
        struct sockaddr_in client;

        server.sin_family = AF_INET;
        server.sin_port = htons(port);
        server.sin_addr.s_addr = INADDR_ANY;
        bzero(&(server.sin_zero), 8);

        if ((fd = socket(AF_INET, SOCK_STREAM, 0)) < 0)
        {
            perror("Error de apertura de socket");
            exit(ERROR);
        }

        if (bind(fd, (struct sockaddr *)&server, sizeof(struct sockaddr)) == ERROR)
        {
            printf("error en funcion bind().\n");
            exit(ERROR);
        }

        if (listen(fd, 5) == ERROR)
        {
            printf("error en listen() \n");
            exit(ERROR);
        }

        int canEntry = 1;
        int cantMatchs = 0;
        char characterToAdd;

        while (canEntry)
        {
            // if(cantMatchs >= 1)
            // {
            //     printf("\nQuiere cerrar el servidor? (s/n)\n");
            //     cin >> characterToAdd;

            //     if(toupper(characterToAdd) == 'S')
            //     {
            //         closeServer(SIGUSR1);
            //     }
        
            // }

            cantMatchs++;

            clientSize = sizeof(struct sockaddr_in);

            socklen_t clientLen = clientSize;

            if ((fd2 = accept(fd, (struct sockaddr *)&client, &clientLen)) == ERROR)
            {
                printf("error en funcion accept().\n");
                exit(ERROR);
            }

            send(fd2, "Bienvenido al servidor! \n", FIL, 0);

            printf("Inicio de la partida! \n");

            printf("Se ha conectado el cliente\n");

            strncpy(playedLetters, "", sizeof(playedLetters));

            char *palAux;
            int random = obtenerPalabraAleatoria(txtLines);

            palAux = txtLines[random];

            strcpy(wordToGuess, palAux);

            int tam = strlen(wordToGuess) - 1;
            int confirmation = 1;
            int receivedConfirmation = 0;
            int returnStatus = 0;
            int sendConfirmation = 0;

            char *middleDashVecAux = (char *)malloc(tam);

            char *aux = middleDashVecAux;

            for (int i = 0; i < tam; i++)
            {
                *aux = '-';
                aux++;
            }

            *aux = '\0';

            strcpy(middleDashVec, middleDashVecAux);

            send(fd2, middleDashVec, sizeof(middleDashVec), 0);

            if ((returnStatus = recv(fd2, &receivedConfirmation, sizeof(receivedConfirmation), 0)) == ERROR)
            {
                printf("Error en funcion recv().\n");
                exit(ERROR);
            }

            confirmation = ntohl(receivedConfirmation);

            send(fd2, playedLetters, sizeof(playedLetters), 0);

            if ((returnStatus = recv(fd2, &receivedConfirmation, sizeof(receivedConfirmation), 0)) == ERROR)
            {
                printf("Error en funcion recv().\n");
                exit(ERROR);
            }

            confirmation = ntohl(receivedConfirmation);

            send(fd2, wordToGuess, sizeof(wordToGuess), 0);

            if ((returnStatus = recv(fd2, &receivedConfirmation, sizeof(receivedConfirmation), 0)) == ERROR)
            {
                printf("Error en funcion recv().\n");
                exit(ERROR);
            }

            confirmation = ntohl(receivedConfirmation);

            char character;
            char oldCharacter;
            int total = 0;
            int numbytes = 0;

            while (attemps > 0 && notGuessedWord(middleDashVec))
            {

                if ((returnStatus = recv(fd2, &receivedConfirmation, sizeof(receivedConfirmation), 0)) == ERROR)
                {
                    printf("Error en funcion recv().\n");
                    exit(ERROR);
                }

                confirmation = ntohl(receivedConfirmation);

                sendConfirmation = htonl(confirmation);
                send(fd2, &sendConfirmation, sizeof(sendConfirmation), 0);

                if ((numbytes = recv(fd2, &character, sizeof(char), 0)) == ERROR)
                {
                    printf("Error en funcion recv().\n");
                    exit(ERROR);
                }

                sendConfirmation = htonl(confirmation);
                send(fd2, &sendConfirmation, sizeof(sendConfirmation), 0);

                oldCharacter = character;

                if (strchr(wordToGuess, character) != NULL && strchr(playedLetters, character) == NULL)
                {

                    char *pointerStartWord = wordToGuess;
                    char *pointerStartMiddleDashVec = middleDashVec;

                    char *pointerWordToGuess = pointerStartWord;
                    char *pointerMiddleDashVec = pointerStartMiddleDashVec;

                    int length = strlen(wordToGuess);

                    for (int i = 0; i < length; i++)
                    {
                        if (toupper(character) == toupper(*pointerWordToGuess))
                        {
                            *pointerMiddleDashVec = toupper(character);
                        }

                        pointerMiddleDashVec++;
                        pointerWordToGuess++;
                    }

                    pointerWordToGuess = pointerStartWord;
                    pointerMiddleDashVec = pointerStartMiddleDashVec;
                }
                else if (strchr(wordToGuess, character) == NULL)
                {
                    attemps--;
                }

                oldCharacter = toupper(character);
                mi_strcat(playedLetters, &oldCharacter);

                printf("Las letras que jugaste son: \n");
                showVec(playedLetters);

                send(fd2, middleDashVec, sizeof(middleDashVec), 0);

                if ((returnStatus = recv(fd2, &receivedConfirmation, sizeof(receivedConfirmation), 0)) == ERROR)
                {
                    printf("Error en funcion recv().\n");
                    exit(ERROR);
                }

                confirmation = ntohl(receivedConfirmation);

                send(fd2, playedLetters, sizeof(playedLetters), 0);

                if ((returnStatus = recv(fd2, &receivedConfirmation, sizeof(receivedConfirmation), 0)) == ERROR)
                {
                    printf("Error en funcion recv().\n");
                    exit(ERROR);
                }

                confirmation = ntohl(receivedConfirmation);
            }

            printf("Partida finalizada!\n");
            close(fd2);
        }

        closeServer(SIGUSR1);
    }
    else
    {
        printf("Parametros invalidos. Para más ayuda ejecute: %s -h o --help\n", argv[0]);
    }

    return 0;
}