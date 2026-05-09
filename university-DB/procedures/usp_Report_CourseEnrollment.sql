-- =============================================
-- Stored Procedure: usp_Report_CourseEnrollment
-- Purpose: Returns total active enrollments per 
--          course alongside the university-wide
--          average enrollment for that semester
-- Parameters: @Semester, @Academic_Year
-- =============================================

CREATE OR ALTER PROCEDURE dbo.usp_Report_CourseEnrollment
    @Semester VARCHAR(6),
    @Academic_Year SMALLINT,
    @Status VARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        c.CourseName AS [Course Name],
        COUNT(e.StudentID) AS [Total Enrollments],
        (
            SELECT ROUND(CAST(COUNT(*) AS FLOAT) / COUNT(DISTINCT CourseID), 2)
            FROM dbo.Enrollments
            WHERE Semester = @Semester
              AND Academic_Year = @Academic_Year
              AND Status = @Status
        ) AS [Avg Enrollment Per Course]

    FROM dbo.Enrollments e
    INNER JOIN dbo.Courses c ON e.CourseID = c.CourseID

    WHERE e.Semester = @Semester
      AND e.Academic_Year = @Academic_Year
      AND e.Status = @Status

    GROUP BY c.CourseName

    ORDER BY [Total Enrollments] DESC;

END;
GO


-- =============================================
-- USAGE EXAMPLES
-- =============================================

-- Active enrollments for Spring 2026
EXEC dbo.usp_Report_CourseEnrollment
    @Semester = 'Spring',
    @Academic_Year = 2026,
    @Status = 'Active';

-- Active enrollments for Fall 2025
EXEC dbo.usp_Report_CourseEnrollment
    @Semester = 'Fall',
    @Academic_Year = 2025,
    @Status = 'Completed';