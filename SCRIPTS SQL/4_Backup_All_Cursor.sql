
USE master
GO

CREATE OR ALTER PROC Backup_con_Cursor
AS 
	BEGIN
		DECLARE @name VARCHAR(50)	--database name
		DECLARE @path VARCHAR (256)	--path for backup name
		DECLARE @filename VARCHAR(256)	--filename for backup
		DECLARE @fileDate VARCHAR(20)	--used for file name
		
		--specify database backup directory
		SET @path = 'C:\Backup\' 
		
		--specify filename format hour : minute


		SELECT @fileDate = CONVERT(VARCHAR(20),GETDATE(),112)+REPLACE(CONVERT(VARCHAR(20),GETDATE(),108),':','') --fecha, hora y minutos

		DECLARE db_cursor CURSOR READ_ONLY FOR
		SELECT name
		FROM master.dbo.sysdatabases
		WHERE name IN ('Northwind','AdventureWorks2019')
		--se puede hacer WHERE name NOT IN ('') y las que no queramos

		OPEN db_cursor
		FETCH NEXT FROM db_cursor INTO @name

		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @filename = @path + @name + '_' + @fileDate + '.BAK'
			BACKUP DATABASE @name TO DISK = @filename
			FETCH NEXT FROM db_cursor INTO @name
		END
		CLOSE db_cursor
		DEALLOCATE db_cursor
	END
GO

EXEC Backup_con_Cursor
GO

