CREATE OR ALTER PROCEDURE usp_BorrowBook
    @member_id  INT,
    @book_id INT,
    @copy_id INT,
    @staff_id INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @UnpaidFines INT;
    DECLARE @borrow_date DATE = CAST(GETDATE() AS DATE);
    DECLARE @date_due DATE = CAST(DATEADD(DAY, 14, GETDATE()) AS DATE);

    BEGIN TRY

        -- 1. Check member exists
        IF NOT EXISTS (SELECT member_id FROM Members WHERE member_id = @member_id)
            RAISERROR('Member not found.', 16, 1);

        -- 2. Check membership validity
        IF dbo.fn_IsMembershipValid(@member_id) = 0
            RAISERROR('Member does not have an active membership.', 16, 1);

        -- 3. Check outstanding fines
        IF dbo.fn_MemberOutstandingFines(@member_id) >= 300.00
            RAISERROR('Member has NGN 300.00 or more in outstanding fines. Please settle before borrowing.', 16, 1);

        -- 4. Check book exists
        IF NOT EXISTS (SELECT book_id FROM Books WHERE book_id = @book_id)
            RAISERROR('Book not found in catalogue.', 16, 1);

        -- 5. Check copy exists and is available
        IF NOT EXISTS (SELECT copy_id FROM Copies WHERE copy_id = @copy_id AND book_id = @book_id AND availability = 1)
            RAISERROR('This copy is either unavailable or does not belong to the specified book.', 16, 1);
        
        -- All checks passed — execute transaction
        BEGIN TRANSACTION;

            INSERT INTO Borrowings 
                (copy_id, member_id, staff_id, borrow_date, date_due, return_date)
            VALUES 
                (@copy_id, @member_id, @staff_id, @borrow_date, @date_due, NULL);

            UPDATE Copies 
            SET availability = 0 
            WHERE  copy_id = @copy_id;

        COMMIT TRANSACTION;

        -- Success message
        SELECT 
            CONCAT(m.first_name, ' ', m.last_name) AS Member,
            b.title AS Book,
            c.copy_id AS CopyID,
            br.borrow_date AS BorrowDate,
            br.date_due AS DueDate,
            'Borrowing successful' AS Status
        FROM Borrowings br
        INNER JOIN Members m  ON br.member_id = m.member_id
        INNER JOIN Copies c ON br.copy_id = c.copy_id
        INNER JOIN Books  b ON c.book_id = b.book_id
        WHERE  br.borrow_id = SCOPE_IDENTITY();

    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;

END;