CREATE OR ALTER PROCEDURE usp_ReturnBook
    @borrow_id INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @return_date  DATE = CAST(GETDATE() AS DATE);
    DECLARE @due_date DATE;
    DECLARE @copy_id INT;
    DECLARE @member_id INT;
    DECLARE @days_overdue INT;
    DECLARE @fine_amount  DECIMAL(7,2);
    DECLARE @fine_rate DECIMAL(7,2) = 20.00;

    BEGIN TRY

        -- 1. Check active borrowing exists
        IF NOT EXISTS (
            SELECT borrow_id FROM Borrowings
            WHERE  borrow_id   = @borrow_id
            AND return_date IS NULL
        )
            RAISERROR('No active borrowing found for this ID.', 16, 1);

        -- Retrieve values needed for processing
        SELECT 
            @due_date  = date_due,
            @copy_id = copy_id,
            @member_id = member_id
        FROM Borrowings
        WHERE borrow_id = @borrow_id;

        -- Calculate days overdue (only meaningful if positive)
        SET @days_overdue = DATEDIFF(DAY, @due_date, @return_date);

        -- All checks passed — execute transaction
        BEGIN TRANSACTION;

            -- Update borrowing record with return date
            UPDATE Borrowings
            SET return_date = @return_date
            WHERE borrow_id = @borrow_id;

            -- Insert fine if overdue
            IF @days_overdue > 0
            BEGIN
                SET @fine_amount = @days_overdue * @fine_rate;

                INSERT INTO Fines
                    (borrow_id, issue_date, amount, payment_status, payment_date)
                VALUES
                    (@borrow_id, @return_date, @fine_amount, 'Not Paid', NULL);
            END;

            -- Return copy to available
            UPDATE Copies
            SET availability = 1
            WHERE  copy_id = @copy_id;

        COMMIT TRANSACTION;

        -- Success message
        SELECT
            CONCAT(m.first_name, ' ', m.last_name) AS Member,
            b.title AS Book,
            br.return_date AS ReturnDate,
            br.date_due AS DueDate,
            CASE 
                WHEN @days_overdue > 0 
                THEN CONCAT('Returned ', @days_overdue, ' day(s) late. Fine: NGN ', @fine_amount)
                ELSE 'Returned on time'
            END AS ReturnStatus
        FROM   Borrowings br
        INNER JOIN Members m ON br.member_id = m.member_id
        INNER JOIN Copies  c ON br.copy_id   = c.copy_id
        INNER JOIN Books   b ON c.book_id    = b.book_id
        WHERE  br.borrow_id = @borrow_id;

    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;

END;