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
    archivo="$2"
    fecha="$3"
    pathArchi="$4"
    contadorIncons=0
    cont1="$(grep -o '¡' "$archivo" | wc -l)"
    cont2="$(grep -o '!' "$archivo" | wc -l)"
    resultadoResta=$(("$cont1" - "$cont2"))
    contadorIncons=$(("$contadorIncons" + "${resultadoResta#-}"))

    cont1="$(grep -o '¿' "$archivo" | wc -l)"
    cont2="$(grep -o '?' "$archivo" | wc -l)"
    resultadoResta=$(("$cont1" - "$cont2"))
    contadorIncons=$(("$contadorIncons" + "${resultadoResta#-}"))

    cont1="$(grep -o '(' "$archivo" | wc -l)"
    cont2="$(grep -o ')' "$archivo" | wc -l)"
    resultadoResta=$(("$cont1" - "$cont2"))
    contadorIncons=$(("$contadorIncons" + "${resultadoResta#-}"))
    echo  "Cantidad de cambios realizados: $1" > "$pathArchi${archivo%.*}_$fecha.log"
    echo  "Cantidad de inconsistencias: $contadorIncons" >> "$pathArchi${archivo%.*}_$fecha.log"
}

help(){
      echo "Ingresaste a la ayuda del prgrama."
      echo "El archivo se ejecuta ingresando: -in'." 
      echo "Ejemplo: bash nombreScript -in archivoAParsear"
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
contadorCambios=0 

for lineaArchivo in $( cat "$archivoDeEntrada" )
    do        
        cantidadCambiosAnterior=${#lineaArchivo}
        lineaCambio="$( echo "$lineaArchivo" | tr -s " ")"        
        cantidadCambiosActual=${#lineaCambio}
        aux=$(("$cantidadCambiosAnterior"-"$cantidadCambiosActual"))
        abs $aux
        aux=$?
        contadorCambios="$(("$contadorCambios" + "$aux"))"
        cantidadCambiosAnterior=$cantidadCambiosActual
        lineaCambio=$( echo "$lineaCambio"| sed 's/[[:space:]]\././g' | sed 's/[[:space:]]\;/;/g' | sed 's/[[:space:]]\,/,/g' ) 
        cantidadCambiosActual=${#lineaCambio}
        aux=$(("$cantidadCambiosAnterior"-"$cantidadCambiosActual"))
        abs $aux
        aux=$?
        contadorCambios="$(("$contadorCambios" + "$aux"))"
        cantidadCambiosAnterior=$cantidadCambiosActual
        lineaCambio=$( echo "$lineaCambio" | sed 's/\./\. /g' | sed 's/\;/\; /g' | sed 's/\,/\, /g' | sed 's/ *$//' | tr -s " ")
        cantidadCambiosActual=${#lineaCambio}
        aux=$(("$cantidadCambiosAnterior"-"$cantidadCambiosActual"))
        abs $aux
        aux=$?
        contadorCambios=$(("$contadorCambios" + "$aux"))
        echo  "$lineaCambio" >> "$pathArchi$nombre""_$fecha.$extension"
    done

unset IFS

print "$contadorCambios" "$soloArchivo" "$fecha" "$pathArchi"