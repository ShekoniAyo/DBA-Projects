/*
Stored Procedure: usp_Report_DepartmentDiligence
Purpose: Returns average courses enrolled per student per department across all
semesters, excluding dropped courses.
Also shows the overall university average for comparison.
*/
CREATE PROCEDURE dbo.usp_Report_DepartmentDiligence
AS
BEGIN
    SET NOCOUNT ON;

    WITH StudentSemesterCount AS
    (
        -- Stage 1: Count non-dropped enrollments
        -- per student per semester
        SELECT
            s.DepartmentID,
            e.StudentID,
            e.Semester,
            e.Academic_Year,
            COUNT(*) AS CourseCount
        FROM dbo.Enrollments e
        INNER JOIN dbo.Students s ON e.StudentID = s.StudentID
        WHERE e.Status != 'Dropped'
        GROUP BY s.DepartmentID, e.StudentID, e.Semester, e.Academic_Year
    ),
    DepartmentAverage AS
    (
        -- Stage 2: Average course count per student
        -- across all semesters per department
        SELECT
            DepartmentID,
            AVG(CAST(CourseCount AS FLOAT)) AS AvgCoursesPerStudent
        FROM StudentSemesterCount
        GROUP BY DepartmentID
    )

    -- Final SELECT: Join to Department for names,
    -- add overall university average as benchmark
    SELECT
        d.DepartmentName AS [Department],
        ROUND(da.AvgCoursesPerStudent, 2) AS [Avg Courses Per Student],
        ROUND(
            (SELECT AVG(AvgCoursesPerStudent)
             FROM DepartmentAverage), 2) AS [University Average]

    FROM DepartmentAverage da
    INNER JOIN dbo.Department d ON da.DepartmentID = d.DepartmentID
    ORDER BY da.AvgCoursesPerStudent DESC;

END;
GO


-- USAGE
EXEC dbo.usp_Report_DepartmentDiligence;