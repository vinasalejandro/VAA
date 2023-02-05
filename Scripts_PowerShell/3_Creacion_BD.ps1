
Get-InstalledModule -Name "SqlServer"

Install-Module -Name "SqlServer"


#Creamos directorios
New-Item "C:\Scripts" -itemType Directory

New-Item "C:\BD" -itemType Directory


#Creamos la BD desde el script de la ruta

Invoke-SqlCmd -ServerInstance localhost -InputFile C:\scripts\CrearBD_Alquiler_Avionetas.sql

#Lanzamos una Query para borrar la BD

Invoke-SqlCmd -ServerInstance localhost -Query "DROP DATABASE Alquiler_Avionetas_Prueba"

######################################################################################################################################

#create variable with SQL to execute

#creamos la variable con el codigo sql
$sql = "
CREATE DATABASE Alquiler_Avionetas_Prueba
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'Alquiler_Avionetas_Prueba', FILENAME = N'C:\BD\Alquiler_Avionetas_Prueba.mdf' , SIZE = 1048576KB , FILEGROWTH = 262144KB )
 LOG ON 
( NAME = N'Alquiler_Avionetas_Prueba_log', FILENAME = N'C:\BD\Alquiler_Avionetas_Prueba_log.ldf' , SIZE = 524288KB , FILEGROWTH = 131072KB )
GO
 
USE [master]
GO
ALTER DATABASE Alquiler_Avionetas_Prueba SET RECOVERY SIMPLE WITH NO_WAIT
GO
 
ALTER AUTHORIZATION ON DATABASE::Alquiler_Avionetas_Prueba TO [sa]
GO"

Invoke-SqlCmd -ServerInstance localhost -Query $sql #en vez de crear una variable podemos poner el código de la query entre comillas en lugar de llamar a la variable


#########################################################################################################################


# Method # 3 - Create SQL Server Database Using PowerShell and dbatools

# verify you have dbatools module installed
Get-InstalledModule -Name "dbatools"	

Install-Module -Name "dbatools"


###Cremos un BD
#creamos las variables y ejecutamos la creación de la BD con las variables

$SqlInstance = 'localhost'                                                          # SQL Server name 
$Name = 'Alquiler_Avionetas_Prueba'                                                 # database name
$DataFilePath = 'C:\BD\'                                                            # data file path
$LogFilePath = 'C:\BD\'                                                             # log file path
$Recoverymodel = 'Simple'                                                           # recovery model
$Owner = 'sa'                                                                       # database owner
$PrimaryFilesize = 1024                                                             # data file initial size
$PrimaryFileGrowth = 256                                                            # data file autrogrowth amount
$LogSize = 512                                                                      # data file initial size
$LogGrowth = 128                                                                    # data file autrogrowth amount
 
New-DbaDatabase -SqlInstance $SqlInstance -Name $Name -DataFilePath $DataFilePath -LogFilePath $LogFilePath -Recoverymodel $Recoverymodel -Owner $Owner -PrimaryFilesize $PrimaryFilesize -PrimaryFileGrowth $PrimaryFileGrowth -LogSize $LogSize -LogGrowth $LogGrowth | Out-Null


#Comprobamos que se creó la BD

Get-DbaDatabase -SqlInstance $SqlInstance -Database $Name

#Eliminamos la BD

Invoke-SqlCmd -ServerInstance localhost -Query "DROP DATABASE Alquiler_Avionetas_Prueba"


