#!/bin/bash

#####                   APL Nº1                 #####
#####		    Ejercicio 4 - Entrega           #####
#####			    Ejercicio 4.sh		        #####

#####				  GRUPO N°2		            #####
#####       41.915.248 - Zella, Ezequiel        #####
#####       41.292.382 - Cencic, Maximiliano    #####
#####       40.538.404 - Bonvehi, Sebastian     #####
#####       40.137.778 - Rossy, Gastón Lucas    #####
#####       40.227.531 - Tebes, Leandro  	    #####

KILL_PROCESS=false
BACKGROUND=false

help(){
    echo "El script se usa de la siguiente manera: ""$0"" -d Directorio a monitorear -o Directorio destino "
    echo "Sino se pasa el parametro -o el directorio destino es el directorio a monitorear "
    echo "La ejecucion del script de esta manera ""$0"" -s permite la detencion del demonio "
    echo "No se puede ejecutar el script si se reliza el llamado del parametro '-s' junto con '-d' y '-o'"
    echo "Para llamar a la ayuda: "
    echo "$0 -h"
    echo "$0 -help"
    echo "$0 -?"
    exit
}

validatePathFrom(){
    if [[ ! -d "$PATH_FROM" || ! -r "$PATH_FROM" ]]; then
        echo " ""$PATH_FROM"" No es un directorio valido o no tiene los permisos necesarios"
        help
        exit 1
    fi
}

killProcess(){
    OLD_PID=$( ps ax  | grep "${BASH_SOURCE[0]}" | head -n 1 | awk '{print $1}' )
    eval "$( kill -9 "$OLD_PID" )"
    NEW_PID=$( ps ax  | grep "${BASH_SOURCE[0]}" | head -n 1 | awk '{print $1}' )
    
    until [ "$NEW_PID" == "$OLD_PID" ]
        do
            OLD_PID=$( ps ax  | grep "${BASH_SOURCE[0]}" | head -n 1 | awk '{print $1}' )
            eval "$( kill -9 "$OLD_PID" )"
            NEW_PID=$( ps ax  | grep "${BASH_SOURCE[0]}" | head -n 1 | awk '{print $1}' )
        done
    exit 0
}

validatePathDestiny(){
    if [ ! "$PATH_DESTINY" ]; then
        PATH_DESTINY="$PATH_FROM"
    elif [[ ! -d "$PATH_DESTINY"  || ! -r "$PATH_DESTINY" || ! -w "$PATH_DESTINY" ]]; then
        echo """$PATH_DESTINY"" No es un path valida o no tiene los permisos correspondientes"
        help
        exit 1
    fi
}

validateKillProcess(){
    if [ "$KILL_PROCESS" = true ]; then
        killProcess
    fi
}

createAndMove(){
    if [ "$FILE_EXTENSION" ]; then
        if [ ! -d "$PATH_DESTINY/${FILE_EXTENSION^^}" ]; then
            eval "$( mkdir "$PATH_DESTINY/${FILE_EXTENSION^^}" )"
        fi
        eval "$( mv "$PATH_FROM/$1" "$PATH_DESTINY/${FILE_EXTENSION^^}" )"
    else
        if [ -d "$PATH_DESTINY" ]; then
        eval "$( mv -i "$PATH_FROM/$1" "$PATH_DESTINY" )"
        fi
    fi

}

getExtensionName(){
    CONT_POINT=0
    CONT_POINT=$( echo "$1" | awk -F"." '{ print NF-1 }' )
    FIRST_CHAR="${1:0:1}"

    if [[ "$FIRST_CHAR" == "." && $CONT_POINT == 1 ]]; then
        FILE_EXTENSION=""
    else
        FILE_EXTENSION="${1#*.}"

        while [[ "$FILE_EXTENSION" =~ \. ]]
        do
            FILE_EXTENSION="${FILE_EXTENSION#*.}"
        done
        
        if [[ "$FILE_EXTENSION" == "$1" ]]; then
            FILE_EXTENSION=""
        fi
    fi
}

begin(){
    IFS=$'\n'
    while true
        do
            for FILE in $( ls -a "$PATH_FROM" ); 
                do
                    if [[ "$FILE" != "." && "$FILE" != ".." ]]; then
                        getExtensionName "$FILE"
                        createAndMove "$FILE"
                    fi
                done
        sleep 10        
        done
    unset IFS
}

WORDS_HELP=false

#######    Region de validaciones de parámetros.     #########

if [[ "$@" =~ '-async' ]]; then
    while [ $# -gt 0 ]
        do 
            case "$1" in
                -async)
                BACKGROUND=true 
                ;;
            esac
            case "$1" in
                -d) 
                shift
                PATH_FROM="$1"
                validatePathFrom "$PATH_FROM" 
                ;;
            esac
            case "$2" in
                -d) 
                shift
                PATH_FROM="$2"
                validatePathFrom "$PATH_FROM"
                ;;
            esac
            case "$1" in
                -o) 
                shift
                PATH_DESTINY="$1" 
                validatePathDestiny "$PATH_DESTINY"
                ;;
            esac
            case "$2" in
                -o) 
                shift
                PATH_DESTINY="$2"
                validatePathDestiny "$PATH_DESTINY"
                ;;
            esac
            case "$1" in
                -s)
                shift
                if [ "$1" != "" ]; then
                    echo "Error en parametros."
                    help
                    exit
                fi
                killProcess ;;
            esac
            case "$1" in
                -help)
                shift
                if [[ "$1" != "" || $# > 1 ]]; then
                    echo "Error en parametros."
                    help
                    exit
                fi
                help
                ;;
            esac
            case "$1" in
                -h)
                shift
                if [ "$1" != "" ]; then
                    echo "Error en parametros."
                    help
                    exit
                fi
                help
                ;;
            esac
            shift
    done
else
    if [[ "$#" == 1 && ( "$@" =~ '-help'  ||  "$@" =~ '-?'  || "$@" =~ '-h' ) ]]; then
        help
        exit 0
    fi

    while getopts d:o:s opt; do
        case $opt in
            o) PATH_DESTINY="$OPTARG"
                validatePathDestiny "$PATH_DESTINY"
                ;;
            d) PATH_FROM="$OPTARG"
                validatePathFrom "$PATH_FROM"
                ;;
            s)
                if [[ "$OPTARG" != "" || $# > 1 ]]; then
                    echo "Error en parametros."
                    help
                    exit
                fi
            killProcess 
            ;;
            *) help ;;
        esac 
    done

    if [[ $# > 4 || $# < 1 || ! "$PATH_FROM" ]] ; then
        echo "Error en parametros."
        help
        exit
    fi

    if [[ "$PATH_FROM" && ! "$@" =~ '-o' && $# > 2 ]] ; then
        echo "Error en parametros."
        help
        exit
    fi

fi

if [[ "$@" =~ '-s' || "$@" =~ '-help' || "$@" =~ '-?' ]]; then
    WORDS_HELP=true
fi

if [[ $# > 1 && "$WORDS_HELP" = true ]]; then
    echo "Error en parametros"
    help
    exit
fi

if [[ $BACKGROUND == false && $KILL_PROCESS == false ]]; then
    nohup "./${BASH_SOURCE[0]}" "-async" "-d" "$PATH_FROM" "-o" "$PATH_DESTINY" &
    exit 0
fi

validateKillProcess
validatePathFrom
validatePathDestiny
begin