CREATE TABLE [dbo].[Students](
	[StudentID] [int] IDENTITY(1,1) NOT NULL,
	[First_Name] [varchar](50) NOT NULL,
	[Last_Name] [varchar](50) NOT NULL,
	[Email] [varchar](70) NULL,
	[DepartmentID] [int] NOT NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Students] 
ADD CONSTRAINT [PK_Students] PRIMARY KEY CLUSTERED 
(
	[StudentID] ASC
)
GO

ALTER TABLE [dbo].[Students]
ADD CONSTRAINT [FK_2] FOREIGN KEY([DepartmentID]) REFERENCES [dbo].[Department] ([DepartmentID])
GO

ALTER TABLE [dbo].[Students] 
CHECK CONSTRAINT [FK_2]
GO
