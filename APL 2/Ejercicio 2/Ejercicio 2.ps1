#####                   APL Nº2                 #####
#####		    Ejercicio 2 - Entrega           #####
#####			  Ejercicio 2.ps1    	        #####

#####				  GRUPO N°2		            #####
#####       41.915.248 - Zella, Ezequiel        #####
#####       41.292.382 - Cencic, Maximiliano    #####
#####       40.538.404 - Bonvehi, Sebastian     #####
#####       40.137.778 - Rossy, Gastón Lucas    #####
#####       40.227.531 - Tebes, Leandro  	    #####

<#
.Synopsis
Crear un archivo resultado a partir de la eliminacion de espacios incosistentes.
.Description
La funcion del script que desea ejecutar es la de crear un archivo nuevo en base al ingresado eliminando espacios inconsistentes (por ejemplo \"hola     como    estas   ? ==> hola como estas?\") y agregando un espacio, en caso que falte, luego de los signos de puntuacion (punto, coma y punto y coma). Ademas, luego de su ejecucion podra consultar un reporte de correcciones que incluira la cantidad de correcciones realizadas y la cantidad de inconsistencias encontradas.
.Parameter value
Archivo de texto el cual servira como entrada para crear otro resultante sin inconsistencias de espacios.
.Example
El archivo se ejecuta ingresando: 
        Ejercicio 2.ps1 -in <Archivo>
Ejemplo: Ejercicio 2.ps1 -in archivoBase
#>

## Declaro parametros
Param(
    [Parameter(Position = 1, Mandatory=$True)] [switch]$in,
    [Parameter(Position = 2, Mandatory=$True)] [string]$archivoDeEntrada
)

function print()
{
    Param(
    [int] $contadorCambiosED,
    [int] $contadorCambiosEspaciosAntesComa,
    [int] $contadorCambiosEspaciosAntesPunto,
    [int] $contadorCambiosAgregarEspacioComa,
    [int] $contadorCambiosAgregarEspacioPunto,
    [int] $contadorCambiosAgregarEspacioPuntoComa,
    [int] $contadorSigAdm,
    [int] $contadorSigPreg,
    [int] $contadorParentesis,
    [String] $soloArchivo,
    [String] $fecha,
    [String] $pathArchi
    )

    Write-Output  "Espacios duplicados eliminados: $contadorCambiosED" > "$pathArchi/$nombre_$fecha.log"
    Write-Output  "Espacios de mas eliminados antes de un punto: $contadorCambiosEspaciosAntesPunto" >> "$pathArchi/$nombre_$fecha.log"
    Write-Output  "Espacios de mas eliminados antes de una coma: $contadorCambiosEspaciosAntesComa" >> "$pathArchi/$nombre_$fecha.log"
    Write-Output  "Espacios de mas eliminados antes de un punto y coma: $contadorCambiosEspaciosAntesPuntoComa" >> "$pathArchi/$nombre_$fecha.log"
    Write-Output  "Espacios agregados despues de un punto: $contadorCambiosAgregarEspacioPunto" >> "$pathArchi/$nombre_$fecha.log"
    Write-Output  "Espacios agregados despues de una coma: $contadorCambiosAgregarEspacioComa" >> "$pathArchi/$nombre_$fecha.log"
    Write-Output  "Espacios agregados despues de un punto y coma: $contadorCambiosAgregarEspacioPuntoComa" >> "$pathArchi/$nombre_$fecha.log"
    Write-Output  "Cantidad de inconsistencias de parentesis dispares: $contadorParentesis" >> "$pathArchi/$nombre_$fecha.log"
    Write-Output  "Cantidad de inconsistencias de signos de admiracion dispares: $contadorSigAdm" >> "$pathArchi/$nombre_$fecha.log"
    Write-Output  "Cantidad de inconsistencias de signos de pregunta dispares: $contadorSigPreg" >> "$pathArchi/$nombre_$fecha.log"
}

if(!(Test-Path $archivoDeEntrada))
{
    Write-Output "No existe ingresado"
    Write-Output "Finalizando..."
    exit
}
elseif ((file -b --mime-type $archivoDeEntrada) -ne "text/plain") {
    Write-Output "El archivo ingresado no es un archivo de texto plano. Vuelva a intentarlo."
    Write-Output "Finalizando..."
    exit
}

$soloArchivo = Split-Path $archivoDeEntrada -Leaf -Resolve
$fecha = Get-date -format "yyyyMMddHHmm"
$nombre = Split-Path $soloArchivo -Leafbase
$extension = Split-Path $soloArchivo -Extension
$pathArchi = Split-Path $archivoDeEntrada -Parent
$contadorCambiosED=0
$contadorCambiosEspaciosAntesComa=0
$contadorCambiosEspaciosAntesPunto=0
$contadorCambiosEspaciosAntesPuntoComa=0
$contadorCambiosAgregarEspacioComa=0
$contadorCambiosAgregarEspacioPunto=0
$contadorCambiosAgregarEspacioPuntoComa=0

foreach ($lineaArchivo in $(cat "$archivoDeEntrada"))
    {
        $lineaAntes = $lineaArchivo
        $lineaCambio = $lineaAntes -replace '\s+',' '
        $aux = [Math]::Abs("$lineaAntes".Length-"$lineaCambio".Length)
        $contadorCambiosED = $contadorCambiosED + $aux
        
        $lineaAntes = $lineaCambio
        $lineaCambio = $lineaAntes -replace  ([regex]::Escape(' .')) , "."
        $aux = [Math]::Abs("$lineaAntes".Length-"$lineaCambio".Length)
        $contadorCambiosEspaciosAntesPunto = $contadorCambiosEspaciosAntesPunto + $aux

        $lineaAntes = $lineaCambio
        $lineaCambio = $lineaAntes -replace  ([regex]::Escape(' ;')) , ";"
        $aux = [Math]::Abs("$lineaAntes".Length-"$lineaCambio".Length)
        $contadorCambiosEspaciosAntesPuntoComa = $contadorCambiosEspaciosAntesPuntoComa + $aux

        $lineaAntes = $lineaCambio
        $lineaCambio = $lineaAntes -replace ([regex]::Escape(' ,')) , ","
        $aux = [Math]::Abs("$lineaAntes".Length-"$lineaCambio".Length)
        $contadorCambiosEspaciosAntesComa = $contadorCambiosEspaciosAntesComa + $aux
        
        $lineaAntes = $lineaCambio
        $lineaCambio = $lineaAntes -replace '\.  ', '.'
        $lineaCambio = $lineaAntes -replace '\.', '. '
        $aux = [Math]::Abs("$lineaAntes".Length-"$lineaCambio".Length)
        $contadorCambiosAgregarEspacioPunto = $contadorCambiosAgregarEspacioPunto + $aux

        $lineaAntes = $lineaCambio
        $lineaCambio = $lineaAntes -replace '\;  ', '\;'
        $lineaCambio = $lineaAntes -replace '\;', '\; '
        $aux = [Math]::Abs("$lineaAntes".Length-"$lineaCambio".Length)
        $contadorCambiosAgregarEspacioPuntoComa = $contadorCambiosAgregarEspacioPuntoComa + $aux

        $lineaAntes = $lineaCambio
        $lineaCambio = $lineaAntes -replace '\,  ', ','
        $lineaCambio = $lineaAntes -replace '\,', ', '
        $aux = [Math]::Abs("$lineaAntes".Length-"$lineaCambio".Length)
        $contadorCambiosAgregarEspacioComa = $contadorCambiosAgregarEspacioComa + $aux

        # $lineaCambio = $lineaAntes -replace '\s+',' '
        $lineaCambio = $lineaCambio.trim()
        Write-Output "  Antes: $lineaArchivo"
        Write-Output "Despues: $lineaCambio"
        Write-Output  $lineaCambio >> $pathArchi'/'$nombre'_'$fecha$extension

        $cont1 = ($lineaCambio.ToCharArray() | Where-Object {$_ -eq '!'} | Measure-Object).Count
        $cont2 = ($lineaCambio.ToCharArray() | Where-Object {$_ -eq '¡'} | Measure-Object).Count
        $contadorSigAdm = $contadorSigAdm + [Math]::Abs($cont1 - $cont2)

        $cont1 = ($lineaCambio.ToCharArray() | Where-Object {$_ -eq '?'} | Measure-Object).Count
        $cont2 = ($lineaCambio.ToCharArray() | Where-Object {$_ -eq '¿'} | Measure-Object).Count
        $contadorSigPreg = $contadorSigPreg + [Math]::Abs($cont1 - $cont2)

        $cont1 = ($lineaCambio.ToCharArray() | Where-Object {$_ -eq '('} | Measure-Object).Count
        $cont2 = ($lineaCambio.ToCharArray() | Where-Object {$_ -eq ')'} | Measure-Object).Count
        $contadorParentesis = $contadorParentesis + [Math]::Abs($cont1 - $cont2)


    # Write-Output  "Espacios duplicados eliminados: $contadorCambiosED"
    # Write-Output  "Espacios de mas eliminados antes de un punto: $contadorCambiosEspaciosAntesPunto"
    # Write-Output  "Espacios de mas eliminados antes de una coma: $contadorCambiosEspaciosAntesComa"
    # Write-Output  "Espacios de mas eliminados antes de un punto y coma: $contadorCambiosEspaciosAntesPuntoComa"
    # Write-Output  "Espacios agregados despues de un punto: $contadorCambiosAgregarEspacioPunto"
    # Write-Output  "Espacios agregados despues de una coma: $contadorCambiosAgregarEspacioComa"
    # Write-Output  "Espacios agregados despues de un punto y coma: $contadorCambiosAgregarEspacioPuntoComa"
    # Write-Output  "Cantidad de inconsistencias de parentesis dispares: $contadorParentesis"
    # Write-Output  "Cantidad de inconsistencias de signos de admiracion dispares: $contadorSigAdm"
    # Write-Output  "Cantidad de inconsistencias de signos de pregunta dispares: $contadorSigPreg"
    # Write-Output " "
    # Write-Output " "
    
    }

print $contadorCambiosED $contadorCambiosEspaciosAntesComa $contadorCambiosEspaciosAntesPunto $contadorCambiosAgregarEspacioComa $contadorCambiosAgregarEspacioPunto $contadorCambiosAgregarEspacioPuntoComa $contadorSigAdm $contadorSigPreg $contadorParentesis $nombre $fecha $pathArchi