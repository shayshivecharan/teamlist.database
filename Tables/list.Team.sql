CREATE TABLE [list].[Team]
(
    [Id]          UNIQUEIDENTIFIER NOT NULL,
    [Index]       BIGINT           IDENTITY (1, 1) NOT NULL,
    [Name]        NVARCHAR(128)    NOT NULL,
    [Description] NVARCHAR(512)    NULL,
    CONSTRAINT [PK_list_Team] PRIMARY KEY NONCLUSTERED ([Id])
);
GO
CREATE UNIQUE CLUSTERED INDEX [CX_list_Team_Index] ON [list].[Team] ([Index]);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_list_Team_Name] ON [list].[Team] ([Name]);
