
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
	Values ('Pedro','Álvarez','2015-01-01'), 
			('Alejandro','Viñas','2015-05-05'), 
			('Alicia','Pérez','2015-08-11')
Go


----------------
-- METADATA INFORMATION

SELECT *,$Partition.Fecha_Alquiler(fecha_alquiler) AS Partition
FROM Fechas_Alquiler
GO

--id_alquiler	nombre	apellido	fecha_alta	Partition
--1	Pedro	Álvarez	2015-01-01 00:00:00.000	1
--2	Alejandro	Viñas	2015-05-05 00:00:00.000	1
--3	Alicia	Pérez	2015-08-11 00:00:00.000	1


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
	VALUES ('Juan','López','2016-06-23'), 
	('Ana Maria','Vázquez','2016-02-03'), 
	('Carlos','Rodriguez','2016-04-06')
GO

SELECT *,$Partition.Fecha_Alquiler(fecha_alquiler) AS Partition
FROM Fechas_Alquiler
GO

--1	Pedro	Álvarez	2015-01-01 00:00:00.000	1
--2	Alejandro	Viñas	2015-05-05 00:00:00.000	1
--3	Alicia	Pérez	2015-08-11 00:00:00.000	1
--4	Juan	López	2016-06-23 00:00:00.000	2
--5	Ana Maria	Vázquez	2016-02-03 00:00:00.000	2
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

----------------------------------------------------------------------------------------------------------------------------------------HASTA AQUI---------------------------------------------------------------------------------------------------

INSERT INTO Alta_Coleg 
	VALUES ('Ismael','Cabana','2017-05-21'), 
	('Alejandra','Martinez','2017-07-09'), 
	('Alfonso','Verdes','2017-09-12')
GO

--(3 rows affected)

SELECT *,$Partition.FN_altas_fecha(fecha_alta) 
FROM Alta_Coleg
GO


--id_alta	nombre	apellido	fecha_alta	(No column name)
--1	Antonio	Ruiz	2015-01-01 00:00:00.000	1
--2	Lucas	García	2015-05-05 00:00:00.000	1
--3	Manuel	Sanchez	2015-08-11 00:00:00.000	1
--4	Laura	Muñoz	2016-06-23 00:00:00.000	2
--5	Rosa Maria	Leandro	2016-02-03 00:00:00.000	2
--6	Federico	Ramos	2016-04-06 00:00:00.000	2
--7	Ismael	Cabana	2017-05-21 00:00:00.000	3
--8	Alejandra	Martinez	2017-07-09 00:00:00.000	3
--9	Alfonso	Verdes	2017-09-12 00:00:00.000	3


select name, create_date, value from sys.partition_functions f 
inner join sys.partition_range_values rv 
on f.function_id=rv.function_id 
where f.name = 'FN_altas_fecha'
gO


select p.partition_number, p.rows from sys.partitions p 
inner join sys.tables t 
on p.object_id=t.object_id and t.name = 'Alta_Coleg' 
GO

DECLARE @TableName NVARCHAR(200) = N'Alta_Coleg' 
SELECT SCHEMA_NAME(o.schema_id) + '.' + OBJECT_NAME(i.object_id) AS [object] , p.partition_number AS [p#] , fg.name AS [filegroup] , p.rows , au.total_pages AS pages , CASE boundary_value_on_right WHEN 1 THEN 'less than' ELSE 'less than or equal to' END as comparison , rv.value , CONVERT (VARCHAR(6), CONVERT (INT, SUBSTRING (au.first_page, 6, 1) + SUBSTRING (au.first_page, 5, 1))) + ':' + CONVERT (VARCHAR(20), CONVERT (INT, SUBSTRING (au.first_page, 4, 1) + SUBSTRING (au.first_page, 3, 1) + SUBSTRING (au.first_page, 2, 1) + SUBSTRING (au.first_page, 1, 1))) AS first_page FROM sys.partitions p INNER JOIN sys.indexes i ON p.object_id = i.object_id AND p.index_id = i.index_id INNER JOIN sys.objects o
ON p.object_id = o.object_id INNER JOIN sys.system_internals_allocation_units au ON p.partition_id = au.container_id INNER JOIN sys.partition_schemes ps ON ps.data_space_id = i.data_space_id INNER JOIN sys.partition_functions f ON f.function_id = ps.function_id INNER JOIN sys.destination_data_spaces dds ON dds.partition_scheme_id = ps.data_space_id AND dds.destination_id = p.partition_number INNER JOIN sys.filegroups fg ON dds.data_space_id = fg.data_space_id LEFT OUTER JOIN sys.partition_range_values rv ON f.function_id = rv.function_id AND p.partition_number = rv.boundary_id WHERE i.index_id < 2 AND o.object_id = OBJECT_ID(@TableName);
GO

--object	p#	filegroup	rows	pages	comparison	value	first_page
--dbo.Alta_Coleg	1	FG_Archivo	3	9	less than	2016-01-01 00:00:00.000	3:8
--dbo.Alta_Coleg	2	FG_2016	3	9	less than	2017-01-01 00:00:00.000	4:8
--dbo.Alta_Coleg	3	FG_2017	3	9	less than	NULL	5:8

------------------


INSERT INTO Alta_Coleg 
	VALUES ('Amanda','Smith','2018-02-12'), 
	('Adolfo','Muñiz','2018-01-23'), 
	('Rosario','Fuertes','2018-02-23')
GO



SELECT *,$Partition.FN_altas_fecha(fecha_alta) as PARTITION
FROM Alta_Coleg
GO

--id_alta	nombre	apellido	fecha_alta	PARTITION
--1	Antonio	Ruiz	2015-01-01 00:00:00.000	1
--2	Lucas	García	2015-05-05 00:00:00.000	1
--3	Manuel	Sanchez	2015-08-11 00:00:00.000	1
--4	Laura	Muñoz	2016-06-23 00:00:00.000	2
--5	Rosa Maria	Leandro	2016-02-03 00:00:00.000	2
--6	Federico	Ramos	2016-04-06 00:00:00.000	2
--7	Ismael	Cabana	2017-05-21 00:00:00.000	3
--8	Alejandra	Martinez	2017-07-09 00:00:00.000	3
--9	Alfonso	Verdes	2017-09-12 00:00:00.000	3
--10	Amanda	Smith	2018-02-12 00:00:00.000	3
--11	Adolfo	Muñiz	2018-01-23 00:00:00.000	3
--12	Rosario	Fuertes	2018-02-23 00:00:00.000	3

select name, create_date, value from sys.partition_functions f 
inner join sys.partition_range_values rv 
on f.function_id=rv.function_id 
where f.name = 'FN_altas_fecha'
gO


select p.partition_number, p.rows from sys.partitions p 
inner join sys.tables t 
on p.object_id=t.object_id and t.name = 'Alta_Coleg' 
GO

DECLARE @TableName NVARCHAR(200) = N'Alta_Coleg' 
SELECT SCHEMA_NAME(o.schema_id) + '.' + OBJECT_NAME(i.object_id) AS [object] , p.partition_number AS [p#] , fg.name AS [filegroup] , p.rows , au.total_pages AS pages , CASE boundary_value_on_right WHEN 1 THEN 'less than' ELSE 'less than or equal to' END as comparison , rv.value , CONVERT (VARCHAR(6), CONVERT (INT, SUBSTRING (au.first_page, 6, 1) + SUBSTRING (au.first_page, 5, 1))) + ':' + CONVERT (VARCHAR(20), CONVERT (INT, SUBSTRING (au.first_page, 4, 1) + SUBSTRING (au.first_page, 3, 1) + SUBSTRING (au.first_page, 2, 1) + SUBSTRING (au.first_page, 1, 1))) AS first_page FROM sys.partitions p INNER JOIN sys.indexes i ON p.object_id = i.object_id AND p.index_id = i.index_id INNER JOIN sys.objects o
ON p.object_id = o.object_id INNER JOIN sys.system_internals_allocation_units au ON p.partition_id = au.container_id INNER JOIN sys.partition_schemes ps ON ps.data_space_id = i.data_space_id INNER JOIN sys.partition_functions f ON f.function_id = ps.function_id INNER JOIN sys.destination_data_spaces dds ON dds.partition_scheme_id = ps.data_space_id AND dds.destination_id = p.partition_number INNER JOIN sys.filegroups fg ON dds.data_space_id = fg.data_space_id LEFT OUTER JOIN sys.partition_range_values rv ON f.function_id = rv.function_id AND p.partition_number = rv.boundary_id WHERE i.index_id < 2 AND o.object_id = OBJECT_ID(@TableName);
GO

--NO SALEN EN LA PARTICIÓN DE 2018 YA QUE NO SE AÑADIÓ UN INERVALO DE FECHAS EN ESA PARTICIÓN

--object	p#	filegroup	rows	pages	comparison	value	first_page
--dbo.Alta_Coleg	1	FG_Archivo	3	9	less than	2016-01-01 00:00:00.000	3:8
--dbo.Alta_Coleg	2	FG_2016		3	9	less than	2017-01-01 00:00:00.000	4:8
--dbo.Alta_Coleg	3	FG_2017		6	9	less than	NULL	5:8

-- PARTITIONS OPERATIONS

-- SPLIT


ALTER PARTITION FUNCTION FN_altas_fecha() 
	SPLIT RANGE ('2018-01-01'); 
GO

SELECT *,$Partition.FN_altas_fecha(fecha_alta) as PARTITION
FROM Alta_Coleg
GO

DECLARE @TableName NVARCHAR(200) = N'Alta_Coleg' 
SELECT SCHEMA_NAME(o.schema_id) + '.' + OBJECT_NAME(i.object_id) AS [object] , p.partition_number AS [p#] , fg.name AS [filegroup] , p.rows , au.total_pages AS pages , CASE boundary_value_on_right WHEN 1 THEN 'less than' ELSE 'less than or equal to' END as comparison , rv.value , CONVERT (VARCHAR(6), CONVERT (INT, SUBSTRING (au.first_page, 6, 1) + SUBSTRING (au.first_page, 5, 1))) + ':' + CONVERT (VARCHAR(20), CONVERT (INT, SUBSTRING (au.first_page, 4, 1) + SUBSTRING (au.first_page, 3, 1) + SUBSTRING (au.first_page, 2, 1) + SUBSTRING (au.first_page, 1, 1))) AS first_page FROM sys.partitions p INNER JOIN sys.indexes i ON p.object_id = i.object_id AND p.index_id = i.index_id INNER JOIN sys.objects o
ON p.object_id = o.object_id INNER JOIN sys.system_internals_allocation_units au ON p.partition_id = au.container_id INNER JOIN sys.partition_schemes ps ON ps.data_space_id = i.data_space_id INNER JOIN sys.partition_functions f ON f.function_id = ps.function_id INNER JOIN sys.destination_data_spaces dds ON dds.partition_scheme_id = ps.data_space_id AND dds.destination_id = p.partition_number INNER JOIN sys.filegroups fg ON dds.data_space_id = fg.data_space_id LEFT OUTER JOIN sys.partition_range_values rv ON f.function_id = rv.function_id AND p.partition_number = rv.boundary_id WHERE i.index_id < 2 AND o.object_id = OBJECT_ID(@TableName);
GO
--SE REPARTEN AUTOMATICAMENTE
--object			p#	filegroup	rows	pages	comparison	value	first_page
--dbo.Alta_Coleg	1	FG_Archivo	3	9	less than	2016-01-01 00:00:00.000	3:8
--dbo.Alta_Coleg	2	FG_2016		3	9	less than	2017-01-01 00:00:00.000	4:8
--dbo.Alta_Coleg	3	FG_2017		3	9	less than	2018-01-01 00:00:00.000	5:8
--dbo.Alta_Coleg	4	FG_2018		3	9	less than	NULL	6:8

-- MERGE

ALTER PARTITION FUNCTION FN_Altas_Fecha ()
 MERGE RANGE ('2016-01-01'); 
 GO

SELECT *,$Partition.FN_altas_fecha(fecha_alta) 
FROM Alta_Coleg
GO
DECLARE @TableName NVARCHAR(200) = N'Alta_Coleg' 
SELECT SCHEMA_NAME(o.schema_id) + '.' + OBJECT_NAME(i.object_id) AS [object] , p.partition_number AS [p#] , fg.name AS [filegroup] , p.rows , au.total_pages AS pages , CASE boundary_value_on_right WHEN 1 THEN 'less than' ELSE 'less than or equal to' END as comparison , rv.value , CONVERT (VARCHAR(6), CONVERT (INT, SUBSTRING (au.first_page, 6, 1) + SUBSTRING (au.first_page, 5, 1))) + ':' + CONVERT (VARCHAR(20), CONVERT (INT, SUBSTRING (au.first_page, 4, 1) + SUBSTRING (au.first_page, 3, 1) + SUBSTRING (au.first_page, 2, 1) + SUBSTRING (au.first_page, 1, 1))) AS first_page FROM sys.partitions p INNER JOIN sys.indexes i ON p.object_id = i.object_id AND p.index_id = i.index_id INNER JOIN sys.objects o
ON p.object_id = o.object_id INNER JOIN sys.system_internals_allocation_units au ON p.partition_id = au.container_id INNER JOIN sys.partition_schemes ps ON ps.data_space_id = i.data_space_id INNER JOIN sys.partition_functions f ON f.function_id = ps.function_id INNER JOIN sys.destination_data_spaces dds ON dds.partition_scheme_id = ps.data_space_id AND dds.destination_id = p.partition_number INNER JOIN sys.filegroups fg ON dds.data_space_id = fg.data_space_id LEFT OUTER JOIN sys.partition_range_values rv ON f.function_id = rv.function_id AND p.partition_number = rv.boundary_id WHERE i.index_id < 2 AND o.object_id = OBJECT_ID(@TableName);
GO
--FUSIONA DOS PARTICIONES
--object			p#	filegroup	rows	pages	comparison	value	first_page
--dbo.Alta_Coleg	1	FG_Archivo	6	9	less than	2017-01-01 00:00:00.000	3:8
--dbo.Alta_Coleg	2	FG_2017		3	9	less than	2018-01-01 00:00:00.000	5:8
--dbo.Alta_Coleg	3	FG_2018		3	9	less than	NULL	6:8

-- Example SWITCH

USE master
GO
ALTER DATABASE [Colegio_Medico] REMOVE FILE Altas_2016
go

ALTER DATABASE [Colegio_Medico] REMOVE FILEGROUP FG_2016 
GO


--The file 'Altas_2016' has been removed.
--The filegroup 'FG_2016' has been removed.

select * from sys.filegroups
GO

select * from sys.database_files
GO


-- SWITCH

USE Colegio_Medico
go

SELECT *,$Partition.FN_altas_fecha(fecha_alta) 
FROM Alta_Coleg
GO
DECLARE @TableName NVARCHAR(200) = N'Alta_Coleg' 
SELECT SCHEMA_NAME(o.schema_id) + '.' + OBJECT_NAME(i.object_id) AS [object] , p.partition_number AS [p#] , fg.name AS [filegroup] , p.rows , au.total_pages AS pages , CASE boundary_value_on_right WHEN 1 THEN 'less than' ELSE 'less than or equal to' END as comparison , rv.value , CONVERT (VARCHAR(6), CONVERT (INT, SUBSTRING (au.first_page, 6, 1) + SUBSTRING (au.first_page, 5, 1))) + ':' + CONVERT (VARCHAR(20), CONVERT (INT, SUBSTRING (au.first_page, 4, 1) + SUBSTRING (au.first_page, 3, 1) + SUBSTRING (au.first_page, 2, 1) + SUBSTRING (au.first_page, 1, 1))) AS first_page FROM sys.partitions p INNER JOIN sys.indexes i ON p.object_id = i.object_id AND p.index_id = i.index_id INNER JOIN sys.objects o
ON p.object_id = o.object_id INNER JOIN sys.system_internals_allocation_units au ON p.partition_id = au.container_id INNER JOIN sys.partition_schemes ps ON ps.data_space_id = i.data_space_id INNER JOIN sys.partition_functions f ON f.function_id = ps.function_id INNER JOIN sys.destination_data_spaces dds ON dds.partition_scheme_id = ps.data_space_id AND dds.destination_id = p.partition_number INNER JOIN sys.filegroups fg ON dds.data_space_id = fg.data_space_id LEFT OUTER JOIN sys.partition_range_values rv ON f.function_id = rv.function_id AND p.partition_number = rv.boundary_id WHERE i.index_id < 2 AND o.object_id = OBJECT_ID(@TableName);
GO

--object			p#	filegroup	rows	pages	comparison	value	first_page
--dbo.Alta_Coleg	1	FG_Archivo	6	9	less than	2017-01-01 00:00:00.000	3:8
--dbo.Alta_Coleg	2	FG_2017		3	9	less than	2018-01-01 00:00:00.000	5:8
--dbo.Alta_Coleg	3	FG_2018		3	9	less than	NULL	6:8



CREATE TABLE Archivo_Altas 
( id_alta int identity (1,1), 
nombre varchar(20), 
apellido varchar (20), 
fecha_alta datetime ) 
ON FG_Archivo
go


ALTER TABLE Alta_Coleg 
	SWITCH Partition 1 to Archivo_Altas
go


select * from Alta_Coleg 
go


--id_alta	nombre	apellido	fecha_alta
--7	Ismael	Cabana	2017-05-21 00:00:00.000
--8	Alejandra	Martinez	2017-07-09 00:00:00.000
--9	Alfonso	Verdes	2017-09-12 00:00:00.000
--10	Amanda	Smith	2018-02-12 00:00:00.000
--11	Adolfo	Muñiz	2018-01-23 00:00:00.000
--12	Rosario	Fuertes	2018-02-23 00:00:00.000


select * from Archivo_Altas 
go

--id_alta	nombre	apellido	fecha_alta
--1	Antonio	Ruiz	2015-01-01 00:00:00.000
--2	Lucas	García	2015-05-05 00:00:00.000
--3	Manuel	Sanchez	2015-08-11 00:00:00.000
--4	Laura	Muñoz	2016-06-23 00:00:00.000
--5	Rosa Maria	Leandro	2016-02-03 00:00:00.000
--6	Federico	Ramos	2016-04-06 00:00:00.000



DECLARE @TableName NVARCHAR(200) = N'Alta_Coleg' SELECT SCHEMA_NAME(o.schema_id) + '.' + OBJECT_NAME(i.object_id) AS [object] , p.partition_number AS [p#] , fg.name AS [filegroup] , p.rows
, au.total_pages AS pages , CASE boundary_value_on_right WHEN 1 THEN 'less than' ELSE 'less than or equal to' END as comparison , rv.value , CONVERT (VARCHAR(6), CONVERT (INT, SUBSTRING (au.first_page, 6, 1) + SUBSTRING (au.first_page, 5, 1))) + ':' + CONVERT (VARCHAR(20), CONVERT (INT, SUBSTRING (au.first_page, 4, 1) + SUBSTRING (au.first_page, 3, 1) + SUBSTRING (au.first_page, 2, 1) + SUBSTRING (au.first_page, 1, 1))) AS first_page FROM sys.partitions p INNER JOIN sys.indexes i ON p.object_id = i.object_id AND p.index_id = i.index_id INNER JOIN sys.objects o ON p.object_id = o.object_id INNER JOIN sys.system_internals_allocation_units au ON p.partition_id = au.container_id INNER JOIN sys.partition_schemes ps ON ps.data_space_id = i.data_space_id INNER JOIN sys.partition_functions f ON f.function_id = ps.function_id INNER JOIN sys.destination_data_spaces dds ON dds.partition_scheme_id = ps.data_space_id AND dds.destination_id = p.partition_number INNER JOIN sys.filegroups fg ON dds.data_space_id = fg.data_space_id LEFT OUTER JOIN sys.partition_range_values rv ON f.function_id = rv.function_id AND p.partition_number = rv.boundary_id WHERE i.index_id < 2 AND o.object_id = OBJECT_ID(@TableName);
GO

--object			p#	filegroup	rows	pages	comparison	value	first_page
--dbo.Alta_Coleg	1	FG_Archivo	0	0	less than	2017-01-01 00:00:00.000	0:0
--dbo.Alta_Coleg	2	FG_2017		3	9	less than	2018-01-01 00:00:00.000	5:8
--dbo.Alta_Coleg	3	FG_2018		3	9	less than	NULL	6:8

-- TRUNCATE

TRUNCATE TABLE Alta_Coleg 
	WITH (PARTITIONS (3));
go

select * from Alta_Coleg
GO

--id_alta	nombre	apellido	fecha_alta
--7	Ismael	Cabana	2017-05-21 00:00:00.000
--8	Alejandra	Martinez	2017-07-09 00:00:00.000
--9	Alfonso	Verdes	2017-09-12 00:00:00.000


DECLARE @TableName NVARCHAR(200) = N'Alta_Coleg' 
SELECT SCHEMA_NAME(o.schema_id) + '.' + OBJECT_NAME(i.object_id) AS [object] , p.partition_number AS [p#] , fg.name AS [filegroup] , p.rows , au.total_pages AS pages , CASE boundary_value_on_right WHEN 1 THEN 'less than' ELSE 'less than or equal to' END as comparison , rv.value , CONVERT (VARCHAR(6), CONVERT (INT, SUBSTRING (au.first_page, 6, 1) + SUBSTRING (au.first_page, 5, 1))) + ':' + CONVERT (VARCHAR(20), CONVERT (INT, SUBSTRING (au.first_page, 4, 1) + SUBSTRING (au.first_page, 3, 1) + SUBSTRING (au.first_page, 2, 1) + SUBSTRING (au.first_page, 1, 1))) AS first_page FROM sys.partitions p INNER JOIN sys.indexes i ON p.object_id = i.object_id AND p.index_id = i.index_id INNER JOIN sys.objects o
ON p.object_id = o.object_id INNER JOIN sys.system_internals_allocation_units au ON p.partition_id = au.container_id INNER JOIN sys.partition_schemes ps ON ps.data_space_id = i.data_space_id INNER JOIN sys.partition_functions f ON f.function_id = ps.function_id INNER JOIN sys.destination_data_spaces dds ON dds.partition_scheme_id = ps.data_space_id AND dds.destination_id = p.partition_number INNER JOIN sys.filegroups fg ON dds.data_space_id = fg.data_space_id LEFT OUTER JOIN sys.partition_range_values rv ON f.function_id = rv.function_id AND p.partition_number = rv.boundary_id WHERE i.index_id < 2 AND o.object_id = OBJECT_ID(@TableName);
GO

--object			p#	filegroup	rows	pages	comparison	value	first_page
--dbo.Alta_Coleg	1	FG_Archivo	0	0	less than	2017-01-01 00:00:00.000	0:0
--dbo.Alta_Coleg	2	FG_2017		3	9	less than	2018-01-01 00:00:00.000	5:8
--dbo.Alta_Coleg	3	FG_2018		0	0	less than	NULL	0:0










