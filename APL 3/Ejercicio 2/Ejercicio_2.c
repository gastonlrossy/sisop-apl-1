#include <stdio.h>
#include <stdlib.h>
#include <semaphore.h>
#include <pthread.h>
#include <time.h>

static void* iteracion(void * datosNecesarios);
int validarDatos(int N, int paralelismo);
void procesoPrincipal(int n, int p);


int main()
{
    int n, para;
    char entrada = '3';
    do{
        printf("\nIngrese una opcion...");
        printf("\n-h para ingresar a la ayuda...");
        printf("\n-1 para ejecutar el programa principal...");
	printf("\n-0 para salir...");
        printf("\n\nOpcion elegida...\n");
        fflush(stdin);
        scanf("%c", &entrada);

        if(entrada == '1'){
        do {
            printf("\nIngrese la cantidad de iteraciones que desea: ");
            scanf("%d", &n);
            printf("\nIngrese el paralelismo deseado: ");
            scanf("%d",&para);
        }while (validarDatos(n, para) == 0);

        printf("\nElegiste %d iteraciones y %d threads ...", n, para);
        procesoPrincipal(n, para);
        }

        if(entrada == 'h')
            printf("El objetivo de este proceso es....");
	
	printf("\n\n\nPresione una tecla para continuar...");
        getc(stdin);
    }while(entrada != '0');

}


typedef double(*funcIte)(int, int);


typedef struct{
    int nro;
     double tiempo;
}t_iteraciones;

typedef struct {
    int nHilo;
    int* M;
    int iteraciones, itePropia;
    t_iteraciones *ciclo;
    double tiempoFinal;
    sem_t *semaforoPropio, *semaforoSiguiente;
}t_datos;



int validarDatos(int N, int paralelismo){
    if(N < 0 || paralelismo < 0)
        return 0;

    return 1;
}


static void* iteracion(void * datosNecesarios){

    t_datos* d = (t_datos*) datosNecesarios;

    while(*(d->M) <= 9){
        sem_wait(d->semaforoPropio);
        clock_t tiempo_ini , tiempo_fin;
        tiempo_ini =clock();

        if(*(d->M) > 9){
            sem_post(d->semaforoSiguiente);
            return NULL;
        }



        int m = *(d->M);

        for(int i = 0; i < d->iteraciones; i++){
            m = m * ( *(d->M) );
            m += m;
            m = m / *(d->M);
        }
        tiempo_fin = clock();

        d->ciclo[d->itePropia].nro = *(d->M);
        *(d->M)+=1;

        sem_post(d->semaforoSiguiente);


        double tiempo = (double) (tiempo_fin-tiempo_ini) / CLOCKS_PER_SEC;


        d->ciclo[d->itePropia].tiempo = tiempo;
        d->itePropia++;
        d->tiempoFinal+=tiempo;
    }
    sem_post(d->semaforoSiguiente);
    return NULL;
}

void procesoPrincipal(int n, int p){
    pthread_t vecThreads[p];
    sem_t vecSemaforos[p];
    t_datos datos[p];
    int M = 2;

    sem_init(&vecSemaforos[0], 1, 1);

    for(int a = 1; a < p; a++)
        sem_init(&vecSemaforos[a], 1, 0);

    for( int x = 0; x < p; x++){
        datos[x].M = &M;
        datos[x].nHilo = x;
        datos[x].iteraciones = n;
        datos[x].tiempoFinal = 0;
        datos[x].itePropia = 0;
        datos[x].ciclo = (t_iteraciones*) malloc(sizeof(t_iteraciones)* (8/p));
        datos[x].semaforoPropio = &vecSemaforos[x];
        datos[x].semaforoSiguiente = x + 1 >= p ? &vecSemaforos[0] : &vecSemaforos[x+1];

        if(pthread_create(&vecThreads[x], NULL, iteracion, &datos[x]) != 0)
            exit(1);
    }

    for( int k = 0; k < p; k++)
        pthread_join(vecThreads[k], NULL);



    for( int x = 0; x < p; x++){
        printf("\n\n\nInformacion del Thread Numero: %d", x+1);
        printf("\n El Thread ejecuto %d vez/ces el ciclo", datos[x].itePropia);
        for( int k = 0; k < datos[x].itePropia; k++)
            printf("\nPara el numero %d, el Thread tardo: %.8lf", datos[x].ciclo[k].nro, datos[x].ciclo[k].tiempo);

        printf("\nTiempo total: %.8lf", datos[x].tiempoFinal);
    }

}
