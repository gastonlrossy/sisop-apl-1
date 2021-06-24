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
    cout << "El objetivo de este programa es la creacion de un arbol binario de N niveles siendo N un valor entero mayor a 1" << endl;
    cout << "Forma de Ejecucion: " << endl;
    cout << "\t./ejercicioExec <N>" << endl;
    cout << "Ejemplo de ejecución: " << endl;
    cout << "\t./ejercicioExec 2" << endl;
    cout << "\tEsta ejecucion resultaria en un proceso padre con 2 hijos." << endl;
}

int main(int argc, char *argv[])
{
    if (argc != 2)
    {
        cout << "Error: Cantidad de parametros invalida. \nEjecute -h o --help si necesita ayuda. " << endl;
        return -1;
    }
    if (strcmp(argv[1], "-h") == 0 || strcmp(argv[1], "--help") == 0)
    {
        help();
        return 0;
    }

    for (int i = 0; i < strlen(argv[1]); i++)
    {
        if (!isdigit(argv[1][i]))
        {
            cout << "Error: El parametro enviado debe ser un numero mayor o igual a 1. \nEjecute -h o --help si necesita ayuda.  " << endl;
            return -1;
        }
    }

    int pidbase = getpid();
    string arbol;
    int nivel = atoi(argv[1]);
    int nivelrecib = nivel;
    if(nivel<=5)
    arbol = "pstree -Gnp ";
    else
    arbol = "pstree -np ";
    arbol += to_string(pidbase);
    arbol += "|grep Ejercicio1Exe";
    
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
            nivel--;
            hijos = 0;
            break;
        default:
            hijos++;
        }
    }
    if (nivel < nivelrecib - 1)
        kill(getpid(), SIGSTOP);

    system(arbol.c_str());

    char termina;
    cout << "\nPresione cualquier tecla para finalizar..." << endl;
    scanf("%c", &termina);
}