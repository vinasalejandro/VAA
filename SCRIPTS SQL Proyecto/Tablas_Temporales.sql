
--TABLAS TEMPORALES



USE Alquiler_Avionetas
GO

DROP TABLE IF EXISTS Alquileres
GO

CREATE TABLE Alquileres
	(Alquiler VARCHAR(20) PRIMARY KEY CLUSTERED,
	Num_Personas_Vuelo INTEGER,	--hasta aqui es tabla normal
		SysStartTime DATETIME2 GENERATED ALWAYS AS ROW START NOT NULL,	--tiempo en el que se crea la fila
		SysEndTime DATETIME2 GENERATED ALWAYS AS ROW END NOT NULL,	--tiempo hasta que es válida la fila
		PERIOD FOR SYSTEM_TIME (SysStartTime,SysEndTime) )	--aqui acaba la funcion
		WITH (System_Versioning = ON (History_Table = dbo.Alquileres_Historico))	--para convertir la tabla normal en tabla temporal ponemos en ON y le damos un nombre a la tabla
GO


--comprobamos que las dos estan vacias

SELECT * FROM dbo.Alquileres
GO

SELECT * FROM dbo.Alquileres_Historico
GO

--añadimos contenido a la tabla

INSERT INTO Alquileres(Alquiler,Num_Personas_Vuelo)
VALUES ('Alquiler1',2),
	('Alquiler2',1),
	('Alquiler3',2),
	('Alquiler4',3),
	('Alquiler5',1)
GO


--muestra la fecha (UTC)


PRINT GETUTCDATE()
GO


--comprobamos que se insertaron los registros

SELECT * FROM Alquileres
GO



--comprobamos que en la tabla temporal no hay nada ya que no hubo cambios

SELECT * FROM Alquileres_Historico
GO


UPDATE Alquileres
	SET Num_Personas_Vuelo = 3
	WHERE Alquiler = 'Alquiler1'
GO

--comprobamos que se actualizó

SELECT * FROM Alquileres
GO


--comprobamos en la tabla historica que se añadio en registro anterior a la modificación

SELECT * FROM Alquileres_Historico
GO


--hacemos otra actualización

UPDATE Alquileres
	SET Num_Personas_Vuelo = 4
	WHERE Alquiler = 'Alquiler2'
GO

--comprobamos la acualización

SELECT * FROM Alquileres
GO

--comprobamos el cambio en la tabla historica

SELECT * FROM Alquileres_Historico
GO




--modificamos otro registro

UPDATE Alquileres
	SET Num_Personas_Vuelo = 5
	WHERE Alquiler = 'Alquiler2'
GO

--comprobamos el cambio

SELECT * FROM Alquileres
GO



--comprobamos que se añadió el regitro anterior en la tabla histórica

SELECT * FROM Alquileres_Historico
GO


--vemos el contenido del Alquiler4
SELECT * FROM Alquileres WHERE Alquiler = 'Alquiler4'
GO



--borramos alquiler4
DELETE FROM Alquileres
	WHERE Alquiler = 'Alquiler4'
GO

--comprobamos que aparece en la tabla historica

SELECT * FROM Alquileres_Historico
GO



INSERT INTO Alquileres(Alquiler,Num_Personas_Vuelo)
	VALUES ('Alquiler6',7)
GO

--comprobamos que no aparece en la tabla historica ya que es un nuevo registro 

SELECT * FROM Alquileres_Historico
GO



--borramos el registro anterior

DELETE FROM Alquileres
	WHERE Alquiler = 'Alquiler6'
GO

--comprobamos que al borrarlo ya aparece en la tabla historica

SELECT * FROM Alquileres_Historico
GO


--comprobamos todas la modificaciones realizadas en la tabla (ALL)

SELECT * FROM Alquileres
FOR SYSTEM_TIME ALL
GO


--lo mismo pero filtrando por un registro concreto

SELECT * FROM Alquileres
FOR SYSTEM_TIME ALL
WHERE Alquiler = 'Alquiler2'
GO

--comprobamos como estaba el contenido en una fecha concreta

SELECT * FROM Alquileres
FOR SYSTEM_TIME AS OF '2023-03-9 21:00:00'
GO


--igual que lo anterior pero para un registro concreto

SELECT * FROM Alquileres
FOR SYSTEM_TIME AS OF '2023-01-16 19:51:00'
WHERE Alquiler = 'Alquiler1'
GO

--hacer modificaciones esperando dias para que se vean los cambios




--comprobamos entre un intervalo de tiempo (TO)

SELECT * FROM Alquileres
FOR SYSTEM_TIME FROM '2023-01-16 19:40:00' TO '2023-01-16 19:51:00'
WHERE Alquiler = 'Alquiler1'
GO

--igual que el anterior pero con "between"

SELECT * FROM Alquileres
FOR SYSTEM_TIME BETWEEN '2023-03-09 20:00:00' AND '2023-03-09 20:06:00'
WHERE Alquiler = 'Alquiler1'
GO

--igual que el anterior pero con "CONTAINED IN"
SELECT * FROM Alquileres
FOR SYSTEM_TIME CONTAINED IN ('2023-01-16 19:51:00','2023-01-16 19:40:00')
WHERE Alquiler = 'Alquiler1'
GO

