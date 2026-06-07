CREATE TABLE [security].[EmailVerificationToken]
(
    [Id]            UNIQUEIDENTIFIER NOT NULL,
    [Index]         BIGINT           NOT NULL IDENTITY (1, 1),
    [UserId]        UNIQUEIDENTIFIER NOT NULL,
    [Token]         NVARCHAR(256)    NOT NULL,
    [DateCreated]   DATETIME2(3)     NOT NULL CONSTRAINT [DF_security_EmailVerificationToken_DateCreated] DEFAULT (SYSUTCDATETIME()),
    [DateExpires]   DATETIME2(3)     NOT NULL,
    [DateConsumed]  DATETIME2(3)     NULL,
    CONSTRAINT [PK_security_EmailVerificationToken] PRIMARY KEY NONCLUSTERED ([Id]),
    CONSTRAINT [FK_security_EmailVerificationToken_User] FOREIGN KEY ([UserId]) REFERENCES [security].[User] ([Id]) ON DELETE CASCADE
);
GO
CREATE UNIQUE CLUSTERED INDEX [CX_security_EmailVerificationToken_Index] ON [security].[EmailVerificationToken] ([Index]);
GO
CREATE UNIQUE INDEX [UX_security_EmailVerificationToken_Token] ON [security].[EmailVerificationToken] ([Token]);
GO
CREATE INDEX [IX_security_EmailVerificationToken_UserId] ON [security].[EmailVerificationToken] ([UserId]);
