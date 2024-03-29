USE [meetMasterData]
GO
/****** Object:  StoredProcedure [dbo].[RegisterNewCourse]     ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[RegisterNewCourse]

	@Name nvarchar(150),
	@Description nvarchar(500),
	@Owner nvarchar(200),	
	@CreationDate datetime,
	@IsActive bit

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
	if exists (Select null from Courses where Name like @Name)
		Begin
		  Return 1      -- 1 = Course Name Exits
		End
	else
		Begin
		  Insert into Courses 
			Values (
						@Name,
						@Description,
						@Owner,
						@CreationDate,
						@IsActive
					)
		End

		Return 0      -- 0 = Ok
END
GO

/****** Object:  StoredProcedure [dbo].[GetAllAssignmentsForUser]    ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[GetAllAssignmentsForUser]

	@UserId uniqueidentifier,
	@IncludeNotAvailable bit		

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
		--Updated 080318 added OwnerEjsId field
		--Updated 080318 added ExternalAssignmentId field
		--Updated 080318 added ParentAssignmentId field
	if(@IncludeNotAvailable = 1)
       Begin
		  SELECT InternalDbId, 
				 Title, 
				 Description,
			     StudyCount,
				 OwnerId,
				 Status,
				 CreationDate, 
				 LastModified,
				 Version,
				 IsAvailable,
				 DataSize,
				 CommentCount,
				 CourseId,
				 OwnerName,
				 OwnerEjsId,
				 ExternalAssignmentId,
				 ParentAssignmentId
				 from AllAssignments_MetaOnly
       End
    Else
	   Begin
		  SELECT InternalDbId, 
				 Title, 
				 Description,
			     StudyCount,
				 OwnerId,
				 Status,
				 CreationDate, 
				 LastModified,
				 Version,
				 IsAvailable,
				 DataSize,
				 CommentCount,
				 CourseId,
				 OwnerName,
				 OwnerEjsId,
				 ExternalAssignmentId,
				 ParentAssignmentId
				 from AllAssignments_MetaOnly
				 where IsAvailable = 'true'
       End
	
END
GO
/****** Object:  StoredProcedure [dbo].[AddToLog]    ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<shiniwa>
-- Create date: <Mar.19, 2009>
-- Description:	<insert new logging>
-- =============================================
CREATE PROCEDURE [dbo].[AddToLog]
	-- Add the parameters for the stored procedure here
	@Text nvarchar(MAX),
	@Cat int = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    INSERT into Logging
	Values (
		@Text,
		GETDATE(),
		@Cat
	)
END
GO
/****** Object:  StoredProcedure [dbo].[AddDocumentToCourse]    ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[AddDocumentToCourse]

	@Title nvarchar(150),
	@Description nvarchar(500),
	@DocumentId uniqueidentifier,
	@CreationDate datetime,
	@IsAvailable bit,
	@CourseId int,
	@Data varbinary(MAX),
	@DataSize bigint

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	if exists (Select null from Courses where Id=@CourseId)
		Begin
		
		insert into CourseDocuments

		values (
					@Title, 
					@Description, 
					@DocumentId, 
					@CreationDate, 
					@IsAvailable, 
					@CourseId,
					@Data, 
					@DataSize
				)
		End
END
GO
/****** Object:  StoredProcedure [dbo].[DeleteCourseDocument]    ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[DeleteCourseDocument]

	@DocumentId uniqueIdentifier,
	@UserId uniqueIdentifier

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	declare @UserGroupId int
	declare @GroupId int
	declare @perform bit
	
	if exists (Select null from Users where UserId=@UserId and IsMarkedDeleted = 'false')
		Begin
			set @UserGroupId = (Select UserGroupId from Users where UserId=@UserId)
			set @GroupId = (Select Id from UserGroups where Id=@UserGroupId)

			-- User is a Teacher
			if(@GroupId = 2)
			Begin
				set @perform = 1
			End

			-- User is an Administrator
			if(@GroupId = 1)
			Begin
				set @perform = 1
			End
			

			if(@perform = 1)
				Begin
					Delete from
						CourseDocuments
					where 
						DocumentId = @DocumentId 
				return 0 -- 0 == ok
			end
			else
				return 1 -- 1 == error
		End
	else
		return 1 -- 1 == error
END
GO
/****** Object:  StoredProcedure [dbo].[GetAssignment]    ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[GetAssignment]

	@UserId uniqueIdentifier,
    @AssignmentOwnerId int,
    @AssignmentId int

AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON; 

    -- Insert statements for procedure here
    
    declare @UserDbId int
    declare @UserDbName varchar(128)
    
    if exists (Select null from Users where UserId=@UserId)
        Begin
            set @UserDbId = (Select Id from Users where Id=@AssignmentOwnerId) 
            set @UserDbName = (Select DatabaseName from Users where Id=@AssignmentOwnerId)
        
            declare @cmdSaveAssignment nvarchar(2000)
            select @cmdSaveAssignment = 'USE '+@UserDbName+'; 
                     Select Data from Assignments 
                     where Id = '+CONVERT(varchar(10),@AssignmentId)+';'

            exec sp_executesql @cmdSaveAssignment

        End
    
END
GO
/****** Object:  StoredProcedure [dbo].[GetAllStudiesForUser]    ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[GetAllStudiesForUser]

	@UserId uniqueidentifier,
	@IncludeNotAvailable bit	

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
	declare @UserDbId int
	declare @UserDbName varchar(128)
	
	if exists (Select null from Users where UserId=@UserId)
		Begin
			set @UserDbId = (Select Id from Users where UserId=@UserId)
			set @UserDbName = (Select DatabaseName from Users where Id=@UserDbId)


			declare @cmdSaveAssignment nvarchar(2000)

			if(@IncludeNotAvailable = 1)
				Begin
					select @cmdSaveAssignment = 'USE '+@UserDbName+'; 
								 Select * from StudyMetaData 
								 where OwnerId = '+CONVERT(varchar(10),@UserDbId)+';'
				End
			Else
				Begin
					select @cmdSaveAssignment = 'USE '+@UserDbName+'; 
								 Select * from StudyMetaData 
								 where OwnerId = '+CONVERT(varchar(10),@UserDbId)+
								 'AND IsAvailable = 1;'
				End
			
				exec sp_executesql @cmdSaveAssignment
		
			return 0 -- 0 == OK
			
		End
	else
		Begin
			return 1 -- 1 == failure
		End
END
GO
/****** Object:  StoredProcedure [dbo].[GetAllRegisteredUsers]    ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[GetAllRegisteredUsers]

	@UserGroupId int

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
	if(@UserGroupId = -1)
		Begin
			Select UserName, FirstName, LastName, Email, DatabaseName, IsAccountActive, UserId, UserGroupId
				From Users
				where IsMarkedDeleted = 'false'
				Order By Id
		End
	else
		Begin
			Select UserName, FirstName, LastName, Email, DatabaseName, IsAccountActive, UserId UserGroupId
				From Users
				Where UserGroupId = @UserGroupId and IsMarkedDeleted = 'false'
				Order By Id
		End
END
GO
/****** Object:  StoredProcedure [dbo].[GetAllRegisteredCourses]    ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[GetAllRegisteredCourses]

	@UserId	uniqueidentifier,	
	@IncludeNotAvailable bit

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
	declare @UserGroupId int

    if exists (Select null from Users where UserId=@UserId and IsMarkedDeleted = 'false')
		Begin
			set @UserGroupId = (Select UserGroupId from Users where UserId=@UserId)

			-- IF the user is not a Teacher...			
			--if(@UserGroupId != 2)
			--	Begin
					-- return 1
			--	End
			--else
				Begin

					if(@IncludeNotAvailable = 'True')
						Begin
							select * from Courses
							order by CreationDate
						End
					else
						Begin
							select * from Courses where IsActive='True'
							order by CreationDate
						End
				End
		return 0
		End
	else
		return 1

END
GO
/****** Object:  StoredProcedure [dbo].[UploadAndSaveStudyMetaData]    ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UploadAndSaveStudyMetaData]

	@UserId uniqueIdentifier,
	@Title nvarchar(50),
	@Description nvarchar(500),
	@ParentAssignmentId int, 
	@CreationDate datetime,
	@LastModifiedDate datetime,
	@IsAvailable bit,
	@CommentCount int

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
	declare @UserDbId int
	declare @UserDbName varchar(128)
	
	if exists (Select null from Users where UserId=@UserId)
		Begin
			set @UserDbId = (Select Id from Users where UserId=@UserId)
			set @UserDbName = (Select DatabaseName from Users where Id=@UserDbId)

			declare @cmdSaveAssignment nvarchar(4000)
			set @cmdSaveAssignment = 'USE '+ @UserDbName + ';' +
				N' 
				Insert into StudyMetaData Values (
					@Title, 
					@Description,
					@UserDbId,
					@ParentAssignmentId,
					@CreationDate,
					@LastModifiedDate,
					@IsAvailable,
					@CommentCount)'

		exec sp_executesql @cmdSaveAssignment,
		
                   N'@Title nvarchar(50), @Description nvarchar(500),
						@UserDbId int, @ParentAssignmentId int, @CreationDate datetime,
						@LastModifiedDate datetime, @IsAvailable bit,
						@CommentCount int',
					
					@Title, 
					@Description,
					@UserDbId,
					@ParentAssignmentId,
					@CreationDate,
					@LastModifiedDate,
					@IsAvailable,
					@CommentCount
		
			
					declare @newId int	
					declare @cmdSGetNewId nvarchar(2000)
					select @cmdSGetNewId = 'USE '+@UserDbName+'; 
								 Select @NewId = Max(Id) from Assignments'
					
					exec sp_executesql @cmdSGetNewId, N'@NewId int output', @newId output
				
					set @newId = 10
			return @newId -- Id of the new entry
			
		End
	else
		Begin
			return -1 -- failure
		End

END
GO
/****** Object:  StoredProcedure [dbo].[UploadAndSaveAssignment]    ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UploadAndSaveAssignment]

	@UserId uniqueIdentifier,
	@AssignmentTitle nvarchar(50),
	@Description nvarchar(500),
	@StudyCount int,
	@Status int,
	@CreationDate datetime,
	@LastModifiedDate datetime,
	@Version int,
	@IsAvailable bit,
	@DataSize bigint,
	@Data varbinary(Max),
	@CommentCount int,
	@CourseId int,
	@ExternalAssignmentId uniqueIdentifier,	--added 080318
	@ParentAssignmentId uniqueIdentifier --added 080318
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
	declare @UserDbId int
	declare @UserFriendlyName nvarchar(100)
	declare @UserDbName varchar(128)
	
	if exists (Select null from Users where UserId=@UserId)
		Begin
			set @UserDbId = (Select Id from Users where UserId=@UserId)
			set @UserFriendlyName = (Select FirstName + ' ' + LastName from Users where UserId=@UserId)
			set @UserDbName = (Select DatabaseName from Users where Id=@UserDbId)

		--insert into Users Assignment Database

		declare @cmdSaveAssignment nvarchar(2000)
		set @cmdSaveAssignment = 'USE '+ @UserDbName + ';' +
				N' 
				Insert into Assignments Values (
					@AssignmentTitle, 
					@Description,
					@StudyCount,
					@UserDbId,
					@Status,
					@CreationDate,
					@LastModifiedDate,
					@Version,
					@IsAvailable,
					@DataSize,
					@Data,
					@CommentCount,
					@CourseId)'

		exec sp_executesql @cmdSaveAssignment,
		
                   N'@AssignmentTitle nvarchar(50), @Description nvarchar(500),
						@StudyCount int, @UserDbId int, @Status int, @CreationDate datetime,
						@LastModifiedDate datetime, @Version int, @IsAvailable bit,
						@DataSize bigint, @Data varbinary(MAX), @CommentCount int, @CourseId int',
					
					@AssignmentTitle, 
					@Description,
					@StudyCount,
					@UserDbId,
					@Status,
					@CreationDate,
					@LastModifiedDate,
					@Version,
					@IsAvailable,
					@DataSize,
					@Data,
					@CommentCount,
					@CourseId

					declare @newId int	
					declare @cmdSGetNewId nvarchar(2000)
					select @cmdSGetNewId = 'USE '+@UserDbName+'; 
								 Select @NewId = Max(Id) from Assignments'
					
					exec sp_executesql @cmdSGetNewId, N'@NewId int output', @newId output

					-- set the current working database back to MasterData (Added 080205)
						declare @cmdInsertIntoMeta nvarchar(2000)
						select @cmdInsertIntoMeta = 'USE MeetMasterData;'
						exec sp_executesql @cmdInsertIntoMeta

						--insert into AllAssignments_MetaOnly (Added 080205)
								--Updated 080318 params to include @UserId, @ExternalAssignmentId, @ParentAssignmentId
							Insert into AllAssignments_MetaOnly
								 values(@AssignmentTitle, @Description, @StudyCount, 
										@UserDbId, @UserId, @Status, @CreationDate, @LastModifiedDate, 
										@Version, @IsAvailable, @DataSize, @CommentCount,
										@CourseId, @UserFriendlyName, @UserDbName, 
										@newId, @ExternalAssignmentId, @ParentAssignmentId )

			return @newId -- 0 == OK
			
		End
	else
		Begin
			return -1 -- -1 == failure
		End
END
GO
/****** Object:  StoredProcedure [dbo].[UpdateUserPassword]    ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UpdateUserPassword]

	@UserName nvarchar(50),
	@OldPassword nvarchar(512),
	@NewPassword nvarchar(512)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
		if exists (Select null from Users where UserName=@UserName AND Password=@OldPassword and IsMarkedDeleted = 'false')
		Begin
			declare @Id int

			set @Id = (Select Id from Users where 
							UserName=@UserName AND 
							Password=@OldPassword AND 
							IsAccountActive = 'True')
			
			Update Users Set 
								Password = @NewPassword
						 where
								Id = @Id AND
								Password = @OldPassword
			
			return 0 -- 0 == OK

		End
		Else
			Begin
				return 1 -- 1 == failure
			End
		
		
END
GO
/****** Object:  StoredProcedure [dbo].[UpdateUser]  ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UpdateUser]

	@OperatorId uniqueidentifier,
	@UserName varchar(50),
	@FirstName nvarchar(100),
	@LastName nvarchar(100),
	@IsAccountActive bit,
	@UserId uniqueidentifier,
	@Email varchar(128),
	@Password varchar(512),
	@NewUserGroupId int

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	if exists (Select null from Users where UserName = @UserName)
	Begin
		-- is this the user we are updating?
		declare @ExistingUNameId uniqueidentifier
		set @ExistingUNameId = (select UserId From Users where UserName = @UserName)
		if(@ExistingUNameId != @UserId)
			Return 1      -- 1 = User Name Exits
    End

	if exists (Select null from Users where UserId=@UserId and IsMarkedDeleted = 'false')
		Begin
		
		declare @UserGroupId int
		declare @GroupId int
		declare @perform bit
		
		if exists (Select null from Users where UserId=@OperatorId)
			Begin
				set @UserGroupId = (Select UserGroupId from Users where UserId=@OperatorId)
				set @GroupId = (Select Id from UserGroups where Id=@UserGroupId)

				-- User is a Teacher
				if(@GroupId = 2)
				Begin
					set @perform = 1
				End

				-- User is an Administrator
				if(@GroupId = 1)
				Begin
					set @perform = 1
				End
				
				if(@perform = 1)
					Begin

						update 
							Users
						set 
							UserName = @UserName,
							FirstName = @FirstName,
							LastName = @LastName,
							IsAccountActive = @IsAccountActive,
							Email = @Email,
							UserGroupId = @NewUserGroupId
						where
							UserId = @UserId

						if(@password != 'NoChange')
							begin
								update 
									Users
								set 
									Password = @Password
								where
									UserId = @UserId
							end
						return 0 -- OK
					end
				else
					return 2 -- Insufficient user level
				end
			else
				return 3 -- Invalid operator Id
		End
END
GO
/****** Object:  StoredProcedure [dbo].[UpdateStudyMetaData]   ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UpdateStudyMetaData]

	@UserId uniqueIdentifier,
	@StudyId int,
	@Title nvarchar(50),
	@Description nvarchar(500),
	@OwnerId int,
	@ParentAssignmentId int, 
	@CreationDate datetime,
	@LastModifiedDate datetime,
	@IsAvailable bit,
	@CommentCount int



AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	declare @UserDbId int
	declare @UserDbName varchar(128)
	
	if exists (Select null from Users where UserId=@UserId)
		Begin
			set @UserDbId = (Select Id from Users where UserId=@UserId)
			set @UserDbName = (Select DatabaseName from Users where Id=@UserDbId)

			declare @cmdSaveStudy nvarchar(2000)
			select @cmdSaveStudy = 'USE '+ @UserDbName + ';'+
			'Update StudyMetaData
			set 
				Title = '+ @Title + ', 
				Description = '+ @Description + ', 
				OwnerId = '+ @UserDbId + ', 
				ParentAssignmentId = '+ @ParentAssignmentId + ', 
				CreationDate = '+ @CreationDate + ', 
				LastModifiedDate = '+ @LastModifiedDate + ', 
				IsAvailable = '+ @IsAvailable + ', 
				CommentCount = '+ @CommentCount
				
					+ 'where Id = ' + +CONVERT(varchar(10),@StudyId)+

			+ ';'
			exec sp_executesql @cmdSaveStudy
		
			return 0 -- 0 == OK
			
		End
	else
		Begin
			return 1 -- 1 == failure
		End
END
GO
/****** Object:  StoredProcedure [dbo].[UpdateCourseRecord]   ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UpdateCourseRecord] 
	
	@UserId uniqueidentifier,
	@CourseId int,
	@Name nvarchar(150),
	@Description nvarchar(500),
	@Owner nvarchar(200),	
	@IsActive bit


AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	if exists (Select null from Courses where Id=@CourseId)
		Begin
		
		declare @UserGroupId int
		declare @GroupId int
		declare @perform bit
		
		if exists (Select null from Users where UserId=@UserId and IsMarkedDeleted = 'false')
			Begin
				set @UserGroupId = (Select UserGroupId from Users where UserId=@UserId)
				set @GroupId = (Select Id from UserGroups where Id=@UserGroupId)

				-- User is a Teacher
				if(@GroupId = 2)
				Begin
					set @perform = 1
				End

				-- User is an Administrator
				if(@GroupId = 1)
				Begin
					set @perform = 1
				End
				

				if(@perform = 1)
					Begin

						update Courses

						set 
								Name = @Name, 
								Description = @Description, 
								IsActive = @IsActive, 
								Owner = @Owner
						where
								Id = @CourseId
					end
				else
					return 1 -- Insufficient User Level
			end
		else
			return 2 -- Course does not exist
		End
END
GO
/****** Object:  StoredProcedure [dbo].[UpdateCourseDocument]  ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UpdateCourseDocument]
	
	@UserId uniqueidentifier,
	@Title nvarchar(150),
	@Description nvarchar(500),
	@DocumentId uniqueidentifier,
	@IsAvailable bit,
	@CourseId int
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	if exists (Select null from Courses where Id=@CourseId)
		Begin
		
		declare @UserGroupId int
		declare @GroupId int
		declare @perform bit
		
		if exists (Select null from Users where UserId=@UserId and IsMarkedDeleted = 'false')
			Begin
				set @UserGroupId = (Select UserGroupId from Users where UserId=@UserId)
				set @GroupId = (Select Id from UserGroups where Id=@UserGroupId)

				-- User is a Teacher
				if(@GroupId = 2)
				Begin
					set @perform = 1
				End

				-- User is an Administrator
				if(@GroupId = 1)
				Begin
					set @perform = 1
				End
				

				if(@perform = 1)
					Begin

						update CourseDocuments

						set 
								Title = @Title, 
								Description = @Description, 
								IsAvailable = @IsAvailable, 
								CourseId = @CourseId
						where
								DocumentId = @DocumentId
					end
				end
		End
END
GO
/****** Object:  StoredProcedure [dbo].[UpdateAssignment]   ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UpdateAssignment]

	@UserId uniqueIdentifier,
	@AssignmentId int,
	@AssignmentTitle nvarchar(50),
	@Description nvarchar(500),
	@StudyCount int,
	@Status int,
	@CreationDate datetime,
	@LastModifiedDate datetime,
	@Version int,
	@IsAvailable bit,
	@DataSize bigint,
	@Data varbinary(Max),
	@CommentCount int

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
	declare @UserDbId int
	declare @UserDbName varchar(128)
	
	if exists (Select null from Users where UserId=@UserId)
		Begin
			set @UserDbId = (Select Id from Users where UserId=@UserId)
			set @UserDbName = (Select DatabaseName from Users where Id=@UserDbId)

			declare @cmdSaveAssignment nvarchar(2000)
			select @cmdSaveAssignment = 'Update Assingments
			Set 
				Title = '+ @AssignmentTitle + ', 
				Description = '+ @Description + ', 
				StudyCoutn = '+ @StudyCount + ', 
				OwnerId = '+ @UserDbId + ', 
				Status = '+ @Status + ', 
				CreationDate = '+ @CreationDate + ', 
				LastModifiedDate = '+ @LastModifiedDate + ', 
				Version = '+ @Version + ', 
				IsAvailable = '+ @IsAvailable + ', 
				DataSize = '+ @DataSize + ', 
				Data = '+ @Data + ', 
				CommentCount = '+ @CommentCount + '
			
					Where Id = ' + +CONVERT(varchar(10),@AssignmentId)+
				
			+ ');'
			exec sp_executesql @cmdSaveAssignment
		
			return 0 -- 0 == OK
			
		End
	else
		Begin
			return 1 -- 1 == failure
		End
END
GO
/****** Object:  StoredProcedure [dbo].[RestoreAssignment]  ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[RestoreAssignment] 
	
	@UserId uniqueIdentifier,
	@AssignmentOwnerId int,
	@AssignmentId int

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
	declare @UserDbId int
	declare @UserGroupId int
	declare @GroupId int
	declare @perform bit
	declare @AssOwnerDbName varchar(128)
	
	if exists (Select null from Users where UserId=@UserId)
		Begin
			set @UserDbId = (Select Id from Users where UserId=@UserId)
			set @UserGroupId = (Select UserGroupId from Users where UserId=@UserId)
			set @GroupId = (Select Id from UserGroups where Id=@UserGroupId)
			
			-- User owns the assignment
			if(@UserDbId = @AssignmentOwnerId)
			Begin
				set @perform = 1
			End

			-- User is a Teacher
			else if(@GroupId = 2)
			Begin
				set @perform = 1
			End

			-- User is an Administrator
			else if(@GroupId = 1)
			Begin
				set @perform = 1
			End
			

			if(@perform = 1)
				Begin
					set @AssOwnerDbName = (Select DatabaseName from Users where Id=@AssignmentOwnerId)
					
					-- first update the record in the AllAssignments_MetaOnly table (Added 080205)
					Update AllAssignments_MetaOnly 
							set 
								IsAvailable = 1 
							where 
								OwnerId = @AssignmentOwnerId AND
								InternalDbId = +CONVERT(varchar(10),@AssignmentId)


					-- then update the record in the users database
					declare @cmd nvarchar(2000)
					select @cmd = 'USE '+ @AssOwnerDbName + ';'+
					'Update Assignments
					set 
						IsAvailable = 1'
						
							+ 'where Id = ' + +CONVERT(varchar(10),@AssignmentId)+

					+ ';'
					exec sp_executesql @cmd

					return 0 -- 0 = ok
				End
			else
				return 1 -- 1 = failure
		End
	
END
GO
/****** Object:  StoredProcedure [dbo].[ValidateUserNamePassword]   ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[ValidateUserNamePassword] 
	
	@UserName varchar(50),
	@Password varchar(512),
	@Id uniqueidentifier output,
	@FirstName varchar(100) output,
	@LastName varchar(100) output
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	if exists (Select null from Users where UserName=@UserName AND Password=@PassWord)
		Begin
			set @Id = (Select UserId from Users where UserName=@UserName AND Password=@Password AND IsAccountActive = 'True' and IsMarkedDeleted = 'false')

--			Declare crsUId Cursor for Select UserId from Users where UserName=@UserName AND Password=@Password AND IsAccountActive = 'True'
--			Open crsUId
--			Fetch crsUId into @Id
--			Close crsUId
--			Deallocate crsUId

			Declare crsFName Cursor for Select FirstName from Users where UserName=@UserName AND Password=@Password AND IsAccountActive = 'True' and IsMarkedDeleted = 'false'
			Open crsFName
			Fetch crsFName into @FirstName
			Close crsFName
			Deallocate crsFName

			Declare crsLName Cursor for Select LastName from Users where UserName=@UserName AND Password=@Password AND IsAccountActive = 'True' and IsMarkedDeleted = 'false'
			Open crsLName
			Fetch crsLName into @LastName
			Close crsLName
			Deallocate crsLName

			return 0 -- 0 == user found
		End

	return 1 -- 1 == user not found

END
GO
/****** Object:  StoredProcedure [dbo].[HideAssignment]   ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[HideAssignment]

	@UserId uniqueIdentifier,
	@AssignmentOwnerId int,
	@AssignmentId int

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
	declare @UserDbId int
	declare @UserGroupId int
	declare @GroupId int
	declare @perform bit
	declare @AssOwnerDbName varchar(128)
	
	if exists (Select null from Users where UserId=@UserId)
		Begin
			set @UserDbId = (Select Id from Users where UserId=@UserId)
			set @UserGroupId = (Select UserGroupId from Users where UserId=@UserId)
			set @GroupId = (Select Id from UserGroups where Id=@UserGroupId)

			-- User owns the assignment
			if(@UserDbId = @AssignmentOwnerId)
			Begin
				set @perform = 1
			End

			-- User is a Teacher
			if(@GroupId = 2)
			Begin
				set @perform = 1
			End

			-- User is an Administrator
			if(@GroupId = 1)
			Begin
				set @perform = 1
			End
			

			if(@perform = 1)
				Begin
					set @AssOwnerDbName = (Select DatabaseName from Users where Id=@AssignmentOwnerId)
					
					-- first update the record in the AllAssignments_MetaOnly table (Added 080205)
					Update AllAssignments_MetaOnly 
							set 
								IsAvailable = 0 
							where 
								OwnerId = @AssignmentOwnerId AND
								InternalDbId = +CONVERT(varchar(10),@AssignmentId)


					-- then update the record in the users database
					declare @cmd nvarchar(2000)
					select @cmd = 'USE '+ @AssOwnerDbName + ';'+
					'Update Assignments
					set 
						IsAvailable = 0'
						
							+ 'where Id = ' + +CONVERT(varchar(10),@AssignmentId)+

					+ ';'
					exec sp_executesql @cmd

					return 0 -- 0 = ok
				End
			else
				return 1 -- 1 = failure
		End
	
END
GO
/****** Object:  StoredProcedure [dbo].[GetStudiesForAssignment]   ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[GetStudiesForAssignment]
 
 @UserId int,
 @AssignmentId int

AS
BEGIN

 SET NOCOUNT ON;
 declare @UserDbName varchar(128)
 
 if exists (Select null from Users where Id=@UserId)
  Begin
   set @UserDbName = (Select DatabaseName from Users where Id=@UserId)
   declare @cmdSaveAssignment nvarchar(2000)
   Begin
    select @cmdSaveAssignment = 'USE '+@UserDbName+'; 
        Select * from StudyMetaData 
        where ParentAssignmentId = '+CONVERT(varchar(10),@AssignmentId)+';' 
   End
   exec sp_executesql @cmdSaveAssignment
  
   return 0 -- 0 == OK
   
  End
 else
  Begin
   return 1 -- 1 == failure
  End
END
GO
/****** Object:  StoredProcedure [dbo].[RegisterNewUser]   ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[RegisterNewUser]

@UserName varchar(50),
@Password varchar(512),
@FirstName nvarchar(100),
@LastName nvarchar(100),
@Email varchar(128),
@DBName varchar(128),
@IsAccountActive bit,
@UserGroupId int,
@UserId uniqueidentifier

AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements. 
    SET NOCOUNT ON;

	if exists (Select null from Users where UserName = @UserName)
	Begin
      Return 1      -- 1 = User Name Exits
    End


    insert into Users values(@UserName, @Password, @FirstName, @LastName, 
								@Email, 'NotSet', 0, @IsAccountActive, @UserGroupId, @UserId, 'false')

	declare @NewUserId int
	set @NewUserId = (select Id from Users where UserId = @UserId)
	declare @newUserDBname varchar(50)
	set @newUserDBname = 'meetF_user_'+ CONVERT(varchar(10), @NewUserId)

    --Create database
    declare @query varchar(150)
    --Constrcut Dynamic SQL
    set @query = 'CREATE DATABASE '+ @newUserDBname 
    --Execute it
    EXECUTE(@query)

	-- Push the new name into the new user record
	update Users set DatabaseName = @newUserDBname where UserId = @UserId

	-- Add the needed tables into the new database
	declare @cmdCTAssignments nvarchar(2000)
	select @cmdCTAssignments = 'USE '+ @newUserDBname + ';'+'
	Create Table Assignments (
		Id int not null primary key identity(1,1), 
		Title varchar(50) not null,
		Description varchar(500) not null,
		StudyCount int not null,
		OwnerId int not null,
		Status int not null,
		CreationDate datetime not null,
		LastModified datetime not null,
		Version int not null,
		IsAvailable bit not null,
		DataSize bigint not null,
		Data varbinary(Max) not null,
		CommentCount int not null,
		CourseId int not null,
	);'
	exec sp_executesql @cmdCTAssignments

	declare @cmdCTStudyMetaData nvarchar(2000)
	select @cmdCTStudyMetaData = 'USE '+ @newUserDBname + ';'+'
	Create Table StudyMetaData (
		Id int not null primary key identity(1,1), 
		Title varchar(50) not null,
		Description varchar(500) not null,
		OwnerId int not null,
		ParentAssignmentId int not null foreign key references Assignments(Id) ON DELETE NO ACTION,
		CreationDate datetime not null,
		LastModified datetime not null,
		IsAvailable bit not null,
		CommentCount int not null
	);'
	exec sp_executesql @cmdCTStudyMetaData

	return 0 -- succeeded

END
GO
/****** Object:  StoredProcedure [dbo].[DeleteAssignment]   ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[DeleteAssignment] 
	
	@UserId uniqueIdentifier,
	@AssignmentOwnerId int,
	@AssignmentId int

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
	declare @UserDbId int
	declare @UserGroupId int
	declare @GroupId int
	declare @perform bit
	declare @AssOwnerDbName varchar(128)
	
	if exists (Select null from Users where UserId=@UserId and IsMarkedDeleted = 'false')
		Begin
			set @UserDbId = (Select Id from Users where UserId=@UserId)
			set @UserGroupId = (Select UserGroupId from Users where UserId=@UserId)
			set @GroupId = (Select Id from UserGroups where Id=@UserGroupId)

			-- User owns the assignment
			if(@UserDbId = @AssignmentOwnerId)
			Begin
				set @perform = 1
			End

			-- User is a Teacher
			if(@GroupId = 2)
			Begin
				set @perform = 1
			End

			-- User is an Administrator
			if(@GroupId = 1)
			Begin
				set @perform = 1
			End
			

			if(@perform = 1)
				Begin
					set @AssOwnerDbName = (Select DatabaseName from Users where Id=@AssignmentOwnerId)
					
					-- first delete the record in the AllAssignments_MetaOnly table
					Delete from 
							AllAssignments_MetaOnly 
							where 
								OwnerId = @AssignmentOwnerId AND
								InternalDbId = +CONVERT(varchar(10),@AssignmentId)


					-- then update the record in the users database
					declare @cmd nvarchar(2000)
					select @cmd = 'USE '+ @AssOwnerDbName + ';'+

					'Delete from StudyMetaData '
					+ 'where ParentAssignmentId = ' + +CONVERT(varchar(10),@AssignmentId)+
					+ ';' +

					'Delete from Assignments '
					+ 'where Id = ' + +CONVERT(varchar(10),@AssignmentId)+
					+ ';'
					exec sp_executesql @cmd

					return 0 -- 0 = ok
				End
			else
				return 1 -- 1 = failure
		End
	
END
GO
/****** Object:  StoredProcedure [dbo].[GetAllCourseDocuments]   ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[GetAllCourseDocuments]

	@UserId uniqueidentifier,
	@IncludeNotAvailable bit

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	select * from CourseDocuments order by CourseID, CreationDate	

END
GO
/****** Object:  StoredProcedure [dbo].[GetAllAssignmentsForUser_OLD]  ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[GetAllAssignmentsForUser_OLD]

	@UserId uniqueidentifier,
	@IncludeNotAvailable bit	

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
declare @UserDbIdCursor Cursor
 declare @DbNameCursor Cursor
 declare @UserNameCursor Cursor
 
 declare @UserDbId int
 declare @UserName nvarchar(100) 
 declare @UserDbName varchar(128)
 if exists (Select null from Users where UserId=@UserId)
  Begin
   create table #t_Ass 
   (Id int , Title nvarchar(50), Description nvarchar(500), 
    StudyCount int, OwnerId int, Status int, CreationDate datetime, 
    LastModified datetime, Version int, IsAvailable bit, DataSize bigint, 
    CommentCount int, CourseId int, OwnerName nvarchar(100))
   --set @UserDbName = (Select DatabaseName from Users where Id=@UserDbId)
   set @UserDbIdCursor = Cursor for 
    Select Id from Users Where UserGroupId = 3
   set @DbNameCursor = Cursor for 
    Select DatabaseName from Users Where UserGroupId = 3
   set @UserNameCursor = Cursor for 
    Select LastName + ' ' + FirstName as OwnerName from Users Where UserGroupId = 3
   open @UserDbIdCursor
   fetch next from @UserDbIdCursor
   into @UserDbId
   open @DbNameCursor
   fetch next from @DbNameCursor
   into @UserDbName
   open @UserNameCursor
   fetch next from @UserNameCursor
   into @UserName

   while (@@FETCH_Status = 0)
    begin
     declare @cmdSaveAssignment nvarchar(2000)
     
     if(@IncludeNotAvailable = 1)
       Begin
      select @cmdSaveAssignment = 'USE '+@UserDbName+'; 
          Select 
           Id, Title, Description, 
           StudyCount, OwnerId, Status, CreationDate, 
           LastModified, Version, IsAvailable, DataSize,
           CommentCount, CourseId, Title 
          from Assignments 
          where OwnerId = '+CONVERT(varchar(10),@UserDbId)+';'
      insert #t_Ass exec sp_executesql @cmdSaveAssignment
       End
     Else
       Begin
      select @cmdSaveAssignment = 'USE '+@UserDbName+'; 
         Select 
          Id, Title, Description, 
          StudyCount, OwnerId, Status, CreationDate, 
          LastModified, Version, IsAvailable, DataSize, 
          CommentCount, CourseId, Title
         from Assignments 
         where OwnerId = '+CONVERT(varchar(10),@UserDbId)+
         'AND IsAvailable = 1;'
      insert #t_Ass exec sp_executesql @cmdSaveAssignment 
           End
     Update #t_Ass 
      Set OwnerName = @UserName
      Where OwnerId = @UserDbId
     fetch next from @UserDbIdCursor
     into @UserDbId
     fetch next from @DbNameCursor
     into @UserDbName
     fetch next from @UserNameCursor
     into @UserName
    end
   --Next we need to remove the assignments that belong to courses 
   --that the user has not signed up for.
   -- create a new temp table that will hold the selected Assignemnts only
   create table #t_SelectedAss 
   (Id int , Title nvarchar(50), Description nvarchar(500), 
    StudyCount int, OwnerId int, Status int, CreationDate datetime, 
    LastModified datetime, Version int, IsAvailable bit, DataSize bigint,
    CommentCount int, CourseId int, OwnerName nvarchar(100))
   --get the real user Id for the user invoking the SP
   declare @UdBId int
   set @UdBId = (Select Id from Users where UserId=@UserId)
   --Set up the cursor what we will use to loop through the course Regs.
   declare @CourseId int
   declare @CourseIdCursor Cursor
   set @CourseIdCursor = Cursor for
   select 
    c.Id
   from CourseRegistrations 
   Inner Join Courses c on c.Id = CourseId
   where UserId = @UdBId
   open @CourseIdCursor
   fetch next from @CourseIdCursor
   into @CourseId
   while (@@FETCH_Status = 0)
    begin
     insert #t_SelectedAss 
      select
      *
      From #t_Ass
      Where CourseId = @CourseId
    fetch next from @CourseIdCursor
    into @CourseId
    
    end
   select * from #t_SelectedAss
   drop table #t_Ass
   drop table #t_SelectedAss
  
   return 0 -- 0 == OK
  end   
 else
  Begin
   return 1 -- 1 == failure
  End
END
GO
/****** Object:  StoredProcedure [dbo].[GetRegisteredCoursesForUser]   ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[GetRegisteredCoursesForUser]

	@UserId	uniqueidentifier

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	declare @UdBId int

    if exists (Select null from Users where UserId=@UserId)
		Begin
			set @UdBId = (Select Id from Users where UserId=@UserId)

			select 
				c.Id,
				c.Name,
				c.Description,
				c.Owner,
				c.CreationDate

			from CourseRegistrations 
			Inner Join Courses c on c.Id = CourseId
			where UserId = @UdBId
			and c.IsActive = 'True'
			order by RegisteredDate
		
		return 0
		End
	else
		return 1

END
GO
/****** Object:  StoredProcedure [dbo].[GetDocumentsFromUserRegisteredCourses]    ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[GetDocumentsFromUserRegisteredCourses]

	@UserId uniqueidentifier	
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
	declare @UdBId int

	 if exists (Select null from Users where UserId=@UserId and IsMarkedDeleted = 'false')
		Begin
			-- Get the database Id for the user
			set @UdBId = (Select Id from Users where UserId=@UserId)

			-- Get all the ids from all the courses that the user is 
			-- registered to.

			declare @CourseId int
			declare @CourseIdCursor Cursor
			set @CourseIdCursor = Cursor for

			-- select the first Id into the cursor
			-- that is used to loop through the results			

			select 
				c.Id

			from CourseRegistrations 
			Inner Join Courses c on c.Id = CourseId
			where UserId = @UdBId
			order by RegisteredDate

			create table #t1 
			(Id int , Title nvarchar(50), Description nvarchar(500), 
				DocumentId uniqueidentifier, CreationDate datetime, 
				CourseId int, DataSize bigint)
			
			open @CourseIdCursor
			fetch next from @CourseIdCursor
			into @CourseId

			-- loop through all the returned results

			while (@@FETCH_Status = 0)
				begin

					-- Loop through the courses and get all documents registered to 
					-- each course.
					insert #t1 select 
						d.Id,
						d.Title,
						d.Description,
						d.DocumentId,
						d.CreationDate,
						d.CourseId,
						d.DataSize

					from CourseDocuments d 
					where CourseId = @CourseId
						and IsAvailable='True'
					order by CreationDate

				fetch next from @CourseIdCursor
				into @CourseId

				end
			end

			select * from #t1

			drop table #t1
END
GO
/****** Object:  StoredProcedure [dbo].[RemoveUserFromCourse]   ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[RemoveUserFromCourse]
	@CourseId int,
	@UserId uniqueidentifier
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	declare @UdBId int

	if exists (Select null from Users where UserId=@UserId)
			Begin
				set @UdBId = (Select Id from Users where UserId=@UserId)

					if exists (Select null from CourseRegistrations 
							where UserId = @UdBId AND CourseId = @CourseId)
						Begin
						  delete from
								 CourseRegistrations 
							where
								UserId = @UdBId 
								AND
								CourseId = @CourseId
							return 0 -- ok
						End
					else
						return 1 -- Course Registration does not exist
			end
	else
		return 2 -- the user does not exist
END
GO
/****** Object:  StoredProcedure [dbo].[RegisterUserToCourse]   ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[RegisterUserToCourse]

	@CourseId int,
	@UserId uniqueidentifier,
	@RegistrationDate datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	declare @UdBId int

	if exists (Select null from Users where UserId=@UserId and IsMarkedDeleted = 'false')
			Begin
				set @UdBId = (Select Id from Users where UserId=@UserId)

					if exists (Select null from CourseRegistrations 
							where UserId = @UdBId AND CourseId = @CourseId)
						Begin
						  Return 1      -- 1 = Course Name Exits
						End
					else
						Begin
						  
						  Insert into CourseRegistrations 
							Values (
										@UdBId,
										@CourseId,
										@RegistrationDate
									)
						End
			end

		Return 0      -- 0 = Ok	

END
GO
/****** Object:  StoredProcedure [dbo].[GetAllCourseRegistrations]   ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[GetAllCourseRegistrations] 

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
	
	Select r.CourseId, u.UserId, r.RegisteredDate
		From CourseRegistrations r
		Inner Join Users u on r.UserId = u.Id
		Order By r.UserId
	
END
GO
/****** Object:  StoredProcedure [dbo].[DeleteUser]   ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[DeleteUser]

	@OperatorId uniqueidentifier,
	@UserId uniqueidentifier

	AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	if exists (Select null from Users where UserId=@OperatorId)
		Begin
		
		declare @UserGroupId int
		declare @GroupId int
		declare @perform bit
		
		if exists (Select null from Users where UserId=@OperatorId and IsMarkedDeleted = 'false')
			Begin
				set @UserGroupId = (Select UserGroupId from Users where UserId=@OperatorId)
				set @GroupId = (Select Id from UserGroups where Id=@UserGroupId)

				-- User is a Teacher
				if(@GroupId = 2)
				Begin
					set @perform = 1
				End

				-- User is an Administrator
				if(@GroupId = 1)
				Begin
					set @perform = 1
				End
				
				if(@perform = 1)
					Begin

						declare @UserDbName varchar(50)
						declare @UserDbId int
						set @UserDbName = (select DatabaseName from Users where UserId=@UserId)
						set @UserDbId = (select Id from Users where UserId=@UserId)

						-- Delete the user database.
						--declare @query varchar(150)
						--Constrcut Dynamic SQL
						--set @query = 'ALTER DATABASE '+ @UserDbName + ' MODIFY NAME = ' + @UserDbName + 'DELETED'
						--Execute it
						--EXECUTE(@query)

						--Delete all the Users Course Registrations
						Delete from 
							CourseRegistrations
						where
							UserId = @UserDbId

						Update 
							Users 
						set
							IsMarkedDeleted = 'true'
						where
							Id = @UserDbId

						--Do not delete the User unless all assignments have been deleted.
						--Not Implemented.
						--Delete the user login
						--Delete from
						--	Users
						--where 
						--	UserId = @UserId 

						return 0 -- OK
					end
			end
		else
			return 1 -- Invalid operator Id	
		end
	else
		return 2 -- Invalid operator Id	
end
GO
/****** Object:  StoredProcedure [dbo].[DeleteCourseRegistration]   ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[DeleteCourseRegistration]
	
	@CourseId int,
	@UserId uniqueidentifier,
	@OperatorId uniqueidentifier

AS
BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	declare @UdBId int

	if exists (Select null from Users where UserId=@UserId and IsMarkedDeleted = 'false')
		Begin
			set @UdBId = (Select Id from Users where UserId=@UserId)

			if exists (Select null from CourseRegistrations 
					where UserId = @UdBId AND CourseId = @CourseId)
				Begin
					  
					Delete from
						CourseRegistrations
					where
						UserId = @UdBId
						and
						CourseId = @CourseId

					return 0 -- ok

				End
			else
				return 1 -- registration does not exist
		end
	else
		return 2 -- User does not exist
END
GO
/****** Object:  StoredProcedure [dbo].[DeleteCourse]  ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[DeleteCourse]

	@UserId uniqueidentifier,
	@CourseId int

AS
BEGIN
	
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	declare @UserGroupId int
	declare @GroupId int
	declare @perform bit
	
	if exists (Select null from Users where UserId=@UserId and IsMarkedDeleted = 'false')
		Begin
			set @UserGroupId = (Select UserGroupId from Users where UserId=@UserId)
			set @GroupId = (Select Id from UserGroups where Id=@UserGroupId)

			-- User is a Teacher
			if(@GroupId = 2)
			Begin
				set @perform = 1
			End

			-- User is an Administrator
			if(@GroupId = 1)
			Begin
				set @perform = 1
			End
			

			if(@perform = 1)
				Begin

					--Delete all course Registrations
					Delete from
						CourseRegistrations
					where 
						CourseId = @CourseId 


					--Delete all course Documents
					Delete from
						CourseDocuments
					where 
						CourseId = @CourseId 

					--Delete the course
					Delete from
						Courses
					where 
						Id = @CourseId 


				return 0 -- 0 == ok
			end
			else
				return 1 -- Insufficient User Level
		End
	else
		return 2 -- User does not exist


END
GO
