-- Lab 05: Stored Procedure
-- II) Stored Procedure:
 /*
1) Viết một thủ tục tính tổng tiền thu (TotalDue) của mỗi khách hàng trong một
tháng bất kỳ của một năm bất kỳ (tham số tháng và năm) được nhập từ bàn phím,
thông tin gồm: CustomerID, SumofTotalDue =Sum(TotalDue)
*/
CREATE PROCEDURE TotalDue @month int, @year int AS
SELECT CustomerID,
       TotalDue
FROM Sales.SalesOrderHeader
WHERE MONTH(OrderDate) = @month
  AND YEAR(OrderDate) = @year EXEC TotalDue @month = 7,
                                            @year = 2005
/*
2) Viết một thủ tục dùng để xem doanh thu từ đầu năm cho đến ngày hiện tại của
một nhân viên bất kỳ, với một tham số đầu vào và một tham số đầu ra. Tham số
@SalesPerson nhận giá trị đầu vào theo chỉ định khi gọi thủ tục, tham số
@SalesYTD được sử dụng để chứa giá trị trả về của thủ tục
*/
GO
  CREATE PROCEDURE totalSalesEmployee @SalesPerson int, @SalesYTD MONEY OUTPUT AS
  SELECT @SalesYTD =
    (SELECT SalesYTD
     FROM Sales.SalesPerson
     WHERE BusinessEntityID = @SalesPerson);

-- Thực thi
DECLARE @SalesOutput MONEY EXEC totalSalesEmployee @SalesPerson = 274,
                                                   @SalesYTD = @SalesOutput OUTPUT;


SELECT @SalesOutput AS N'Doanh thu từ đầu năm đến hiện tại' 

/*
3) Viết một thủ tục trả về một danh sách các sản phẩm có giá không vượt quá một
giá trị được chỉ định, với tham số input @Product và @MaxPrice, tham số
output là ListPrice
*/ 
GO
CREATE PROCEDURE productsPriceLimit @Product int, @MaxPrice MONEY,
                                                            @ListPrice MONEY OUTPUT AS
SELECT @ListPrice =
  (SELECT ListPrice
   FROM Production.Product
   WHERE ProductID = @Product
     AND ListPrice < @MaxPrice) -- Thực thi
DECLARE @ListPriceOutput MONEY EXEC productsPriceLimit @Product = 907,
                                                       @MaxPrice = 600,
                                                       @ListPrice = @ListPriceOutput OUTPUT
SELECT @ListPriceOutput AS N'Danh sách các sản phẩm'

/*
4) Viết thủ tục tên NewBonus cập nhật lại tiền thưởng (Bonus) cho nhân viên bán
hàng (SalesPerson), dựa trên tổng doanh thu của mỗi nhân viên, mức thưởng mới
bằng mức thưởng hiện tại tăng thêm 1% tổng doanh thu, thông tin bao gồm
[SalesPersonID], NewBonus (thưởng mới), sumofSubTotal. Trong đó:
SumofSubTotal =sum(SubTotal)
NewBonus = Bonus+ sum(SubTotal)*0.01
*/
GO
CREATE PROCEDURE NewBonus @SalesPersonID int AS
SELECT sp.BusinessEntityID,
       NewBonus = (Bonus + SUM(soh.SubTotal) * 0.01),
       sumOfSubTotal = SUM(soh.SubTotal)
FROM Sales.SalesPerson sp
INNER JOIN Sales.SalesOrderHeader soh ON sp.BusinessEntityID = soh.SalesPersonID
WHERE sp.BusinessEntityID = @SalesPersonID
GROUP BY sp.BusinessEntityID, Bonus 

-- Thuc thi
EXEC NewBonus @SalesPersonID = 275

/*
5) Viết một thủ tục dùng để xem thông tin của nhóm sản phẩm (ProductCategory)
có tổng số lượng (OrderQty) đặt hàng cao nhất trong một năm tùy ý (tham số
input), thông tin gồm: ProductCategoryID, Name, SumofQty. Dữ liệu từ bảng
ProductCategory, ProductSubcategory, Product và SalesOrderDetail (Lưu ý:
dùng subquery)
*/
GO
CREATE PROCEDURE highestOrderProductCategory @year int AS

/*
6) Tạo thủ tục đặt tên là TongThu có tham số vào là mã nhân viên, tham số đầu ra
là tổng trị giá các hóa đơn nhân viên đó bán được. Sử dụng lệnh RETURN để trả
về trạng thái thành công hay thất bại của thủ tục.
*/
GO
CREATE PROCEDURE TongThu @SalesPersonID int AS RETURN
  (SELECT SUM(TotalDue)
   FROM Sales.SalesOrderHeader
   WHERE SalesPersonID = @SalesPersonID)

-- Thuc thi
EXEC TongThu @SalesPersonID = 279;

/*
7) Tạo thủ tục hiển thị tên và số tiền mua của cửa hàng mua nhiều hàng nhất theo
năm đã cho.
*/
GO
CREATE PROCEDURE showNameTotalDue @year INT AS
SELECT TOP 1 s.Name,
           SumOfTotalDue = SUM(soh.TotalDue)
FROM Sales.SalesOrderHeader soh
INNER JOIN Sales.Customer c ON soh.CustomerID = c.CustomerID
INNER JOIN Sales.Store s ON c.StoreID = s.BusinessEntityID
WHERE YEAR(soh.OrderDate) = @year
GROUP BY s.Name,
         soh.TotalDue
ORDER BY soh.TotalDue DESC -- Thuc thi
EXEC showNameTotalDue @year = 2007

/*
8) Viết thủ tục Sp_InsertProduct có tham số dạng input dùng để chèn một mẫu tin
vào bảng Production.Product. Yêu cầu: chỉ thêm vào các trường có giá trị not
null và các field là khóa ngoại.
*/
GO
CREATE PROCEDURE Sp_InsertProduct AS
INSERT Production.Product([Name], [ProductNumber], [SafetyStockLevel], [ReorderPoint], [StandardCost], [ListPrice], [DaysToManufacture], [SellStartDate])
VALUES ('Adjustable Race 999', 'AR-5399', 1000, 750, 0, 0, 1, '2007-07-01 00:00:00.000')

-- Thuc thi
EXEC Sp_InsertProduct

/*
9) Viết thủ tục XoaHD, dùng để xóa 1 hóa đơn trong bảng Sales.SalesOrderHeader
khi biết SalesOrderID. Lưu ý trước khi xóa mẫu tin trong
Sales.SalesOrderHeader thì phải xóa các mẫu tin của hoá đơn đó trong
Sales.SalesOrderDetail. Nếu không xoá được hoá đơn thì cũng không được phép
xóa Sales.SalesOrderDetail của hóa đơn đó.
*/
go
CREATE PROCEDURE XoaHD
@SalesOrderID INT
as
delete from Sales.SalesOrderHeader
where SalesOrderID = @SalesOrderID

-- Thuc thi
exec XoaHD @SalesOrderID = 43659


/*
10)Viết thủ tục Sp_Update_Product có tham số ProductId dùng để tăng listprice lên
10% nếu sản phẩm này tồn tại, ngược lại hiện thông báo không có sản phẩm này.
*/
go
create procedure Sp_Update_Product
@ProductID int
as
update Production.Product
set ListPrice =
	if exists (select * from Production.Product where ProductID = @ProductID)
	begin
	end
	else 0

else print N'Sản phẩm không tồn tại'

-- Thực thi
exec Sp_Update_Product