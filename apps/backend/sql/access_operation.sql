USE [AI_AP]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ACCESS_OPERATION](
	[OBJID] [bigint] IDENTITY(1,1) NOT NULL,
	[CREATE_AT] [datetime2](7) NULL,
	[TOKEN] [nvarchar](256) NULL,
	[IP_ADDRESS] [nvarchar](64) NULL,
	[QUERY_TIME] [nvarchar](32) NULL,
	[PROCESS_ID] [int] NULL,
	[CODE] [nvarchar](20) NULL,
	[SSO_ACCOUNT] [nvarchar](64) NULL,
	[ROUTE] [nvarchar](100) NULL,
	[REF] [bigint] NULL,
	[LOG] [nvarchar](512) NULL
) ON [PRIMARY]
GO


