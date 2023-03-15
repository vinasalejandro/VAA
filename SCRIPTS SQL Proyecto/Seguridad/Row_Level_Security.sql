
----ROW LEVEL SECURITY----

DROP DATABASE IF EXISTS RLS_DEMO
GO

CREATE DATABASE RLS_DEMO
GO

USE RLS_DEMO
GO

--Creamos usuarios

CREATE USER Jane WITHOUT LOGIN
CREATE USER Dick WITHOUT LOGIN
CREATE USER Sally WITHOUT LOGIN
GO

--Creamos la tabla Customer

DROP TABLE IF EXISTS Customer
GO
 
 CREATE TABLE Customer(
	CustomerName VARCHAR(100) NULL,
	CustomerEmail VARCHAR(100) NULL,
	SalesPersonUserName VARCHAR(20) NULL
	);
GO

--Concedemos permisos de Select a los usuarios

GRANT SELECT ON dbo.Customer TO Jane;
GRANT SELECT ON dbo.Customer TO Dick;
GRANT SELECT ON dbo.Customer TO Sally;
GO

--Insertamos contenido

INSERT INTO Customer VALUES 
   ('ABC Company','Manager@ABC.COM','Jane'),
   ('Info Services','info@AInfaSerice.COM','Jane'),
   ('Washing-R-Us','HeadWasher@washrus.COM','Dick'),
   ('Blue Water Utilities','marketing@bluewater.COM','Dick'),
   ('Star Brite','steve@starbright.COM','Jane'),
   ('Rainy Day Fund','Tom@rainydayfund','Sally');
GO

PRINT USER
GO

select * from Customer
GO



--FUNCTION RLS IN-LINE TABLE

CREATE OR ALTER FUNCTION fn_RowLevelSecurity (@FilterColumnName sysname)
RETURNS TABLE
WITH SCHEMABINDING
AS
	RETURN SELECT 1 AS fn_SecureCustomerData
	--filter our records based in database user name
	WHERE @FilterColumnName = user_name() --OR user_name()= 'dbo'; --muestra solo los datos del usuario activo (si añadimos a dbo el dbo tambien podria ver los datos)
GO



--SECURITY POLICY FILTER PREDICATE. NOT ALLOW READ

--comprobamos que el dbo puede ver los datos de la tabla

select * from Customer
GO


--para borrar la politica de seguridad
--drop security policy filterCustomer
--go


--activamos la politica de seguridad

CREATE SECURITY POLICY FilterCustomer
ADD FILTER PREDICATE dbo.fn_RowLevelSecurity(SalesPersonUserName)
ON dbo.Customer
WITH (STATE = ON);
GO

--comprobamos que al crear la politica de seguridad el dbo ya no puede ver los datos (es necesaria la funcion creada anteriormente)

PRINT USER
GO

select * from Customer
GO


--concedemos permisos de grant a los usuarios para demostrar que despues los podemos bloquear

GRANT UPDATE, INSERT ON dbo.Customer TO Jane;
GRANT UPDATE, INSERT ON dbo.Customer TO Dick;
GRANT UPDATE, INSERT ON dbo.Customer TO Sally;
GO

--cambiamos de usuario

EXECUTE AS USER = 'Dick';
GO

--comprobamos que dick puede ver sus datos y no los de los demas

SELECT * FROM Customer
GO

--comprobamos lo mismo con los otros usuarios y vemos que solo pueden ver sus datos

REVERT
GO

EXECUTE AS USER = 'Jane';
GO

SELECT * FROM Customer
GO

REVERT
GO

EXECUTE AS USER = 'Sally';
GO

SELECT * FROM Customer
GO

REVERT
GO


------------------------------------------------------------

--Comprobamos que jane puede modificar los datos de Dick

EXECUTE AS USER = 'Jane'
GO

PRINT USER
GO

--esta funciona (le pasamos a dick un registro de jane)
UPDATE Customer
SET CustomerEmail = 'Jack@ABC.com',
	SalesPersonUserName = 'Dick'
WHERE CustomerName = 'ABC Company';
GO

--por lo tanto al pasarselo a dick siendo jane no lo veremos
SELECT * FROM Customer
GO


--Probamos a hacer un insert con jane en nombre de sally

INSERT INTO Customer VALUES
	('Rock the Dock','Rocky@RockTheDock.com','Sally');
GO

--Siendo Jane no se puede ver con la select ya que no es Sally pero si que puede insertar

SELECT * FROM Customer
GO

REVERT
GO

--comprobamos con Sally que se insertaron los datos anteriores

EXECUTE AS USER = 'Sally'
GO

SELECT * FROM Customer
GO

REVERT
GO


-----------------------------------------------------------------------------------
--Para corregir el problema anterior haremos lo siguiente (evitar que los usuario puedan insertar datos en nombre de otro)


ALTER SECURITY POLICY FilterCustomer
ADD BLOCK PREDICATE dbo.fn_RowLevelSecurity(SalesPersonUserName)
ON dbo.Customer AFTER UPDATE,
ADD BLOCK PREDICATE dbo.fn_RowLevelSecurity(SalesPersonUserName)
ON dbo.Customer AFTER INSERT;
GO

--comprobamos que Jane no puede hacer update (no da error pero pone 0 filas afectadas)

EXECUTE AS USER = 'Jane'
GO

UPDATE Customer
SET CustomerEmail = 'bloquear@ABC.com',
	SalesPersonUserName = 'Dick'
WHERE CustomerName = 'ABC Company';
GO

--comprobamos que Jane tampoco puede insertar datos(nos dice que hay un bloqueo de predicado)

INSERT INTO Customer VALUES
	('Rock the Dock','Rocky@RockTheDock.com','Sally');
GO

REVERT
GO

-------------------------------------------------------------------------------------------
--borrado de datos
--Nos cambiamos a dick y intentamos borrar, vemos que no puede ya que no tiene permiso de delete

EXECUTE AS USER = 'Dick'
GO

DELETE FROM Customer WHERE CustomerName = 'ABC Company'
GO

--concedemos permisos de borrado a los usuarios

REVERT
GO

GRANT DELETE ON dbo.Customer TO Jane;
GRANT DELETE ON dbo.Customer TO Dick;
GRANT DELETE ON dbo.Customer TO Sally;
GO

--cambiamos a dick otra vez

EXECUTE AS USER = 'Dick'
GO

--comprobamos que si que puede borrar los datos de otros

DELETE FROM Customer WHERE CustomerName = 'ABC Company'
GO

REVERT
GO

--Para corregir que no se puedan borrar datos de otros añadimos una nueva politica

--AÑADO POLITICA PARA PREVENIR BORRADO

ALTER SECURITY POLICY FilterCustomer
ADD BLOCK PREDICATE dbo.fn_RowLevelSecurity(SalesPersonUserName)
ON dbo.Customer BEFORE DELETE
GO

--Nos cambiamos a dick y comprobamos que ya no puede borrar los datos de otro(teoricamente si podria borrar sus datos)

EXECUTE AS USER = 'Dick'
GO

DELETE FROM Customer WHERE CustomerName = 'Star Brite'
GO



--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
