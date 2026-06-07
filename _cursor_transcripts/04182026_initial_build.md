# Database datetime field renaming
_Exported on 4/18/2026 at 10:34:40 EDT from Cursor (3.1.15)_

---

**User**

okay for all tables in @TeamList.Database/Tables/ I would like CreatedUtc to be renamed DateCreated. AssignedUtc renamed to DateAssigned. Any related datetime field should utilize this same convention

---

**Cursor**

I've reviewed all three table files. Here's what I found:

- `security.User.sql` has `CreatedUtc` (and the default constraint `DF_security_User_CreatedUtc`)
- `security.UserRole.sql` has `AssignedUtc` (and the default constraint `DF_security_UserRole_AssignedUtc`)
- `security.Role.sql` has no datetime columns

These columns are not referenced anywhere else in the codebase, so the rename is isolated to these two files.

---

**User**

Implement the plan as specified, it is attached for your reference. Do NOT edit the plan file itself.

To-do's from the plan have already been created. Do not create them again. Mark them as in_progress as you work, starting with the first one. Don't stop until you have completed all the to-dos.

---

**Cursor**

Both renames are complete.

- [TeamList.Database/Tables/security.User.sql](TeamList.Database/Tables/security.User.sql): `CreatedUtc` -> `DateCreated`, default constraint `DF_security_User_CreatedUtc` -> `DF_security_User_DateCreated`
- [TeamList.Database/Tables/security.UserRole.sql](TeamList.Database/Tables/security.UserRole.sql): `AssignedUtc` -> `DateAssigned`, default constraint `DF_security_UserRole_AssignedUtc` -> `DF_security_UserRole_DateAssigned`

`security.Role.sql` was left untouched since it has no datetime columns.

---

**User**

can you create a new folder insider of @TeamList.Database/Tables/ called "security"? Then move all .sql files in @TeamList.Database/Tables/into the new folder

---

**Cursor**

I've reviewed the `.sqlproj` — it explicitly lists each `.sql` file with its path, so moving the files also requires updating the project file so the build still includes them.

---

**User**

Implement the plan as specified, it is attached for your reference. Do NOT edit the plan file itself.

To-do's from the plan have already been created. Do not create them again. Mark them as in_progress as you work, starting with the first one. Don't stop until you have completed all the to-dos.

---

**Cursor**

Done. Summary of changes:

- Created `TeamList.Database/Tables/security/` and moved all three files (`security.User.sql`, `security.Role.sql`, `security.UserRole.sql`) into it.
- Updated [TeamList.Database/TeamList.Database.sqlproj](TeamList.Database/TeamList.Database.sqlproj):
  - Added `<Folder Include="Tables\security" />`
  - Updated the three `<Build Include="..." />` entries to `Tables\security\...`

---

**User**

can you ensure the moved files are tracked?

---

**Cursor**

The workspace isn't a git repository (no `.git` folder), so there's nothing git-side to track. Let me confirm what "tracked" means here. There are two relevant senses:

1. **Git version control** — `git status` returns `fatal: not a git repository`. No git repo exists at `C:\projects\TeamList\TeamList` or its parent.
2. **SSDT project tracking** — the `.sqlproj` already references the moved files at their new paths. Let me verify.

The SSDT project tracking is already correct — the `Tables\security` folder is registered and all three moved files are listed with their new `Tables\security\...` paths, so the build will pick them up.

If you meant git tracking, I can initialize a repo and commit the current state. Which would you like?

> **What did you mean by "tracked"? The workspace isn't currently a git repo.**
> - Just confirm SSDT/.sqlproj tracking (already done) - no further action
> - Initialize a new git repo here and commit the current state
> - Something else - I will clarify
>
> Answer: I mean ensure all *.sql files are tracked by git

> **There is no existing git repo at C:\projects\TeamList\TeamList or any parent directory. To git-track the files, a repo needs to be initialized first. How would you like to proceed?**
> - Initialize repo at C:\projects\TeamList\TeamList (solution root) and commit all files
> - Initialize repo at TeamList.Database (database project folder) and commit all files
> - Don't initialize - skip this
>
> Answer: the repo should exist at  C:\projects\TeamList\TeamList\TeamList.Database

A git repo does exist at `TeamList.Database` (my earlier `git status` ran from the wrong directory). Let me check status and add the moved files.

All three `.sql` files are now tracked by git as renames (not delete + add), so history is preserved:

- `Tables/security.Role.sql` -> `Tables/security/security.Role.sql`
- `Tables/security.User.sql` -> `Tables/security/security.User.sql`
- `Tables/security.UserRole.sql` -> `Tables/security/security.UserRole.sql`

The changes are staged but not committed. The `TeamList.Database.sqlproj` modification (the new folder/build paths) is left unstaged - let me know if you want me to stage and/or commit.

---

**User**

okay now I need to add another schema in @TeamList.Database/Schemas/ called "list" and a folder under @TeamList.Database/Tables/ with the same name

Implement the plan as specified, it is attached for your reference. Do NOT edit the plan file itself.

To-do's from the plan have already been created. Do not create them again. Mark them as in_progress as you work, starting with the first one. Don't stop until you have completed all the to-dos.

---

**Cursor**

All done. Summary:

- Created [TeamList.Database/Schemas/list.sql](TeamList.Database/Schemas/list.sql) with `CREATE SCHEMA [list] AUTHORIZATION [dbo];`
- Created empty folder `TeamList.Database/Tables/list/`
- Updated [TeamList.Database/TeamList.Database.sqlproj](TeamList.Database/TeamList.Database.sqlproj) with:
  - `<Folder Include="Tables\list" />`
  - `<Build Include="Schemas\list.sql" />`

Note: the empty `Tables/list/` folder won't show up in `git status` until a file is added to it, but Visual Studio/SSDT will display it via the `<Folder>` entry.

---

**User**

@list in this folder I need new tables to represent todo lists with todo items. The todo lists should be able to be shared by multiple users (as defined by rows in the @TeamList.Database/Tables/security/security.User.sql table). Todo lists and items should have created and modified dates. Items should have states that include 1) New 2) In Progress 3) Completed and 4) Aborted. These states should be in their own state table. Each table's primary key field should be GUID not null except for state tables which should be an int. None should be identity columns. The state id values should be increments of 1000. Each table with a GUID primary key should also have an "Index" column that is a bigint IDENTITY (1,1). This column should created as a clustered index whereas the primary key GUID column should ne nonclustered. Each item can be assigned to a specific user. Each list should be assigned to a Team (new table also). A Team should have a list of Users that are part of that team.

---

**Cursor**

Let me check a couple of references to make sure the plan aligns with existing conventions.

---

**User**

Implement the plan as specified, it is attached for your reference. Do NOT edit the plan file itself.

To-do's from the plan have already been created. Do not create them again. Mark them as in_progress as you work, starting with the first one. Don't stop until you have completed all the to-dos.

---

**Cursor**

All done. Summary of changes:

**New table files in `list` schema:**
- [TeamList.Database/Tables/list/list.ItemState.sql](TeamList.Database/Tables/list/list.ItemState.sql) - int PK state lookup
- [TeamList.Database/Tables/list/list.Team.sql](TeamList.Database/Tables/list/list.Team.sql) - GUID PK nonclustered, `[Index]` clustered
- [TeamList.Database/Tables/list/list.TeamUser.sql](TeamList.Database/Tables/list/list.TeamUser.sql) - junction with composite PK
- [TeamList.Database/Tables/list/list.TodoList.sql](TeamList.Database/Tables/list/list.TodoList.sql) - GUID PK, FK to Team, Date fields
- [TeamList.Database/Tables/list/list.TodoItem.sql](TeamList.Database/Tables/list/list.TodoItem.sql) - GUID PK, FKs to TodoList / ItemState / User, Date fields

**New post-deploy seed script:**
- [TeamList.Database/Scripts/Script.PostDeployment.sql](TeamList.Database/Scripts/Script.PostDeployment.sql) - idempotent MERGE seeding states 1000/2000/3000/4000

**Updated project:**
- [TeamList.Database/TeamList.Database.sqlproj](TeamList.Database/TeamList.Database.sqlproj) - added `Scripts` folder, 5 new `<Build>` entries, and the `<PostDeploy>` entry.

---

**User**

create a file called "standards.design.md" in @TeamList.Database/ that contains all the understand design standards/guidelines established in this chat

Implement the plan as specified, it is attached for your reference. Do NOT edit the plan file itself.

To-do's from the plan have already been created. Do not create them again. Mark them as in_progress as you work, starting with the first one. Don't stop until you have completed all the to-dos.

---

**Cursor**

Created [TeamList.Database/standards.design.md](TeamList.Database/standards.design.md) with the 9 sections covering:

1. Project structure (SSDT layout, file naming, `.sqlproj` registration)
2. Identifier and naming conventions (bracket-quoting, PK/FK/DF/UX/IX/CX patterns)
3. Primary keys and the `[Index]` column (GUID nonclustered + bigint identity clustered)
4. Date/time columns (`DATETIME2(3)`, `SYSUTCDATETIME()`, `Date<Verb>` naming)
5. Foreign keys and cascade rules
6. Indexes (FK coverage, unique natural keys)
7. State / lookup tables (int PK, increments of 1000, `MERGE` seeds)
8. SQL style (`GO`, NVARCHAR lengths, one table per file)
9. A worked example using `[list].[TodoList]`

