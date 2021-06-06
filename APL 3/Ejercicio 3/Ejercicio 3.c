/****                APL N°3                  *****/
/****		      Ejercicio 1 - Entrega           *****/
/****		         Ejercicio 1.sh               *****/

/****		             GRUPO Nº2                *****/
/****       Tebes, Leandro - 40.227.531       *****/
/****       Rossy, Gaston L. - 40.137.778     *****/
/****	      Zella, Ezequiel - 41.915.248      *****/
/****       Cencic, Maximiliano - 41.292.382  *****/
/****       Bonvehi, Sebastian - 40.538.404   *****/

// Si la sintaxis esperada del script es invalida, 
//  se imprime por stdout la salida esperada.

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>

void help();
int getMonthlyBilling(char* month, int year);
int getAnnualBilling(int year);
int getAverageAnnualTurnover(int year);
int askYear();
void askMonth(char* month);
void printOptions();
int testMonth(char* month);

int main()
{
  int option = 0;
  printf ("Hola! Bienvenido al menu de facturacion de la empresa APL\n");
  printf("¿Que desea hacer?\n");
  do{
    printOptions();
    fflush(stdin);
    scanf("%d",&option);
  }
  while(!isdigit(option) || option > 5 && option < 1);
  switch (option)
  {
  case 1:{
    askYear();
    askMonth();
  }
  break;
  case 2:{

  }
  break;
  case 3:{

  }
  break;
  case 4:{

  }
  break;
  default:
    help();
    break;
  }
  return 0;
}

void printOptions(){
  printf("1 ----> Facturacion mensual\n");
  printf("2 ----> Facturacion anual\n");
  printf("3 ----> Facturacion media anual\n");
  printf("4 ----> Salir\n");
  printf("5 ----> Ayuda\n");
  printf("Ingrese una opcion:\n");
}

void help(){
  printf("Usted ha ingresado a la ayuda del programa\n");
  printf("Este programa le brinda informacion sobre la facturacion de su empresa\n");
  printf("Cuenta con un menu de 4 opciones.\n");
  printf("Para acceder a cada opcion, es necesario ingresar el numero de la opcion que se quiere utilizar.\n");
  printf("La opcion 1 le brinda un detalle de la facturacion mensual.\n");
  printf("La misma le solicitara 2 datos mas, el anio y el mes, \npara poder ir a la base de datos a buscar la informacion y hacer el calculo.\n");
  printf("La opcion 2 le brinda un detalle de la facturacion anual.\n");
  printf("La misma le solicitara un dato mas, el anio, \npara poder ir a la base de datos a buscar la informacion y hacer el calculo.\n");
  printf("La opcion 3 le brindara un detalle de la facturacion media anual\n");
  printf("La misma le solicitara un dato mas, el anio,\npara poder ir a la base de datos a buscar la informacion y hacer el calculo.\n");
}

int getAnnualBilling(int year){
  DIR *dir;
  double result = 0;
  struct dirent *ent;
  char* folder
  itoa(year, folder, 10);
  //Abro el directorio.
  if ((dir = opendir (folder)) != NULL) {    
    //Itero sobre el directorio
    while ((ent = readdir (dir)) != NULL) {
      char* aux;
      char line[100] = "";
      //"2021"
      strcpy(aux,folder);
      //"2021/"
      strcat(aux, "/");
      //"2021/febrero"
      strcat(aux, dir->d_name);
      //"2021/febrero.txt"
      strcat(aux, ".txt");
      FILE* file = fopen(aux, "r");
      if (!file) {
         printf("No nos fue posible hacer el calculo. Le sugerimos revisar si los archivos de facturacion existen.");
         return 0;
      }      
      while (fgets(line, sizeof(line), file)) {
        double number = atof(line);
        result += number;
      }
      fclose(file);
    }
    closedir (dir);
  }    
  else {
    printf("No nos fue posible hacer el calculo. Revise si los archivos de facturacion existen.");
    return 0;
  }
  printf("La facturacion correspondiente al anio %d es %f", folder, result);
  return 1;
}

int getAverageAnnualTurnover(int year){
  DIR *dir;
  double result = 0;
  struct dirent *ent;
  char* folder
  itoa(year, folder, 10);
  //Abro el directorio.
  if ((dir = opendir (folder)) != NULL) {    
    //Itero sobre el directorio
    while ((ent = readdir (dir)) != NULL) {
      char* aux;
      char line[100] = "";
      //"2021"
      strcpy(aux,folder);
      //"2021/"
      strcat(aux, "/");
      //"2021/febrero"
      strcat(aux, dir->d_name);
      //"2021/febrero.txt"
      strcat(aux, ".txt");
      FILE* file = fopen(aux, "r");
      if (!file) {
         printf("No nos fue posible hacer el calculo. Le sugerimos revisar si los archivos de facturacion existen.");
         return 0;
      }      
      while (fgets(line, sizeof(line), file)) {
        double number = atof(line);
        result += number;
      }
      fclose(file);
    }
    closedir (dir);
  }    
  else {
    printf("No nos fue posible hacer el calculo. Revise si los archivos de facturacion existen.");
    return 0;
  }
  printf("La facturacion correspondiente al anio %d es %f", folder, result/12);
  return 1;
}

int askYear(){
  int year;
  do{
    fflush(stdin);
    scanf("%d",&year);    
  }
  while(!isdigit(year) || year > 1990 && year < 2022);
  return year;
}

void askMonth(char* month){
  do{
    fflush(stdin);
    fgets(month, sizeof(month), stdin);
  }
  while(testMonth(month));
}

int testMonth(char* month){
  for ( ; *month; ++month) *month = tolower(*month);
  switch (month)
  {
    case "enero":
    case "febrero":
    case "marzo":
    case "abril":
    case "mayo":
    case "junio":
    case "julio":
    case "agosto":
    case "septiembre":
    case "octubre":
    case "noviembre":
    case "diciembre":
      return 1;
    default:
      return 0;
  }
}

int getMonthlyBilling(int year,char* month){
  DIR *dir;
  struct dirent *ent;
  char* folder
  itoa(year, folder, 10);
  //Abro el directorio.
  if ((dir = opendir (folder)) != NULL) {    
    //Itero sobre el directorio
    int fileFound = 0;
    while ((ent = readdir (dir)) != NULL && !fileFound) {
      if(!strcmp(ent->d_name,month) continue;
      
      char* aux;
      char line[100] = "";
      double result = 0;
      fileFound = 1;
      //"2021"
      strcpy(aux,folder);
      //"2021/"
      strcat(aux, "/");
      //"2021/febrero"
      strcat(aux, dir->d_name);
      //"2021/febrero.txt"
      strcat(aux, ".txt");
      FILE* file = fopen(aux, "r");
      if (!file) {
         printf("No nos fue posible hacer el calculo. Le sugerimos revisar si los archivos de facturacion existen.");
         return 0;
      }      
      while (fgets(line, sizeof(line), file)) {
        double number = atof(line);
        result += number;
      }
      fclose(file);
      printf("La facturacion correspondiente al mes %s del anio %d es %f", month, folder, result);      
    }
    closedir (dir);
  }    
  else {
    printf("No nos fue posible hacer el calculo. Revise si los archivos de facturacion existen.");
    return 0;
  }
  return 1;
}