#####                   APL N2                  #####
#####		    Ejercicio 4 - Entrega           #####
#####				Ejercicio 4.ps1             #####

#####			      GRUPO Nº2                 #####
#####         Tebes, Leandro - 40.227.531       #####
#####         Rossy, Gaston L. - 40.137.778     #####
#####	      Zella, Ezequiel - 41.915.248      #####
#####       Cencic, Maximiliano - 41.292.382    #####
#####       Bonvehi, Sebastian - 40.538.404     #####

<#
 .SYNOPSIS
    El script, una vez ejecutado, detectará en la carpeta origen cualquier archivo nuevo y lo moverá a un subdirectorio cuyo nombre será la extensión del archivo en cuestion. Por ejemplo, si aparece un archivo .zip en nuestra carpeta de origen, este sera movido a la carpeta de destino y dentro de ella aparecera una carpeta llamada \"ZIP\" con el archivo en cuestion dentro.
 .PARAMETER Descargas
    Indica el directorio a monitorear por el script.
 .PARAMETER Destino
    Indica el directorio contenedor de las carpetas organizadoras por extension. De no indicarse se tomara por defecto el directorio Descargas.
 .PARAMETER Detener
    Frena la ejecucion del script. En caso de enviar este parametro, no deben ser enviados los otros dos.
 .EXAMPLE
  \Ejercicio 4.ps1 -Descargas Downloads
 .EXAMPLE
  \Ejercicio 4.ps1 -Descargas Downloads -Destino Destiny
 .EXAMPLE
  \Ejercicio 4.ps1 -Detener
#>

Param (
    [Parameter()]
    [string]$Descargas = $false,
    [Parameter()]
    [string]$Destino = $false,
    [Parameter()]
    [switch]$Detener
)
$global:handlers
$global:DescargasG=$Descargas
$global:DestinoG=$Destino
function Test-Parameters(){
    if($Detener -eq $True -and ($Descargas -ne $False -or $Destino -ne $False)){
        Write-Output "No se puede ingresar el comando [-Detener] junto con los comandos [-Descarga] y [-Destino]"
        exit
    }
    if($Destino -ne $False -and $Descargas -eq $False){
        Write-Output "No se puede ingresar el comando [-Destino] sin enviar el comando [-Descarga]"
        exit
    }
    Test-Kill-Command -path $Detener
    Test-Path-From -path $Descargas
    Test-Path-Destiny -path $Destino
}
function Test-Path-From(){
    Param(
        [string]$path
    )
    if(! (Test-Path $path)){
        Write-Output "El directorio a organizar no es un directorio valido o no tiene los permisos necesarios."
        exit
    }
}
function Test-Path-Destiny(){
    Param(
        [string]$path
    )
    if([string]::IsNullOrEmpty($path))
    {
        $global:Destino = $Descargas
    }
    else{
        if(! (Test-Path $path)){
            Write-Output "El directorio de destino no es un directorio valido o no tiene los permisos necesarios."
            exit
        }
    }
}
function Test-Kill-Command(){
    if($PSBoundParameters.ContainsKey('Detener'))
    {
        Unregister-Watcher
        exit
    }
}
function global:Move-Files(){
    Param(
        [string]$pathFrom,
        [string]$pathDestiny,
        [string]$fileExtension,
        [string]$file
    )
    if(!([string]::IsNullOrEmpty($fileExtension))){
        if(! (Test-Path "$pathDestiny/$fileExtension")) {
            New-Item "$pathDestiny/$fileExtension" -itemtype directory -force >> $null
        }
        Move-item –path "$pathFrom/$file" –destination "$pathDestiny/$fileExtension" -force >> $null
    }
    else{
        Move-Item -Path "$pathFrom/$file" -Destination "$pathDestiny" -force >> $null
    }
}
function global:Start-Movement(){
    $files = (Get-ChildItem -Path "$DescargasG" -Name -force)
    foreach ($file in $files) {
        $fileExtension = [IO.Path]::GetExtension("$file")
        if($file -eq $fileExtension){
            $fileExtension = ""
        }
        $fileExtension = $fileExtension.Replace(".","")
        $fileExtension = $fileExtension.ToUpper()
        Move-Files -pathFrom $DescargasG -pathDestiny $DestinoG -fileExtension $fileExtension -file $file
    }
}
function Start-Process(){
    global:Start-Movement
    Register-Watcher
}
function Register-Watcher(){
    $watcher = New-Object -TypeName System.IO.FileSystemWatcher 
    $watcher.Path = (Resolve-Path "$Descargas").Path
    $watcher.Filter = "*"
    $watcher.IncludeSubdirectories = $false
    $watcher.EnableRaisingEvents = $false

    $action = {
        global:Start-Movement
    }

    $global:handlers = . { Register-ObjectEvent -InputObject $watcher -EventName Created -Action $action >> $null }
    $watcher.EnableRaisingEvents = $true
}
function Unregister-Watcher(){
    $watcher.EnableRaisingEvents = $false
    $handlers | ForEach-Object {
        Unregister-Event -SourceIdentifier $_.Name
      }
      $handlers | Remove-Job
      $watcher.Dispose()
}

Test-Parameters
Start-Process