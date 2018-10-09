/*

http://technet.microsoft.com/en-us/library/ms345414(v=sql.105).aspx

If you have a transaction log that is not growing, and you’re taking regular log backups, but the log_reuse_wait_desc remains LOG_BACKUP, this is because zero VLFs were cleared when the previous log backup was performed.

How can that happen?

Imagine a database where there’s very little insert/update/delete/DDL activity, so in between your regular log backups there are only a few log records generated, and they’re all in the same VLF. The next log backup runs, backing up those few log records, but it can’t clear the current VLF, so can’t clear log_reuse_wait_desc. As soon as there are enough changes in the database that the current VLF fills up and the next VLF is activated, the next log backup should be able to clear the previous VLF and then the log_reuse_wait_desc will revert to NOTHING. Until the next log backup occurs and isn’t able to clear the current VLF, in which case it will go back to LOG_BACKUP again.

So LOG_BACKUP really means “either you need to take a log backup, or the log records that were backed up were all in the current VLF and so it could not be cleared.”

*/


SELECT name, [log_reuse_wait_desc]
	FROM [master].[sys].[databases]
--	WHERE [name] = N'Company';