-- FUNCTION 1: Checking for membership validity
CREATE FUNCTION dbo.fn_IsMembershipValid
(
    @member_id INT
)
RETURNS BIT
AS
BEGIN
    DECLARE @result BIT = 0;

    IF EXISTS (
        SELECT member_id FROM Members
        WHERE member_id   = @member_id
        AND [status] = 'Active'
        AND [expiry_date] >= GETDATE()
    )
        SET @result = 1;

    RETURN @result;
END
GO


-- FUNCTION 2: Calculating days overdue
CREATE FUNCTION dbo.fn_DaysOverdue
(
    @due_date DATE,
    @return_date DATE
)
RETURNS INT
AS
BEGIN
    DECLARE @days INT;

    SET @days = DATEDIFF(
        DAY,
        @due_date,
        COALESCE(@return_date, CAST(GETDATE() AS DATE))
    );

    RETURN CASE 
        WHEN @days > 0 THEN @days 
        ELSE 0 
        END;
END
GO

-- FUNCTION 3: Calculating member's total outstanding fines
CREATE FUNCTION dbo.fn_MemberOutstandingFines
(
    @member_id INT
)
RETURNS DECIMAL(7,2)
AS
BEGIN
    DECLARE @recorded_fines DECIMAL(7,2) = 0;
    DECLARE @accrued_fines DECIMAL(7,2) = 0;
    DECLARE @fine_rate DECIMAL(7,2) = 20.00;

    -- Part 1: Unpaid fines already recorded in Fines table
    SELECT @recorded_fines = COALESCE(SUM(f.amount), 0)
    FROM Fines f
    INNER JOIN Borrowings b 
        ON f.borrow_id = b.borrow_id
    WHERE b.member_id = @member_id
    AND f.payment_status  = 'Not Paid';

    -- Part 2: Accrued fines for overdue active borrowings not yet recorded in the Fines table
    SELECT @accrued_fines = COALESCE(
        SUM(dbo.fn_DaysOverdue(b.date_due, b.return_date) * @fine_rate),
        0
    )
    FROM Borrowings b
    WHERE b.member_id = @member_id
    AND b.return_date IS NULL
    AND dbo.fn_DaysOverdue(b.date_due, b.return_date) > 0;

    RETURN @recorded_fines + @accrued_fines;
END
GO