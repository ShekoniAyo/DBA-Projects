CREATE TABLE [dbo].[CourseTargets](
	[CourseID] [int] NOT NULL,
	[Target] [int] NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[CourseTargets] ADD PRIMARY KEY CLUSTERED 
(
	[CourseID] ASC
)
GO

ALTER TABLE [dbo].[CourseTargets]
ADD CONSTRAINT [FK_6] FOREIGN KEY([CourseID]) REFERENCES [dbo].[Courses] ([CourseID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[CourseTargets] 
CHECK CONSTRAINT [FK_6]
GO
