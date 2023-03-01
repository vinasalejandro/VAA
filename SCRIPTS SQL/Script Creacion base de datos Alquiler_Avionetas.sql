
--Script creacion base de datos Alquiler Avionetas

DROP DATABASE IF EXISTS Alquiler_Avionetas
GO

CREATE DATABASE Alquiler_Avionetas
GO



CREATE TABLE Aeropuerto 
    (
     Id_aeropuerto INTEGER NOT NULL , 
     Nombre VARCHAR , 
     Avioneta_Matricula_Avioneta VARCHAR NOT NULL , 
     Localizacion_Id_localización INTEGER NOT NULL 
    )
GO

ALTER TABLE Aeropuerto ADD CONSTRAINT Aeropuerto_PK PRIMARY KEY CLUSTERED (Id_aeropuerto)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

CREATE TABLE Alquiler 
    (
     Id_Alquiler VARCHAR NOT NULL , 
     Avioneta_Matricula_Avioneta VARCHAR NOT NULL , 
     Cliente_DNI_Cliente VARCHAR NOT NULL , 
     Tarifa_Id_Tarifa VARCHAR NOT NULL , 
     Disponibilidad DATE , 
     Duracion TIME 
    )
GO

ALTER TABLE Alquiler ADD CONSTRAINT Alquiler_PK PRIMARY KEY CLUSTERED (Id_Alquiler)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

CREATE TABLE Avioneta 
    (
     Matricula_Avioneta VARCHAR NOT NULL , 
     Marca VARCHAR , 
     Modelo VARCHAR , 
     Año_Fabricacion NUMERIC (28) , 
     Piloto_Id_Piloto VARCHAR NOT NULL , 
     Copiloto_Id_Copiloto VARCHAR NOT NULL 
    )
GO

ALTER TABLE Avioneta ADD CONSTRAINT Avioneta_PK PRIMARY KEY CLUSTERED (Matricula_Avioneta)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

CREATE TABLE Cliente 
    (
     DNI_Cliente VARCHAR NOT NULL , 
     Nombre VARCHAR , 
     Apellidos VARCHAR , 
     Edad NUMERIC (28) , 
     Direccion VARCHAR , 
     Telefono NUMERIC (28) 
    )
GO

ALTER TABLE Cliente ADD CONSTRAINT Cliente_PK PRIMARY KEY CLUSTERED (DNI_Cliente)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

CREATE TABLE Copiloto 
    (
     Id_Copiloto VARCHAR NOT NULL , 
     Nombre VARCHAR , 
     Apellidos VARCHAR 
    )
GO

ALTER TABLE Copiloto ADD CONSTRAINT Copiloto_PK PRIMARY KEY CLUSTERED (Id_Copiloto)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

CREATE TABLE Localizacion 
    (
     Id_localización INTEGER NOT NULL , 
     Ciudad VARCHAR , 
     Pais VARCHAR 
    )
GO

ALTER TABLE Localizacion ADD CONSTRAINT Localizacion_PK PRIMARY KEY CLUSTERED (Id_localización)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

CREATE TABLE Mantenimiento 
    (
     Id_mantenimiento INTEGER NOT NULL , 
     Numero_Horas_Vuelo NUMERIC (28) , 
     Avioneta_Matricula_Avioneta VARCHAR NOT NULL , 
     Mecanico_Id_mecanico VARCHAR NOT NULL , 
     Operaciones_Realizadas VARCHAR 
    )
GO

ALTER TABLE Mantenimiento ADD CONSTRAINT Mantenimiento_PK PRIMARY KEY CLUSTERED (Id_mantenimiento)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

CREATE TABLE Mecanico 
    (
     Id_mecanico VARCHAR NOT NULL , 
     Nombre VARCHAR , 
     Apellidos VARCHAR , 
     DNI VARCHAR 
    )
GO

ALTER TABLE Mecanico ADD CONSTRAINT Mecanico_PK PRIMARY KEY CLUSTERED (Id_mecanico)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

CREATE TABLE Piloto 
    (
     Id_Piloto VARCHAR NOT NULL , 
     Nombre VARCHAR , 
     Apellidos VARCHAR 
    )
GO

ALTER TABLE Piloto ADD CONSTRAINT Piloto_PK PRIMARY KEY CLUSTERED (Id_Piloto)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

CREATE TABLE Tarifa 
    (
     Id_Tarifa VARCHAR NOT NULL , 
     Precio MONEY , 
     Tiempo TIME 
    )
GO

ALTER TABLE Tarifa ADD CONSTRAINT Tarifa_PK PRIMARY KEY CLUSTERED (Id_Tarifa)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

ALTER TABLE Aeropuerto 
    ADD CONSTRAINT Aeropuerto_Avioneta_FK FOREIGN KEY 
    ( 
     Avioneta_Matricula_Avioneta
    ) 
    REFERENCES Avioneta 
    ( 
     Matricula_Avioneta 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

ALTER TABLE Aeropuerto 
    ADD CONSTRAINT Aeropuerto_Localizacion_FK FOREIGN KEY 
    ( 
     Localizacion_Id_localización
    ) 
    REFERENCES Localizacion 
    ( 
     Id_localización 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

ALTER TABLE Alquiler 
    ADD CONSTRAINT Alquiler_Avioneta_FK FOREIGN KEY 
    ( 
     Avioneta_Matricula_Avioneta
    ) 
    REFERENCES Avioneta 
    ( 
     Matricula_Avioneta 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

ALTER TABLE Alquiler 
    ADD CONSTRAINT Alquiler_Cliente_FK FOREIGN KEY 
    ( 
     Cliente_DNI_Cliente
    ) 
    REFERENCES Cliente 
    ( 
     DNI_Cliente 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

ALTER TABLE Alquiler 
    ADD CONSTRAINT Alquiler_Tarifa_FK FOREIGN KEY 
    ( 
     Tarifa_Id_Tarifa
    ) 
    REFERENCES Tarifa 
    ( 
     Id_Tarifa 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

ALTER TABLE Avioneta 
    ADD CONSTRAINT Avioneta_Copiloto_FK FOREIGN KEY 
    ( 
     Copiloto_Id_Copiloto
    ) 
    REFERENCES Copiloto 
    ( 
     Id_Copiloto 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

ALTER TABLE Avioneta 
    ADD CONSTRAINT Avioneta_Piloto_FK FOREIGN KEY 
    ( 
     Piloto_Id_Piloto
    ) 
    REFERENCES Piloto 
    ( 
     Id_Piloto 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

ALTER TABLE Mantenimiento 
    ADD CONSTRAINT Mantenimiento_Avioneta_FK FOREIGN KEY 
    ( 
     Avioneta_Matricula_Avioneta
    ) 
    REFERENCES Avioneta 
    ( 
     Matricula_Avioneta 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

ALTER TABLE Mantenimiento 
    ADD CONSTRAINT Mantenimiento_Mecanico_FK FOREIGN KEY 
    ( 
     Mecanico_Id_mecanico
    ) 
    REFERENCES Mecanico 
    ( 
     Id_mecanico 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO