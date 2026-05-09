-- VIEW 1: vw_EnrollmentDetails
-- Purpose: Full enrollment information combining Enrollments, Students, Courses and Department for easy querying

CREATE OR ALTER VIEW dbo.vw_EnrollmentDetails AS

    SELECT
        e.EnrollmentID AS [Enrollment ID],
        e.StudentID AS [Student ID],
        s.First_Name AS [First Name],
        s.Last_Name AS [Last Name],
        s.Email AS [Email],
        d.DepartmentName AS [Department],
        c.CourseName AS [Course Name],
        e.Semester AS [Semester],
        e.Academic_Year AS [Academic Year],
        e.Grade AS [Grade],
        e.Status AS [Status]
    FROM dbo.Enrollments  e
    INNER JOIN dbo.Students s ON e.StudentID = s.StudentID
    INNER JOIN dbo.Courses c ON e.CourseID = c.CourseID
    INNER JOIN dbo.Department d ON s.DepartmentID = d.DepartmentID;
GO


-- VIEW 2: vw_StudentDetails
-- Purpose: Student information with Department name instead of DepartmentID

CREATE OR ALTER VIEW dbo.vw_StudentDetails AS
    SELECT
        s.StudentID AS [Student ID],
        s.First_Name AS [First Name],
        s.Last_Name AS [Last Name],
        s.Email AS [Email],
        d.DepartmentName AS [Department]
    FROM dbo.Students s
    INNER JOIN dbo.Department d ON s.DepartmentID = d.DepartmentID;
GO


-- VIEW 3: vw_InstructorDetails
-- Purpose: Instructor information with their Department and Course details

CREATE OR ALTER VIEW dbo.vw_InstructorDetails AS
    SELECT
        i.InstructorID AS [Instructor ID],
        i.Name AS [Instructor Name],
        d.DepartmentName AS [Department],
        c.CourseName AS [Course Name],
        c.Credits AS [Credits]
    FROM dbo.Instructors  i
    INNER JOIN dbo.Department d ON i.DepartmentID = d.DepartmentID
    INNER JOIN dbo.Courses c ON c.InstructorID = i.InstructorID;
GO


-- USAGE EXAMPLES
-- View 1: All Spring 2026 active enrollments
SELECT *
FROM dbo.vw_EnrollmentDetails
WHERE Semester = 'Spring'
AND [Academic Year] = 2026
AND Status = 'Active';

-- View 1: Full history for a specific student
SELECT *
FROM dbo.vw_EnrollmentDetails
WHERE [Student ID] = 1
ORDER BY [Academic Year], [Semester];

-- View 2: All students in Computer Science
SELECT *
FROM dbo.vw_StudentDetails
WHERE Department = 'Computer Science';

-- View 3: All instructors in Mathematics
SELECT *
FROM dbo.vw_InstructorDetails
WHERE Department = 'Mathematics';