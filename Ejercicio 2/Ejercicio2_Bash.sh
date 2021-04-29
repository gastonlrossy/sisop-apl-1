#!/bin/bash

#####                   APL Nº1                 #####
#####		    Ejercicio 2 - Entrega           #####
#####			  Ejercicio2_Bash.sh	        #####

#####				  GRUPO N°2		            #####
#####       41.915.248 - Zella, Ezequiel        #####
#####       41.292.382 - Cencic, Maximiliano    #####
#####       40.538.404 - Bonvehi, Sebastian     #####
#####       40.137.778 - Rossy, Gastón Lucas    #####
#####       40.227.531 - Tebes, Leandro  	    #####

imprimirReporte(){
    archivo=$2
    fecha=$3
    pathArchi=$4
    contadorIncons=0
    cont1="`grep -o '¡' $archivo | wc -l`"
    cont2="`grep -o '!' $archivo | wc -l`"
    resultadoResta=`expr $cont1 - $cont2`
    contadorIncons=`expr $contadorIncons + ${resultadoResta#-}`

    cont1="`grep -o '¿' $archivo | wc -l`"
    cont2="`grep -o '?' $archivo | wc -l`"
    resultadoResta=`expr $cont1 - $cont2`
    contadorIncons=`expr $contadorIncons + ${resultadoResta#-}`

    cont1="`grep -o '(' $archivo | wc -l`"
    cont2="`grep -o ')' $archivo | wc -l`"
    resultadoResta=`expr $cont1 - $cont2`
    contadorIncons=`expr $contadorIncons + ${resultadoResta#-}`
    echo  "Cantidad de cambios realizados: $1" > "$pathArchi/${archivo%.*}_$fecha.log"
    echo  "Cantidad de inconsistencias: $contadorIncons" >> "$pathArchi/${archivo%.*}_$fecha.log"
}

if [[ $# != 1 && $# != 2 ]]
then
    echo "Error en la cantidad de parametros: Ejecute el script con -h, -help o -? para mas informacion..."
    exit
fi

archivoDeEntrada=

while getopts "h' help' ?' i: " op; do
    case "${op}" in
    i)
                
        tipoArchivo=$(file -b --mime-type $OPTARG)
        if [[ $tipoArchivo != 'text/plain' || ! -r $OPTARG ]]
        then
            echo "El archivo $archivoDeEntrada no es un archivo de texto plano y/o no posee permisos de lectura.  Enviar: -h, -help o -? para obtener indicaciones"
            exit
        fi
        archivoDeEntrada=$OPTARG
        archivoDeEntrada=${archivoDeEntrada/'./'/"$(pwd $archivoDeEntrada)/"}        
    ;;

    *)
        if [[ $1 == '-h' || $1 == '-help' || $1 == '-?' ]] 
        then
            echo "El archivo se ejecuta ingresando: -i'"
            echo "Ejemplo: bash nombreScript -i archivoAParsear"
            exit
        else
            echo "Ejecucion invalida del script, ejecute -h, -help o -? para mas info..."
                exit
        fi
    ;;
    esac
done


IFS=$'\n'

soloArchivo=${archivoDeEntrada//*'/'}

fecha=`date +"%Y%m%d%H%M" `

nombre="${soloArchivo%.*}" 
extension=${soloArchivo//*'.'}
pathArchi=${archivoDeEntrada%/*}

contadorCambios=0 

for lineaArchivo in $(cat $archivoDeEntrada)
    do
        cantidadCambiosAnterior=${#lineaArchivo}
        lineaCambio="` echo $lineaArchivo | tr -s " "`" 
        cantidadCambiosActual=${#lineaCambio}
        contadorCambios="$(($contadorCambios + ($cantidadCambiosAnterior-$cantidadCambiosActual)))"
        cantidadCambiosAnterior=$cantidadCambiosActual
        lineaCambio=` echo $lineaCambio| sed 's/[[:space:]]\././g' | sed 's/[[:space:]]\;/;/g' | sed 's/[[:space:]]\,/,/g' ` 
        cantidadCambiosActual=${#lineaCambio}
        contadorCambios="$(($contadorCambios + ($cantidadCambiosAnterior-$cantidadCambiosActual)))"
        cantidadCambiosAnterior=$cantidadCambiosActual
        lineaCambio=` echo $lineaCambio | sed 's/\./\. /g' | sed 's/\;/\; /g' | sed 's/\,/\, /g' | sed 's/ *$//' | tr -s " "`
        cantidadCambiosActual=${#lineaCambio}
        contadorCambios=`expr $contadorCambios + $cantidadCambiosActual - $cantidadCambiosAnterior`
       echo  $lineaCambio >> "$pathArchi/$nombre"_"$fecha.$extension"
    done


unset IFS

imprimirReporte $contadorCambios $soloArchivo $fecha $pathArchi 