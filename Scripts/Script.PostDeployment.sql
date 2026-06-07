
/*
Post-deployment script (runs at the end of every publish).
Idempotent backfills only — safe to re-run.
See TeamList.Prd/UserManagement/decisions-team-admin-user-management.md.
*/

PRINT N'Backfill: TeamUser.TeamRole — promote earliest joiner per team to TeamAdmin (idempotent).';

;WITH FirstJoiner AS (
    SELECT
        [TeamId],
        [UserId],
        ROW_NUMBER() OVER (
            PARTITION BY [TeamId]
            ORDER BY [DateJoined] ASC, [UserId] ASC
        ) AS rn
    FROM [list].[TeamUser]
)
UPDATE tu
SET tu.[TeamRole] = 2 -- TeamAdmin
FROM [list].[TeamUser] tu
JOIN FirstJoiner fj
    ON fj.[TeamId] = tu.[TeamId]
   AND fj.[UserId] = tu.[UserId]
WHERE fj.rn = 1
  AND NOT EXISTS (
      SELECT 1
      FROM [list].[TeamUser] x
      WHERE x.[TeamId]   = tu.[TeamId]
        AND x.[TeamRole] = 2
  );


MERGE INTO [list].[ItemState] AS target
USING (VALUES
    (1000, N'New'),
    (2000, N'In Progress'),
    (3000, N'Completed'),
    (4000, N'Aborted')
) AS source ([Id], [Name])
ON target.[Id] = source.[Id]
WHEN MATCHED AND target.[Name] <> source.[Name] THEN
    UPDATE SET [Name] = source.[Name]
WHEN NOT MATCHED BY TARGET THEN
    INSERT ([Id], [Name]) VALUES (source.[Id], source.[Name]);
