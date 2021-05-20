
<#
.SYNOPSIS
La funcion del script ejecutado es la de buscar archivos duplicados (en contenido) con un tamaño superior al umbral y dejarlos expresados en forma de listado e un documento de texto plano resultante, al que luego el usuario podra entrar para consultar los nombres y rutas de dichos archivos duplicados.
Este script cuenta con tres parametros:
-Directorio : directorio al cual el script va a ingresar a buscar los archivos duplicados.
-DirectorioSalida : directorio donde se alojara el archivo resultante con el listado de archivos duplicados.
-Umbral : Tamaño minimo en KB para evaluar si los arhivos son duplicados o no.
El archivo se ejecuta ingresando: -Directorio 'archivoOrigen', -DirectorioSalida 'archivoDestino', -Umbral 'umbralKB'

.EXAMPLE
Ejercicio3.ps1 -Directorio Origen -DirectorioSalida Destino -Umbral 1
#>

Param(
[ValidateScript({
    if(-Not ($_ | Test-Path) ){
        throw "El directorio no existe" 
    }
    return $true
})]
[Parameter(Mandatory=$False)] [string]$Directorio,


[ValidateScript({
    if(-Not ($_ | Test-Path) ){
        throw "El directorio no existe" 
    }
    return $true
})]
[Parameter(Mandatory=$False)][string]$DirectorioSalida,
[Parameter(Mandatory=$False)][int]$Umbral
)



if($help){
    Write-Host "Ingresaste a la ayuda del prgrama."
    Write-Host "La funcion del script ejecutado es la de buscar archivos duplicados (en contenido) con un tamaño superior al umbral y dejarlos expresados en forma de listado e un documento de texto plano resultante, al que luego el usuario podra entrar para consultar los nombres y rutas de dichos archivos duplicados."
    Write-Host "Este script cuenta con tres parametros:"
    Write-Host "-Directorio : directorio al cual el script va a ingresar a buscar los archivos duplicados."
    Write-Host "-DirectorioSalida : directorio donde se alojara el archivo resultante con el listado de archivos duplicados."
    Write-Host "-Umbral : Tamaño minimo en KB para evaluar si los arhivos son duplicados o no."
    Write-Host "El archivo se ejecuta ingresando: -Directorio 'archivoOrigen', -DirectorioSalida 'archivoDestino', -Umbral 'umbralKB'"
    Write-Host "Ejemplo: bash $0 -Directorio Origen -DirectorioSalida Destino -Umbral 0"
    exit
}

If (!$Directorio -or !$DirectorioSalida -or !$Umbral ){
    Write-Host "Error al ejecutar el script: El mismo debe ser ejecutado ingresando Archivo de 
    destino, origen y un umbral"
    exit
}





function Get-Differences(){
Param([Parameter(Mandatory=$False)] [string]$Archivo1,
[Parameter(Mandatory=$False)] [string]$Archivo2)

    $contenido1=Get-Content $Archivo1
    $contenido2=Get-Content $Archivo2

    $diff=(Compare-Object $contenido1 $contenido2)
    if($diff.length -eq 0 ){ 
        return 1
    }
    return 0
}


function get-repe([Object[]]$ArrayArch){

    $repetidos=New-Object Collections.Generic.List[String]
    $tamanioArray=$ArrayArch.Length

    for($i=0; $i -lt $tamanioArray; $i++){
        $incluido=0

        for($j=$i+1; $j -lt $tamanioArray; $j++){
            try{ 
            if(!$ArrayArch[$i].FullName.equals("") -And !$ArrayArch[$j].FullName.equals("") -And ((Get-Differences $ArrayArch[$i].FullName $ArrayArch[$j].FullName) -eq 1)){
                if($incluido -eq 0){
                    $repetidos.Add($ArrayArch[$i].FullName)
                    $incluido=1
                }

                $repetidos.Add($ArrayArch[$j].FullName)
                $ArrayArch[$j].FullName=""
            }
        }
        catch{
            Write-Host "No es posible leer los archivos $ArrayArchi[$i]/$ArrayArchi[$j]"
            exit
        }
        
        }
        if($incluido -eq 1){
            $repetidos.Add(" ")
            $ArrayArch[$i].FullName=""
        }
    }
    return $repetidos
}

$ArrayArchivos=Get-Childitem -File $Origen -Recurse -include *.txt | Select-Object -Property FullName 

$repe=get-repe ($ArrayArchivos)
$dateTime=Get-Date -Format "yyyyMMddHHmm"

for($l=0; $l -lt $repe.Length; $l++){
    if($repe[$l].Length -le 1){
        Add-Content -Value "" -Path "$Destino/Resultado_$datetime.out"
    }
    else{   
    $nombre=$repe[$l].Substring($repe[$l].lastIndexOf('\')+1)
    $path=$repe[$l].Substring(0,$repe[$l].lastIndexOf('\')+1)


    $op=$path.Substring(0,$path.Length-1)

    $text="{0,-30} {1,20}" -f "$nombre", "$op"
    Add-Content -Value $text -Path "$Destino/Resultado_$datetime.out"
    }
 
    
}