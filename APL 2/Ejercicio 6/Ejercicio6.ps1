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
      $nameAddress = Split-Path -Path "$file"
      printf "%-25s %-50s\n" "$name" "/$nameAddress" 
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

  # cd $HOME -> comento esto porque el compilador me recomendo usar Set-Location
  Set-Location $HOME
  unzip -p "$RecycleBin" "$PathOriginalFile" >"$originalName"
  $nameAddress = Split-Path -Path $PathOriginalFile
  $nameAddress = "/$nameAddress"
  # mv $HOME/$originalName $DIRNAME -> lo mismo que el cd pero con mv
  Move-Item $HOME/$originalName $DIRNAME
  zip -d "$RECYCLEBIN" "$PathOriginalFile"
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

      if ( "$name" -eq "$FileName" ) {
        $Counter = $Counter + 1
        $MatchingFiles += $file
        $nameAddress = Split-Path -Path "$file"
        Write-Output "$Counter - $NOMBRE  /$nameAddress"              
      }
    }

  }

  if ($Counter -eq 0) {
    Write-Output "El archivo no existe en la papelera"
    exit
  }

  Write-Output "¿Qué archivo desea recuperar? Si no quiere recuperar ninguno, presione 0 "
  $Option = Read-Host 
  while ( $Option -lt 0 -or $OPTION -gt $Counter) {
    Write-Output "Opcion invalida. La opcion debe ser un numero y se debe encontrar listado en las opciones por pantalla."
    Write-Output "¿Qué archivo desea recuperar? Si no quiere recuperar ninguno, presione 0 "
    $Option = Read-Host 
  }

  if ( $OPTION -eq 0 ) {
    Write-Output "Ha elegido no recuperar ningún archivo."
    exit
  }
  
  $Index = ($OPTION - 1)
  Extract-File $MatchingFiles[$Index] 


}
function EmptyTrash() {
  Write-Output "Vaciando la Papelera..."
  Remove-Item "$RecycleBin" -Force
  # zip -d "$RecycleBin" \**
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
  Validate-RecycleBin-Content
  Recover-File "$InputFile"
  $Recover = $true
}

if (!$InputFile -or $Recover) {
  exit
}

$name = Split-Path $inputFile -Leaf

$PATH_BASE = $Pwd

if ($InputFile.contains("../")) {
  $j = ([regex]::Matches($InputFile, "../" )).count

  for ($i = 0; $i -lt $j ; $i++) {
    $PATH_BASE = Split-Path -Path "$PATH_BASE"
  }

  $InputFile = "$PATH_BASE/$name"
}

elseif (!($InputFile.contains($PATH_BASE))) {
  $InputFile = "$PWD/$InputFile"
}


$PATH_BASE = $inputFile.Split("/")[-1].Split(".")[0] 
$PATH_CUT = $inputFile.TrimStart("/")

if (Test-Path "$RecycleBin") {

  if ( ` unzip -Z1 "$RecycleBin" | grep "$PATH_CUT" ` ) {

    $date = Get-Date -format "yyyyMMddHHmm" 

    $date = "_$date"

    $nameWithoutExt = $InputFile.Split("/")[-1].Split(".")[0] 

    if ("$name" -ne "$nameWithoutExt") {   
      $extension = $InputFile.Split("/")[-1].Split(".")[-1]
      $extension = ".$extension"
    }   

    $nameAddress = Split-Path -Path $InputFile
    $REPEATEDFILE = "$nameAddress/$nameWithoutExt$date$extension"

    Move-Item "$InputFile" "$REPEATEDFILE"
    zip -m "$RECYCLEBIN" "$REPEATEDFILE" 
  }
  else {
    zip -m "$RECYCLEBIN" "$InputFile"
  }
}    
else {
  zip -m "$RECYCLEBIN" "$InputFile" 
}