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

while getopts "h' help' ?' DirectorioSalida: Directorio: Umbral:" o; do
    case "${o}" in

        Umbral) 
            umbral=$OPTARG
            echo "umbral va bien"
        ;;

        DirectorioSalida)
            if [[ ! -d $OPTARG || ! -r $OPTARG || ! -w $OPTARG ]]; then
                    echo "El directorio de destino no puede ser escrito/leido..."
                    exit
            fi
            echo "destino va bien"
            directorioDestino=$OPTARG
        ;;
        
        Directorio)
            if [[ ! -d $OPTARG || ! -r $OPTARG ]]; then
                    echo "El directorio de origen no puede ser leido..."
                    exit
            fi
            echo "origen va bien"
            directorioOrigen=$OPTARG
        ;;

        *)
            if [[ $1 == '-h' || $1 == '-help' || $1 == '-?' ]]; then
                    echo
                    echo "El archivo se ejecuta ingresando: -Directorio 'archivoOrigen', -DirectorioSalida 'archivoDestino', -Umbral 'umbralKB'"
                    echo "Ejemplo: bash $0 -Directorio Origen -DirectorioSalida Destino - Umbral 0"
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
                            printf "\n" >> "$2/Resultado_["$diaEjecucion""$horaEjecucion"].out"
                        else
                            path=${x/'./'/"$(pwd ${archivos[i]})/"}
                            printf "%-30s %-30s\n" "${x//*'/'}" "${path%/*}" >> "$2/Resultado_"$diaEjecucion""$horaEjecucion".out"
                    fi
                done
}


escriboRepeticiones $directorioOrigen $directorioDestino $umbral