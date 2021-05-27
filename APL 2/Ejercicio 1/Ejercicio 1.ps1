#####                   APL N2                  #####
#####		    Ejercicio 1 - Entrega           #####
#####				Ejercicio 1.ps1             #####

#####			      GRUPO Nº2                 #####
#####         Tebes, Leandro - 40.227.531       #####
#####         Rossy, Gaston L. - 40.137.778     #####
#####	      Zella, Ezequiel - 41.915.248      #####
#####       Cencic, Maximiliano - 41.292.382    #####
#####       Bonvehi, Sebastian - 40.538.404     ##### 

# Si la sintaxis esperada del script es invalida, 
#  se imprime por stdout la salida esperada.

[CmdletBinding()]
Param (
[Parameter(Position = 1, Mandatory = $true)] #El parámetro en la posicion uno y no es obligatorio
[ValidateScript( { Test-Path -PathType Container $_ } )] ##Valida que sea un path lo que llega después del pipe |
[String] $path, #El parametro es un path
[Parameter(Position = 2, Mandatory = $true)]
[ValidateScript( { $_ -gt 0 },
ErrorMessage = "{0} no es valido. La cantidad debe ser mayor a cero." )] ##Valida que sea un path lo que llega después del pipe |
[int] $cantidad #El segundo parametro es un entero y sirve para obtener la cantidad de items
)

$LIST = Get-ChildItem -Path $path -Directory ##Le da una lista de directorios (carpetas) en el path que llegó por parametro.
$ITEMS = ForEach ($ITEM in $LIST) {
    $COUNT = (Get-ChildItem -Path $ITEM).Length ##Itera y a cada hijo se fija le cantidad de archivos/carpetas que tiene cada uno 
    ##Y lo va guardando aca con el directorio y la cantidad de carpetas y archivos dentro.
    $props = @{
        name = $ITEM
        count = $COUNT
        }
    New-Object psobject -Property $props ##Crea un objeto con las propiedades name y count.
    }

    ##Ordena según la cantidad de mayor a menor
    ## después se queda con la cantidad de items que le llegó por parámetro
    ## y se queda con los nombres de los directorios nomas
    $CANDIDATES = $ITEMS | Sort-Object -Property count -Descending | Select-Object -First $cantidad | Select-Object -Property name

    Write-Output "Los directorios de la ruta proporcionada son:" # COMPLETAR
    $CANDIDATES | Format-Table -HideTableHeaders


# 1.a ¿Cuál es el objetivo de este script?

# El objetivo es poder ver los directorios que se encuentran dentro de la ruta proporcionada al script.
# Estos directorios se listarán según la cantidad de directorios y archivos que tienen dentro.
# La cantidad límite de directorios que el script listará viene dado por el segundo parámetro.

# 1.b ¿Qué parámetros recibe? 

# La ruta y la cantidad de directorios a mostrar.

# 4. ¿Agregaría alguna otra validación a los parámetros? 

# Que la cantidad de directorios a mostrar sea siempre mayor a cero.

# ¿Existe algún error en el script? 

# Sí.

# Errores:

# Si no enviamos la cantidad de directorios que queremos ver no nos va a mostrar ninguno porque el valor por defecto del parametro es 0.
# Si no enviamos path, no tiene nada para listar.

#Soluciones:

# Para solucionar los errores mencionados, ambos parámetros deben ser obligatorios.

# 5. ¿Para qué se utiliza [CmdletBinding()]?

# CmdletBinding convierte una función en una función avanzanda. Proporciona acceso a las características de los cmdlets.
# En las funciones que tienen el CmdletBinding atributo, los parámetros desconocidos y los argumentos posicionales que no tienen parámetros posicionales coincidentes provocan un error en el enlace de parámetros.

# 6- Explique las diferencias entre los distintos tipos de comillas que se pueden utilizar en Shell scripts.

# Comillas simples: Una cadena entre comillas simples es una cadena textual. Los nombres de variable precedidos por un signo de dólar ( ) se reemplazan por el valor de la variable antes de que la cadena se pase $ al comando para su procesamiento.
# Comillas dobles: Una cadena entre comillas dobles es una cadena que se puede expandir.
# Comillas francesas: Para evitar la sustitución de un valor de variable en una cadena entre comillas dobles usamos el carácter `, que es el caracter de escape de PowerShell. 

# 7. ¿Qué sucede si se ejecuta el script sin ningún parámetro?

# Si se ejecuta sin ningún parametro, no tiene nada para mostrar porque no tiene ninguna ruta para iterar. Si se envía solo
# con el parámetro de path, como el valor default de la cantidad a mostrar es cero, no muestra nada tampoco.