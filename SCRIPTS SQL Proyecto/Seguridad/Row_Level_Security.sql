
----ROW LEVEL SECURITY----

USE Alquiler_Avionetas2
GO

--Creamos usuarios

CREATE USER Lucas WITHOUT LOGIN
CREATE USER Pablo WITHOUT LOGIN
CREATE USER Lucia WITHOUT LOGIN
GO

--Creamos la tabla Clientes

DROP TABLE IF EXISTS Clientes
GO
 CREATE TABLE Clientes(
	Nombre VARCHAR(100) NULL,
	Email VARCHAR(100) NULL,
	Nombre_Piloto VARCHAR(20) NULL
	);
GO

--Concedemos permisos de Select a los usuarios

GRANT SELECT ON Clientes TO Lucas;
GRANT SELECT ON Clientes TO Pablo;
GRANT SELECT ON Clientes TO Lucia;
GO

--Insertamos contenido

INSERT INTO Clientes VALUES 
   ('Maria','Manager@ABC.COM','Lucas'),
   ('Lidia','info@AInfaSerice.COM','Lucas'),
   ('Jesus','HeadWasher@washrus.COM','Pablo'),
   ('Juan','marketing@bluewater.COM','Pablo'),
   ('Ana','steve@starbright.COM','Lucas'),
   ('Pedro','Tom@rainydayfund','Lucia');
GO

PRINT USER
GO

select * from Clientes
GO



--FUNCTION RLS IN-LINE TABLE

CREATE OR ALTER FUNCTION Funcion_RowLevelSecurity (@FilterColumnName sysname)
RETURNS TABLE
WITH SCHEMABINDING
AS
	RETURN SELECT 1 AS Funcion_SeguridadClientesData
	--filter our records based in database user name
	WHERE @FilterColumnName = user_name() --OR user_name()= 'dbo'; --muestra solo los datos del usuario activo (si añadimos a dbo el dbo tambien podria ver los datos)
GO



--SECURITY POLICY FILTER PREDICATE. NOT ALLOW READ

--comprobamos que el dbo puede ver los datos de la tabla

select * from Clientes
GO


--para borrar la politica de seguridad
--drop security policy filterCustomer
--go


--activamos la politica de seguridad

CREATE SECURITY POLICY FilterClientes
ADD FILTER PREDICATE dbo.Funcion_RowLevelSecurity(Nombre_Piloto)
ON dbo.Clientes
WITH (STATE = ON);
GO

--comprobamos que al crear la politica de seguridad el dbo ya no puede ver los datos (es necesaria la funcion creada anteriormente)

PRINT USER
GO

select * from Clientes
GO


--concedemos permisos de grant a los usuarios para demostrar que despues los podemos bloquear

GRANT UPDATE, INSERT ON Clientes TO Lucas;
GRANT UPDATE, INSERT ON Clientes TO Pablo;
GRANT UPDATE, INSERT ON Clientes TO Lucia;
GO

--cambiamos de usuario

EXECUTE AS USER = 'Pablo';
GO

--comprobamos que pablo puede ver sus datos y no los de los demas

SELECT * FROM Clientes
GO

--comprobamos lo mismo con los otros usuarios y vemos que solo pueden ver sus datos

REVERT
GO

EXECUTE AS USER = 'Lucas';
GO

SELECT * FROM Clientes
GO

REVERT
GO

EXECUTE AS USER = 'Lucia';
GO

SELECT * FROM Clientes
GO

REVERT
GO


------------------------------------------------------------

--Comprobamos que Lucas puede modificar los datos de Pablo

EXECUTE AS USER = 'Lucas'
GO

PRINT USER
GO




--esta funciona (le pasamos a Pablo un registro de Lucas)
UPDATE Clientes
SET Email = 'Jack@ABC.com',
	Nombre_Piloto = 'Pablo'
WHERE Nombre = 'Maria';
GO

--por lo tanto al pasarselo a Pablo siendo Lucas no lo veremos
SELECT * FROM Clientes
GO


--Probamos a hacer un insert con Lucas en nombre de Lucia

INSERT INTO Clientes VALUES
	('Eugenio','Rocky@RockTheDock.com','Lucia');
GO

--Siendo Lucas no se puede ver con la select ya que no es Lucia pero si que puede insertar

SELECT * FROM Clientes
GO

REVERT
GO

--comprobamos con Lucia que se insertaron los datos anteriores

EXECUTE AS USER = 'Lucia'
GO

SELECT * FROM Clientes
GO

REVERT
GO


-----------------------------------------------------------------------------------
--Para corregir el problema anterior haremos lo siguiente (evitar que los usuario puedan insertar datos en nombre de otro)


ALTER SECURITY POLICY FilterClientes
ADD BLOCK PREDICATE dbo.Funcion_RowLevelSecurity(Nombre_Piloto)
ON dbo.Clientes AFTER UPDATE,
ADD BLOCK PREDICATE dbo.Funcion_RowLevelSecurity(Nombre_Piloto)
ON dbo.Clientes AFTER INSERT;
GO

--comprobamos que Lucas no puede hacer update (no da error pero pone 0 filas afectadas)

EXECUTE AS USER = 'Lucas'
GO

PRINT USER
GO

UPDATE Clientes
SET Email = 'Jack@DEF.com',
	Nombre_Piloto = 'Pablo'
WHERE Nombre = 'Maria';
GO

--comprobamos que Lucas tampoco puede insertar datos(nos dice que hay un bloqueo de predicado)

INSERT INTO Clientes VALUES
	('Paco','Rocky@RockTheDock.com','Lucia');
GO

REVERT
GO

-------------------------------------------------------------------------------------------
--borrado de datos
--Nos cambiamos a Pablo y intentamos borrar, vemos que no puede ya que no tiene permiso de delete

EXECUTE AS USER = 'Pablo'
GO

DELETE FROM Clientes WHERE Nombre = 'Maria'
GO

--concedemos permisos de borrado a los usuarios

REVERT
GO

GRANT DELETE ON dbo.Clientes TO Lucas;
GRANT DELETE ON dbo.Clientes TO Pablo;
GRANT DELETE ON dbo.Clientes TO Lucia;
GO

--cambiamos a Pablo otra vez

EXECUTE AS USER = 'Pablo'
GO

--comprobamos que si que puede borrar los datos de otros

DELETE FROM Clientes WHERE Nombre = 'Maria'
GO

REVERT
GO

--Para corregir que no se puedan borrar datos de otros añadimos una nueva politica

--AÑADO POLITICA PARA PREVENIR BORRADO

ALTER SECURITY POLICY FilterClientes
ADD BLOCK PREDICATE dbo.Funcion_RowLevelSecurity(Nombre_Piloto)
ON dbo.Clientes BEFORE DELETE
GO

--Nos cambiamos a Pablo y comprobamos que ya no puede borrar los datos de otro(teoricamente si podria borrar sus datos)

EXECUTE AS USER = 'Pablo'
GO

PRINT USER
GO

DELETE FROM Clientes WHERE Nombre = 'Pedro'
GO



--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
