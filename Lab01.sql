USE SmallWorks;

-- Dùng T-SQL tạo thêm một filegroup tên Test1FG1 trong SmallWorks, sau đó add
-- thêm 2 file filedat1.ndf và filedat2.ndf dung lượng 5MB vào filegroup Test1FG1.
-- Dùng SSMS xem kết quả.
ALTER DATABASE SmallWorks ADD FILEGROUP Test1FG1;
ALTER DATABASE SmallWorks
ADD FILE(NAME='filedat1', FILENAME='D:\IUH\HQTCSDL\BT_Lab_Duz\filedat1.ndf', SIZE=5MB, MAXSIZE=25MB),
    (NAME='filedat2', FILENAME='D:\IUH\HQTCSDL\BT_Lab_Duz\filedat2.ndf', SIZE=5MB, MAXSIZE=25MB);

-- BTVN:
--Tạo database Sales
CREATE DATABASE Sales
ON PRIMARY(NAME=Sales_data1, FILENAME='D:\IUH\HQTCSDL\BT_Lab_Duz\Sales_data1.mdf', SIZE=10MB, MAXSIZE=UNLIMITED, FILEGROWTH=20%),
       (NAME=Sales_data22, FILENAME='D:\IUH\HQTCSDL\BT_Lab_Duz\Sales_data2.ldf', SIZE=10MB, MAXSIZE=UNLIMITED, FILEGROWTH=20%);
USE Sales;
--1. Tạo các kiểu dữ liệu người dùng
EXEC sp_addtype Mota, 'nvarchar(40)', 'NULL';
EXEC sp_addtype IDKH, 'char(10)', 'NOT NULL';
EXEC sp_addtype DT, 'char(12)', 'NULL';

--2. Tạo bảng
--Tạo table SanPham
CREATE TABLE SanPham (Masp CHAR(6) NOT NULL,
TenSp VARCHAR(20),
NgayNhap DATE,
DVT CHAR(10),
SoLuongTon INT,
DonGiaNhap MONEY);

--Tạo table HoaDon
CREATE TABLE HoaDon (MaHD CHAR(10) NOT NULL,
NgayLap DATE,
NgayGiao DATE,
Makh IDKH,
DienGiai Mota);

--Tạo table KhachHang
CREATE TABLE KhachHang (MaKH IDKH, TenKH NVARCHAR(30), DiaChi NVARCHAR(40), Dienthoat DT);

--Tạo table ChiTietHD
CREATE TABLE ChiTietHD (MaHD CHAR(10), Masp CHAR(6), Soluong INT);

--3.  Trong Table HoaDon, sửa cột DienGiai thành nvarchar(100)
ALTER TABLE HoaDon ALTER COLUMN DienGiai NVARCHAR(100);

--4. Thêm vào bảng SanPham cột TyLeHoaHong
ALTER TABLE SanPham ADD TyLeHoaHong FLOAT;

--5. Xóa cột NgayNhap trong bảng SanPham
ALTER TABLE SanPham DROP COLUMN NgayNhap;

--6. Tạo các ràng buộc khóa chính và khóa ngoại cho các bảng trên
--Tạo các ràng buộc khóa chính
ALTER TABLE SanPham ADD CONSTRAINT PK_Masp PRIMARY KEY(Masp);
ALTER TABLE HoaDon ADD CONSTRAINT PK_MaHD PRIMARY KEY(MaHD);
ALTER TABLE KhachHang ADD CONSTRAINT PK_MaKH PRIMARY KEY(MaKH);

--Tạo các ràng buộc khóa ngoại
ALTER TABLE HoaDon
ADD CONSTRAINT FK_Makh_HoaDon FOREIGN KEY(Makh)REFERENCES KhachHang(MaKH);
ALTER TABLE ChiTietHD
ADD CONSTRAINT FK_MaHD FOREIGN KEY(MaHD)REFERENCES HoaDon(MaHD);
ALTER TABLE ChiTietHD
ADD CONSTRAINT FK_Masp FOREIGN KEY(Masp)REFERENCES SanPham(Masp);

--7. Thêm vào bảng HoaDon các ràng buộc
--NgayGiao >= NgayLap
ALTER TABLE HoaDon ADD CONSTRAINT HD_NgayGiao CHECK(NgayGiao>=NgayLap);

--MaHD gồm 6 ký tự, 2 ký tự đầu là chữ, các ký tự còn lại là số
ALTER TABLE HoaDon
ADD CONSTRAINT HD_MaHD CHECK(MaHD LIKE '[A-Z][A-Z][0-9][0-9][0-9][0-9]');

--Giá trị mặc định ban đầu cho cột NgayLap luôn luôn là ngày hiện hành
ALTER TABLE HoaDon ADD CONSTRAINT NgayLap_DF DEFAULT GETDATE()FOR NgayLap;

--8. Thêm vào bảng SanPham các ràng buộc sau
--SoLuongTon chỉ nhập từ 0 đến 500
ALTER TABLE SanPham
ADD CONSTRAINT SP_SLT CHECK(SoLuongTon>=0 AND SoLuongTon<=500);

--DonGiaNhap lớn hơn 0
ALTER TABLE SanPham ADD CONSTRAINT SP_DGN CHECK(DonGiaNhap>0);

--Giá trị mặc định cho NgayNhap là ngày hiện hành
--Vì xóa cột NgayNhap ở câu trên nên giờ phải thêm lại.
ALTER TABLE SanPham ADD NgayNhap DATE;
ALTER TABLE SanPham
ADD CONSTRAINT NgayNhap_DF DEFAULT GETDATE()FOR NgayNhap;

--DVT chỉ nhập vào các giá trị ‘KG’, ‘Thùng’, ‘Hộp’, ‘Cái'
ALTER TABLE SanPham
ADD CONSTRAINT SP_DVT CHECK(DVT IN ('KG', 'Thùng', 'Hộp', 'Cái'));

--9. Dùng lệnh T-SQL nhập dữ liệu vào 4 table trên, dữ liệu tùy ý, chú ý các ràng 
--buộc của mỗi Table
INSERT INTO SanPham(Masp, TenSp)VALUES('123', 'Card');
INSERT INTO KhachHang(MaKH)VALUES('aa');
INSERT INTO HoaDon(MaHD, Makh)VALUES('aa0101', 'aa');
INSERT INTO ChiTietHD(MaHD, Masp)VALUES('aa0101', '123');

--10. Xóa 1 hóa đơn bất kỳ trong bảng HoaDon. Có xóa được không? Tại sao? Nếu vẫn muốn xóa thì phải dùng cách nào?
--Không xóa được vì trong bảng HoaDon có khóa ngoại bảng ChiTietHD tham chiếu đến MaHD. Nếu vẫn muốn xóa thì ta thêm ON DELETE CASCADE vào ràng buộc khóa ngoại
ALTER TABLE ChiTietHD DROP CONSTRAINT FK_MaHD;
ALTER TABLE ChiTietHD
ADD CONSTRAINT Fk_MaHD FOREIGN KEY(MaHD)REFERENCES HoaDon(MaHD)ON DELETE CASCADE;
DELETE FROM HoaDon WHERE MaHD='aa0101';

--11. Nhập 2 bản ghi mới vào bảng ChiTietHD với MaHD = ‘HD999999999’ và MaHD=’1234567890’. Có nhập được không? Tại sao?
--Không nhập được bới vì MaHD ở bảng HoaDon không tồn tại MaHD = ‘HD999999999’ và MaHD=’1234567890’

--12. Đổi tên CSDL Sales thành BanHang
EXEC sp_renamedb 'Sales', 'BanHang';

--13. Tạo thư mục T:\QLBH, chép CSDL BanHang vào thư mục này, bạn có sao  chép được không? Tại sao? Muốn sao chép được bạn phải làm gì? Sau khi sao  chép, bạn thực hiện Attach CSDL vào lại SQL.
-- Không sao chép được. Vì CSDL vẫn đang được kết nối đến server. Muốn sao chép được phải detach CSDL

--14. Tạo bản BackUp cho CSDL BanHang
BACKUP DATABASE BanHang TO DISK='D:\NguyenGiaBao\BanHang.bak';

--15. Xóa CSDL BanHang
USE master;
DROP DATABASE BanHang;

--16. Phục hồi lại CSDL BanHang.
RESTORE DATABASE BanHang
FROM DISK='D:\NguyenGiaBao\BanHang.bak'
WITH REPLACE;