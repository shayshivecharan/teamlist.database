CREATE TABLE [list].[TeamUser]
(
    [TeamId]     UNIQUEIDENTIFIER NOT NULL,
    [UserId]     UNIQUEIDENTIFIER NOT NULL,
    [DateJoined] DATETIME2(3)     NOT NULL CONSTRAINT [DF_list_TeamUser_DateJoined] DEFAULT (SYSUTCDATETIME()),
    [TeamRole]   TINYINT          NOT NULL CONSTRAINT [DF_list_TeamUser_TeamRole]   DEFAULT (1),
    CONSTRAINT [PK_list_TeamUser]            PRIMARY KEY CLUSTERED ([TeamId], [UserId]),
    CONSTRAINT [FK_list_TeamUser_Team]       FOREIGN KEY ([TeamId]) REFERENCES [list].[Team]      ([Id]) ON DELETE CASCADE,
    CONSTRAINT [FK_list_TeamUser_User]       FOREIGN KEY ([UserId]) REFERENCES [security].[User]  ([Id]) ON DELETE CASCADE,
    CONSTRAINT [CK_list_TeamUser_TeamRole]   CHECK ([TeamRole] IN (1, 2))
);
GO
CREATE NONCLUSTERED INDEX [IX_list_TeamUser_UserId] ON [list].[TeamUser] ([UserId]);
