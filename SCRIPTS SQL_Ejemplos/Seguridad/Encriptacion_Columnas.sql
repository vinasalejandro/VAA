
--ENCRIPTACIÓN DE COLUMNAS

--Ejemplo hospital

USE master
GO

--creamos los login (los login son a nivel de servidor)

CREATE LOGIN doctor1 WITH PASSWORD='abc123.'
GO

CREATE LOGIN doctor2 WITH PASSWORD='abc123.'
GO

--creamos la base de datos

DROP DATABASE IF EXISTS hospitaldb
GO

CREATE DATABASE hospitaldb
GO

USE hospitaldb
GO

--creamos los usuarios para los login

DROP USER IF EXISTS doctor1
GO

DROP USER IF EXISTS doctor1
GO

CREATE USER doctor1 FOR LOGIN doctor1
GO

CREATE USER doctor2 FOR LOGIN doctor2
GO


--creamos la tabla

DROP TABLE IF EXISTS patientdata
GO

CREATE TABLE patientdata
(
	id INT,
	name NVARCHAR(30),
	doctorname VARCHAR(25),
	uid VARBINARY(1000),
	symptom VARBINARY(4000)
)
GO

--concedemos permisos a los doctores sobre la tabla

GRANT SELECT, INSERT ON patientdata TO doctor1;
GRANT SELECT, INSERT ON patientdata TO doctor2;
GO


--Creamos la master key

DROP MASTER KEY
GO

CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'abc123.'
GO

--consultamos las claves creadas en el sistema

SELECT name KeyName,
	symmetric_key_id keyID,
	key_length KeyLength,
	algorithm_desc KeyAlgorithm
FROM sys.symmetric_keys;
GO


--Creamos los certificados para los doctores

CREATE CERTIFICATE doctor1cert AUTHORIZATION doctor1
WITH SUBJECT = 'abc123.', START_DATE ='01/01/2023'
GO

CREATE CERTIFICATE doctor2cert AUTHORIZATION doctor2
WITH SUBJECT = 'abc123.', START_DATE ='01/01/2023'
GO


--vemos los certificados creados

SELECT NAME certName,
	certificate_id CertID,
	pvt_key_encryption_type_desc EncryptType,
	issuer_name Issuer
FROM sys.certificates;
GO


--Creamos las claves simetricas para los doctores

CREATE SYMMETRIC KEY doctor1key
WITH ALGORITHM = AES_256
ENCRYPTION BY CERTIFICATE doctor1cert
GO

CREATE SYMMETRIC KEY doctor2key
WITH ALGORITHM = AES_256
ENCRYPTION BY CERTIFICATE doctor2cert
GO

--consultamos la claves creadas en el sistema

SELECT name KeyName,
	symmetric_key_id keyID,
	key_length KeyLength,
	algorithm_desc KeyAlgorithm
FROM sys.symmetric_keys;
GO


--damos permisos a los usuarios sobre sus certificados

GRANT VIEW DEFINITION ON CERTIFICATE::doctor1cert TO doctor1
GO
GRANT VIEW DEFINITION ON SYMMETRIC KEY::doctor1key TO doctor1
GO

GRANT VIEW DEFINITION ON CERTIFICATE::doctor2cert TO doctor2
GO
GRANT VIEW DEFINITION ON SYMMETRIC KEY::doctor2key TO doctor2
GO


--impersonamos al doctor1

EXECUTE AS USER = 'doctor1'
GO
PRINT USER
GO

OPEN SYMMETRIC KEY doctor1key
	DECRYPTION BY CERTIFICATE doctor1cert
GO


--insertamos datos

INSERT INTO patientdata
VALUES (1, 'Jack', 'Doctor1', ENCRYPTBYKEY(Key_guid('doctor1key'), '1111111111'),
ENCRYPTBYKEY(Key_guid('doctor1key'), 'cut'))
GO

INSERT INTO patientdata
VALUES (2, 'Jill', 'Doctor1', ENCRYPTBYKEY(Key_guid('doctor1key'), '1111111111'),
ENCRYPTBYKEY(Key_guid('doctor1key'), 'Bruise'))
GO

INSERT INTO patientdata
VALUES (3, 'Jim', 'Doctor1', ENCRYPTBYKEY(Key_guid('doctor1key'), '1111111111'),
ENCRYPTBYKEY(Key_guid('doctor1key'), 'Head ache'))
GO



--hacemos lo mismo con el doctor2

REVERT
GO
EXECUTE AS USER = 'doctor2'
GO
PRINT USER
GO

OPEN SYMMETRIC KEY doctor2key
	DECRYPTION BY CERTIFICATE doctor2cert
GO

--comprobamos las claves que estan abiertas

SELECT * FROM sys.openkeys
GO

--insertamos datos

INSERT INTO patientdata
VALUES (4, 'Rick', 'Doctor2', ENCRYPTBYKEY(Key_guid('doctor2key'), '444444444'),
ENCRYPTBYKEY(Key_guid('doctor2key'), 'cough'))
GO

INSERT INTO patientdata
VALUES (5, 'Joe', 'Doctor2', ENCRYPTBYKEY(Key_guid('doctor2key'), '55555555'),
ENCRYPTBYKEY(Key_guid('doctor2key'), 'Asthma'))
GO

INSERT INTO patientdata
VALUES (6, 'Pro', 'Doctor2', ENCRYPTBYKEY(Key_guid('doctor2key'), '666666666'),
ENCRYPTBYKEY(Key_guid('doctor2key'), 'cold'))
GO


--comprobamos que esta encriptado

SELECT NAME,UID,symptom FROM patientdata
GO

SELECT name, doctorname, symptom
FROM patientdata
GO



--Desencriptamos con doctor1 (no debemos ver nada del doctor2)

REVERT
GO

EXECUTE AS USER = 'doctor1'
GO

OPEN SYMMETRIC KEY doctor1key
	DECRYPTION BY CERTIFICATE doctor1cert
GO

SELECT id, name, doctorname, CONVERT(VARCHAR, DECRYPTBYKEY(uid)) AS UID,
CONVERT (VARCHAR, DECRYPTBYKEY(symptom)) AS Sintomas
FROM patientdata
GO


REVERT
GO

CLOSE ALL SYMMETRIC KEYS
GO


--desencriptamos con doctor2 (no debemos ver nada del doctor1)

EXECUTE AS USER = 'doctor2'
GO

OPEN SYMMETRIC KEY doctor2key
	DECRYPTION BY CERTIFICATE doctor2cert
GO

SELECT id, name, doctorname, CONVERT(VARCHAR, DECRYPTBYKEY(uid)) AS UID,
CONVERT (VARCHAR, DECRYPTBYKEY(symptom)) AS Sintomas
FROM patientdata
GO

REVERT 
GO


