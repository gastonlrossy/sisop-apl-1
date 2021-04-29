#!/bin/bash


#####                   APL N1                  #####
#####		        Ejercicio 1 - Entrega       #####
#####				APL1-ejercicio1.sh          #####

#####			GRUPO Nº2                       #####
#####       Tebes, Leandro - 40.227.531	        #####
#####       Rossy, Gaston L. - 40.137.778       #####
#####	      Zella, Ezequiel - 41.915.248      #####
#####       Cencic, Maximiliano - 41.292.382    #####
#####       Bonvehi, Sebastian - 40.538.404     ##### 

# Si la sintaxis esperada del script es invalida, 
#  se imprime por stdout la salida esperada.
validarSintaxis() {
    echo "Error. La sintaxis esperada del script es la siguiente:"
    echo $0 "<directorio> <cantidad>"
    echo "En lugar de eso, se recibio: "
    echo $0 $*
    exit
}

# Si el param 1 es un directorio invalido, 
#  se imprime por stdout que no lo es.
validarDirectorio() {
    echo "Error. $1 no es un directorio valido."
    exit
}

# En esta funcion se realizan las validaciones
#  pertinentes para el script.
validarParams() {
    if test $1 -ne 2 ; then
        validarSintaxis $2 $3 $4 $5 $6
    fi

    if [[ ! -d $2 ]]; then
        validarDirectorio $2
    fi
    
    if ! [[ $3 =~ ^[0-9]$ ]]; then
        validarNumero $3
    fi
}

# Si el param 2 no es un numero, se  
#  imprime por stdout que no lo es.
validarNumero() {
    echo "Error. $1 no es un numero valido."
    exit
}

validarParams $# $1 $2 $3 $4 $5
LIST=$(ls -d $1*/)
ITEMS=()
for d in $LIST; do            # En este for agregan a la lista ITEMS los directorios con la cantidad de directorios al comienzo
    ITEM="`ls $d | wc -l`-$d" # con el formato <cantidad de directorios>-<directorio>
    ITEMS+=($ITEM)
done

IFS=$'\n'

sorted=($(sort -rV -t '-' -k 1 <<<${ITEMS[*]})) # Se ordena la lista de reversa
CANDIDATES="${sorted[*]:0:$2}" # Se mete en CANDIDATES la lista previamente ordenada desde el comienzo hasta el numero ingresado como parametro 2
unset IFS
echo "La lista de directorios ordenada de forma descendente es: " # COMPLETAR
printf "%s\n" "$(cut -d '-' -f 2 <<<${CANDIDATES[*]})" # Se imprimen por stdout los items en CANDIDATES eliminando la primera parte, osea lo previo al guion.


# 1. ¿Cuál es el objetivo de este script?, ¿Qué parámetros recibe? 

# Analiza los directorios en la raíz del script y en base al 1er parámetro lista las carpetas cuyo nombre sea el directorio del 1er parámetro + cualquier continuación. Esta lista se ordena según los archivos que tengan dentro de mayor a menor. Luego, en base al 2do parámetro, se delimita la cantidad de carpetas a mostrar en la salida final.

# Recibe dos parámetros, el primero debe ser un directorio válido y el 2do debe ser un número.

# 2. Comentar el código según la funcionalidad (no describa los comandos, indique la lógica) 

# 3. Completar los “echo” con el mensaje correspondiente.

# 4. ¿Qué nombre debería tener las funciones funcA, funcB, funcC, funcD? 

# validarSintaxis, validarDirectorio, validarParams, validarNumero respectivamente.

# 5. ¿Agregaría alguna otra validación a los parámetros?, ¿existe algún error en el script? 

# Se agregó una validación para el 2do parámetro que tiene que ser un número válido.
# Se agregó el parámetro al llamar la funcB (ahora “validarDirectorio”).
# Al final de cada función que hacía un echo para comentar sobre el error, se seguía ejecutando el script en lugar de hacer un exit.

# 6. ¿Qué información brinda la variable $#? ¿Qué otras variables similares conocen? 
# Explíquelas. 

# $#: Cantidad de parámetros enviados

# $1 ... $n: Parámetros enviados

# $@ o $*: La lista de todos los parámetros

# $$: El Pid del proceso actual

# $!: El Pid del último proceso hijo ejecutado en segundo plano

# $?: Valor de ejecución del último comando

# 7. Explique las diferencias entre los distintos tipos de comillas que se pueden utilizar en Shell scripts. 
# Comillas Dobles ("): Se utilizan para definir textos y "se expanden". Es decir, las variables dentro de las comillas dobles son interpretadas (y no se muestran como el nombre de la variable).
# Comillas Simples ('): Se utilizan para definir textos y "no se expanden". Es decir, las variables dentro de las comillas simples se muestran como el nombre de la variable (y no se muestran como su valor).
# Acento Grave (`): Se utilizan para indicar a bash que interprete el comando que hay entre los acentos.


# 8. ¿Qué sucede si se ejecuta el script sin ningún parámetro?

# El flujo del script termina en la funcA (ahora “validarSintaxis”) que imprime la salida esperada del script.


