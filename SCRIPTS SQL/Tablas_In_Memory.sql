
--TABLAS IN-MEMORY

SELECT d.compatibility_level
    FROM sys.databases as d
    WHERE d.name = Db_Name();
GO


-- GUI Properties DB
--compatibility_level
--140

ALTER DATABASE Alquiler_Avionetas
SET COMPATIBILITY_LEVEL = 140;
GO

ALTER DATABASE Alquiler_Avionetas
SET MEMORY_OPTIMIZED_ELEVATE_TO_SNAPSHOT = ON;
GO

ALTER DATABASE Alquiler_Avionetas
ADD FILEGROUP Alquiler_Avionetas_InMemory CONTAINS MEMORY_OPTIMIZED_DATA;
go

ALTER DATABASE Alquiler_Avionetas
ADD FILE 
	(name='Alquiler_Avionetas_InMemory', 
	filename='c:\data\Alquiler_Avionetas_InMemory')
	TO FILEGROUP Alquiler_Avionetas_InMemory
go


USE Alquiler_Avionetas
go

CREATE TABLE Clientes_InMemory
    (
        ID_Cliente   INTEGER   NOT NULL   IDENTITY
            PRIMARY KEY NONCLUSTERED,
        Nombre   VARCHAR(20)    NOT NULL,
		Apellidos VARCHAR (20) NOT NULL,
        Fecha_Alquiler DATETIME   NOT NULL
    )
        WITH
            (MEMORY_OPTIMIZED = ON,
            DURABILITY = SCHEMA_AND_DATA);
GO








CREATE TABLE [dbo].[MemoryOptimizationAdvisor](
[Id] [int] NOT NULL,
CONSTRAINT [PK_Example] PRIMARY KEY CLUSTERED 
(
[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO