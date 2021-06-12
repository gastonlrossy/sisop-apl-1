/****                   APL N°3                   *****/
/****             Ejercicio 1 - Entrega           *****/
/****                Ejercicio 1.sh               *****/

/****                   GRUPO Nº2                 *****/
/****           Tebes, Leandro - 40.227.531       *****/
/****         Rossy, Gaston L. - 40.137.778       *****/
/****          Zella, Ezequiel - 41.915.248       *****/
/****      Cencic, Maximiliano - 41.292.382       *****/
/****       Bonvehi, Sebastian - 40.538.404       *****/

#include <cstring>
#include <unistd.h>
#include <sys/wait.h>
#include <iostream>

using namespace std;

void help()
{
    cout << "Programa que genera un árbol de procesos de N generaciones." << endl;
    cout << "Siendo N un valor entero mayor a 1 que determinará los niveles que tendrá el árbol" << endl;
    cout << "Cada proceso deberá generar dos procesos hijos por cada generación." << endl;
    cout << "Ejemplo de ejecución: " << endl;
    cout << "./ejercicioExec 3" << endl;
    cout << "Esta ejecucion daria como resultado un proceso padre con 2 hijos, y a la vez, esos dos hijos con sus hijos otros 2 hijos." << endl;
}

int main(int argc, char *argv[])
{
    if (argc != 2)
    {
        if (strcmp(argv[1], "-h") == 0 || strcmp(argv[1], "--help") == 0)
        {
            help();
            return 0;
        }
        cout << "El número de argumentos es incorrecto" << endl;
        cout << "Para pedir ayuda, ejecute -h o --help." << endl;
        return -1;
    }

    for (int i = 0; i < strlen(argv[1]); i++)
    {
        if (!isdigit(argv[1][i]))
        {
            cout << "Parametro invalido." << endl;
            cout << "Para pedir ayuda, ejecute -h o --help." << endl;
            return -1;
        }
    }


    int pidbase = 0;
    if(pidbase==0)
        pidbase= getpid();
    string arbol="pstree -Gnp ";
    arbol += to_string(pidbase);
    arbol += "|grep Ejercicio1Exe";
    int nivel = atoi(argv[1]);
    int nivelrecib = nivel;
    if (nivel <= 1)
    {
        cout << "El nivel debe ser mayor a 1." << endl;
        cout << "Para pedir ayuda, ejecute -h o --help." << endl;
        return -1;
    }

    nivel--;
    int hijos = 0;
    int proceso;
    while (nivel > 0 && hijos < 2)
    {
        proceso = fork();
        switch (proceso)
        {
        case -1:
            cout << "Error en la creación del proceso" << endl;
            exit(-1);
        case 0:
            cout << "PID: " << getpid();
            cout << "  PPID: " << getppid() << endl;
            nivel--;
            hijos = 0;
            break;
        default:
            cout << "PID: " << getpid() << endl;
            hijos++;
        }
    }
    if(nivel<nivelrecib-1)
        kill(getpid(), SIGSTOP);

    system(arbol.c_str());
}



// #include <cstring>
// #include <unistd.h>
// #include <sys/wait.h>
// #include <stdio.h>
// #include <vector>
// #include <stdlib.h>
// #include <ctype.h>

// using namespace std;

// vector<int> info;

// void mostrar();
// void ayuda();
// void error();
// int crear_procesos(int n);
// int validaciones(int argc, char *argv[]);

// int main(int argc, char *argv[])
// {

// 	int numero;
// 	numero = validaciones(argc, argv);
// 	if (numero < 0)
// 	{
// 		return (-1);
// 	}
// 	else
// 	{
// 		crear_procesos(numero);
// 		return (0);
// 	}
// }
// int crear_procesos(int n)
// {
// 	int i, j,band;
// 	info.push_back(1);		   //El primer elemento del array serÃ¡ el nivel
// 	info.push_back(getppid()); //El pid de la terminal
// 	info.push_back(getpid());  //El pid del main

// 	if (n > 1)
// 	{
// 		for (i = 0; i < 3; i++)
// 		{

// 			if (!fork())
// 			{
// 				info.at(0)++;
// 				info.push_back(getpid());
// 				mostrar();
// 				if (n > 2)
// 				{
// 					if (i == 0)
// 					{
// 						band=0;
// 						for (j = 0; j < 2 && band ==0; j++)
// 						{
// 							if (!fork() )
// 							{
// 								band=1;
// 								info.at(0)++;
// 								info.push_back(getpid());
// 								mostrar();
// 								if (j == 1 && n>3)
// 								{
// 									if (!fork())
// 									{
// 										info.at(0)++;
// 										info.push_back(getpid());
// 										mostrar();
// 									}else
// 									{
// 										wait(NULL);
// 										return 0;
// 									}
									
// 								}
// 							}
// 						}
// 					} 

// 					if (i == 1)
// 					{
// 						if (!fork())
// 						{
// 							info.at(0)++;
// 							info.push_back(getpid());
// 							mostrar();
// 							if (n > 3)
// 							{
// 								if (!fork())
// 								{
// 									info.at(0)++;
// 									info.push_back(getpid());
// 									mostrar();
// 									if (n > 4)
// 									{
// 										if (!fork())
// 										{
// 											info.at(0)++;
// 											info.push_back(getpid());
// 											mostrar();
// 										}
// 										else
// 										{
// 											wait(NULL);
// 											return (0);
// 										}
// 									}
// 								}
// 								else
// 								{
// 									wait(NULL);
// 									return (0);
// 								}
// 							}
// 						}
// 						else
// 						{
// 							wait(NULL);
// 							return (0);
// 						}
// 					}
// 				}
// 				kill(getpid(), SIGSTOP);
// 				return 0;
// 			}
// 		}
// 	}
// 	mostrar();

// 	getchar();

// 	killpg(getpgrp(), SIGCONT);

// 	wait(NULL);
// 	wait(NULL);
// 	wait(NULL);

// 	return 0;
// }

// void mostrar()
// {
// 	printf("Nivel: %d -", info.at(0));
// 	printf("PID: %d - Predecesores:", info.back());

// 	for (unsigned int i = 1; i < info.size() - 1; i++)
// 	{
// 		printf(" [ %d ] ", info.at(i));
// 	}
// 	printf("\n");
// };

// int validaciones(int argc, char *argv[])
// {
// 	int n = 5;
// 	if (argc <= 1)
// 	{
// 		return n;
// 	}
// 	else if (argc > 2)
// 	{
// 		printf("Ingreso mas de un parametro, por favor revise la ayuda(-h,-help,-?)\n");
// 		exit(-1);
// 	}
// 	else if (strcmp(argv[1], "-h") == 0 || strcmp(argv[1], "-help") == 0 || strcmp(argv[1], "-?") == 0)
// 	{
// 		ayuda();
// 		return (-1);
// 	}
// 	else if (atoi(argv[1]) < 0)
// 	{
// 		printf("Ingreso un numero negativo, por favor revise la ayuda(-h,-help,-?)\n");
// 		return (-1);
// 	}
// 	else if (!isdigit(*argv[1]))
// 	{
// 		printf("Lo que ingreso no es un numero valido, por favor revise la ayuda(-h,-help,-?)\n");
// 		return (-1);
// 	}
// 	if (atoi(argv[1]) > 0 && atoi(argv[1]) <= 5)
// 	{
// 		n = atoi(argv[1]);
// 	}
// 	else
// 	{
// 		printf("Lo que ingreso no es un numero valido, por favor revise la ayuda (-h,-help,-?)\n");
// 		return (-1);
// 	}

// 	return n;
// }

// void ayuda()
// {
// 	printf("Ingrese un numero menor o igual a cinco para visualizar el arbol de procesos\n");
// 	printf("Ejemplo de ejecucion:\n");
// 	printf("Paso 1: 'make'\n");
// 	printf("Paso 2: './ejericio.o 3'\n");
// }