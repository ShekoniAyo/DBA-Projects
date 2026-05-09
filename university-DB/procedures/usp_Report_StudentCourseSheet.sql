-- =============================================
-- Stored Procedure: usp_Report_StudentCourseSheet
-- Purpose: Returns all courses a student is 
--          taking for a specific semester
--          ordered by credits
-- Parameters: @StudentID, @Semester, @Academic_Year
-- =============================================

CREATE PROCEDURE dbo.usp_Report_StudentCourseSheet
    @StudentID INT,
    @Semester VARCHAR(6),
    @Academic_Year SMALLINT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        c.CourseID AS [Course ID],
        c.CourseName AS [Course Name],
        c.Credits AS [Credits],
        e.Grade AS [Grade],
        e.Status AS [Status]

    FROM dbo.Courses c
    INNER JOIN dbo.Enrollments e 
        ON e.CourseID = c.CourseID
    INNER JOIN dbo.Students s 
        ON e.StudentID = s.StudentID

    WHERE s.StudentID = @StudentID
      AND e.Semester = @Semester
      AND e.Academic_Year = @Academic_Year
    ORDER BY c.Credits DESC;

END;
GO


-- =============================================
-- USAGE EXAMPLES
-- =============================================

-- Course sheet for Student 111, Spring 2026
EXEC dbo.usp_Report_StudentCourseSheet
    @StudentID = 111,
    @Semester = 'Spring',
    @Academic_Year = 2026;

-- Course sheet for Student 1, Fall 2019
EXEC dbo.usp_Report_StudentCourseSheet
    @StudentID = 1,
    @Semester = 'Fall',
    @Academic_Year = 2019;