
--DYNAMIC DATA MASKING (DDM)



USE Alquiler_Avionetas
GO


DROP TABLE IF EXISTS AlquileresMensuales
GO

CREATE TABLE AlquileresMensuales (
	Id_Alquiler int IDENTITY (1,1) NOT NULL PRIMARY KEY,
	Fecha_Alquiler DATETIME2 (7) NULL,
	Cliente VARCHAR (50) NULL,
	Email VARCHAR (200) NULL,
	Horas_vuelo VARCHAR (150) NULL,
	Precio_Total DECIMAL (10, 2) NULL
	)
GO


SET IDENTITY_INSERT AlquileresMensuales ON
INSERT INTO [AlquileresMensuales] ([Id_Alquiler], [Fecha_Alquiler], [Cliente],[Email], [Horas_vuelo], [Precio_Total]) VALUES (1, N'2019-05-01 00:00:00', N'Asif', N'Asif@companytest-0001.com', N'12', CAST(300.00 AS Decimal(10, 2)))
INSERT INTO [AlquileresMensuales] ([Id_Alquiler], [Fecha_Alquiler], [Cliente],[Email], [Horas_vuelo], [Precio_Total]) VALUES (2, N'2019-05-02 00:00:00', N'Mike',N'Mike@companytest-0002.com', N'5', CAST(300.00 AS Decimal(10, 2)))
INSERT INTO [AlquileresMensuales] ([Id_Alquiler], [Fecha_Alquiler], [Cliente],[Email], [Horas_vuelo], [Precio_Total]) VALUES (3, N'2019-05-02 00:00:00', N'Adil',N'Adil@companytest-0003.com',N'7', CAST(350.00 AS Decimal(10, 2)))
INSERT INTO [AlquileresMensuales] ([Id_Alquiler], [Fecha_Alquiler], [Cliente],[Email], [Horas_vuelo], [Precio_Total]) VALUES (4, N'2019-05-03 00:00:00', N'Sarah',N'Sarah@companytest-0004', N'14', CAST(250.00 AS Decimal(10, 2)))
INSERT INTO [AlquileresMensuales] ([Id_Alquiler], [Fecha_Alquiler], [Cliente],[Email], [Horas_vuelo], [Precio_Total]) VALUES (5, N'2019-05-05 00:00:00', N'Asif', N'Asif@companytest-0001.com', N'3', CAST(200.00 AS Decimal(10, 2)))
INSERT INTO [AlquileresMensuales] ([Id_Alquiler], [Fecha_Alquiler], [Cliente],[Email], [Horas_vuelo], [Precio_Total]) VALUES (6, N'2019-05-10 00:00:00', N'Sam',N'Sam@companytest-0005', N'9', CAST(300.00 AS Decimal(10, 2)))
INSERT INTO [AlquileresMensuales] ([Id_Alquiler], [Fecha_Alquiler], [Cliente],[Email], [Horas_vuelo], [Precio_Total]) VALUES (7, N'2019-05-12 00:00:00', N'Mike',N'Mike@companytest-0002.comcom', N'10', CAST(250.00 AS Decimal(10, 2)))
INSERT INTO [AlquileresMensuales] ([Id_Alquiler], [Fecha_Alquiler], [Cliente],[Email], [Horas_vuelo], [Precio_Total]) VALUES (8, N'2019-05-13 00:00:00', N'Mike',N'Mike@companytest-0002.comcom', N'4', CAST(250.00 AS Decimal(10, 2)))
INSERT INTO [AlquileresMensuales] ([Id_Alquiler], [Fecha_Alquiler], [Cliente],[Email], [Horas_vuelo], [Precio_Total]) VALUES (9, N'2019-05-20 00:00:00', N'Peter',N'Peter@companytest-0006', N'1', CAST(350.00 AS Decimal(10, 2)))
INSERT INTO [AlquileresMensuales] ([Id_Alquiler], [Fecha_Alquiler], [Cliente],[Email], [Horas_vuelo], [Precio_Total]) VALUES (10, N'2019-05-25 00:00:00', N'Peter',N'Peter@companytest-0006', N'5', CAST(400.00 AS Decimal(10, 2)))
SET IDENTITY_INSERT [AlquileresMensuales] OFF
GO

--End Populate

SELECT * FROM AlquileresMensuales
GO


--create DataUser to have select acces to MonthlySale table
--creamos un usuario y le damos permisos de select

DROP USER IF EXISTS VAA3
GO

CREATE USER VAA3 WITHOUT LOGIN;
GO

GRANT SELECT ON AlquileresMensuales TO VAA3;
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

ALTER TABLE AlquileresMensuales
	ALTER COLUMN Email VARCHAR(200) MASKED WITH (FUNCTION = 'default()');
GO

--vemos que aparece la columna Email con el dynamic data masking aplicado

EXEC VerMaskingStatus
GO


--nos cambiamos de usuario

EXECUTE AS USER = 'VAA3';
GO

--hacemos una select y vemos que no puede ver el email

SELECT * FROM AlquileresMensuales
GO


--volvemos a dbo

REVERT 
GO

PRINT USER 
GO

--el dbo si que puede ver el email

SELECT * FROM AlquileresMensuales
GO



---------------------------
--SEGUNDO TIPO

ALTER TABLE AlquileresMensuales
	ALTER COLUMN Cliente ADD MASKED WITH (FUNCTION = 'partial(1,"XXXXXXX",0)')
GO


EXEC VerMaskingStatus
GO


--cambiamos de usuario

EXECUTE AS USER = 'VAA3';
GO

--vemos que no puede ver el cliente(se ve solo la primera letra)

SELECT * FROM AlquileresMensuales
GO

--volvemos a dbo

REVERT
GO

PRINT USER
GO


-----------------------
--TERCER TIPO

ALTER TABLE AlquileresMensuales
	ALTER COLUMN Precio_Total DECIMAL (10,2) MASKED WITH (FUNCTION = 'random(1, 12)')
GO


EXEC VerMaskingStatus
GO

--cambiamos de usuario

EXECUTE AS USER = 'VAA3';
GO

--hacemos la select y vemos que escondió los precios cambiandolos por otros aleatorios

SELECT * FROM AlquileresMensuales
GO

--volvemos a dbo

REVERT
GO




----------------------------------
--CUARTO TIPO
--Custom string dynamic data masking

ALTER TABLE AlquileresMensuales
	ALTER COLUMN Horas_Vuelo ADD MASKED WITH (FUNCTION = 'partial(1,"---",1)')
GO

EXEC VerMaskingStatus
GO

--cambiamos de usuario

EXECUTE AS USER = 'VAA3';
GO


SELECT * FROM AlquileresMensuales
GO

--volvemos a dbo

REVERT
GO



------------------------------------

--concedemos permiso unmask al usuario

GRANT UNMASK TO VAA3
GO

--cambiamos de usuario

EXECUTE AS USER = 'VAA3';
GO

--comprobamos que ya lo puede ver
PRINT USER
GO
SELECT * FROM AlquileresMensuales
GO

--volvemos a dbo

REVERT
GO





--DROPPING A DYNAMIC DATA MASKING

--quitamos el enmascaramiento de la columna email

ALTER TABLE AlquileresMensuales
	ALTER COLUMN Email DROP MASKED;
GO

--comprobamos que se quitó con el procediento

EXEC VerMaskingStatus
GO




--quitamos el permiso al usuario

REVOKE UNMASK TO VAA3
GO

EXECUTE AS USER = 'VAA3';
GO

--vemos que ya puede ver el email pero no el resto de campos

SELECT * FROM AlquileresMensuales
GO

REVERT
GO