USE CarRentalDb;
GO

-- =========================================================================================
-- 1. Chèn 30 Users (Tổng 33 Users: ID 1-33)
-- =========================================================================================
-- Khai báo biến cục bộ cho lô này
DECLARE @MinDate DATETIME2 = '2025-09-01';
DECLARE @MaxDate DATETIME2 = '2025-11-30';
DECLARE @UserCount INT = 30;
DECLARE @i INT = 1;
DECLARE @RandomRole INT;
DECLARE @RandomEmail NVARCHAR(255);
DECLARE @RandomDate DATETIME2;
DECLARE @RandomStringOutput NVARCHAR(MAX);
DECLARE @RandomPhone NVARCHAR(20);

WHILE @i <= @UserCount
BEGIN
    SET @RandomRole = CASE WHEN RAND(CHECKSUM(NEWID())) < 0.2 THEN 2 ELSE 3 END;
    
    EXEC dbo.sp_GetRandomString @length = 5, @Result = @RandomStringOutput OUTPUT;
    SET @RandomEmail = 'mockuser' + @RandomStringOutput + '@carborrow.com';

    EXEC dbo.sp_GetRandomString @length = 7, @Result = @RandomStringOutput OUTPUT;
    SET @RandomPhone = '09' + CAST(ABS(CHECKSUM(NEWID())) % 10 AS NVARCHAR(1)) + @RandomStringOutput;
    
    SET @RandomDate = DATEADD(SECOND, ABS(CHECKSUM(NEWID())) % DATEDIFF(SECOND, @MinDate, @MaxDate), @MinDate);

    INSERT INTO Users (FirstName, LastName, Email, PasswordHash, PhoneNumber, IsActive, IsEmailConfirmed, RoleId, CreatedAt, UpdatedAt)
    VALUES (
        'MockName' + CAST(@i AS NVARCHAR(5)),
        'MockUser' + CAST(@i AS NVARCHAR(5)),
        @RandomEmail,
        '$2a$11$XKWQZYjQm5rQZJ3QZK8M4.xN4K7LQZ8qYQKwN7N5qZ3K8M4xN4K7L',
        @RandomPhone,
        1, 
        CASE WHEN RAND(CHECKSUM(NEWID())) < 0.95 THEN 1 ELSE 0 END, 
        @RandomRole,
        @RandomDate,
        DATEADD(HOUR, ABS(CHECKSUM(NEWID())) % 24, @RandomDate)
    );
    SET @i = @i + 1;
END
PRINT 'Chèn thành công 30 Users mới. ID Users: 1 -> 33';
GO

-- =========================================================================================
-- 2. Chèn 100 Vehicles (Tổng 105 Vehicles: ID 1-105)
-- =========================================================================================
-- Khai báo biến cục bộ cho lô này
DECLARE @MinDate DATETIME2 = '2025-09-01';
DECLARE @MaxDate DATETIME2 = '2025-11-30';
DECLARE @VehicleCount INT = 100;
DECLARE @j INT = 1;
DECLARE @RandomCategory INT;
DECLARE @RandomRate DECIMAL(10, 2);
DECLARE @RandomDate DATETIME2;
DECLARE @RandomStringOutput NVARCHAR(MAX);
DECLARE @LicensePlate NVARCHAR(20);

WHILE @j <= @VehicleCount
BEGIN
    SET @RandomCategory = ABS(CHECKSUM(NEWID())) % 5 + 1; 
    SET @RandomRate = (ABS(CHECKSUM(NEWID())) % 2000000 + 500000); 
    SET @RandomDate = DATEADD(SECOND, ABS(CHECKSUM(NEWID())) % DATEDIFF(SECOND, @MinDate, '2025-11-25'), @MinDate);
    
    EXEC dbo.sp_GetRandomString @length = 5, @Result = @RandomStringOutput OUTPUT;
    SET @LicensePlate = '51Z-' + @RandomStringOutput;

    INSERT INTO Vehicles (Make, Model, Year, Color, LicensePlate, DailyRate, Seats, Transmission, FuelType, Mileage, Status, Description, CategoryId, CreatedAt, UpdatedAt)
    VALUES (
        'Make' + CAST(@j AS NVARCHAR(5)),
        'Model' + CAST(@j AS NVARCHAR(5)),
        2018 + (ABS(CHECKSUM(NEWID())) % 8), 
        CASE ABS(CHECKSUM(NEWID())) % 4 WHEN 0 THEN 'Black' WHEN 1 THEN 'White' WHEN 2 THEN 'Red' ELSE 'Silver' END,
        @LicensePlate,
        @RandomRate,
        5 + (ABS(CHECKSUM(NEWID())) % 3), 
        CASE ABS(CHECKSUM(NEWID())) % 2 WHEN 0 THEN 'Automatic' ELSE 'Manual' END,
        'Gasoline',
        ABS(CHECKSUM(NEWID())) % 50000, 
        CASE ABS(CHECKSUM(NEWID())) % 4 WHEN 0 THEN 'Rented' WHEN 1 THEN 'Maintenance' ELSE 'Available' END,
        'Mô tả chi tiết cho xe thuê số ' + CAST(@j AS NVARCHAR(5)),
        @RandomCategory,
        @RandomDate,
        DATEADD(HOUR, ABS(CHECKSUM(NEWID())) % 24, @RandomDate)
    );
    SET @j = @j + 1;
END
PRINT 'Chèn thành công 100 Vehicles mới. ID Vehicles: 1 -> 105';
GO

-- =========================================================================================
-- 3. Chèn 150 Bookings
-- =========================================================================================
-- Khai báo biến cục bộ cho lô này
DECLARE @MinDate DATETIME2 = '2025-09-01';
DECLARE @MaxDate DATETIME2 = '2025-11-30';
DECLARE @BookingCount INT = 150;
DECLARE @k INT = 1;
DECLARE @RandomUserId INT;
DECLARE @RandomVehicleId INT;
DECLARE @StartDate DATETIME2;
DECLARE @EndDate DATETIME2;
DECLARE @RandomStatus NVARCHAR(50);
DECLARE @RandomRating INT;

WHILE @k <= @BookingCount
BEGIN
    SET @RandomUserId = ABS(CHECKSUM(NEWID())) % 33 + 1; 
    SET @RandomVehicleId = ABS(CHECKSUM(NEWID())) % 105 + 1; 
    
    SET @StartDate = DATEADD(SECOND, ABS(CHECKSUM(NEWID())) % DATEDIFF(SECOND, '2025-09-17', @MaxDate), '2025-09-17');
    SET @EndDate = DATEADD(DAY, 3 + (ABS(CHECKSUM(NEWID())) % 5), @StartDate);
    
    SET @RandomStatus = CASE ABS(CHECKSUM(NEWID())) % 5
        WHEN 0 THEN 'Completed' WHEN 1 THEN 'Confirmed' WHEN 2 THEN 'Pending' WHEN 3 THEN 'Cancelled' ELSE 'Completed' END;
        
    SET @RandomRating = CASE 
        WHEN @RandomStatus = 'Completed' AND RAND(CHECKSUM(NEWID())) < 0.7 
        THEN (ABS(CHECKSUM(NEWID())) % 5 + 1) 
        ELSE NULL END;

    INSERT INTO Bookings (UserId, VehicleId, StartDate, EndDate, PickupLocation, ReturnLocation, TotalCost, Status, Rating, Review, CreatedAt, UpdatedAt)
    VALUES (
        @RandomUserId,
        @RandomVehicleId,
        @StartDate,
        @EndDate,
        'Quận 1, TP.HCM',
        'Quận Tân Bình, TP.HCM',
        (ABS(CHECKSUM(NEWID())) % 9000000 + 1000000), 
        @RandomStatus,
        @RandomRating,
        CASE WHEN @RandomRating IS NOT NULL THEN 'Dịch vụ tốt, xe sạch sẽ!' ELSE NULL END,
        DATEADD(SECOND, ABS(CHECKSUM(NEWID())) % DATEDIFF(SECOND, @MinDate, '2025-11-25'), @MinDate),
        DATEADD(HOUR, 1, DATEADD(SECOND, ABS(CHECKSUM(NEWID())) % DATEDIFF(SECOND, @MinDate, '2025-11-25'), @MinDate))
    );
    SET @k = @k + 1;
END
PRINT 'Chèn thành công 150 Bookings.';
GO

-- =========================================================================================
-- 4. Chèn 200 VehicleImages
-- =========================================================================================
-- Khai báo biến cục bộ cho lô này
DECLARE @MinDate DATETIME2 = '2025-09-01';
DECLARE @ImageCount INT = 200;
DECLARE @l INT = 1;
DECLARE @VehicleIdForImage INT = 1; 
DECLARE @ImageIndex INT = 1;
DECLARE @RandomDate DATETIME2;

WHILE @l <= @ImageCount
BEGIN
    SET @RandomDate = DATEADD(SECOND, ABS(CHECKSUM(NEWID())) % DATEDIFF(SECOND, @MinDate, '2025-11-25'), @MinDate);
    
    INSERT INTO VehicleImages (VehicleId, ImagePath, IsPrimary, UploadedAt)
    VALUES (
        @VehicleIdForImage,
        'https://mock-image-cdn/vehicle/' + CAST(@VehicleIdForImage AS NVARCHAR(10)) + '-img-' + CAST(@ImageIndex AS NVARCHAR(5)) + '.jpg',
        CASE WHEN @ImageIndex = 1 THEN 1 ELSE 0 END, 
        @RandomDate
    );
    
    SET @l = @l + 1;
    SET @ImageIndex = @ImageIndex + 1;
    
    IF @ImageIndex > 2 
    BEGIN
        SET @ImageIndex = 1;
        SET @VehicleIdForImage = @VehicleIdForImage + 1; 
        IF @VehicleIdForImage > 105 BREAK; 
    END
END
PRINT 'Chèn thành công 200 VehicleImages.';
GO

-- =========================================================================================
-- 5. Chèn 50 RefreshTokens
-- =========================================================================================
-- Khai báo biến cục bộ cho lô này
DECLARE @MinDate DATETIME2 = '2025-09-01';
DECLARE @TokenCount INT = 50;
DECLARE @m INT = 1;
DECLARE @RandomUserId INT;
DECLARE @RandomDate DATETIME2;

WHILE @m <= @TokenCount
BEGIN
    SET @RandomUserId = ABS(CHECKSUM(NEWID())) % 33 + 1;
    SET @RandomDate = DATEADD(SECOND, ABS(CHECKSUM(NEWID())) % DATEDIFF(SECOND, @MinDate, '2025-11-25'), @MinDate);
    
    INSERT INTO RefreshTokens (UserId, Token, Expires, Created, Revoked, IsActive)
    VALUES (
        @RandomUserId,
        NEWID(), 
        DATEADD(DAY, 30, @RandomDate), 
        @RandomDate,
        CASE WHEN RAND(CHECKSUM(NEWID())) < 0.2 THEN DATEADD(DAY, 1, @RandomDate) ELSE NULL END, 
        1 
    );
    SET @m = @m + 1;
END
PRINT 'Chèn thành công 50 RefreshTokens.';
GO

-- =========================================================================================
-- 6. Chèn 300 AuditLogs
-- =========================================================================================
-- Khai báo biến cục bộ cho lô này
DECLARE @MinDate DATETIME2 = '2025-09-01';
DECLARE @MaxDate DATETIME2 = '2025-11-30';
DECLARE @LogCount INT = 300;
DECLARE @n INT = 1;
DECLARE @RandomUserId INT;
DECLARE @RandomDate DATETIME2;
DECLARE @RandomAction NVARCHAR(50);

WHILE @n <= @LogCount
BEGIN
    SET @RandomUserId = ABS(CHECKSUM(NEWID())) % 33 + 1;
    SET @RandomDate = DATEADD(SECOND, ABS(CHECKSUM(NEWID())) % DATEDIFF(SECOND, @MinDate, @MaxDate), @MinDate);
    
    SET @RandomAction = CASE ABS(CHECKSUM(NEWID())) % 5
        WHEN 0 THEN 'Login' 
        WHEN 1 THEN 'Create Booking' 
        WHEN 2 THEN 'Update Vehicle' 
        WHEN 3 THEN 'Payment Processed' 
        ELSE 'View Dashboard' END;

    INSERT INTO AuditLogs (UserId, Action, Details, EntityType, EntityId, IpAddress, CreatedAt)
    VALUES (
        @RandomUserId,
        @RandomAction,
        'Log chi tiết: ' + @RandomAction + ' thực hiện bởi user ID ' + CAST(@RandomUserId AS NVARCHAR(10)),
        CASE ABS(CHECKSUM(NEWID())) % 4 WHEN 0 THEN 'User' WHEN 1 THEN 'Vehicle' WHEN 2 THEN 'Booking' ELSE 'Payment' END,
        ABS(CHECKSUM(NEWID())) % 150 + 1, 
        '192.168.' + CAST(ABS(CHECKSUM(NEWID())) % 255 AS NVARCHAR(3)) + '.' + CAST(ABS(CHECKSUM(NEWID())) % 255 AS NVARCHAR(3)),
        @RandomDate
    );
    SET @n = @n + 1;
END
PRINT 'Chèn thành công 300 AuditLogs.';
GO