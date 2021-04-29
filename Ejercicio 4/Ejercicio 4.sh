#!/bin/bash




# ------------------------------------------- Validaciones y mètodos ------------------------------------------- #

MATAR_PROCESO=false
SEG_PLANO=false

#Metodo de ayuda.
help(){
    echo "El script se usa de la siguiente manera: ""$0"" -d [Directorio a monitorear] -o [Directorio destino] (este ùltimo es opcional) "
    echo "Sino se pasa el parametro -o el directorio destino es el directorio a monitorear "
    echo "La ejecucion del script de esta manera ""$0"" -s permite la detencion del demonio "
    echo "No se puede ejecutar el script si se reliza el llamado del parametro '-s' junto con '-d' y '-o'"
    echo "Para llamar a la ayuda: "
    echo "$0 -h"
    echo "$0 -help"
    echo "$0 -?"
    exit
}

# Valida la existencia y los permisos del path a monitorear.
validarPathMonitoreo(){
    if [[ ! -d "$PATH_MONITOREO" || ! -r "$PATH_MONITOREO" ]]; then
        echo " ""$PATH_MONITOREO"" No es un directorio valido o no tiene los permisos necesarios"
        help
        exit 1
    fi
}

matarProceso(){
    PID_VIEJO=$( ps ax  | grep "${BASH_SOURCE[0]}" | head -n 1 | awk '{print $1}' )
    eval "$( kill -9 "$PID_VIEJO" )"
    PID_NUEVO=$( ps ax  | grep "${BASH_SOURCE[0]}" | head -n 1 | awk '{print $1}' )
    
    until [ "$PID_NUEVO" == "$PID_VIEJO" ]
        do
            PID_VIEJO=$( ps ax  | grep "${BASH_SOURCE[0]}" | head -n 1 | awk '{print $1}' )
            eval "$( kill -9 "$PID_VIEJO" )"
            PID_NUEVO=$( ps ax  | grep "${BASH_SOURCE[0]}" | head -n 1 | awk '{print $1}' )
        done
    exit 0
}

# Valida la existencia y los permisos del path destino.
validarPathDestino(){
    if [ ! "$PATH_DESTINO" ]; then
        PATH_DESTINO="$PATH_MONITOREO"
    elif [[ ! -d "$PATH_DESTINO"  || ! -r "$PATH_DESTINO" || ! -w "$PATH_DESTINO" ]]; then
        echo """$PATH_DESTINO"" No es un path valida o no tiene los permisos correspondientes"
        help
        exit 1
    fi
}

# Valida si se debe matar el proceso.
validarMatarProceso(){
    if [ "$MATAR_PROCESO" = true ]; then
        matarProceso
    fi
}

#Crea y mueve los archivos a las carpetas correspondientes.
crearYmover(){

    if [ "$EXTENSION_ARCHIVO" ]; then
        if [ ! -d "$PATH_DESTINO/${EXTENSION_ARCHIVO^^}" ]; then
            eval "$( mkdir "$PATH_DESTINO/${EXTENSION_ARCHIVO^^}" )"
        fi
        eval "$( mv "$PATH_MONITOREO/$1" "$PATH_DESTINO/${EXTENSION_ARCHIVO^^}" )"
    else
        if [ -d "$PATH_DESTINO" ]; then
        eval "$( mv -i "$PATH_MONITOREO/$1" "$PATH_DESTINO" )"
        fi
    fi

}

#Obtiene la extension de los archivos.
obtenerExtension(){
    CONT_PUNTO=0
    #Obtenes la cantidad de puntos
    CONT_PUNTO=$( echo "$1" | awk -F"." '{ print NF-1 }' )
    #Primer caracter
    PRIMER_LETRA="${1:0:1}"


    if [[ "$PRIMER_LETRA" == "." && $CONT_PUNTO == 1 ]]; then
        EXTENSION_ARCHIVO=""
    else
        EXTENSION_ARCHIVO="${1#*.}"

        while [[ "$EXTENSION_ARCHIVO" =~ \. ]]
        do
            EXTENSION_ARCHIVO="${EXTENSION_ARCHIVO#*.}"
        done
        
        if [[ "$EXTENSION_ARCHIVO" == "$1" ]]; then
            EXTENSION_ARCHIVO=""
        fi
    fi
}

#Comienza el programa.
comienzoScript(){
    IFS=$'\n'
    while true
        do
            for ARCHIVO in $( ls -a "$PATH_MONITOREO" ); 
                do
                    if [[ "$ARCHIVO" != "." && "$ARCHIVO" != ".." ]]; then
                        obtenerExtension "$ARCHIVO"
                        crearYmover "$ARCHIVO"
                    fi
                done
        sleep 10        
        done
    unset IFS
}

# Validar parametros -s, -help y -?

OPCIONES_LETRAS_AYUDA=false

if [[ "$@" =~ '-async' ]]; then
    # Validacion de parametros
    while [ $# -gt 0 ]
        do 
            case "$1" in
                -async)
                SEG_PLANO=true 
                ;;
            esac
            case "$1" in
                -d) 
                shift
                PATH_MONITOREO="$1" 
                ;;
            esac
            case "$2" in
                -d) 
                shift
                PATH_MONITOREO="$2" 
                ;;
            esac
            case "$1" in
                -o) 
                shift
                PATH_DESTINO="$1" 
                ;;
            esac
            case "$2" in
                -o) 
                shift
                PATH_DESTINO="$2"
                ;;
            esac
            case "$1" in
                -s)
                shift
                if [ "$1" != "" ]; then
                    echo "No se puede enviar parametros al -s"
                    help
                    exit
                fi
                matarProceso ;;
            esac
            case "$1" in
                -help)
                shift
                if [ "$1" != "" ]; then
                    echo "No se puede enviar parametros al -help"
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
                    echo "No se puede enviar parametros al -h"
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
            d) PATH_MONITOREO=$OPTARG ;;
            o) PATH_DESTINO=$OPTARG ;;
            s) matarProceso ;;
            *) usage ;;
        esac 
    done

    if [[ $# > 4 || $# < 1 || ! $PATH_MONITOREO ]] ; then
        echo "Sintaxis incorrecta"
        help
        exit
    fi
fi

if [[ "$@" =~ '-s' || "$@" =~ '-help' || "$@" =~ '-?' ]]; then
    OPCIONES_LETRAS_AYUDA=true
fi

if [[ $# > 1 && "$OPCIONES_LETRAS_AYUDA" = true ]]; then
    echo "Sintaxis incorrecta"
    help
    exit
fi

# Se valida que si se identica path destino, se tenga el path de monitoreo

# if ! [[ "$@" =~ '-o' || "$@" =~ '-d' || "$@" =~ '-?' || "$@" =~ '-help' || "$@" =~ '-h' || "$@" =~ '-s' ]]; then
#     echo "Sintaxis incorrecta"
#     help
#     exit
# fi

# if [[ "$@" =~ '-o' && ! "$@" =~ '-d' ]]; then
#     echo "Error, si se envia el path de destino, se debe enviar el path de monitoreo"
#     help
#     exit
# fi

# ------------------------------------------- Comienzo del script ------------------------------------------- #

if [[ $SEG_PLANO == false && $MATAR_PROCESO == false ]]; then
    nohup "./${BASH_SOURCE[0]}" "-async" "-d" "$PATH_MONITOREO" "-o" "$PATH_DESTINO" &
    exit 0
fi

validarMatarProceso
validarPathMonitoreo
validarPathDestino
comienzoScript