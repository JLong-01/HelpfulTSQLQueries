CREATE TABLE [dbo].[Users](
    [UserId] [bigint] IDENTITY(1000,1) PRIMARY KEY,
    [UserName] [nvarchar](1000) NOT NULL,
    [Pass] [varchar](512) NOT NULL,
    [FirstName] [nvarchar](512) NOT NULL,
    [LastName] [nvarchar](512) NOT NULL,
    [EmailAddress] [nvarchar](512) NOT NULL,
    [UserEnabled] [bit] NOT NULL,
    [UserSystemDisabled] [bit] NOT NULL,
    [DateCreated] [datetimeoffset](7) NOT NULL
    --...
)