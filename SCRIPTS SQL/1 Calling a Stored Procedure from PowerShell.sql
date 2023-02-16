
USE Alquiler_Avionetas
GO

DROP TABLE IF EXISTS Alquiler
GO

create table Alquiler
( Id_Alquiler int,
  Fecha_alquiler date,
  Id_Cliente int,
  Numero_horas int,
  Precio_hora numeric(10,4)
)
go
insert Alquiler( Id_Alquiler,  Fecha_alquiler, Id_cliente, Numero_horas, Precio_hora)
 values 
  ( 1, '6/11/2020', 1,  2, 100),
  ( 2, '7/20/2020', 1,  4, 100),
  ( 3, '7/25/2020', 4,  1, 100),
  ( 4, '8/12/2020', 6,  3, 100),
  ( 5, '8/21/2020', 6,  5, 100)
  
go
select * from Alquiler
go

create or alter procedure Precio_total
as
begin
   select Id_Alquiler,Fecha_Alquiler, id_cliente, Numero_horas * Precio_hora as Precio_total
  
    from Alquiler
end
go

EXECUTE Precio_total
GO




