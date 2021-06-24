/****                APL N°3                  *****/
/****		      Ejercicio 1 - Entrega       *****/
/****		         Ejercicio 3.c            *****/

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
#include <dirent.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>

typedef struct
{
    int year;
    char month[15];
    int number;
} billing;

void getMonthlyBilling(int year, char* month, char* result);
void getAnnualBilling(int year, char* result);
void getAverageAnnualTurnover(int year, char* result);
int isValidMonthFile(char* month);

int main()
{
    billing bill;
    int fd1;
    char fifo[50] = "./fifo";
    char varFifo[100];
    char result[500];
    double dresult;

    mkfifo(fifo, 0666);

    fd1 = open(fifo, O_RDONLY);
    read(fd1, &bill, sizeof(bill));
    close(fd1);

    switch (bill.number)
    {
    case 1:
        getMonthlyBilling(bill.year,bill.month,result);
        break;

    case 2:
        getAnnualBilling(bill.year,result);
        break;

    case 3:
        getAverageAnnualTurnover(bill.year,result);
        break;
    default:
        break;
    }

    fd1 = open(fifo, O_WRONLY);

    write(fd1, result, strlen(result) + 1);
    close(fd1);
    return 0;
}

void getMonthlyBilling(int year,char* month,char* dev){
    DIR *dir;
    struct dirent *ent;
    char folder[100] = "";
    char buffer[50];
    sprintf(folder, "%d", year);
    //Abro el directorio.
    if ((dir = opendir(folder)) != NULL) {
    //Itero sobre el directorio
    int fileFound = 0;
    while ((ent = readdir(dir)) != NULL && !fileFound) {
        if(!strcmp(ent->d_name,month)) continue;
        char aux[100] = "";
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
            strcat(dev,"No nos fue posible hacer el calculo. Le sugerimos revisar si los archivos de facturacion existen o si existieron facturaciones en ");
            strcat(dev,month);
            strcat(dev,"\n");
            return;            
        }      
        while (fgets(line, sizeof(line), file)) {
            double number = atof(line);
            result += number;
        }
        fclose(file);
        strcat(dev,"La facturacion correspondiente al mes ");
        strcat(dev,month);
        strcat(dev," del anio ");
        strcat(dev,folder);
        strcat(dev," es $");
        gcvt(result, 15, buffer);
        strcat(dev,buffer);
        strcat(dev,"\n");
    }
    closedir(dir);
    }    
    else {
        strcat(dev,"No nos fue posible hacer el calculo. Revise si los archivos de facturacion existen.\n");
    }
}

void getAnnualBilling(int year,char* dev){
    DIR *dir;
    double result = 0;
    int counter = 0;
    struct dirent *ent;
    char folder[100] = "";
    char buffer[50];
    sprintf(folder, "%d", year);
    //Abro el directorio.
    if ((dir = opendir(folder)) != NULL) {    
    //Itero sobre el directorio
    while ((ent = readdir(dir)) != NULL) {
        if (!isValidMonthFile(ent->d_name)) continue;
        //acá tengo que poner el if para chequear que el archivo que voy a abrir sea válido (sea un mes.txt)
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
            strcat(dev,"No nos fue posible hacer el calculo. Le sugerimos revisar si los archivos de facturacion existen.\n");
            return;
        }      
        while (fgets(line, sizeof(line), file)) {
        double number = atof(line);
        result += number;
        }
        fclose(file);
        counter = 1;
    }
    closedir(dir);
    }
    else {
        strcat(dev,"No nos fue posible hacer el calculo. Le sugerimos revisar si los archivos de facturacion existen.\n");
        return;
    }
    if (counter == 0){
        strcat(dev,"No hubo ningun mes facturado durante el anio ");
        strcat(dev,folder);
        strcat(dev,"\n");
    }
    else{
        strcat(dev,"La facturacion correspondiente al anio ");
        strcat(dev,folder);
        strcat(dev," es $");
        gcvt(result, 15, buffer);
        strcat(dev,buffer);
        strcat(dev,"\n");
    }
}

void getAverageAnnualTurnover(int year,char* dev){
    DIR *dir;
    double result = 0;
    int counter = 0;
    struct dirent *ent;
    char folder[100] = "";
    char buffer[50];
    sprintf(folder, "%d", year);
    //Abro el directorio.
    if ((dir = opendir(folder)) != NULL) {    
    //Itero sobre el directorio
    while ((ent = readdir(dir)) != NULL) {
        if (!isValidMonthFile(ent->d_name)) continue;
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
            strcat(dev,"No nos fue posible hacer el calculo. Le sugerimos revisar si los archivos de facturacion existen.\n");
            return;
        }      
        while (fgets(line, sizeof(line), file)) {
            double number = atof(line);
            result += number;
        }
        counter++;
        fclose(file);
    }
    closedir(dir);
    }
    else {
        strcat(dev,"No nos fue posible hacer el calculo. Le sugerimos revisar si los archivos de facturacion existen.\n");        
        return;
    }
    if (counter == 0){
        strcat(dev,"No hubo ningun mes facturado durante el anio ");
        strcat(dev,folder);
        strcat(dev,"\n");
    }
    else{
        strcat(dev,"La facturacion correspondiente al anio ");
        strcat(dev,folder);
        strcat(dev," es $");
        gcvt(result/counter, 15, buffer);
        strcat(dev, buffer);
        strcat(dev,"\n");
    }
}

int isValidMonthFile(char* month){
    char* aux=month;
    for ( ; *month; ++month) *month = tolower(*month);
    month=aux;
    if(!strcmp(month,"enero.txt") ||
    !strcmp(month,"febrero.txt") ||
    !strcmp(month,"marzo.txt") ||
    !strcmp(month,"abril.txt") ||
    !strcmp(month,"mayo.txt") ||
    !strcmp(month,"junio.txt") ||
    !strcmp(month,"julio.txt") ||
    !strcmp(month,"agosto.txt") ||
    !strcmp(month,"septiembre.txt") ||
    !strcmp(month,"octubre.txt") ||
    !strcmp(month,"noviembre.txt") ||
    !strcmp(month,"diciembre.txt")){
        *month = toupper(*month);
        return 1;
    }
    else
        return 0;
}