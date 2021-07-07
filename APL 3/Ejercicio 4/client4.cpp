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
#include <thread>
#include <string.h>
#include <sys/types.h>
#include <netdb.h>
#include <vector>
#include <string>
#include <signal.h>

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

void help(string exe)
{
  cout << "Modo de uso: " << exe << endl;
  cout << "Ejecuta el cliente del juego Ahorcado." << endl;
  cout << "Este juego consiste en adivinar una palabra, ingresando letras y desbloquendo las mismas para completar la palabra. Teniendo asi una cantidad limitada de intentos." << endl;
  cout << "Una vez en el juego elegir una letra a buscar la coincidencias." << endl;
}

void draw(int i){
  switch (i)
  {

  case 0:
    cout << "                    " << endl;
    cout << "                    " << endl;
    cout << "   |------------    " << endl;
    cout << "   |           |    " << endl;
    cout << "   |           |    " << endl;
    cout << "   |           0    " << endl;
    cout << "   |          /|\\  " << endl;
    cout << "   |         / | \\ " << endl;
    cout << "   |           |    " << endl;
    cout << "   |          / \\  " << endl;
    cout << "   |         /   \\ " << endl;
    cout << "   |                " << endl;
    cout << "   |                " << endl;
    cout << "-------             " << endl;
    break;

  case 1:
    cout << "                    " << endl;
    cout << "                    " << endl;
    cout << "   |------------    " << endl;
    cout << "   |           |    " << endl;
    cout << "   |           |    " << endl;
    cout << "   |           0    " << endl;
    cout << "   |          /|\\  " << endl;
    cout << "   |         / | \\ " << endl;
    cout << "   |           |    " << endl;
    cout << "   |            \\  " << endl;
    cout << "   |             \\ " << endl;
    cout << "   |                " << endl;
    cout << "   |                " << endl;
    cout << "-------             " << endl;
    break;

  case 2:
    cout << "                    " << endl;
    cout << "                    " << endl;
    cout << "   |------------    " << endl;
    cout << "   |           |    " << endl;
    cout << "   |           |    " << endl;
    cout << "   |           0    " << endl;
    cout << "   |          /|\\  " << endl;
    cout << "   |         / | \\ " << endl;
    cout << "   |           |    " << endl;
    cout << "   |                " << endl;
    cout << "   |                " << endl;
    cout << "   |                " << endl;
    cout << "   |                " << endl;
    cout << "-------             " << endl;
    break;

  case 3:
    cout << "                    " << endl;
    cout << "                    " << endl;
    cout << "   |------------    " << endl;
    cout << "   |           |    " << endl;
    cout << "   |           |    " << endl;
    cout << "   |           0    " << endl;
    cout << "   |           |\\  " << endl;
    cout << "   |           | \\ " << endl;
    cout << "   |           |    " << endl;
    cout << "   |                " << endl;
    cout << "   |                " << endl;
    cout << "   |                " << endl;
    cout << "   |                " << endl;
    cout << "-------             " << endl;
    break;

  case 4:
    cout << "                   " << endl;
    cout << "                   " << endl;
    cout << "   |------------   " << endl;
    cout << "   |           |   " << endl;
    cout << "   |           |   " << endl;
    cout << "   |           0   " << endl;
    cout << "   |           |   " << endl;
    cout << "   |           |   " << endl;
    cout << "   |           |   " << endl;
    cout << "   |               " << endl;
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
    cout << "   |           0   " << endl;
    cout << "   |               " << endl;
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
    cout << "   |               " << endl;
    cout << "-------            " << endl;
    break;
  }
}

void killClient(int signal)
{
  if (signal == SIGINT || signal == SIGUSR1)
  {
    int semValue;
    sem_getvalue(sem, &semValue);
    while (semValue < 6)
    {
      sem_post(sem);
      sem_getvalue(sem, &semValue);
    }

    sem_unlink("clients");
    sem_unlink("mutex");
    sem_unlink("interaction");
    
    if (signal == SIGINT)
      cout << "Abandonaste la partida!" << endl;
    int client;
    sem_getvalue(cln, &client);
    if (client == 1){
      sem_wait(cln);
    }
    sem_close(cln);
    sem_close(mtx);
    exit(0);
  }
}

void showVector(char *v)
{
  for (int i = 0; i < strlen(v); i++)
  {
    cout << v[i] << " ";
  }
  cout << endl;
}

int main(int argc, char *argv[])
{

  if (argc > 1)
  {
    if ((strcmp(argv[1], "--help") == 0) || ((strcmp(argv[1], "-h")) == 0))
      help(argv[0]);
    else
      cout << "Parametros invalidos. Para mas ayuda ejecute: " << argv[0] << " -h o --help" << endl;

    return NOT_OK;
  }

  signal(SIGINT, killClient);
  int band = 0;
  int cont = 0;
  int semValue = 0;
  int clients;
  int mutex;


  sem = sem_open("interaction", O_RDWR);
  mtx = sem_open("mutex", O_RDWR);
  cln = sem_open("clients", O_RDWR);

  if (sem == NULL || cln == NULL)
  {
    cout << "No hay ningun servidor abierto." << endl;
    return NOT_OK;
  }

  int fd = shm_open("sharedMem", O_RDWR, 0600);
  ftruncate(fd, sizeof(struct shmType));
  struct shmType *data = (struct shmType *)mmap(NULL, sizeof(struct shmType), PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
  close(fd);

  sem_getvalue(sem, &semValue);
  sem_getvalue(cln, &clients);
  sem_getvalue(mtx, &mutex);

  if (clients > 0)
  {
    cout << "Ya hay un cliente jugando." << endl;
    return NOT_OK;
  }
  sem_post(cln);

  bool first = true;

  cout << "Valores semaforos: - Servidor: " << semValue << endl;
  cout << "Valor semaforo: - Cliente: " << clients << endl;

  while (semValue > 1)
  {
    while (data->intentos == -1){}

    cont = 0;

    sem_getvalue(sem, &semValue);
    sem_getvalue(mtx, &mutex);

    if (semValue == 5 && mutex == 1)
    {

      if (first == true)
      {
        draw(data->intentos);
        first = false;
      }

      char* aux=data->guiones;
      showVector(aux);
      bool jugo = false;

      do
      {
        cout << "Ingrese una letra para adivinar la palabra " << endl;
        if (jugo == true)
          cout << "La letra "
               << "'" << data->letraActual << "'"
               << " ya fue jugada. Ingrese otra" << endl;
        jugo = false;
        cin >> data->letraActual;
        int c = 0;
        while (c < strlen(data->letrasJugadas) && jugo == false)
        {
          if (toupper(data->letraActual) == toupper(data->letrasJugadas[c])){
            jugo = true;
          }
          c++;
        }
      } while (!isalpha(data->letraActual) || jugo == true);

      sem_getvalue(sem, &semValue);
      sem_wait(sem);
      sem_getvalue(sem, &semValue);
    }
    else if (semValue == 3 && mutex == 1)
    {

      draw(data->intentos);
      cout << "No acertaste ninguna letra" << endl;
      cout << "Te quedan " << data->intentos << " intentos" << endl;
      sem_wait(mtx);
      sem_post(sem);
      sem_post(sem);
      sem_post(mtx);
    }
    if (semValue == 2 && mutex == 1)
    {
      char *auxVecguiones = data->guiones;
      showVector(auxVecguiones);
      sleep(2);
      sem_wait(sem);
    }
  }

  if (data->intentos > 0)
  {
    cout << "Ganaste!" << endl;
  }
  else
  {
    draw(data->intentos);
    cout << "Perdiste!" << endl;
  }

  cout << "La palabra a adivinar era: " << data->palabra << endl;

  killClient(SIGUSR1);

  return OK;
}
