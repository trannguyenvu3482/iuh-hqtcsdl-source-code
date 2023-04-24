-- Kiem tra thuc hanh 2,3
use AdventureWorks2008R2
-- Tạo  các  login;  tạo  các  user  khai  thác  CSDL  AdventureWorks2008R2  cho  các  nhân  viên  (tên 
-- login  trùng  tên user)

CREATE LOGIN TN WITH PASSWORD = N'Password123'
CREATE LOGIN NV WITH PASSWORD = N'Password123'
CREATE LOGIN QL WITH PASSWORD = N'Password123'

use AdventureWorks2008R2
CREATE USER TN FOR LOGIN TN
CREATE USER NV FOR LOGIN NV
CREATE USER QL FOR LOGIN QL

-- b)
go
grant select, insert, update, delete on HumanResources.EmployeeDepartmentHistory to TN
grant select, insert, update, delete on HumanResources.EmployeeDepartmentHistory to NV

go
sp_addrolemember 'db_datareader', QL
go

-- c)

-- d)
revoke select on HumanResources.EmployeeDepartmentHistory to NV

-- e)
revoke select, insert, update, delete on HumanResources.EmployeeDepartmentHistory to TN
revoke select, insert, update, delete on HumanResources.EmployeeDepartmentHistory to NV
go
sp_droprolemember 'db_datareader', QL
go


-- Câu 2:
-- a)
alter table HumanResources.Department
add NumEmp int

update HumanResources.Department
set NumEmp = 0

-- b)
go
CREATE TRIGGER TranNguyenVu_DepHistory
    ON HumanResources.EmployeeDepartmentHistory
    FOR UPDATE
    AS
    BEGIN
		declare @NumEmp int, @DepartmentID int
		set @DepartmentID = (select DepartmentID from inserted)
		set @NumEmp = (select count(*)
							from HumanResources.EmployeeDepartmentHistory edh inner join HumanResources.Shift s
								on edh.ShiftID = s.ShiftID
							where Name = 'Day');
		update Department
		set NumEmp = @NumEmp
		where DepartmentID = @DepartmentID 
    END
go

-- c)
update HumanResources.EmployeeDepartmentHistory
set EndDate = '2005-06-30'
where DepartmentID = 1 and BusinessEntityID = 4

select * from HumanResources.Department


-- Cau 3:
-- a)
GO
BACKUP DATABASE [AdventureWorks2008R2]
TO DISK = N'T:\AdventureWorks2008R2_Backup.bak'
GO


-- b)
update HumanResources.EmployeePayHistory
set Rate = Rate * 1.1
where BusinessEntityID IN (select BusinessEntityID
							from HumanResources.EmployeeDepartmentHistory edh
							inner join HumanResources.Shift s on edh.ShiftID = s.ShiftID
							where Name = 'Evening')

update HumanResources.EmployeePayHistory
set Rate = Rate * 1.2
where BusinessEntityID IN (select BusinessEntityID
							from HumanResources.EmployeeDepartmentHistory edh
							inner join HumanResources.Shift s on edh.ShiftID = s.ShiftID
							where Name = 'Night')


BACKUP DATABASE [AdventureWorks2008R2]
TO DISK = N'T:\AdventureWorks2008R2_Backup1.bak'
WITH DIFFERENTIAL
GO

-- c)

-- d)
-- ALTER DATABASE AdventureWorks2008R2
-- SET RECOVERY FULL

BACKUP LOG AdventureWorks2008R2
TO DISK N'T:\AdventureWorks2008R2_BackupLog.trn'

-- e)
DROP DATABASE AdventureWorks2008R2

RESTORE DATABASE [database_name]
FROM DISK = 'full_backup_file_path_cau_a'
WITH NORECOVERY;
GO
RESTORE DATABASE [database_name]
FROM DISK = 'differential_backup_file_path_cau_b'
WITH NORECOVERY;
GO
RESTORE LOG [database_name]
FROM DISK = 'transaction_log_backup_file_path_cau_c'
WITH NORECOVERY;
GO
RESTORE DATABASE [database_name]
WITH RECOVERY;
GO
