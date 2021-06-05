#!/bin/bash




validarSintaxis() {
    echo "Error. La sintaxis esperada del script es la siguiente:"
    echo "$0" "<directorio> <cantidad>"
    echo "En lugar de eso, se recibio: "
    echo "$0" "$*"
    exit
}

# Si el param 1 es un directorio invalido, 
#  se imprime por stdout que no lo es.
validarDirectorio() {
    echo "Error." "$1" "no es un directorio valido."
    exit
}

# En esta funcion se realizan las validaciones
#  pertinentes para el script.
validarParams() {
    #Validamos que la cantidad de parámetros que nos enviaron sea igual a 2.
    if test "$1" -ne 2 ; then
        validarSintaxis "$2" "$3" "$4" "$5" "$6"
    fi

    #Validamos que el parámetro 1 sea un directorio.
    if [[ ! -d "$2" ]]; then
        validarDirectorio "$2"
    fi

    #Validamos que el parámetro 2 sea un número.
    if ! [[ "$3" =~ ^[0-9]+$ ]]; then
        validarNumero "$3"
    fi
}

# Si el param 2 no es un numero, se  
#  imprime por stdout que no lo es.
validarNumero() {
    echo "Error. $1 no es un numero valido."
    exit
}

validarParams "$#" "$1" "$2" "$3" "$4" "$5"

#Listamos los directorios
LIST=$(ls -d "$1"*/)

#Creamos un array vacio.
ITEMS=()
IFS=$'\n'
#Agregamos a la lista ITEMS los directorios con la cantidad de directorios al comienzo.
for d in ${LIST}; do
    ITEM="$(ls "$d" | wc -l)-'$d'"  # con el formato <cantidad de directorios>-<directorio>    
    ITEMS+=("$ITEM")
done
IFS=$'\n'

# Se ordena la lista de reversa
sorted=("$(sort -rV -t '-' -k 1 <<< "${ITEMS[*]}")")

# Se mete en CANDIDATES la lista previamente ordenada desde el comienzo hasta el numero ingresado 
# en el segundo parametro.
CANDIDATES="${sorted[*]:0:$2}"

#echo "candidatos: ${CANDIDATES[*]}"
#exit 0

unset IFS
echo "La lista de directorios ordenada de forma descendente es: " # COMPLETAR
echo
# Se imprimen por stdout los directorios de la variable CANDIDATES.
printf "%s\n" "$(cut -d '-' -f 2- <<< "${CANDIDATES[*]}")"


# 1.a ¿Cuál es el objetivo de este script?

# Imprime por consola los directorios subyacentes al directorio enviado en el primer parámetro del script,
# ordenando la impresión por la cantidad de archivos y carpetas que contiene cada directorio de la lista
# de mayor a menor.
# La cantidad de directorios impresos es limitada por el segundo parámetro del script.

# 1.b ¿Qué parámetros recibe? 

# Recibe dos parámetros, el primero debe ser un directorio válido y el 2do debe ser un número.

# 2. Comentar el código según la funcionalidad (no describa los comandos, indique la lógica) 

# 3. Completar los “echo” con el mensaje correspondiente.

# 4. ¿Qué nombre debería tener las funciones funcA, funcB, funcC, funcD? 

# validarSintaxis, validarDirectorio, validarParams, validarNumero respectivamente.

# 5. ¿Agregaría alguna otra validación a los parámetros?, ¿existe algún error en el script? 

# Se agregó una validación para el 2do parámetro que tiene que ser un número válido.
# Se agregó el parámetro al llamar la funcB (ahora “validarDirectorio”).

# Errores:

# No se llamaba la funcA en ningún lado.
# Cuando se realiza la iteracion, no se estaba teniendo en cuenta a nombre de directorios con espacios.
# Cuando se imprimian los directorios, no se estaba teniendo en cuenta si un directorio poseía un "-".
# Si los parámetros enviados no eran correctos, no existía un exit que terminara el script.

# 6. ¿Qué información brinda la variable $#? ¿Qué otras variables similares conocen? 
# Explíquelas. 

# $#: Cantidad de parámetros enviados

# $1 ... $n: Contenido del parámetro n.

# $@ o $*: La lista de todos los parámetros.

# $$: El Pid del proceso actual.

# $!: El Pid del último proceso hijo ejecutado en segundo plano.

# $?: Valor de ejecución del último comando

# 7. Explique las diferencias entre los distintos tipos de comillas que se pueden utilizar en Shell scripts. 
# Comillas Dobles ("): Se utilizan para definir textos y "se expanden". Es decir, las variables dentro de las comillas dobles son interpretadas (y no se muestran como el nombre de la variable).
# Comillas Simples ('): Se utilizan para definir textos y "no se expanden". Es decir, las variables dentro de las comillas simples se muestran como el nombre de la variable (y no se muestran como su valor).
# Acento Grave (`): Se utilizan para indicar a bash que interprete el comando que hay entre los acentos.


# 8. ¿Qué sucede si se ejecuta el script sin ningún parámetro?

# El flujo del script termina en la funcA (ahora “validarSintaxis”) que imprime la salida esperada del script.


