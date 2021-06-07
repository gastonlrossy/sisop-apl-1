/****                APL N°3                  *****/
/****		      Ejercicio 1 - Entrega       *****/
/****		         Ejercicio 1.sh           *****/

/****		             GRUPO Nº2            *****/
/****       Tebes, Leandro - 40.227.531       *****/
/****       Rossy, Gaston L. - 40.137.778     *****/
/****	      Zella, Ezequiel - 41.915.248    *****/
/****       Cencic, Maximiliano - 41.292.382  *****/
/****       Bonvehi, Sebastian - 40.538.404   *****/

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <sys/types.h>
#include <dirent.h>

void help();
void askMonth(char* month);
void swap(char *x, char *y);
int getMonthlyBilling(int year, char* month);
int getAnnualBilling(int year);
int getAverageAnnualTurnover(int year);
int askYear();
int testMonth(char* month);
int getNumber(const char *prompt);
char* itoa(int value, char* buffer, int base);
char* reverse(char *buffer, int i, int j);


int main()
{
    int option = 0;
    printf ("Hola! Bienvenido al menu de facturacion de la empresa APL\n");
    printf("¿Que desea hacer?\n");
    do{
        option = getNumber("1 ----> Facturacion mensual\n2 ----> Facturacion anual\n3 ----> Facturacion media anual\n4 ----> Salir\n5 ----> Ayuda\nIngrese una opcion:\n");
    }
    while(option != 1 && option != 2
        && option != 3 && option != 4 && option != 5);

    switch (option)
    {
        case 1:{
            int year = askYear();
            char month[100];
            askMonth(month);
            getMonthlyBilling(year, month);
        }
        break;
        case 2:{
            int year = askYear();
            getAnnualBilling(year);
        }
        break;
        case 3:{
            int year = askYear();
            getAverageAnnualTurnover(year);
        }
        break;
        case 4:{
            printf("Se cerrara el programa...\n");
            return 0;
        }
        break;
        default:
            help();
        break;
    }
    return 0;
}

void help(){
    printf("Usted ha ingresado a la ayuda del programa\n");
    printf("Este programa le brinda informacion sobre la facturacion de su empresa\n");
    printf("Cuenta con un menu de 5 opciones.\n");
    printf("Para acceder a cada opcion, es necesario ingresar el numero de la opcion que se quiere utilizar.\n");
    printf("La opcion 1 le brinda un detalle de la facturacion mensual.\n");
    printf("La misma le solicitara 2 datos mas, el anio y el mes, \npara poder ir a la base de datos a buscar la informacion y hacer el calculo correspondiente.\n");
    printf("La opcion 2 le brinda un detalle de la facturacion anual.\n");
    printf("La misma le solicitara un dato mas, el anio, \npara poder ir a la base de datos a buscar la informacion y hacer el calculo correspondiente.\n");
    printf("La opcion 3 le brindara un detalle de la facturacion media anual\n");
    printf("La misma le solicitara un dato mas, el anio,\npara poder ir a la base de datos a buscar la informacion y hacer el calculo correspondiente.\n");
    printf("La opcion 4 cierra el programa.\n");
}

int askYear(){
    int year;
    do{    
        year = getNumber("Por favor, indiquenos el anio.\n");
    }
    while(year < 1990 || year > 2021);
    return year;
}

void askMonth(char* month){
    do{
        printf("Indiquenos el mes.\n");
        fgets(month, sizeof(month), stdin);
    }
    while(!testMonth(month));
}

int testMonth(char* month){
    char* aux=month;
    for ( ; *month; ++month) *month = tolower(*month);
    month=aux;
    if(!strcmp(month,"enero") ||
    !strcmp(month,"febrero") ||
    !strcmp(month,"marzo") ||
    !strcmp(month,"abril") ||
    !strcmp(month,"mayo") ||
    !strcmp(month,"junio") ||
    !strcmp(month,"julio") ||
    !strcmp(month,"agosto") ||
    !strcmp(month,"septiembre") ||
    !strcmp(month,"octubre") ||
    !strcmp(month,"noviembre") ||
    !strcmp(month,"diciembre")){
        return 1;
    }
    else
        return 0;
}

int getMonthlyBilling(int year,char* month){
    DIR *dir;
    struct dirent *ent;
    char folder[100] = "";
    itoa(year, folder, 10);
    //Abro el directorio.
    if ((dir = opendir (folder)) != NULL) {
    //Itero sobre el directorio
    int fileFound = 0;
    while ((ent = readdir (dir)) != NULL && !fileFound) {
        if(!strcmp(ent->d_name,month)) continue;
        char* aux;
        char line[100] = "";
        double result = 0;
        fileFound = 1;
        //"2021"
        strcpy(aux,folder);
        //"2021/"
        strcat(aux, "/");
        //"2021/febrero.txt"
        strcat(aux, ent->d_name);
        FILE* file = fopen(aux, "r");
        if (!file) {
            printf("No nos fue posible hacer el calculo. Le sugerimos revisar si los archivos de facturacion existen o si existieron facturaciones en %s.\n",month);
            return 0;
        }      
        while (fgets(line, sizeof(line), file)) {
            double number = atof(line);
            result += number;
        }
        fclose(file);
        printf("La facturacion correspondiente al mes %s del anio %d es $%.2f\n", month, year, result);      
    }
    closedir (dir);
    }    
    else {
        printf("No nos fue posible hacer el calculo. Revise si los archivos de facturacion existen.\n");
        return 0;
    }
    return 1;
}

int getAnnualBilling(int year){
    DIR *dir;
    double result = 0;
    int counter = 0;
    struct dirent *ent;
    char folder[100] = "";
    itoa(year, folder, 10);
    //Abro el directorio.
    if ((dir = opendir (folder)) != NULL) {    
    //Itero sobre el directorio
    while ((ent = readdir (dir)) != NULL) {
        char aux[100] = "";
        char line[100] = "";
        //"2021"
        strcpy(aux,folder);
        //"2021/"
        strcat(aux, "/");
        //"2021/febrero.txt"
        strcat(aux, ent->d_name);
        FILE* file = fopen(aux, "r");
        if (!file) {
            printf("No nos fue posible hacer el calculo. Le sugerimos revisar si los archivos de facturacion existen.\n");
            return 0;
        }      
        while (fgets(line, sizeof(line), file)) {
        double number = atof(line);
        result += number;
        }
        fclose(file);
        counter = 1;
    }
    closedir (dir);
    }    
    else {
        printf("No nos fue posible hacer el calculo. Revise si los archivos de facturacion existen.\n");
        return 0;
    }
    if (counter == 0)
        printf("No hubo ningun mes facturado durante el anio %d\n",year);
    else
        printf("La facturacion correspondiente al anio %d es $%.2f\n", year, result);

    return 1;
}

int getAverageAnnualTurnover(int year){
    DIR *dir;
    double result = 0;
    int counter = 0;
    struct dirent *ent;
    char folder[100] = "";
    itoa(year, folder, 10);
    //Abro el directorio.
    if ((dir = opendir (folder)) != NULL) {    
    //Itero sobre el directorio
    while ((ent = readdir (dir)) != NULL) {
        char aux[100] = "";
        char line[100] = "";
        //"2021"
        strcpy(aux,folder);
        //"2021/"
        strcat(aux, "/");
        //"2021/febrero.txt"
        strcat(aux, ent->d_name);
        FILE* file = fopen(aux, "r");
        if (!file) {
            printf("No nos fue posible hacer el calculo. Le sugerimos revisar si los archivos de facturacion existen.\n");
            return 0;
        }      
        while (fgets(line, sizeof(line), file)) {
            double number = atof(line);
            result += number;
        }
        counter++;
        fclose(file);
    }
    closedir (dir);
    }    
    else {
        printf("No nos fue posible hacer el calculo. Revise si los archivos de facturacion existen.\n");
        return 0;
    }
    if (counter == 0){
        printf("No hubo ningun mes facturado durante el anio %d\n",year);
        return 1;
    }
    else{
        printf("La facturacion correspondiente al anio %d es $%.2f\n", year, result/counter);
        return 1;
}
}

char* itoa(int value, char* buffer, int base)
{
    if (base < 2 || base > 32) {
        return buffer;
    }

    int n = abs(value);

    int i = 0;
    while (n)
    {
        int r = n % base;

        if (r >= 10) {
            buffer[i++] = 65 + (r - 10);
        }
        else {
            buffer[i++] = 48 + r;
        }

        n = n / base;
    }

    if (i == 0) {
        buffer[i++] = '0';
    }

    if (value < 0 && base == 10) {
        buffer[i++] = '-';
    }

    buffer[i] = '\0';

    return reverse(buffer, 0, i - 1);
}

char* reverse(char *buffer, int i, int j)
{
    while (i < j) {
        swap(&buffer[i++], &buffer[j--]);
    }

    return buffer;
}

void swap(char *x, char *y) {
    char t = *x; *x = *y; *y = t;
}

int getNumber(const char *prompt)
{
    int value;
    char line[4096];
    while (fputs(prompt, stdout) != EOF &&
            fgets(line, sizeof(line), stdin) != 0)
    {
        if (sscanf(line, "%d", &value) == 1){
            return value;
        }
    }
}