$PSVersionTable

#muestra la versión


#Prueba con concepto de variable

$version=$PSVersionTable
$version

####################################################################################

#ayuda

Show-Command

#Ayuda en PS

Get-Help

Get-Help -Full      
Get-Help -ShowWindow

Update-Help


help cmdlet -Full
help Get-Service -ShowWindow
help *network* -ShowWindow
help Get-DisplayResolution


#Funcionan los comandos habituales externos

ping localhost

ipconfig

#borrar pantalla

Clear
Clear-Host

#cmdlets ejecutados (comandos)

Get-History

#Policy Execution Script

Get-ExecutionPolicy

Get-ExecutionPolicy Unrestricted    #Permite ejecutar sin restricciones
Get-ExecutionPolicy RemoteSigned    #Permite ejecutar scripts firmados
Get-ExecutionPolicy Restricted

##########################################################################################################################################

#Manipulando el entorno

#Display the name of the default options

$psISE.Options.DefaultOptions

#Cambia el color de fondo

$psISE.Options.ScriptPaneBackgroundColor = "green"

#Restaura los valores por defecto

$psISE.Options.RestoreDefaults()

#Cambia el color de la letra

$psISE.Options.ConsolePaneBackgroundColor = "blue"

#Cambia el tipo de letra

$psISE.Options.FontName ="courier new"

#cambia el tamaño de la fuente

$psISE.Options.FontSize = 16

#ajusta el zoom

$psISE.Options.Zoom = 175

#restauramos de nuevo

$psISE.Options.RestoreDefaults()

######################################################################################################################################

#ALIAS

alias

Get-Alias ls

#dir is an alias for the cmdlet Get-ChildItem
Get-ChildItem

dir

Get-Alias ft      #ft --> Format-Table


#Obtener alias de un cmdlet

Get-Alias -Definition "Get-Service"

#Crear un alias temporales (cuando cerramos la sesión se borra)

New-Alias -Name d -Value Get-ChildItem

Get-Alias -Definition "Get-ChildItem"

d


####################################################################################################################################################

#PipeLine (tuberias)

Get-Process

#manda los procesos del sistema a un txt y lo muestra en el notepad

Get-Process | Out-File c:\procesos.txt
Notepad C:\procesos.txt


Get-Process | Export-Csv c:\procs.csv
Notepad c:\procs.csv


Get-Process | Out-GridView



###########################################################################################################################################################

#Instalación SQL

Set-PSRepository -name 'PSGallery' -InstallationPolicy Trusted

Install-Module -Name SqlServer

Install-Module -Name SqlServer -AllowClobber





