CREATE TABLE [list].[TeamInvitation]
(
    [Id]                UNIQUEIDENTIFIER NOT NULL,
    [Index]             BIGINT           IDENTITY (1, 1) NOT NULL,
    [TeamId]            UNIQUEIDENTIFIER NOT NULL,
    [EmailNormalized]   NVARCHAR(256)    NOT NULL,
    [TokenHash]         NVARCHAR(64)     NOT NULL,
    [InvitedByUserId]   UNIQUEIDENTIFIER NOT NULL,
    [DateCreated]       DATETIME2(3)     NOT NULL CONSTRAINT [DF_list_TeamInvitation_DateCreated] DEFAULT (SYSUTCDATETIME()),
    [DateExpires]       DATETIME2(3)     NOT NULL,
    [DateRevoked]       DATETIME2(3)     NULL,
    [DateConsumed]      DATETIME2(3)     NULL,
    [ConsumedByUserId]  UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_list_TeamInvitation]                 PRIMARY KEY NONCLUSTERED ([Id]),
    CONSTRAINT [FK_list_TeamInvitation_Team]            FOREIGN KEY ([TeamId])           REFERENCES [list].[Team]     ([Id]) ON DELETE CASCADE,
    CONSTRAINT [FK_list_TeamInvitation_InvitedByUser]   FOREIGN KEY ([InvitedByUserId])  REFERENCES [security].[User] ([Id]),
    CONSTRAINT [FK_list_TeamInvitation_ConsumedByUser]  FOREIGN KEY ([ConsumedByUserId]) REFERENCES [security].[User] ([Id])
);
GO
CREATE UNIQUE CLUSTERED INDEX [CX_list_TeamInvitation_Index] ON [list].[TeamInvitation] ([Index]);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_list_TeamInvitation_TokenHash] ON [list].[TeamInvitation] ([TokenHash]);
GO
CREATE NONCLUSTERED INDEX [IX_list_TeamInvitation_TeamId] ON [list].[TeamInvitation] ([TeamId]);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_list_TeamInvitation_TeamId_EmailNormalized_Pending]
    ON [list].[TeamInvitation] ([TeamId], [EmailNormalized])
    WHERE [DateConsumed] IS NULL AND [DateRevoked] IS NULL;
