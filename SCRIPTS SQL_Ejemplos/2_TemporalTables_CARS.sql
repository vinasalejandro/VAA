

-- How to Use SQL Temporal Tables For Easy Point-In-Time Analysis
-- https://bertwagner.com/posts/how-to-use-sql-temporal-tables-for-easy-point-in-time-analysis/


-- https://bertwagner.com/category/sql/development/temporal-tables/page/2/

DROP DATABASE IF EXISTS CAR
GO
CREATE DATABASE CAR
GO
USE CAR
GO
---------- 
DROP TABLE IF EXISTS CarInventory
GO
DROP TABLE IF EXISTS CarInventoryHistory
GO
----------
IF OBJECT_ID('dbo.CarInventory', 'U') IS NOT NULL 
BEGIN
    -- When deleting a temporal table, we need to first turn versioning off
    ALTER TABLE [dbo].[CarInventory] SET ( SYSTEM_VERSIONING = OFF  ) 
    DROP TABLE dbo.CarInventory
    DROP TABLE dbo.CarInventoryHistory
END
--------------
CREATE TABLE CarInventory   
(    
    CarId INT IDENTITY PRIMARY KEY,
    Year INT,
    Make VARCHAR(40),
    Model VARCHAR(40),
    Color varchar(10),
    Mileage INT,
    InLot BIT NOT NULL DEFAULT 1,
    SysStartTime datetime2 GENERATED ALWAYS AS ROW START NOT NULL,
    SysEndTime datetime2 GENERATED ALWAYS AS ROW END NOT NULL,
    PERIOD FOR SYSTEM_TIME (SysStartTime, SysEndTime)     
)   
WITH 
( 
    SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.CarInventoryHistory)   
);
GO
SELECT * FROM CarInventory
GO
SELECT * FROM [CarInventoryHistory]
GO
INSERT INTO dbo.CarInventory (Year,Make,Model,Color,Mileage) VALUES(2017,'Chevy','Malibu','Black',0)
INSERT INTO dbo.CarInventory (Year,Make,Model,Color,Mileage) VALUES(2017,'Chevy','Malibu','Silver',0)
GO

--aparecen los datos insertados
SELECT * FROM CarInventory
GO
--CarId	Year	Make	Model	Color	Mileage	InLot	SysStartTime					SysEndTime
--1		2017	Chevy	Malibu	Black	0			1	2021-01-17 18:50:34.3437580	9999-12-31 23:59:59.9999999
--2		2017	Chevy	Malibu	Silver	0			1	2021-01-17 18:50:34.3437580	9999-12-31 23:59:59.9999999

--no aparecen ya que no hubo modificaciones
SELECT * FROM [CarInventoryHistory]
GO

-- CarId	Year	Make	Model	Color	Mileage	InLot	SysStartTime	SysEndTime

-- You'll notice that since we've only inserted one row for each our cars, there's no row history yet and therefore our historical table is empty.

-- Let's change that by getting some customers and renting out our cars!

UPDATE dbo.CarInventory SET InLot = 0 WHERE CarId = 1
UPDATE dbo.CarInventory SET InLot = 0 WHERE CarId = 2
GO
SELECT * FROM CarInventory
GO

--CarId	Year	Make	Model	Color	Mileage	InLot		SysStartTime			SysEndTime
--1	2017	Chevy	Malibu	Black	0	0	2021-01-17		18:52:10.3974371	9999-12-31 23:59:59.9999999
--2	2017	Chevy	Malibu	Silver	0	0	2021-01-17		18:52:10.4930912	9999-12-31 23:59:59.9999999

SELECT * FROM [CarInventoryHistory]
GO

--CarId	Year	Make	Model	Color	Mileage	InLot	SysStartTime					SysEndTime
--1	2017	Chevy	Malibu	Black	0	1	2021-01-17	18:50:34.3437580		2021-01-17 18:52:10.3974371
--2	2017	Chevy	Malibu	Silver	0	1	2021-01-17	18:50:34.3437580		2021-01-17 18:52:10.4930912

-- After a while, our customers return their rental cars:

UPDATE dbo.CarInventory SET InLot = 1, Mileage = 73  WHERE CarId = 1
UPDATE dbo.CarInventory SET InLot = 1, Mileage = 488 WHERE CarId = 2
GO
SELECT * FROM CarInventory
GO

--CarId	Year	Make	Model	Color	Mileage	InLot			SysStartTime					SysEndTime
--1	2017	Chevy	Malibu	Black	73	1		2021-01-17		18:55:43.4733240	9999-12-31 23:59:59.9999999
--2	2017	Chevy	Malibu	Silver	488	1		2021-01-17		18:55:43.4875519	9999-12-31 23:59:59.9999999

SELECT * FROM [CarInventoryHistory]
GO

--CarId	Year	Make	Model	Color	Mileage	InLot	SysStartTime	SysEndTime
--1	2017	Chevy	Malibu	Black	0	1	2021-01-17 18:50:34.3437580	2021-01-17 18:52:10.3974371
--2	2017	Chevy	Malibu	Silver	0	1	2021-01-17 18:50:34.3437580	2021-01-17 18:52:10.4930912
--1	2017	Chevy	Malibu	Black	0	0	2021-01-17 18:52:10.3974371	2021-01-17 18:55:43.4733240
--2	2017	Chevy	Malibu	Silver	0	0	2021-01-17 18:52:10.4930912	2021-01-17 18:55:43.4875519


-- Our temporal table show the current state of our rental cars: 
-- the customers have returned the cars back to our lot and each car has accumulated some mileage.

--Our historical table meanwhile got a copy of the rows from our temporal table right before our 
-- last UPDATE statement. It's automatically keeping track of all of this history for us!

--Continuing on, business is going well at the car rental agency. 
-- We get another customer to rent our silver Malibu:

UPDATE dbo.CarInventory SET InLot = 0 WHERE CarId = 2
GO

SELECT * FROM CarInventory
GO

--CarId	Year	Make	Model	Color	Mileage	InLot			SysStartTime	SysEndTime
--1	2017	Chevy	Malibu	Black	73	1	2021-01-17		18:55:43.4733240	9999-12-31 23:59:59.9999999
--2	2017	Chevy	Malibu	Silver	488	0	2021-01-17		18:57:37.4461735	9999-12-31 23:59:59.9999999


SELECT * FROM [CarInventoryHistory]
GO

--CarId	Year	Make	Model	Color	Mileage	InLot			SysStartTime	SysEndTime
--1	2017	Chevy	Malibu	Black	0	1	2021-01-17			18:50:34.3437580	2021-01-17 18:52:10.3974371
--2	2017	Chevy	Malibu	Silver	0	1	2021-01-17			18:50:34.3437580	2021-01-17 18:52:10.4930912
--1	2017	Chevy	Malibu	Black	0	0	2021-01-17			18:52:10.3974371	2021-01-17 18:55:43.4733240
--2	2017	Chevy	Malibu	Silver	0	0	2021-01-17			18:52:10.4930912	2021-01-17 18:55:43.4875519
--2	2017	Chevy	Malibu	Silver	488	1	2021-01-17			18:55:43.4875519	2021-01-17 18:57:37.4461735


-- Unfortunately, our second customer gets into a crash and destroys our car:
PRINT GETDATE()
GO
DELETE FROM dbo.CarInventory WHERE CarId = 2
GO
SELECT * FROM CarInventory
GO

--CarId	Year	Make	Model	Color	Mileage	InLot			SysStartTime	SysEndTime
--1	2017	Chevy	Malibu	Black	73	1	2021-01-17			18:55:43.4733240	9999-12-31 23:59:59.9999999


SELECT * FROM [CarInventoryHistory]
GO

--CarId	Year	Make	Model	Color	Mileage	InLot	SysStartTime	SysEndTime
--1	2017	Chevy	Malibu	Black	0	1	2021-01-17 18:50:34.3437580	2021-01-17 18:52:10.3974371
--2	2017	Chevy	Malibu	Silver	0	1	2021-01-17 18:50:34.3437580	2021-01-17 18:52:10.4930912
--1	2017	Chevy	Malibu	Black	0	0	2021-01-17 18:52:10.3974371	2021-01-17 18:55:43.4733240
--2	2017	Chevy	Malibu	Silver	0	0	2021-01-17 18:52:10.4930912	2021-01-17 18:55:43.4875519
--2	2017	Chevy	Malibu	Silver	488	1	2021-01-17 18:55:43.4875519	2021-01-17 18:57:37.4461735
--2	2017	Chevy	Malibu	Silver	488	0	2021-01-17 18:57:37.4461735	2021-01-17 18:59:51.6703003

--With the deletion of our silver Malibu, our test data is complete.

--Now that we have all of this great historically tracked data, how can we query it?

--If we want to reminisce about better times when both cars were damage free 
--and we were making money, we can write a query using SYSTEM_TIME AS OF 
-- to show us what our table looked like at that point in the past:

SELECT    *
FROM     dbo.CarInventory
FOR SYSTEM_TIME AS OF '2021-01-17 18:55:43.4875519'
GO

--CarId	Year	Make	Model	Color	Mileage	InLot	SysStartTime	SysEndTime
--1	2017	Chevy	Malibu	Black	73	1	2021-01-17 18:55:43.4733240	9999-12-31 23:59:59.9999999
--2	2017	Chevy	Malibu	Silver	488	1	2021-01-17 18:55:43.4875519	2021-01-17 18:57:37.4461735


-- And if we want to do some more detailed analysis,
-- like what rows have been deleted, we can query both temporal and historical tables normally as well:

-- Find the CarIds of cars that have been wrecked and deleted





--muestra el número de registros borrados

SELECT DISTINCT    hist.CarId AS DeletedCarId
FROM    dbo.CarInventory t
    RIGHT JOIN CarInventoryHistory hist
    ON t.CarId = hist.CarId 
WHERE     t.CarId IS NULL
GO

-- 2

select * 
from dbo.CarInventory
for system_time all 
go

--CarId	Year	Make	Model	Color	Mileage	InLot	SysStartTime	SysEndTime
--1	2017	Chevy	Malibu	Black	73	1	2021-01-17 18:55:43.4733240	9999-12-31 23:59:59.9999999
--1	2017	Chevy	Malibu	Black	0	1	2021-01-17 18:50:34.3437580	2021-01-17 18:52:10.3974371
--2	2017	Chevy	Malibu	Silver	0	1	2021-01-17 18:50:34.3437580	2021-01-17 18:52:10.4930912
--1	2017	Chevy	Malibu	Black	0	0	2021-01-17 18:52:10.3974371	2021-01-17 18:55:43.4733240
--2	2017	Chevy	Malibu	Silver	0	0	2021-01-17 18:52:10.4930912	2021-01-17 18:55:43.4875519
--2	2017	Chevy	Malibu	Silver	488	1	2021-01-17 18:55:43.4875519	2021-01-17 18:57:37.4461735
--2	2017	Chevy	Malibu	Silver	488	0	2021-01-17 18:57:37.4461735	2021-01-17 18:59:51.6703003

select CarId,Year,Make,Model,Color,Mileage,InLot
from dbo.CarInventory
for system_time all 
go

--CarId	Year	Make	Model	Color	Mileage	InLot
--1	2017	Chevy	Malibu	Black	73	1
--1	2017	Chevy	Malibu	Black	0	1
--2	2017	Chevy	Malibu	Silver	0	1
--1	2017	Chevy	Malibu	Black	0	0
--2	2017	Chevy	Malibu	Silver	0	0
--2	2017	Chevy	Malibu	Silver	488	1
--2	2017	Chevy	Malibu	Silver	488	0
---------------------

-- https://docs.microsoft.com/es-es/sql/relational-databases/tables/temporal-tables?view=sql-server-ver15

-- https://www.sqlshack.com/temporal-tables-in-sql-server/


-- Otros ejemplo sde consultas

SELECT * FROM Employee
  FOR SYSTEM_TIME
    BETWEEN '2014-01-01 00:00:00.0000000' AND '2015-01-01 00:00:00.0000000'
      WHERE EmployeeID = 1000 ORDER BY ValidFrom;
go



