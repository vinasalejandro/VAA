
#PSDRIVE

Get-location

Install-Module -Name SqlServer #Se usaria esta para instalar

Install-Module -Name SqlServer -AllowClobber #En caso de que la anterior de error se usaria esta


#Para comprobar que el módulo esta correctamente instalado

Get-Module SqlServer -ListAvailable

Update-Module -Name SqlServer -AllowClobber


#Para que aparezca como un nuevo directorio

Import-Module SqlServer


CD SQLSERVER:\
PSDRIVE
Get-Location

Set_location SQLSERVER:\SQL\localhost
Get-ChildItem

#Lists the categories of objets available in the default instance on the local computer

Set-Location SQLSERVER:\SQL\localhost\DEFAULT
Get-ChildItem

#List the databases from the local default instance
#the force parameter is used to include the system databases

#Para ver las bases de datos

Set-Location SQLSERVER:\SQL\localhost\DEFAULT\Databases
Get-ChildItem
ls
Set-Location pubs
ls
Set-Location Tables
ls

