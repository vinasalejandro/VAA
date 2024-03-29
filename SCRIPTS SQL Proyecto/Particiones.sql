
USE master
GO


-- CREATE FOLDER DATA

DROP DATABASE IF EXISTS Alquiler_Avionetas 
GO
CREATE DATABASE Alquiler_Avionetas
	ON PRIMARY ( NAME = 'Alquiler_Avionetas', 
		FILENAME = 'C:\Data\Alquiler_Avionetas_Fijo.mdf' , 
		SIZE = 15360KB , MAXSIZE = UNLIMITED, FILEGROWTH = 0) 
	LOG ON ( NAME = 'Alquiler_Avionetas_log', 
		FILENAME = 'C:\Data\Alquiler_Avionetas_log.ldf' , 
		SIZE = 10176KB , MAXSIZE = 2048GB , FILEGROWTH = 10%) 
GO



USE Alquiler_Avionetas
GO
-- CREAMOS LOS FILEGROUPS
ALTER DATABASE [Alquiler_Avionetas] ADD FILEGROUP [Fechas_Archivo] 
GO 
ALTER DATABASE [Alquiler_Avionetas] ADD FILEGROUP [Fechas_2016] 
GO 
ALTER DATABASE [Alquiler_Avionetas] ADD FILEGROUP [Fechas_2017] 
GO 
ALTER DATABASE [Alquiler_Avionetas] ADD FILEGROUP [Fechas_2018]
GO

select * from sys.filegroups
GO

-- -- CREATE FILES

ALTER DATABASE [Alquiler_Avionetas] ADD FILE ( NAME = 'Fechas_Archivo', FILENAME = 'c:\DATA\Fechas_Archivo.ndf', SIZE = 5MB, MAXSIZE = 100MB, FILEGROWTH = 2MB ) TO FILEGROUP [Fechas_Archivo] 
GO
ALTER DATABASE [Alquiler_Avionetas] ADD FILE ( NAME = 'Fechas_2016', FILENAME = 'c:\DATA\Fechas_2016.ndf', SIZE = 5MB, MAXSIZE = 100MB, FILEGROWTH = 2MB ) TO FILEGROUP [Fechas_2016] 
GO
ALTER DATABASE [Alquiler_Avionetas] ADD FILE ( NAME = 'Fechas_2017', FILENAME = 'c:\DATA\Fechas_2017.ndf', SIZE = 5MB, MAXSIZE = 100MB, FILEGROWTH = 2MB ) TO FILEGROUP [Fechas_2017] 
GO
ALTER DATABASE [Alquiler_Avionetas] ADD FILE ( NAME = 'Fechas_2018', FILENAME = 'c:\DATA\Fechas_2018.ndf', SIZE = 5MB, MAXSIZE = 100MB, FILEGROWTH = 2MB ) TO FILEGROUP [Fechas_2018] 
GO


select * from sys.filegroups
GO

select * from sys.database_files
GO


-- PARTITION FUNCTION
-- BOUNDARIES (LIMITES)

CREATE PARTITION FUNCTION Fecha_Alquiler (datetime) 
AS RANGE RIGHT 
	FOR VALUES ('2016-01-01','2017-01-01')
GO

-- PARTITION SCHEME

CREATE PARTITION SCHEME alquiler_fecha 
AS PARTITION Fecha_Alquiler 
	TO (Fechas_Archivo,Fechas_2016,Fechas_2017,Fechas_2018) 
GO


DROP TABLE IF EXISTS Fechas_Alquiler
GO
CREATE TABLE Fechas_Alquiler
	( id_alquiler int identity (1,1), 
	nombre varchar(20), 
	apellido varchar (20), 
	fecha_alquiler datetime ) 
	ON alquiler_fecha -- partition scheme
		(fecha_alquiler) -- the column to apply the function within the scheme
GO

-- SSMS TABLE PROPERTIES PARTITIONS

INSERT INTO Fechas_Alquiler
	Values ('Pedro','�lvarez','2015-01-01'), 
			('Alejandro','Vi�as','2015-05-05'), 
			('Alicia','P�rez','2015-08-11')
Go


----------------
-- METADATA INFORMATION

SELECT *,$Partition.Fecha_Alquiler(fecha_alquiler) AS Partici�n
FROM Fechas_Alquiler
GO

--id_alquiler	nombre	apellido	fecha_alta	Partition
--1	Pedro	�lvarez	2015-01-01 00:00:00.000	1
--2	Alejandro	Vi�as	2015-05-05 00:00:00.000	1
--3	Alicia	P�rez	2015-08-11 00:00:00.000	1


-- partition function
select name, create_date, value from sys.partition_functions f 
inner join sys.partition_range_values rv 
on f.function_id=rv.function_id 
where f.name = 'Fecha_Alquiler'
GO

--name	create_date	value
--Fecha_Alquiler	2022-11-28 21:10:20.880	2016-01-01 00:00:00.000
--Fecha_Alquiler	2022-11-28 21:10:20.880	2017-01-01 00:00:00.000

select p.partition_number, p.rows from sys.partitions p 
inner join sys.tables t 
on p.object_id=t.object_id and t.name = 'Fechas_Alquiler' 
GO

--partition_number	rows
--1					3
--2					0
--3					0

DECLARE @TableName NVARCHAR(200) = N'Fechas_Alquiler' 
SELECT SCHEMA_NAME(o.schema_id) + '.' + OBJECT_NAME(i.object_id) AS [object] , p.partition_number AS [p#] , fg.name AS [filegroup] , p.rows , au.total_pages AS pages , CASE boundary_value_on_right WHEN 1 THEN 'less than' ELSE 'less than or equal to' END as comparison , rv.value , CONVERT (VARCHAR(6), CONVERT (INT, SUBSTRING (au.first_page, 6, 1) + SUBSTRING (au.first_page, 5, 1))) + ':' + CONVERT (VARCHAR(20), CONVERT (INT, SUBSTRING (au.first_page, 4, 1) + SUBSTRING (au.first_page, 3, 1) + SUBSTRING (au.first_page, 2, 1) + SUBSTRING (au.first_page, 1, 1))) AS first_page FROM sys.partitions p INNER JOIN sys.indexes i ON p.object_id = i.object_id AND p.index_id = i.index_id INNER JOIN sys.objects o
ON p.object_id = o.object_id INNER JOIN sys.system_internals_allocation_units au ON p.partition_id = au.container_id INNER JOIN sys.partition_schemes ps ON ps.data_space_id = i.data_space_id INNER JOIN sys.partition_functions f ON f.function_id = ps.function_id INNER JOIN sys.destination_data_spaces dds ON dds.partition_scheme_id = ps.data_space_id AND dds.destination_id = p.partition_number INNER JOIN sys.filegroups fg ON dds.data_space_id = fg.data_space_id LEFT OUTER JOIN sys.partition_range_values rv ON f.function_id = rv.function_id AND p.partition_number = rv.boundary_id WHERE i.index_id < 2 AND o.object_id = OBJECT_ID(@TableName);
GO

--object			p#	filegroup	rows	pages	comparison	value	first_page
--dbo.Fechas_Alquiler	1	Fechas_Archivo	3	9	less than	2016-01-01 00:00:00.000	3:8
--dbo.Fechas_Alquiler	2	Fechas_2016	0	0	less than	2017-01-01 00:00:00.000	0:0
--dbo.Fechas_Alquiler	3	Fechas_2017	0	0	less than	NULL	0:0


INSERT INTO Fechas_Alquiler 
	VALUES ('Juan','L�pez','2016-06-23'), 
	('Ana Maria','V�zquez','2016-02-03'), 
	('Carlos','Rodriguez','2016-04-06')
GO

SELECT *,$Partition.Fecha_Alquiler(fecha_alquiler) AS Partition
FROM Fechas_Alquiler
GO

--1	Pedro	�lvarez	2015-01-01 00:00:00.000	1
--2	Alejandro	Vi�as	2015-05-05 00:00:00.000	1
--3	Alicia	P�rez	2015-08-11 00:00:00.000	1
--4	Juan	L�pez	2016-06-23 00:00:00.000	2
--5	Ana Maria	V�zquez	2016-02-03 00:00:00.000	2
--6	Carlos	Rodriguez	2016-04-06 00:00:00.000	2


select name, create_date, value from sys.partition_functions f 
inner join sys.partition_range_values rv 
on f.function_id=rv.function_id 
where f.name = 'Fecha_Alquiler'
GO

--name				create_date	value
---Fecha_Alquiler	2022-11-28 21:10:20.880	2016-01-01 00:00:00.000
--Fecha_Alquiler	2022-11-28 21:10:20.880	2017-01-01 00:00:00.000


select p.partition_number, p.rows from sys.partitions p 
inner join sys.tables t 
on p.object_id=t.object_id and t.name = 'Fechas_Alquiler' 
GO

--partition_number	rows
--1					3
--2					3
--3					0


DECLARE @TableName NVARCHAR(200) = N'Fechas_Alquiler' 
SELECT SCHEMA_NAME(o.schema_id) + '.' + OBJECT_NAME(i.object_id) AS [object] , p.partition_number AS [p#] , fg.name AS [filegroup] , p.rows , au.total_pages AS pages , CASE boundary_value_on_right WHEN 1 THEN 'less than' ELSE 'less than or equal to' END as comparison , rv.value , CONVERT (VARCHAR(6), CONVERT (INT, SUBSTRING (au.first_page, 6, 1) + SUBSTRING (au.first_page, 5, 1))) + ':' + CONVERT (VARCHAR(20), CONVERT (INT, SUBSTRING (au.first_page, 4, 1) + SUBSTRING (au.first_page, 3, 1) + SUBSTRING (au.first_page, 2, 1) + SUBSTRING (au.first_page, 1, 1))) AS first_page FROM sys.partitions p INNER JOIN sys.indexes i ON p.object_id = i.object_id AND p.index_id = i.index_id INNER JOIN sys.objects o
ON p.object_id = o.object_id INNER JOIN sys.system_internals_allocation_units au ON p.partition_id = au.container_id INNER JOIN sys.partition_schemes ps ON ps.data_space_id = i.data_space_id INNER JOIN sys.partition_functions f ON f.function_id = ps.function_id INNER JOIN sys.destination_data_spaces dds ON dds.partition_scheme_id = ps.data_space_id AND dds.destination_id = p.partition_number INNER JOIN sys.filegroups fg ON dds.data_space_id = fg.data_space_id LEFT OUTER JOIN sys.partition_range_values rv ON f.function_id = rv.function_id AND p.partition_number = rv.boundary_id WHERE i.index_id < 2 AND o.object_id = OBJECT_ID(@TableName);
GO

--object	p#	filegroup	rows	pages	comparison	value	first_page
--dbo.Fechas_Alquiler	1	Fechas_Archivo	3	9	less than	2016-01-01 00:00:00.000	3:8
--dbo.Fechas_Alquiler	2	Fechas_2016	3	9	less than	2017-01-01 00:00:00.000	4:8
--dbo.Fechas_Alquiler	3	Fechas_2017	0	0	less than	NULL	0:0
--------------------


INSERT INTO Fechas_Alquiler
	VALUES ('Jorge','Rodr�guez','2017-05-21'), 
	('Pedro','Sanchez','2017-07-09'), 
	('Mariano','Rajoy','2017-09-12')
GO

--(3 rows affected)

SELECT *,$Partition.Fecha_Alquiler(fecha_alquiler) AS Partici�n
FROM Fechas_Alquiler
GO




select p.partition_number, p.rows from sys.partitions p 
inner join sys.tables t 
on p.object_id=t.object_id and t.name = 'Fechas_Alquiler' 
GO






INSERT INTO Fechas_Alquiler
	VALUES ('Cristiano','Ronaldo','2018-02-12'), 
	('Juan Carlos','Valeron','2018-01-23'), 
	('Lucas','Vazquez','2018-02-23')
GO




SELECT *,$Partition.Fecha_Alquiler(fecha_alquiler) AS Partici�n
FROM Fechas_Alquiler
GO

select p.partition_number, p.rows from sys.partitions p 
inner join sys.tables t 
on p.object_id=t.object_id and t.name = 'Fechas_Alquiler' 
GO






--NO SALEN EN LA PARTICI�N DE 2018 YA QUE NO SE A�ADI� UN INERVALO DE FECHAS EN ESA PARTICI�N




-- PARTITIONS OPERATIONS

-- SPLIT


ALTER PARTITION FUNCTION Fecha_Alquiler() 
	SPLIT RANGE ('2018-01-01'); 
GO


SELECT *,$Partition.Fecha_Alquiler(fecha_alquiler) AS Partici�n
FROM Fechas_Alquiler
GO


--SE REPARTEN AUTOMATICAMENTE

-- MERGE

ALTER PARTITION FUNCTION Fecha_Alquiler ()
 MERGE RANGE ('2016-01-01'); 
 GO


SELECT *,$Partition.Fecha_Alquiler(fecha_alquiler) AS Partici�n
FROM Fechas_Alquiler
GO

--FUSIONA DOS PARTICIONES


-- Example SWITCH

USE master
GO
ALTER DATABASE Alquiler_Avionetas REMOVE FILE Fechas_2016
go

ALTER DATABASE [Alquiler_Avionetas] REMOVE FILEGROUP Fechas_2016
GO



select * from sys.filegroups
GO

select * from sys.database_files
GO

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- SWITCH

USE Alquiler_Avionetas
go

SELECT *,$Partition.Fecha_Alquiler(fecha_alquiler) AS Partici�n
FROM Fechas_Alquiler
GO

DECLARE @TableName NVARCHAR(200) = N'Fechas_Alquiler' 
SELECT SCHEMA_NAME(o.schema_id) + '.' + OBJECT_NAME(i.object_id) AS [object] , p.partition_number AS [p#] , fg.name AS [filegroup] , p.rows , au.total_pages AS pages , CASE boundary_value_on_right WHEN 1 THEN 'less than' ELSE 'less than or equal to' END as comparison , rv.value , CONVERT (VARCHAR(6), CONVERT (INT, SUBSTRING (au.first_page, 6, 1) + SUBSTRING (au.first_page, 5, 1))) + ':' + CONVERT (VARCHAR(20), CONVERT (INT, SUBSTRING (au.first_page, 4, 1) + SUBSTRING (au.first_page, 3, 1) + SUBSTRING (au.first_page, 2, 1) + SUBSTRING (au.first_page, 1, 1))) AS first_page FROM sys.partitions p INNER JOIN sys.indexes i ON p.object_id = i.object_id AND p.index_id = i.index_id INNER JOIN sys.objects o
ON p.object_id = o.object_id INNER JOIN sys.system_internals_allocation_units au ON p.partition_id = au.container_id INNER JOIN sys.partition_schemes ps ON ps.data_space_id = i.data_space_id INNER JOIN sys.partition_functions f ON f.function_id = ps.function_id INNER JOIN sys.destination_data_spaces dds ON dds.partition_scheme_id = ps.data_space_id AND dds.destination_id = p.partition_number INNER JOIN sys.filegroups fg ON dds.data_space_id = fg.data_space_id LEFT OUTER JOIN sys.partition_range_values rv ON f.function_id = rv.function_id AND p.partition_number = rv.boundary_id WHERE i.index_id < 2 AND o.object_id = OBJECT_ID(@TableName);
GO

--object			p#	filegroup	rows	pages	comparison	value	first_page
--dbo.Alta_Coleg	1	FG_Archivo	6	9	less than	2017-01-01 00:00:00.000	3:8
--dbo.Alta_Coleg	2	FG_2017		3	9	less than	2018-01-01 00:00:00.000	5:8
--dbo.Alta_Coleg	3	FG_2018		3	9	less than	NULL	6:8

DROP TABLE IF EXISTS Archivo_Alquileres
GO

CREATE TABLE Archivo_Alquileres
( id_alquiler int identity (1,1), 
nombre varchar(20), 
apellido varchar (20), 
fecha_alquiler datetime ) 
ON Fechas_Archivo
go

SELECT * FROM Archivo_Alquileres
GO



ALTER TABLE Fechas_Alquiler
	SWITCH Partition 1 to Archivo_Alquileres
go


SELECT * FROM Archivo_Alquileres
GO


select * from Fechas_Alquiler
go




-- TRUNCATE

TRUNCATE TABLE Fechas_Alquiler 
	WITH (PARTITIONS (3));
GO

select * from Fechas_Alquiler
GO
