CREATE TABLE [security].[UserRole]
(
    [UserId]      UNIQUEIDENTIFIER NOT NULL,
    [RoleId]      UNIQUEIDENTIFIER NOT NULL,
    [DateAssigned] DATETIME2(3)     NOT NULL CONSTRAINT [DF_security_UserRole_DateAssigned] DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT [PK_security_UserRole] PRIMARY KEY CLUSTERED ([UserId], [RoleId]),
    CONSTRAINT [FK_security_UserRole_User] FOREIGN KEY ([UserId]) REFERENCES [security].[User] ([Id]) ON DELETE CASCADE,
    CONSTRAINT [FK_security_UserRole_Role] FOREIGN KEY ([RoleId]) REFERENCES [security].[Role] ([Id]) ON DELETE CASCADE
);
GO
CREATE INDEX [IX_security_UserRole_RoleId] ON [security].[UserRole] ([RoleId]);
