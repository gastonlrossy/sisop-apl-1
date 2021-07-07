/*
#####                   APL N3                  #####
#####		        Ejercicio 4 - Entrega           #####
#####				        server4.cpp                 #####

#####			            GRUPO Nº2                 #####
#####       Tebes, Leandro - 40.227.531         #####
#####       Rossy, Gaston L. - 40.137.778       #####
#####	      Zella, Ezequiel - 41.915.248        #####
#####       Cencic, Maximiliano - 41.292.382    #####
#####       Bonvehi, Sebastian - 40.538.404     ##### 
*/

#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <iostream>
#include <sys/mman.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <semaphore.h>
#include <time.h>
#include <ctime>
#include <sys/time.h>
#include <thread>
#include <string.h>
#include <sys/types.h>
#include <netdb.h>
#include <vector>
#include <string>
#include <sstream>
#include <signal.h>
#include <fstream>

#define OK 0
#define NOT_OK 1

using namespace std;

struct shmType
{
  char palabra[50];
  char guiones[50];
  char letrasJugadas[28];
  char letraActual;
  int intentos;
};

sem_t *sem;
sem_t *cln;
sem_t *mtx;

bool serverActive = true;
string fileInput = "archivo.txt";

void killServer(int signal)
{
  if (SIGUSR1 == signal)
  {

    int clients;
    sem_getvalue(cln, &clients);

    if (clients > 0)
    {
      printf("No pudo finalizarse el servidor!\nHay un cliente en ejecucion!!\n");
      return;
    }

    serverActive = false;
    int semValue;
    sem_getvalue(sem, &semValue);
    while (semValue > 5)
    {
      sem_wait(sem);
      sem_getvalue(sem, &semValue);
    }

    sem_close(sem);
    sem_close(cln);
    sem_close(mtx);

    sem_unlink("clients");
    sem_unlink("interaction");
    sem_unlink("mutex");
    shm_unlink("sharedMem");

    printf("\nServidor finalizado!\n");

    exit(0);
  }
}

void help(string exe)
{
  cout << "Manera de uso: " << exe << endl;
  cout << "Ejecuta el servidor del Ahorcado." << endl;
  cout << "Este juego consiste en adivinar una palabra, ingresando letras y desbloquendo las mismas para completar la palabra. Teniendo asi una cantidad limitada de intentos." << endl;
  cout << "Ejecute la instancia de cliente y visualice las letras ingresadas desde el servidor" << endl;

}

string getRandomWord()
{
  int random = 0;
  ifstream infile(fileInput);
  string line;
  vector<string> vec;

  while (getline(infile, line))
  {
    istringstream iss(line);
    vec.push_back(line);
  }
  srand(time(NULL));
  random = rand() % vec.size();

  return vec[random];
}

char *insertPlayedWord(const char *l, char *v)
{
  char letrita = toupper(*l);
  strcat(v, &letrita);

  return v;
}

void showVector(char *v)
{
  for (int i = 0; i < strlen(v); i++)
  {
    cout << v[i] << " ";
  }
  cout << endl;
}

bool isAValidFile(const char *fileName)
{
  std::ifstream infile(fileName);
  return infile.good();
}

std::string run(const char *cmd)
{
  std::array<char, 128> buff;
  std::string r;
  std::unique_ptr<FILE, decltype(&pclose)> pipe(popen(cmd, "r"), pclose);
  if (!pipe)
  {
    throw std::runtime_error("popen() fallo!!");
  }
  while (fgets(buff.data(), buff.size(), pipe.get()) != nullptr)
  {
    r += buff.data();
  }
  return r;
}

void cleanVec(char *v)
{
  *v = '\0';
}

int main(int argc, char *argv[])
{
  if (!(argc == 1 || argc == 2))
  {
    cout << "Parametros invalidos. Para mas ayuda ejecute: " << argv[0] << " -h o --help" << endl;

    return NOT_OK;
  }

  if (argc == 2)
  {
    if ((strcmp(argv[1], "--help") == 0) || ((strcmp(argv[1], "-h")) == 0))
    {
      help(argv[0]);
      return OK;
    }

    if (isAValidFile(argv[1]))
    {
      fileInput = argv[1];
    }
    else
    {
      cout << "Error en primer parametro. El parametro " << "'" << argv[1] << "'"
          << " no es un archivo valido" << endl;
      return NOT_OK;
    }
  }

  string result = run("ps -fea | grep ./server4.exe | wc -l");
  int lenghtResult;
  stringstream stream;
  stream << result;
  stream >> lenghtResult;

  if (lenghtResult > 3)
  {
    cout << "Ya hay un servidor corriendo actualmente." << endl;
    return NOT_OK;
  }

  signal(SIGINT, SIG_IGN);
  signal(SIGUSR1, killServer);

  sem_close(sem);
  sem_close(cln);
  sem_close(mtx);
  sem_unlink("clients");
  sem_unlink("interaction");
  sem_unlink("mutex");
  shm_unlink("sharedMem");

  int semValue = 0;
  int cont = 0;
  int mutex;

  int sM = shm_open("sharedMem", O_CREAT | O_RDWR, 0600);
  ftruncate(sM, sizeof(struct shmType));
  struct shmType *data = (struct shmType *)mmap(NULL, sizeof(struct shmType), PROT_READ | PROT_WRITE, MAP_SHARED, sM, 0);
  close(sM);

  cout << "Server inicializado!" << endl;

  while (serverActive == 1)
  {

    sem = sem_open("interaction", O_CREAT, 0600, 5);
    cln = sem_open("clients", O_CREAT, 0600, 0);
    mtx = sem_open("mutex", O_CREAT, 0600, 1);

    int client;

    sem_getvalue(sem, &semValue);
    sem_getvalue(mtx, &mutex);

    data->intentos = -1;

    char *auxPalabra = data->palabra;
    char *auxGuiones = data->guiones;
    int lengthWord;

    while (semValue > 0 && semValue < 6)
    {
      sem_getvalue(sem, &semValue);
      sem_getvalue(cln, &client);
      sem_getvalue(mtx, &mutex);
      if (client == 1 && data->intentos == -1 && mutex == 1)
      {
        printf("Se ha conectado el cliente! Se inicia el juego del ahorcado.\n");
        string wordFromFile = getRandomWord();
        char *auxPalabraAdivinada = (data->palabra);
        auxPalabraAdivinada = const_cast<char *>(wordFromFile.c_str());
        strcpy(data->palabra, auxPalabraAdivinada);
        lengthWord = strlen(data->palabra);
        int c;
        char *aux = data->guiones;

        for (c = 0; c < lengthWord; c++)
        {
          *aux = '_';
          aux++;
        }
        *aux = '\0';
        data->intentos = 6;
      }

      if (semValue == 4 && mutex == 1)
      {
        char *auxPlayedLetters = data->letrasJugadas;
        sem_getvalue(sem, &semValue);
        auxPlayedLetters = insertPlayedWord(&data->letraActual, data->letrasJugadas);
        printf("Las letras que jugaste son: \n");
        showVector(auxPlayedLetters);
        int matches = 0;

        for (int i = 0; i < lengthWord; i++)
        {
          if (toupper(data->letraActual) == toupper(auxPalabra[i]))
          {
            matches++;
            auxGuiones[i] = toupper(data->letraActual);
          }
        }

        if (matches > 0)
        {
          int i = 0;
          while (i < strlen(data->guiones) && auxGuiones[i] != '_')
          {
            i++;
          }
          sem_wait(mtx);
          if (auxGuiones[i] != '_')
          {
            sem_wait(sem);
            sem_wait(sem);
          }
          else {
            sem_post(sem);
          }

          sem_post(mtx);
        }
        else
        {
          sem_wait(mtx);
          data->intentos--;
          if (data->intentos == 0)
          {
            sem_wait(sem);
          }
          sem_wait(sem);
          sem_post(mtx);
        }
      }
      else if (semValue == 1 && mutex == 1)
      {
        sem_wait(sem);
      }
    }

    while (client != 0)
    {
      sem_getvalue(cln, &client);
    }

    if (client == 0)
    {
      if (semValue == 0)
      {
        sem_post(sem);
        sem_post(sem);
        sem_post(sem);
        sem_post(sem);
        sem_post(sem);
      }
    }
    printf("Partida finalizada!\n");
    while (semValue > 5)
    {
      sem_wait(sem);
      sem_getvalue(sem, &semValue);
    }
    cleanVec(data->letrasJugadas);
  }
  return OK;
}
