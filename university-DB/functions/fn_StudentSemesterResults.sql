-- =============================================
-- Function: fn_StudentSemesterResults
-- Purpose: Returns all courses taken by a student
--          in a given semester with grade points
--          calculated per course
-- Type: Inline Table-Valued Function
-- Inputs: @StudentID, @Semester, @Academic_Year
-- =============================================

CREATE OR ALTER FUNCTION dbo.fn_StudentSemesterResults
(
    @StudentID INT,
    @Semester VARCHAR(6),
    @Academic_Year SMALLINT
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        c.CourseID AS [Course ID],
        c.CourseName AS [Course Name],
        c.Credits AS [Credits],
        e.Grade AS [Grade],
        e.Status AS [Status],
        dbo.fn_GradePoints(e.Grade, c.Credits) AS [Grade Points]
    FROM dbo.Enrollments  e
    INNER JOIN dbo.Courses c ON e.CourseID = c.CourseID
    WHERE e.StudentID = @StudentID
      AND e.Semester = @Semester
      AND e.Academic_Year = @Academic_Year
);
GO


-- USAGE EXAMPLES
-- Student 1 results for Fall 2019
SELECT *
FROM dbo.fn_StudentSemesterResults(1, 'Fall', 2019)
ORDER BY [Credits] DESC;

-- Student 111 results for Spring 2026
SELECT *
FROM dbo.fn_StudentSemesterResults(111, 'Spring', 2026)
ORDER BY [Credits] DESC;

-- Total grade points and credits earned by Student 1 in Fall 2019
SELECT
    SUM([Credits])      AS [Total Credits],
    SUM([Grade Points]) AS [Total Grade Points]
FROM dbo.fn_StudentSemesterResults(1, 'Fall', 2019)
WHERE [Status] = 'Completed';