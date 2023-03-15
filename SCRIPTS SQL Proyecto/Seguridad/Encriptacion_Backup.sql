
--ENCRIPTACIÓN DE BACKUP


--PRIMER SERVIDOR (source)
DROP DATABASE IF EXISTS Alquiler_Avionetas2
GO
CREATE DATABASE Alquiler_Avionetas2
GO

USE Alquiler_Avionetas2
GO



--creamos la master key
--si da error es que ya esta creada

CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'abc123.'
GO

--creamos el certificado
drop certificate CertificadoBackup
go

CREATE CERTIFICATE CertificadoBackup
	WITH SUBJECT = 'Certificado';
GO

--comprobamos que se creó el certificado

SELECT * FROM sys.certificates
GO


--nos avisa de que debemos hacer un backup del certificado y la clave ya que si lo perdemos no podremos desencriptar

CREATE DATABASE ENCRYPTION KEY 
WITH ALGORITHM = AES_256
ENCRYPTION BY SERVER CERTIFICATE CertificadoBackup;
GO

--hacemos un backup de la base de datos usando el certificado y la clave (encriptamos el backup)

USE master
GO

BACKUP DATABASE Alquiler_Avionetas2
TO DISK = 'C:\AlquilerAvionetasBackup\Alquiler_Avionetas2.bak'
WITH ENCRYPTION (
	ALGORITHM = AES_256, SERVER CERTIFICATE = CertificadoBackup),
STATS = 10 --marca progreso
GO


--hacemos el backup del certificado

BACKUP CERTIFICATE CertificadoBackup
	TO FILE = 'C:\AlquilerAvionetasBackup\CertificadoBackup'
	WITH PRIVATE KEY
		(
		FILE = 'C:\AlquilerAvionetasBackup\CertificadoBackup.pvk',
		ENCRYPTION BY PASSWORD = 'abc123.'
		)
GO


----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--SEGUNDO SERVIDOR en 




-- Restaurando Certificado en el 2 Servidor

CREATE CERTIFICATE CertificadoBackup1  
    FROM FILE = 'C:\AlquilerAvionetasBackup\CertificadoBackup'
     WITH PRIVATE KEY 
      ( 
        FILE = 'C:\AlquilerAvionetasBackup\CertificadoBackup.pvk' ,
        DECRYPTION BY PASSWORD = 'abc123.' 
      ) 
GO
 
 --restauramos la bd


RESTORE DATABASE Alquiler_Avionetas2
    FROM  DISK = 'C:\AlquilerAvionetasBackup\Alquiler_Avionetas2.bak' 
    WITH  FILE = 1,  NOUNLOAD,  STATS = 5
GO


