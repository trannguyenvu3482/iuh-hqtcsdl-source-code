-- Lab 03: Bài tập về nhà

-- 1) Tạo hai bảng mới trong cơ sở dữ liệu AdventureWorks2008 theo cấu trúc sau:
CREATE TABLE dbo.MyDepartment (DepID SMALLINT NOT NULL PRIMARY KEY,
DepName NVARCHAR(50) NOT NULL,
GrpName NVARCHAR(50) NOT NULL);
CREATE TABLE MyEmployee (EmpID INT NOT NULL PRIMARY KEY,
FrstName NVARCHAR(50) NOT NULL,
MidName NVARCHAR(50) NOT NULL,
LstName NVARCHAR(50) NOT NULL,
DepID SMALLINT NOT NULL FOREIGN KEY REFERENCES MyDepartment(DepID));

/*
2) Dùng lệnh insert <TableName1> select <fieldList> from
<TableName2> chèn dữ liệu cho bảng MyDepartment, lấy dữ liệu từ
bảng [HumanResources].[Department].
*/
INSERT MyDepartment
SELECT [DepartmentID], [Name], [GroupName]
FROM [HumanResources].[Department];
SELECT * FROM MyDepartment;

/*
3) Tương tự câu 2, chèn 20 dòng dữ liệu cho bảng MyEmployee lấy dữ liệu
từ 2 bảng
[Person].[Person] và
[HumanResources].[EmployeeDepartmentHistory]
*/
INSERT MyEmployee
SELECT TOP 20 P.[BusinessEntityID], P.[FirstName], P.[MiddleName], P.[LastName], H.[DepartmentID]
FROM [HumanResources].[Employee] E
     JOIN [HumanResources].[EmployeeDepartmentHistory] H ON E.[BusinessEntityID]=H.[BusinessEntityID]
     JOIN [Person].[Person] P ON H.[BusinessEntityID]=P.[BusinessEntityID]
ORDER BY P.LastName;

/*
4) Dùng lệnh delete xóa 1 record trong bảng MyDepartment với DepID=1,
có thực hiện được không? Vì sao?
*/
SELECT * FROM MyDepartment WHERE DepID=1;
DELETE FROM MyDepartment WHERE DepID=1;
SELECT * FROM MyDepartment;

/*
5) Thêm một default constraint vào field DepID trong bảng MyEmployee,
với giá trị mặc định là 1.
*/
ALTER TABLE dbo.MyEmployee
ADD CONSTRAINT def_myEmployee DEFAULT 1 FOR DepID;

/*
6) Nhập thêm một record mới trong bảng MyEmployee, theo cú pháp sau:
insert into MyEmployee (EmpID, FrstName, MidName,
LstName) values(1, 'Nguyen','Nhat','Nam'). Quan sát giá trị
trong field depID của record mới thêm.
*/
insert into MyEmployee (EmpID, FrstName, MidName, LstName)
values(1, 'Nguyen','Nhat','Nam')

SELECT * from MyEmployee where EmpID = 31


/*
7) Xóa foreign key constraint trong bảng MyEmployee, thiết lập lại khóa ngoại
DepID tham chiếu đến DepID của bảng MyDepartment với thuộc tính on
delete set default.
*/

/*
8) Xóa một record trong bảng MyDepartment có DepID=7, quan sát kết quả
trong hai bảng MyEmployee và MyDepartment
*/

/*
9) Xóa foreign key trong bảng MyEmployee. Hiệu chỉnh ràng buộc khóa
ngoại DepID trong bảng MyEmployee, thiết lập thuộc tính on delete
cascade và on update cascade
*/

/*
10)Thực hiện xóa một record trong bảng MyDepartment với DepID =3, có
thực hiện được không?
*/

/*
11)Thêm ràng buộc check vào bảng MyDepartment tại field GrpName, chỉ cho
phép nhận thêm những Department thuộc group Manufacturing
*/

/*
12)Thêm ràng buộc check vào bảng [HumanResources].[Employee], tại cột
BirthDate, chỉ cho phép nhập thêm nhân viên mới có tuổi từ 18 đến 60
*/