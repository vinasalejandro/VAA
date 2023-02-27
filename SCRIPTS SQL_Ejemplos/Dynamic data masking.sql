
--DYNAMIC DATA MASKING (DDM)


DROP DATABASE IF EXISTS ITSalesV2
GO

CREATE DATABASE ITSalesV2
GO

USE ITsalesV2
GO


DROP TABLE IF EXISTS MonthlySale
GO

CREATE TABLE dbo.MonthlySale (
	SaleId int IDENTITY (1,1) NOT NULL PRIMARY KEY,
	SellingDate DATETIME2 (7) NULL,
	Customer VARCHAR (50) NULL,
	Email VARCHAR (200) NULL,
	Product VARCHAR (150) NULL,
	TotalPrice DECIMAL (10, 2) NULL
	)
GO


SET IDENTITY_INSERT [dbo].[MonthlySale] ON
INSERT INTO [dbo].[MonthlySale] ([SaleId], [SellingDate], [Customer],[Email], [Product], [TotalPrice]) VALUES (1, N'2019-05-01 00:00:00', N'Asif', N'Asif@companytest-0001.com', N'Dell Laptop', CAST(300.00 AS Decimal(10, 2)))
INSERT INTO [dbo].[MonthlySale] ([SaleId], [SellingDate], [Customer],[Email], [Product], [TotalPrice]) VALUES (2, N'2019-05-02 00:00:00', N'Mike',N'Mike@companytest-0002.com', N'Dell Laptop', CAST(300.00 AS Decimal(10, 2)))
INSERT INTO [dbo].[MonthlySale] ([SaleId], [SellingDate], [Customer],[Email], [Product], [TotalPrice]) VALUES (3, N'2019-05-02 00:00:00', N'Adil',N'Adil@companytest-0003.com',N'Lenovo Laptop', CAST(350.00 AS Decimal(10, 2)))
INSERT INTO [dbo].[MonthlySale] ([SaleId], [SellingDate], [Customer],[Email], [Product], [TotalPrice]) VALUES (4, N'2019-05-03 00:00:00', N'Sarah',N'Sarah@companytest-0004', N'HP Laptop', CAST(250.00 AS Decimal(10, 2)))
INSERT INTO [dbo].[MonthlySale] ([SaleId], [SellingDate], [Customer],[Email], [Product], [TotalPrice]) VALUES (5, N'2019-05-05 00:00:00', N'Asif', N'Asif@companytest-0001.com', N'Dell Desktop', CAST(200.00 AS Decimal(10, 2)))
INSERT INTO [dbo].[MonthlySale] ([SaleId], [SellingDate], [Customer],[Email], [Product], [TotalPrice]) VALUES (6, N'2019-05-10 00:00:00', N'Sam',N'Sam@companytest-0005', N'HP Desktop', CAST(300.00 AS Decimal(10, 2)))
INSERT INTO [dbo].[MonthlySale] ([SaleId], [SellingDate], [Customer],[Email], [Product], [TotalPrice]) VALUES (7, N'2019-05-12 00:00:00', N'Mike',N'Mike@companytest-0002.comcom', N'iPad', CAST(250.00 AS Decimal(10, 2)))
INSERT INTO [dbo].[MonthlySale] ([SaleId], [SellingDate], [Customer],[Email], [Product], [TotalPrice]) VALUES (8, N'2019-05-13 00:00:00', N'Mike',N'Mike@companytest-0002.comcom', N'iPad', CAST(250.00 AS Decimal(10, 2)))
INSERT INTO [dbo].[MonthlySale] ([SaleId], [SellingDate], [Customer],[Email], [Product], [TotalPrice]) VALUES (9, N'2019-05-20 00:00:00', N'Peter',N'Peter@companytest-0006', N'Dell Laptop', CAST(350.00 AS Decimal(10, 2)))
INSERT INTO [dbo].[MonthlySale] ([SaleId], [SellingDate], [Customer],[Email], [Product], [TotalPrice]) VALUES (10, N'2019-05-25 00:00:00', N'Peter',N'Peter@companytest-0006', N'Asus Laptop', CAST(400.00 AS Decimal(10, 2)))
SET IDENTITY_INSERT [dbo].[MonthlySale] OFF
GO

--End Populate

SELECT * FROM MonthlySale
GO

--view monthly sales data (usando alias s)

SELECT s.SaleId, s.SellingDate, s.Customer, s.Email, s.Product, s.TotalPrice
FROM MonthlySale s
GO

--create DataUser to have select acces to MonthlySale table
--creamos un usuario y le damos permisos de select

DROP USER IF EXISTS DataUser
GO

CREATE USER DataUser WITHOUT LOGIN;
GO

GRANT SELECT ON MonthlySale TO DataUser;
GO


--creamos un procedimiento almacenado para ver el estado de DDM

CREATE OR ALTER PROC VerMaskingStatus
AS
BEGIN
	SET NOCOUNT ON
	SELECT c.Name, tbl.name as table_name, c.is_masked, c.masking_function
	FROM sys.masked_columns AS c
	JOIN sys.tables AS tbl
		ON c.object_id = tbl.object_id
	WHERE is_masked = 1;
END
GO


--ejecutamos el procedimiento (no aparece nada ya que no se uso en ninguna columna el dynamic data masking)

EXEC VerMaskingStatus
GO


--vamos a implementar los 4 tipos de dynamic data masking

--PRIMER TIPO

ALTER TABLE MonthlySale
	ALTER COLUMN Email VARCHAR(200) MASKED WITH (FUNCTION = 'default()');
GO

--vemos que aparece la columna Email con el dynamic data masking aplicado

EXEC VerMaskingStatus
GO


--nos cambiamos de usuario

EXECUTE AS USER = 'DataUser';
GO

--hacemos una select y vemos que no puede ver el email

SELECT s.SaleId, s.SellingDate, s.Customer, s.Email, s.Product, s.TotalPrice
FROM MonthlySale s
GO

--volvemos a dbo

REVERT 
GO

PRINT USER 
GO

--el dbo si que puede ver el email

SELECT s.SaleId, s.SellingDate, s.Customer, s.Email, s.Product, s.TotalPrice
FROM MonthlySale s
GO



---------------------------
--SEGUNDO TIPO

ALTER TABLE MonthlySale
	ALTER COLUMN Customer ADD MASKED WITH (FUNCTION = 'partial(1,"XXXXXXX",0)')
GO


EXEC VerMaskingStatus
GO


--cambiamos de usuario

EXECUTE AS USER = 'DataUser';
GO

--vemos que no puede ver el cliente(se ve solo la primera letra)

SELECT s.SaleId, s.SellingDate, s.Customer, s.Email, s.Product, s.TotalPrice
FROM MonthlySale s
GO

--volvemos a dbo

REVERT
GO

PRINT USER
GO


-----------------------
--TERCER TIPO

ALTER TABLE MonthlySale
	ALTER COLUMN TotalPrice DECIMAL (10,2) MASKED WITH (FUNCTION = 'random(1, 12)')
GO


EXEC VerMaskingStatus
GO

--cambiamos de usuario

EXECUTE AS USER = 'DataUser';
GO

--hacemos la select y vemos que escondió los precios cambiandolos por otros aleatorios

SELECT s.SaleId, s.SellingDate, s.Customer, s.Email, s.Product, s.TotalPrice
FROM MonthlySale s
GO

--volvemos a dbo

REVERT
GO




----------------------------------
--CUARTO TIPO
--Custom string dynamic data masking

ALTER TABLE MonthlySale
	ALTER COLUMN Product ADD MASKED WITH (FUNCTION = 'partial(1,"---",1)')
GO

EXEC VerMaskingStatus
GO

--cambiamos de usuario

EXECUTE AS USER = 'DataUser';
GO


SELECT s.SaleId, s.SellingDate, s.Customer, s.Email, s.Product, s.TotalPrice
FROM MonthlySale s
GO

--volvemos a dbo

REVERT
GO



------------------------------------

--concedemos permiso unmask al usuario

GRANT UNMASK TO DataUser
GO

--cambiamos de usuario

EXECUTE AS USER = 'DataUser';
GO

--comprobamos que ya lo puede ver

SELECT s.SaleId, s.SellingDate, s.Customer, s.Email, s.Product, s.TotalPrice
FROM MonthlySale s
GO

--volvemos a dbo

REVERT
GO





--DROPPING A DYNAMIC DATA MASKING

--quitamos el enmascaramiento de la columna email

ALTER TABLE MonthlySale
	ALTER COLUMN Email DROP MASKED;
GO

--comprobamos que se quitó con el procediento

EXEC VerMaskingStatus
GO




--quitamos el permiso al usuario

REVOKE UNMASK TO DataUser
GO

EXECUTE AS USER = 'DataUser';
GO

--vemos que ya puede ver el email pero no el resto de campos

SELECT s.SaleId, s.SellingDate, s.Customer, s.Email, s.Product, s.TotalPrice
FROM MonthlySale s
GO

REVERT
GO