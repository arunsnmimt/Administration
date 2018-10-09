SELECT SubString(S2.Name,1,30) as [Table],
SubString(S.Name, 1,30) as [Trigger],
CASE (SELECT -- Correlated subquery
OBJECTPROPERTY(OBJECT_ID(S.Name),
'ExecIsTriggerDisabled'))
WHEN 0 THEN 'Enabled'
WHEN 1 THEN 'Disabled'
END AS Status
FROM Sysobjects S
JOIN Sysobjects S2
ON S.parent_obj = S2.ID
WHERE S.Type = 'TR'
ORDER BY [Table], [Trigger]

