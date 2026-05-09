# University Database System

A mini university database system built on **Microsoft SQL Server**, designed to simulate the core data management needs of a real university environment. The project covers schema design, data integrity enforcement, transactional data manipulation, reporting, and reusable query objects.

---

## Table of Contents

- [Project Overview](#project-overview)
- [Database Schema](#database-schema)
- [Data Population](#data-population)
- [Stored Procedures](#stored-procedures)
- [Views](#views)
- [User Defined Functions](#user-defined-functions)
- [Key Design Decisions](#key-design-decisions)
- [Project Summary](#project-summary)

---

## Project Overview

| Detail | Value |
|---|---|
| Platform | Microsoft SQL Server |
| Database | TestDB |
| Schema | dbo |

The system manages five core entities; **Departments, Instructors, Courses, Students, and Enrollments**, with a supporting `CourseTargets` table. It simulates real-world university operations including student registration, course dropping, enrollment reporting, and academic performance tracking.

---

## Database Schema

### Tables

| Table | Rows | Description |
|---|---|---|
| `dbo.Department` | 10 | University departments |
| `dbo.Instructors` | 35 | Instructors, max 4 per department |
| `dbo.Courses` | 30 | Courses, 3 per department |
| `dbo.Students` | 150 | Students across all departments; 30 newly admitted with no enrollments |
| `dbo.Enrollments` | 900+ | Enrollment records spanning Fall 2019 to Spring 2026 |
| `dbo.CourseTargets` | 30 | Target enrollment per course, used for reporting |

### Entity Relationship Chain

Tables must be populated in this order to respect foreign key dependencies:

```
Department → Instructors → Courses → Students → Enrollments
```

### Enrollments Table Design

The `Enrollments` table was designed to reflect the full lifecycle of a student's enrollment:

| Column | Type | Constraint | Notes |
|---|---|---|---|
| `EnrollmentID` | INT | PK, IDENTITY | Auto-generated |
| `StudentID` | INT | FK → Students | Not null |
| `CourseID` | INT | FK → Courses | Not null |
| `Semester` | VARCHAR(6) | CHECK: Fall, Spring, Summer | Not null |
| `Academic_Year` | SMALLINT | CHECK: BETWEEN 2019 AND 2026 | Not null |
| `Grade` | CHAR(1) | CHECK: A, B, C, D, F | Nullable — NULL for Active/Dropped |
| `Status` | VARCHAR(10) | CHECK: Active, Completed, Failed, Dropped | DEFAULT Active |

> `Date_enrolled` was replaced by `Semester + Academic_Year` for structured, queryable time data.

---

## Data Population

Data was populated using a single authoritative script in GO batches, respecting FK dependency order. The dataset simulates realistic scenarios across multiple academic years.

### Student Cohorts

| Cohort | Students | Semesters | Status Mix |
|---|---|---|---|
| Cohort 1 | 1 – 30 | Fall 2019, Spring 2020 | Completed, Failed |
| Cohort 2 | 31 – 60 | Fall 2020, Spring 2021 | Completed, Failed, Dropped |
| Cohort 3 | 61 – 90 | Fall 2021, Spring 2022 | Completed, Failed, Dropped |
| Cohort 4 | 91 – 110 | Fall 2023, Spring 2024, Fall 2024 | Completed, Dropped |
| Cohort 5 | 111 – 120 | Fall 2025, Spring 2026 | Completed, Active |
| New Admits | 121 – 150 | None | No enrollments |

Student names are culturally diverse, representing Nigerian, Japanese, Brazilian, Arab, Indian, Italian, British, and other backgrounds.

---

## Stored Procedures

### Transaction Procedures

#### `usp_EnrollStudent`

Enrolls a student into a course for the current semester with full validation.

**Parameters:** `@StudentID INT`, `@CourseID INT`, `@EnrollDeadline DATE`

> `@Semester` and `@Academic_Year` are declared internally as a deliberate access control measures, callers cannot enroll students into arbitrary semesters.

**Validation Checks:**

| # | Check | Error |
|---|---|---|
| 1 | Enrollment deadline has not passed | 50001 |
| 2 | Student exists in the system | 50002 |
| 3 | Course exists in the system | 50003 |
| 4 | Not already enrolled (excluding Dropped) | 50004 |
| 5 | 7-course cap not exceeded (excluding Dropped) | 50005 |

```sql
EXEC dbo.usp_EnrollStudent
    @StudentID      = 121,
    @CourseID       = 5;
```

---

#### `usp_DropCourse`

Drops a student from an active course enrollment for the current semester.

**Parameters:** `@StudentID INT`, `@CourseID INT`, `@DropDeadline DATE`

> `@Semester` and `@Academic_Year` are declared internally. On drop, `Status` is set to `Dropped` and `Grade` is set to `NULL`.

**Validation Checks:**

| # | Check | Error |
|---|---|---|
| 1 | Drop deadline has not passed *(guard clause — fails fast)* | 50001 |
| 2 | Student is enrolled in this course this semester | 50002 |
| 3 | Course has not already been dropped | 50003 |

```sql
EXEC dbo.usp_DropCourse
    @StudentID    = 111,
    @CourseID     = 3;
```

> Both procedures use `TRY/CATCH/THROW` with a `@@TRANCOUNT > 0` guard before `ROLLBACK`, and re-raise errors to the caller.

---

### Report Procedures

| Procedure | Purpose | Parameters |
|---|---|---|
| `usp_Report_CourseEnrollment` | Total and average enrollments per course | `@Semester`, `@Academic_Year`, `@Status` |
| `usp_Report_EnrollmentRate` | Classifies courses as High / Medium / Low vs target | `@Semester`, `@Academic_Year` |
| `usp_Report_FailureRate` | Failure rate per course; labels High (≥15%) or Okay | `@Semester`, `@Academic_Year` |
| `usp_Report_StudentCourseSheet` | All courses a student is taking in a semester | `@StudentID`, `@Semester`, `@Academic_Year` |
| `usp_Report_ActiveEnrollments` | Active enrollments vs target per course | `@Semester`, `@Academic_Year` |
| `usp_Report_DepartmentDiligence` | Avg courses per student per department across all semesters | None |

#### Enrollment Rate Classification

```
>= 70%  →  High
50–69%  →  Medium
<= 50%  →  Low
```

#### Failure Rate Threshold

```
>= 15%  →  High
< 15%   →  Okay
```

> Failure rate denominator = Completed + Failed only. Dropped students are excluded as they never finished the course.

---

## Views

Views abstract the underlying schema and simplify querying. They return full result sets; callers filter using `WHERE` clauses.

| View | Tables Joined | Purpose |
|---|---|---|
| `vw_EnrollmentDetails` | Enrollments, Students, Courses, Department | Full enrollment picture including student names, department, course, grade and status |
| `vw_StudentDetails` | Students, Department | Student records with department name instead of DepartmentID |
| `vw_InstructorDetails` | Instructors, Department, Courses | Instructor records with department and course details |

**Example — filter the view at query time:**

```sql
SELECT *
FROM dbo.vw_EnrollmentDetails
WHERE Semester = 'Spring'
AND Academic_Year = 2026
AND   Status = 'Active';
```

---

## User Defined Functions

### `fn_GradePoints` — Scalar Function

Calculates grade points for a single course by multiplying the numerical grade value by the course credits.

**Parameters:** `@Grade CHAR(1)`, `@Credits INT`  
**Returns:** `DECIMAL(4,2)` — `NULL` if no grade assigned

| Grade | Value | Example (3 Credits) |
|---|---|---|
| A | 4.0 | 12.00 |
| B | 3.0 | 9.00 |
| C | 2.0 | 6.00 |
| D | 1.0 | 3.00 |
| F | 0.0 | 0.00 |
| NULL | NULL | NULL |

```sql
-- Inline usage against a view
SELECT
    [Course Name],
    dbo.fn_GradePoints([Grade], [Credits]) AS [Grade Points]
FROM dbo.vw_EnrollmentDetails
WHERE [Student ID] = 1
AND [Status] = 'Completed';
```

---

### `fn_StudentSemesterResults` — Inline Table-Valued Function

Returns all courses taken by a student in a given semester with grade points calculated per course using `fn_GradePoints`.

**Parameters:** `@StudentID INT`, `@Semester VARCHAR(6)`, `@Academic_Year SMALLINT`  
**Returns:** `CourseID`, `CourseName`, `Credits`, `Grade`, `Status`, `Grade Points`

```sql
-- Total grade points earned in a semester
SELECT
    SUM([Credits]) AS [Total Credits],
    SUM([Grade Points]) AS [Total Grade Points]
FROM dbo.fn_StudentSemesterResults(1, 'Fall', 2019)
WHERE [Status] = 'Completed';
```

---

## Key Design Decisions

| Decision | Rationale |
|---|---|
| `Semester + Academic_Year` instead of `Date_enrolled` | More structured and queryable; reflects how universities actually track academic periods |
| `Grade` is nullable | Active and Dropped enrollments legitimately have no grade; NULL is semantically correct |
| `Status` defaults to `Active` | Every new enrollment starts as Active; no manual input required at registration |
| Semester/Year declared internally in transaction procedures | Prevents callers from enrolling or dropping in arbitrary semesters; deliberate access control |
| Enrollment and drop deadlines as parameters with defaults | Hardcoded defaults reflect school policy; parameter allows override without editing the procedure body |
| `CourseTargets` as a separate table | 30 courses each with different targets; a table is more maintainable than 30 hardcoded CASE conditions |
| Dropped enrollments excluded from 7-course cap | A dropped course no longer occupies a slot; students should be able to re-enroll without penalty |
| `@Status` parameterised in report procedures | Hardcoding `Active` returns empty results for historical semesters; parameterising makes reports work across all time periods |

---

## Project Summary

| Component | Count | Details |
|---|---|---|
| Tables | 6 | Department, Instructors, Courses, Students, Enrollments, CourseTargets |
| Transaction Procedures | 2 | usp_EnrollStudent, usp_DropCourse |
| Report Procedures | 6 | CourseEnrollment, EnrollmentRate, FailureRate, StudentCourseSheet, ActiveEnrollments, DepartmentDiligence |
| Views | 3 | vw_EnrollmentDetails, vw_StudentDetails, vw_InstructorDetails |
| User Defined Functions | 2 | fn_GradePoints (Scalar), fn_StudentSemesterResults (TVF) |
| Total Data Rows | 1,100+ | 150 students, 35 instructors, 30 courses, 10 departments, 900+ enrollments |

---

*University Database System — Built with Microsoft SQL Server*
