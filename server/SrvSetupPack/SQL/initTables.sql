USE [meetMasterData]
GO
/****** Object:  User [meet]    ******/
CREATE USER [meet] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  Table [dbo].[Courses]  ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Courses](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](150) NOT NULL,
	[Description] [nvarchar](500) NOT NULL,
	[Owner] [nvarchar](200) NOT NULL,
	[CreationDate] [datetime] NOT NULL,
	[IsActive] [bit] NOT NULL,
 CONSTRAINT [PK_Courses] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[AllAssignments_MetaOnly]  ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AllAssignments_MetaOnly](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Title] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](500) NOT NULL,
	[StudyCount] [int] NOT NULL,
	[OwnerId] [int] NOT NULL,
	[OwnerEjsId] [uniqueidentifier] NOT NULL,
	[Status] [int] NOT NULL,
	[CreationDate] [datetime] NOT NULL,
	[LastModified] [datetime] NOT NULL,
	[Version] [int] NOT NULL,
	[IsAvailable] [bit] NOT NULL,
	[DataSize] [bigint] NOT NULL,
	[CommentCount] [int] NOT NULL,
	[CourseId] [int] NOT NULL,
	[OwnerName] [nvarchar](100) NOT NULL,
	[DatabaseName] [nchar](150) NOT NULL,
	[InternalDBId] [int] NOT NULL,
	[ExternalAssignmentId] [uniqueidentifier] NULL,
	[ParentAssignmentId] [uniqueidentifier] NULL,
 CONSTRAINT [PK_AllAssignments_MetaOnly] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UserGroups]     ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserGroups](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1000) NOT NULL,
	[AuthorityLevel] [int] NOT NULL,
 CONSTRAINT [PK_UserGroups] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[Logging]    Script Date: 03/31/2009 04:51:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Logging](
	[EventText] [nvarchar](max) NOT NULL,
	[EventTime] [datetime] NOT NULL,
	[EventCategory] [int] NULL
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[Users]    ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Users](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UserName] [varchar](50) NOT NULL,
	[Password] [varchar](512) NOT NULL,
	[FirstName] [nvarchar](100) NOT NULL,
	[LastName] [nvarchar](100) NOT NULL,
	[Email] [varchar](128) NOT NULL,
	[DatabaseName] [varchar](128) NOT NULL,
	[IsLoggedIn] [bit] NOT NULL,
	[IsAccountActive] [bit] NOT NULL,
	[UserGroupId] [int] NOT NULL,
	[UserId] [uniqueidentifier] NOT NULL,
	[IsMarkedDeleted] [bit] NOT NULL,
 CONSTRAINT [PK_Users] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CourseDocuments]     ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CourseDocuments](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Title] [nvarchar](150) NOT NULL,
	[Description] [nvarchar](500) NOT NULL,
	[DocumentId] [uniqueidentifier] NOT NULL,
	[CreationDate] [datetime] NOT NULL,
	[IsAvailable] [bit] NOT NULL,
	[CourseId] [int] NOT NULL,
	[Data] [varbinary](max) NULL,
	[DataSize] [bigint] NULL,
 CONSTRAINT [PK_CourseDocuments] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO

/****** Object:  Table [dbo].[CourseRegistrations]     ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CourseRegistrations](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [int] NOT NULL,
	[CourseId] [int] NOT NULL,
	[RegisteredDate] [datetime] NOT NULL,
 CONSTRAINT [PK_CourseRegistrations] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

/****** Object:  ForeignKey [FK_CourseDocuments_Courses]  ******/
ALTER TABLE [dbo].[CourseDocuments]  WITH CHECK ADD  CONSTRAINT [FK_CourseDocuments_Courses] FOREIGN KEY([CourseId])
REFERENCES [dbo].[Courses] ([Id])
GO
ALTER TABLE [dbo].[CourseDocuments] CHECK CONSTRAINT [FK_CourseDocuments_Courses]
GO
/****** Object:  ForeignKey [FK_CourseRegistrations_Courses]      ******/
ALTER TABLE [dbo].[CourseRegistrations]  WITH CHECK ADD  CONSTRAINT [FK_CourseRegistrations_Courses] FOREIGN KEY([CourseId])
REFERENCES [dbo].[Courses] ([Id])
GO
ALTER TABLE [dbo].[CourseRegistrations] CHECK CONSTRAINT [FK_CourseRegistrations_Courses]
GO
/****** Object:  ForeignKey [FK_CourseRegistrations_Users]      ******/
ALTER TABLE [dbo].[CourseRegistrations]  WITH CHECK ADD  CONSTRAINT [FK_CourseRegistrations_Users] FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [dbo].[CourseRegistrations] CHECK CONSTRAINT [FK_CourseRegistrations_Users]
GO
/****** Object:  ForeignKey [FK_Users_UserGroups]      ******/
ALTER TABLE [dbo].[Users]  WITH CHECK ADD  CONSTRAINT [FK_Users_UserGroups] FOREIGN KEY([UserGroupId])
REFERENCES [dbo].[UserGroups] ([Id])
GO
ALTER TABLE [dbo].[Users] CHECK CONSTRAINT [FK_Users_UserGroups]
GO
