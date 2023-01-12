
--TABLAS TEMPORALES

--Ejemplo colegio médico

USE master
GO

DROP DATABASE IF EXISTS Colegio_Medico
GO

CREATE DATABASE Colegio_Medico
	ON PRIMARY (NAME = 'Colegio_Medico',
	FILENAME = 'C:\Data\Colegio_Medico_Fijo.mdf',
	SIZE = 15360kb, MAXSIZE = UNLIMITED, FILEGROWTH = 0)
	LOG ON ( NAME = 'Colegio_Medico_log',
	FILENAME = 'C:\Data\Colegio_Medico_log.ldf',
	SIZE = 10176KB, MAXSIZE = 2048GB, FILEGROWTH = 10%)
GO


