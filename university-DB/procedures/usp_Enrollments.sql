-- =============================================
-- Stored Procedure: usp_EnrollStudent (Updated)
-- Purpose: Safely enrolls a student into a course
--          for the current semester with full
--          validation and transaction control
-- Changes: 
--   - Enrollment deadline guard clause added
--   - Semester and Academic_Year moved to
--     internal variables for consistency
--     with usp_DropCourse
-- =============================================

CREATE OR ALTER PROCEDURE dbo.usp_EnrollStudent
    @StudentID INT,
    @CourseID INT,
    @EnrollDeadline DATE = '2026-02-28'   -- Update at start of each semester
AS
BEGIN
    SET NOCOUNT ON;

    -- ─────────────────────────────────────────
    -- Hardcoded current semester values
    -- Update these at the start of each semester
    -- ─────────────────────────────────────────
    DECLARE @Semester VARCHAR(6) = 'Spring';
    DECLARE @Academic_Year SMALLINT  = 2026;

    -- ─────────────────────────────────────────
    -- DECLARE variables for validation checks
    -- ─────────────────────────────────────────
    DECLARE @StudentExists  INT;
    DECLARE @CourseExists INT;
    DECLARE @EnrollmentCount INT;
    DECLARE @AlreadyEnrolled INT;

    BEGIN TRY

        -- ─────────────────────────────────────
        -- CHECK 1: Is today within the enrollment window?
        -- Guard clause - fails fast if deadline passed
        -- ─────────────────────────────────────
        IF CAST(GETDATE() AS DATE) > @EnrollDeadline
            THROW 50001, 'Enrollment failed: The enrollment deadline has passed for this semester.', 1;

        -- ─────────────────────────────────────
        -- CHECK 2: Does the student exist?
        -- ─────────────────────────────────────
        SELECT @StudentExists = COUNT(*)
        FROM dbo.Students
        WHERE StudentID = @StudentID;

        IF @StudentExists = 0
            THROW 50002, 'Enrollment failed: Student ID does not exist in the system.', 1;

        -- ─────────────────────────────────────
        -- CHECK 3: Does the course exist?
        -- ─────────────────────────────────────
        SELECT @CourseExists = COUNT(*)
        FROM dbo.Courses
        WHERE CourseID = @CourseID;

        IF @CourseExists = 0
            THROW 50003, 'Enrollment failed: Course ID does not exist in the system.', 1;

        -- ─────────────────────────────────────
        -- CHECK 4: Has the student already enrolled
        --          in this course this semester?
        -- ─────────────────────────────────────
        SELECT @AlreadyEnrolled = COUNT(*)
        FROM dbo.Enrollments
        WHERE StudentID = @StudentID
          AND CourseID = @CourseID
          AND Semester = @Semester
          AND Academic_Year = @Academic_Year
          AND Status != 'Dropped';     -- Dropped students can re-enroll

        IF @AlreadyEnrolled > 0
            THROW 50004, 'Enrollment failed: Student is already enrolled in this course for the current semester.', 1;

        -- ─────────────────────────────────────
        -- CHECK 5: Has the student hit the 7-course
        --          cap for this semester?
        -- ─────────────────────────────────────
        SELECT @EnrollmentCount = COUNT(*)
        FROM dbo.Enrollments
        WHERE StudentID = @StudentID
          AND Semester = @Semester
          AND Academic_Year = @Academic_Year
          AND Status != 'Dropped';     -- Dropped courses don't count toward cap

        IF @EnrollmentCount >= 7
            THROW 50005, 'Enrollment failed: Student has reached the maximum of 7 courses for this semester.', 1;

        -- ─────────────────────────────────────
        -- All checks passed — open transaction
        -- and perform the enrollment
        -- ─────────────────────────────────────
        BEGIN TRANSACTION;

            INSERT INTO dbo.Enrollments (StudentID, CourseID, Semester, Academic_Year, Grade, Status)
            VALUES (@StudentID, @CourseID, @Semester, @Academic_Year, NULL, 'Active');

        COMMIT TRANSACTION;

        PRINT 'Enrollment successful: Student ' + CAST(@StudentID AS VARCHAR) +
              ' has been enrolled in Course ' + CAST(@CourseID AS VARCHAR) +
              ' for ' + @Semester + ' ' + CAST(@Academic_Year AS VARCHAR) + '.';

    END TRY
    BEGIN CATCH

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;

    END CATCH;
END;
GO


-- =============================================
-- USAGE EXAMPLES
-- =============================================

-- Successful enrollment
EXEC dbo.usp_EnrollStudent
    @StudentID = 121,
    @CourseID  = 5;

-- Should fail: Enrollment deadline has passed
EXEC dbo.usp_EnrollStudent
    @StudentID      = 121,
    @CourseID       = 5,
    @EnrollDeadline = '2026-01-01';

-- Should fail: Student does not exist
EXEC dbo.usp_EnrollStudent
    @StudentID = 999,
    @CourseID  = 5;

-- Should fail: Course does not exist
EXEC dbo.usp_EnrollStudent
    @StudentID = 121,
    @CourseID  = 999;

-- Should fail: Duplicate enrollment
EXEC dbo.usp_EnrollStudent
    @StudentID = 121,
    @CourseID  = 5;

-- Re-enrollment after drop should SUCCEED
-- First drop the course
EXEC dbo.usp_DropCourse
    @StudentID = 121,
    @CourseID  = 5;
-- Then re-enroll
EXEC dbo.usp_EnrollStudent
    @StudentID = 121,
    @CourseID  = 5;