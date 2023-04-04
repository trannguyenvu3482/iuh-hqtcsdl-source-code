-- Lab 07: Sử dụng Trigger

/*
1. Tạo một Instead of trigger thực hiện trên view. Thực hiện theo các bước sau:
- Tạo mới 2 bảng M_Employees và M_Department theo cấu trúc sau:
- Tạo một view tên EmpDepart_View bao gồm các field: EmployeeID, FirstName, MiddleName, LastName, DepartmentID, Name, GroupName, dựa
trên 2 bảng M_Employees và M_Department.
- Tạo một trigger tên InsteadOf_Trigger thực hiện trên view EmpDepart_View, dùng để chèn dữ liệu vào các bảng M_Employees và
M_Department khi chèn một record mới thông qua view EmpDepart_View.
*/

CREATE TABLE M_Department (DepartmentID INT NOT NULL PRIMARY KEY,
Name NVARCHAR(50),
GroupName NVARCHAR(50));
CREATE TABLE M_Employees (EmployeeID INT NOT NULL PRIMARY KEY,
Firstname NVARCHAR(50),
MiddleName NVARCHAR(50),
LastName NVARCHAR(50),
DepartmentID INT FOREIGN KEY REFERENCES M_Department(DepartmentID));
GO
CREATE VIEW EmpDepart_View
--WITH ENCRYPTION, SCHEMABINDING, VIEW_METADATA
AS
SELECT e.EmployeeID, e.Firstname, e.MiddleName, e.LastName, d.DepartmentID, d.Name, d.GroupName
FROM dbo.M_Department d
     INNER JOIN dbo.M_Employees e ON e.DepartmentID=d.DepartmentID;
-- WITH CHECK OPTION
GO
GO
CREATE TRIGGER InsteadOf_Trigger
ON dbo.EmpDepart_View
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (SELECT * FROM Inserted)BEGIN
        INSERT dbo.M_Department(DepartmentID, Name, GroupName)
        SELECT [DepartmentID], [Name], [GroupName] FROM inserted;
        INSERT dbo.M_Employees(EmployeeID, Firstname, MiddleName, LastName, DepartmentID)
        SELECT Inserted.EmployeeID, Inserted.Firstname, Inserted.MiddleName, Inserted.LastName, Inserted.DepartmentID
        FROM Inserted;
    END;
END;
GO
GO
INSERT dbo.EmpDepart_View(EmployeeID, Firstname, MiddleName, LastName, DepartmentID, Name, GroupName)
VALUES(1, -- EmployeeID - int
N'Nguyen', -- Firstname - nvarchar(50)
N'Hoang', -- MiddleName - nvarchar(50)
N'Huy', -- LastName - nvarchar(50)
11  , -- DepartmentID - int
N'Marketing', -- Name - nvarchar(50)
N'Sales' -- GroupName - nvarchar(50)
    );
GO
INSERT dbo.EmpDepart_View(EmployeeID, Firstname, MiddleName, LastName, DepartmentID, Name, GroupName)
VALUES(2, -- EmployeeID - int
N'Tran', -- Firstname - nvarchar(50)
N'Nguyen', -- MiddleName - nvarchar(50)
N'Vu', -- LastName - nvarchar(50)
11  , -- DepartmentID - int
N'Development', -- Name - nvarchar(50)
N'IT' -- GroupName - nvarchar(50)
    );
SELECT * FROM [dbo].[M_Department];
SELECT * FROM [dbo].[M_Employees];
GO
--------------------------------------------------------------------------------------------------
/*
2. Tạo một trigger thực hiện trên bảng MySalesOrders có chức năng thiết lập độ ưu
tiên của khách hàng (CustPriority) khi người dùng thực hiện các thao tác Insert,
Update và Delete trên bảng MySalesOrders theo điều kiện như sau:
- Nếu tổng tiền Sum(SubTotal) của khách hàng dưới 10,000 $ thì độ ưu tiên của
khách hàng (CustPriority) là 3
- Nếu tổng tiền Sum(SubTotal) của khách hàng từ 10,000 $ đến dưới 50000 $
thì độ ưu tiên của khách hàng (CustPriority) là 2
- Nếu tổng tiền Sum(SubTotal) của khách hàng từ 50000 $ trở lên thì độ ưu tiên
của khách hàng (CustPriority) là 1
*/
GO
CREATE TABLE MCustomer (CustomerID INT NOT NULL PRIMARY KEY, CustPriority INT);
CREATE TABLE MSalesOrders (SalesOrderID INT NOT NULL PRIMARY KEY,
OrderDate DATE,
SubTotal MONEY,
CustomerID INT FOREIGN KEY REFERENCES MCustomer(CustomerID));
GO
INSERT INTO dbo.MCustomer(CustomerID, CustPriority)
VALUES(30115, -- CustomerID - int
NULL -- CustPriority - int
    );
INSERT INTO dbo.MSalesOrders(SalesOrderID, OrderDate, SubTotal, CustomerID)
VALUES(46935, -- SalesOrderID - int
'2006-08-01 00:00:00.000', -- OrderDate - date
688 , -- SubTotal - money
30115 -- CustomerID - int
    );
INSERT INTO dbo.MSalesOrders(SalesOrderID, OrderDate, SubTotal, CustomerID)
VALUES(47964, -- SalesOrderID - int
'2006-11-01 00:00:00.000', -- OrderDate - date
2618, -- SubTotal - money
30115 -- CustomerID - int
    );
GO
CREATE TRIGGER bai2_Trigger
ON dbo.MSalesOrders
FOR DELETE, INSERT, UPDATE
AS
BEGIN
    IF EXISTS (SELECT * FROM Inserted)BEGIN
        DECLARE @CustomerID INT, @SubTotal MONEY;
        SELECT @CustomerID=Inserted.CustomerID, @SubTotal=Inserted.SubTotal
        FROM Inserted;
        UPDATE dbo.MCustomer
        SET CustPriority=CASE WHEN @SubTotal<10000 THEN 3
                         WHEN @SubTotal<50000 THEN 2
                         WHEN @SubTotal>50000 THEN 1 ELSE 0 END
        WHERE CustomerID=@CustomerID;
    END;
    ELSE IF EXISTS (SELECT * FROM Deleted)BEGIN
             SELECT @CustomerID=Deleted.CustomerID FROM Deleted;
             UPDATE dbo.MCustomer SET CustPriority=NULL WHERE CustomerID=@CustomerID;
    END;
END;
GO

INSERT INTO dbo.MSalesOrders(SalesOrderID, OrderDate, SubTotal, CustomerID)
VALUES(69469, -- SalesOrderID - int
'2008-05-01 00:00:00.000', -- OrderDate - date
16000, -- SubTotal - money
30115   -- CustomerID - int
    )

SELECT * FROM dbo.MSalesOrders
SELECT * FROM dbo.MCustomer

------------------------------------------------------------------------------------------------
/*
3. Viết một trigger thực hiện trên bảng MEmployees sao cho khi người dùng thực
hiện chèn thêm một nhân viên mới vào bảng MEmployees thì chương trình cập
nhật số nhân viên trong cột NumOfEmployee của bảng MDepartment. Nếu tổng
số nhân viên của phòng tương ứng <=200 thì cho phép chèn thêm, ngược lại thì
hiển thị thông báo “Bộ phận đã đủ nhân viên” và hủy giao tác. Các bước thực hiện:
- Tạo mới 2 bảng MEmployees và MDepartment theo cấu trúc sau:
*/
go
create table MDepartment
(
DepartmentID int not null primary key,
Name nvarchar(50),
NumOfEmployee int
)
create table MEmployees
(
EmployeeID int not null,
FirstName nvarchar(50),
MiddleName nvarchar(50),
LastName nvarchar(50),
DepartmentID int foreign key references MDepartment(DepartmentID),
constraint pk_emp_depart primary key(EmployeeID, DepartmentID)
)
GO

INSERT dbo.MDepartment(DepartmentID, Name)
SELECT DepartmentID, Name
FROM HumanResources.Department
------------------------------------------------------------------------------------------------
/*
6. Tạo trigger cập nhật tiền thưởng (Bonus) cho nhân viên bán hàng SalesPerson, khi
người dùng chèn thêm một record mới trên bảng SalesOrderHeader, theo quy định
như sau: Nếu tổng tiền bán được của nhân viên có hóa đơn mới nhập vào bảng
SalesOrderHeader có giá trị >10000000 thì tăng tiền thưởng lên 10% của mức
thưởng hiện tại. 
*/
go
CREATE table M_SalesPerson
(
SalePSID int not null primary key,
TerritoryID int,
BonusPS money
)
create table M_SalesOrderHeader
(
SalesOrdID int not null primary key,
OrderDate date,
SubTotalOrd money,
SalePSID int foreign key references M_SalesPerson(SalePSID)
)
GO

INSERT dbo.M_SalesPerson(SalePSID, TerritoryID, BonusPS)
SELECT BusinessEntityID, TerritoryID, Bonus
FROM Sales.SalesPerson

INSERT dbo.M_SalesOrderHeader(SalesOrdID, OrderDate, SubTotalOrd, SalePSID)
SELECT SalesOrderID, OrderDate, SubTotal, SalesPersonID
FROM Sales.SalesOrderHeader

go
CREATE TRIGGER cau6_Trigger
    ON dbo.M_SalesOrderHeader
    FOR INSERT
    AS
    BEGIN
		IF EXISTS (SELECT * FROM Inserted)
		BEGIN
			DECLARE @SubTotal MONEY, @SalesPersonID INT
			
			SELECT @SalesPersonID = Inserted.SalePSID
			FROM Inserted

			SELECT @SubTotal = SUM(SubTotal)
			FROM Sales.SalesOrderHeader
			WHERE SalesPersonID = @SalesPersonID
			GROUP BY SalesPersonID

			IF (@SubTotal > 10000000)
				BEGIN
				    UPDATE dbo.M_SalesPerson
					SET BonusPS = BonusPS * 1.1
					WHERE SalePSID = @SalesPersonID
				END
		END
        
	END
GO

-- Dữ liệu Test
INSERT dbo.M_SalesOrderHeader(SalesOrdID, OrderDate, SubTotalOrd, SalePSID)
VALUES(98765, -- SalesOrdID - int
'2005-07-01', -- OrderDate - date
15000000, -- SubTotalOrd - money
276   -- SalePSID - int
    )

SELECT * FROM dbo.M_SalesOrderHeader
SELECT * FROM dbo.M_SalesPerson