CREATE TABLE [dbo].[Enrollments](
	[EnrollmentID] [int] IDENTITY(1,1) NOT NULL,
	[StudentID] [int] NOT NULL,
	[CourseID] [int] NOT NULL,
	[Semester] [varchar](6) NOT NULL,
	[Academic_Year] [smallint] NULL,
	[Grade] [char](1) NULL,
	[Status] [varchar](10) NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Enrollments] ADD CONSTRAINT [PK_Enrollments] PRIMARY KEY CLUSTERED 
(
	[EnrollmentID] ASC
)
GO

ALTER TABLE [dbo].[Enrollments] ADD CONSTRAINT [DEFAULT_Enrollments_Status]  DEFAULT ('Active') FOR [Status]
GO

ALTER TABLE [dbo].[Enrollments] 
ADD CONSTRAINT [FK_3] FOREIGN KEY([StudentID]) REFERENCES [dbo].[Students] ([StudentID])
GO

ALTER TABLE [dbo].[Enrollments] CHECK CONSTRAINT [FK_3]
GO

ALTER TABLE [dbo].[Enrollments] 
ADD CONSTRAINT [FK_4] FOREIGN KEY([CourseID]) REFERENCES [dbo].[Courses] ([CourseID])
GO

ALTER TABLE [dbo].[Enrollments] CHECK CONSTRAINT [FK_4]
GO

ALTER TABLE [dbo].[Enrollments] 
ADD CONSTRAINT [CK_Enrollments_Grade] CHECK (([Grade]='F' OR [Grade]='D' OR [Grade]='C' OR [Grade]='B' OR [Grade]='A'))
GO

ALTER TABLE [dbo].[Enrollments] CHECK CONSTRAINT [CK_Enrollments_Grade]
GO

ALTER TABLE [dbo].[Enrollments] 
ADD CONSTRAINT [CK_Enrollments_Semester] CHECK  (([Semester]='Spring' OR [Semester]='Fall' OR [Semester]='Summer'))
GO

ALTER TABLE [dbo].[Enrollments] CHECK CONSTRAINT [CK_Enrollments_Semester]
GO

ALTER TABLE [dbo].[Enrollments] 
ADD CONSTRAINT [CK_Enrollments_Status] 
CHECK  (([Status]='Dropped' OR [Status]='Failed' OR [Status]='Completed' OR [Status]='Active'))
GO

ALTER TABLE [dbo].[Enrollments] 
CHECK CONSTRAINT [CK_Enrollments_Status]
GO

ALTER TABLE [dbo].[Enrollments]  WITH CHECK 
ADD CONSTRAINT [CK_Enrollments_Year] CHECK (([Academic_Year]>=(2019) AND [Academic_Year]<=(2026)))
GO

ALTER TABLE [dbo].[Enrollments]
CHECK CONSTRAINT [CK_Enrollments_Year]
GO
