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


unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     machine="Linux";;
    MINGW*)     machine="MinGw";;
    *)          machine="UNKNOWN:${unameOut}"
esac

if [[ $machine == "Linux" ]]
then
    echo `dos2unix $"./$0"`
elif [[ $machine == "MinGw" ]]
    then
        echo `unix2dos $"./$0"`
fi


#$1 # -> directorio con los .csv
#$2 # -> ruta del archivo a json a generar

#validar parámetros (existencia de rutas y permisos, cantidad de parámetros).   DONE
clear
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
  # echo "ASDASD: " ${!ARRAY[*]}
  echo "ASDASD: " ${#ARRAY[*]}


  json_vacio=$(jo -a < /dev/null)

  echo $json_vacio > $HOME"/vacio.json"

  mmm=$( jo actas=:$HOME"/vacio.json" )

  echo $mmm > $HOME"/vacio.json"
  
  echo "uwu2 :: " $mmm

for (( c=0; c<${#ARRAY[*]}; c+=2 )); do

    nota=${ARRAY[$c + 1]}
    # echo "Oh see perro::  " $MATERIA "  " ${ARRAY[$c]} "  " ${ARRAY[$c + 1]}
    obj_nota=$( jo materia="$MATERIA" nota=$nota )
    obj_alumno=$( jo dni=${ARRAY[$c]} notas[]=$obj_nota)

    # obj_nota2=$( jo materia="puto" nota="8rey" )
    # obj_alumno2=$( jo dni="ahhsocurioso" notas[]=$obj_nota2)

    echo "obj_alumno:: " $obj_alumno
    
    asd="`grep -o "${ARRAY[$c]}" "$HOME/vacio.json" | wc -l`"
    # asd="`grep -o "${ARRAY[$c]}" "$HOME/falopita.json" | wc -l`"

    echo "es hoy es hoyy:: " $asd

    if test $asd -eq 0; then
      echo "No existe el alumno, lo tengo q crear"
      por_favor=$( jq --argjson alumno $obj_alumno \
                      '.actas[.actas | length] += $alumno' "$HOME/vacio.json" )
                      # '.actas[.actas | length] += $alumno' "$HOME/falopita.json" )
    else
      echo "Existe, tengo q agregar nota"
      por_favor=$( jq --argjson dni ${ARRAY[$c]} \
                      --argjson nota_alumno "$obj_nota" \
                      '.actas[] | select(.dni==$dni).notas += [$nota_alumno]' "$HOME/vacio.json" )
                      # '.actas[] | select(.dni==$dni).notas += [$nota_alumno]' "$HOME/falopita.json" )
    fi

    echo "por_favor:: " $por_favor

    por_favor_arr=$( jq -s '.' <<< $por_favor)

    echo $por_favor_arr > $HOME"/arr_alumnos.json" # idealmente seria bueno no necesitar guardarlo en un file

    mmm2=$( jo actas=:$HOME"/arr_alumnos.json" ) # para no necesitar guardarlo en un file, tendria q poder consumirlo acá

    echo $mmm2 > $HOME"/vacio.json"

    echo "uwu :: " $mmm2

    # echo $JSON_STRING > $HOME"/falopita.json" # para guardar archivo
done


# DEBERIA HACER:
# { "actas": [
#  {
#     "dni": "42353607",
#     "notas": [
#       { "materia": 6666, "nota": 10 }
#     ]
#  },
#   {
#     "dni": "45123321",
#     "notas": [
#       { "materia": 6666, "nota": 3.75 }
#     ]
#  }
# ] }

# HACE :()
{
  "actas": [
    {
      "actas": [
        {
          "dni": 42353607,
          "notas": [
            { "materia": 6666, "nota": 10 }
          ]
        }
      ]
    },
    {
      "dni": 45123321,
      "notas": [
        { "materia": 6666, "nota": 3.75 }
      ]
    }
  ]
}



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



