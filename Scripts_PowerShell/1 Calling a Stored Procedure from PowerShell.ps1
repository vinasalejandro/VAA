# Calling a Stored Procedure from PowerShell

#Usamos para crear el procedimieto el .sql con el mismo nombre

Invoke-Sqlcmd -ServerInstance localhost -Database TEMPDB -Query "CustomerSales"



$results = Invoke-Sqlcmd -ServerInstance localhost -Database tempdb -Query "CustomerSales"
foreach ($sale in $results) {Write-Host("Customer: " + $sale.CustomerID + ", TotalSale:$" +$sale.totalsale)}


#Guarda el resultado del procedimiento en un fichero
$results = Invoke-Sqlcmd -ServerInstance localhost -Database tempdb -Query "CustomerSales"
$results | Select-Object CustomerID, totalsale | out-file c:\procesos.txt
notepad c:\procesos.txt

#Guarda en resultado del procedimieto en un .csv
$results = Invoke-Sqlcmd -ServerInstance localhost -Database tempdb -Query "CustomerSales"
$results | Select-Object CustomerID, totalsale | Export-Csv -Path "c:\sales.csv" -NoTypeInformation

notepad c:\sales.csv


###############

# Calling Procs from PowerShell with Parameters

$results = Invoke-Sqlcmd -ServerInstance localhost -Database AdventureWorks2019 -Query "uspGetBillOfMaterials" #no funciona ya que faltan los parámetros de entrada

$results = Invoke-Sqlcmd -ServerInstance localhost -Database AdventureWorks2019 -Query "[dbo].[uspGetBillOfMaterials] @StartProductID = 749, @CheckDate = '2010-05-26'"
$results 

$productid = 749
$checkdate = "2010-05-26"
$results = Invoke-Sqlcmd -ServerInstance localhost -Database AdventureWorks2019 -Query "[dbo].[uspGetBillOfMaterials] @StartProductID = $productid, @CheckDate = '$checkdate'"
$results | Export-Csv -Path "c:\sproc.csv" -NoTypeInformation
notepad sproc.csv


############################3

# ADO.NET

$Server = "localhost"
$Database = "AdventureWorks2019"
$SqlConn = New-Object System.Data.SqlClient.SqlConnection("Server = $Server; Database = $Database; Integrated Security = True;")
$SqlConn.Open()
$cmd = $SqlConn.CreateCommand()
$cmd.CommandType = 'StoredProcedure'
$cmd.CommandText = 'dbo.uspGetBillOfMaterials'
$p1 = $cmd.Parameters.Add('@StartProductID',[int])
$p1.ParameterDirection.Input
$p1.Value = 749
$p2 = $cmd.Parameters.Add('@CheckDate',[DateTime])
$p2.ParameterDirection.Input
$p2.Value = '2010-05-26'
$results = $cmd.ExecuteReader()
$dt = New-Object System.Data.DataTable
$dt.Load($results)
$SqlConn.Close()
$dt | Export-Csv -LiteralPath "C:\sproc.txt" -NoTypeInformation
notepad C:\sproc.txt


















