/*
	Error description									event_type value
	=================									===============
	823 error caused by an operating system				1
	CRC error or 824 error other than a bad checksum 
	or a torn page (for example, a bad page ID)
		
	Bad checksum										2

	Torn page											3

	Restored (The page was restored after it			4		
	was marked bad)
		

	Repaired (DBCC repaired the page)					5

	Deallocated by DBCC									7
*/


SELECT * FROM msdb..suspect_pages
WHERE (event_type = 1 OR event_type = 2 OR event_type = 3);