-- Calling a Stored Procedure from PowerShell
-- https://www.sqlservercentral.com/articles/calling-a-stored-procedure-from-powershell

USE tempdb
GO
create table SalesOrder
( SaleID int,
  LineNumber int,
  SaleDate datetime,
  CustomerID int,
  ProductID int,
  Qty int,
  Price numeric(10,4),
  LineTotal numeric(10,4)
)
go
insert SalesOrder ( SaleID, LineNumber, SaleDate, CustomerID, ProductID, Qty, Price, LineTotal)
 values 
  ( 10, 1, '6/11/2020', 1, 50, 2, 100, 200),
  ( 10, 2, '6/11/2020', 1, 51, 20, 50, 1000),
  ( 20, 1, '6/15/2020', 4, 52, 50, 10, 500),
  ( 30, 1, '6/15/2020', 6, 53, 10, 60, 600),
  ( 30, 2, '6/15/2020', 6, 54, 2, 60, 12),
  ( 30, 3, '6/15/2020', 6, 55, 100, 50, 5000),
  ( 40, 1, '6/19/2020', 7, 50, 20, 100, 2000),
  ( 50, 1, '6/25/2020', 1, 50, 40, 100, 4000),
  ( 50, 2, '6/25/2020', 1, 57, 40, 25, 1000),
  ( 50, 3, '6/25/2020', 1, 58, 80, 50, 4000)
go
select * from SalesOrder
go

create or alter procedure CustomerSales
as
begin
   select CustomerID,
          sum(qty) as totalunits,
  avg(price) as averageprice,
          sum(Linetotal) as totalsale
    from SalesOrder
group by CustomerID
end
go

EXECUTE CustomerSales
GO

--CustomerID	totalunits	averageprice	totalsale
--1	182	65.000000	10200.0000
--4	50	10.000000	500.0000
--6	112	56.666666	5612.0000
--7	20	100.000000	2000.0000

--Invoke-SqlCmd
--When PowerShell first came out, connecting to SQL Server was a hassle. In fact, it remained a pain until the SqlServer module was released in the PowerShell Gallery. It can be a pain to set up, so I'll do another article on that, but for now, I'll assume you have this module installed.

--One of the cmdlets in his module is the Invoke-SqlCmd, which allows you to execute a batch against a SQL Server, just as if you were connected to SQL Server.

--I can do this directly by typing in a few parameter values. I'll describe them here:

--ServerInstance - The SQL Server instance  to connect to
--Database - The database in which to run the command. If you don't include this, the query will run in your default database.
--Query - The batch commands to run.

-- For my simple procedure, I can run a powershell cmdlet and get results on the screen, as you see here.

-- Invoke-Sqlcmd -ServerInstance localhost -Database TEMPDB -Query "CustomerSales"

--This uses my Windows account to connect, but I could have included the -UserName and -Password parameters if I wanted.

--As you can see, the results are formatted on the screen as though they are in a table. However, an object is really returned, and I can use that to capture results and display them selectively, or even write them to a file.

--As an example, this result set has 4 fields. What if I just want the CustomerID and the total sale? In that case, I can assign the results to a variable, and then I can output data from that variable. For example, here is a short script:

--$results = Invoke-Sqlcmd -ServerInstance localhost -Database tempdb -Query "CustomerSales"
--foreach ($sale in $results) {Write-Host("Customer: " + $sale.CustomerID + ", TotalSale:$" +$sale.totalsale)}

-- If I wanted to output these to a file, I could use Select-Object to pick certain fields, and then the Export-Csv cmdlet to write this to a file. I string this together, passing in my $results variable. like this:

 -- $results | Select-Object CustomerID, totalsale | Export-Csv -Path "sales.csv" -NoTypeInformation
-- If I open up the file, sales.csv

-- If I skipped the entire Select-Object part of the script, I'd run this:

-- $results | Export-Csv -Path "sales2.txt" -NoTypeInformation

-- Calling Procs from PowerShell with Parameters
-- https://www.sqlservercentral.com/articles/calling-procs-from-powershell-with-parameters

--Finding a Sproc in AdventureWorks
--I restored a copy of AdventureWorks2017 on my development instance. In here, there are a few sprocs, one of which is [dbo].[uspGetBillOfMaterials]. This takes two parameters, a product ID and a date. With a little experimenting, I found that using a product of 749 and a date of May 26, 2010 gets me some data. I can see this with a scripted execution in SSMS.

USE [AdventureWorks2019]
GO

SELECT * FROM 
DECLARE @RC INT
DECLARE @STARTPRODUCTID INT = 749
DECLARE @CHECKDATE DATETIME = '2010-05-26'

EXEC @RC = [dbo].[uspGetBillOfMaterials] @STARTPRODUCTID, @CHECKDATE
GO

EXECUTE [dbo].[uspGetBillOfMaterials] @StartProductID = 749, @CheckDate = '2010-05-26'
GO

--A Better Way to Declare Parameters
--The problem with doing things this way is that you are essentially building a string out of parameter values. Doing this in .NET code, or really any code, has been a recipe for SQL Injection. I would like to avoid this, so that means I want to use a more secure method of specifying specific parameter values, not building a string from other strings.

--To do this, I need to use some of the .NET classes to construct my code. This feels complex, but it's not that hard. Once you have the code, you can use this over and over. Here's how I'd do it.

--First, I need to get a connection and open it. I'll do that, but set a couple variables.





