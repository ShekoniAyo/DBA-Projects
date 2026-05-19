CREATE OR ALTER VIEW dbo.vw_MemberCount 
AS
SELECT [status], COUNT(*) AS no_of_members
FROM members
GROUP BY [status]
GO;

CREATE OR ALTER VIEW dbo.vw_BookCatalogue
AS
SELECT 
    b.book_id,
    b.title,
    b.ISBN,
    g.name AS genre,
    STRING_AGG(a.first_name + ' ' + a.last_name, ', ') AS authors
FROM Books b
INNER JOIN Genre g ON b.genre_id  = g.genre_id
INNER JOIN BookAuthors ba ON b.book_id   = ba.book_id
INNER JOIN Authors a  ON ba.author_id = a.author_id
GROUP BY 
    b.book_id,
    b.title,
    b.ISBN,
    g.name
GO;

CREATE OR ALTER VIEW dbo.vw_CopiesAvailability
AS
SELECT c.book_id, title, count(*) AS no_available
FROM Copies c
INNER JOIN Books b
ON c.book_id = b.book_id
WHERE availability = 1
GROUP BY c.book_id, title
GO;

CREATE OR ALTER VIEW dbo.vw_BooksNeverBorrowed
AS
SELECT 
    b.book_id,
    b.title,
    b.ISBN,
    g.name AS genre
FROM Books b
INNER JOIN Genre g 
ON b.genre_id = g.genre_id
WHERE NOT EXISTS (
    SELECT 1 
    FROM Copies c
    INNER JOIN Borrowings br ON c.copy_id = br.copy_id
    WHERE c.book_id = b.book_id
)
GO;

CREATE OR ALTER VIEW dbo.vw_MostActiveMembers
AS
SELECT TOP (10) m.member_id, first_name, last_name, reg_date, COUNT(*) AS no_of_borrowings, DATEDIFF(DAY, reg_date, GETDATE()) AS duration_of_membership
FROM Borrowings b
INNER JOIN Members m
ON b.member_id = m.member_id
GROUP BY m.member_id, first_name, last_name, reg_date
ORDER BY no_of_borrowings DESC
GO;