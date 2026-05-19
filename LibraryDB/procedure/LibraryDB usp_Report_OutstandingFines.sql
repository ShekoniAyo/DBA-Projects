CREATE OR ALTER PROCEDURE usp_Report_OutstandingFines
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        CONCAT(m.first_name, ' ', m.last_name) AS member_name,
        m.phone_no,
        m.email,
        b.title AS book_title,
        f.issue_date,
        DATEDIFF(DAY, f.issue_date, GETDATE()) AS days_outstanding,
        f.amount
    FROM Fines f
    INNER JOIN Borrowings br 
        ON f.borrow_id = br.borrow_id
    INNER JOIN Members m  
        ON br.member_id = m.member_id
    INNER JOIN Copies c  
        ON br.copy_id = c.copy_id
    INNER JOIN Books b  
        ON c.book_id = b.book_id
    WHERE f.payment_status = 'Not Paid'
    ORDER BY f.issue_date ASC;

    IF @@ROWCOUNT = 0
        PRINT 'No outstanding fines at this time.';

END;