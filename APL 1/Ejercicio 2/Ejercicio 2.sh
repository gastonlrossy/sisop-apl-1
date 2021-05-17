#!/bin/bash

#####                   APL Nº1                 #####
#####		    Ejercicio 2 - Entrega           #####
#####			  Ejercicio 2.sh    	        #####

#####				  GRUPO N°2		            #####
#####       41.915.248 - Zella, Ezequiel        #####
#####       41.292.382 - Cencic, Maximiliano    #####
#####       40.538.404 - Bonvehi, Sebastian     #####
#####       40.137.778 - Rossy, Gastón Lucas    #####
#####       40.227.531 - Tebes, Leandro  	    #####


abs(){
    local number="$(( "$1" < 0 ? -1 : 1 ))"
    local returnValue=$(("$1" * "$number"))
    return $returnValue 
}

print(){
    cont1="$(grep -o '¡' "$soloArchivo" | wc -l)"
    cont2="$(grep -o '!' "$soloArchivo" | wc -l)"
    resultadoResta=$(("$cont1" - "$cont2"))
    contadorSigAdm=$(("$contadorSigAdm" + "${resultadoResta#-}"))

    cont1="$(grep -o '¿' "$soloArchivo" | wc -l)"
    cont2="$(grep -o '?' "$soloArchivo" | wc -l)"
    resultadoResta=$(("$cont1" - "$cont2"))
    contadorSigPreg=$(("$contadorSigPreg" + "${resultadoResta#-}"))

    cont1="$(grep -o '(' "$soloArchivo" | wc -l)"
    cont2="$(grep -o ')' "$soloArchivo" | wc -l)"
    resultadoResta=$(("$cont1" - "$cont2"))
    contadorParentesis=$(("$contadorParentesis" + "${resultadoResta#-}"))

    echo  "Espacios duplicados eliminados: $contadorCambiosED" > "$pathArchi${soloArchivo%.*}_$fecha.log"
    echo  "Espacios de mas eliminados antes de un punto: $contadorCambiosEspaciosAntesPunto" >> "$pathArchi${soloArchivo%.*}_$fecha.log"
    echo  "Espacios de mas eliminados antes de una coma: $contadorCambiosEspaciosAntesComa" >> "$pathArchi${soloArchivo%.*}_$fecha.log"
    echo  "Espacios de mas eliminados antes de un punto y coma: $contadorCambiosEspaciosAntesPuntoComa" >> "$pathArchi${soloArchivo%.*}_$fecha.log"
    echo  "Espacios agregados despues de un punto: $contadorCambiosAgregarEspacioPunto" >> "$pathArchi${soloArchivo%.*}_$fecha.log"
    echo  "Espacios agregados despues de una coma: $contadorCambiosAgregarEspacioComa" >> "$pathArchi${soloArchivo%.*}_$fecha.log"
    echo  "Espacios agregados despues de un punto y coma: $contadorCambiosAgregarEspacioPuntoComa" >> "$pathArchi${soloArchivo%.*}_$fecha.log"
    echo  "Cantidad de inconsistencias de parentesis dispares: $contadorParentesis" >> "$pathArchi${soloArchivo%.*}_$fecha.log"
    echo  "Cantidad de inconsistencias de signos de admiracion dispares: $contadorSigAdm" >> "$pathArchi${soloArchivo%.*}_$fecha.log"
    echo  "Cantidad de inconsistencias de signos de pregunta dispares: $contadorSigPreg" >> "$pathArchi${soloArchivo%.*}_$fecha.log"
}

help(){
    echo "Ingresaste a la ayuda del prgrama."
    echo "La funcion del script que desea ejecutar es la de crear un archivo nuevo en base al ingresado eliminando espacios inconsistentes (por ejemplo \"hola     como    estas   ? ==> hola como estas?\") y agregando un espacio, en caso que falte, luego de los signos de puntuacion (punto, coma y punto y coma)."
    echo "Ademas, luego de su ejecucion podra consultar un reporte de correcciones que incluira la cantidad de correcciones realizadas y la cantidad de inconsistencias encontradas."
    echo "El archivo se ejecuta ingresando: -in <Archivo>" 
    echo "Ejemplo: bash nombreScript.sh -in archivoAParsear"
}

## Chequeamos cantidad de argumentos ##
if [[ $# != 1 && $# != 2 ]]
then
    echo "Error en la cantidad de parametros."
    help
    exit
fi

## Sirve para validar si el argumento empieza con guió medio ##
if  [[ ! ($1 =~ ^[-]) ]] || [[ ${1#*-} == '' ]]; then
    echo "No corresponde con un parametro valido"
    help
    exit
fi

## Validamos que luego del "-" se mande el comando correcto y guardamos en ese caso. ##
while getopts "?'help'h'i:in:" op; do
    case "${op}" in
    i)
        if [[ "$1" != "-in" ]]; then
            echo "$1 no corresponde a una opcion invalida."
            help
            exit 0 
        fi

        tipoArchivo=$( file -b --mime-type "$2" )

        if [[ $tipoArchivo != 'text/plain' || ! -r "$2" ]]
        then
            echo "El archivo ""$archivoDeEntrada"" no es un archivo de texto plano y/o no posee permisos de lectura.  Enviar: -h, -help o -? para obtener indicaciones"
            exit 0
        fi
        
        archivoDeEntrada="$2"
        PATH_BASE=$( pwd "$archivoDeEntrada" )

        if [[ "$archivoDeEntrada" == *"../"* ]]; then
            COMMAND_AWK="$(awk -F"../" '{print NF-1}' <<< "${archivoDeEntrada}" )"
            COMMAND_PATH_BASE=$( pwd "$PATH_BASE" )

        for (( i=0; i<"$COMMAND_AWK" ; i++ ))
            do
                archivoDeEntrada="${archivoDeEntrada##*/}"
                COMMAND_PATH_BASE=$( dirname -- "$COMMAND_PATH_BASE")
        done
        archivoDeEntrada="$COMMAND_PATH_BASE"'/'"$archivoDeEntrada"
        elif [[ "$archivoDeEntrada" != *"$PATH_BASE"* ]]; then
            archivoDeEntrada=$( pwd "$PATH_BASE")/"$archivoDeEntrada" #Con esta linea se obtiene el PATH absoluto
        fi
    ;;
    *)
        if [[ "$1" == '-h' || "$1" == '-help' || "$1" == '-?' ]] 
        then
            help
        else
            echo "Ejecucion invalida del script, ejecute -h, -help o -? para mas info..."
            
        fi
        exit 0
    ;;
    esac
done

IFS=$'\n'

soloArchivo=${archivoDeEntrada//*'/'}
fecha=$(date +"%Y%m%d%H%M" )
nombre="${soloArchivo%.*}" 
extension="${soloArchivo#*.}"
pathArchi=${archivoDeEntrada%/*}/
if [[ $pathArchi == *"$nombre"* ]]; then
    pathArchi="${pathArchi#*/}"
fi
contadorCambiosED=0
contadorCambiosEspaciosAntesComa=0
contadorCambiosEspaciosAntesPunto=0
contadorCambiosEspaciosAntesPuntoComa=0
contadorCambiosAgregarEspacioComa=0
contadorCambiosAgregarEspacioPunto=0
contadorCambiosAgregarEspacioPuntoComa=0


for lineaArchivo in $( cat "$archivoDeEntrada" )
    do
        lineaAntes=${#lineaArchivo}
        lineaCambio="$( echo "$lineaArchivo" | tr -s " ")"
        lineaDespues=${#lineaCambio}
        aux=$(("$lineaAntes"-"$lineaDespues"))
        abs $aux
        aux=$?
        contadorCambiosED="$(("$contadorCambiosED" + "$aux"))"

        
        lineaAntes=${#lineaCambio}
        lineaCambio=$( echo "$lineaCambio" | sed 's/[[:space:]]\././g' )
        lineaDespues=${#lineaCambio}
        aux=$(("$lineaAntes"-"$lineaDespues"))
        abs $aux
        aux=$?
        contadorCambiosEspaciosAntesPunto="$(("$contadorCambiosEspaciosAntesPunto" + "$aux"))"


        lineaAntes=${#lineaCambio}
        lineaCambio=$( echo "$lineaCambio" | sed 's/[[:space:]]\;/;/g' )
        lineaDespues=${#lineaCambio}
        aux=$(("$lineaAntes"-"$lineaDespues"))
        abs $aux
        aux=$?
        contadorCambiosEspaciosAntesPuntoComa="$(("$contadorCambiosEspaciosAntesPuntoComa" + "$aux"))"

        lineaAntes=${#lineaCambio}
        lineaCambio=$( echo "$lineaCambio" | sed 's/[[:space:]]\,/,/g' )
        lineaDespues=${#lineaCambio}
        aux=$(("$lineaAntes"-"$lineaDespues"))
        abs $aux
        aux=$?
        contadorCambiosEspaciosAntesComa="$(("$contadorCambiosEspaciosAntesComa" + "$aux"))"
        
        lineaAntes=${#lineaCambio}
        lineaCambio=$( echo "$lineaCambio" | sed 's/\./\. /g' )
        lineaDespues=${#lineaCambio}
        aux=$(("$lineaAntes"-"$lineaDespues"))
        abs $aux
        aux=$?
        contadorCambiosAgregarEspacioPunto="$(("$contadorCambiosAgregarEspacioPunto" + "$aux"))"

        lineaAntes=${#lineaCambio}
        lineaCambio=$( echo "$lineaCambio" | sed 's/\;/\; /g' )
        lineaDespues=${#lineaCambio}
        aux=$(("$lineaAntes"-"$lineaDespues"))
        abs $aux
        aux=$?
        contadorCambiosAgregarEspacioPuntoComa="$(("$contadorCambiosAgregarEspacioPuntoComa" + "$aux"))"

        lineaAntes=${#lineaCambio}
        lineaCambio=$( echo "$lineaCambio" | sed 's/\,/\, /g' )
        lineaDespues=${#lineaCambio}
        aux=$(("$lineaAntes"-"$lineaDespues"))
        abs $aux
        aux=$?
        contadorCambiosAgregarEspacioComa="$(("$contadorCambiosAgregarEspacioComa" + "$aux"))"
        
        lineaCambio=$( echo "$lineaCambio" | sed 's/ *$//' )
        lineaCambio=$( echo "$lineaCambio" | tr -s " " )

        echo  "$lineaCambio" >> "$pathArchi$nombre""_$fecha.$extension"
    done

unset IFS

print