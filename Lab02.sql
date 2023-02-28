-- Lab 02

/*
1) Liệt kê danh sách các hóa đơn (SalesOrderID) lập trong tháng 6 năm 2008 có
tổng tiền >70000, thông tin gồm SalesOrderID, Orderdate, SubTotal, trong đó
SubTotal =SUM(OrderQty*UnitPrice).
*/
SELECT sod.SalesOrderID, soh.OrderDate, SUM(sod.OrderQty * sod.UnitPrice) AS 'SubTotal'
FROM Sales.SalesOrderHeader soh
     INNER JOIN Sales.SalesOrderDetail sod ON sod.SalesOrderID=soh.SalesOrderID
WHERE MONTH(soh.OrderDate)=6 AND YEAR(soh.OrderDate)=2008
GROUP BY sod.SalesOrderID, soh.OrderDate
HAVING SUM(sod.OrderQty * sod.UnitPrice)>70000;

/*
2) Đếm tổng số khách hàng và tổng tiền của những khách hàng thuộc các quốc gia
có mã vùng là US (lấy thông tin từ các bảng Sales.SalesTerritory,
Sales.Customer, Sales.SalesOrderHeader, Sales.SalesOrderDetail). Thông tin
bao gồm TerritoryID, tổng số khách hàng (CountOfCust), tổng tiền
(SubTotal) với SubTotal = SUM(OrderQty*UnitPrice)
*/
SELECT c.TerritoryID, COUNT(c.CustomerID) AS 'CountOfCust', SUM(sod.OrderQty * sod.UnitPrice) AS 'SubTotal'
FROM Sales.SalesOrderHeader soh
     INNER JOIN Sales.SalesOrderDetail sod ON sod.SalesOrderID=soh.SalesOrderID
     INNER JOIN Sales.Customer c ON c.CustomerID=soh.CustomerID
     INNER JOIN Sales.SalesTerritory st ON st.TerritoryID=c.TerritoryID
WHERE st.CountryRegionCode='US'
GROUP BY c.TerritoryID;

/*
3) Tính tổng trị giá của những hóa đơn với Mã theo dõi giao hàng
(CarrierTrackingNumber) có 3 ký tự đầu là 4BD, thông tin bao gồm
SalesOrderID, CarrierTrackingNumber, SubTotal=SUM(OrderQty*UnitPrice)
*/
SELECT sod.SalesOrderID, sod.CarrierTrackingNumber, SUM(sod.OrderQty * sod.UnitPrice) AS 'SubTotal'
FROM Sales.SalesOrderDetail sod
     INNER JOIN Sales.SalesOrderHeader soh ON soh.SalesOrderID=sod.SalesOrderID
WHERE sod.CarrierTrackingNumber LIKE '4BD%'
GROUP BY sod.SalesOrderID, sod.CarrierTrackingNumber;

/*
4) Liệt kê các sản phẩm (Product) có đơn giá (UnitPrice)<25 và số lượng bán
trung bình >5, thông tin gồm ProductID, Name, AverageOfQty.
*/
SELECT p.ProductID, p.Name, AVG(sod.OrderQty) AS 'AverageOfQty'
FROM Production.Product p
     INNER JOIN Sales.SalesOrderDetail sod ON sod.ProductID=p.ProductID
WHERE sod.UnitPrice<25
GROUP BY p.ProductID, p.Name
HAVING AVG(sod.OrderQty)>5;

/*
5) Liệt kê các công việc (JobTitle) có tổng số nhân viên >20 người, thông tin gồm
JobTitle, CountOfPerson=Count(*)
*/
SELECT JobTitle, COUNT(*) AS 'CountOfPerson'
FROM HumanResources.Employee
GROUP BY JobTitle
HAVING COUNT(*)>20;

/*
6) Tính tổng số lượng và tổng trị giá của các sản phẩm do các nhà cung cấp có tên
kết thúc bằng ‘Bicycles’ và tổng trị giá > 800000, thông tin gồm
BusinessEntityID, Vendor_Name, ProductID, SumOfQty, SubTotal
(sử dụng các bảng [Purchasing].[Vendor], [Purchasing].[PurchaseOrderHeader] và
[Purchasing].[PurchaseOrderDetail])
*/
SELECT v.BusinessEntityID, v.Name AS 'Vendor_Name', pod.ProductID, SUM(pod.OrderQty) AS 'SumOfQty', SUM(pod.OrderQty * pod.UnitPrice) AS 'SubTotal'
FROM Purchasing.Vendor v
     INNER JOIN Purchasing.PurchaseOrderHeader poh ON poh.VendorID=v.BusinessEntityID
     INNER JOIN Purchasing.PurchaseOrderDetail pod ON pod.PurchaseOrderID=poh.PurchaseOrderID
WHERE v.Name LIKE '%Bicycles'
GROUP BY v.BusinessEntityID, v.Name, pod.ProductID
HAVING SUM(pod.OrderQty * pod.UnitPrice)>800000;

/*
7) Liệt kê các sản phẩm có trên 500 đơn đặt hàng trong quí 1 năm 2008 và có tổng
trị giá >10000, thông tin gồm ProductID, Product_Name, CountOfOrderID và
SubTotal
*/
SELECT pod.ProductID, p.Name AS 'Product_Name', COUNT(pod.PurchaseOrderID) AS 'CountOfOrderID', SUM(pod.OrderQty * pod.UnitPrice) AS 'SubTotal'
FROM Purchasing.PurchaseOrderDetail pod
     INNER JOIN Purchasing.PurchaseOrderHeader poh ON poh.PurchaseOrderID=pod.PurchaseOrderID
     INNER JOIN Production.Product p ON p.ProductID=pod.ProductID
WHERE DATEPART(qq, poh.OrderDate)=1 AND YEAR(poh.OrderDate)=2008
GROUP BY pod.ProductID, p.Name
HAVING SUM(pod.OrderQty * pod.UnitPrice)>10000 AND COUNT(pod.PurchaseOrderID)>500;

/*
8) Liệt kê danh sách các khách hàng có trên 25 hóa đơn đặt hàng từ năm 2007 đến
2008, thông tin gồm mã khách (PersonID) , họ tên (FirstName +' '+ LastName
as FullName), Số hóa đơn (CountOfOrders).
*/
SELECT c.PersonID, (p.FirstName+' '+p.LastName) AS 'FullName', COUNT(*) AS 'CountOfOrders'
FROM Sales.SalesOrderHeader soh
     INNER JOIN Sales.Customer c ON c.CustomerID=soh.CustomerID
     INNER JOIN Person.Person p ON p.BusinessEntityID=c.PersonID
WHERE YEAR(soh.OrderDate)=2007 OR YEAR(soh.OrderDate)=2008
GROUP BY c.PersonID, (p.FirstName+' '+p.LastName)
HAVING COUNT(*)>25;

/*
9) Liệt kê những sản phẩm có tên bắt đầu với ‘Bike’ và ‘Sport’ có tổng số lượng
bán trong mỗi năm trên 500 sản phẩm, thông tin gồm ProductID, Name,
CountOfOrderQty, Year. (Dữ liệu lấy từ các bảng Sales.SalesOrderHeader,
Sales.SalesOrderDetail và Production.Product)
*/
SELECT p.ProductID, p.Name, COUNT(sod.OrderQty) AS 'CountOfOrderQty', YEAR(soh.OrderDate) AS 'Year'
FROM Sales.SalesOrderHeader soh
     INNER JOIN Sales.SalesOrderDetail sod ON sod.SalesOrderID=soh.SalesOrderID
     INNER JOIN Production.Product p ON p.ProductID=sod.ProductID
WHERE p.Name LIKE 'Bike%' OR p.Name LIKE 'Sport%'
GROUP BY YEAR(soh.OrderDate), p.ProductID, p.Name
HAVING COUNT(sod.OrderQty)>500;

/*
10)Liệt kê những phòng ban có lương (Rate: lương theo giờ) trung bình >30, thông
tin gồm Mã phòng ban (DepartmentID), tên phòng ban (Name), Lương trung
bình (AvgofRate). Dữ liệu từ các bảng
[HumanResources].[Department],
[HumanResources].[EmployeeDepartmentHistory],
[HumanResources].[EmployeePayHistory]
*/
SELECT *
FROM HumanResources.Department d
     INNER JOIN HumanResources.EmployeeDepartmentHistory edh ON edh.DepartmentID=d.DepartmentID
     INNER JOIN HumanResources.EmployeePayHistory eph ON eph.BusinessEntityID=edh.BusinessEntityID;

-- II) Subquery
/*
1) Liệt kê các sản phẩm gồm các thông tin Product Names và Product ID có
trên 100 đơn đặt hàng trong tháng 7 năm 2008
*/
SELECT p.ProductID, p.Name
FROM Production.Product p
WHERE p.ProductID IN (SELECT sod.ProductID
                     FROM Sales.SalesOrderDetail sod
                          INNER JOIN Sales.SalesOrderHeader soh ON soh.SalesOrderID=sod.SalesOrderID
                     WHERE MONTH(soh.OrderDate)=7 AND YEAR(soh.OrderDate)=2008
                     GROUP BY sod.ProductID
                     HAVING SUM(sod.OrderQty)>100)
GROUP BY p.Name, p.ProductID;

/*
2) Liệt kê các sản phẩm (ProductID, Name) có số hóa đơn đặt hàng nhiều nhất
trong tháng 7/2008
*/
SELECT p.ProductID, p.Name
FROM Production.Product p
     INNER JOIN Sales.SalesOrderDetail sod ON sod.ProductID=p.ProductID
     INNER JOIN Sales.SalesOrderHeader soh ON soh.SalesOrderID=sod.SalesOrderID
WHERE sod.OrderQty>(SELECT SUM(sod.OrderQty)
                    FROM Sales.SalesOrderHeader soh
                         INNER JOIN Sales.SalesOrderDetail sod ON sod.SalesOrderID=soh.SalesOrderID
                    WHERE MONTH(soh.OrderDate)=7 AND YEAR(soh.OrderDate)=2008
                    GROUP BY sod.ProductID);

/*
3) Hiển thị thông tin của khách hàng có số đơn đặt hàng nhiều nhất, thông tin gồm:
CustomerID, Name, CountOfOrder
*/

SELECT TOP 1 Customer.CustomerID, p.FirstName + ' ' + p.LastName AS 'Name', COUNT(*) AS 'CountOfOrder' 
FROM Sales.SalesOrderHeader soh
	INNER JOIN Sales.Customer ON Customer.CustomerID = soh.CustomerID
	INNER JOIN Person.Person p ON p.BusinessEntityID = Customer.PersonID
GROUP BY Customer.CustomerID, p.FirstName + ' ' + p.LastName 
ORDER BY CountOfOrder DESC

/*
4) Liệt kê các sản phẩm (ProductID, Name) thuộc mô hình sản phẩm áo dài tay với
tên bắt đầu với “Long-Sleeve Logo Jersey”, dùng phép IN và EXISTS, (sử dụng
bảng Production.Product và Production.ProductModel)
*/
SELECT
FROM
WHERE
GROUP BY

/*
5) Tìm các mô hình sản phẩm (ProductModelID) mà giá niêm yết (list price) tối
đa cao hơn giá trung bình của tất cả các mô hình.
*/

/*
6) Liệt kê các sản phẩm gồm các thông tin ProductID, Name, có tổng số lượng
đặt hàng > 5000 (dùng IN, EXISTS)
*/

/*
7) Liệt kê những sản phẩm (ProductID, UnitPrice) có đơn giá (UnitPrice) cao
nhất trong bảng Sales.SalesOrderDetail
*/

/*
8) Liệt kê các sản phẩm không có đơn đặt hàng nào thông tin gồm ProductID,
Nam; dùng 3 cách Not in, Not exists và Left join.
*/

/*
9) Liệt kê các nhân viên không lập hóa đơn từ sau ngày 1/5/2008, thông tin gồm
EmployeeID, FirstName, LastName (dữ liệu từ 2 bảng
HumanResources.Employees và Sales.SalesOrdersHeader)
*/

/*
10)Liệt kê danh sách các khách hàng (CustomerID, Name) có hóa đơn dặt hàng
trong năm 2007 nhưng không có hóa đơn đặt hàng trong năm 2008
*/