-- Lab 06: Scalar Function

/*
1)	Viết hàm tên countofEmplyees (dạng scalar function) với tham số @mapb,
 giá trị truyền vào lấy từ field [DepartmentID], hàm trả về số nhân viên trong phòng ban tương ứng.
  Áp dụng hàm đã viết vào câu truy vấn liệt kê danh sách các phòng ban với số nhân viên của mỗi phòng ban,
   thông tin gồm: C countOfEmp với countOfEmp= CountOfEmplyees([DepartmentID]). 
(Dữ liệu lấy từ bảng 
[HumanResources].[EmployeeDepartmentHistory] và 
[HumanResources].[Department]) 
*/
CREATE FUNCTION countofEmplyees(@mapb INT)
RETURNS INT
AS BEGIN
    RETURN (SELECT COUNT(D.[DepartmentID])
            FROM [HumanResources].[Department] D
                 JOIN [HumanResources].[EmployeeDepartmentHistory] E ON D.[DepartmentID]=E.[DepartmentID]
            WHERE D.[DepartmentID]=@mapb);
END;
GO
SELECT * FROM countofEmplyees(12);
SELECT [DepartmentID] FROM [HumanResources].[Department];

/*
2)	Viết hàm tên là InventoryProd (dạng scalar function) với tham số vào là 
@ProductID và @locationID trả về số lượng tồn kho của sản phẩm trong khu vực tương ứng với giá trị của tham số 
(Dữ liệu lấy từ bảng[Production].[ProductInventory]) 
*/
GO
CREATE FUNCTION InventoryProd(@ProductID1 INT, @locationID1 SMALLINT, @soluongton1 SMALLINT)
RETURNS SMALLINT
AS BEGIN
    DECLARE @ProductID INT, @locationID AS SMALLINT, @soluongton AS SMALLINT;
    SELECT @soluongton=COUNT([Quantity])
    FROM [Production].[ProductInventory]
    WHERE [ProductID]=@ProductID AND [LocationID]=@locationID AND [Quantity]=@soluongton;
    RETURN @soluongton;
END;
GO

/*
3)	Viết hàm tên SubTotalOfEmp (dạng scalar function) trả về tổng doanh thu của một nhân viên trong một tháng tùy ý trong một năm tùy ý, với tham số vào 
@EmplID, @MonthOrder, @YearOrder 
(Thông tin lấy từ bảng [Sales].[SalesOrderHeader]) 
*/
GO
CREATE FUNCTION SubTotalOfEmp(@EmplID INT, @orderdate DATETIME, @tongluong MONEY)
RETURNS MONEY
AS BEGIN
    DECLARE @EmplID1 INT, @orderdate1 DATETIME, @tongluong1 MONEY;
    SELECT @tongluong1=COUNT([SubTotal])
    FROM [Sales].[SalesOrderHeader]
    WHERE [SalesOrderID]=@EmplID1 AND [OrderDate]=@orderdate1 AND [SubTotal]=@tongluong1;
    RETURN @tongluong;
END;
GO
SELECT * FROM [Sales].[SalesOrderHeader];
/*
4)	Viết hàm sumofOrder với hai tham số @thang và @nam trả về danh sách các hóa đơn (SalesOrderID) lập trong tháng và năm được truyền vào từ    2 tham số 
@thang và @nam, có tổng tiền >70000, thông tin gồm SalesOrderID, OrderDate, SubTotal, trong đó SubTotal =sum(OrderQty*UnitPrice). 
*/
GO
CREATE FUNCTION sumofOrder(@thang INT, @nam INT)
RETURNS TABLE
AS
RETURN(SELECT H.SalesOrderID, OrderDate, SubTotal=SUM(OrderQty * UnitPrice)
       FROM [Sales].[SalesOrderHeader] H
            JOIN [Sales].[SalesOrderDetail] D ON H.SalesOrderID=D.SalesOrderID
       WHERE YEAR(OrderDate)=@nam AND MONTH(OrderDate)=@thang
       GROUP BY H.SalesOrderID, OrderDate
       HAVING SUM(OrderQty * UnitPrice)>70000);
GO
SELECT * FROM sumofOrder(8, 2005);

/*
5)	Viết hàm tên NewBonus tính lại tiền thưởng (Bonus) cho nhân viên bán hàng (SalesPerson), 
dựa trên tổng doanh thu của mỗi nhân viên, 
mức thưởng mới bằng mức thưởng hiện tại tăng thêm 1% tổng doanh thu, thông tin bao gồm 
[SalesPersonID], NewBonus (thưởng mới), sumofSubTotal. Trong đó: 
SumofSubTotal =sum(SubTotal), 
NewBonus = Bonus+ sum(SubTotal)*0.01 
*/
GO
CREATE FUNCTION NewBonus5(@tienthuong MONEY)
RETURNS @bang TABLE(SalesPersonID INT, bonus MONEY, NewBonus MONEY, SumofSubTotal MONEY)
AS BEGIN
    INSERT @bang
    SELECT H.[SalesPersonID], Bonus AS OldBonus, NewBonus=P.Bonus+SUM(SubTotal)* 0.01, SumofSubTotal=SUM(SubTotal)
    FROM [Sales].[SalesPerson] P
         JOIN [Sales].[SalesOrderHeader] H ON P.[TerritoryID]=H.[TerritoryID]
         JOIN [Sales].[SalesOrderDetail] D ON H.[SalesOrderID]=D.[SalesOrderID]
    GROUP BY H.[SalesPersonID], Bonus;
    RETURN;
END;
GO
SELECT Bonus FROM [Sales].[SalesPerson];
SELECT * FROM NewBonus5(410000);

/*
6)	Viết hàm tên SumofProduct với tham số đầu vào là @MaNCC (VendorID),
 hàm dùng để tính tổng số lượng (sumOfQty) và tổng trị giá (SumofSubtotal) 
của các sản phẩm do nhà cung cấp @MaNCC cung cấp, thông tin gồm 
ProductID, SumofProduct, SumofSubtotal 
*/
GO
CREATE FUNCTION SumofProduct(@MaNCC INT)
RETURNS @bang TABLE(ProductID INT, SumofProduct INT, SumofSubtotal MONEY)
AS BEGIN
    INSERT @bang
    SELECT D.ProductID, SumofProduct=SUM(OrderQty), SumofSubtotal=SUM(H.SubTotal)
    FROM [Sales].[SalesOrderDetail] D
         JOIN [Sales].[SalesOrderHeader] H ON D.[SalesOrderID]=H.[SalesOrderID]
         JOIN [Purchasing].[ProductVendor] V ON D.[ProductID]=V.[ProductID]
    WHERE @MaNCC=[BusinessEntityID]
    GROUP BY D.ProductID;
    RETURN;
END;
GO
SELECT [BusinessEntityID] FROM [Purchasing].[ProductVendor];
SELECT [VendorID] FROM [Purchasing].[PurchaseOrderHeader];
SELECT * FROM SumofProduct(1492);

/*
7) Viết hàm tên Discount_Func tính số tiền giảm trên các hóa đơn (SalesOrderID),
 thông tin gồm SalesOrderID, [SubTotal], Discount, trong đó, Discount được tính như sau: 
Nếu [SubTotal]<1000 thì Discount=0  
Nếu 1000<=[SubTotal]<5000 thì Discount = 5%[SubTotal] 
Nếu 5000<=[SubTotal]<10000 thì Discount = 10%[SubTotal]  Nếu [SubTotal>=10000 thì Discount = 15%[SubTotal] 
Gợi ý: Sử dụng Case.. When … Then … 
(Sử dụng dữ liệu từ bảng [Sales].[SalesOrderHeader]) 
*/
GO
CREATE FUNCTION Discount_Func(@Discount MONEY)
RETURNS TABLE
AS
RETURN(SELECT SalesOrderID, [SubTotal]
       FROM [Sales].[SalesOrderHeader]
       WHERE @Discount=CASE WHEN [SubTotal]<1000 THEN 0
                       WHEN [SubTotal]>1000 AND [SubTotal]<5000 THEN [SubTotal] * 0.05
                       WHEN [SubTotal]>5000 AND [SubTotal]<10000 THEN [SubTotal] * 0.1
                       WHEN [SubTotal]>10000 THEN [SubTotal] * 0.15 END);
GO
SELECT * FROM Discount_Func(1);
SELECT SalesOrderID, SubTotal FROM [Sales].[SalesOrderHeader];

/*
8) Viết hàm TotalOfEmp với tham số @MonthOrder, @YearOrder để tính tổng doanh thu của các nhân viên bán hàng (SalePerson)
 trong tháng và năm được truyền và 2 tham số, thông tin gồm [SalesPersonID], Total, với Total=Sum([SubTotal]) 
 Multi statement Table Valued Functions: 
*/
GO
CREATE FUNCTION TotalOfEmp5(@MonthOrder INT, @YearOrder INT)
RETURNS @bang TABLE(SalesPersonID INT, total MONEY)
AS BEGIN
    INSERT @bang
    SELECT [SalesPersonID], Total=SUM([SubTotal])
    FROM [Sales].[SalesPerson] P
         JOIN [Sales].[SalesOrderHeader] H ON P.[TerritoryID]=H.[TerritoryID]
         JOIN [Sales].[SalesOrderDetail] D ON H.[SalesOrderID]=D.[SalesOrderID]
    WHERE @MonthOrder=MONTH(OrderDate)AND @YearOrder=YEAR(OrderDate)
    GROUP BY [SalesPersonID];
    RETURN;
END;
GO
SELECT * FROM TotalOfEmp5(7, 2005);
SELECT MONTH(OrderDate) AS ordermonth, YEAR(OrderDate) AS orderyear
FROM [Sales].[SalesOrderHeader];

/*
9)	Viết lại các câu 5,6,7,8 bằng Multi-statement table valued function 
*/

/*
10)	Viết hàm tên SalaryOfEmp trả về kết quả là bảng lương của nhân viên,
 với tham số vào là @MaNV (giá trị của [BusinessEntityID]), thông tin gồm BusinessEntityID, FName, LName, Salary (giá trị của cột Rate). 
Nếu giá trị của tham số truyền vào là Mã nhân viên khác Null thì kết quả là bảng lương của nhân viên đó.
Ví dụ thực thi hàm: select*from SalaryOf[Sales].[SalesPerson]Emp(288) 
*/