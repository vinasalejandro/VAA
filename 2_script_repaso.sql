
--SCRIPT BACKUP BD

USE master
GO

DROP PROCEDURE IF EXISTS BACKUP_ALL_DB_PARENTRADA
GO
 
 --crear procedimiento almacenado para backup

CREATE OR ALTER PROC BACKUP_ALL_DB_PARENTRADA
	@path VARCHAR(256)='C:\backup\'
AS
DECLARE
	--@path VARCHAR (256),
	@name VARCHAR(50),
	@fileName VARCHAR(256),
	@fileDate VARCHAR(20),
	@backupCount INT
CREATE TABLE dbo.#tempBackup
(intID INT IDENTITY (1, 1),
Name VARCHAR(200))

--incluir la fecha en el filename

SET @fileDate = CONVERT (VARCHAR(20), GETDATE(), 112)

--incluir fecha y hora en el filename

--SET @fileDate = CONVERT (VARCHAR(20), GETDATE(), 112) + '_' + REPLACE(CONVERT(VARCHAR(20), GETDATE

INSERT INTO dbo.#tempBackup (name)
	SELECT name
	FROM master.dbo.sysdatabases
	WHERE name in ('Northwind','pubs','AdventureWorks2019')
	--la opción contraria seria
	--WHERE name not in ('master','model',''tempdb')  

SELECT TOP 1 @backupCount = intID
FROM dbo.#tempBackup
ORDER BY intID DESC


--Utilidad: solo comprobación Nº backups a realizar

PRINT @backupCount

IF ((@backupCount IS NOT NULL) AND (@backupCount > 0 ))
BEGIN
	DECLARE @currentBackup INT
	SET @currentBackup = 1
	WHILE (@currentBackup <= @backupCount)
		BEGIN
			SELECT
				@name = name,
				@fileName = @path + name + '_' + @fileDate + '.BAK' --Unique Filename
				FROM dbo.#tempBackup
				WHERE intID = @currentBackup


				--Utilidad: solo comprobación nombre backup
				PRINT @fileName
					
					--does not overwrite the existing file
					BACKUP DATABASE @name TO DISK = @fileName
					--overwrites the existing file (note: remove @fileDate from the fileName source
					--BACKUP DATABASE @name TO DISK = @fileName WITH INIT

					SET @currentBackup = @currentBackup +1
		END
END



GO







--ejecutar procedimiento 

--parametro de entrada ruta de la carpeta donde se hará el backup

EXEC BACKUP_ALL_DB_PARENTRADA
GO