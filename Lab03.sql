-- Module 3: View

/*
1) Tạo view dbo.vw_Products hiển thị danh sách các sản phẩm từ bảng
Production.Product và bảng Production.ProductCostHistory. Thông tin bao gồm
ProductID, Name, Color, Size, Style, StandardCost, EndDate, StartDate
*/
CREATE VIEW dbo.vw_Products
AS
SELECT p.ProductID, p.Name, p.Color, p.Size, p.Style, p.StandardCost, pch.EndDate, pch.StartDate
FROM Production.Product p
     INNER JOIN Production.ProductCostHistory pch ON pch.ProductID=p.ProductID;
GO

/*
2) Tạo view List_Product_View chứa danh sách các sản phẩm có trên 500 đơn đặt
hàng trong quí 1 năm 2008 và có tổng trị giá >10000, thông tin gồm ProductID,
Product_Name, CountOfOrderID và SubTotal.
*/
CREATE VIEW dbo.vw_List_Product_View
AS
SELECT sod.ProductID, p.Name, COUNT(sod.SalesOrderID) CountOfOrderID, SUM(sod.LineTotal) SubTotal
FROM Sales.SalesOrderHeader soh
     INNER JOIN Sales.SalesOrderDetail sod ON sod.SalesOrderID=soh.SalesOrderID
     INNER JOIN Production.Product p ON p.ProductID=sod.ProductID
WHERE DATEPART(QUARTER, soh.OrderDate)=1 AND YEAR(soh.OrderDate)=2008
GROUP BY sod.ProductID, p.Name
HAVING SUM(sod.UnitPrice * sod.OrderQty)>10000 AND COUNT(sod.SalesOrderID) > 500;
GO

/*
3) Tạo view dbo.vw_CustomerTotals hiển thị tổng tiền bán được (total sales) từ cột
TotalDue của mỗi khách hàng (customer) theo tháng và theo năm. Thông tin gồm
CustomerID, YEAR(OrderDate) AS OrderYear, MONTH(OrderDate) AS
OrderMonth, SUM(TotalDue).
*/
CREATE VIEW dbo.vw_CustomerTotals
AS
SELECT c.CustomerID, YEAR(soh.OrderDate) OrderYear, MONTH(soh.OrderDate) OrderMonth, SUM(soh.TotalDue) SumOfTotalDue
FROM Sales.SalesOrderHeader soh
     INNER JOIN Sales.Customer c ON c.CustomerID= soh.CustomerID
GROUP BY MONTH(soh.OrderDate), YEAR(soh.OrderDate), c.CustomerID;
GO

/*
4) Tạo view trả về tổng số lượng sản phẩm (Total Quantity) bán được của mỗi nhân
viên theo từng năm. Thông tin gồm SalesPersonID, OrderYear, sumOfOrderQty
*/
CREATE VIEW dbo.vw_EmpTotalQuantity
AS
SELECT soh.SalesPersonID, YEAR(soh.OrderDate) OrderYear, SUM(sod.OrderQty) AS 'SumOfOrderQty'
FROM Sales.SalesOrderHeader soh
     INNER JOIN Sales.SalesOrderDetail sod ON sod.SalesOrderID=soh.SalesOrderID
GROUP BY soh.SalesPersonID, YEAR(soh.OrderDate);
GO

/*
5) Tạo view ListCustomer_view chứa danh sách các khách hàng có trên 25 hóa đơn
đặt hàng từ năm 2007 đến 2008, thông tin gồm mã khách (PersonID) , họ tên
(FirstName +' '+ LastName as FullName), Số hóa đơn (CountOfOrders).
*/
CREATE VIEW dbo.ListCustomer_view
AS
SELECT c.PersonID, (p.FirstName+' '+p.LastName) FullName, COUNT(soh.SalesOrderID) CountOfOrders
FROM Sales.SalesOrderHeader soh
     INNER JOIN Sales.Customer c ON c.CustomerID=soh.CustomerID
     INNER JOIN Person.Person p ON p.BusinessEntityID=c.PersonID
WHERE YEAR(soh.OrderDate)=2007 OR YEAR(soh.OrderDate)=2008
GROUP BY c.PersonID, (p.FirstName+' '+p.LastName)
HAVING COUNT(soh.SalesOrderID)>25;
GO

/*
6) Tạo view ListProduct_view chứa danh sách những sản phẩm có tên bắt đầu với
‘Bike’ và ‘Sport’ có tổng số lượng bán trong mỗi năm trên 50 sản phẩm, thông
tin gồm ProductID, Name, SumOfOrderQty, Year. (dữ liệu lấy từ các bảng
Sales.SalesOrderHeader, Sales.SalesOrderDetail, và
Production.Product)
*/
CREATE VIEW dbo.ListProduct_view
AS
SELECT sod.ProductID, p.Name, SUM(sod.OrderQty) SumOfOrderQty, YEAR(soh.OrderDate) AS 'Year'
FROM Sales.SalesOrderHeader soh
     INNER JOIN Sales.SalesOrderDetail sod ON sod.SalesOrderID=soh.SalesOrderID
     INNER JOIN Production.Product p ON p.ProductID=sod.ProductID
WHERE p.Name LIKE 'Bike%' OR p.Name LIKE 'Sport%'
GROUP BY YEAR(soh.OrderDate), sod.ProductID, p.Name
HAVING SUM(sod.OrderQty)>50;
GO

/*
7) Tạo view List_department_View chứa danh sách các phòng ban có lương (Rate:
lương theo giờ) trung bình >30, thông tin gồm Mã phòng ban (DepartmentID),
tên phòng ban (Name), Lương trung bình (AvgOfRate). Dữ liệu từ các bảng
[HumanResources].[Department],
[HumanResources].[EmployeeDepartmentHistory],
[HumanResources].[EmployeePayHistory].
*/
CREATE VIEW dbo.List_department_View
AS
SELECT d.DepartmentID, d.Name, AVG(eph.Rate) AvgOfRate
FROM HumanResources.Department d
     INNER JOIN HumanResources.EmployeeDepartmentHistory edh ON edh.DepartmentID=d.DepartmentID
     INNER JOIN HumanResources.EmployeePayHistory eph ON eph.BusinessEntityID=edh.BusinessEntityID
	 GROUP BY d.DepartmentID, d.Name
	 HAVING AVG(eph.Rate) > 30
GO

/*
8) Tạo view Sales.vw_OrderSummary với từ khóa WITH ENCRYPTION gồm
OrderYear (năm của ngày lập), OrderMonth (tháng của ngày lập), OrderTotal
(tổng tiền). Sau đó xem thông tin và trợ giúp về mã lệnh của view này
*/
CREATE VIEW Sales.vw_OrderSummary
WITH ENCRYPTION
AS
  SELECT YEAR(OrderDate) OrderYear, MONTH(OrderDate) OrderMonth, SubTotal OrderTotal
  FROM Sales.SalesOrderHeader
  GROUP BY YEAR(OrderDate), MONTH(OrderDate), SubTotal
GO

sp_helptext	'Sales.vw_OrderSummary';
/*
9) Tạo view Production.vwProducts với từ khóa WITH SCHEMABINDING
gồm ProductID, Name, StartDate,EndDate,ListPrice của bảng Product và bảng
ProductCostHistory. Xem thông tin của View. Xóa cột ListPrice của bảng
Product. Có xóa được không? Vì sao?
*/
CREATE VIEW Production.vw_Products
WITH SCHEMABINDING
AS
  SELECT p.ProductID, p.Name, pch.StartDate, pch.EndDate, p.ListPrice
  FROM Production.Product p INNER JOIN Production.ProductCostHistory pch ON pch.ProductID = p.ProductID
GO

/*
10) Tạo view view_Department với từ khóa WITH CHECK OPTION chỉ chứa các
phòng thuộc nhóm có tên (GroupName) là “Manufacturing” và “Quality
Assurance”, thông tin gồm: DepartmentID, Name, GroupName.
*/
CREATE VIEW dbo.view_Department
AS
    SELECT d.DepartmentID, d.Name, d.GroupName
    FROM HumanResources.Department d
	WHERE d.GroupName IN ('Manufacturing', 'Quality Assurance')
	WITH CHECK OPTION
GO

-- a. Chèn thêm một phòng ban mới thuộc nhóm không thuộc hai nhóm
-- “Manufacturing” và “Quality Assurance” thông qua view vừa tạo. Có
-- chèn được không? Giải thích.

-- b. Chèn thêm một phòng mới thuộc nhóm “Manufacturing” và một
-- phòng thuộc nhóm “Quality Assurance”.

-- c. Dùng câu lệnh Select xem kết quả trong bảng Department.