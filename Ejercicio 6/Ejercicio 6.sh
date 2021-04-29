#!/bin/bash

#####                   APL Nº1                 #####
#####		    Ejercicio 6 - Entrega           #####
#####				Ejercicio 6.sh			    #####

#####				    GRUPO N°2		        #####
#####       Tebes, Leandro - 40.227.531         #####
#####       Rossy, Gaston L. - 40.137.778       #####
#####       Zella, Ezequiel - 41.915.248        #####
#####       Cencic, Maximiliano - 41.292.382    #####
#####       Bonvehi, Sebastian - 40.538.404     #####

help(){
    echo "El script se forma con estas opciones de ejecución:"
    echo " -l lista los archivos que contiene la papelera de reciclaje, dando la informacion del nombre de archivo y la ubicación donde se encuentra"
    echo " -r [archivo] recupera el archivo pasado por parámetro a la ubicacion donde estaba."
    echo " -e vacia la papelera de reciclaje"
    echo " [archivo] Sin modificadores para que este archivo lo envíe a la papelera de reciclaje."
    echo "Para pedir ayuda es de la siguiente manera: "
    echo "Path/$0 -h"
    echo "Path/$0 -help"
    echo "Path/$0 -?"
    exit
}

validateIfRecycleBinIsEmpty(){
    if [ ! -s "$HOME/Recycle Bin.zip" ]; then
        echo "La papelera se encuentra vacia"
        exit
    fi
}

recover(){
    ORIGINAL_PATH="$1"
    ENTIRE_NAME="${1##*/}"
    cd $HOME
    unzip -p "$HOME/Recycle Bin.zip" "$ORIGINAL_PATH" >"$ENTIRE_NAME"
    DIRNAME="$(dirname -- $ORIGINAL_PATH)"
    mv "$HOME/$ENTIRE_NAME" "/$DIRNAME"
    zip -d "$HOME/Recycle Bin.zip" "$ORIGINAL_PATH"
}

recoverFile(){
    FILE_NAME="$1"
    LIST=$(zipinfo -1 $HOME/Recycle Bin.zip)
    COUNTER=1
    
    MATCHING_FILES=()
    IFS=$'\n'

    for d in $LIST; do
        NAME="${d##*/}"
        if [[ "$NAME" = "$FILE_NAME" ]]; then
            MATCHING_FILES[$(( $COUNTER - 1))]="$d"
            COUNTER=$(($COUNTER + 1))
        fi
    done
    
    unset IFS

    if test "$COUNTER" -eq "1" ; then
        echo "El archivo no se encuentra en la papelera."
        exit
    fi
    
    echo "¿Qué archivo quiere recuperar? "
    read OPTION

    while [ [ $OPTION -gt $(($COUNTER - 1)) ] ]; do
        echo "Opcion invalida. ¿Qué archivo desea recuperar? "
        read OPTION
    done
    
    if test $OPTION -eq 0 ; then
        echo "No se ha recuperado ningún archivo."
        exit
    fi
    
    INDEX=$(($OPTION - 1))
    recover ${MATCHING_FILES[$INDEX]}
}

printFiles(){
    
    validateIfRecycleBinIsEmpty
    
    RECYCLE_BIN="$HOME/Recycle Bin.zip"
    LIST=$(zipinfo -1 $HOME/Recycle Bin.zip)
    IFS=$'\n'

    if  zipinfo -t "$RECYCLE_BIN" > /dev/null ; then
        for d in $LIST; do
            NAME="${d##*/}"
            if [[ ! -z $NAME ]]; then
                printf "%-40s %-70s\n" "$NAME" "/$(dirname -- $d)"
            fi
        done
    else
        echo "La papelera se encuentra vacía"
    fi

    unset IFS
    
}

empty(){
    echo "Ha elegido la opcion de vaciar papelera. Vaciando papelera... "
    zip -d "$HOME/Recycle Bin.zip" \**
}

recover(){
    FILE_NAME="$1"
    validateIfRecycleBinIsEmpty
    recoverFile "$1"
}

validateParameterList(){
    if [ $1 = 1 ] && [ "$2" = '-l' ]; then
        printFiles
    else
        help
    fi
}

validateParameterHelp(){
    if [ $1 = 1 ]; then
        if [ "$2" != '-help' ] && [ "$2" != '-?' ] && [ "$2" != '-h' ]; then
            echo "El script es incorrecto."
        fi
    fi    
}

validateParameterRecover(){
    if [ $1 = 2 ] && [ "$2" = '-r' ]; then
        recover "$3"
    else
        help
    fi
}

resetParameters(){
    shift $(($OPTIND - 1))
}

while getopts "?lr:ehhelp" option; do
    case $option in
        e)
            empty
            exit ;;
        r)
            validateParameterRecover $# "$1" "$2"
            exit ;;
        l)
            validateParameterList $# "$1"
            exit ;;
        *)
            validateParameterHelp $# "$1"
            help ;;
    esac
done

resetParameters

if test $# -eq 0; then
    echo "Es necesario que el script se ejecute con parametros."
    help
fi

INPUT_FILE="$1"
NOMBRE="${INPUT_FILE##*/}"
PATH_BASE=` pwd $INPUT_FILE `

if [[ $INPUT_FILE == *"../"* ]]; then
    COMMAND_AWK="`awk -F"../" '{print NF-1}' <<< "${INPUT_FILE}" `"
    COMMAND_PATH_BASE=` pwd $PATH_BASE `
    
    for (( i=0; i<$COMMAND_AWK ; i++ ))
    do
        INPUT_FILE="${INPUT_FILE##*/}"
        COMMAND_PATH_BASE=` dirname -- $COMMAND_PATH_BASE`
    done
    INPUT_FILE=$COMMAND_PATH_BASE'/'$INPUT_FILE
    elif [[ $INPUT_FILE != *$PATH_BASE* ]]; then
    INPUT_FILE=` pwd $PATH_BASE`/$INPUT_FILE #Con esta linea se obtiene el PATH absoluto
    
fi

zip -m "$HOME/Papelera" $INPUT_FILE