-- PARTITIONS

-- SCALE UP - SCALE OUT
-- MODELO RELACIONAL - MODELO NOSQL
-- MODELO NOSQL (BASES DE DATOS DISTRIBUIDAS)
-- MONGODB		SHARD


-- CASSANDRA	PRIMARY KEY : PARTITION KEY + CLUSTERING KEY
--Primary Key: Is composed of partition key(s) [and optional clustering keys(or columns)]
--Partition Key: The hash value of Partition key is used to determine the specific node in a cluster to store the data
--Clustering Key: Is used to sort the data in each of the partitions (or responsible node and its replicas)
--Compound Primary Key: As said above, the clustering keys are optional in a Primary Key. If they aren't mentioned, it's a simple primary key. If clustering keys are mentioned, it's a Compound primary key.
--Composite Partition Key: Using just one column as a partition key, might result in wide row issues (depends on use case/data modeling). Hence the partition key is sometimes specified as a combination of more than one column.
-- EXAMPLES :
--CREATE TABLE cycling.cyclist_category ( 
--	category text, 
--	points int, 
--	id UUID, 
--	lastname text,     
--	PRIMARY KEY (category, points)
--	) WITH CLUSTERING ORDER BY (points DESC);

CREATE TABLE IF NOT EXISTS posts_by_user ( 
  user_id     UUID, 
  post_id     TIMEUUID,
  room_id     TEXT, 
  text        TEXT,
  PRIMARY KEY ((user_id), post_id)
) WITH CLUSTERING ORDER BY (post_id DESC);

CREATE TABLE IF NOT EXISTS posts_by_room ( 
  room_id     TEXT, 
  post_id     TIMEUUID,
  user_id     UUID,
  text        TEXT,
  PRIMARY KEY ((room_id), post_id)
) WITH CLUSTERING ORDER BY (post_id DESC);


--------------------
-- https://docs.microsoft.com/en-us/sql/relational-databases/partitions/partitioned-tables-and-indexes?view=sql-server-ver15

-- PARTITIONS
--Crear un grupo o grupos de archivos y los archivos correspondientes que contendr�n las particiones especificadas por el esquema de partici�n.
--Crear una funci�n de partici�n que asigna las filas de una tabla o un �ndice a particiones seg�n los valores de una columna especificada.
--Crear un esquema de partici�n que asigna las particiones de una tabla o �ndice con particiones a los nuevos grupos de archivos.
--Crear o modificar una tabla o un �ndice y especificar el esquema de partici�n como ubicaci�n de almacenamiento.


-- OPERATIONS
-- Operations SPLIT-MERGE-SWITCH-TRUNCATE PARTITION

--Create a database with multiple files and filegroups
--Create a Partition Function and a Partition Scheme based on date
--Create a Table on the Partition
--Insert Data into the Table
--Investigate how the data is stored according to partition

-- ONLY HORIZONTAL
-- http://datablog.roman-halliday.com/index.php/2019/02/02/partitions-in-sql-server-creating-a-partitioned-table/


--What makes a partitioned table in SQL Server?
--In SQL Server, to partition a table you first need to define a function, and then a scheme.

--Partition Function: The definition of how data is to be split. 
-- It includes the data type and the value ranges to use in each partition.

--Partition Scheme: The definition of how a function is to be applied to data files. 
-- This allows DBAs to split data across logical storage locations if required, 
-- however in most modern environments with large SANs most SQL Server implementations and their DBAs
--  will just use �primary�.

--A partition function can be used in one or more schemes, 
-- and a scheme in one or more tables. 
-- There can be organisational advantages to sharing a scheme/function across tables 
--(update one, and you update everything in kind). However, in my experience most cases DBAs prefer to have one function and scheme combination for each table.

USE master 
go
-- CREATE FOLDER DATA
DROP DATABASE IF EXISTS Colegio_Medico 
GO
CREATE DATABASE [Colegio_Medico] 
	ON PRIMARY ( NAME = 'Colegio_Medico', 
		FILENAME = 'C:\Data\Colegio_Medico_Fijo.mdf' , 
		SIZE = 15360KB , MAXSIZE = UNLIMITED, FILEGROWTH = 0) 
	LOG ON ( NAME = 'Colegio_Medico_log', 
		FILENAME = 'C:\Data\Colegio_Medico_log.ldf' , 
		SIZE = 10176KB , MAXSIZE = 2048GB , FILEGROWTH = 10%) 
GO

-- SSMS DB Properties

USE Colegio_Medico
GO
-- CREATE FILEGROUPS
ALTER DATABASE [Colegio_Medico] ADD FILEGROUP [FG_Archivo] 
GO 
ALTER DATABASE [Colegio_Medico] ADD FILEGROUP [FG_2016] 
GO 
ALTER DATABASE [Colegio_Medico] ADD FILEGROUP [FG_2017] 
GO 
ALTER DATABASE [Colegio_Medico] ADD FILEGROUP [FG_2018]
GO

select * from sys.filegroups
GO

-- -- CREATE FILES

ALTER DATABASE [Colegio_Medico] ADD FILE ( NAME = 'Altas_Archivo', FILENAME = 'c:\DATA\Altas_Archivo.ndf', SIZE = 5MB, MAXSIZE = 100MB, FILEGROWTH = 2MB ) TO FILEGROUP [FG_Archivo] 
GO
ALTER DATABASE [Colegio_Medico] ADD FILE ( NAME = 'altas_2016', FILENAME = 'c:\DATA\altas_2016.ndf', SIZE = 5MB, MAXSIZE = 100MB, FILEGROWTH = 2MB ) TO FILEGROUP [FG_2016] 
GO
ALTER DATABASE [Colegio_Medico] ADD FILE ( NAME = 'altas_2017', FILENAME = 'c:\DATA\altas_2017.ndf', SIZE = 5MB, MAXSIZE = 100MB, FILEGROWTH = 2MB ) TO FILEGROUP [FG_2017] 
GO
ALTER DATABASE [Colegio_Medico] ADD FILE ( NAME = 'altas_2018', FILENAME = 'c:\DATA\altas_2018.ndf', SIZE = 5MB, MAXSIZE = 100MB, FILEGROWTH = 2MB ) TO FILEGROUP [FG_2018] 
GO


select * from sys.filegroups
GO

select * from sys.database_files
GO


-- PARTITION FUNCTION
-- BOUNDARIES (LIMITES)

CREATE PARTITION FUNCTION FN_altas_fecha (datetime) 
AS RANGE RIGHT 
	FOR VALUES ('2016-01-01','2017-01-01')
GO

-- PARTITION SCHEME

CREATE PARTITION SCHEME altas_fecha 
AS PARTITION FN_altas_fecha 
	TO (FG_Archivo,FG_2016,FG_2017,FG_2018) 
GO


-- Partition scheme 'altas_fecha' has been created successfully. 
-- 'FG_2018' is marked as the next used filegroup in partition scheme 'altas_fecha'.

--Partitioned Table
--Lastly a table needs to be defined (as normal), with two additional requirements:

--The storage location is given as the partition scheme (with the name of the column to be used 
--for partitioning).
--The table must have a clustered index (usually the primary key) which includes the column to be used 
-- for partitioning.

DROP TABLE IF EXISTS Alta_Coleg
GO
CREATE TABLE Alta_Coleg
	( id_alta int identity (1,1), 
	nombre varchar(20), 
	apellido varchar (20), 
	fecha_alta datetime ) 
	ON altas_fecha -- partition scheme
		(fecha_alta) -- the column to apply the function within the scheme
GO

-- SSMS TABLE PROPERTIES PARTITIONS

INSERT INTO Alta_Coleg 
	Values ('Antonio','Ruiz','2015-01-01'), 
			('Lucas','Garc�a','2015-05-05'), 
			('Manuel','Sanchez','2015-08-11')
Go


----------------
-- METADATA INFORMATION

SELECT *,$Partition.FN_altas_fecha(fecha_alta) AS Partition
FROM Alta_Coleg
GO

--id_alta	nombre	apellido	fecha_alta	Partition
--1	Antonio	Ruiz	2015-01-01 00:00:00.000	1
--2	Lucas	Garc�a	2015-05-05 00:00:00.000	1
--3	Manuel	Sanchez	2015-08-11 00:00:00.000	1


-- partition function
select name, create_date, value from sys.partition_functions f 
inner join sys.partition_range_values rv 
on f.function_id=rv.function_id 
where f.name = 'FN_altas_fecha'
gO

--name	create_date	value
--FN_altas_fecha	2022-01-26 11:38:18.493	2016-01-01 00:00:00.000
--FN_altas_fecha	2022-01-26 11:38:18.493	2017-01-01 00:00:00.000

select p.partition_number, p.rows from sys.partitions p 
inner join sys.tables t 
on p.object_id=t.object_id and t.name = 'Alta_Coleg' 
GO

--partition_number	rows
--1					 3
--2					 0
--3					 0

DECLARE @TableName NVARCHAR(200) = N'Alta_Coleg' 
SELECT SCHEMA_NAME(o.schema_id) + '.' + OBJECT_NAME(i.object_id) AS [object] , p.partition_number AS [p#] , fg.name AS [filegroup] , p.rows , au.total_pages AS pages , CASE boundary_value_on_right WHEN 1 THEN 'less than' ELSE 'less than or equal to' END as comparison , rv.value , CONVERT (VARCHAR(6), CONVERT (INT, SUBSTRING (au.first_page, 6, 1) + SUBSTRING (au.first_page, 5, 1))) + ':' + CONVERT (VARCHAR(20), CONVERT (INT, SUBSTRING (au.first_page, 4, 1) + SUBSTRING (au.first_page, 3, 1) + SUBSTRING (au.first_page, 2, 1) + SUBSTRING (au.first_page, 1, 1))) AS first_page FROM sys.partitions p INNER JOIN sys.indexes i ON p.object_id = i.object_id AND p.index_id = i.index_id INNER JOIN sys.objects o
ON p.object_id = o.object_id INNER JOIN sys.system_internals_allocation_units au ON p.partition_id = au.container_id INNER JOIN sys.partition_schemes ps ON ps.data_space_id = i.data_space_id INNER JOIN sys.partition_functions f ON f.function_id = ps.function_id INNER JOIN sys.destination_data_spaces dds ON dds.partition_scheme_id = ps.data_space_id AND dds.destination_id = p.partition_number INNER JOIN sys.filegroups fg ON dds.data_space_id = fg.data_space_id LEFT OUTER JOIN sys.partition_range_values rv ON f.function_id = rv.function_id AND p.partition_number = rv.boundary_id WHERE i.index_id < 2 AND o.object_id = OBJECT_ID(@TableName);
GO

--object			p#	filegroup	rows	pages	comparison	value	first_page
--dbo.Alta_Coleg	1	FG_Archivo	3		9			less than	2016-01-01 00:00:00.000	3:8
--dbo.Alta_Coleg	2	FG_2016		0		0			less than	2017-01-01 00:00:00.000	0:0
--dbo.Alta_Coleg	3	FG_2017		0		0			less than	NULL	0:0
-------------------
INSERT INTO Alta_Coleg 
	VALUES ('Laura','Mu�oz','2016-06-23'), 
	('Rosa Maria','Leandro','2016-02-03'), 
	('Federico','Ramos','2016-04-06')
GO

SELECT *,$Partition.FN_altas_fecha(fecha_alta) 
FROM Alta_Coleg
GO

-- (3 rows affected)


select name, create_date, value from sys.partition_functions f 
inner join sys.partition_range_values rv 
on f.function_id=rv.function_id 
where f.name = 'FN_altas_fecha'
gO

--name				create_date	value
--FN_altas_fecha	2022-01-26 11:38:18.493	2016-01-01 00:00:00.000
--FN_altas_fecha	2022-01-26 11:38:18.493	2017-01-01 00:00:00.000

select p.partition_number, p.rows from sys.partitions p 
inner join sys.tables t 
on p.object_id=t.object_id and t.name = 'Alta_Coleg' 
GO

--partition_number	rows
--1					3
--2					3
--3					0


DECLARE @TableName NVARCHAR(200) = N'Alta_Coleg' 
SELECT SCHEMA_NAME(o.schema_id) + '.' + OBJECT_NAME(i.object_id) AS [object] , p.partition_number AS [p#] , fg.name AS [filegroup] , p.rows , au.total_pages AS pages , CASE boundary_value_on_right WHEN 1 THEN 'less than' ELSE 'less than or equal to' END as comparison , rv.value , CONVERT (VARCHAR(6), CONVERT (INT, SUBSTRING (au.first_page, 6, 1) + SUBSTRING (au.first_page, 5, 1))) + ':' + CONVERT (VARCHAR(20), CONVERT (INT, SUBSTRING (au.first_page, 4, 1) + SUBSTRING (au.first_page, 3, 1) + SUBSTRING (au.first_page, 2, 1) + SUBSTRING (au.first_page, 1, 1))) AS first_page FROM sys.partitions p INNER JOIN sys.indexes i ON p.object_id = i.object_id AND p.index_id = i.index_id INNER JOIN sys.objects o
ON p.object_id = o.object_id INNER JOIN sys.system_internals_allocation_units au ON p.partition_id = au.container_id INNER JOIN sys.partition_schemes ps ON ps.data_space_id = i.data_space_id INNER JOIN sys.partition_functions f ON f.function_id = ps.function_id INNER JOIN sys.destination_data_spaces dds ON dds.partition_scheme_id = ps.data_space_id AND dds.destination_id = p.partition_number INNER JOIN sys.filegroups fg ON dds.data_space_id = fg.data_space_id LEFT OUTER JOIN sys.partition_range_values rv ON f.function_id = rv.function_id AND p.partition_number = rv.boundary_id WHERE i.index_id < 2 AND o.object_id = OBJECT_ID(@TableName);
GO

--object	p#	filegroup	rows	pages	comparison	value	first_page
--dbo.Alta_Coleg	1	FG_Archivo	3	9	less than	2016-01-01 00:00:00.000	3:8
--dbo.Alta_Coleg	2	FG_2016	3	9	less than	2017-01-01 00:00:00.000	4:8
--dbo.Alta_Coleg	3	FG_2017	0	0	less than	NULL	0:0

--------------------
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
--2	Lucas	Garc�a	2015-05-05 00:00:00.000	1
--3	Manuel	Sanchez	2015-08-11 00:00:00.000	1
--4	Laura	Mu�oz	2016-06-23 00:00:00.000	2
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
	('Adolfo','Mu�iz','2018-01-23'), 
	('Rosario','Fuertes','2018-02-23')
GO



SELECT *,$Partition.FN_altas_fecha(fecha_alta) as PARTITION
FROM Alta_Coleg
GO

--id_alta	nombre	apellido	fecha_alta	PARTITION
--1	Antonio	Ruiz	2015-01-01 00:00:00.000	1
--2	Lucas	Garc�a	2015-05-05 00:00:00.000	1
--3	Manuel	Sanchez	2015-08-11 00:00:00.000	1
--4	Laura	Mu�oz	2016-06-23 00:00:00.000	2
--5	Rosa Maria	Leandro	2016-02-03 00:00:00.000	2
--6	Federico	Ramos	2016-04-06 00:00:00.000	2
--7	Ismael	Cabana	2017-05-21 00:00:00.000	3
--8	Alejandra	Martinez	2017-07-09 00:00:00.000	3
--9	Alfonso	Verdes	2017-09-12 00:00:00.000	3
--10	Amanda	Smith	2018-02-12 00:00:00.000	3
--11	Adolfo	Mu�iz	2018-01-23 00:00:00.000	3
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

--NO SALEN EN LA PARTICI�N DE 2018 YA QUE NO SE A�ADI� UN INERVALO DE FECHAS EN ESA PARTICI�N

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
--11	Adolfo	Mu�iz	2018-01-23 00:00:00.000
--12	Rosario	Fuertes	2018-02-23 00:00:00.000


select * from Archivo_Altas 
go

--id_alta	nombre	apellido	fecha_alta
--1	Antonio	Ruiz	2015-01-01 00:00:00.000
--2	Lucas	Garc�a	2015-05-05 00:00:00.000
--3	Manuel	Sanchez	2015-08-11 00:00:00.000
--4	Laura	Mu�oz	2016-06-23 00:00:00.000
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










