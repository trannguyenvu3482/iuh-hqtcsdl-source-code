-- Lab 08, Module 06: Role-Permission

/*
1) Đăng nhập vào SQL bằng SQL Server authentication, tài khoản sa. Sử dụng TSQL.
*/

/*
2) Tạo hai login SQL server Authentication User2 và User3
*/

CREATE LOGIN User2 WITH PASSWORD = '@Password123'
CREATE LOGIN User3 WITH PASSWORD = '@Password123'

/*
3) Tạo một database user User2 ứng với login User2 và một database user User3
ứng với login User3 trên CSDL AdventureWorks2008.
*/
GO
USE AdventureWorks2008R2
CREATE USER User2 FOR LOGIN User2
CREATE USER User3 FOR LOGIN User3
GO


/*
4) Tạo 2 kết nối đến server thông qua login User2 và User3, sau đó thực hiện các
thao tác truy cập CSDL của 2 user tương ứng (VD: thực hiện câu Select). Có thực
hiện được không?
*/
-- Không thực hiện được, do chưa gắn quyền Select cho các User

/*
5) Gán quyền select trên Employee cho User2, kiểm tra kết quả. Xóa quyền select
trên Employee cho User2. Ngắt 2 kết nối của User2 và User3
*/
GRANT SELECT ON HumanResources.Employee TO User2
--> Sau lệnh này thì User2 đã có quyền Select, User3 thì chưa

REVOKE SELECT ON HumanResources.Employee TO User2

/*
6) Trở lại kết nối của sa, tạo một user-defined database Role tên Employee_Role trên
CSDL AdventureWorks2008, sau đó gán các quyền Select, Update, Delete cho
Employee_Role.
*/
go
USE AdventureWorks2008R2
CREATE ROLE Employee_Role;
GO

GRANT SELECT, UPDATE, DELETE TO Employee_Role


/*
7) Thêm các User2 và User3 vào Employee_Role. Tạo lại 2 kết nối đến server thông
qua login User2 và User3 thực hiện các thao tác sau:
*/
go
sp_addrolemember 'Employee_Role', User2
sp_addrolemember 'Employee_Role', User3
GO

/*
a) Tại kết nối với User2, thực hiện câu lệnh Select để xem thông tin của bảng
Employee
*/
SELECT * FROM [HumanResources].[Employee]
--> Thực hiện thành công do đã cấp quyền cho User2

/*
b) Tại kết nối của User3, thực hiện cập nhật JobTitle=’Sale Manager’ của nhân
viên có BusinessEntityID=1
*/
UPDATE [HumanResources].[Employee]
SET JobTitle = 'Sale Manager'
WHERE BusinessEntityID = 1
--> Thực hiện thành công

/*
c) Tại kết nối User2, dùng câu lệnh Select xem lại kết quả.
*/
SELECT * FROM [HumanResources].[Employee]
--> Kết quả đã thay đổi do User3 đã cập nhật JobTitle cho nhân viên ID = 1

/*
d) Xóa role Employee_Role, (quá trình xóa role ra sao?)
*/
-- Ta phải xóa các member trong role trước khi xóa role
sp_droprolemember 'Employee_Role', User2
sp_droprolemember 'Employee_Role', User3

DROP ROLE Employee_Role