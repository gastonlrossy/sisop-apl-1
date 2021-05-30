#!/bin/bash

#####                   APL Nº1                 #####
#####		    Ejercicio 6 - Entrega           #####
#####				Ejercicio 6.sh			    #####

#####				  GRUPO N°2 		        #####
#####       Tebes, Leandro - 40.227.531         #####
#####       Rossy, Gaston L. - 40.137.778       #####
#####       Zella, Ezequiel - 41.915.248        #####
#####       Cencic, Maximiliano - 41.292.382    #####
#####       Bonvehi, Sebastian - 40.538.404     #####

help(){
    echo "La funcionalidad del script es la de emular una papelera de reciclaje, pudiendo asi eliminar archivos y luego en un futuro poder recuperalos."
    echo "El script se forma con estas opciones de ejecucion:"
    echo " -l lista los archivos que contiene la papelera de reciclaje, dando la informacion del nombre de archivo y la ubicacion donde se encuentra"
    echo " -r [archivo] recupera el archivo pasado por parametro a la ubicacion donde estaba."
    echo " -e vacia la papelera de reciclaje"
    echo " [archivo] Sin modificadores para que este archivo lo envie a la papelera de reciclaje."
    echo "Para pedir ayuda es de la siguiente manera: "
    echo "Path/$0 -h"
    echo "Path/$0 -help"
    echo "Path/$0 -?"
    exit
}

validateIfRecycleBinIsEmpty(){
    if [ ! -s "$HOME/Recycle_Bin.zip" ]; then
        echo "La papelera se encuentra vacia"
        exit
    fi
    if ! zipinfo -t "$HOME/Recycle_Bin.zip" > /dev/null ; then
        echo "La papelera esta vacia"
        exit
    fi
}

recoverF(){
    ORIGINAL_PATH="$1"
    ENTIRE_NAME=$(basename "$1")
    cd "$HOME" || exit
    unzip -p "$HOME/Recycle_Bin.zip" "$ORIGINAL_PATH" > "$ENTIRE_NAME"
    DIRNAME="$(dirname -- "$ORIGINAL_PATH")"
    LAST_PART=${NAME//*'_'}
    NEWNAME=${NAME%"_$LAST_PART"}
    mv "$HOME/$ENTIRE_NAME" "$NEWNAME" > /dev/null
    
    if [[ ! -e "/$DIRNAME/$NEWNAME" ]]; then
        mv "$HOME/$NEWNAME" "/$DIRNAME" > /dev/null
    else
        num=1
        while [[ -e "/$DIRNAME/$NEWNAME ($num)" ]]; do
                (( num++ ))
        done
        mv "$HOME/$NEWNAME" "/$DIRNAME/$NEWNAME ($num)" > /dev/null
        echo "Tu archivo fue recuperado bajo el nombre $NEWNAME ($num) debido a que ya existía un archivo con el mismo nombre en el directorio"
        echo "/$DIRNAME"
    fi

    zip -d "$HOME/Recycle_Bin.zip" "$ORIGINAL_PATH" > /dev/null
    echo "Archivo recuperado exitosamente."
}

recoverFile(){
    FILE_NAME="$1"
    LIST=$(zipinfo -1 """$HOME""/Recycle_Bin.zip")
    COUNTER=1
    MATCHING_FILES=()

    IFS=$'\n'
    for d in $LIST; do
        NAME=$(basename "$d")
        if [[ "$NAME" = "$FILE_NAME" ]]; then
            MATCHING_FILES[$(( "$COUNTER" - 1))]="$d"
            echo $COUNTER ' - '"$NAME"" /$(dirname -- "$d")"
            COUNTER=$(("$COUNTER" + 1))
        elif [[ "$NAME" = "$FILE_NAME"* ]]; then
            LAST_PART=${NAME//*'_'}
            if [[ "${FILE_NAME}_${LAST_PART}" == "$NAME" ]]; then
                MATCHING_FILES[$(( "$COUNTER" - 1))]="$d"
                echo $COUNTER ' - '"$FILE_NAME" "borrado el $LAST_PART /$(dirname -- "$d")"
                COUNTER=$(("$COUNTER" + 1))
            fi
        fi
            
    done

    unset IFS

    if test "$COUNTER" -eq "1" ; then
        echo "El archivo no se encuentra en la papelera."
        exit
    fi
    if test "$COUNTER" -gt "2" ; then 
        echo "¿Que archivo quiere recuperar? "
        read -r OPCION
    else
        INDEX=$(("$OPCION" - 1))
        recoverF "${MATCHING_FILES[$INDEX]}"
        exit
    fi

    while ! [[ $OPCION =~ [0-9]{1}  ]]; do
        echo "Opcion invalida. ¿Que archivo desea recuperar? "
        read -r OPCION
    done
    
    if test "$OPCION" -eq 0 ; then
        echo "No se ha recuperado ningun archivo."
        exit
    fi
    
    INDEX=$(("$OPCION" - 1))
    FILE="${MATCHING_FILES[$INDEX]}"
    if [ -z "$FILE" ]; then
        echo "Escribio un numero que no estaba dentro de las opciones. Vuelva a intentarlo ejecutando el script nuevamente."
        exit
    fi
    recoverF "$FILE"
}

printFiles(){
    
    validateIfRecycleBinIsEmpty
    
    RECYCLE_BIN="$HOME/Recycle_Bin.zip"
    LIST=$(zipinfo -1 "$RECYCLE_BIN")
    IFS=$'\n'

    if  zipinfo -t "$RECYCLE_BIN" > /dev/null ; then
        for d in $LIST; do
            NAME=$(basename "$d")
            if [[ ! -z "$NAME" ]]; then
                LAST_PART=${NAME//*'_'}
                PRINT=${NAME%"_$LAST_PART"}
                printf "%-40s %-70s\n" "$PRINT borrado el $LAST_PART"  "/$(dirname -- "$d")"
            fi
        done
    else
        echo "La papelera se encuentra vacía"
    fi

    unset IFS
    
}

empty(){
    echo "Ha elegido la opcion de vaciar papelera. Vaciando papelera... "
    zip -d "$HOME/Recycle_Bin.zip" \** > /dev/null
    echo "Papelera vacia."
}

recover(){
    FILE_NAME="$1"
    validateIfRecycleBinIsEmpty
    recoverFile "$1"
}

validateParameterList(){
    if [ "$1" = 1 ] && [ "$2" = '-l' ]; then
        printFiles
    else
        help
    fi
}

validateParameterHelp(){
    if [ "$1" = 1 ]; then
        if [ "$2" != '-help' ] && [ "$2" != '-?' ] && [ "$2" != '-h' ]; then
            echo "El script es incorrecto."
            exit
        fi
    fi
}

validateParameterRecover(){
    if [ "$1" = 2 ] && [ "$2" = '-r' ]; then
        recover "$3"
    else
        help
    fi
}

resetParameters(){
    shift $(("$OPTIND" - 1))
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

if [ ! -f "$1" ]; then
    echo "El archivo que se intenta eliminar no existe en la ruta brindada."
    exit
fi

INPUT_FILE="$1"
_NAME=$(basename "$INPUT_FILE")
PATH_BASE=$PWD

if [[ $INPUT_FILE == *"../"* ]]; then
    AWK="$(awk -F"../" '{print NF-1}' <<< "${INPUT_FILE}" )"
    for (( i=0; i<"$AWK" ; i++ ))
    do
        PATH_BASE=$( dirname -- "$PATH_BASE")
    done
    INPUT_FILE=${INPUT_FILE##*/}
    INPUT_FILE=$PATH_BASE'/'"$INPUT_FILE"
elif [[ $INPUT_FILE != *$PATH_BASE* ]]; then
    INPUT_FILE=$PWD/"$INPUT_FILE"
fi

PATH_BASE=$(dirname "$INPUT_FILE")
DATE=$(date "+%Y-%m-%d %H:%M:%S" )
if [ "$_NAME" != "${_NAME%.*}" ]; then
EXTENSION=".${_NAME##*.}"
else
EXTENSION=""
fi
REPEATED=$(dirname "$INPUT_FILE")'/'${_NAME%.*}$EXTENSION'_'$DATE''
mv "$INPUT_FILE" "$REPEATED" > /dev/null

zip -m "$HOME/Recycle_Bin.zip" "$REPEATED" > /dev/null

echo "Archivo eliminado exitosamente."