/*
#####                   APL N3                  #####
#####		    Ejercicio 5 - Entrega           #####
#####				server.cpp                  #####

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
#include <string.h>
#include <vector>
#include <string>
#include <sstream>
#include <signal.h>
#include <fstream>
#include <thread>
#include <string.h>
#include <sys/types.h>
#include <netdb.h>
#include <vector>
#include <string>
#include <sstream>
#include <signal.h>

#define ERROR -1
#define OK 0
#define NOT_OK 1
#define TAM 50
#define FIL 100
#define COL 300

using namespace std;

//fd = servidor,
//fd2 = cliente
int fd, fd2; 
int attemps = 6;

string executeCommand(const char *cmd)
{
    std::array<char, 128> buffer;
    string result;
    std::unique_ptr<FILE, decltype(&pclose)> pipe(popen(cmd, "r"), pclose);

    if (!pipe)
    {
        throw std::runtime_error("ha ocurrido un error con popen()");
    }

    while (fgets(buffer.data(), buffer.size(), pipe.get()) != nullptr)
    {
        result += buffer.data();
    }

    return result;
}

void closeServer(int sig)
{
    if (SIGUSR1 == sig)
    {
        string result = executeCommand("ps -fea | grep ./client.exe | wc -l");

        if (stoi(result) > 2)
        {
            printf("Existe un cliente que esta en ejecucion\n");
            return;
        }
        else
        {
            printf("\nServidor finalizado!\n");
            close(fd);
            close(fd2);
            exit(OK);
        }
    }
}

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
    char *auxVec = vector;
    int tam = strlen(auxVec);
    for (int i = 0; i < tam; i++)
    {
        if((isalpha(*auxVec)))
            printf("%c ", *auxVec);
        auxVec++;
    }
    printf("\n");
}

void help(string exe)
{
    cout << "Manera de uso: " << exe << " [Puerto] " << endl;
    cout << "Ejemplo: " << exe << " " << 8080 << endl;
    cout << "Ejecuta el servidor del Ahorcado." << endl;
    cout << "Este juego consiste en adivinar una palabra, ingresando letras y desbloquendo las mismas para completar la palabra. Teniendo asi una cantidad limitada de intentos." << endl;
    cout << "Ejecute la instancia de cliente y visualice las letras ingresadas desde el servidor" << endl;
}

string archivoEntrada = "archivo.txt";

int getRandomWord(char txt[FIL][COL])
{
    char linea[COL];
    int cantLineas = 0;

    FILE *pTxt = fopen("archivo.txt", "rt");

    if (!fopen)
    {
        printf("Error al abrir archivo");
        exit(ERROR);
    }

    while (fgets(linea, sizeof(linea), pTxt))
    {
        strcpy(txt[cantLineas], linea);
        cantLineas++;
    }

    srand(time(NULL));

    int random = rand() % cantLineas;

    fclose(pTxt);

    return random;
}

int notGuessedWord(char *middleDashVec)
{
    return strchr(middleDashVec, '-') != NULL;
}

void restartServer(int sig)
{
    attemps = 0;
}

int main(int argc, char **argv)
{
    signal(SIGUSR1, closeServer);
    signal(SIGINT, SIG_IGN);
    signal(SIGPIPE, restartServer);

    if (argc > 1)
    {

        if (argc == 2)
        {
            if ((strcmp(argv[1], "--help") == 0) || ((strcmp(argv[1], "-h")) == 0))
            {
                help(argv[0]);
                return OK;
            }
        }

        string result = executeCommand("ps -fea | grep ./server.exe | wc -l");

        if (stoi(result) > 3)
        {
            cout << "Ya existe un servidor." << endl;
            return NOT_OK;
        }

        // char txt[FIL][COL];

        // char wordToGuess[TAM];
        // char middleDashVec[TAM];
        // char actualWord;
        // char playedLetters[TAM];

        //int fd, fd2, 
        int sizeClient, port;
        port = atoi(argv[1]);

        struct sockaddr_in server;
        struct sockaddr_in client;

        server.sin_family = AF_INET;
        server.sin_port = htons(port);
        server.sin_addr.s_addr = INADDR_ANY;
        bzero(&(server.sin_zero), 8);

        if ((fd = socket(AF_INET, SOCK_STREAM, 0)) < OK)
        {
            perror("Error en apertura de socket");
            exit(ERROR);
        }

        if (bind(fd, (struct sockaddr *)&server, sizeof(struct sockaddr)) == ERROR)
        {
            printf("error en funcion bind().\n");
            exit(ERROR);
        }

        if (listen(fd, 5) == ERROR)
        {
            printf("error en funcion listen().\n");
            exit(ERROR);
        }

        int entry = 1;

        while (entry)
        {

            attemps = 6;
            char txt[FIL][COL];

            char wordToGuess[TAM] = "\0";
            char middleDashVec[TAM] = "\0";
            char actualWord = '\0';
            char playedLetters[TAM] = "\0" ;

            sizeClient = sizeof(struct sockaddr_in);

            socklen_t clientLen = sizeClient;

            if ((fd2 = accept(fd, (struct sockaddr *)&client, &clientLen)) == ERROR)
            {
                printf("error en funcion accept()\n");
                exit(ERROR);
            }

            send(fd2, "Bienvenido al servidor! \n", FIL, 0);

            printf("Inicio de la partida! \n");

            printf("Se ha conectado el cliente! Se inicia el juego del ahorcado.\n");

            strncpy(playedLetters, "", sizeof(playedLetters));

            playedLetters[0] = '\0';

            char *palAux;
            int random = getRandomWord(txt);

            palAux = txt[random];

            strcpy(wordToGuess, palAux);

            int tam = strlen(wordToGuess) - 1;
            int confirmation = 1;
            int confirmationReceived = 0;
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

            if ((send(fd2, middleDashVec, sizeof(middleDashVec), 0)) == ERROR)
            {
                continue;
            }

            if ((returnStatus = recv(fd2, &confirmationReceived, sizeof(confirmationReceived), 0)) == ERROR)
            {
                printf("Error en funcion recv().\n");
                exit(ERROR);
            }

            confirmation = ntohl(confirmationReceived);

            send(fd2, playedLetters, sizeof(playedLetters), 0);

            if ((returnStatus = recv(fd2, &confirmationReceived, sizeof(confirmationReceived), 0)) == ERROR)
            {
                printf("Error en funcion recv().\n");
                exit(ERROR);
            }

            confirmation = ntohl(confirmationReceived);

            send(fd2, wordToGuess, sizeof(wordToGuess), 0);

            if ((returnStatus = recv(fd2, &confirmationReceived, sizeof(confirmationReceived), 0)) == ERROR)
            {
                printf("Error en funcion recv().\n");
                exit(ERROR);
            }

            confirmation = ntohl(confirmationReceived);

            char character;
            char beforeCharacter;
            int total = 0;
            int numbytes = 0;

            while (attemps > 0 && notGuessedWord(middleDashVec))
            {
                if ((returnStatus = recv(fd2, &confirmationReceived, sizeof(confirmationReceived), 0)) == ERROR)
                {
                    printf("Error en funcion recv().\n");
                    exit(ERROR);
                }

                confirmation = ntohl(confirmationReceived);

                sendConfirmation = htonl(confirmation);

                send(fd2, &sendConfirmation, sizeof(sendConfirmation), 0);

                if ((numbytes = recv(fd2, &character, sizeof(char), 0)) == ERROR)
                {
                    printf("Error en funcion recv().\n");
                    exit(ERROR);
                }

                sendConfirmation = htonl(confirmation);
                send(fd2, &sendConfirmation, sizeof(sendConfirmation), 0);

                beforeCharacter = character;

                if (strchr(wordToGuess, character) != NULL && strchr(playedLetters, character) == NULL)
                {

                    char *startOfWord = wordToGuess;
                    char *startOfMiddleDashVec = middleDashVec;

                    char *pWordToGuess = startOfWord;
                    char *pMiddleDashVec = startOfMiddleDashVec;

                    int length = strlen(wordToGuess);

                    for (int i = 0; i < length; i++)
                    {
                        if (toupper(character) == toupper(*pWordToGuess))
                        {
                            *pMiddleDashVec = toupper(character);
                        }

                        pMiddleDashVec++;
                        pWordToGuess++;
                    }

                    pWordToGuess = startOfWord;
                    pMiddleDashVec = startOfMiddleDashVec;
                }

                else if (strchr(wordToGuess, character) == NULL)
                {
                    attemps--;
                }

                beforeCharacter = toupper(character);
                mi_strcat(playedLetters, &beforeCharacter);

                send(fd2, middleDashVec, sizeof(middleDashVec), 0);

                if ((returnStatus = recv(fd2, &confirmationReceived, sizeof(confirmationReceived), 0)) == ERROR)
                {
                    printf("Error en funcion recv().\n");
                    exit(ERROR);
                }

                confirmation = ntohl(confirmationReceived);

                if(attemps != 0){
                    printf("Las letras que jugaste son: \n");
                    showVec(playedLetters);
                }

                send(fd2, playedLetters, sizeof(playedLetters), 0);

                if ((returnStatus = recv(fd2, &confirmationReceived, sizeof(confirmationReceived), 0)) == ERROR)
                {
                    printf("Error en funcion recv().\n");
                    exit(ERROR);
                }

                confirmation = ntohl(confirmationReceived);
            }

            printf("Partida finalizada!\n");
        }
    }
    else
    {
        printf("Parametros invalidos. Para más ayuda ejecute: %s -h o --help\n", argv[0]);
    }

    return OK;
}