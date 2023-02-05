############# BACKUP Y RESTORE CON UN CDMLET ####################################


# Almacena los BACKUPS en C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\Backup

Backup-SqlDatabase -ServerInstance "localhost" -Database "Pubs"




# Backup completo con variables y AÑADIENDO LA FECHA


$dt = Get-Date -Format yyyyMMddHHmmss
$instancename = "localhost"
$dbname = 'Trasteros'
Backup-SqlDatabase -Serverinstance $instancename -Database $dbname -BackupFile "c:\BACKUP\$($dbname)_db_$($dt).bak"

Trasteros_db_20221205204130.bak

###############################    RESTORE  #############################

# Antes del restore

Invoke-Sqlcmd -Serverinstance localhost -Database Pubs -Query 'Alter Database Pubs SET SINGLE_USER WITH ROLLBACK IMMEDIATE;'

#borrar Pubs
Restart-Service "MSSQLSERVER" -Force

Invoke-Sqlcmd -Serverinstance localhost -Query "Drop database Trasteros;"

#restore
Restore-Sqldatabase -Serverinstance $instancename -Database $dbname -Backupfile "C:\BACKUP\Trasteros_db_20221205204130.bak" -replacedatabase

#fin restore




##############################  INVOKE   ###############################
 

## Ejecuta comandos en equipos locales y remotos.
Invoke-Sqlcmd -Query "SELECT GETDATE() AS ATimeofQuery" -ServerInstance "."

Invoke-Sqlcmd -Query "SELECT COUNT(*) AS Count FROM Authors" -Database "Pubs"
-ConnecionString "Data Source=.;Initial Catalog=Pubs;Integrated Security=True;ApplicationIntent=ReadOnly" 

Invoke-Sqlcmd -Query "SELECT * FROM Alta_Alquiler" -Database Trasteros |ogv



# Ejecutar SQL(CREAR BASE DE DATOS) con Invoke-SqlCmd
Invoke-SqlCmd -ServerInstance localhost -InputFile "C:\DATABASES_EXAMPLES\Create_MyDatabase.sql"






#################################  FUNCIONES ######################################


# EJEMPLO FUNCION EN PS

#CREAMOS UNA FUNCION PARA OBTENER EL USUARIO ACTUAL

Function UsuarioActual
    { [System.Security.Principal.windowsIdentity]::GetCurrent().Name }

# EJECUTAMOS LA FUNCION
UsuarioActual

DESKTOP-4BR36G5\OMV



# Vamos a obtener las bases de datos de dos formas diferentes

# Con una select de los nombres de las bases de datos
invoke-sqlcmd -serverinstance "localhost" -database master -Query "SELECT name From Sys.databases" | ogv


# Utilizamos un procedimiento almacenado
invoke-sqlcmd -serverinstance "." -database master -Query "EXEC sp_databases" | ogv


