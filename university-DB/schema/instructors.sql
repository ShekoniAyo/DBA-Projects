CREATE TABLE [dbo].[Instructors](
	[InstructorID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](70) NOT NULL,
	[DepartmentID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Instructors] 
ADD CONSTRAINT [PK_Instructors] PRIMARY KEY CLUSTERED 
(
	[InstructorID] ASC
)

ALTER TABLE [dbo].[Instructors]  
ADD CONSTRAINT [FK_1] FOREIGN KEY([DepartmentID]) REFERENCES [dbo].[Department] ([DepartmentID])
GO

ALTER TABLE [dbo].[Instructors] CHECK CONSTRAINT [FK_1]
GO
