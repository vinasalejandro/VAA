
--Ejemplo encriptacion procedimiento almacenado

USE Alquiler_Avionetas
GO

CREATE OR ALTER PROCEDURE Personas_Vuelo
	WITH ENCRYPTION
AS
	select Alquiler from Alquileres
	where Num_Personas_Vuelo = 5
GO

EXECUTE Personas_Vuelo
GO

--sirve para encriptar tanto procedimientos almacenados como triggers como cualquier elemento

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--EJEMPLO CON FUNCIONES



USE Alquiler_Avionetas
GO

--creamos una tabla piloto 
--de tipo varbinary para que contenga información encriptada

CREATE TABLE Piloto
	(CodigoPiloto INT NOT NULL IDENTITY (1,1),
	Nombre VARCHAR (100) NOT NULL,
	DNI_Piloto VARBINARY(128))
GO

--insertamos un valor

INSERT INTO Piloto(Nombre, DNI_Piloto)
VALUES ('Juan', ENCRYPTBYPASSPHRASE ('EstaEsMiFraseSecreta','34821654J'))
GO

--intentamos hacer un select convencional
--vemos que aparece la tarjeta de credito cifrada

SELECT * FROM Piloto
GO

--intentamos hacer una select con una frase incorrecta

SELECT CodigoPiloto, Nombre, CONVERT (VARCHAR(50),
DECRYPTBYPASSPHRASE ('EstaNoEsMiFraseSecreta', DNI_Piloto)) AS DNI
FROM Piloto
GO

--vemos que sale NULL

--hacemos la select con la frase correcta

SELECT CodigoPiloto, Nombre, CONVERT (VARCHAR(50),
DECRYPTBYPASSPHRASE ('EstaEsMiFraseSecreta', DNI_Piloto)) AS DNI
FROM Piloto
GO



--vemos que desencripta correctamente


--EJEMPLO USANDO UN AUTENTICADOR

--insertamos un valor

DECLARE @v_usuario SYSNAME
	--SET @v_usuario = 'VAA'
SET @v_usuario = SYSTEM_USER
PRINT SYSTEM_USER
INSERT INTO Piloto (Nombre, DNI_Piloto)
VALUES ('Ramón', ENCRYPTBYPASSPHRASE('EstaEsMiFraseSecreta','47621587K',1,@v_usuario))
GO


--probamos a hacer una select convencional

SELECT * FROM Piloto
GO

--vemos que aparece la tarjeta encriptada

--hacemos una select con la frase correcta

DECLARE @v_Usuario SYSNAME
SET @v_usuario = SYSTEM_USER
SELECT CodigoPiloto, Nombre, CONVERT (VARCHAR(50),
DECRYPTBYPASSPHRASE ('EstaEsMiFraseSecreta', DNI_Piloto,1,@v_Usuario)) AS DNI
FROM Piloto
GO

--vemos que aparece desencriptada
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--ENCRIPTACION CON CLAVES

USE master
GO

CREATE LOGIN VAA2 WITH PASSWORD='abc123.'
GO


USE Alquiler_Avionetas
GO

CREATE USER VAA2 FOR LOGIN VAA2
GO

DROP TABLE IF EXISTS Cliente
GO

CREATE TABLE Cliente
	(Cliente_id INT PRIMARY KEY,
	Nombre VARCHAR(50) NOT NULL,
	Apellidos VARCHAR(50) NOT NULL,
	DNI VARBINARY(100) NOT NULL)
GO


GRANT SELECT, INSERT, UPDATE, DELETE ON Cliente
TO VAA2
GO

--creamos la clave simétrica

CREATE SYMMETRIC KEY DNI_AlquilerAvionetas_Key
AUTHORIZATION VAA2
WITH ALGORITHM=AES_256
ENCRYPTION BY PASSWORD='abc123.'
GO



EXECUTE AS USER ='VAA2'
GO

PRINT USER
GO

--abrimos la clave simétrica

OPEN SYMMETRIC KEY DNI_AlquilerAvionetas_Key
DECRYPTION BY PASSWORD='abc123.'
GO

INSERT INTO Cliente VALUES (1,'Juan','Alvarez',
ENCRYPTBYKEY(KEY_GUID('DNI_AlquilerAvionetas_Key'),'21683214L'))
INSERT INTO Cliente VALUES (2,'Alicia','Perez',
ENCRYPTBYKEY(KEY_GUID('DNI_AlquilerAvionetas_Key'),'71896245F'))
INSERT INTO Cliente VALUES (3,'Ana','Garcia',
ENCRYPTBYKEY(KEY_GUID('DNI_AlquilerAvionetas_Key'),'14568745U'))
GO

--vemos que aparece el DNI encriptado

SELECT * FROM Cliente
GO

--cerramos la clave simétrica

CLOSE ALL SYMMETRIC KEYS
GO



--vamos a desencriptar

OPEN SYMMETRIC KEY DNI_AlquilerAvionetas_Key
DECRYPTION BY PASSWORD='abc123.'
GO

--vemos que ya podemos ver el numero de seguridad social


SELECT Cliente_ID, Nombre + ' ', Apellidos AS Nombre_Clientes,
CONVERT (VARCHAR, DECRYPTBYKEY(DNI)) AS 'DNI'
FROM Cliente
GO

CLOSE ALL SYMMETRIC KEYS
GO

REVERT 
GO

PRINT USER
GO

