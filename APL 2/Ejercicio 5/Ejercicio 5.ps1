#####                   APL N2                  #####
#####		          Ejercicio 5               #####
#####				Ejercicio 5.ps1              #####

#####			      GRUPO Nº2                 #####
#####         Tebes, Leandro - 40.227.531       #####
#####         Rossy, Gaston L. - 40.137.778     #####
#####	      Zella, Ezequiel - 41.915.248      #####
#####       Cencic, Maximiliano - 41.292.382    #####
#####       Bonvehi, Sebastian - 40.538.404     ##### 

<#
.SYNOPSIS
    El objetivo del script es procesar las notas guardadas en archivos .csv
    y generar un archivo .json con dichas notas a partir de todos los .csv procesados.
.DESCRIPTION
    El objetivo del script es procesar las notas guardadas en archivos .csv
    y generar un archivo JSON con dichas notas a partir de todos los .csv procesados.
    Teniendose que especificar el directorio donde estan alojados los archivos .csv con -Notas
    y el directorio (de ser necesario) + nombre del archivo .JSON a ser generado en -Salida.
.EXAMPLE
    Para utilizar el script debera ser ejecutado de la siguiente manera:
    ./Ejercicio 5.ps1
    -Notas <directorio con los archivos .csv> 
    -Salida <directorio + nombre del archivo .json a generar>
.EXAMPLE
    ./Ejercicio 5.ps1 -Notas ./notas -Salida ./salida.json
#>

Param(
    [Parameter(Mandatory = $True)] [string]$Notas,
    [Parameter(Mandatory = $True)] [string]$Salida
)

$DirectorioNotas = $Notas

if ( -not (Test-Path $DirectorioNotas) ) {
    Write-Error -Message "$DirectorioNotas no es un directorio valido. [1]"
    exit
}

$Dirname = Split-Path -Path "$Salida" 

if ( -not (Test-Path $Dirname) ) {
    Write-Error -Message "$Dirname no es un directorio valido. [2]"
    exit
}

$Extension = Split-Path -Path "$Salida" -Extension
$NombreArchivo = Split-Path -Path "$Salida" -LeafBase

if ($NombreArchivo -eq '') {
    Write-Error -Message "No se ingreso el nombre del archivo a generar."
}

if ($Extension -eq '.json') {
    $SalidaFinal = $Salida
}
elseif ($Extension -eq '') {
    $NombreArchivo = $NombreArchivo + '.json'

    $SalidaFinal = Split-Path -Path "$Salida"
    $SalidaFinal = "$SalidaFinal/$NombreArchivo"
}
else {
    Write-Error -Message "Extension del archivo a generar inválida ."
    exit 
}

$DirectorioCSV = $DirectorioNotas + '/*.csv'

$Array = Split-Path -Path "$DirectorioCSV" -Leaf -Resolve

$FlagPrimerArchivo = 1

foreach ($Archivo in $Array) {

    if ($FlagPrimerArchivo -eq 1) {
        $ArrayNotas = New-Object System.Collections.ArrayList
        $Alumnos = New-Object System.Collections.ArrayList

        $FlagPrimerArchivo = 0
    }
    
    $csv = "$DirectorioNotas/$Archivo"
    $CantidadEj = (Get-Content $csv -TotalCount 1).Split(',').Count - 1

    $valorCadaEjercicio = 10 / $CantidadEj
    $NotaAlumno = 0

    $Cabecera = @('DNI')

    (1..$CantidadEj) | ForEach-Object { $Cabecera += "ej$_" }

    $Body = Import-Csv -Path $csv -Header $Cabecera 

    $DniYNota = @()


    foreach ($Row in $Body) {
        $NotaAlumno = 0
        $Columna = 1
        foreach ($Campo in $Cabecera) {
            if ($Columna -eq 1) {
                $DniAlumno = $Row.$Campo
            }
            if ($Row.$Campo -eq 'b') {
                $NotaAlumno += $valorCadaEjercicio
            }
            elseif ($Row.$Campo -eq 'r') {
                $NotaAlumno += $valorCadaEjercicio / 2
            }
            
            $Columna = $Columna + 1
        }

        $DniYNota += $DniAlumno
        $DniYNota += $NotaAlumno
    }

    $Materia = [int]$Archivo.Substring(0, $Archivo.IndexOf("_"))

    $Json = @{}
    $Json.Add("actas", $Alumnos)


    for ($i = 0; $i -lt $DniYNota.Length; $i += 2) {

        $FlagMateriaRendida = 0
        $Dni = $DniYNota[$i]
        $Nota = $DniYNota[$i + 1]

        $Documentos = $Json | ForEach-Object { $_.actas.dni }
        
        if ($Documentos -contains "$Dni" -eq "True") {
            if($Documentos.Count -gt 0) {
                $Index = [Array]::IndexOf($Documentos, "$Dni")
                if($Index -ge 0){
                    $Alumnito = $Alumnos[$Index]
                    $NotasAlumno = $Alumnito.notas
        
                    foreach($NotitaAlumno in $NotasAlumno){
    
                        if($NotitaAlumno.Materia -eq "$Materia"){
                            Write-Warning ('El alumno ' + $Dni + ' rindio mas de una vez la materia: ' + $Materia + '. No se lo volvio a agregar.')
                            $FlagMateriaRendida = 1
                        }
                    }
                    
                    if($FlagMateriaRendida -eq 0){
                        [void]$NotasAlumno.Add([ordered]@{"materia" = $Materia; "nota" = $Nota})
                    }
        
                }
            }
        }
        else {
            $ArrayNotas = New-Object System.Collections.ArrayList
            [void]$ArrayNotas.Add([ordered]@{"materia" = $Materia; "nota" = $Nota})
            [void]$Alumnos.Add([ordered]@{"dni" = "$Dni"; "notas" = $ArrayNotas})
        }

        $Json | ConvertTo-Json -Depth 10 | Out-File "$SalidaFinal"
    }

}