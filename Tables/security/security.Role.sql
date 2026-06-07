CREATE TABLE [security].[Role]
(
    [Id]          UNIQUEIDENTIFIER NOT NULL,
    [Name]        NVARCHAR(128)    NOT NULL,
    [Description] NVARCHAR(512)    NULL,
    CONSTRAINT [PK_security_Role] PRIMARY KEY CLUSTERED ([Id])
);
GO
CREATE UNIQUE INDEX [UX_security_Role_Name] ON [security].[Role] ([Name]);
