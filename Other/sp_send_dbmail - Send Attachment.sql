-- For attached messages must be run under Windows User 
-- RUN ON SUNNY

	EXEC msdb.dbo.sp_send_dbmail
		@profile_name = 'Microlise',
		@recipients = 'charlie.george@booker.co.uk; gary.grace@booker.co.uk; Douglas.Waight@booker.co.uk',
		@blind_copy_recipients = 'chris.pitsillidis@microlise.com; dba@microlise.com;',
		@subject = 'Booker Direct PvA Report', 
		@body = 'Please find attached the Booker Direct PvA Report for the last 7 days (WB Mon 8th July). This is an automated report, please do not reply directly to this email',
		@file_attachments = 'C:\temp\Booker Direct PvA Last 7 Days (Mon-Sun).xls'
		
		
		

-- BnQ Pod Extract 
-- RUN ON SUNNY
/*
	EXEC msdb.dbo.sp_send_dbmail
		@profile_name = 'Microlise',
		@recipients = 'Branston.MIS@b-and-q.co.uk',
		@blind_copy_recipients = 'dba@microlise.com; andrew.curtis@microlise.com',
		@subject = 'Daily POD Extract - Friday 28th June', 
		@body = 'Please find attached the POD Daily Extract file for Friday 28th June. This is an automated email, please do not reply direct to this email.',
		@file_attachments = 'c:\temp\BnQ_POD_2013-06-29.7z'
		
		
	EXEC msdb.dbo.sp_send_dbmail
		@profile_name = 'Microlise',
		@recipients = 'stephen.warden@jcb.com; adam-r.elliott@jcb.com',
		@copy_recipients = 'paul.woodward@microlise.com',
		@blind_copy_recipients = 'john.waller@microlise.com; grant.pettigrew@microlise.com; michael.giles@microlise.com',
		@subject = 'JCB Dealership LLECU Data', 
		@body = 'Pleased find attached the JCB Dealership LLECU Data. This is an automated report, please do not reply to this email.',
		@file_attachments = 'c:\temp\JCB Machine List Report.xls'		
*/		