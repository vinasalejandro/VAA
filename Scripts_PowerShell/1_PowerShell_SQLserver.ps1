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

