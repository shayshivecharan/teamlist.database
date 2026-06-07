# TeamList Database - Design Standards

This document captures the database design standards and conventions for the
`TeamList.Database` SSDT project. New schema work should follow these rules so
that tables, indexes, and constraints remain consistent across the codebase.

## 1. Project structure

- The database is an SSDT (`.sqlproj`) declarative schema. There are no
  imperative migration scripts; the target database is brought into line with
  the model at publish time.
- Folder layout:
  - `Schemas/` - one file per schema. Each file contains a single
    `CREATE SCHEMA [<name>] AUTHORIZATION [dbo];` statement (for example
    `Schemas/security.sql`, `Schemas/list.sql`).
  - `Tables/<schema>/` - one file per table, grouped by schema.
  - `Scripts/Script.PostDeployment.sql` - idempotent seed data using `MERGE`.
- File name convention: `<schema>.<TableName>.sql`
  (for example `security.User.sql`, `list.TodoItem.sql`).
- Every `.sql` file must be listed explicitly in `TeamList.Database.sqlproj`:
  - Schema and table files under `<ItemGroup>` as `<Build Include="..." />`.
  - The post-deploy script under `<ItemGroup>` as
    `<PostDeploy Include="Scripts\Script.PostDeployment.sql" />`.
  - Every folder must have a matching `<Folder Include="..." />` entry.

## 2. Identifier and naming conventions

- All object and column names are bracket-quoted: `[schema].[Table]`,
  `[Column]`.
- Tables and columns use `PascalCase`. Schemas are lowercase
  (for example `security`, `list`).
- Constraint and index naming:

  | Kind                     | Pattern                             |
  | ------------------------ | ----------------------------------- |
  | Primary key              | `PK_<schema>_<Table>`               |
  | Foreign key              | `FK_<schema>_<ChildTable>_<Parent>` |
  | Default constraint       | `DF_<schema>_<Table>_<Column>`      |
  | Unique nonclustered idx  | `UX_<schema>_<Table>_<Column>`      |
  | Nonunique nonclustered   | `IX_<schema>_<Table>_<Column>`      |
  | Clustered idx on `Index` | `CX_<schema>_<Table>_Index`         |

## 3. Primary keys and the `[Index]` column

- Entity tables use `[Id] UNIQUEIDENTIFIER NOT NULL` as the primary key,
  declared `NONCLUSTERED`. The column is never `IDENTITY`; GUIDs are generated
  by the application (or `NEWID()` / `NEWSEQUENTIALID()` if defaulted).
- Every entity table also has `[Index] BIGINT NOT NULL IDENTITY(1,1)` backed
  by `CREATE UNIQUE CLUSTERED INDEX [CX_<schema>_<Table>_Index]`. This
  provides sequential physical ordering on inserts while keeping the GUID as
  the logical key.
- Consumers of the `[Index]` column must treat it as always store-generated:
  no client should ever write to it on insert or update. For EF Core
  specifically, configure it with `ValueGeneratedOnAddOrUpdate()` (not
  `ValueGeneratedOnAdd()`); see
  [`TeamList.Api/TeamList.Api/standards.design.md`](../TeamList.Api/TeamList.Api/standards.design.md)
  section 5 for the full pattern.
- Junction / many-to-many tables: composite primary key made up of the FK
  columns, PK `CLUSTERED`, no `[Index]` column. Examples:
  `[security].[UserRole]`, `[list].[TeamUser]`.
- Lookup / state tables: `[Id] INT NOT NULL`, PK `CLUSTERED`, never
  `IDENTITY`. ID values are assigned manually in increments of 1000
  (for example 1000, 2000, 3000, 4000) and seeded via the post-deploy
  `MERGE`. The gap between values leaves room for future insertions without
  renumbering.

## 4. Date/time columns

- Type is always `DATETIME2(3)`.
- Defaulted with `SYSUTCDATETIME()`:

  ```sql
  [DateCreated] DATETIME2(3) NOT NULL
      CONSTRAINT [DF_list_TodoList_DateCreated] DEFAULT (SYSUTCDATETIME())
  ```

- Naming uses the `Date<Verb>` form: `DateCreated`, `DateModified`,
  `DateAssigned`, `DateJoined`. Do **not** use a `...Utc` suffix.
- Entity tables that track lifecycle include both `DateCreated` and
  `DateModified`.
- Junction tables typically have a single membership timestamp column
  (for example `DateJoined` on `[list].[TeamUser]`, `DateAssigned` on
  `[security].[UserRole]`).

## 5. Foreign keys and cascade rules

- Junction tables cascade on both sides (`ON DELETE CASCADE` on each FK).
- Owning parent/child relationships (for example `TodoList -> TodoItem`) use
  `ON DELETE CASCADE` from the child FK to the parent.
- Nullable assignment FKs (for example
  `TodoItem.AssignedUserId -> security.User`) use `ON DELETE SET NULL` so the
  row survives deletion of the referenced principal.
- FKs to lookup / state tables use the default `NO ACTION`.
- All other FKs use the default `NO ACTION`.
- Avoid creating multiple cascade paths that converge on the same table - SQL
  Server will reject the FK.

## 6. Indexes

- Add a nonclustered index on every FK column that is not already the leading
  column of another index (so joins and cascade operations have an index to
  seek into).
- Add `UX_*` unique indexes on natural-key columns that must be unique across
  the table (for example `[security].[User].[UserName]`,
  `[security].[Role].[Name]`, `[list].[Team].[Name]`).

## 7. State / lookup tables

- Live in the owning feature schema (for example `[list].[ItemState]`, not a
  global `dbo` bucket).
- Minimum shape:

  ```sql
  CREATE TABLE [list].[ItemState]
  (
      [Id]   INT          NOT NULL,
      [Name] NVARCHAR(64) NOT NULL,
      CONSTRAINT [PK_list_ItemState] PRIMARY KEY CLUSTERED ([Id])
  );
  GO
  CREATE UNIQUE INDEX [UX_list_ItemState_Name] ON [list].[ItemState] ([Name]);
  ```

- Values are seeded via post-deploy `MERGE` using `(Id, Name)` source rows so
  the seed is idempotent across repeated publishes.
- Consumer tables default the FK column to the baseline state ID, for
  example `[TodoItem].[StateId] INT NOT NULL DEFAULT (1000)`.

## 8. SQL style

- Use `GO` to separate `CREATE TABLE` from the follow-up `CREATE INDEX`
  statements within the same file.
- NVARCHAR lengths are always explicit; use `N'...'` string literals for
  NVARCHAR values.
- Keep each file scoped to a single table (plus its indexes).
- Align column declarations for readability.

## 9. Worked example

A minimal compliant entity table combining the rules above:

```sql
CREATE TABLE [list].[TodoList]
(
    [Id]           UNIQUEIDENTIFIER NOT NULL,
    [Index]        BIGINT           NOT NULL IDENTITY(1,1),
    [TeamId]       UNIQUEIDENTIFIER NOT NULL,
    [Name]         NVARCHAR(256)    NOT NULL,
    [DateCreated]  DATETIME2(3)     NOT NULL CONSTRAINT [DF_list_TodoList_DateCreated]  DEFAULT (SYSUTCDATETIME()),
    [DateModified] DATETIME2(3)     NOT NULL CONSTRAINT [DF_list_TodoList_DateModified] DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT [PK_list_TodoList] PRIMARY KEY NONCLUSTERED ([Id]),
    CONSTRAINT [FK_list_TodoList_Team] FOREIGN KEY ([TeamId]) REFERENCES [list].[Team] ([Id])
);
GO
CREATE UNIQUE CLUSTERED INDEX [CX_list_TodoList_Index] ON [list].[TodoList] ([Index]);
GO
CREATE INDEX [IX_list_TodoList_TeamId] ON [list].[TodoList] ([TeamId]);
```

---

This document is a living reference. When a new design pattern is agreed on
(for example an update trigger for `DateModified`, soft-delete columns, or
row-version tracking), update this file as part of the same change.
