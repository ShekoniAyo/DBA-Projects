CREATE OR ALTER PROCEDURE usp_Report_StaffTransactions
    @start_date DATE,
    @end_date   DATE = NULL,
    @staff_id   INT  = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SET @end_date = COALESCE(@end_date, DATEADD(MONTH, 3, @start_date));

    -- Validations
    IF @start_date > CAST(GETDATE() AS DATE)
        RAISERROR('Start date cannot be in the future.', 16, 1);

    IF @end_date < @start_date
        RAISERROR('End date cannot be before start date.', 16, 1);

    SELECT
        s.staff_id,
        CONCAT(s.first_name, ' ', s.last_name) AS staff_name,
        s.position,
        COUNT(*) AS total_transactions
    FROM Borrowings br
    INNER JOIN Staff s 
        ON br.staff_id = s.staff_id
    WHERE br.borrow_date BETWEEN @start_date AND @end_date
    AND  (@staff_id IS NULL OR s.staff_id = @staff_id)
    GROUP BY s.staff_id, s.first_name, s.last_name, s.position
    ORDER BY total_transactions DESC;

    IF @@ROWCOUNT = 0
        PRINT 'No transactions found for the specified period.';

END;