-- =============================================
-- Stored Procedure: usp_Report_EnrollmentRate
-- Purpose: Classifies each course as High, Medium
--          or Low enrollment based on percentage
--          of target enrollment reached
-- Parameters: @Semester, @Academic_Year
-- =============================================

CREATE OR ALTER PROCEDURE dbo.usp_Report_EnrollmentRate
    @Semester VARCHAR(6),
    @Academic_Year SMALLINT,
    @Status VARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

    WITH EnrollmentData AS
    (
        SELECT
            c.CourseName,
            ct.Target,
            COUNT(e.StudentID) AS TotalEnrolled,
            (CAST(COUNT(e.StudentID) AS FLOAT) / ct.Target) * 100 AS PctOfTarget

        FROM dbo.Enrollments e
        INNER JOIN dbo.Courses c  ON e.CourseID = c.CourseID
        INNER JOIN dbo.CourseTargets ct ON e.CourseID = ct.CourseID

        WHERE  e.Semester = @Semester
          AND  e.Academic_Year = @Academic_Year
          AND  e.Status = @Status

        GROUP BY c.CourseName, ct.Target
    )

    SELECT
        CourseName AS [Course Name],
        Target AS [Enrollment Target],
        TotalEnrolled AS [Total Enrolled],
        ROUND(PctOfTarget, 2) AS [% of Target],
        CASE
            WHEN PctOfTarget >= 70 THEN 'High'
            WHEN PctOfTarget <= 50 THEN 'Low'
            ELSE 'Medium'
        END AS [Enrollment Status]

    FROM EnrollmentData

    ORDER BY PctOfTarget DESC;

END;
GO


-- =============================================
-- USAGE EXAMPLES
-- =============================================

-- Enrollment rate for Spring 2026
EXEC dbo.usp_Report_EnrollmentRate
    @Semester = 'Spring',
    @Academic_Year = 2026,
    @Status = 'Active';

-- Enrollment rate for Fall 2025
EXEC dbo.usp_Report_EnrollmentRate
    @Semester = 'Fall',
    @Academic_Year = 2025,
    @Status = 'Completed';