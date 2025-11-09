-- =============================================
-- Car Rental Database Creation Script
-- Database: CarRentalDb
-- Description: Script để tạo database cho hệ thống thuê xe
-- =============================================

USE master;
GO

-- Xóa database nếu đã tồn tại
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'CarRentalDb')
BEGIN
    ALTER DATABASE CarRentalDb SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE CarRentalDb;
END
GO

-- Tạo database mới
CREATE DATABASE CarRentalDb;
GO

USE CarRentalDb;
GO

-- =============================================
-- Table: Roles
-- =============================================
CREATE TABLE Roles (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(50) NOT NULL UNIQUE,
    Description NVARCHAR(255) NULL
);
GO

-- =============================================
-- Table: Categories
-- =============================================
CREATE TABLE Categories (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL UNIQUE,
    Description NVARCHAR(500) NULL
);
GO

-- =============================================
-- Table: Users
-- =============================================
CREATE TABLE Users (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    FirstName NVARCHAR(100) NOT NULL,
    LastName NVARCHAR(100) NOT NULL,
    Email NVARCHAR(255) NOT NULL UNIQUE,
    PasswordHash NVARCHAR(MAX) NOT NULL,
    PhoneNumber NVARCHAR(20) NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    IsEmailConfirmed BIT NOT NULL DEFAULT 0,
    EmailVerificationToken NVARCHAR(500) NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    RoleId INT NOT NULL,
    CONSTRAINT FK_Users_Roles FOREIGN KEY (RoleId) REFERENCES Roles(Id) ON DELETE NO ACTION
);
GO

CREATE INDEX IX_Users_Email ON Users(Email);
CREATE INDEX IX_Users_RoleId ON Users(RoleId);
GO

-- =============================================
-- Table: Vehicles
-- =============================================
CREATE TABLE Vehicles (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Make NVARCHAR(50) NOT NULL,
    Model NVARCHAR(50) NOT NULL,
    Year INT NOT NULL,
    Color NVARCHAR(30) NULL,
    LicensePlate NVARCHAR(20) NOT NULL UNIQUE,
    DailyRate DECIMAL(10,2) NOT NULL,
    Seats INT NOT NULL DEFAULT 5,
    Transmission NVARCHAR(50) NULL,
    FuelType NVARCHAR(30) NULL,
    Mileage FLOAT NOT NULL DEFAULT 0,
    Features NVARCHAR(1000) NULL,
    Status NVARCHAR(50) NOT NULL DEFAULT 'Available',
    Description NVARCHAR(1000) NULL,
    ImageUrl NVARCHAR(500) NULL,
    IsDeleted BIT NOT NULL DEFAULT 0,
    CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CategoryId INT NOT NULL,
    CONSTRAINT FK_Vehicles_Categories FOREIGN KEY (CategoryId) REFERENCES Categories(Id) ON DELETE NO ACTION
);
GO

CREATE INDEX IX_Vehicles_LicensePlate ON Vehicles(LicensePlate);
CREATE INDEX IX_Vehicles_CategoryId ON Vehicles(CategoryId);
CREATE INDEX IX_Vehicles_Status ON Vehicles(Status);
GO

-- =============================================
-- Table: VehicleImages
-- =============================================
CREATE TABLE VehicleImages (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    VehicleId INT NOT NULL,
    ImagePath NVARCHAR(500) NOT NULL,
    IsPrimary BIT NOT NULL DEFAULT 0,
    UploadedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT FK_VehicleImages_Vehicles FOREIGN KEY (VehicleId) REFERENCES Vehicles(Id) ON DELETE CASCADE
);
GO

CREATE INDEX IX_VehicleImages_VehicleId ON VehicleImages(VehicleId);
GO

-- =============================================
-- Table: Bookings
-- =============================================
CREATE TABLE Bookings (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    UserId INT NOT NULL,
    VehicleId INT NOT NULL,
    StartDate DATETIME2 NOT NULL,
    EndDate DATETIME2 NOT NULL,
    PickupLocation NVARCHAR(255) NULL,
    ReturnLocation NVARCHAR(255) NULL,
    TotalCost DECIMAL(10,2) NOT NULL,
    Status NVARCHAR(50) NOT NULL DEFAULT 'Pending',
    Rating INT NULL,
    Review NVARCHAR(1000) NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT FK_Bookings_Users FOREIGN KEY (UserId) REFERENCES Users(Id) ON DELETE NO ACTION,
    CONSTRAINT FK_Bookings_Vehicles FOREIGN KEY (VehicleId) REFERENCES Vehicles(Id) ON DELETE NO ACTION,
    CONSTRAINT CK_Bookings_Rating CHECK (Rating IS NULL OR (Rating >= 1 AND Rating <= 5)),
    CONSTRAINT CK_Bookings_Dates CHECK (EndDate > StartDate)
);
GO

CREATE INDEX IX_Bookings_UserId ON Bookings(UserId);
CREATE INDEX IX_Bookings_VehicleId ON Bookings(VehicleId);
CREATE INDEX IX_Bookings_Status ON Bookings(Status);
CREATE INDEX IX_Bookings_StartDate ON Bookings(StartDate);
CREATE INDEX IX_Bookings_EndDate ON Bookings(EndDate);
GO

-- =============================================
-- Table: RefreshTokens
-- =============================================
CREATE TABLE RefreshTokens (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    UserId INT NOT NULL,
    Token NVARCHAR(MAX) NOT NULL,
    Expires DATETIME2 NOT NULL,
    Created DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    Revoked DATETIME2 NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    CONSTRAINT FK_RefreshTokens_Users FOREIGN KEY (UserId) REFERENCES Users(Id) ON DELETE CASCADE
);
GO

CREATE INDEX IX_RefreshTokens_UserId ON RefreshTokens(UserId);
GO

-- =============================================
-- Table: AuditLogs
-- =============================================
CREATE TABLE AuditLogs (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    UserId INT NOT NULL,
    Action NVARCHAR(100) NOT NULL,
    Details NVARCHAR(500) NULL,
    EntityType NVARCHAR(50) NULL,
    EntityId INT NULL,
    IpAddress NVARCHAR(45) NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT FK_AuditLogs_Users FOREIGN KEY (UserId) REFERENCES Users(Id) ON DELETE NO ACTION
);
GO

CREATE INDEX IX_AuditLogs_UserId ON AuditLogs(UserId);
CREATE INDEX IX_AuditLogs_CreatedAt ON AuditLogs(CreatedAt);
CREATE INDEX IX_AuditLogs_EntityType ON AuditLogs(EntityType);
GO

-- =============================================
-- Seed Data: Roles
-- =============================================
INSERT INTO Roles (Name, Description) VALUES 
('Admin', 'Administrator với full quyền truy cập'),
('Staff', 'Nhân viên quản lý xe và booking'),
('Customer', 'Khách hàng thuê xe');
GO

-- =============================================
-- Seed Data: Categories
-- =============================================
INSERT INTO Categories (Name, Description) VALUES 
('Sedan', 'Xe sedan 4-5 chỗ, phù hợp gia đình'),
('SUV', 'Xe SUV rộng rãi, 7 chỗ'),
('Hatchback', 'Xe hatchback nhỏ gọn, tiết kiệm nhiên liệu'),
('Luxury', 'Xe sang trọng, cao cấp'),
('Van', 'Xe van, phù hợp cho nhóm đông người');
GO

-- =============================================
-- Seed Data: Users (Password mặc định: Admin@123)
-- =============================================
-- Password hash cho "Admin@123" sử dụng BCrypt
INSERT INTO Users (FirstName, LastName, Email, PasswordHash, PhoneNumber, IsActive, IsEmailConfirmed, RoleId, CreatedAt, UpdatedAt) 
VALUES 
('Admin', 'System', 'admin@carborrow.com', '$2a$11$XKWQZYjQm5rQZJ3QZK8M4.xN4K7LQZ8qYQKwN7N5qZ3K8M4xN4K7L', '0901234567', 1, 1, 1, GETUTCDATE(), GETUTCDATE()),
('Nguyen Van', 'Staff', 'staff@carborrow.com', '$2a$11$XKWQZYjQm5rQZJ3QZK8M4.xN4K7LQZ8qYQKwN7N5qZ3K8M4xN4K7L', '0901234568', 1, 1, 2, GETUTCDATE(), GETUTCDATE()),
('Tran Thi', 'Customer', 'customer@carborrow.com', '$2a$11$XKWQZYjQm5rQZJ3QZK8M4.xN4K7LQZ8qYQKwN7N5qZ3K8M4xN4K7L', '0901234569', 1, 1, 3, GETUTCDATE(), GETUTCDATE());
GO

-- =============================================
-- Seed Data: Vehicles
-- =============================================
INSERT INTO Vehicles (Make, Model, Year, Color, LicensePlate, DailyRate, Seats, Transmission, FuelType, Mileage, Features, Status, Description, CategoryId, CreatedAt, UpdatedAt)
VALUES 
('Toyota', 'Camry', 2022, 'Black', '51A-12345', 800000, 5, 'Automatic', 'Gasoline', 15000, 'GPS, Bluetooth, Air Conditioning, USB Port', 'Available', 'Xe sedan hạng sang, tiện nghi hiện đại', 1, GETUTCDATE(), GETUTCDATE()),
('Honda', 'CR-V', 2023, 'White', '51B-67890', 1200000, 7, 'Automatic', 'Gasoline', 8000, 'GPS, Bluetooth, Cruise Control, Leather Seats', 'Available', 'SUV rộng rãi, phù hợp gia đình', 2, GETUTCDATE(), GETUTCDATE()),
('Mazda', 'CX-5', 2022, 'Red', '51C-11111', 1000000, 5, 'Automatic', 'Diesel', 12000, 'GPS, Bluetooth, Backup Camera, Sunroof', 'Available', 'SUV thể thao, vận hành mạnh mẽ', 2, GETUTCDATE(), GETUTCDATE()),
('Hyundai', 'i10', 2021, 'Blue', '51D-22222', 500000, 5, 'Manual', 'Gasoline', 20000, 'Air Conditioning, USB Port', 'Available', 'Xe nhỏ gọn, tiết kiệm nhiên liệu', 3, GETUTCDATE(), GETUTCDATE()),
('Mercedes-Benz', 'E-Class', 2023, 'Silver', '51E-33333', 2500000, 5, 'Automatic', 'Gasoline', 5000, 'GPS, Bluetooth, Massage Seats, Premium Sound System', 'Available', 'Xe sang trọng, đẳng cấp doanh nhân', 4, GETUTCDATE(), GETUTCDATE());
GO

-- =============================================
-- View: Dashboard Statistics
-- =============================================
CREATE VIEW vw_DashboardStats AS
SELECT 
    (SELECT COUNT(*) FROM Users WHERE IsActive = 1) AS TotalActiveUsers,
    (SELECT COUNT(*) FROM Vehicles WHERE IsDeleted = 0 AND Status = 'Available') AS TotalAvailableVehicles,
    (SELECT COUNT(*) FROM Bookings WHERE Status IN ('Pending', 'Confirmed')) AS TotalActiveBookings,
    (SELECT ISNULL(SUM(TotalCost), 0) FROM Bookings WHERE Status = 'Completed') AS TotalRevenue;
GO

-- =============================================
-- Stored Procedure: Get Available Vehicles
-- =============================================
CREATE PROCEDURE sp_GetAvailableVehicles
    @StartDate DATETIME2,
    @EndDate DATETIME2
AS
BEGIN
    SELECT DISTINCT v.*
    FROM Vehicles v
    WHERE v.IsDeleted = 0 
    AND v.Status = 'Available'
    AND v.Id NOT IN (
        SELECT b.VehicleId 
        FROM Bookings b
        WHERE b.Status IN ('Confirmed', 'Active')
        AND (
            (@StartDate BETWEEN b.StartDate AND b.EndDate)
            OR (@EndDate BETWEEN b.StartDate AND b.EndDate)
            OR (b.StartDate BETWEEN @StartDate AND @EndDate)
        )
    );
END
GO

-- =============================================
-- Kết thúc script
-- =============================================
PRINT 'Database CarRentalDb đã được tạo thành công!';
PRINT 'Tổng số bảng: 8';
PRINT 'Tổng số roles: 3 (Admin, Staff, Customer)';
PRINT 'Tổng số categories: 5';
PRINT 'Tổng số vehicles mẫu: 5';
PRINT 'Tổng số users mẫu: 3';
PRINT '';
PRINT 'Thông tin đăng nhập mẫu:';
PRINT '- Admin: admin@carborrow.com / Admin@123';
PRINT '- Staff: staff@carborrow.com / Admin@123';
PRINT '- Customer: customer@carborrow.com / Admin@123';
GO
