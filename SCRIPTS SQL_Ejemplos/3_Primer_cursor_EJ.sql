
--INCLUDE ACTUAL EXECUTION PLAN

USE AdventureWorks2019
GO

DECLARE Employee_Cursor CURSOR FOR 
	SELECT BusinessEntityID, JobTitle
	FROM AdventureWorks2019.HumanResources.Employee;
OPEN Employee_Cursor;
FETCH NEXT FROM Employee_Cursor;
WHILE @@FETCH_STATUS = 0
	BEGIN
		FETCH NEXT FROM Employee_Cursor
	END;
CLOSE Employee_Cursor;
DEALLOCATE Employee_Cursor;

GO


--Procedimiento almacenado de lo anterior

CREATE OR ALTER PROC Employee_Cursor
AS
	DECLARE Employee_Cursor CURSOR FOR 
		SELECT BusinessEntityID, JobTitle
		FROM AdventureWorks2019.HumanResources.Employee;
	OPEN Employee_Cursor;
	FETCH NEXT FROM Employee_Cursor;
	WHILE @@FETCH_STATUS = 0
		BEGIN
			FETCH NEXT FROM Employee_Cursor
		END;
	CLOSE Employee_Cursor;
	DEALLOCATE Employee_Cursor;
GO

EXEC Employee_Cursor
GO


