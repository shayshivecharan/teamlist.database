CREATE TABLE [list].[ItemState]
(
    [Id]   INT          NOT NULL,
    [Name] NVARCHAR(64) NOT NULL,
    CONSTRAINT [PK_list_ItemState] PRIMARY KEY CLUSTERED ([Id])
);
GO
CREATE UNIQUE INDEX [UX_list_ItemState_Name] ON [list].[ItemState] ([Name]);
