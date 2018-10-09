DECLARE
@nProcessorCount	INT
,@vcProcessorModel	VARCHAR(5)
,@vcProcessorType	VARCHAR(30)
,@vcProcessorNameString	VARCHAR(60)

CREATE TABLE #tblStats 
(
[Index] INT,
[Name] VARCHAR(200),
Internal_Value VARCHAR(50),
Character_Value VARCHAR(200)
)

INSERT INTO #tblStats
EXEC master.dbo.xp_msver 'ProcessorCount'
INSERT INTO #tblStats 
EXEC master.dbo.xp_msver 'ProcessorType'
INSERT INTO #tblStats
EXEC master.dbo.xp_msver 'ProcessorType'


SELECT @nProcessorCount = Internal_Value FROM #tblStats WHERE [Index] = 16
SELECT @vcProcessorModel = Internal_Value FROM #tblStats WHERE [Index] = 18
SELECT @vcProcessorType = Character_Value FROM #tblStats WHERE [Index] = 18 

EXEC master.dbo.xp_instance_regread	N'HKEY_LOCAL_MACHINE',
N'HARDWARE\DESCRIPTION\System\CentralProcessor\0',
N'ProcessorNameString',
@vcProcessorNameString OUTPUT,
N'no_output' 

SELECT 
@nProcessorCount 
,@vcProcessorModel
,@vcProcessorType
,@vcProcessorNameString


DROP TABLE #tblStats