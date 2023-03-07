-- Lab 05: Stored Procedure
-- II) Stored Procedure:

/*
1) Viết một thủ tục tính tổng tiền thu (TotalDue) của mỗi khách hàng trong một
tháng bất kỳ của một năm bất kỳ (tham số tháng và năm) được nhập từ bàn phím,
thông tin gồm: CustomerID, SumofTotalDue =Sum(TotalDue)
*/

/*
2) Viết một thủ tục dùng để xem doanh thu từ đầu năm cho đến ngày hiện tại của
một nhân viên bất kỳ, với một tham số đầu vào và một tham số đầu ra. Tham số
@SalesPerson nhận giá trị đầu vào theo chỉ định khi gọi thủ tục, tham số
@SalesYTD được sử dụng để chứa giá trị trả về của thủ tục
*/

/*
3) Viết một thủ tục trả về một danh sách các sản phẩm có giá không vượt quá một
giá trị được chỉ định, với tham số input @Product và @MaxPrice, tham số
output là ListPrice
*/

/*
4) Viết thủ tục tên NewBonus cập nhật lại tiền thưởng (Bonus) cho nhân viên bán
hàng (SalesPerson), dựa trên tổng doanh thu của mỗi nhân viên, mức thưởng mới
bằng mức thưởng hiện tại tăng thêm 1% tổng doanh thu, thông tin bao gồm
[SalesPersonID], NewBonus (thưởng mới), sumofSubTotal. Trong đó:
SumofSubTotal =sum(SubTotal)
NewBonus = Bonus+ sum(SubTotal)*0.01
*/

/*
5) Viết một thủ tục dùng để xem thông tin của nhóm sản phẩm (ProductCategory)
có tổng số lượng (OrderQty) đặt hàng cao nhất trong một năm tùy ý (tham số
input), thông tin gồm: ProductCategoryID, Name, SumofQty. Dữ liệu từ bảng
ProductCategory, ProductSubcategory, Product và SalesOrderDetail (Lưu ý:
dùng subquery)
*/

/*
6) Tạo thủ tục đặt tên là TongThu có tham số vào là mã nhân viên, tham số đầu ra
là tổng trị giá các hóa đơn nhân viên đó bán được. Sử dụng lệnh RETURN để trả
về trạng thái thành công hay thất bại của thủ tục.
*/

/*
7) Tạo thủ tục hiển thị tên và số tiền mua của cửa hàng mua nhiều hàng nhất theo
năm đã cho.
*/

/*
8) Viết thủ tục Sp_InsertProduct có tham số dạng input dùng để chèn một mẫu tin
vào bảng Production.Product. Yêu cầu: chỉ thêm vào các trường có giá trị not
null và các field là khóa ngoại.
*/

/*
9) Viết thủ tục XoaHD, dùng để xóa 1 hóa đơn trong bảng Sales.SalesOrderHeader
khi biết SalesOrderID. Lưu ý trước khi xóa mẫu tin trong
Sales.SalesOrderHeader thì phải xóa các mẫu tin của hoá đơn đó trong
Sales.SalesOrderDetail. Nếu không xoá được hoá đơn thì cũng không được phép
xóa Sales.SalesOrderDetail của hóa đơn đó.
*/

/*
10)Viết thủ tục Sp_Update_Product có tham số ProductId dùng để tăng listprice lên
10% nếu sản phẩm này tồn tại, ngược lại hiện thông báo không có sản phẩm này.
*/