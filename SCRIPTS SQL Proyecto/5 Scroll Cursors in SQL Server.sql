-- Scroll Cursors in SQL Server


DROP DATABASE IF EXISTS SCROLLCURSOR
GO
CREATE DATABASE SCROLLCURSOR
GO
USE SCROLLCURSOR
GO
--
CREATE TABLE [dbo].[Employees](
   [Id]              [int] NULL,
   [Firstname]       [varchar](50) NULL,
   [Lastname]        [varchar](50) NULL,
   [Phone]           [varchar](50) NULL,
   [Email]           [varchar](50) NULL,
   [CountryId]       [varchar](50) NULL,
   [Dateofbirth]     [date] NULL,
   [DepartmentId]    [int] NULL,
   [Secondary_Phone] [varchar](255) NULL
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[Project_Details](
   [Emp_Id]      [int] NULL,
   [ProjectName] [varchar](50) NULL,
   [ProjectDesc] [varchar](50) NULL,
   [ProjectCost] [int] NULL,
   [Project_Id]  [int] NULL
) ON [PRIMARY]
GO

-- insert sample Employees data
INSERT [dbo].[Employees] ([Id], [Firstname], [Lastname], [Phone], [Email], [CountryId], [Dateofbirth], [DepartmentId], [Secondary_Phone]) 
   VALUES (10, N'John', N'Reacher', N'87169', N'John@mail.com', N'100', CAST(N'1987-10-04' AS Date), 80, N'878763')
INSERT [dbo].[Employees] ([Id], [Firstname], [Lastname], [Phone], [Email], [CountryId], [Dateofbirth], [DepartmentId], [Secondary_Phone]) 
   VALUES (11, N'Sam', N'Smith', N'87168', N'Sam@mail.com', N'101', CAST(N'1987-10-09' AS Date), 81, N'878764')
INSERT [dbo].[Employees] ([Id], [Firstname], [Lastname], [Phone], [Email], [CountryId], [Dateofbirth], [DepartmentId], [Secondary_Phone]) 
   VALUES (12, N'Ted', N'Mosby', N'87167', N'Ted@mail.com', N'102', CAST(N'1986-10-09' AS Date), 82, N'878765')
INSERT [dbo].[Employees] ([Id], [Firstname], [Lastname], [Phone], [Email], [CountryId], [Dateofbirth], [DepartmentId], [Secondary_Phone]) 
   VALUES (13, N'Nelson', N'Glen', N'87170', N'Nelson@mail.com', N'103', CAST(N'1985-10-08' AS Date), 83, N'878766')
INSERT [dbo].[Employees] ([Id], [Firstname], [Lastname], [Phone], [Email], [CountryId], [Dateofbirth], [DepartmentId], [Secondary_Phone]) 
   VALUES (14, N'Ash', N'Grey', N'87171', N'Ash@mail.com', N'104', CAST(N'1988-10-04' AS Date), 83, N'878767')
GO

SELECT * FROM [dbo].[Employees]
GO
-- insert sample Project_Details data
INSERT [dbo].[Project_Details] ([Emp_Id], [ProjectName], [ProjectDesc], [ProjectCost], [Project_Id]) 
   VALUES (10, N'Finace', N'Payroll Software Rollouts', 10000, 100)
INSERT [dbo].[Project_Details] ([Emp_Id], [ProjectName], [ProjectDesc], [ProjectCost], [Project_Id]) 
   VALUES (10, N'HR', N'HR Software Rollouts', 20000, 101)
INSERT [dbo].[Project_Details] ([Emp_Id], [ProjectName], [ProjectDesc], [ProjectCost], [Project_Id]) 
   VALUES (10, N'Inventory', N'Inventory Software Rollouts', 30000, 102)
INSERT [dbo].[Project_Details] ([Emp_Id], [ProjectName], [ProjectDesc], [ProjectCost], [Project_Id]) 
   VALUES (11, N'Ledgers', N'Ledger Software Rollouts', 3000, 103)
INSERT [dbo].[Project_Details] ([Emp_Id], [ProjectName], [ProjectDesc], [ProjectCost], [Project_Id]) 
   VALUES (11, N'Marketing', N'Marketing Software Rollouts', 40000, 104)
INSERT [dbo].[Project_Details] ([Emp_Id], [ProjectName], [ProjectDesc], [ProjectCost], [Project_Id]) 
   VALUES (11, N'Risk Management', N'Risk Mgmt Software Rollouts', 5000, 105)
INSERT [dbo].[Project_Details] ([Emp_Id], [ProjectName], [ProjectDesc], [ProjectCost], [Project_Id]) 
   VALUES (12, N'Ledger', N'Ledger Software Rollouts', 3000, 103)
INSERT [dbo].[Project_Details] ([Emp_Id], [ProjectName], [ProjectDesc], [ProjectCost], [Project_Id]) 
   VALUES (12, N'Marketing', N'Marketing Software Rollouts', 40000, 104)
INSERT [dbo].[Project_Details] ([Emp_Id], [ProjectName], [ProjectDesc], [ProjectCost], [Project_Id]) 
   VALUES (13, N'Risk Management', N'Risk Mgmt Software Rollouts', 5000, 105)
INSERT [dbo].[Project_Details] ([Emp_Id], [ProjectName], [ProjectDesc], [ProjectCost], [Project_Id]) 
   VALUES (14, N'Utility', N'Utility Software Rollouts', 45000, 106)
GO
SELECT * FROM Project_Details
GO

SELECT 
   b.id, 
   b.Firstname, 
   b.Lastname, 
   a.ProjectName, 
   a.ProjectDesc, 
   a.ProjectCost
FROM Project_Details a
  INNER JOIN Employees b ON b.Id = a.Emp_id
ORDER BY b.id;
GO

SELECT ROW_NUMBER() OVER (order by b.id) AS 'RowNumber', 
   b.id, 
   b.Firstname, 
   b.Lastname, 
   a.ProjectName, 
   a.ProjectDesc, 
   a.ProjectCost
FROM Project_Details a
  INNER JOIN Employees b ON b.Id = a.Emp_id
ORDER BY b.id;
GO

-- SQL Cursor to Loop Through All Rows

DECLARE @RowNumber varchar(max);
DECLARE @Field1 varchar(max);
DECLARE @Field2 varchar(max);
DECLARE @Field3 varchar(max);
DECLARE @Field4 varchar(max);

BEGIN
   -- set the variable to the query used for the cursor
   DECLARE MyCursor CURSOR READ_ONLY FOR
      SELECT ROW_NUMBER() OVER (order by b.id) AS 'RowNumber', b.id, b.Firstname, b.Lastname, a.ProjectName
      FROM Project_Details a
        INNER JOIN Employees b ON b.Id = a.Emp_id
      ORDER BY b.id;
  
   OPEN MyCursor;

   FETCH NEXT FROM MyCursor INTO @RowNumber, @Field1, @Field2, @Field3, @Field4;

   WHILE @@FETCH_STATUS = 0
   BEGIN
      PRINT 'RowNumber:' + @RowNumber + ', ID:' + @Field1 + ', Employee:' + @Field2 + ' ' + @Field3 + ', Project:' + @Field4;
   
      FETCH NEXT FROM MyCursor INTO @RowNumber, @Field1, @Field2, @Field3, @Field4;
   END; 
 
   CLOSE MyCursor;
   DEALLOCATE MyCursor;
END;
GO
-- STORED PROCEDURE

CREATE OR ALTER PROC SCROLLCURSOR
AS
DECLARE @RowNumber varchar(max);
DECLARE @Field1 varchar(max);
DECLARE @Field2 varchar(max);
DECLARE @Field3 varchar(max);
DECLARE @Field4 varchar(max);

BEGIN
   -- set the variable to the query used for the cursor
   DECLARE MyCursor CURSOR READ_ONLY FOR
      SELECT ROW_NUMBER() OVER (order by b.id) AS 'RowNumber', b.id, b.Firstname, b.Lastname, a.ProjectName
      FROM Project_Details a
        INNER JOIN Employees b ON b.Id = a.Emp_id
      ORDER BY b.id;
  
   OPEN MyCursor;

   FETCH NEXT FROM MyCursor INTO @RowNumber, @Field1, @Field2, @Field3, @Field4;

   WHILE @@FETCH_STATUS = 0
   BEGIN
      PRINT 'RowNumber:' + @RowNumber + ', ID:' + @Field1 + ', Employee:' + @Field2 + ' ' + @Field3 + ', Project:' + @Field4;
   
      FETCH NEXT FROM MyCursor INTO @RowNumber, @Field1, @Field2, @Field3, @Field4;
   END; 
 
   CLOSE MyCursor;
   DEALLOCATE MyCursor;
END
GO

EXECUTE SCROLLCURSOR
GO


--RowNumber:1, ID:10, Employee:John Reacher, Project:Finace
--RowNumber:2, ID:10, Employee:John Reacher, Project:HR
--RowNumber:3, ID:10, Employee:John Reacher, Project:Inventory
--RowNumber:4, ID:11, Employee:Sam Smith, Project:Ledgers
--RowNumber:5, ID:11, Employee:Sam Smith, Project:Marketing
--RowNumber:6, ID:11, Employee:Sam Smith, Project:Risk Management
--RowNumber:7, ID:12, Employee:Ted Mosby, Project:Ledger
--RowNumber:8, ID:12, Employee:Ted Mosby, Project:Marketing
--RowNumber:9, ID:13, Employee:Nelson Glen, Project:Risk Management
--RowNumber:10, ID:14, Employee:Ash Grey, Project:Utility



--
--SQL Scroll Cursor to Selectively Pick Rows
--In this example, we will use a scroll cursor and use the following items to selectively choose the record to work with instead of looping through rows one by one.

--FETCH FIRST: Moves to the first record.
--FETCH LAST: Moves the cursor to the last record of the result set.
--FETCH ABSOLUTE: Moves the cursor to the specified record 'n' of the result set, where n is the number of rows.
--FETCH RELATIVE: Moves the cursor to 'n' rows after the current row, where n is the number of rows.
--FETCH NEXT: Moves to the next record.
--FETCH PRIOR: Moves the cursor before last fetch of the result set. Note: there will be no result for the first fetch because it will position the cursor before the first row.
--To defined the cursor, we use the SCROLL keyword and we are also making it a READ_ONLY cursor, so updates cannot be made to the cursor.

--This is the line in the code to define the cursor: DECLARE MyCursor CURSOR SCROLL READ_ONLY FOR

CREATE OR ALTER PROC SCROLLCURSOR_PICK
AS
DECLARE @RowNumber varchar(max);
DECLARE @Field1 varchar(max);
DECLARE @Field2 varchar(max);
DECLARE @Field3 varchar(max);
DECLARE @Field4 varchar(max);

BEGIN
   -- set the variable to the query used for the cursor
   DECLARE MyCursor CURSOR SCROLL READ_ONLY FOR
      SELECT ROW_NUMBER() OVER (order by b.id) AS 'RowNumber', b.id, b.Firstname, b.Lastname, a.ProjectName
      FROM Project_Details a
        INNER JOIN Employees b ON b.Id = a.Emp_id
      ORDER BY b.id;
  
   OPEN MyCursor;

   --FETCH LAST
   FETCH LAST FROM MyCursor INTO @RowNumber, @Field1, @Field2, @Field3, @Field4;
   PRINT 'RowNumber:' + @RowNumber + ', ID:' + @Field1 + ', Employee:' + @Field2 + ' ' + @Field3 + ', Project:' + @Field4

   --FETCH ABSOLUTE
   FETCH ABSOLUTE 5 FROM MyCursor INTO @RowNumber, @Field1, @Field2, @Field3, @Field4;
   PRINT 'RowNumber:' + @RowNumber + ', ID:' + @Field1 + ', Employee:' + @Field2 + ' ' + @Field3 + ', Project:' + @Field4
   
   --FETCH RELATIVE
   FETCH RELATIVE 3 FROM MyCursor INTO @RowNumber, @Field1, @Field2, @Field3, @Field4;
   PRINT 'RowNumber:' + @RowNumber + ', ID:' + @Field1 + ', Employee:' + @Field2 + ' ' + @Field3 + ', Project:' + @Field4
      
   --FETCH PRIOR
   FETCH PRIOR FROM MyCursor INTO @RowNumber, @Field1, @Field2, @Field3, @Field4;
   PRINT 'RowNumber:' + @RowNumber + ', ID:' + @Field1 + ', Employee:' + @Field2 + ' ' + @Field3 + ', Project:' + @Field4

   --FETCH FIRST
   FETCH FIRST FROM MyCursor INTO @RowNumber, @Field1, @Field2, @Field3, @Field4;
   PRINT 'RowNumber:' + @RowNumber + ', ID:' + @Field1 + ', Employee:' + @Field2 + ' ' + @Field3 + ', Project:' + @Field4
 
   --FETCH NEXT
   FETCH NEXT FROM MyCursor INTO @RowNumber, @Field1, @Field2, @Field3, @Field4;
   PRINT 'RowNumber:' + @RowNumber + ', ID:' + @Field1 + ', Employee:' + @Field2 + ' ' + @Field3 + ', Project:' + @Field4
    
   CLOSE MyCursor;
   DEALLOCATE MyCursor;
END
GO

EXECUTE SCROLLCURSOR_PICK
GO

--RowNumber:10, ID:14, Employee:Ash Grey, Project:Utility
--RowNumber:5, ID:11, Employee:Sam Smith, Project:Marketing
--RowNumber:8, ID:12, Employee:Ted Mosby, Project:Marketing
--RowNumber:7, ID:12, Employee:Ted Mosby, Project:Ledger
--RowNumber:1, ID:10, Employee:John Reacher, Project:Finace
--RowNumber:2, ID:10, Employee:John Reacher, Project:HR

--Here is a breakdown of how these rows were selected:

--RowNumber 10 = LAST
--RowNumber 5 = ABSOLUTE 5 (go to 5th row)
--RowNumber 8 = RELATIVE 3 (cursor is at row 5 plus 3 more rows)
--RowNumber 7 = PRIOR
--RowNumber 1 = FIRST
--RowNumber 2 = NEXT
