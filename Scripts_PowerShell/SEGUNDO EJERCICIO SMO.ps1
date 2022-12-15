# get-executionpolicy
# set-executionpolicy unrestricted
# Crear Base de datos

# Lo primero es importar la librería de SQLServer (si no la tenemos)
Import-Module SQLSERVER

# Cargamos en una variable el nombre de nuestro equipo y la instancia
$instanceName = "localhost"
$server = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList $instanceName

# Comprobamos que no existe la base de datos , que queremos crear, listando las bases de datos de nuestro servidor
$server.Databases | Select Name, Status, Owner, CreateDate 


# Creamos una BD nueva "Prueba"
$dbName = "prueba2"
$db = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Database($server, $dbName)
$db.Create()

# Comprobamos que esta creada
$server.Databases | Select Name, Status, Owner, CreateDate 
