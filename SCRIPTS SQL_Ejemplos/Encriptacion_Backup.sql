
--ENCRIPTACIÓN DE BACKUP


--PRIMER SERVIDOR

USE master
GO

DROP DATABASE IF EXISTS testBackup
GO

CREATE DATABASE testBackup
GO

USE testBackup
GO

--generamos el script de la tabla authors de pubs


CREATE TABLE [dbo].[authors](
	[au_id] int  NOT NULL,
	[au_lname] [varchar](40) NOT NULL,
	[au_fname] [varchar](20) NOT NULL,
	[phone] [char](12) NOT NULL,
	[address] [varchar](40) NULL,
	[city] [varchar](20) NULL,
	[state] [char](2) NULL,
	[zip] [char](5) NULL,
	[contract] [bit] NOT NULL)
GO




USE master
GO


--creamos la master key
--si da error es que ya esta creada

CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'abc123.'
GO


--creamos el certificado

CREATE CERTIFICATE MyServerCert
	WITH SUBJECT = 'Mi certificado TDE';
GO


--comprobamos que se creó el certificado

SELECT * FROM sys.certificates
GO


USE testBackup
GO

--nos avisa de que debemos hacer un backup del certificado y la clave ya que si lo perdemos no podremos desencriptar

CREATE DATABASE ENCRYPTION KEY 
WITH ALGORITHM = AES_256
ENCRYPTION BY SERVER CERTIFICATE MyServerCert;
GO

--hacemos un backup de la base de datos usando el certificado y la clave (encriptamos el backup)

USE master
GO

BACKUP DATABASE testBackup
TO DISK = 'C:\temp\testBackup.bak'
WITH ENCRYPTION (
	ALGORITHM = AES_256, SERVER CERTIFICATE = MyServerCert),
STATS = 10 --marca progreso
GO


--hacemos el backup del certificado

BACKUP CERTIFICATE MyServerCert
	TO FILE = 'C:\temp\MyServerCert'
	WITH PRIVATE KEY
		(
		FILE = 'C:\temp\MyServerCert.pvr',
		ENCRYPTION BY PASSWORD = 'abc123.'
		)
GO



--SEGUNDO SERVIDOR

RESTORE DATABASE testBackup
	FROM DISK = 'C:\temp\testBackup.bak'
	WITH FILE = 1, NOUNLOAD, STATS = 5,
	MOVE N'testBackup' TO 'C:\test',
	MOVE N'testBackup_log' TO 'C:\test'
GO


