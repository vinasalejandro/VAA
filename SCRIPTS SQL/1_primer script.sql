
DROP DATABASE IF EXISTS TestDB
GO

CREATE DATABASE TestDB
GO

USE TestDB
GO

DROP SCHEMA IF EXISTS HR
GO
CREATE SCHEMA HR;
GO

DROP TABLE IF EXISTS HR.Employee
GO
CREATE TABLE HR.Employee
(
	EmployeeID CHAR(2),
	GivenName VARCHAR(50),
	Surname VARCHAR(50),
	SSN CHAR(9) --no queremos que los becarios vean esto
);
GO


--AÑADOR DATOS EN FICHERO TXT
--EmployeeID,GivenName,Surname,SSN
--1,Luis,Arias,111
--2,Ana,Gomez,222
--3,Juan,Perez,333


SELECT * FROM HR.Employee
GO

DROP VIEW IF EXISTS HR.LookupEmployee
GO
CREATE VIEW HR.LookupEmployee
AS
	SELECT EmployeeID, GivenName, Surname
	FROM HR.Employee;
GO

DROP ROLE IF EXISTS HumanResourcesAnalyst
GO
CREATE ROLE HumanResourcesAnalyst;
GO

GRANT SELECT ON HR.LookupEmployee TO HumanResourcesAnalyst;
GO

DROP USER IF EXISTS JaneDoe
GO

CREATE USER JaneDoe WITHOUT LOGIN;
GO

ALTER ROLE HumanResourcesAnalyst
ADD MEMBER JaneDoe;
GO


--cambiamos al usuario JaneDoe

EXEC AS USER = 'JaneDoe';
GO

PRINT USER 
GO

--comprobamos que puede consultar ya que el usuario está en el rol y tiene permisos sobre la vista

SELECT * FROM HR.LookupEmployee;
GO


--comprobamos que no puede consultar la tabla ya que no tiene permisos

SELECT * FROM HR.Employee;
GO

--cambiamos al usuario del sistema de nuevo

REVERT
GO

PRINT USER
GO



--STORED PROCEDURE

CREATE OR ALTER PROC HR.InsertEmployee
	--parametros de entrada
	@EmployeeID INT,
	@GivenName VARCHAR(50),
	@Surname VARCHAR(50),
	@SSN CHAR(9)
AS
BEGIN
	INSERT INTO HR.Employee
	( EmployeeID, GivenName, Surname, SSN )
	VALUES
	( @EmployeeID, @GivenName, @Surname, @SSN );
END;

GO



EXEC HR.InsertEmployee 1, Luis, Perez, 1111
GO

SELECT * FROM HR.Employee
GO


--creamos un nuevo role
CREATE ROLE HumanResourcesRecruiter;
GO

--concedemos permiso de ejecución en el esquema HR al role
GRANT EXECUTE ON SCHEMA::[HR] TO HumanResourcesRecruiter;
GO

CREATE USER JohnSmith WITHOUT LOGIN;
GO

--añadimos el nuevo usuario al role
ALTER ROLE HumanResourcesRecruiter
	ADD MEMBER JohnSmith
GO

EXEC AS USER = 'JohnSmith'
GO

PRINT USER
GO

EXEC HR.InsertEmployee 10, Juan, Alvarez, 4444
GO

REVERT 
GO

