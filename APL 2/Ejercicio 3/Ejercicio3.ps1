#####                   APL Nº2                 #####
#####		    Ejercicio 3 - Entrega           #####
#####			  Ejercicio 3.ps1    	        #####

#####				  GRUPO N°2		            #####
#####       41.915.248 - Zella, Ezequiel        #####
#####       41.292.382 - Cencic, Maximiliano    #####
#####       40.538.404 - Bonvehi, Sebastian     #####
#####       40.137.778 - Rossy, Gastón Lucas    #####
#####       40.227.531 - Tebes, Leandro  	    #####


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
[Parameter(Mandatory=$False)] [string]$Directorio,
[Parameter(Mandatory=$False)][string]$DirectorioSalida,
[Parameter(Mandatory=$False)][int]$Umbral
)


if(-Not (Test-Path -Path $Directorio -PathType Container)){
    Write-Host "El directorio de origen no es un directorio valido..."
        return 
}

if(-Not (Test-Path -Path $DirectorioSalida -PathType Container)){
    Write-Host "El directorio de salida no es un directorio valido..."
    return 
}


if($Umbral -lt 0){
    Write-Host "El Umbral no puede ser negativo";
    return ;
}

If($Directorio -eq $DirectorioSalida){
    Write-Host "Error: Los directorios de entrada y salida deben ser distintos...";
    return ;
}

If (!$Directorio -or !$DirectorioSalida){
    Write-Host "Error al ejecutar el script: El mismo debe ser ejecutado con los
    parametros -Directorio, -DirectorioSalida y -Umbral. Ejecute el comando Get-Help para mas informacion..."
    return ;
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
        if((file -b --mime-type $ArrayArch[$i].FullName > $null) -eq "text/plain"){
            $incluido=0

            for($j=$i+1; $j -lt $tamanioArray; $j++){
                if((file -b  --mime-type $($ArrayArch[$j].FullName > $null)) -eq "text/plain"){
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
    }
        if($incluido -eq 1){
            $repetidos.Add(" ")
            $ArrayArch[$i].FullName=""
        }
    }
    }
    return $repetidos
}

$size="$Umbral"+"kb"
$ArrayArchivos=Get-Childitem -File $Directorio -Recurse | Where-Object Length -gt $size | Select-Object -Property FullName 

$repe=get-repe ($ArrayArchivos)
$dateTime=Get-Date -Format "yyyyMMddHHmm"

for($l=0; $l -lt $repe.Length; $l++){
    if($repe[$l].Length -le 1){
        Add-Content -Value "" -Path "$DirectorioSalida/Resultado_$datetime.out"
    }
    else{   
    $nombre=$repe[$l].Substring($repe[$l].lastIndexOf('\')+1)
    $path=$repe[$l].Substring(0,$repe[$l].lastIndexOf('\')+1)

    if($path.Length -gt 0){ 
    $op=$path.Substring(0,$path.Length-1)
    }

    $text="{0,-30} {1,20}" -f "$nombre", "$op"
    Add-Content -Value $text -Path "$DirectorioSalida/Resultado_$datetime.out"
    }
 
    
}