


USE IMAGENES
GO

DROP TABLE IF EXISTS dbo.documentos
GO


CREATE TABLE dbo.documentos
(
	ID INT IDENTITY,
	Nombre VARCHAR(255),
	Contenido VARBINARY(MAX),
	EXTENSION CHAR(4)
)

GO

INSERT INTO dbo.documentos(Nombre,Contenido,EXTENSION)
SELECT 'BRAD', BULKCOLUMN,'JPG'
FROM OPENROWSET (BULK N'C:\Imagenes\arbusto.jpg', SINGLE_BLOB) AS DOCUMENT
GO

INSERT INTO dbo.documentos(Nombre,Contenido,EXTENSION)
SELECT 'TOM', BULKCOLUMN,'JPG'
FROM OPENROWSET (BULK N'C:\Imagenes\flor.jpg', SINGLE_BLOB) AS DOCUMENT
GO


SELECT * FROM dbo.documentos
GO


--ejemplo con la bd del proyecto

USE Alquiler_Avionetas
GO

DROP TABLE IF EXISTS dbo.avionetas
GO


CREATE TABLE dbo.avionetas
(
	ID INT IDENTITY,
	Nombre VARCHAR(255),
	Contenido VARBINARY(MAX),
	EXTENSION CHAR(4)
)

GO

INSERT INTO dbo.avionetas(Nombre,Contenido,EXTENSION)
SELECT 'Avioneta1', BULKCOLUMN,'JPG'
FROM OPENROWSET (BULK N'C:\Imagenes\Avioneta1.jpg', SINGLE_BLOB) AS DOCUMENT
GO

INSERT INTO dbo.avionetas(Nombre,Contenido,EXTENSION)
SELECT 'Avioneta2', BULKCOLUMN,'JPG'
FROM OPENROWSET (BULK N'C:\Imagenes\Avioneta2.jpg', SINGLE_BLOB) AS DOCUMENT
GO


SELECT * FROM dbo.avionetas
GO






--------------------------------------------------------------------------------------------------------------------------------------------------

--FILESTREAM

--Se deberá habilitar la posibilidad de usar el FILESTREAM desde el Configuration manager


EXEC sp_configure filestream_access_level,2
RECONFIGURE
GO




USE master
GO

DROP DATABASE IF EXISTS PruebaFS
GO

CREATE DATABASE PruebaFS
GO

USE PruebaFS
GO

ALTER DATABASE PruebaFS
	ADD FILEGROUP [PRIMARY_FILESTREAM]
	CONTAINS FILESTREAM
GO

ALTER DATABASE Alquiler_Avionetas
	ADD FILE (
		NAME = 'Alquiler_Avionetas_filestream',
		FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\FILESTREAM'
		)
		TO FILEGROUP [PRIMARY_FILESTREAM]
GO


--otro ejemplo

DROP TABLE IF EXISTS IMAGES
GO

CREATE TABLE IMAGES
(
	ID UNIQUEIDENTIFIER ROWGUIDCOL NOT NULL UNIQUE,
	IMAGEFILE VARBINARY(MAX) FILESTREAM
);
GO


INSERT INTO IMAGES (ID,IMAGEFILE)
	SELECT NEWID(), BULKCOLUMN
	FROM OPENROWSET (BULK 'C:\Imagenes\Avioneta1.jpg',SINGLE_BLOB) AS f;
GO

INSERT INTO IMAGES (ID,IMAGEFILE)
	SELECT NEWID(), BULKCOLUMN
	FROM OPENROWSET (BULK 'C:\Imagenes\arbusto.jpg',SINGLE_BLOB) AS f;
GO

INSERT INTO IMAGES (ID,IMAGEFILE)
	SELECT NEWID(), BULKCOLUMN
	FROM OPENROWSET (BULK 'C:\Imagenes\flor.jpg',SINGLE_BLOB) AS f;
GO

SELECT * FROM IMAGES
GO

--el filestream se guarda en la carpeta de ssms 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\FILESTREAM'



ALTER TABLE dbo.images DROP COLUMN [IMAGEFILE]
GO

ALTER TABLE IMAGES SET (FILESTREAM_ON="NULL")
GO

ALTER DATABASE PruebaFS REMOVE FILE MyDatabase_filestream;
GO







--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--FILETABLE

USE master
GO

DROP DATABASE IF EXISTS IMAGENES
GO


CREATE DATABASE IMAGENES
GO

USE IMAGENES
GO

ALTER DATABASE IMAGENES
SET FILESTREAM (DIRECTORY_NAME = 'IMAGENES') WITH ROLLBACK IMMEDIATE
GO

ALTER DATABASE IMAGENES 
	SET FILESTREAM (NON_TRANSACTED_ACCESS = FULL, DIRECTORY_NAME = 'IMAGENES') WITH ROLLBACK IMMEDIATE
GO


DROP TABLE IF EXISTS MyDocumentStore
GO

CREATE TABLE MyDocumentStore AS FILETABLE
WITH
	( Filetable_Directory = 'MyDocumentStore',
	FileTable_Collate_Filename = database_default);
	--FILETABLE_STREAMID_UNIQUE_CONSTRAINT_NAME=UQ_STREAM_id);
GO



