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
GO
DECLARE @makh VARCHAR(10), @n INT, @nam INT
SET @makh = 'ABC'
SET @nam = 2008
SET @n = (SELECT COUNT(*) FROM Sales.SalesOrderHeader WHERE YEAR(OrderDate) = @nam AND CustomerID = @makh)
IF @n > 0 PRINT 'Khách hàng có ' + @n + ' hóa đơn trong năm 2008'
ELSE PRINT 'Khách hàng không có hóa đơn nào trong năm 2008' 
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