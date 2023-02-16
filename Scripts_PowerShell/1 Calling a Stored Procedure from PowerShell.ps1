# Calling a Stored Procedure from PowerShell

#Usamos para crear el procedimieto el .sql con el mismo nombre

Invoke-Sqlcmd -ServerInstance localhost -Database Alquiler_Avionetas -Query "Precio_total" ##Ejecuta el procedimiento almacenado "Precio_total"



#$results = Invoke-Sqlcmd -ServerInstance localhost -Database tempdb -Query "CustomerSales"
#foreach ($sale in $results) {Write-Host("Customer: " + $sale.CustomerID + ", TotalSale:$" +$sale.totalsale)}


#Guarda el resultado del procedimiento en un fichero
$results = Invoke-Sqlcmd -ServerInstance localhost -Database Alquiler_avionetas -Query "Precio_total"
$results | Select-Object ID_cliente, Precio_total | out-file c:\precio.txt
notepad c:\precio.txt

#Guarda en resultado del procedimieto en un .csv
$results = Invoke-Sqlcmd -ServerInstance localhost -Database Alquiler_Avionetas -Query "Precio_total"
$results | Select-Object ID_cliente, Precio_total | Export-Csv -Path "c:\precio.csv" -NoTypeInformation

notepad c:\precio.csv


###############


# Calling Procs from PowerShell with Parameters

#Ejecutar procedimientos almacenados con parámetros de entrada

$results = Invoke-Sqlcmd -ServerInstance localhost -Database AdventureWorks2019 -Query "uspGetBillOfMaterials" #no funciona ya que faltan los parámetros de entrada

#Añadimos parámetros de entrada
$results = Invoke-Sqlcmd -ServerInstance localhost -Database AdventureWorks2019 -Query "[dbo].[uspGetBillOfMaterials] @StartProductID = 749, @CheckDate = '2010-05-26'"
$results 

#Añadimos los parámetros de entrada como variables
$productid = "749"
$checkdate = "2010-05-26"
$results = Invoke-Sqlcmd -ServerInstance localhost -Database AdventureWorks2019 -Query "[dbo].[uspGetBillOfMaterials] @StartProductID = $productid, @CheckDate = '$checkdate'"
$results | Export-Csv -Path "c:\sproc.csv" -NoTypeInformation
notepad c:\sproc.csv


#############################################################################################################################################################

# ADO.NET

$Server = "localhost"
$Database = "AdventureWorks2019"
$SqlConn = New-Object System.Data.SqlClient.SqlConnection("Server = $Server; Database = $Database; Integrated Security = True;") #Se usa la libreria de clases de ADO.net y se añade la cadena de conexión
$SqlConn.Open() #abrimos la conexión
$cmd = $SqlConn.CreateCommand() #creamos el objeto

#Llamamos el procedimiento almacenado
$cmd.CommandType = 'StoredProcedure'
$cmd.CommandText = 'dbo.uspGetBillOfMaterials'

#Añadimos parámetros de entrada
$p1 = $cmd.Parameters.Add('@StartProductID',[int])
$p1.ParameterDirection.Input
$p1.Value = 749
$p2 = $cmd.Parameters.Add('@CheckDate',[DateTime])
$p2.ParameterDirection.Input
$p2.Value = '2010-05-26'

$results = $cmd.ExecuteReader()
$dt = New-Object System.Data.DataTable
$dt.Load($results)

$SqlConn.Close() #cerramos la conexión

$dt | Export-Csv -LiteralPath "C:\sproc.txt" -NoTypeInformation
notepad C:\sproc.txt


















