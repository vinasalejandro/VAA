
--ENCRIPTACION CON CERTIFICADOS

--Encrypt with simple symmetric encryption



--creamos la master key 

CREATE master KEY encryption BY password = 'abc123.'
GO

--creamos el certificado

CREATE CERTIFICATE Matricula_Avioneta 
   WITH SUBJECT = 'Matriculas Avionetas';  
GO  

--creamos la clave simetrica

CREATE SYMMETRIC KEY Ma_Avioneta  
    WITH ALGORITHM = AES_256  
    ENCRYPTION BY CERTIFICATE Matricula_Avioneta;  
GO  




USE Alquiler_Avionetas;  
GO  

CREATE TABLE Avioneta
(
	id INT,
	Nombre_Piloto VARCHAR(25),
	Matricula_Avioneta VARBINARY(1000),
	Ruta_Vuelo VARBINARY(4000)
)
GO




OPEN SYMMETRIC KEY Ma_Avioneta  
   DECRYPTION BY CERTIFICATE Matricula_Avioneta ;  
go



INSERT INTO Avioneta
VALUES (1, 'Lucas', ENCRYPTBYKEY(Key_guid('Ma_Avioneta '), '111111'),
ENCRYPTBYKEY(Key_guid('Ma_Avioneta'), 'Madrid_Burgos'))
GO


SELECT * from Avioneta
GO


OPEN SYMMETRIC KEY Ma_Avioneta  
   DECRYPTION BY CERTIFICATE Matricula_Avioneta ;  
go

  
SELECT Ruta_Vuelo,   
    CONVERT(nvarchar, DecryptByKey(Ruta_Vuelo))   
    FROM Avioneta 
GO

--cerramos las key

CLOSE ALL SYMMETRIC KEYS
GO
