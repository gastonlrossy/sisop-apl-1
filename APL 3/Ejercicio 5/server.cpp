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

#define TAM 50
#define FIL 100
#define COL 300

using namespace std;

char* mi_strcat(char *s1, const char *s2)
{
    char *p=s1;

    while(*s1)
    {
        s1++;
    }

    while(*s2)
    {
        *s1=*s2;
        s1++;
        s2++;
    }

    *s1='\0';

    return p;
}

void help(string nombreEjecutable)
{
    cout << "Modo de uso: " << nombreEjecutable << " (Aqui se especifica el puerto)" << endl;
    cout << "Por ejemplo: " << nombreEjecutable << " " << 8080 << endl;
    cout << "Ejecuta el servidor del Ahorcado." << endl;
    cout << "Este juego consiste en adivinar una palabra, ingresando letras y desbloquendo las mismas para completar la palabra. Teniendo una cantidad limitada de jugadas" << endl;
    cout << "Ejecute la instancia de cliente y observe las letras ingresadas desde el servidor" << endl;
}

string inputFile = "archivo.txt";

int getRandomWord(char linesTxt[FIL][COL])
{
    char line[COL];
    int linesCount = 0;

    FILE *pTxt = fopen("archivo.txt", "rt");
    if (!fopen)
    {
        printf("Error al abrir archivo");
        exit(-1);
    }

    while (fgets(line, sizeof(line), pTxt))
    {
        strcpy(linesTxt[linesCount], line);
        linesCount++;
    }

    srand(time(NULL));
    int random = rand() % linesCount;

    fclose(pTxt);
    return random;
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

        int attemps = 6;
        char linesTxt[FIL][COL];

        char wordToGuess[TAM];
        char middleDashVector[TAM];
        char playedLetters[TAM];

        int fd, fd2, sizeClient, port;
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
            exit(-1);
        }

        if (bind(fd, (struct sockaddr *)&server, sizeof(struct sockaddr)) == -1)
        {
            printf("error en funcion bind() \n");
            exit(-1);
        }

        if (listen(fd, 5) == -1)
        {
            printf("error en funcion listen() \n");
            exit(-1);
        }

        int flag = 1;

        while (flag)
        {
            sizeClient = sizeof(struct sockaddr_in);

            socklen_t clientLen = sizeClient;

            if ((fd2 = accept(fd, (struct sockaddr *)&client, &clientLen)) == -1)
            {
                printf("error en funcion accept() \n");
                exit(-1);
            }

            send(fd2, "Bienvenido al servidor! \n", FIL, 0);

            printf("Inicio del servidor! \n");

            strncpy(playedLetters, "", sizeof(playedLetters));

            char *palAux;
            int random = getRandomWord(linesTxt);

            palAux = linesTxt[random];

            strcpy(wordToGuess, palAux);

            int tam = strlen(wordToGuess) - 1;
            int confirmation = 1;
            int confirmationReceived = 0;
            int returnStatus = 0;
            int sendConfirmation = 0;

            char *middleDashVectorAux = (char *)malloc(tam);

            char *aux = middleDashVectorAux;
            for (int i = 0; i < tam; i++)
            {
                *aux = '-';
                aux++;
            }

            *aux = '\0';

            strcpy(middleDashVector, middleDashVectorAux);

            send(fd2, middleDashVector, sizeof(middleDashVector), 0);

            if ((returnStatus = recv(fd2, &confirmationReceived, sizeof(confirmationReceived), 0)) == -1)
            {
                printf("Error en funcion read()\n");
                exit(-1);
            }

            confirmation = ntohl(confirmationReceived);

            printf("La confirmacion recibida fue: %d\n", confirmation);

            send(fd2, playedLetters, sizeof(playedLetters), 0);

            if ((returnStatus = recv(fd2, &confirmationReceived, sizeof(confirmationReceived), 0)) == -1)
            {
                printf("Error en funcion read()\n");
                exit(-1);
            }

            confirmation = ntohl(confirmationReceived);

            printf("La confirmacion recibida fue: %d\n", confirmation);

            send(fd2, wordToGuess, sizeof(wordToGuess), 0);

            if ((returnStatus = recv(fd2, &confirmationReceived, sizeof(confirmationReceived), 0)) == -1)
            {
                printf("Error en funcion read()\n");
                exit(-1);
            }

            confirmation = ntohl(confirmationReceived);

            printf("La confirmacion recibida fue: %d\n", confirmation);

            char character;
            char beforeCharacter;
            int total = 0;
            int numbytes = 0;

            while (attemps > 0)
            {

                if ((returnStatus = recv(fd2, &confirmationReceived, sizeof(confirmationReceived), 0)) == -1)
                {
                    printf("Error recibiendo entero ( read() )  \n");
                    exit(-1);
                }

                confirmation = ntohl(confirmationReceived);

                printf("La confirmacion recibida es: %d\n", confirmation);

                sendConfirmation = htonl(confirmation);
                printf("Enviando confirmacion (%d): \n", sendConfirmation);
                send(fd2, &sendConfirmation, sizeof(sendConfirmation), 0);

                if ((numbytes = recv(fd2, &character, sizeof(char), 0)) == -1)
                {
                    printf("error en recv() \n");
                    exit(-1);
                }

                sendConfirmation = htonl(confirmation);
                printf("Enviando confirmacion (%d): \n", sendConfirmation);

                send(fd2, &sendConfirmation, sizeof(sendConfirmation), 0);

                printf("Numero de bytes: %d\n", numbytes);

                printf("Caracter recibido: %c\n", character);

                beforeCharacter = character;

                if (strchr(wordToGuess, character) != NULL && strchr(playedLetters, character) == NULL)
                {

                    char *pStartWord = wordToGuess;
                    char *pStartMiddleDashVector = middleDashVector;

                    printf("La palabra %c esta incluida\n", character);

                    char *pWordToGuess = pStartWord;
                    char *pMiddleDashVector = pStartMiddleDashVector;

                    int length = strlen(wordToGuess);

                    printf("El vector de guiones es: (antes) *%s*\n", middleDashVector);

                    for (int i = 0; i < length; i++)
                    {
                        if (toupper(character) == toupper(*pWordToGuess))
                        {
                            *pMiddleDashVector = toupper(character);
                        }

                        pMiddleDashVector++;
                        pWordToGuess++;
                    }

                    printf("El vector de guiones es: *%s*\n", middleDashVector);

                    pWordToGuess = pStartWord;
                    pMiddleDashVector = pStartMiddleDashVector;
                }
                else if (strchr(wordToGuess, character) == NULL)
                {
                    printf("La palabra %c NO esta incluida\n", character);

                    printf("El vector de guiones es: *%s*\n", middleDashVector);

                    attemps--;
                }

                character = toupper(character);

                mi_strcat(playedLetters, &character);

                printf("Letras jugadas: %s\n", playedLetters);

                send(fd2, middleDashVector, sizeof(middleDashVector), 0);

                if ((returnStatus = recv(fd2, &confirmationReceived, sizeof(confirmationReceived), 0)) == -1)
                {
                    printf("Error en funcion recv()\n");
                    exit(-1);
                }

                confirmation = ntohl(confirmationReceived);

                printf("La confirmacion recibida es: %d\n", confirmation);

                send(fd2, playedLetters, sizeof(playedLetters), 0);

                if ((returnStatus = recv(fd2, &confirmationReceived, sizeof(confirmationReceived), 0)) == -1)
                {
                    printf("Error en funcion recv()\n");
                    exit(-1);
                }

                confirmation = ntohl(confirmationReceived);

                printf("La confirmacion recibida es: %d\n", confirmation);
            }

            close(fd2);

            flag = 0;
        }

        close(fd);
    }
    else
    {
        printf("Parametros invalidos. Para más ayuda ejecute: %s -h o --help\n", argv[0]);
    }

    return 0;
}