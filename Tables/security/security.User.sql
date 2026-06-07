CREATE TABLE [security].[User]
(
    [Id]              UNIQUEIDENTIFIER NOT NULL,
    [UserName]        NVARCHAR(256)    NOT NULL,
    [Email]           NVARCHAR(256)    NOT NULL,
    [FullName]        NVARCHAR(200)    NOT NULL,
    [PasswordHash]    NVARCHAR(512)    NOT NULL,
    [IsEmailVerified] BIT              NOT NULL CONSTRAINT [DF_security_User_IsEmailVerified] DEFAULT (0),
    [IsActive]        BIT              NOT NULL CONSTRAINT [DF_security_User_IsActive] DEFAULT (1),
    [DateCreated]     DATETIME2(3)     NOT NULL CONSTRAINT [DF_security_User_DateCreated] DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT [PK_security_User] PRIMARY KEY CLUSTERED ([Id])
);
GO
CREATE UNIQUE INDEX [UX_security_User_Email] ON [security].[User] ([Email]);
