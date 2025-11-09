USE CarRentalDb;
GO

-- Xóa SP nếu đã tồn tại
IF OBJECT_ID('dbo.sp_GetRandomString') IS NOT NULL DROP PROCEDURE dbo.sp_GetRandomString;
GO

-- Stored Procedure để sinh chuỗi ngẫu nhiên
CREATE PROCEDURE dbo.sp_GetRandomString
    @length INT,
    @Result NVARCHAR(MAX) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Chars VARCHAR(62) = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    SET @Result = '';
    DECLARE @Counter INT = 0;
    
    WHILE @Counter < @length
    BEGIN
        SET @Result = @Result + SUBSTRING(@Chars, CONVERT(INT, RAND(CHECKSUM(NEWID())) * 62) + 1, 1);
        SET @Counter = @Counter + 1;
    END
END
GO