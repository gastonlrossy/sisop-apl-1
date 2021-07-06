#####                   APL Nº2                 #####
#####		        Ejercicio 6 - Entrega           #####
#####				        Ejercicio 6.ps1			        #####

#####				          GRUPO N°2 		            #####
#####       Tebes, Leandro - 40.227.531         #####
#####       Rossy, Gaston L. - 40.137.778       #####
#####       Zella, Ezequiel - 41.915.248        #####
#####       Cencic, Maximiliano - 41.292.382    #####
#####       Bonvehi, Sebastian - 40.538.404     #####

<#
.Synopsis
Este programa emula el funcionamiento de una papelera de reciclaje
.Description
El script se forma con estas opciones de ejecucion:
    -l lista los archivos que contiene la papelera de reciclaje, dando la informacion del nombre de archivo y la ubicacion donde se encuentra
    -r [archivo] recupera el archivo pasado por parametro a la ubicacion donde estaba.
    -e vacia la papelera de reciclaje
    [archivo] Sin modificadores para que este archivo lo envie a la papelera de reciclaje.
#>

Param(
  [Parameter(Mandatory = $false)]
  [Switch]$e,
  [Parameter(Mandatory = $false)]
  [Switch]$l,
  [Parameter(Mandatory = $false)]
  [String]$InputFile,
  [Parameter(Mandatory = $false)]
  [Switch]$r
)
function Validate-RecycleBin-Content() {

  if (!(Test-Path "$RecycleBin") -or !([System.IO.Compression.ZipFile]::OpenRead("$RecycleBin").Entries.Name)) {
    Write-Output "La papelera se encuentra vacia"
    exit
  }
 
}

$RecycleBin = "$HOME/RecycleBin.zip"

function List-RecicleByn() {
    
  $LIST = [io.compression.zipfile]::OpenRead($RecycleBin).Entries.FullName
    
  foreach ($file in $LIST) {

    if (!($file -match '/$')) {
      $name = Split-Path $file -Leaf
      $nameAddress = Split-Path -Path "/$file"
      $nameShowed = $name.Substring(0, $name.LastIndexOf("_"))
      $date = $name.Substring($name.LastIndexOf("_")+1)
      printf "%-25s %-50s\n" "$nameShowed borrado el $date $nameAddress"
    }
  }
}
function Extract-File() {

  Param(
    [Parameter(Mandatory = $true)]
    [String]$PathOriginalFile
  )

  $Address = $Pwd

  $originalName = Split-Path $file -Leaf
  Set-Location $HOME
  unzip -p "$RecycleBin" "$PathOriginalFile" > "$originalName"
  $nameAddress = Split-Path -Path "/$PathOriginalFile"

  $newName=$originalName.Substring(0, $originalName.LastIndexOf("_"))
  Rename-Item -Path "$HOME/$originalName" -NewName $newName >> $null

  if (-Not (Test-Path -Path "$nameAddress/$newName" -PathType Leaf)){
    Move-Item "$HOME/$newName" "$nameAddress/$newName"
  }
  else{
    $num=1
    while (Test-Path -Path "$nameAddress/$newName ($num)" -PathType Leaf){
      $num++
    }
    Move-Item "$HOME/$newName" "$nameAddress/$newName ($num)" >> $null
    Write-Output "Tu archivo fue recuperado bajo el nombre $NEWNAME ($num) debido a que ya existía un archivo con el mismo nombre en el directorio"
    Write-Output "$nameAddress"
  }

  zip -d "$RECYCLEBIN" "$PathOriginalFile" >> $null
  Write-Output "Archivo recuperado exitosamente."
  Set-Location $Address
}

function Recover-File() {

  Param(
    [Parameter(Mandatory = $true)]
    [String]$FileName
  )

  $LIST = [io.compression.zipfile]::OpenRead($RecycleBin).Entries.FullName
  $Counter = 0
  $MatchingFiles = @()

  foreach ($file in $LIST) {

    if (!($file -match '/$')) {

      $name = Split-Path $file -Leaf

      if ( "$name" -like "$FileName*" ) {
        $Counter = $Counter + 1
        $MatchingFiles += $file
        $nameAddress = Split-Path -Path "/$file"
        $date = $name.Substring($name.LastIndexOf("_")+1)
        $nameShowed = $name.Substring(0,$name.LastIndexOf("_"))

        if ("$($nameShowed)_$($date)" -eq $name) {
          Write-Output "$Counter - $nameShowed borrado el $date $nameAddress"
        }
      }
    }

  }

  if ($Counter -eq 0) {
    Write-Output "El archivo no existe en la papelera"
    exit
  }

  if ($Counter -gt "1"){
    Write-Output "¿Qué archivo desea recuperar? Si no quiere recuperar ninguno, presione 0 "
    $Option = Read-Host
  }
  else{
    $Index = ($OPTION - 1)
    $file = $MatchingFiles[$Index]
    Extract-File $file
    exit
  }

  while ( $Option -notmatch '[0-9]{1}') {
    Write-Output "Opcion invalida. La opcion debe ser un numero y se debe encontrar listado en las opciones por pantalla."
    Write-Output "¿Qué archivo desea recuperar? Si no quiere recuperar ninguno, presione 0 "
    $Option = Read-Host 
  }

  if ( $OPTION -eq 0 ) {
    Write-Output "Ha elegido no recuperar ningún archivo."
    exit
  }
  
  $Index = ($OPTION - 1)
  $file = $MatchingFiles[$Index]

  if($null -eq $file) {
    Write-Output "Escribio un numero que no estaba dentro de las opciones. Vuelva a intentarlo ejecutando el script nuevamente."
    exit
  }

  Extract-File $file
}
function EmptyTrash() {
  Write-Output "Vaciando la Papelera..."
  Remove-Item "$RecycleBin" -Force
  Write-Output "Papelera vaciada con exito."
}

if(!$e -and !$l -and !$InputFile -and !$r){
  Write-Output "Por favor, ejecute el script con los parametros correctos. Get-Help para mas informacion."
  exit
}

if ($l) {
  Validate-RecycleBin-Content
  List-RecicleByn
}
elseif ($e) {
  Validate-RecycleBin-Content
  EmptyTrash
}
elseif ($r) {
  if("$InputFile"){
    Validate-RecycleBin-Content
    Recover-File "$InputFile"
    $Recover = $true
  }else {
    Write-Output "Por favor, ejecute el script con los parametros correctos. Get-Help para mas informacion."
    exit
  }
  
}

if (!$InputFile -or $Recover) {
  exit
}

$name = Split-Path $inputFile -Leaf

$PATH_BASE = $Pwd

$test=Resolve-Path -Path $InputFile -ErrorAction SilentlyContinue

if($test -eq $null){
  Write-Output "El archivo que se intenta borrar no existe."
  exit
}

$inputFile=Resolve-Path -Path $InputFile
# if ($InputFile.contains("../")) {
#   $j = ([regex]::Matches($InputFile, "../" )).count

#   for ($i = 0; $i -lt $j ; $i++) {
#     $PATH_BASE = Split-Path -Path "$PATH_BASE"
#   }

#   $InputFile = "$PATH_BASE/$name"
# }
# elseif (!($InputFile.contains($PATH_BASE))) {
#   $InputFile = "$PWD/$InputFile"
# }

# if(-Not (Test-Path -Path "$InputFile" -PathType Leaf)){
#   Write-Output "El archivo que se intenta borrar no existe."
#   exit
# }

$PATH_BASE = $inputFile.Split("/")[-1].Split(".")[0]

$date = Get-Date -format "yyyy-MM-dd HH.mm.ss" 

$date = "_$date"

$nameAddress = Split-Path -Path $InputFile
$REPEATEDFILE = "$nameAddress/$name$date"
Rename-Item "$InputFile" "$REPEATEDFILE" >> $null
zip -m "$RECYCLEBIN" "$REPEATEDFILE"  >> $null
Write-Output "Archivo eliminado correctamente."
 