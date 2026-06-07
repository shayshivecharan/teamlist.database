CREATE TABLE [list].[TodoItem]
(
    [Id]             UNIQUEIDENTIFIER NOT NULL,
    [Index]          BIGINT           NOT NULL IDENTITY(1,1),
    [TodoListId]     UNIQUEIDENTIFIER NOT NULL,
    [StateId]        INT              NOT NULL CONSTRAINT [DF_list_TodoItem_StateId] DEFAULT (1000),
    [AssignedUserId] UNIQUEIDENTIFIER NULL,
    [Title]          NVARCHAR(256)    NOT NULL,
    [Description]    NVARCHAR(2048)   NULL,
    [DateCreated]    DATETIME2(3)     NOT NULL CONSTRAINT [DF_list_TodoItem_DateCreated]  DEFAULT (SYSUTCDATETIME()),
    [DateModified]   DATETIME2(3)     NOT NULL CONSTRAINT [DF_list_TodoItem_DateModified] DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT [PK_list_TodoItem] PRIMARY KEY NONCLUSTERED ([Id]),
    CONSTRAINT [FK_list_TodoItem_TodoList] FOREIGN KEY ([TodoListId])     REFERENCES [list].[TodoList]  ([Id]) ON DELETE CASCADE,
    CONSTRAINT [FK_list_TodoItem_State]    FOREIGN KEY ([StateId])        REFERENCES [list].[ItemState] ([Id]),
    CONSTRAINT [FK_list_TodoItem_User]     FOREIGN KEY ([AssignedUserId]) REFERENCES [security].[User]  ([Id]) ON DELETE SET NULL
);
GO
CREATE UNIQUE CLUSTERED INDEX [CX_list_TodoItem_Index] ON [list].[TodoItem] ([Index]);
GO
CREATE INDEX [IX_list_TodoItem_TodoListId]     ON [list].[TodoItem] ([TodoListId]);
GO
CREATE INDEX [IX_list_TodoItem_StateId]        ON [list].[TodoItem] ([StateId]);
GO
CREATE INDEX [IX_list_TodoItem_AssignedUserId] ON [list].[TodoItem] ([AssignedUserId]);
