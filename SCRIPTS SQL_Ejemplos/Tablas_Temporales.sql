
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

USE Colegio_Medico
GO

DROP TABLE IF EXISTS reserva_plaza
GO

CREATE TABLE reserva_plaza
	(curso VARCHAR(20) PRIMARY KEY CLUSTERED,
	Num_reservas INTEGER,	--hasta aqui es tabla normal
		SysStartTime DATETIME2 GENERATED ALWAYS AS ROW START NOT NULL,	--tiempo en el que se crea la fila
		SysEndTime DATETIME2 GENERATED ALWAYS AS ROW END NOT NULL,	--tiempo hasta que es válida la fila
		PERIOD FOR SYSTEM_TIME (SysStartTime,SysEndTime) )	--aqui acaba la funcion
		WITH (System_Versioning = ON (History_Table = dbo.reserva_plaza_historico))	--para convertir la tabla normal en tabla temporal ponemos en ON y le damos un nombre a la tabla
GO


--comprobamos que las dos estan vacias
SELECT * FROM dbo.reserva_plaza
GO

SELECT * FROM dbo.reserva_plaza_historico
GO

--añadimos contenido a la tabla
INSERT INTO reserva_plaza (curso,Num_reservas)
VALUES ('curso1',2),
	('curso2',1),
	('curso3',4),
	('curso4',2),
	('curso5',6)
GO


--muestra la fecha (UTC)
PRINT GETUTCDATE()
GO


--comprobamos que se insertaron los registros

SELECT * FROM dbo.reserva_plaza
GO


--curso1	2	2023-01-16 19:25:13.6952266	9999-12-31 23:59:59.9999999
--curso2	1	2023-01-16 19:25:13.6952266	9999-12-31 23:59:59.9999999
--curso3	4	2023-01-16 19:25:13.6952266	9999-12-31 23:59:59.9999999
--curso4	2	2023-01-16 19:25:13.6952266	9999-12-31 23:59:59.9999999
--curso5	6	2023-01-16 19:25:13.6952266	9999-12-31 23:59:59.9999999

--comprobamos que en la tabla temporal no hay nada ya que no hubo cambios

SELECT * FROM dbo.reserva_plaza_historico
GO

UPDATE reserva_plaza
	SET Num_reservas = 7
	WHERE curso = 'curso1'
GO

--comprobamos que se actualizó

SELECT * FROM dbo.reserva_plaza
GO

--curso1	7	2023-01-16 19:34:45.7460727	9999-12-31 23:59:59.9999999
--curso2	1	2023-01-16 19:25:13.6952266	9999-12-31 23:59:59.9999999
--curso3	4	2023-01-16 19:25:13.6952266	9999-12-31 23:59:59.9999999
--curso4	2	2023-01-16 19:25:13.6952266	9999-12-31 23:59:59.9999999
--curso5	6	2023-01-16 19:25:13.6952266	9999-12-31 23:59:59.9999999

--comprobamos en la tabla historica que se añadio en registro anterior a la modificación

SELECT * FROM dbo.reserva_plaza_historico
GO
			--Num_reservas		SysStartTime															SysEndTime
--curso1	2				2023-01-16 19:25:13.6952266(fecha creación del registro)		2023-01-16 19:34:45.7460727(fecha en la que el registro cambió)

--hacemos otra actualización

UPDATE reserva_plaza
	SET Num_reservas = 9
	WHERE curso = 'curso2'
GO

--comprobamos la acualización

SELECT * FROM dbo.reserva_plaza
GO

--curso1	7	2023-01-16 19:34:45.7460727	9999-12-31 23:59:59.9999999
--curso2	9	2023-01-16 19:40:05.4270219	9999-12-31 23:59:59.9999999
--curso3	4	2023-01-16 19:25:13.6952266	9999-12-31 23:59:59.9999999
--curso4	2	2023-01-16 19:25:13.6952266	9999-12-31 23:59:59.9999999
--curso5	6	2023-01-16 19:25:13.6952266	9999-12-31 23:59:59.9999999

--comprobamos el cambio en la tabla historica

SELECT * FROM dbo.reserva_plaza_historico
GO

--curso1	2	2023-01-16 19:25:13.6952266	2023-01-16 19:34:45.7460727
--curso2	1	2023-01-16 19:25:13.6952266	2023-01-16 19:40:05.4270219


--modificamos otro registro

UPDATE reserva_plaza
	SET Num_reservas = 12
	WHERE curso = 'curso2'
GO

--comprobamos el cambio
SELECT * FROM dbo.reserva_plaza
GO

--curso1	7	2023-01-16 19:34:45.7460727	9999-12-31 23:59:59.9999999
--curso2	12	2023-01-16 19:42:08.5363212	9999-12-31 23:59:59.9999999
--curso3	4	2023-01-16 19:25:13.6952266	9999-12-31 23:59:59.9999999
--curso4	2	2023-01-16 19:25:13.6952266	9999-12-31 23:59:59.9999999
--curso5	6	2023-01-16 19:25:13.6952266	9999-12-31 23:59:59.9999999

--comprobamos que se añadió el regitro anterior en la tabla histórica

SELECT * FROM dbo.reserva_plaza_historico
GO

--curso1	2	2023-01-16 19:25:13.6952266	2023-01-16 19:34:45.7460727
--curso2	1	2023-01-16 19:25:13.6952266	2023-01-16 19:40:05.4270219
--curso2	9	2023-01-16 19:40:05.4270219	2023-01-16 19:42:08.5363212


--vemos el contenido del curso5
SELECT * FROM dbo.reserva_plaza WHERE curso = 'curso5'
GO

--curso5	6	2023-01-16 19:25:13.6952266	9999-12-31 23:59:59.9999999

--borramos curso5
DELETE FROM reserva_plaza
	WHERE curso = 'curso5'
GO

--comprobamos que aparece en la tabla historica
SELECT * FROM dbo.reserva_plaza_historico
GO

--curso1	2	2023-01-16 19:25:13.6952266	2023-01-16 19:34:45.7460727
--curso2	1	2023-01-16 19:25:13.6952266	2023-01-16 19:40:05.4270219
--curso2	9	2023-01-16 19:40:05.4270219	2023-01-16 19:42:08.5363212
--curso5	6	2023-01-16 19:25:13.6952266	2023-01-16 19:47:38.1596128


INSERT INTO reserva_plaza (curso,Num_reservas)
	VALUES ('curso6',13)
GO

--comprobamos que no aparece en la tabla historica ya que es un nuevo registro 

SELECT * FROM dbo.reserva_plaza_historico
GO


--curso1	2	2023-01-16 19:25:13.6952266	2023-01-16 19:34:45.7460727
--curso2	1	2023-01-16 19:25:13.6952266	2023-01-16 19:40:05.4270219
--curso2	9	2023-01-16 19:40:05.4270219	2023-01-16 19:42:08.5363212
--curso5	6	2023-01-16 19:25:13.6952266	2023-01-16 19:47:38.1596128
--curso6	13	2023-01-16 19:50:52.3249844	2023-01-16 19:51:01.9967454

--borramos el registro anterior

DELETE FROM reserva_plaza
	WHERE curso = 'curso6'
GO

--comprobamos que al borrarlo ya aparece en la tabla historica

SELECT * FROM dbo.reserva_plaza_historico
GO

--curso1	2	2023-01-16 19:25:13.6952266	2023-01-16 19:34:45.7460727
--curso2	1	2023-01-16 19:25:13.6952266	2023-01-16 19:40:05.4270219
--curso2	9	2023-01-16 19:40:05.4270219	2023-01-16 19:42:08.5363212
--curso5	6	2023-01-16 19:25:13.6952266	2023-01-16 19:47:38.1596128
--curso6	13	2023-01-16 19:51:18.1223493	2023-01-16 19:51:36.7310638

--comprobamos todas la modificaciones realizadas en la tabla (ALL)

SELECT * FROM dbo.reserva_plaza
FOR SYSTEM_TIME ALL
GO

--curso1	7	2023-01-16 19:34:45.7460727	9999-12-31 23:59:59.9999999
--curso2	12	2023-01-16 19:42:08.5363212	9999-12-31 23:59:59.9999999
--curso3	4	2023-01-16 19:25:13.6952266	9999-12-31 23:59:59.9999999
--curso4	2	2023-01-16 19:25:13.6952266	9999-12-31 23:59:59.9999999
--curso1	2	2023-01-16 19:25:13.6952266	2023-01-16 19:34:45.7460727
--curso2	1	2023-01-16 19:25:13.6952266	2023-01-16 19:40:05.4270219
--curso2	9	2023-01-16 19:40:05.4270219	2023-01-16 19:42:08.5363212
--curso5	6	2023-01-16 19:25:13.6952266	2023-01-16 19:47:38.1596128
--curso6	13	2023-01-16 19:50:52.3249844	2023-01-16 19:51:01.9967454
--curso6	13	2023-01-16 19:51:18.1223493	2023-01-16 19:51:36.7310638

--lo mismo pero filtrando por un registro concreto

SELECT * FROM dbo.reserva_plaza
FOR SYSTEM_TIME ALL
WHERE curso = 'curso2'
GO

--comprobamos como estaba el contenido en una fecha concreta

SELECT * FROM dbo.reserva_plaza
FOR SYSTEM_TIME AS OF '2023-01-16 19:51:00'
GO


--igual que lo anterior pero para un registro concreto

SELECT * FROM dbo.reserva_plaza
FOR SYSTEM_TIME AS OF '2023-01-16 19:51:00'
WHERE curso = 'curso1'
GO

--hacer modificaciones esperando dias para que se vean los cambios




--comprobamos entre un intervalo de tiempo (TO)

SELECT * FROM dbo.reserva_plaza
FOR SYSTEM_TIME FROM '2023-01-16 19:40:00' TO '2023-01-16 19:51:00'
WHERE curso = 'curso1'
GO

--igual que el anterior pero con "between"

SELECT * FROM dbo.reserva_plaza
FOR SYSTEM_TIME BETWEEN '2023-01-16 19:51:00' AND '2023-01-16 19:40:00'
WHERE curso = 'curso1'
GO

--igual que el anterior pero con "CONTAINED IN"
SELECT * FROM dbo.reserva_plaza
FOR SYSTEM_TIME CONTAINED IN ('2023-01-16 19:51:00','2023-01-16 19:40:00')
WHERE curso = 'curso1'
GO

