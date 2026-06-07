CREATE TABLE [list].[TodoList]
(
    [Id]           UNIQUEIDENTIFIER NOT NULL,
    [Index]        BIGINT           NOT NULL IDENTITY(1,1),
    [TeamId]       UNIQUEIDENTIFIER NOT NULL,
    [Name]         NVARCHAR(256)    NOT NULL,
    [Description]  NVARCHAR(1024)   NULL,
    [DateCreated]  DATETIME2(3)     NOT NULL CONSTRAINT [DF_list_TodoList_DateCreated]  DEFAULT (SYSUTCDATETIME()),
    [DateModified] DATETIME2(3)     NOT NULL CONSTRAINT [DF_list_TodoList_DateModified] DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT [PK_list_TodoList] PRIMARY KEY NONCLUSTERED ([Id]),
    CONSTRAINT [FK_list_TodoList_Team] FOREIGN KEY ([TeamId]) REFERENCES [list].[Team] ([Id])
);
GO
CREATE UNIQUE CLUSTERED INDEX [CX_list_TodoList_Index] ON [list].[TodoList] ([Index]);
GO
CREATE INDEX [IX_list_TodoList_TeamId] ON [list].[TodoList] ([TeamId]);
