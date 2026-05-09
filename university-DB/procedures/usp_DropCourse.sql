-- =============================================
-- Stored Procedure: usp_DropCourse
-- Purpose: Safely drops a student from a course
--          for the current semester with full
--          validation and transaction control
-- =============================================

CREATE PROCEDURE dbo.usp_DropCourse
    @StudentID INT,
    @CourseID INT,
    @DropDeadline DATE = '2026-03-31'   -- Update at start of each semester
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
    DECLARE @IsEnrolled INT;
    DECLARE @CurrentStatus VARCHAR(10);

    BEGIN TRY

        -- ─────────────────────────────────────
        -- CHECK 1: Is today within the drop window?
        -- Guard clause - fails fast if deadline passed
        -- ─────────────────────────────────────
        IF CAST(GETDATE() AS DATE) > @DropDeadline
            THROW 50001, 'Drop failed: The course drop deadline has passed for this semester.', 1;

        -- ─────────────────────────────────────
        -- CHECK 2: Is the student enrolled in
        --          this course this semester?
        -- ─────────────────────────────────────
        SELECT @CurrentStatus = Status
        FROM dbo.Enrollments
        WHERE StudentID = @StudentID
          AND CourseID = @CourseID
          AND Semester = @Semester
          AND Academic_Year = @Academic_Year;

        IF @CurrentStatus IS NULL
            THROW 50002, 'Drop failed: No enrollment record found for this student in this course for the current semester.', 1;

        -- ─────────────────────────────────────
        -- CHECK 3: Has the course already been dropped?
        -- ─────────────────────────────────────
        IF @CurrentStatus = 'Dropped'
            THROW 50003, 'Drop failed: This course has already been dropped by the student.', 1;

        -- ─────────────────────────────────────
        -- All checks passed — open transaction
        -- and perform the drop
        -- ─────────────────────────────────────
        BEGIN TRANSACTION;

            UPDATE dbo.Enrollments
            SET Status = 'Dropped',
                   Grade  = NULL
            WHERE  StudentID = @StudentID
              AND  CourseID = @CourseID
              AND  Semester = @Semester
              AND  Academic_Year = @Academic_Year;

        COMMIT TRANSACTION;

        PRINT 'Course drop successful: Student ' + CAST(@StudentID AS VARCHAR) +
              ' has been dropped from Course ' + CAST(@CourseID AS VARCHAR) +
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

-- Successful drop (Student 111 is Active in Course 3, Spring 2026)
EXEC dbo.usp_DropCourse
    @StudentID = 111,
    @CourseID  = 3;

-- Should fail: Drop deadline has passed
EXEC dbo.usp_DropCourse
    @StudentID    = 112,
    @CourseID     = 7,
    @DropDeadline = '2026-01-01';

-- Should fail: Student not enrolled in this course this semester
EXEC dbo.usp_DropCourse
    @StudentID = 111,
    @CourseID  = 99;

-- Should fail: Course already dropped (run the first example twice)
EXEC dbo.usp_DropCourse
    @StudentID = 111,
    @CourseID  = 3;