USE [Processed_Data]

-- Cards 

SELECT * --[RecordID],[AccountID],[TimeStamp],[UserID],[NodeID],[Deleted],[UserPriority],[CardNumber],[Issue],[CardHolderID],[AccessLevelID],[ExpirationDate],[NoOfUsesLeft],[PIN1],[PIN2],[CMDFileID],[CardStatus],[Display],[BackDrop1ID],[BackDrop2ID],[ActionGroupID],[LastReaderHID],[LastReaderDate],[PrintStatus],[SpareW1],[SpareW2],[SpareW3],[SpareW4],[SpareDW1],[SpareDW2],[SpareDW3],[SpareDW4],[SpareStr1],[SpareStr2]
from Card_Giles_Test
EXCEPT
SELECT * --[RecordID],[AccountID],[TimeStamp],[UserID],[NodeID],[Deleted],[UserPriority],[CardNumber],[Issue],[CardHolderID],[AccessLevelID],[ExpirationDate],[NoOfUsesLeft],[PIN1],[PIN2],[CMDFileID],[CardStatus],[Display],[BackDrop1ID],[BackDrop2ID],[ActionGroupID],[LastReaderHID],[LastReaderDate],[PrintStatus],[SpareW1],[SpareW2],[SpareW3],[SpareW4],[SpareDW1],[SpareDW2],[SpareDW3],[SpareDW4],[SpareStr1],[SpareStr2]
from [BC-CW-WINPAK].[WIN-PAK 2].dbo.Card

-- CardHolder

SELECT *
FROM CardHolder_Giles_Test
EXCEPT
SELECT *
from [BC-CW-WINPAK].[WIN-PAK 2].dbo.CardHolder

--

SELECT [NSID],	[Surname],	[Forename],	[PersonCode],	[StaffCode],	[SpclDescription],	[CollegeLogin],	[CardIssueNo],	[DateAdded],	[ReviewMonths],	[ApprovedBy],	[LastReviewed],	[Team],	[ActiveStaff]
FROM NonStaff
EXCEPT
SELECT [NSID],	[Surname],	[Forename],	[PersonCode],	[StaffCode],	[SpclDescription],	[CollegeLogin],	[CardIssueNo],	[DateAdded],	[ReviewMonths],	[ApprovedBy],	[LastReviewed],	[Team],	[ActiveStaff]
FROM [BC-SQL-01].Processed_Data.dbo.NonStaff


 [BC-SQL-01].processed_data.dbo.tblStudentAccessLevels
		UPDATE Student_Access_Levels

			SET @SQL = 'SELECT FES_STAFF_CODE,
							   UPDATED_BY,
							   UPDATED_DATE	
						FROM FES.PEOPLE
						 WHERE PERSON_CODE = ' + @Person_Code 

			SET @SQL = 'UPDATE OPENQUERY (' + @EBSDatabase +',''' + REPLACE(@SQL, '''', '''''') + ''')'  + ' 
						SET	FES_STAFF_CODE = NULL,
							UPDATED_BY = ''Process_Security_Data'',' + '
							UPDATED_DATE = ''' + CONVERT(VARCHAR(20), GETDATE(), 113) + '''' 


 'SELECT ACL_LEVEL, USER_PRIORITY, TEMP_PRIORITY FROM BROX_ACCESS_LEVEL_PRIORITY'