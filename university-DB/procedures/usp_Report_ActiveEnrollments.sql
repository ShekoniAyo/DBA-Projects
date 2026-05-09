/*
Stored Procedure: usp_Report_ActiveEnrollments
Purpose: Returns total active enrollments per course for a given semester alongside
each course's enrollment target
Parameters: @Semester, @Academic_Year
*/

CREATE PROCEDURE dbo.usp_Report_ActiveEnrollments
    @Semester VARCHAR(6),
    @Academic_Year SMALLINT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        c.CourseID AS [Course ID],
        c.CourseName AS [Course Name],
        COUNT(*) AS [Active Enrollments],
        ct.Target AS [Enrollment Target]

    FROM dbo.Courses c
    INNER JOIN dbo.Enrollments e ON e.CourseID = c.CourseID
    INNER JOIN dbo.CourseTargets ct ON ct.CourseID = c.CourseID

    WHERE  e.Semester = @Semester
      AND  e.Academic_Year = @Academic_Year
      AND  e.Status = 'Active'
    GROUP BY c.CourseID, c.CourseName, ct.Target
    ORDER BY [Active Enrollments] DESC;

END;
GO


-- USAGE EXAMPLES
-- Active enrollments for Spring 2026
EXEC dbo.usp_Report_ActiveEnrollments
    @Semester = 'Spring',
    @Academic_Year = 2026;

-- Active enrollments for Fall 2025
EXEC dbo.usp_Report_ActiveEnrollments
    @Semester = 'Fall',
    @Academic_Year = 2025;