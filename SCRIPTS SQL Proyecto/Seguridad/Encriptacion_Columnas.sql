
--ENCRIPTACIÓN DE COLUMNAS

--Ejemplo hospital

USE Alquiler_Avionetas
GO

--creamos los login (los login son a nivel de servidor)

CREATE LOGIN Piloto1 WITH PASSWORD='abc123.'
GO

CREATE LOGIN Piloto2 WITH PASSWORD='abc123.'
GO


--creamos los usuarios para los login

DROP USER IF EXISTS Piloto1
GO

DROP USER IF EXISTS Piloto2
GO

CREATE USER Piloto1 FOR LOGIN Piloto1
GO

CREATE USER Piloto2 FOR LOGIN Piloto2
GO


--creamos la tabla

DROP TABLE IF EXISTS Avioneta
GO

CREATE TABLE Avioneta
(
	id INT,
	Nombre_Piloto VARCHAR(25),
	Matricula_Avioneta VARBINARY(1000),
	Ruta_Vuelo VARBINARY(4000)
)
GO

--concedemos permisos a los doctores sobre la tabla

GRANT SELECT, INSERT ON Avioneta TO Piloto1;
GRANT SELECT, INSERT ON Avioneta TO Piloto2;
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

CREATE CERTIFICATE piloto1cert AUTHORIZATION piloto1
WITH SUBJECT = 'abc123.', START_DATE ='01/01/2023'
GO

CREATE CERTIFICATE piloto2cert AUTHORIZATION piloto2
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

CREATE SYMMETRIC KEY piloto1key
WITH ALGORITHM = AES_256
ENCRYPTION BY CERTIFICATE piloto1cert
GO

CREATE SYMMETRIC KEY piloto2key
WITH ALGORITHM = AES_256
ENCRYPTION BY CERTIFICATE piloto2cert
GO

--consultamos la claves creadas en el sistema

SELECT name KeyName,
	symmetric_key_id keyID,
	key_length KeyLength,
	algorithm_desc KeyAlgorithm
FROM sys.symmetric_keys;
GO


--damos permisos a los usuarios sobre sus certificados

GRANT VIEW DEFINITION ON CERTIFICATE::piloto1cert TO piloto1
GO
GRANT VIEW DEFINITION ON SYMMETRIC KEY::piloto1key TO piloto1
GO

GRANT VIEW DEFINITION ON CERTIFICATE::piloto2cert TO piloto2
GO
GRANT VIEW DEFINITION ON SYMMETRIC KEY::piloto2key TO piloto2
GO


--impersonamos al piloto1

EXECUTE AS USER = 'piloto1'
GO
PRINT USER
GO

OPEN SYMMETRIC KEY piloto1key
	DECRYPTION BY CERTIFICATE piloto1cert
GO


--insertamos datos

INSERT INTO Avioneta
VALUES (1, 'Fran',ENCRYPTBYKEY(Key_guid('piloto1key'), '111111111111'),
ENCRYPTBYKEY(Key_guid('piloto1key'), 'ACoruña_Lugo'))
GO

INSERT INTO Avioneta
VALUES (2, 'Fran',ENCRYPTBYKEY(Key_guid('piloto1key'), '222222222222'),
ENCRYPTBYKEY(Key_guid('piloto1key'), 'Oviedo_Burgos'))
GO

INSERT INTO Avioneta
VALUES (3, 'Fran',ENCRYPTBYKEY(Key_guid('piloto1key'), '333333333333'),
ENCRYPTBYKEY(Key_guid('piloto1key'), 'Madrid_Soria'))
GO


--hacemos lo mismo con el doctor2

REVERT
GO
EXECUTE AS USER = 'piloto2'
GO
PRINT USER
GO

OPEN SYMMETRIC KEY piloto2key
	DECRYPTION BY CERTIFICATE piloto2cert
GO

--comprobamos las claves que estan abiertas

SELECT * FROM sys.openkeys
GO

--insertamos datos

INSERT INTO Avioneta
VALUES (4, 'María',ENCRYPTBYKEY(Key_guid('piloto2key'), '444444444'),
ENCRYPTBYKEY(Key_guid('piloto2key'), 'León_Valladolid'))
GO

INSERT INTO Avioneta
VALUES (5, 'María',ENCRYPTBYKEY(Key_guid('piloto2key'), '5555555555'),
ENCRYPTBYKEY(Key_guid('piloto2key'), 'Madrid_Guadalajara'))
GO

INSERT INTO Avioneta
VALUES (6, 'María',ENCRYPTBYKEY(Key_guid('piloto2key'), '666666666'),
ENCRYPTBYKEY(Key_guid('piloto2key'), 'Barcelona_Madrid'))
GO


--comprobamos que esta encriptado



SELECT Nombre_Piloto, Matricula_Avioneta, Ruta_Vuelo
FROM Avioneta
GO



--Desencriptamos con doctor1 (no debemos ver nada del doctor2)

REVERT
GO

EXECUTE AS USER = 'piloto1'
GO

OPEN SYMMETRIC KEY piloto1key
	DECRYPTION BY CERTIFICATE piloto1cert
GO

SELECT id, Nombre_Piloto, CONVERT(VARCHAR, DECRYPTBYKEY(Matricula_Avioneta)) AS Matricula,
CONVERT (VARCHAR, DECRYPTBYKEY(Ruta_Vuelo)) AS Ruta_Vuelo
FROM Avioneta
GO


REVERT
GO

CLOSE ALL SYMMETRIC KEYS
GO


--desencriptamos con doctor2 (no debemos ver nada del doctor1)

EXECUTE AS USER = 'piloto2'
GO
OPEN SYMMETRIC KEY piloto2key
	DECRYPTION BY CERTIFICATE piloto2cert
GO

SELECT id, Nombre_Piloto, CONVERT(VARCHAR, DECRYPTBYKEY(Matricula_Avioneta)) AS Matricula,
CONVERT (VARCHAR, DECRYPTBYKEY(Ruta_Vuelo)) AS Ruta_Vuelo
FROM Avioneta
GO



CLOSE ALL SYMMETRIC KEYS
GO
REVERT 
GO


