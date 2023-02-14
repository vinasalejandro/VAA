############# BACKUP Y RESTORE CON UN CDMLET ####################################


# Almacena los BACKUPS en C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\Backup

Backup-SqlDatabase -ServerInstance "localhost" -Database "Alquiler_Avionetas"




# Backup completo con variables y AÑADIENDO LA FECHA


$dt = Get-Date -Format yyyyMMddHHmmss
$instancename = "localhost"
$dbname = 'Alquiler_Avionetas'
Backup-SqlDatabase -Serverinstance $instancename -Database $dbname -BackupFile "c:\BACKUP\$($dbname)_db_$($dt).bak"



###############################    RESTORE  #############################

# Antes del restore

Invoke-Sqlcmd -Serverinstance localhost -Database Pubs -Query 'Alter Database Pubs SET SINGLE_USER WITH ROLLBACK IMMEDIATE;'

#borrar Alquiler_Avionetas

Invoke-Sqlcmd -Serverinstance localhost -Query "Drop database Alquiler_Avionetas;"

#restore
Restore-Sqldatabase -Serverinstance $instancename -Database $dbname -Backupfile "C:\BACKUP\Alquiler_Avionetas_db_20230214202035.bak" -replacedatabase

#fin restore


