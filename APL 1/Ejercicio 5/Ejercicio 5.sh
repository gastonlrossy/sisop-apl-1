#!/bin/bash


#####                  APL N1                   #####
#####		         Ejercicio 5                #####
#####			  Ejercicio 5.sh    	        #####

#####	             GRUPO N°2                  #####
#####       Tebes, Leandro - 40.227.531	        #####
#####       Rossy, Gaston L. - 40.137.778       #####
#####	    Zella, Ezequiel - 41.915.248        #####
#####       Cencic, Maximiliano - 41.292.382    #####
#####       Bonvehi, Sebastian - 40.538.404     #####


help(){
    echo "Hola!"
    echo "Es necesario ejecutar este script teniendo la biblioteca JQ y JO en las version 1.6 y 1.4 respectivamente."
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
    pathSinExtension="${ruta%.*}"
    file="${1##*/}"
    extension="${file##*.}"

    if [ -z "$pathSinExtension" ]; then
        if [ -z "$extension" ]; then
            helpError "No se ingreso el nombre del archivo a generar."
        fi

        pathSinExtension=$extension
    fi

    ruta=$pathSinExtension".json"
}

validarBibliotecas() {
    JQ_VERSION=`jq --version &> /dev/null`
    if test $? -eq 0; then
        JQ_VERSION=`jq --version`
        if [[ $JQ_VERSION != *"1.6"* ]]; then
            HAY_Q_INSTALAR_JQ=true
        fi
    else
        HAY_Q_INSTALAR_JQ=true
    fi

    JO_VERSION=`jo -version &> /dev/null`
    if test $? -eq "0"; then
        JO_VERSION=`jo -version`
        if [[ $JO_VERSION != *"1.4"* ]]; then
            HAY_Q_INSTALAR_JO=true
        fi
    else
        HAY_Q_INSTALAR_JO=true
    fi

    if [ "$HAY_Q_INSTALAR_JQ" = true ]; then
        if [ "$HAY_Q_INSTALAR_JO" = true ]; then
            helpError "No se puede ejecutar sin la biblioteca JQ en la version 1.6 y JO en la version 1.4"
        fi
        helpError "No se puede ejecutar sin la biblioteca JQ en la version 1.6"
    elif [ "$HAY_Q_INSTALAR_JO" = true ]; then
        helpError "No se puede ejecutar sin la biblioteca JO en la version 1.4"
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

read -ra ARRAY <<<"$resumen"
  
for (( c=0; c<${#ARRAY[*]}; c+=2 )); do

    nota=${ARRAY[$c + 1]}
    obj_nota=$( jo materia="$MATERIA" nota=$nota )
    obj_alumno=$( jo dni=${ARRAY[$c]} notas[]=$obj_nota)
    
    cantAparicionesDni="`grep -o "${ARRAY[$c]}" "$ruta" | wc -l`"

    if test $cantAparicionesDni -eq 0; then
      nuevoJson=$( jq --argjson alumno $obj_alumno \
                      '.actas[.actas | length] += ($alumno)' "$ruta" )
    else
        soloArrAlumnos=$( jq --argjson dni ${ARRAY[$c]} \
                             --argjson nota_alumno "$obj_nota" \
                                '.actas[] | select(.dni==$dni).notas += [$nota_alumno]' "$ruta" )

        soloArrAlumnosFormateado=$( jq -s '.' <<< $soloArrAlumnos)

        nuevoJson=$( jq -n --argjson v "$soloArrAlumnosFormateado" '{"actas": ($v)}' )
    fi

    echo $nuevoJson | jq '.' > "$ruta" # para guardar archivo final
done

done
