CREATE PROCEDURE usp_RegisterMember
    @first_name VARCHAR(20),
    @last_name VARCHAR(20),
    @address VARCHAR(50),
    @phone_no VARCHAR(15),
    @DOB DATE,
    @gender CHAR(2),
    @email VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @reg_date DATE = CAST(GETDATE() AS DATE);
    DECLARE @expiry_date DATE = CAST(DATEADD(MONTH, 6, GETDATE()) AS DATE);
    DECLARE @status VARCHAR(10) = 'Active';

    BEGIN TRY

        -- 1. Check phone number length
        IF LEN(@phone_no) != 11
            RAISERROR('Phone number must be exactly 11 digits.', 16, 1);

        -- 2. Check member is at least 18 years old
        IF @DOB > DATEADD(YEAR, -18, GETDATE())
            RAISERROR('Member must be at least 18 years old to register.', 16, 1);

        -- 3. Check email does not already exist
        IF EXISTS (
            SELECT email FROM Members
            WHERE  email = @email
        )
            RAISERROR('A member with this email address already exists.', 16, 1);

        -- All checks passed — insert member
        BEGIN TRANSACTION;

            INSERT INTO Members
                (first_name, last_name, [address], phone_no, DOB, gender, 
                 email, reg_date, [expiry_date], [status])
            VALUES
                (@first_name, @last_name, @address, @phone_no, @DOB, @gender,
                 @email, @reg_date, @expiry_date, @status);

        COMMIT TRANSACTION;

        -- Success message
        SELECT
            CONCAT(first_name, ' ', last_name) AS Member,
            email AS Email,
            reg_date AS RegistrationDate,
            [expiry_date] AS MembershipExpiry,
            'Registration successful' AS [Status]
        FROM Members
        WHERE member_id = SCOPE_IDENTITY();

    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;

END;