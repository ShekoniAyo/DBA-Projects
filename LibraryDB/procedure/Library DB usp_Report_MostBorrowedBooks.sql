CREATE OR ALTER PROCEDURE usp_Report_MostBorrowedBooks
    @start_date DATE,
    @end_date DATE = NULL,
    @genre VARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SET @end_date = COALESCE(@end_date, DATEADD(MONTH, 3, @start_date));

    IF @start_date > CAST(GETDATE() AS DATE)
        RAISERROR('Start date cannot be in the future.', 16, 1);

    IF @end_date < @start_date
        RAISERROR('End date cannot be before start date.', 16, 1);

    SELECT
        b.title AS book_title,
        g.name AS genre,
        COUNT(*) AS times_borrowed
    FROM Borrowings br
    INNER JOIN Copies c 
        ON br.copy_id = c.copy_id
    INNER JOIN Books b 
        ON c.book_id = b.book_id
    INNER JOIN Genre g 
        ON b.genre_id = g.genre_id
    WHERE br.borrow_date BETWEEN @start_date AND @end_date
    AND  (@genre IS NULL OR g.name = @genre)
    GROUP BY b.title, g.name
    ORDER BY times_borrowed DESC
    
    IF @@ROWCOUNT = 0
        RAISERROR('No borrowings found for the specified period and genre.', 16, 1);

END;