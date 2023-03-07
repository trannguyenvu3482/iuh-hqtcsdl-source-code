-- Module 04: Batch, Stored Procedure, Functions
-- Lab 04: Batch

-- I) Batch
/*
1) Viết một batch khai báo biến @tongsoHD chứa tổng số hóa đơn của sản phẩm
có ProductID=’778’; nếu @tongsoHD>500 thì in ra chuỗi “Sản phẩm 778 có
trên 500 đơn hàng”, ngược lại thì in ra chuỗi “Sản phẩm 778 có ít đơn đặt
hàng”
*/
GO
DECLARE @tongsoHD INT;
SET @tongsoHD=(SELECT COUNT(*)FROM Sales.SalesOrderDetail sod WHERE ProductID='778');
IF @tongsoHD>500 PRINT 'Sản phẩm 778 có trên 500 đơn hàng';
ELSE PRINT 'Sản phẩm 778 có ít đơn đặt hàng';
GO

/*
2) Viết một đoạn Batch với tham số @makh và @n chứa số hóa đơn của khách
hàng @makh, tham số @nam chứa năm lập hóa đơn (ví dụ @nam=2008), nếu
@n>0 thì in ra chuỗi: “Khách hàng có @n hóa đơn trong năm 2008” ngược lại
nếu @n=0 thì in ra chuỗi “Khách hàng không có hóa đơn nào trong năm 2008”
*/
DECLARE @makh INT, @n INT, @nam INT;
SET @makh=29825;
SET @nam=2005;
SET @n=(SELECT COUNT(*)
        FROM Sales.SalesOrderHeader
        WHERE YEAR(OrderDate)=@nam AND CustomerID=@makh);
IF @n>0
    PRINT N'Khách hàng có '+CONVERT(VARCHAR(2), @n)+N' hóa đơn trong năm 2008';
ELSE PRINT N'Khách hàng không có hóa đơn nào trong năm 2008';
GO

/*
3) Viết một batch tính số tiền giảm cho những hóa đơn (SalesOrderID) có tổng
tiền>100000, thông tin gồm [SalesOrderID], Subtotal=sum([LineTotal]),
Discount (tiền giảm), với Discount được tính như sau:
- Những hóa đơn có Subtotal<100000 thì không giảm,
- Subtotal từ 100000 đến <120000 thì giảm 5% của Subtotal
- Subtotal từ 120000 đến <150000 thì giảm 10% của Subtotal
- Subtotal từ 150000 trở lên thì giảm 15% của Subtotal
(Gợi ý: Dùng cấu trúc Case… When …Then …)
*/
SELECT SalesOrderID, Subtotal=SUM(LineTotal), Discount=CASE WHEN SUM(LineTotal)<100000 THEN 0
                                                            WHEN SUM(LineTotal)>=100000 AND SUM(LineTotal)<120000 THEN 0.05 * SUM(LineTotal)
                                                            WHEN SUM(LineTotal)>=120000 AND SUM(LineTotal)<150000 THEN 0.1 * SUM(LineTotal)ELSE 0.15 * SUM(LineTotal)END
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID;
GO

/*
4) Viết một Batch với 3 tham số: @mancc, @masp, @soluongcc, chứa giá trị của
các field [ProductID],[BusinessEntityID],[OnOrderQty], với giá trị truyền cho
các biến @mancc, @masp (vd: @mancc=1650, @masp=4), thì chương trình sẽ
gán giá trị tương ứng của field [OnOrderQty] cho biến @soluongcc, nếu
@soluongcc trả về giá trị là null thì in ra chuỗi “Nhà cung cấp 1650 không cung
cấp sản phẩm 4”, ngược lại (vd: @soluongcc=5) thì in chuỗi “Nhà cung cấp 1650
cung cấp sản phẩm 4 với số lượng là 5”
(Gợi ý: Dữ liệu lấy từ [Purchasing].[ProductVendor])
*/
DECLARE @mancc INT, @masp INT, @soluongcc INT;
SET @mancc=1580;
SET @masp=1;
SELECT @soluongcc=OnOrderQty
FROM Purchasing.ProductVendor
WHERE BusinessEntityID=@mancc AND ProductID=@masp;
IF(@soluongcc IS NULL)
    PRINT N'Nhà cung cấp '+CONVERT(VARCHAR(5), @mancc)+N' không cung cấp sản phẩm '+CONVERT(VARCHAR(5), @masp);
ELSE
    PRINT N'Nhà cung cấp '+CONVERT(VARCHAR(5), @mancc)+N' cung cấp sản phẩm '+CONVERT(VARCHAR(5), @masp)+N' với số lượng là '+CONVERT(VARCHAR(5), @soluongcc);
GO

/*
5) Viết một batch thực hiện tăng lương giờ (Rate) của nhân viên trong
[HumanResources].[EmployeePayHistory] theo điều kiện sau: Khi tổng lương
giờ của tất cả nhân viên Sum(Rate)<6000 thì cập nhật tăng lương giờ lên 10%,
nếu sau khi cập nhật mà lương giờ cao nhất của nhân viên >150 thì dừng.
*/
DECLARE @rate INT;
SELECT @rate=SUM(Rate)FROM HumanResources.EmployeePayHistory;
WHILE(SELECT SUM(Rate)FROM [HumanResources].[EmployeePayHistory])<6000 BEGIN
    UPDATE [HumanResources].[EmployeePayHistory] SET Rate=Rate * 1.1;
    IF(SELECT MAX(Rate)FROM [HumanResources].[EmployeePayHistory])>150 BREAK;
    ELSE CONTINUE;
END;