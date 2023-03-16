
--AUDITORIA A NIVEL DE SERVIDOR

--Creacion de las auditorias (a nivel de servidor)

--aplication.log (La captura va al visor de sucesos Aplications)
--security-log (La captura va al visor de sucesos Security)
--File	(La captura va a un fichero)


USE master
GO

--creamos la auditoria

CREATE SERVER AUDIT AuditoriaVAA
	TO application_log
WITH
	(queue_delay = 1000,
	on_failure = fail_operation
	)
GO

--para ver el resultado en el GUI "security --> audits"


--crear desde el entorno grafico y generar el codigo

CREATE SERVER AUDIT [Security_log_audit]
TO SECURITY_LOG WITH (QUEUE_DELAY = 1000, ON_FAILURE = CONTINUE, AUDIT_GUID = '0d972dd2-d26f-4693-8bc9-99817febeaf2')
ALTER SERVER AUDIT [Security_log_audit] WITH (STATE = OFF)
GO



-----------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------

USE master
GO

--AUDOTORIA EN FICHERO
--creamos una auditoria en un fichero

CREATE SERVER AUDIT AuditoriaVAA3
TO FILE (
	filepath = 'C:\auditoria\',
	maxsize = 0mb,
	max_rollover_files = 2147483647,
	reserve_disk_space = off
)
WITH
	(queue_delay = 1000,
	on_failure = continue
	)
GO


---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------

--ESPECIFICAMOS A QUE SE HARÁ LA AUDITORIA ANTERIOR

CREATE SERVER AUDIT SPECIFICATION [ServerAuditSpecification-20230313-204505]
FOR SERVER AUDIT [File_Log_audits]
ADD (BACKUP_RESTORE_GROUP),
ADD (DBCC_GROUP)
WITH (STATE = ON)
GO


--hacemos el backup para comprobar la auditoria

BACKUP DATABASE Alquiler_Avionetas
	TO DISK = 'C:\Auditoria\Alquiler_Avionetas.bak'
	WITH INIT;
GO

--check the current database (audit action type)

DBCC CHECKDB;
GO

--check adventureWorks2017 databse without nonclustered indexes

DBCC CHECKDB (adventureWorks2017, NOINDEX);
GO

--para consultar el fichero

SELECT * FROM sys.fn_get_audit_file ('C:\Auditoria\*', default,default);
GO






------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--AUDITORIA A NIVEL DE BASE DE DATOS

USE Alquiler_Avionetas
GO


--en el GUI adventureWorks2017 --> security --> databse audit specifications

--generado desde el gui


CREATE DATABASE AUDIT SPECIFICATION [AuditoriaTablaAccesoPilotos]
FOR SERVER AUDIT [AuditoriaVAA3]
ADD (DELETE ON OBJECT::[dbo].[Acceso_Piloto] BY [dbo]),
ADD (INSERT ON OBJECT::[dbo].[Acceso_Piloto] BY [dbo]),
ADD (SELECT ON OBJECT::[dbo].[Acceso_Piloto] BY [dbo]),
ADD (UPDATE ON OBJECT::[dbo].[Acceso_Piloto] BY [dbo])
WITH (STATE = ON)
GO




--hacemos select para que salgan en la auditoria

SELECT * FROM Acceso_Piloto
GO

--consultamos el fichero

SELECT * 
	FROM sys.fn_get_audit_file ('C:\Auditoria\*.sqlaudit',default,default);
GO


--borrar auditoria

ALTER DATABASE AUDIT SPECIFICATION [AuditoriaTablaAccesoPilotos]
WITH (STATE = OFF)
GO

DROP DATABASE AUDIT SPECIFICATION [AuditoriaTablaAccesoPilotos]
Go



