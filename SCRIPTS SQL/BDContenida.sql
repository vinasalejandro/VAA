
USE master
GO

EXEC sp_configure
GO

--A uno se activan opciones avanzadas

EXEC sp_configure 'show advanced options', 1
GO

--actualizamos el valor

RECONFIGURE
GO


--ACTIVAMOS CARACTERÍSTICA

EXEC sp_configure 'contained database authentication', 1
GO

--actualizamos de nuevo

RECONFIGURE
GO

------------------------------------------------------------------------------------------------

--Hasta aqui preparamos el entorno para lo que vamos a ejecutar

DROP DATABASE IF EXISTS Contenida
GO

CREATE DATABASE Contenida
CONTAINMENT=PARTIAL
GO

--una vez creada la activamos

USE Contenida
GO

--Creo el usuario VAA, asocio esquena dbo
DROP USER IF EXISTS vaa
GO

CREATE USER vaa 
	WITH PASSWORD='Abc123.',
	DEFAULT_SCHEMA=dbo
GO


--añadimos el usuario vaa el rol db_owner

ALTER ROLE db_owner
ADD MEMBER vaa
GO

--Intento conectarme con vaa desde el GUI 
--DA ERROR

--Damos permiso de conexión a vaa

GRANT CONNECT TO vaa
GO

--intento conectarme de nuevo desde el GUI
--Vuelve a dar ERROR

--Para conectarse hay que ir a opciones avanzadas en la esquina inferior derecha de la ventana de conexión (ver drive)

--desde vaa creamos una tabla

CREATE TABLE dbo.TablaContenida
	(Codigo NCHAR(10) NULL,
	Nombre NCHAR(10) NULL
	) ON [PRIMARY]
GO



