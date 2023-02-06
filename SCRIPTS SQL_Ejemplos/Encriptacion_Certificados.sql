
--ENCRIPTACION CON CERTIFICADOS

--Encrypt with simple symmetric encryption



--creamos la master key 

CREATE master KEY encryption BY password = 'Abcd1234.'
GO

--creamos el certificado

CREATE CERTIFICATE HumanResources037  
   WITH SUBJECT = 'Employee Social Security Numbers';  
GO  

--creamos la clave simetrica

CREATE SYMMETRIC KEY SSN_Key_01  
    WITH ALGORITHM = AES_256  
    ENCRYPTION BY CERTIFICATE HumanResources037;  
GO  

USE [AdventureWorks2017];  
GO  

-- Create a column in which to store the encrypted data.  
ALTER TABLE HumanResources.Employee  
    ADD EncryptedNationalIDNumber varbinary(128);   
GO  

-- Open the symmetric key with which to encrypt the data.  
OPEN SYMMETRIC KEY SSN_Key_01  
   DECRYPTION BY CERTIFICATE HumanResources037;  
go
-- Encrypt the value in column NationalIDNumber with symmetric   
-- key SSN_Key_01. Save the result in column EncryptedNationalIDNumber.  
UPDATE HumanResources.Employee  
SET EncryptedNationalIDNumber = EncryptByKey(Key_GUID('SSN_Key_01'), NationalIDNumber);  
GO  

-- Verify the encryption.  
-- First, open the symmetric key with which to decrypt the data.  
OPEN SYMMETRIC KEY SSN_Key_01  
   DECRYPTION BY CERTIFICATE HumanResources037;  
GO  

-- Now list the original ID, the encrypted ID, and the   
-- decrypted ciphertext. If the decryption worked, the original  
-- and the decrypted ID will match.  
SELECT NationalIDNumber, EncryptedNationalIDNumber   
    AS 'Encrypted ID Number',  
    CONVERT(nvarchar, DecryptByKey(EncryptedNationalIDNumber))   
    AS 'Decrypted ID Number'  
    FROM HumanResources.Employee;  
GO

--cerramos las key

CLOSE ALL SYMMETRIC KEYS
GO








---------------------------------------------------------------------------------------------------------------------------------------------
-- Example: Encrypt with symmetric encryption and authenticator

-- Encryption Card Number


-- Puede que ya tengamos una master key
-- Para cifrar una columna de datos usando un cifrado simétrico simple
-- Create the Master Key

CREATE master KEY encryption BY password = 'Abcd1234.'
GO
--
--Msg 15578, Level 16, State 1, Line 13
--There is already a master key in the database. Please drop it before performing this statement.
--

--vemos las master key creadas

SELECT name KeyName,
  symmetric_key_id KeyID,
  key_length KeyLength,
  algorithm_desc KeyAlgorithm
FROM sys.symmetric_keys;
GO


USE Adventureworks2017
GO
DROP TABLE IF EXISTS Sales.TarjetadeCredito
GO
SELECT * FROM  [Sales].[CreditCard]
GO
SELECT * 
	INTO Sales.TarjetadeCredito
	FROM [Sales].[CreditCard]
GO
-- (19118 rows affected)


--If there is no master key, create one now. 
IF NOT EXISTS 
    (SELECT * FROM sys.symmetric_keys WHERE symmetric_key_id = 101)
    CREATE MASTER KEY ENCRYPTION BY 
    PASSWORD = 'Abcd1234.'
GO

CREATE CERTIFICATE Cert_Xan_2018
   WITH SUBJECT = 'Customer Credit Card Numbers';
GO

CREATE SYMMETRIC KEY SK_CreditCards_Xan_2018
    WITH ALGORITHM = AES_256
    ENCRYPTION BY CERTIFICATE Cert_Xan_2018;
GO

-- Create a column in which to store the encrypted data.
ALTER TABLE Sales.TarjetadeCredito
    ADD CardNumber_Encrypted varbinary(128); 
GO


SELECT TOP 10 CardNumber, CardNumber_Encrypted 
	FROM Sales.TarjetadeCredito
GO

-- Open the symmetric key with which to encrypt the data.


OPEN SYMMETRIC KEY SK_CreditCards_Xan_2018
   DECRYPTION BY CERTIFICATE Cert_Xan_2018;
GO

-- Encrypt the value in column CardNumber using the
-- symmetric key CreditCards_Key11.
-- Save the result in column CardNumber_Encrypted.  



UPDATE Sales.TarjetadeCredito
SET CardNumber_Encrypted = EncryptByKey(Key_GUID('SK_CreditCards_Xan_2018')  
    , CardNumber, 1, HASHBYTES('SHA2_256', CONVERT( varbinary  
    , CreditCardID)));  
GO  


SELECT TOP 10 CardNumber, CardNumber_Encrypted 
FROM Sales.TarjetadeCredito
GO


SELECT TOP 10 *  FROM Sales.TarjetadeCredito
GO




-- Verify the encryption.
-- First, open the symmetric key with which to decrypt the data.

OPEN SYMMETRIC KEY SK_CreditCards_Xan_2018
   DECRYPTION BY CERTIFICATE Cert_Xan_2018
GO

-- Now list the original card number, the encrypted card number,
-- and the decrypted ciphertext. If the decryption worked,
-- the original number will match the decrypted number.

SELECT TOP 3 CardNumber, CardNumber_Encrypted 
    AS 'Encrypted card number', CONVERT(nvarchar,  
	DecryptByKey(CardNumber_Encrypted, 1 , 
    HashBytes('SHA2_256', CONVERT(varbinary, CreditCardID))))
    AS 'Decrypted card number' FROM Sales.TarjetadeCredito
GO

--CardNumber	   Encrypted card number																											Decrypted card number
--33332664695310	0x00C00F283656D646AA88A83F8ED73AAB01000000AE7090F32DE7B8A6E660C5ABA25132AD78B38B3368C4B2E7AD7AEB21C02BE3C472CB35F0A533C459518471BAA2F3FD96DFC510A32FC4FB76619ABD3F1F6BAE951315A75390CAF37F1B4B68AAFDCCCE4C	33332664695310
--55552127249722	0x00C00F283656D646AA88A83F8ED73AAB01000000DDDB21C8E836EDAFDA4607085876C2901A3025C9AE76C851DA3425D78F9B495941DBB725A70922818CD7403B7DE90C717EB6DD6B974BC51EC8DCD061995DADA4361D1FF5DBDB0EC84B97C788828C0752	55552127249722
--77778344838353	0x00C00F283656D646AA88A83F8ED73AAB01000000F561C4B01DBD43EC62D98B7C8CA66F6C77A1F5A73185DDF60B8B5040DA601F01884ABD3DA5037745391D78A09AAE7F250DF5E393886C3FE854DAD5E85F7CFBE92FF566FF10EFA0B53DCABF0154D8602A	77778344838353


CLOSE ALL SYMMETRIC KEYS
GO

---------------------------------------------