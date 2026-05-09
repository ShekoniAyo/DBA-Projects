CREATE TABLE [dbo].[Courses](
	[CourseID] [int] IDENTITY(1,1) NOT NULL,
	[CourseName] [varchar](50) NOT NULL,
	[InstructorID] [int] NOT NULL,
	[Credits] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Courses] ADD  CONSTRAINT [PK_Courses] PRIMARY KEY CLUSTERED 
(
	[CourseID] ASC
)
GO

ALTER TABLE [dbo].[Courses] 
ADD CONSTRAINT [FK_5] FOREIGN KEY([InstructorID]) REFERENCES [dbo].[Instructors] ([InstructorID])
GO

ALTER TABLE [dbo].[Courses] 
CHECK CONSTRAINT [FK_5]
GO
