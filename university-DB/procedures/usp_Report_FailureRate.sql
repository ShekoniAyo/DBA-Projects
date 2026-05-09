-- =============================================
-- Stored Procedure: usp_Report_FailureRate
-- Purpose: Returns failure rate per course for
--          a given semester, labelled as
--          High (>=15%) or Okay (<15%)
-- Denominator: Students who Completed or Failed
--              (excludes Dropped students)
-- Parameters: @Semester, @Academic_Year
-- =============================================

CREATE PROCEDURE dbo.usp_Report_FailureRate
    @Semester VARCHAR(6),
    @Academic_Year SMALLINT
AS
BEGIN
    SET NOCOUNT ON;

    WITH table1 AS
    (
        -- Denominator: all students who finished the course
        SELECT
            e.CourseID,
            c.CourseName AS Course,
            COUNT(*) AS TotalFinished
        FROM dbo.Enrollments e
        INNER JOIN dbo.Courses c ON e.CourseID = c.CourseID
        WHERE e.Academic_Year = @Academic_Year
          AND e.Semester = @Semester
          AND e.Status IN ('Completed', 'Failed')
        GROUP BY e.CourseID, c.CourseName
    ),
    table2 AS
    (
        -- Numerator: only students who failed
        SELECT
            e.CourseID,
            c.CourseName AS Course,
            COUNT(*) AS TotalFailed
        FROM dbo.Enrollments e
        INNER JOIN dbo.Courses c ON e.CourseID = c.CourseID
        WHERE  e.Academic_Year = @Academic_Year
          AND e.Semester = @Semester
          AND e.Grade = 'F'
          AND e.Status = 'Failed'
        GROUP BY e.CourseID, c.CourseName
    ),
    table3 AS
    (
        -- Calculate failure rate per course
        SELECT
            a.Course,
            a.TotalFinished,
            b.TotalFailed,
            (CAST(b.TotalFailed AS FLOAT) / a.TotalFinished) * 100 AS FailureRate
        FROM table1 a
        INNER JOIN table2 b ON a.CourseID = b.CourseID
    )

    -- Final SELECT: classify each course
    SELECT
        Course AS [Course Name],
        TotalFinished AS [Students Finished],
        TotalFailed AS [Students Failed],
        ROUND(FailureRate, 2) AS [Failure Rate %],
        CASE
            WHEN FailureRate >= 15 THEN 'High'
            ELSE 'Okay'
        END AS [Status]
    FROM table3
    ORDER BY FailureRate DESC;
END;
GO



-- USAGE EXAMPLES
-- Failure rate for Fall 2019
EXEC dbo.usp_Report_FailureRate
    @Semester = 'Fall',
    @Academic_Year = 2019;

-- Failure rate for Spring 2020
EXEC dbo.usp_Report_FailureRate
    @Semester = 'Spring',
    @Academic_Year = 2020;