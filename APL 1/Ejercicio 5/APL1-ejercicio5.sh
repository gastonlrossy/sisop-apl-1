#!/bin/bash

#####                  APL N1                   #####
#####		         Ejercicio 5                #####
#####			  APL1-ejercicio5.sh	        #####

#####	   GRUPO: 			                    #####
#####       Tebes, Leandro - 40.227.531	        #####
#####       Rossy, Gaston L. - 40.137.778       #####
#####	    Zella, Ezequiel - 41.915.248        #####
#####       Cencic, Maximiliano - 41.292.382    #####
#####       Bonvehi, Sebastian - 40.538.404     #####


help(){
    echo "Hola!"
    echo "Es necesario ejecutar este script teniendo la biblioteca JQ en la version 1.5 o upper."
    echo "Al ejecutar el script, el mismo evaluará si se tiene dicha dependencia y de tenerla, evaluará las version de la misma."
    printf "De no tenerla o de tener una version anterior, el programa intentará instalarla preguntandole al usuario previamente.\n\n"
    echo "El objetivo del script es procesar las notas guardadas en archivos CSV y generar un archivo JSON con dichas notas a partir de todos los CSV guardados."
    echo "El script recibirá los siguientes parámetros:"
    echo " • --notas: Directorio en el que se encuentran los archivos CSV."
    echo " • --salida: Ruta del archivo JSON a generar incluyendo el nombre del archivo."
    echo "Luego, la ejecucion del script es la siguiente:"
    printf "\t$0 --notas <directorio con los archivos .CSV> --salida <directorio + nombre del archivo json a generar>\n\n"
    exit
}

helpError() {
    echo "Hola!"
    printf "La sintaxis para la ejecución del script no fue correcta.\n"
    if [ "$1" != "" ]; then
        printf "\n"
        echo El error fue: "$1"
        printf "\n"
    fi
    printf "\nPodes ver la ayuda de la siguiente manera:"
    printf "\n\t$0 -h"
    printf "\n\t$0 -help"
    printf "\n\t$0 -?\n\n"

    exit
}

validacionCantParams(){
    if test $1 -ne 4; then
        helpError "Cantidad de parametros incorrecta."
    fi
}

validacionParams(){
    if [[ "$1" != "--notas" || "$3" != "--salida" ]]; then
        helpError "Cantidad de parametros incorrecta."
    fi

    if ! [ -d "$2" ]; then
        helpError "$2 no es un directorio valido."
    fi

    if ! [ -r "$2" ]; then
        helpError "$2 no posee permisos de lectura."
    fi

    if ! [ -d `dirname $4` ]; then
        helpError "$4 no es un directorio valido."
    fi
}

obtenerNombreJson(){
    ruta=$1

    if [[ $ruta == *"./"* ]]; then
        basepath=${ruta%/*}''/
        ruta="${ruta##*/}"
    fi

    pathSinExtension="${ruta%.*}"
    file="${1##*/}"

    if [ -z "$pathSinExtension" ]; then
        helpError "No se ingreso el nombre del archivo a generar."
    fi

    if [ ! -z "$basepath" ]; then
        pathSinExtension=$basepath''$pathSinExtension
    fi

    ruta=$pathSinExtension".json"
}

validarBibliotecas() {
    JQ_VERSION=`jq --version &> /dev/null`
    if test $? -eq 0; then
        JQ_VERSION=`jq --version`
        if [[ $JQ_VERSION != *"1.6"* && $JQ_VERSION != *"1.5"* ]]; then
            helpError "No se puede ejecutar sin la biblioteca JQ en la version 1.5 o upper."
        fi
    else
        helpError "No se puede ejecutar sin la biblioteca JQ en la version 1.5 o upper."
    fi
}

while getopts "?'help'h'-:" o; do
    case $o in
        -)
            validacionCantParams $#

            validacionParams "$1" "$2" "$3" "$4"

            obtenerNombreJson "$4"

            validarBibliotecas

        ;;
        *)
            if [[ $1 == '-h' || $1 == '-help' || $1 == '-?' ]]; then
                help
            else
                helpError "Parametro incorrecto."
            fi
        ;;
    esac
done

arrVacio=$( jq -n '{"actas": []}' )
echo $arrVacio > "$ruta"

for i in $(ls $2 | grep '\.csv$'); do
    MATERIA="${i%_*}"

    resumen=$(awk '
    BEGIN{
        FS=","
    }
    {
        total=0
        if(NR==1)
        valorEj=(10/(NF-1));
        
        for(k=2; k<=NF; k++){
        if("B" == toupper($k)){
            total+=valorEj;
        } else if ("R" == toupper($k)) {
            total+=(valorEj/2);
        }
        }
        print $1 " " total
    }' "$2/$i")

    resumen=` echo $resumen | sed 's/\\n/\ /g'`

    IFS=' '

    read -ra alumnos <<<"$resumen"
    
    for (( c=0; c<${#alumnos[*]}; c+=2 )); do

        nota=${alumnos[$c + 1]}

        obj_nota=$( jq -n --argjson materia "$MATERIA" \
                          --argjson nota "$nota" \
                            '{"materia": ($materia), "nota": ($nota)}' | sed 's/ //g' | sed 's/\n//g')

        obj_alumno=$( jq -n --argjson dni "${alumnos[$c]}" \
                            --argjson nota "$obj_nota" \
                            '{"dni": ($dni), "notas": [($nota)]}' | sed 's/ //g' | sed 's/\n//g')
        
        cantAparicionesDni="`grep -o "${alumnos[$c]}" "$ruta" | wc -l`"

        if test $cantAparicionesDni -eq 0; then
            nuevoJson=$( jq --argjson alumno $obj_alumno \
                        '.actas[.actas | length] += ($alumno)' "$ruta" )
        else
            notasDelAlumno=$( jq --argjson dni ${alumnos[$c]} \
                      '.actas[] | select(.dni==$dni).notas' "$ruta" )

            if [[ $notasDelAlumno == *"$MATERIA"* ]]; then
                printf "Warning:\n\tEl alumno: ${alumnos[$c]} rindio mas de una vez la materia: $MATERIA.\n"
            fi

            soloArrAlumnos=$( jq --argjson dni ${alumnos[$c]} \
                                 --argjson nota_alumno "$obj_nota" \
                                    '.actas[] | select(.dni==$dni).notas += [$nota_alumno]' "$ruta" )

            soloArrAlumnosFormateado=$( jq -s '.' <<< $soloArrAlumnos)

            nuevoJson=$( jq -n --argjson v "$soloArrAlumnosFormateado" '{"actas": ($v)}' )
        fi

        echo $nuevoJson | jq '.' > "$ruta" # para guardar archivo final
    done
    unset IFS
done
