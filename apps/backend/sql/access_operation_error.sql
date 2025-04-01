USE [AI_AP]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ACCESS_OPERATION_ERROR](
	[OBJID] [bigint] IDENTITY(1,1) NOT NULL,
	[CREATE_AT] [datetime2](7) NULL,
	[TOKEN] [nvarchar](max) NULL,
	[IP_ADDRESS] [nvarchar](max) NULL,
	[QUERY_TIME] [nvarchar](max) NULL,
	[PROCESS_ID] [int] NULL,
	[CODE] [nvarchar](max) NULL,
	[SSO_ACCOUNT] [nvarchar](64) NULL,
	[ROUTE] [nvarchar](100) NULL,
	[REF] [bigint] NULL,
	[ERROR] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO


