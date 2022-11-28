
--Guardar imagenes en una bd
--Tipo de campo VARBINARY(MAX) .IMAGE DEPRECATED

USE pubs
GO

DROP TABLE IF EXISTS Logo
GO

CREATE TABLE Logo
(
	LogoId INT,
	LogoName VARCHAR(255),
	LogoImage VARBINARY(MAX)
)
GO

INSERT INTO dbo.Logo
(
	LogoId,
	LogoName,
	LogoImage
)
SELECT 1, 'Arbusto',
	* FROM OPENROWSET
	(BULK 'C:\IMAGENES\arbusto.jpg', SINGLE_BLOB) AS ImageFile
GO

INSERT INTO dbo.Logo
(
	LogoId,
	LogoName,
	LogoImage
)
SELECT 2, 'Fruta',
	* FROM OPENROWSET
	(BULK 'C:\IMAGENES\Fruta.jpg', SINGLE_BLOB) AS ImageFile
GO

INSERT INTO dbo.Logo
(
	LogoId,
	LogoName,
	LogoImage
)
SELECT 3, 'Flor',
	* FROM OPENROWSET
	(BULK 'C:\IMAGENES\Flor.jpg', SINGLE_BLOB) AS ImageFile
GO



SELECT * FROM dbo.Logo
GO

