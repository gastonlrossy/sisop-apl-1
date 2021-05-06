#!/bin/bash


#####                  APL N1                   #####
#####                Ejercicio 5                #####
#####             APL1-ejercicio5.sh            #####

#####      GRUPO:                               #####
#####       Tebes, Leandro - 40.227.531         #####
#####       Rossy, Gaston L. - 40.137.778       #####
#####       Zella, Ezequiel - 41.915.248        #####
#####       Cencic, Maximiliano - 41.292.382    #####
#####       Bonvehi, Sebastian - 40.538.404     #####


help(){
    echo "Hola!"
    echo "Es necesario ejecutar este script teniendo las bibliotecas JO y JQ en las versiones 1.4 y 1.6 respectivamente."
    echo "Al ejecutar el script, el mismo evaluará si se tienen dichas dependencias y de tenerlas, evaluará las versiones de las mismas."
    printf "De no tenerlas o de tener una version anterior, el programa intentará instalarlas preguntandole al usuario previamente.\n\n"
    echo "Luego, la ejecucion del script es la siguiente:"
    printf "\t$0 --notas <directorio con los archivos .CSV> --salida <directorio + nombre del archivo json a generar>\n\n"

    exit
}

helpError() {
    echo "Hola!"
    printf "La sintaxis para la ejecución del script no fue correcta.\n"
    if [ "$1" != "" ]; then
        printf "\nEl error fue: "$1"\n"
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
        helpError "${2} no es un directorio valido."
    fi

    if ! [ -r "$2" ]; then
        helpError "${2} no posee permisos de lectura."
    fi

    if ! [ -d `dirname $4` ]; then
        helpError "${4} no es un directorio valido."
    fi
}

obtenerNombreJson(){
    ruta=$1
    pathSinExtension="${ruta%.*}"
    file="${1##*/}"
    extension="${file##*.}"

    if [ -z "$extension" ]; then
        helpError "No se ingreso el nombre del archivo a generar."
    fi

    ruta=$pathSinExtension".json"
    
}

while getopts "?'help'h'-:" o; do
    case $o in
        -)
            validacionCantParams $#

            validacionParams "$1" "$2" "$3" "$4"

            obtenerNombreJson "$4"

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

JQ_VERSION=`jq --version &> /dev/null`
if test $? -eq 0; then
    JQ_VERSION=`jq --version`
    if [[ $JQ_VERSION != *"1.6"* ]]; then
        HAY_Q_INSTALAR_JQ=true
    fi
else
    HAY_Q_INSTALAR_JQ=true
fi

if [ "$HAY_Q_INSTALAR_JQ" = true ]; then
    printf "\nEste script utiliza las librerias Jo y Jq.\nQuieres instalar Jq ahora? (Y/N) "
    read OPCION
    OPCION=$(echo ${OPCION} | tr [a-z] [A-Z])
    while ([[ "$OPCION" != "Y" ]] && [[ "$OPCION" != "N" ]]); do
        echo "Opcion invalida, vuelva a intentar.."
        printf "\nEste script utiliza las librerias Jo y Jq.\nQuieres instalar Jq ahora? (Y/N) "
        read OPCION
        OPCION=$(echo ${OPCION} | tr [a-z] [A-Z])
    done
    if [[ "$OPCION" == "N" ]]; then
        echo "Gracias, vuelva prontos."
        exit
    fi
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # Mac OSX
        printf "\n\nInstalando JQ para MacOs...\n"
        brew install jq
    elif [[ "$OSTYPE" == "linux-gnu" ]]; then
        printf "\n\nInstalando JQ para Linux...\n"
        sudo apt-get remove jq
        sudo snap install jq --edge #para que sea la version 1.6, para la 1.5 no hace falta el --edge
    fi
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

if [ "$HAY_Q_INSTALAR_JO" = true ]; then
    printf "\nEste script utiliza las librerias Jo y Jq.\nQuieres instalar Jo ahora? (Y/N) "
    read OPCION
    OPCION=$(echo ${OPCION} | tr [a-z] [A-Z])
    while ([[ "$OPCION" != "Y" ]] && [[ "$OPCION" != "N" ]]); do
        echo "Opcion invalida, vuelva a intentar.."
        printf "\nEste script utiliza las librerias Jo y Jq.\nQuieres instalar Jo ahora? (Y/N) "
        read OPCION
        OPCION=$(echo ${OPCION} | tr [a-z] [A-Z])
    done
    if [[ "$OPCION" == "N" ]]; then
        echo "Gracias, vuelva prontos."
        exit
    fi
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # Mac OSX
        printf "\n\nInstalando JO para MacOs...\n"
        brew install jo
    elif [[ "$OSTYPE" == "linux-gnu" ]]; then
        printf "\n\nInstalando JO para Linux...\n"
        sudo apt-get remove jo
        sudo snap install jo
    fi
fi

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

  json_vacio=$(jo -a < /dev/null)

  echo $json_vacio > "$ruta"

  actas_vacio=$( jo actas=:"$ruta" )

  echo $actas_vacio > "$ruta"
  
for (( c=0; c<${#ARRAY[*]}; c+=2 )); do

    nota=${ARRAY[$c + 1]}
    obj_nota=$( jo materia="$MATERIA" nota=$nota )
    obj_alumno=$( jo dni=${ARRAY[$c]} notas[]=$obj_nota)
    
    cantAparicionesDni="`grep -o "${ARRAY[$c]}" "$ruta" | wc -l`"

    if test $cantAparicionesDni -eq 0; then
      nuevoJson=$( jq --argjson alumno $obj_alumno \
                      '.actas[.actas | length] += $alumno' "$ruta" )

    else
      soloArrAlumnos=$( jq --argjson dni ${ARRAY[$c]} \
                      --argjson nota_alumno "$obj_nota" \
                      '.actas[] | select(.dni==$dni).notas += [$nota_alumno]' "$ruta" )

    soloArrAlumnosFormateado=$( jq -s '.' <<< $soloArrAlumnos)

    echo $soloArrAlumnosFormateado > $HOME"/arr_alumnos.json"

    nuevoJson=$( jo actas=:$HOME"/arr_alumnos.json" )

    fi

    echo $nuevoJson > "$ruta" # para guardar archivo final
done

done
