CREATE OR ALTER PROCEDURE usp_Report_Borrowings
    @start_date DATE,
    @end_date DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Default end date to 3 months after start date if not provided
    SET @end_date = COALESCE(@end_date, DATEADD(MONTH, 3, @start_date));

    IF @start_date > @end_date
        RAISERROR('Start date cannot be greater than end date.', 16, 1);

    SELECT
        br.borrow_id,
        b.title AS book_title,
        CONCAT(m.first_name, ' ', m.last_name) AS member_name,
        br.copy_id,
        br.borrow_date,
        br.return_date
    FROM Borrowings br
    INNER JOIN Copies c ON br.copy_id = c.copy_id
    INNER JOIN Books b ON c.book_id = b.book_id
    INNER JOIN Members m ON br.member_id = m.member_id
    WHERE br.borrow_date BETWEEN @start_date AND @end_date
    ORDER BY br.borrow_date DESC;

END;