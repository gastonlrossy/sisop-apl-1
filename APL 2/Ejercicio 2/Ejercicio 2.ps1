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
    [Parameter(Mandatory=$True)] [string]$in
)

function print()
{
    Param(
    [int] $contadorCambios,
    [int] $contadorInconsistencias,
    [String] $soloArchivo,
    [String] $fecha,
    [String] $pathArchi
    )

    Write-Output  "Cantidad de cambios realizados: $contadorCambios" > "$pathArchi/$nombre_$fecha.log"
    Write-Output  "Cantidad de inconsistencias encontradas: $contadorInconsistencias" >> "$pathArchi/$nombre_$fecha.log"
}

if(!(Test-Path $in))
{
    Write-Output "No existe ingresado"
    Write-Output "Finalizando..."
    exit
}
elseif ((file -b --mime-type $in) -ne "text/plain") {
    Write-Output "El archivo ingresado no es un archivo de texto plano. Vuelva a intentarlo."
    Write-Output "Finalizando..."
    exit
}

$soloArchivo = Split-Path $in -Leaf -Resolve
$fecha = Get-date -format "yyyyMMddHHmm"
$nombre = Split-Path $soloArchivo -Leafbase
$extension = Split-Path $soloArchivo -Extension
if(!($pathArchi = Split-Path $in -Parent)){
    $pathArchi = "."}
$contadorCambios=0
$contadorInconsistencias=0

foreach ($lineaArchivo in $(cat "$in"))
    {
        $lineaAntes = $lineaArchivo
        $lineaCambio = $lineaAntes -replace '\s+',' '
        $aux = [Math]::Abs("$lineaAntes".Length-"$lineaCambio".Length)
        $contadorCambios = $contadorCambios + $aux
        
        $lineaAntes = $lineaCambio
        $lineaCambio = $lineaAntes -replace  ([regex]::Escape(' .')) , "."
        $aux = [Math]::Abs("$lineaAntes".Length-"$lineaCambio".Length)
        $contadorCambios = $contadorCambios + $aux

        $lineaAntes = $lineaCambio
        $lineaCambio = $lineaAntes -replace  ([regex]::Escape(' ;')) , ";"
        $aux = [Math]::Abs("$lineaAntes".Length-"$lineaCambio".Length)
        $contadorCambios = $contadorCambios + $aux

        $lineaAntes = $lineaCambio
        $lineaCambio = $lineaAntes -replace ([regex]::Escape(' ,')) , ","
        $aux = [Math]::Abs("$lineaAntes".Length-"$lineaCambio".Length)
        $contadorCambios = $contadorCambios + $aux
        
        $lineaAntes = $lineaCambio
        $lineaCambio = $lineaAntes -replace "\."   , '. '
        $lineaCambio = $lineaCambio -replace "\.  ",'. '
        $aux = [Math]::Abs("$lineaAntes".Length-"$lineaCambio".Length)
        $contadorCambios = $contadorCambios + $aux

        $lineaAntes = $lineaCambio
        $lineaCambio = $lineaAntes -replace "\;",'; '
        $lineaCambio = $lineaCambio -replace "\;  ",'; '
        $aux = [Math]::Abs("$lineaAntes".Length-"$lineaCambio".Length)
        $contadorCambios = $contadorCambios + $aux

        $lineaAntes = $lineaCambio
        $lineaCambio = $lineaAntes -replace "\,"   , ', '
        $lineaCambio = $lineaCambio -replace "\,  ", ', '
        $aux = [Math]::Abs("$lineaAntes".Length-"$lineaCambio".Length)
        $contadorCambios = $contadorCambios + $aux

        $lineaCambio = $lineaCambio.trim()
        
        Write-Output  $lineaCambio >> $pathArchi'/'$nombre'_'$fecha$extension

        $cont1 = ($lineaCambio.ToCharArray() | Where-Object {$_ -eq '!'} | Measure-Object).Count
        $cont2 = ($lineaCambio.ToCharArray() | Where-Object {$_ -eq '¡'} | Measure-Object).Count
        $contadorInconsistencias = $contadorInconsistencias + [Math]::Abs($cont1 - $cont2)

        $cont1 = ($lineaCambio.ToCharArray() | Where-Object {$_ -eq '?'} | Measure-Object).Count
        $cont2 = ($lineaCambio.ToCharArray() | Where-Object {$_ -eq '¿'} | Measure-Object).Count
        $contadorInconsistencias = $contadorInconsistencias + [Math]::Abs($cont1 - $cont2)

        $cont1 = ($lineaCambio.ToCharArray() | Where-Object {$_ -eq '('} | Measure-Object).Count
        $cont2 = ($lineaCambio.ToCharArray() | Where-Object {$_ -eq ')'} | Measure-Object).Count
        $contadorInconsistencias = $contadorInconsistencias + [Math]::Abs($cont1 - $cont2)
    }

print  $contadorCambios $contadorInconsistencias $nombre $fecha $pathArchi
