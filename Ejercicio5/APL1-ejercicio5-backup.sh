#!/bin/bash


#####                   APL N1                  #####
#####		        Ejercicio 2 - Entrega           #####
#####				      APL1-ejercicio2.sh			      #####

#####			GRUPO: 			                          #####
#####       Tebes, Leandro - 40.227.531	        #####
#####       Rossy, Gaston L. - 40.137.778       #####
#####	      Zella, Ezequiel - 41.915.248        #####
#####       Cencic, Maximiliano - 41.292.382    #####
#####       Bonvehi, Sebastian - 40.538.404     #####





#$1 # -> directorio con los .csv
#$2 # -> ruta del archivo a json a generar

#validar parámetros (existencia de rutas y permisos, cantidad de parámetros).   DONE

if ! [ -d "$1" ]; then
    echo "${1} no es un directorio valido."
    exit
elif ! [ -r "$1" ]; then
    echo "${1} no posee posee permisos de lectura."
    exit
fi

echo "paso"
# crear array asociativo de actas
declare -A ACTAS_POR_DNI

# Llamadar a awk pasandole como parametro el directorio con los csv ($1)
# Hacer un foreach donde se recorran uno por uno todos los archivos con extension .csv
for i in $(ls $1 | grep '\.csv$'); do
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
  }' "$1/$i")

  echo $resumen

  resumen=` echo $resumen | sed 's/\\n/\ /g'`
  echo "aaaaaa::: "$resumen

  IFS=' '

  read -ra ARRAY <<<"$resumen"
  echo "ASDASD: " ${!ARRAY[*]}
  echo "ASDASD: " ${#ARRAY[*]}

for (( c=0; c<${#ARRAY[*]}; c+=2 )); do

    echo "Oh see perro::  " $MATERIA "  " ${ARRAY[$c]} "  " ${ARRAY[$c + 1]}
    # obj_nota=$( jo materia="$MATERIA" nota=${ARRAY[$c + 1]} )
    # obj_alumno=$( jo dni=${ARRAY[$c]} notas[]=$obj_nota)
done


obj_nota=$( jo materia="$MATERIA" nota=10 )
obj_nota2=$( jo materia="$MATERIA" nota=7 )


obj_alumno=$( jo dni="40227531" notas[]=$obj_nota)
obj_alumno2=$( jo dni="41216181" notas[]=$obj_nota)

JSON_STRING=$( jo actas[]=$obj_alumno actas[]=$obj_alumno2 )

echo "obj_nota:: " $obj_nota
echo "obj_alumno:: " $obj_alumno
echo "obj_alumno2:: " $obj_alumno2

# echo $JSON_STRING > $HOME"/falopita.json" # para guardar archivo


por_favor=$( jq  --argjson nota_alumno $obj_nota2 '.actas[] | select(.dni == 40227531).notas += [$nota_alumno]' "$HOME/falopita.json" )

por_favor_arr=$( jq -s '.' <<< $por_favor)

echo $por_favor_arr > $HOME"/arr_alumnos.json"

mmm=$( jo actas=:$HOME"/arr_alumnos.json" )

echo "uwu :: " $mmm



# { "actas": [
#  {
#     "dni": "40227531",
#     "notas": [
#       { "materia": 1115, "nota": 8 },
#       { "materia": 1116, "nota": 2 }
#     ]
#  },
#   {
#     "dni": "87654321",
#     "notas": [
#       { "materia": 1116, "nota": 9 },
#       { "materia": 1118, "nota": 7 }
#     ]
#  }
# ] }



# 42353607 10\n45123321 3.75\n40987789 2.5 40987789 2.5

# [0] = 42353607
# [1] = 10
# [2] = 45123321 3.75, 40987789 2.5, 40987789 2.5,

# con el resultado de cada .csv ir llenandno el array asociativo con los dnis como key

# como value se tendria un array q en la posicion 0 tendria el codigo de la materia y en la posicion 1, la nota

# en la primera iteracion de un nuevo csv, se deberia analizar la cantidad de columnas, siendo ese resultado -1, la cantidad de ejercicios

# 10 / CantidadEjercicios.
# • Un ejercicio bien (B) vale el ejercicio entero.
# • Un ejercicio regular (R) vale medio ejercicio.
# • Un ejercicio mal (M) no suma puntos a la nota final.

# generar la nota en base a la respuesta de awk por ese file y ese alumno cuyo dni es la key del array asociativo

done

# ["40227531"][0] -> materia
# ["40227531"][1] -> nota



