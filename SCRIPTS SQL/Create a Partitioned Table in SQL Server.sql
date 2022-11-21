
-- Create a Partitioned Table in SQL Server (T-SQL)
-- https://database.guide/create-a-partitioned-table-in-sql-server-t-sql/

USE master
GO
DROP DATABASE IF EXISTS Test
GO
CREATE DATABASE Test
GO
USE Test
GO

-- -- CREATE FOLDER TEST
-- 'C:\TEST\
-- Create filegroups AND Files

ALTER DATABASE Test
ADD FILEGROUP MoviesFg1;
GO  
ALTER DATABASE Test  
ADD FILEGROUP MoviesFg2;  
GO  
ALTER DATABASE Test  
ADD FILEGROUP MoviesFg3;  
GO  
ALTER DATABASE Test  
ADD FILEGROUP MoviesFg4;   
GO
ALTER DATABASE Test   
ADD FILE   
(  
    NAME = MoviesFg1dat,  
    FILENAME = 'C:\TEST\MoviesFg1dat.ndf',  
    SIZE = 5MB,  
    MAXSIZE = 100MB,  
    FILEGROWTH = 5MB  
)  
TO FILEGROUP MoviesFg1;  
ALTER DATABASE Test   
ADD FILE   
(  
    NAME = MoviesFg2dat,  
    FILENAME = 'C:\TEST\MoviesFg2dat.ndf',  
    SIZE = 5MB,  
    MAXSIZE = 100MB,  
    FILEGROWTH = 5MB  
)  
TO FILEGROUP MoviesFg2;  
GO  
ALTER DATABASE Test   
ADD FILE   
(  
    NAME = MoviesFg3dat,  
    FILENAME = 'C:\TEST\MoviesFg3dat.ndf',  
    SIZE = 5MB,  
    MAXSIZE = 100MB,  
    FILEGROWTH = 5MB  
)  
TO FILEGROUP MoviesFg3;  
GO  
ALTER DATABASE Test   
ADD FILE   
(  
    NAME = MoviesFg4dat,  
    FILENAME = 'C:\TEST\MoviesFg4dat.ndf',  
    SIZE = 5MB,  
    MAXSIZE = 100MB,  
    FILEGROWTH = 5MB  
)  
TO FILEGROUP MoviesFg4;  
GO

--Creamos las particiones

CREATE PARTITION FUNCTION MoviesPartitionFunction (int)  
    AS RANGE LEFT FOR VALUES (1, 100, 1000);
GO
--
--Given these boundary values, and the fact that I specified a RANGE LEFT partition, the four partitions will hold values as specified in the following table.

--Partition	Values
--1			<= 1
--2		> 1 AND <= 100
--3		> 100 AND <=1000
--4			> 1000

--If I had specified a RANGE RIGHT partition, the breakdown would be slightly different, as outlined in the following table.

--Partition	Values
--1			< 1
--2		>= 1 AND < 100
--3		>= 100 AND < 1000
--4			>= 1000

--The same concept applies if the partitioning column uses other data types, such as date/time values.
--
CREATE PARTITION SCHEME MoviesPartitionScheme  
    AS PARTITION MoviesPartitionFunction  
    TO (MoviesFg1, MoviesFg2, MoviesFg3, MoviesFg4);  
GO

DROP TABLE IF EXISTS Movies
GO
CREATE TABLE Movies (
    MovieId int IDENTITY (1,10) PRIMARY KEY, 
    MovieName varchar(60) DEFAULT 'Titanic'
    )  
    ON MoviesPartitionScheme (MovieId);  
GO

SELECT * FROM sys.partition_functions;
go

SELECT * FROM sys.partition_schemes;
GO

SELECT 
    object_schema_name(i.object_id) AS [Schema],
    object_name(i.object_id) AS [Object],
    i.name AS [Index],
    s.name AS [Partition Scheme]
    FROM sys.indexes i
    INNER JOIN sys.partition_schemes s ON i.data_space_id = s.data_space_id;
GO


--inserta 3333 registros
INSERT Movies
VALUES ('Fargo')
GO 3333

SELECT * FROM Movies
GO

-- (3333 rows affected)


--COMPROBAMOS QUE SE REPARTIERON LOS REGISTROS EN LAS PARTICIONES SEGUN LOS VALORES ANTERIORES

SELECT 
    partition_number,
    row_count
FROM sys.dm_db_partition_stats
WHERE object_id = OBJECT_ID('dbo.Movies');
GO

--partition_number	row_count
--1						1
--2						9
--3						90
--4						3233


--HASTA AQUI
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--However, it’s worth noting that the Microsoft documentation actually states that this column is just an approximate count of the rows in each partition.

--Best Practice
--Microsoft recommends that we always keep empty partitions at both ends of the partition range.

--This is in case you need to either split or merge the partitions in the future.

--The reason for this recommendation is to guarantee that the partition split and the partition merge don’t incur any unexpected data movement.

--Therefore, given the data in my example, I could change the partition function to look something like this:

--DROP PARTITION FUNCTION MoviesPartitionFunction
--GO
CREATE PARTITION FUNCTION MoviesPartitionFunction (int)  
    AS RANGE LEFT FOR VALUES (-1, 100, 10000);
GO
CREATE PARTITION SCHEME MoviesPartitionScheme  
    AS PARTITION MoviesPartitionFunction  
    TO (MoviesFg1, MoviesFg2, MoviesFg3, MoviesFg4);  
GO

DROP TABLE IF EXISTS Movies
GO
CREATE TABLE Movies (
    MovieId int IDENTITY (1,10) PRIMARY KEY, 
    MovieName varchar(60)
    )  
    ON MoviesPartitionScheme (MovieId);  
GO

SELECT * FROM sys.partition_functions;
go

SELECT * FROM sys.partition_schemes;
GO

SELECT 
    object_schema_name(i.object_id) AS [Schema],
    object_name(i.object_id) AS [Object],
    i.name AS [Index],
    s.name AS [Partition Scheme]
    FROM sys.indexes i
    INNER JOIN sys.partition_schemes s ON i.data_space_id = s.data_space_id;
GO

INSERT Movies
VALUES ('Fargo')
GO 3333

SELECT * FROM Movies
GO
SELECT 
    partition_number,
    row_count
FROM sys.dm_db_partition_stats
WHERE object_id = OBJECT_ID('dbo.Movies');
GO

--partition_number	row_count
--1	0
--2	10
--3	990
--4	2333

-- and you want to determine which partition a given value would be mapped to, 
-- you can do this nice and quickly with the $PARTITION system function.

-- All you need to know is the name of the partition function (and of course, the value you’re interested in).

SELECT $PARTITION.MoviesPartitionFunction(4) AS PARTITION;
GO
-- 2
SELECT $PARTITION.MoviesPartitionFunction(2222) AS PARTITION;
GO
-- 3
SELECT $PARTITION.MoviesPartitionFunction(3333) AS PARTITION;
GO
SELECT $PARTITION.MoviesPartitionFunction(13333) AS PARTITION;
GO
-- 4

SELECT [MovieId],[MovieName],
    $PARTITION.MoviesPartitionFunction(MovieId) AS [Partition]
FROM Movies;

-- https://database.guide/return-all-rows-from-a-specific-partition-in-sql-server-t-sql/

-- Return Data from the Second Partition

SELECT * FROM Movies
WHERE $PARTITION.MoviesPartitionFunction(MovieId) = 2;
GO

-- (10 rows affected)

-- Return Data from the Third Partition
SELECT * FROM Movies
WHERE $PARTITION.MoviesPartitionFunction(MovieId) = 3;
GO
-- 990

-- to determine the partitioning column for a partitioned table.

SELECT 
    t.name AS [Table], 
    c.name AS [Partitioning Column],
    TYPE_NAME(c.user_type_id) AS [Column Type],
    ps.name AS [Partition Scheme] 
FROM sys.tables AS t   
JOIN sys.indexes AS i   
    ON t.[object_id] = i.[object_id]   
    AND i.[type] <= 1
JOIN sys.partition_schemes AS ps   
    ON ps.data_space_id = i.data_space_id   
JOIN sys.index_columns AS ic   
    ON ic.[object_id] = i.[object_id]   
    AND ic.index_id = i.index_id   
    AND ic.partition_ordinal >= 1 
JOIN sys.columns AS c   
    ON t.[object_id] = c.[object_id]   
    AND ic.column_id = c.column_id   
WHERE t.name = 'Movies';
go

--Table	Partitioning Column	Column Type	Partition Scheme
--Movies	MovieId	int	MoviesPartitionScheme

-- Get the Boundary Values for a Partitioned Table in SQL Server (T-SQL)

SELECT * FROM sys.partition_range_values;
GO

--function_id	boundary_id	parameter_id	value
--65536	1	1	-1
--65536	2	1	100
--65536	3	1	10000



