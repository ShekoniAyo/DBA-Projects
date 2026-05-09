-- =============================================
-- Function: fn_GradePoints
-- Purpose: Calculates grade points for a single
--          course by multiplying the numerical
--          grade value by the course credits
-- Inputs:  @Grade CHAR(1), @Credits INT
-- Returns: DECIMAL(4,2) or NULL if no grade
-- =============================================

CREATE OR ALTER FUNCTION dbo.fn_GradePoints
(
    @Grade CHAR(1),
    @Credits INT
)
RETURNS DECIMAL(4,2)
AS
BEGIN

    DECLARE @GradeValue DECIMAL(4,2);

    -- Mapping letter grade to numerical value
    SET @GradeValue = CASE @Grade
        WHEN 'A' THEN 4.0
        WHEN 'B' THEN 3.0
        WHEN 'C' THEN 2.0
        WHEN 'D' THEN 1.0
        WHEN 'F' THEN 0.0
        ELSE NULL   -- Handles NULL grades (Active/Dropped)
    END;

    -- Return NULL if no grade assigned
    IF @GradeValue IS NULL
        RETURN NULL;

    RETURN @GradeValue * @Credits;

END;
GO


-- USAGE EXAMPLES
-- 1. Grade points for a single course
SELECT dbo.fn_GradePoints('A', 4) AS [Grade Points];   -- Returns 16.00
SELECT dbo.fn_GradePoints('B', 3) AS [Grade Points];   -- Returns 9.00
SELECT dbo.fn_GradePoints(NULL, 3) AS [Grade Points];  -- Returns NULL

-- 2. Used inline against vw_EnrollmentDetails
--    Shows grade points per course per student
SELECT
    [Student ID],
    [First Name],
    [Last Name],
    [Course Name],
    [Credits],
    [Grade],
    dbo.fn_GradePoints([Grade], [Credits]) AS [Grade Points]
FROM dbo.vw_EnrollmentDetails
WHERE [Student ID] = 1
AND [Status] = 'Completed'
ORDER BY [Academic Year], [Semester];

-- 3. Total grade points earned by a student across all completed courses
SELECT
    [Student ID],
    [First Name],
    [Last Name],
    SUM(dbo.fn_GradePoints([Grade], [Credits])) AS [Total Grade Points],
    SUM([Credits]) AS [Total Credits], 
    ROUND(SUM(dbo.fn_GradePoints([Grade], [Credits])) / SUM([Credits]), 2) AS [GPA]
FROM dbo.vw_EnrollmentDetails
WHERE [Student ID] = 1
AND [Status] = 'Completed'
GROUP BY [Student ID], [First Name], [Last Name];