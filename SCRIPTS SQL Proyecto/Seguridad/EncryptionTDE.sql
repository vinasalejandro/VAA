-- TRANSPARENT DATA ENCRYPTION (TDE)

-- AT REST
-- mdf, ndf, ldf

--Configuring a SQL Server database for TDE is a straight-forward process. It consists of:

--Creating the database master key in the master database.
--Creating a certificate encrypted by that key.
--Backing up the certificate and the certificate's private key. While this isn't required to encrypt the database, you want to do this immediately.
--Creating a database encryption key in the database that's encrypted by the certificate.
--Altering the database to turn encryption on.


DROP DATABASE IF EXISTS Alquiler_AvionetasTDE
GO
-- Create our test database
CREATE DATABASE Alquiler_AvionetasTDE
GO 

-- Create the DEK (DATABASE ENCRYPTION KEY)so we can turn on encryption
USE Alquiler_AvionetasTDE;
GO 

-- Create the database master key
-- to encrypt the certificate
CREATE MASTER KEY
  ENCRYPTION BY PASSWORD = 'abc123.';
GO 

-- Create the certificate we're going to use for TDE
CREATE CERTIFICATE TDECertVAA
  WITH SUBJECT = 'TDE cert VAA';
GO 
-- VER EN SSMS EL CERTIFICADO    -BD MASTER -SECURITY -CERTIFICATES

-- CERTIFICATES T-SQL

SELECT TOP 1 * 
FROM sys.certificates 
ORDER BY name DESC
GO

--name	certificate_id	principal_id	pvt_key_encryption_type	pvt_key_encryption_type_desc	is_active_for_begin_dialog	issuer_name	cert_serial_number	sid	string_sid	subject	expiry_date	start_date	thumbprint	attested_by	pvt_key_last_backup_date	key_length
--TDECert	277	1	MK	ENCRYPTED_BY_MASTER_KEY	1	TDE Cert for Test	37 c5 aa 01 a2 ce 59 9d 44 7e 34 0e 1f 09 34 77	0x010600000000000901000000BF05FDBA4584C56ACAEC9AE38E0FF4EED74E7F83	S-1-9-1-3137144255-1791329349-3818581194-4008972174-2206158551	TDE Cert for Test	2022-04-21 14:59:51.000	2021-04-21 14:59:51.000	0xBF05FDBA4584C56ACAEC9AE38E0FF4EED74E7F83	NULL	NULL	2048


-- Back up the certificate and its private key
-- Remember the password!
BACKUP CERTIFICATE TDECertVAA
  TO FILE = 'C:\CERTIFICADOS\TDECertVAA.cer'
  WITH PRIVATE KEY ( 
    FILE = 'C:\CERTIFICADOS\TDECertVAA_key.pvk',
 ENCRYPTION BY PASSWORD = 'abcd123.'
  );
GO
-- Look at Folder C:\CERTIFICADOS


 

CREATE DATABASE ENCRYPTION KEY
  WITH ALGORITHM = AES_256
  ENCRYPTION BY SERVER CERTIFICATE TDECertVAA;
GO 

-- INFORMATION

SELECT  * 
FROM sys.dm_database_encryption_keys
GO


-- Exit out of the database. If we have an active 
-- connection, encryption won't complete.
USE [master];
GO 

-- Turn on TDE
-- T-SQL OR SSMS

ALTER DATABASE Alquiler_AvionetasTDE  SET ENCRYPTION ON;
GO 


SELECT DB_Name(database_id) AS 'Database', encryption_state 
FROM sys.dm_database_encryption_keys;
GO

--Database	encryption_state
--tempdb			3
--RecoveryWithTDE	3

USE master
go



BACKUP DATABASE Alquiler_AvionetasTDE
TO DISK = 'C:\CERTIFICADOS\Alquiler_AvionetasTDE_Full.bak';
GO 

--Processed 288 pages for database 'RecoveryWithTDE', file 'RecoveryWithTDE' on file 1.
--Processed 3 pages for database 'RecoveryWithTDE', file 'RecoveryWithTDE_log' on file 1.
--BACKUP DATABASE successfully processed 291 pages in 0.347 seconds (6.531 MB/sec).

BACKUP LOG Alquiler_AvionetasTDE
TO DISK = 'C:\CERTIFICADOS\Alquiler_AvionetasTDE_log.bak'
With NORECOVERY
GO


CREATE CERTIFICATE TDECertVAA
    FROM FILE = 'C:\CERTIFICADOS\TDECertVAA.cer'
     WITH PRIVATE KEY 
      ( 
        FILE = 'C:\CERTIFICADOS\TDECertVAA_key.pvk',
        DECRYPTION BY PASSWORD = 'abc123.' 
      ) 
GO


RESTORE DATABASE Alquiler_AvionetasTDE
	FROM  DISK = 'C:\CERTIFICADOS\Alquiler_AvionetasTDE_full.bak' 
    WITH  FILE = 1,  NOUNLOAD,  STATS = 5
GO




























--Processed 4 pages for database 'RecoveryWithTDE', file 'RecoveryWithTDE_log' on file 1.
--BACKUP LOG successfully processed 4 pages in 0.093 seconds (0.304 MB/sec).


------------------------------------
-- EN UNA SEGUNDA INSTANCIA PODEMOS

-- RESTORE BACKUP CON / SIN CERTIFICADO
-- ATTACH .mdf .ldf

------------------------------------








-- Restoring the certificate, but without the private key.
CREATE CERTIFICATE TDECertVAA
  FROM FILE = 'C:\CERTIFICADOS\TDECertVAA.cer'
  WITH PRIVATE KEY ( 
    FILE = N'C:\CERTIFICADOS\TDECertVAA_key.pvk',
 DECRYPTION BY PASSWORD = 'abcd123.'
  );
GO

-- We have the correct certificate and we've also restored the 
-- private key. Now everything should work. Finally!
RESTORE DATABASE [RecoveryWithTDE]
  FROM DISK = N'C:\SQLBackups\RecoveryWithTDE_Full.bak'
  WITH MOVE 'RecoveryWithTDE' TO N'C:\SQLData\RecoveryWithTDE_2ndServer.mdf',
       MOVE 'RecoveryWithTDE_log' TO N'C:\SQLData\RecoveryWithTDE_2ndServer_log.mdf';
GO

-- With everything in place, we are finally successful!

------------------------------------
-- EN UNA SEGUNDA INSTANCIA PODEMOS

-- ATTACH .mdf .ldf

-- DETACH (separar)

-- C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\RecoveryWithTDE.mdf

-- Voy al otro Servidor e intento ATTACH (adjuntar)

-- SIN CERTIFICADO ERROR
-- CON CERTIFICADO FUNCIONA ATTACH

-- ESTO SOLO FUNCIONABA CON LA VERSION ENTERPRISE, NO CON LA STANDARD
-- EN SQL SERVER 2019 FUNCIONA EN LA STANDARD

-- COPIO EN LA CARPETA CERTIFICADOS EL MDF/LDF PARA INTENTAR LA RESTAURACION EN OTRO SERVIDOR

-- COMO ESTA EN RESTORING NO PUEDO PONERLA FUERA DE LINEA PARA COPIAR LOS ARCHIVOS FISICOS.

-- PARA SACARLA DE RESTORING

RESTORE DATABASE [RecoveryWithTDEVAA] WITH RECOVERY
GO

-- RESTORE DATABASE successfully processed 0 pages in 0.339 seconds (0.000 MB/sec).


-- DETACH DESDE GUI
-- BD DESAPARECE EXPLORADOR DE OBJETOS

-- ATTACH EN EL OTRO SERVIDOR

