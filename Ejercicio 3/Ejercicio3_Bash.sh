#!/bin/bash

#####                   APL Nº1                 #####
#####		    Ejercicio 3 - Entrega           #####
#####			  Ejercicio3_Bash.sh		    #####

#####				  GRUPO N°2		            #####
#####       41.915.248 - Zella, Ezequiel        #####
#####       41.292.382 - Cencic, Maximiliano    #####
#####       40.538.404 - Bonvehi, Sebastian     #####
#####       40.137.778 - Rossy, Gastón Lucas    #####
#####       40.227.531 - Tebes, Leandro  	    #####



IFS=$'\n'

if [[ $# != 6 && $# != 1 ]]; then
        echo "Cantidad erronea de parametros, ejecute -h, -help o -? para mas informacion..."
        exit
fi

while getopts "h' help' ?' D: U:" o; do
    case $o in
        U | D) 
            PARAMS=( "$@" )
            for (( i=0 ; i<${#PARAMS[*]}; i+=2 ))
            do
                if [[ "${PARAMS[$i]}" == "-Umbral" ]]; then
                    umbral=${PARAMS[$i+1]}
                elif [[ "${PARAMS[$i]}" == "-Directorio" ]]; then
                    if [[ ! -d "${PARAMS[$i+1]}" || ! -r "${PARAMS[$i+1]}" ]]; then
                        echo "El directorio de destino no puede ser escrito/leido..."
                        exit
                    fi
                    directorioOrigen=${PARAMS[$i+1]}
                elif [[ "${PARAMS[$i]}" == "-DirectorioSalida" ]]; then
                    if [[ ! -d "${PARAMS[$i+1]}" || ! -r "${PARAMS[$i+1]}" || ! -w "${PARAMS[$i+1]}" ]]; then
                        echo "El directorio de origen no puede ser leido..."
                        exit
                    fi
                    directorioDestino=${PARAMS[$i+1]}
                else
                    echo "Sintaxis incorrecta"
                fi
            done
        ;;

        *)
            if [[ $1 == '-h' || $1 == '-help' || $1 == '-?' ]]; then
                    echo
                    echo "El archivo se ejecuta ingresando: -Directorio 'archivoOrigen', -DirectorioSalida 'archivoDestino', -Umbral 'umbralKB'"
                    echo "Ejemplo: bash $0 -Directorio Origen -DirectorioSalida Destino -Umbral 0"
                    echo
                    exit
            else
                    echo "Parametro incorrecto, ejecute -h, -help o -? para mas info..."
                    exit
            fi
        ;;
    esac
done

function escriboRepeticiones(){ 
    umbral=$3
    archivos=($(find "$1" -type f -size +"$umbral"k))
    cantidadArchivos=${#archivos[*]}
    repetidos=()

    for ((i=0; i<$cantidadArchivos; i++))
        do 
            if [[ -r "${archivos[i]}" ]]
                then
                    archivoINoIncluido=1
                    repite=0

                    for ((j=i+1; j<$cantidadArchivos; j++))
                        do

                         if [[ -r "${archivos[j]}" ]]
                            then
                                dif=$(diff "${archivos[i]}" "${archivos[j]}") 
                                if [[ ${dif[@]} == "" ]]
                                then
                                    repite=1
                                    if [[ $archivoINoIncluido == 1 ]]
                                    then
                                        repetidos=("${repetidos[@]}" "${archivos[i]}" )
                                        archivoINoIncluido=0
                                    fi
                                    repetidos=("${repetidos[@]}" "${archivos[j]}")
                                    unset archivos[j]
                                fi
                            fi
                    done

                    if [[ $repite==1 ]]
                    then
                        repetidos=("${repetidos[@]}" "|")
                        repite=0
                    fi
                fi

    done
    
    diaEjecucion=`date +"%Y%m%d"`
    horaEjecucion=`date +"%H%M"`

    for x in "${repetidos[@]}"
                do 
                    if [[ $x == '|' ]]
                        then
                            printf "\n" >> "$2/Resultado_"$diaEjecucion""$horaEjecucion".out"
                        else
                            path=${x/'./'/"$(pwd ${archivos[i]})/"}
                            printf "%-30s %-30s\n" "${x//*'/'}" "${path%/*}" >> "$2/Resultado_"$diaEjecucion""$horaEjecucion".out"
                    fi
                done
}


escriboRepeticiones $directorioOrigen $directorioDestino $umbral