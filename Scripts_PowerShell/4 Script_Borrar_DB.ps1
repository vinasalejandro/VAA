
# Borrar BDdir
#import SQL Server module
Import-Module SQLSERVER 

#replace this with your instance name
$instanceName = "localhost"
$server = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList $instanceName

$dbName = "Alquiler_Avionetas_Prueba" #Nombre de la BD que queramos borrar 

#need to check if database exists, and if it does, drop it
$db = $server.Databases[$dbname]
if ($db)
{
      #we will use KillDatabase instead of Drop
      #Kill database will drop active connections before 
	   #dropping the database
      $server.KillDatabase($dbName)
}

