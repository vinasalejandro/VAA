
--Ejemplo encriptacion procedimiento almacenado

USE pubs
GO

CREATE OR ALTER PROCEDURE dbo.royalties
	@percentage int = 30
WITH ENCRYPTION	--sirve para encriptar tanto procedimientos almacenados como triggers como cualquier elemento
AS
	select au_id from titleauthor
	where titleauthor.royaltyper = @percentage
GO

EXECUTE royalties 
GO



-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--EJEMPLO CON FUNCIONES

USE master
GO

DROP DATABASE IF EXISTS SecureDB
GO

--Creamos la BD
CREATE DATABASE SecureDB
GO

USE SecureDB
GO

--creamos una tabla cliente con una columna TarjetaCredito
--de tipo varbinary para que contenga información encriptada

CREATE TABLE dbo.Cliente
	(CodigoCliente INT NOT NULL IDENTITY (1,1),
	Nombres VARCHAR (100) NOT NULL,
	TarjetaCredito VARBINARY(128))
GO

--insertamos un valor

INSERT INTO dbo.Cliente  (Nombres, TarjetaCredito)
VALUES ('Pepe', ENCRYPTBYPASSPHRASE ('EstaEsMiFraseSecreta','1111-1111-1111-1111'))
GO

--intentamos hacer un select convencional
--vemos que aparece la tarjeta de credito cifrada

SELECT * FROM Cliente
GO

--intentamos hacer una select con una frase incorrecta

SELECT CodigoCliente, Nombres, CONVERT (VARCHAR(50),
DECRYPTBYPASSPHRASE ('EstaNoEsMiFraseSecreta', TarjetaCredito)) AS TarjetaCredito
FROM dbo.Cliente
GO

--vemos que sale NULL

--hacemos la select con la frase correcta

SELECT CodigoCliente, Nombres, CONVERT (VARCHAR(50),
DECRYPTBYPASSPHRASE ('EstaEsMiFraseSecreta', TarjetaCredito)) AS TarjetaCredito
FROM dbo.Cliente
GO

--vemos que desencripta correctamente


--EJEMPLO USANDO UN AUTENTICADOR

--insertamos un valor

DECLARE @v_usuario SYSNAME
	--SET @v_usuario = 'VAA'
SET @v_usuario = SYSTEM_USER
PRINT SYSTEM_USER
INSERT INTO dbo.Cliente (Nombres, TarjetaCredito)
VALUES ('Ana', ENCRYPTBYPASSPHRASE('EstaEsMiFraseSecreta','2222-2222-2222-2222',1,@v_usuario))
GO


--probamos a hacer una select convencional

SELECT * FROM Cliente
GO

--vemos que aparece la tarjeta encriptada

--hacemos una select con la frase correcta

DECLARE @v_Usuario SYSNAME
SET @v_usuario = SYSTEM_USER
SELECT CodigoCliente, Nombres, CONVERT (VARCHAR(50),
DECRYPTBYPASSPHRASE ('EstaEsMiFraseSecreta', TarjetaCredito,1,@v_Usuario)) AS TarjetaCredito
FROM dbo.Cliente
GO

--vemos que aparece desencriptada




----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--

USE AdventureWorks2017
GO

DROP TABLE IF EXISTS Sales.TarjetaDeCredito
GO

SELECT * INTO Sales.TarjetaDeCredito
FROM Sales.CreditCard
GO

--Esto no es necesario

ALTER TABLE Sales.TarjetaDeCredito
	DROP COLUMN CardNumber_EncryptedbyPassphase
GO

--vemos que se duplico correctamente

SELECT * FROM Sales.TarjetaDeCredito
GO

--Encriptamos la columna de las tarjetas de credito

ALTER TABLE Sales.TarjetaDeCredito
	ADD CardNumber_EncryptedbyPassphase VARBINARY(256);
GO
SELECT * FROM Sales.TarjetaDeCredito
GO


--Creamos una frase para el usuario

DECLARE @PassphraseEnteredByUser NVARCHAR(128);
SET @PassphraseEnteredByUser = 'Fecha es febrero 2023 y yo soy VAA !';

UPDATE Sales.TarjetaDeCredito
SET CardNumber_EncryptedbyPassphase = ENCRYPTBYPASSPHRASE(@PassphraseEnteredByUser,CardNumber,1, CONVERT (VARBINARY, CreditCardID))
--WHERE CreditCardID = '1';
GO


--desencriptamos

SELECT CardNumber,CardNumber_EncryptedbyPassphase
	AS 'Encrypted card number', CONVERT (NVARCHAR, DECRYPTBYPASSPHRASE (@PassphraseEnteredByUser, CardNumber_EncryptedbyPassphase,1,


