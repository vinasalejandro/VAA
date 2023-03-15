

--sin filestream

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






USE Alquiler_Avionetas
GO

ALTER DATABASE Alquiler_Avionetas
	ADD FILEGROUP Alquiler_Avionetas_filestream
	CONTAINS FILESTREAM
GO

ALTER DATABASE Alquiler_Avionetas
	ADD FILE (
		NAME = 'Alquiler_Avionetas_filestream',
		FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\Alquiler_Avionetas_FILESTREAM'
		)
		TO FILEGROUP Alquiler_Avionetas_filestream
GO




--otro ejemplo

DROP TABLE IF EXISTS Imagenes
GO

CREATE TABLE Imagenes
(
	ID UNIQUEIDENTIFIER ROWGUIDCOL NOT NULL UNIQUE,
	IMAGEFILE VARBINARY(MAX) FILESTREAM
);
GO


INSERT INTO Imagenes(ID,IMAGEFILE)
	SELECT NEWID(), BULKCOLUMN
	FROM OPENROWSET (BULK 'C:\Imagenes\Avioneta1.jpg',SINGLE_BLOB) AS f;
GO

INSERT INTO Imagenes (ID,IMAGEFILE)
	SELECT NEWID(), BULKCOLUMN
	FROM OPENROWSET (BULK 'C:\Imagenes\Avioneta2.jpg',SINGLE_BLOB) AS f;
GO

INSERT INTO Imagenes (ID,IMAGEFILE)
	SELECT NEWID(), BULKCOLUMN
	FROM OPENROWSET (BULK 'C:\Imagenes\Avioneta3.jpg',SINGLE_BLOB) AS f;
GO

SELECT * FROM Imagenes
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





ALTER DATABASE Alquiler_Avionetas
SET FILESTREAM (DIRECTORY_NAME = 'Alquiler_Avionetas_filestream') WITH ROLLBACK IMMEDIATE
GO

ALTER DATABASE Alquiler_Avionetas
	SET FILESTREAM (NON_TRANSACTED_ACCESS = FULL, DIRECTORY_NAME = 'Alquiler_Avionetas_filestream') WITH ROLLBACK IMMEDIATE
GO


DROP TABLE IF EXISTS Imagenes
GO

CREATE TABLE Imagenes AS FILETABLE
WITH
	( Filetable_Directory = 'Alquiler_Avionetas_filestream',
	FileTable_Collate_Filename = database_default);
GO



SELECT * FROM Imagenes
GO