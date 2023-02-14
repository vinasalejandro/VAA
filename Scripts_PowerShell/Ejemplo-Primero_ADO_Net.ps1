
#Listing 1: Retrieving Data Through a SqlDataReader Object

#Listado de datos con string

#Ejemplo con AdventureWorks2019

# Create SqlConnection object and define connection string
$con = New-Object System.Data.SqlClient.SqlConnection
$con.ConnectionString = "Server=.; Database=AdventureWorks2019;   Integrated Security=true"
$con.open()

# Create SqlCommand object, define command text, and set the connection
$cmd = New-Object System.Data.SqlClient.SqlCommand
$cmd.CommandText = "SELECT TOP 10 FirstName, LastName FROM Person.Person"
$cmd.Connection = $con

# Create SqlDataReader
$dr = $cmd.ExecuteReader()

Write-Host

If ($dr.HasRows)
{
  Write-Host Number of fields: $dr.FieldCount
  Write-Host
  While ($dr.Read())
  {
    Write-Host $dr["FirstName"] $dr["LastName"]
  }
}
Else
{
  Write-Host The DataReader contains no rows.
}

Write-Host

# Close the data reader and the connection
$dr.Close()
$con.Close()



########################################################################################################################################

#Ejemplo con pubs (tabla authors, muestra el id y el nombre)

# Create SqlConnection object and define connection string
$con = New-Object System.Data.SqlClient.SqlConnection
$con.ConnectionString = "Server=.; Database=pubs;   Integrated Security=true"
$con.open()

# Create SqlCommand object, define command text, and set the connection
$cmd = New-Object System.Data.SqlClient.SqlCommand
$cmd.CommandText = "SELECT TOP 10 au_id, au_lname FROM dbo.authors"
$cmd.Connection = $con

# Create SqlDataReader
$dr = $cmd.ExecuteReader()

Write-Host

If ($dr.HasRows)
{
  Write-Host Number of fields: $dr.FieldCount
  Write-Host
  While ($dr.Read())
  {
    Write-Host $dr["au_id"] $dr["au_lname"]
  }
}
Else
{
  Write-Host The DataReader contains no rows.
}

Write-Host

# Close the data reader and the connection
$dr.Close()
$con.Close()




#Ejemplo con la Alquiler_Avionetas (tabla clientes, muestra DNI y nombre)



$con = New-Object System.Data.SqlClient.SqlConnection
$con.ConnectionString = "Server=.; Database=Alquiler_Avionetas;   Integrated Security=true"
$con.open()


$cmd = New-Object System.Data.SqlClient.SqlCommand
$cmd.CommandText = "SELECT TOP 10 nombre, DNI FROM dbo.cliente"
$cmd.Connection = $con


$dr = $cmd.ExecuteReader()

Write-Host

If ($dr.HasRows)
{
  Write-Host Number of fields: $dr.FieldCount
  Write-Host
  While ($dr.Read())
  {
    Write-Host $dr["Nombre"] $dr["DNI"]
  }
}
Else
{
  Write-Host The DataReader contains no rows.
}

Write-Host


$dr.Close()
$con.Close()