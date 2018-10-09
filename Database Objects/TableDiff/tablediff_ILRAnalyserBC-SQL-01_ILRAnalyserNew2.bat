DEL /Q "H:\SQL Server\TableDiff\*.*"
rem "C:\Program Files\Microsoft SQL Server\90\COM\tablediff.exe" -sourceserver "SQL-02" -sourcedatabase "ILRAnalyserBC-SQL-01" -sourceschema "dbo" -sourcetable "atblAimLevelSummary" -destinationserver "SQL-02" -destinationdatabase "ILRAnalyserNew2" -destinationschema "dbo" -destinationtable "atblAimLevelSummary" -dt -et "Difference_atblAimLevelSummary" -o "h:\SQL Server\TableDiff\Difference_atblAimLevelSummary.txt" -f "h:\SQL Server\TableDiff\Update_atblAimLevelSummary.sql"
"C:\Program Files\Microsoft SQL Server\90\COM\tablediff.exe" -sourceserver "SQL-02" -sourcedatabase "ILRAnalyserBC-SQL-01" -sourceschema "dbo" -sourcetable "atblCourseLevelSummary" -destinationserver "SQL-02" -destinationdatabase "ILRAnalyserNew2" -destinationschema "dbo" -destinationtable "atblCourseLevelSummary" -dt -et "Difference_atblCourseLevelSummary" -o "h:\SQL Server\TableDiff\Difference_atblCourseLevelSummary.txt" -f "h:\SQL Server\TableDiff\Update_atblCourseLevelSummary.sql"
rem "C:\Program Files\Microsoft SQL Server\90\COM\tablediff.exe" -sourceserver "SQL-02" -sourcedatabase "ILRAnalyserBC-SQL-01" -sourceschema "dbo" -sourcetable "atblDeptFunding" -destinationserver "SQL-02" -destinationdatabase "ILRAnalyserNew2" -destinationschema "dbo" -destinationtable "atblDeptFunding" -dt -et "Difference_atblDeptFunding" -o "h:\SQL Server\TableDiff\Difference_atblDeptFunding.txt" -f "h:\SQL Server\TableDiff\Update_atblDeptFunding.sql"
rem "C:\Program Files\Microsoft SQL Server\90\COM\tablediff.exe" -sourceserver "SQL-02" -sourcedatabase "ILRAnalyserBC-SQL-01" -sourceschema "dbo" -sourcetable "atblDivisionalKPI" -destinationserver "SQL-02" -destinationdatabase "ILRAnalyserNew2" -destinationschema "dbo" -destinationtable "atblDivisionalKPI" -dt -et "Difference_atblDivisionalKPI" -o "h:\SQL Server\TableDiff\Difference_atblDivisionalKPI.txt" -f "h:\SQL Server\TableDiff\Update_atblDivisionalKPI.sql"
rem "C:\Program Files\Microsoft SQL Server\90\COM\tablediff.exe" -sourceserver "SQL-02" -sourcedatabase "ILRAnalyserBC-SQL-01" -sourceschema "dbo" -sourcetable "atblFundingYears" -destinationserver "SQL-02" -destinationdatabase "ILRAnalyserNew2" -destinationschema "dbo" -destinationtable "atblFundingYears" -dt -et "Difference_atblFundingYears" -o "h:\SQL Server\TableDiff\Difference_atblFundingYears.txt" -f "h:\SQL Server\TableDiff\Update_atblFundingYears.sql"
rem "C:\Program Files\Microsoft SQL Server\90\COM\tablediff.exe" -sourceserver "SQL-02" -sourcedatabase "ILRAnalyserBC-SQL-01" -sourceschema "dbo" -sourcetable "atblKPI" -destinationserver "SQL-02" -destinationdatabase "ILRAnalyserNew2" -destinationschema "dbo" -destinationtable "atblKPI" -dt -et "Difference_atblKPI" -o "h:\SQL Server\TableDiff\Difference_atblKPI.txt" -f "h:\SQL Server\TableDiff\Update_atblKPI.sql"
rem "C:\Program Files\Microsoft SQL Server\90\COM\tablediff.exe" -sourceserver "SQL-02" -sourcedatabase "ILRAnalyserBC-SQL-01" -sourceschema "dbo" -sourcetable "atblLearnerAimSummary" -destinationserver "SQL-02" -destinationdatabase "ILRAnalyserNew2" -destinationschema "dbo" -destinationtable "atblLearnerAimSummary" -dt -et "Difference_atblLearnerAimSummary" -o "h:\SQL Server\TableDiff\Difference_atblLearnerAimSummary.txt" -f "h:\SQL Server\TableDiff\Update_atblLearnerAimSummary.sql"
rem "C:\Program Files\Microsoft SQL Server\90\COM\tablediff.exe" -sourceserver "SQL-02" -sourcedatabase "ILRAnalyserBC-SQL-01" -sourceschema "dbo" -sourcetable "atblLearnerNumbyOfferor" -destinationserver "SQL-02" -destinationdatabase "ILRAnalyserNew2" -destinationschema "dbo" -destinationtable "atblLearnerNumbyOfferor" -dt -et "Difference_atblLearnerNumbyOfferor" -o "h:\SQL Server\TableDiff\Difference_atblLearnerNumbyOfferor.txt" -f "h:\SQL Server\TableDiff\Update_atblLearnerNumbyOfferor.sql"
rem "C:\Program Files\Microsoft SQL Server\90\COM\tablediff.exe" -sourceserver "SQL-02" -sourcedatabase "ILRAnalyserBC-SQL-01" -sourceschema "dbo" -sourcetable "atblPIAim" -destinationserver "SQL-02" -destinationdatabase "ILRAnalyserNew2" -destinationschema "dbo" -destinationtable "atblPIAim" -dt -et "Difference_atblPIAim" -o "h:\SQL Server\TableDiff\Difference_atblPIAim.txt" -f "h:\SQL Server\TableDiff\Update_atblPIAim.sql"
rem "C:\Program Files\Microsoft SQL Server\90\COM\tablediff.exe" -sourceserver "SQL-02" -sourcedatabase "ILRAnalyserBC-SQL-01" -sourceschema "dbo" -sourcetable "atblPILearner" -destinationserver "SQL-02" -destinationdatabase "ILRAnalyserNew2" -destinationschema "dbo" -destinationtable "atblPILearner" -dt -et "Difference_atblPILearner" -o "h:\SQL Server\TableDiff\Difference_atblPILearner.txt" -f "h:\SQL Server\TableDiff\Update_atblPILearner.sql"
rem "C:\Program Files\Microsoft SQL Server\90\COM\tablediff.exe" -sourceserver "SQL-02" -sourcedatabase "ILRAnalyserBC-SQL-01" -sourceschema "dbo" -sourcetable "tblACLFundingData" -destinationserver "SQL-02" -destinationdatabase "ILRAnalyserNew2" -destinationschema "dbo" -destinationtable "tblACLFundingData" -dt -et "Difference_tblACLFundingData" -o "h:\SQL Server\TableDiff\Difference_tblACLFundingData.txt" -f "h:\SQL Server\TableDiff\Update_tblACLFundingData.sql"
rem "C:\Program Files\Microsoft SQL Server\90\COM\tablediff.exe" -sourceserver "SQL-02" -sourcedatabase "ILRAnalyserBC-SQL-01" -sourceschema "dbo" -sourcetable "tblAim" -destinationserver "SQL-02" -destinationdatabase "ILRAnalyserNew2" -destinationschema "dbo" -destinationtable "tblAim" -dt -et "Difference_tblAim" -o "h:\SQL Server\TableDiff\Difference_tblAim.txt" -f "h:\SQL Server\TableDiff\Update_tblAim.sql"
rem "C:\Program Files\Microsoft SQL Server\90\COM\tablediff.exe" -sourceserver "SQL-02" -sourcedatabase "ILRAnalyserBC-SQL-01" -sourceschema "dbo" -sourcetable "tblAttendanceClassLearner" -destinationserver "SQL-02" -destinationdatabase "ILRAnalyserNew2" -destinationschema "dbo" -destinationtable "tblAttendanceClassLearner" -dt -et "Difference_tblAttendanceClassLearner" -o "h:\SQL Server\TableDiff\Difference_tblAttendanceClassLearner.txt" -f "h:\SQL Server\TableDiff\Update_tblAttendanceClassLearner.sql"
rem "C:\Program Files\Microsoft SQL Server\90\COM\tablediff.exe" -sourceserver "SQL-02" -sourcedatabase "ILRAnalyserBC-SQL-01" -sourceschema "dbo" -sourcetable "tblBenchmarkHight_Level" -destinationserver "SQL-02" -destinationdatabase "ILRAnalyserNew2" -destinationschema "dbo" -destinationtable "tblBenchmarkHight_Level" -dt -et "Difference_tblBenchmarkHight_Level" -o "h:\SQL Server\TableDiff\Difference_tblBenchmarkHight_Level.txt" -f "h:\SQL Server\TableDiff\Update_tblBenchmarkHight_Level.sql"
rem "C:\Program Files\Microsoft SQL Server\90\COM\tablediff.exe" -sourceserver "SQL-02" -sourcedatabase "ILRAnalyserBC-SQL-01" -sourceschema "dbo" -sourcetable "tblBenchMarkPercentiles" -destinationserver "SQL-02" -destinationdatabase "ILRAnalyserNew2" -destinationschema "dbo" -destinationtable "tblBenchMarkPercentiles" -dt -et "Difference_tblBenchMarkPercentiles" -o "h:\SQL Server\TableDiff\Difference_tblBenchMarkPercentiles.txt" -f "h:\SQL Server\TableDiff\Update_tblBenchMarkPercentiles.sql"
rem "C:\Program Files\Microsoft SQL Server\90\COM\tablediff.exe" -sourceserver "SQL-02" -sourcedatabase "ILRAnalyserBC-SQL-01" -sourceschema "dbo" -sourcetable "tblCollegePerformance" -destinationserver "SQL-02" -destinationdatabase "ILRAnalyserNew2" -destinationschema "dbo" -destinationtable "tblCollegePerformance" -dt -et "Difference_tblCollegePerformance" -o "h:\SQL Server\TableDiff\Difference_tblCollegePerformance.txt" -f "h:\SQL Server\TableDiff\Update_tblCollegePerformance.sql"
rem "C:\Program Files\Microsoft SQL Server\90\COM\tablediff.exe" -sourceserver "SQL-02" -sourcedatabase "ILRAnalyserBC-SQL-01" -sourceschema "dbo" -sourcetable "tblCoursePerformance" -destinationserver "SQL-02" -destinationdatabase "ILRAnalyserNew2" -destinationschema "dbo" -destinationtable "tblCoursePerformance" -dt -et "Difference_tblCoursePerformance" -o "h:\SQL Server\TableDiff\Difference_tblCoursePerformance.txt" -f "h:\SQL Server\TableDiff\Update_tblCoursePerformance.sql"
rem "C:\Program Files\Microsoft SQL Server\90\COM\tablediff.exe" -sourceserver "SQL-02" -sourcedatabase "ILRAnalyserBC-SQL-01" -sourceschema "dbo" -sourcetable "tblDataDate" -destinationserver "SQL-02" -destinationdatabase "ILRAnalyserNew2" -destinationschema "dbo" -destinationtable "tblDataDate" -dt -et "Difference_tblDataDate" -o "h:\SQL Server\TableDiff\Difference_tblDataDate.txt" -f "h:\SQL Server\TableDiff\Update_tblDataDate.sql"
rem "C:\Program Files\Microsoft SQL Server\90\COM\tablediff.exe" -sourceserver "SQL-02" -sourcedatabase "ILRAnalyserBC-SQL-01" -sourceschema "dbo" -sourcetable "tblEBSCourses" -destinationserver "SQL-02" -destinationdatabase "ILRAnalyserNew2" -destinationschema "dbo" -destinationtable "tblEBSCourses" -dt -et "Difference_tblEBSCourses" -o "h:\SQL Server\TableDiff\Difference_tblEBSCourses.txt" -f "h:\SQL Server\TableDiff\Update_tblEBSCourses.sql"
rem "C:\Program Files\Microsoft SQL Server\90\COM\tablediff.exe" -sourceserver "SQL-02" -sourcedatabase "ILRAnalyserBC-SQL-01" -sourceschema "dbo" -sourcetable "tblESF" -destinationserver "SQL-02" -destinationdatabase "ILRAnalyserNew2" -destinationschema "dbo" -destinationtable "tblESF" -dt -et "Difference_tblESF" -o "h:\SQL Server\TableDiff\Difference_tblESF.txt" -f "h:\SQL Server\TableDiff\Update_tblESF.sql"
rem "C:\Program Files\Microsoft SQL Server\90\COM\tablediff.exe" -sourceserver "SQL-02" -sourcedatabase "ILRAnalyserBC-SQL-01" -sourceschema "dbo" -sourcetable "tblFEFundingData" -destinationserver "SQL-02" -destinationdatabase "ILRAnalyserNew2" -destinationschema "dbo" -destinationtable "tblFEFundingData" -dt -et "Difference_tblFEFundingData" -o "h:\SQL Server\TableDiff\Difference_tblFEFundingData.txt" -f "h:\SQL Server\TableDiff\Update_tblFEFundingData.sql"
rem "C:\Program Files\Microsoft SQL Server\90\COM\tablediff.exe" -sourceserver "SQL-02" -sourcedatabase "ILRAnalyserBC-SQL-01" -sourceschema "dbo" -sourcetable "tblHE" -destinationserver "SQL-02" -destinationdatabase "ILRAnalyserNew2" -destinationschema "dbo" -destinationtable "tblHE" -dt -et "Difference_tblHE" -o "h:\SQL Server\TableDiff\Difference_tblHE.txt" -f "h:\SQL Server\TableDiff\Update_tblHE.sql"
rem "C:\Program Files\Microsoft SQL Server\90\COM\tablediff.exe" -sourceserver "SQL-02" -sourcedatabase "ILRAnalyserBC-SQL-01" -sourceschema "dbo" -sourcetable "tblLearner" -destinationserver "SQL-02" -destinationdatabase "ILRAnalyserNew2" -destinationschema "dbo" -destinationtable "tblLearner" -dt -et "Difference_tblLearner" -o "h:\SQL Server\TableDiff\Difference_tblLearner.txt" -f "h:\SQL Server\TableDiff\Update_tblLearner.sql"
rem "C:\Program Files\Microsoft SQL Server\90\COM\tablediff.exe" -sourceserver "SQL-02" -sourcedatabase "ILRAnalyserBC-SQL-01" -sourceschema "dbo" -sourcetable "tblLocalLAD" -destinationserver "SQL-02" -destinationdatabase "ILRAnalyserNew2" -destinationschema "dbo" -destinationtable "tblLocalLAD" -dt -et "Difference_tblLocalLAD" -o "h:\SQL Server\TableDiff\Difference_tblLocalLAD.txt" -f "h:\SQL Server\TableDiff\Update_tblLocalLAD.sql"
rem "C:\Program Files\Microsoft SQL Server\90\COM\tablediff.exe" -sourceserver "SQL-02" -sourcedatabase "ILRAnalyserBC-SQL-01" -sourceschema "dbo" -sourcetable "tblLocations" -destinationserver "SQL-02" -destinationdatabase "ILRAnalyserNew2" -destinationschema "dbo" -destinationtable "tblLocations" -dt -et "Difference_tblLocations" -o "h:\SQL Server\TableDiff\Difference_tblLocations.txt" -f "h:\SQL Server\TableDiff\Update_tblLocations.sql"
rem "C:\Program Files\Microsoft SQL Server\90\COM\tablediff.exe" -sourceserver "SQL-02" -sourcedatabase "ILRAnalyserBC-SQL-01" -sourceschema "dbo" -sourcetable "tblMLP" -destinationserver "SQL-02" -destinationdatabase "ILRAnalyserNew2" -destinationschema "dbo" -destinationtable "tblMLP" -dt -et "Difference_tblMLP" -o "h:\SQL Server\TableDiff\Difference_tblMLP.txt" -f "h:\SQL Server\TableDiff\Update_tblMLP.sql"
rem "C:\Program Files\Microsoft SQL Server\90\COM\tablediff.exe" -sourceserver "SQL-02" -sourcedatabase "ILRAnalyserBC-SQL-01" -sourceschema "dbo" -sourcetable "tblProvider" -destinationserver "SQL-02" -destinationdatabase "ILRAnalyserNew2" -destinationschema "dbo" -destinationtable "tblProvider" -dt -et "Difference_tblProvider" -o "h:\SQL Server\TableDiff\Difference_tblProvider.txt" -f "h:\SQL Server\TableDiff\Update_tblProvider.sql"
rem "C:\Program Files\Microsoft SQL Server\90\COM\tablediff.exe" -sourceserver "SQL-02" -sourcedatabase "ILRAnalyserBC-SQL-01" -sourceschema "dbo" -sourcetable "tblReportTransactions" -destinationserver "SQL-02" -destinationdatabase "ILRAnalyserNew2" -destinationschema "dbo" -destinationtable "tblReportTransactions" -dt -et "Difference_tblReportTransactions" -o "h:\SQL Server\TableDiff\Difference_tblReportTransactions.txt" -f "h:\SQL Server\TableDiff\Update_tblReportTransactions.sql"
rem "C:\Program Files\Microsoft SQL Server\90\COM\tablediff.exe" -sourceserver "SQL-02" -sourcedatabase "ILRAnalyserBC-SQL-01" -sourceschema "dbo" -sourcetable "tblSuggestions" -destinationserver "SQL-02" -destinationdatabase "ILRAnalyserNew2" -destinationschema "dbo" -destinationtable "tblSuggestions" -dt -et "Difference_tblSuggestions" -o "h:\SQL Server\TableDiff\Difference_tblSuggestions.txt" -f "h:\SQL Server\TableDiff\Update_tblSuggestions.sql"
rem "C:\Program Files\Microsoft SQL Server\90\COM\tablediff.exe" -sourceserver "SQL-02" -sourcedatabase "ILRAnalyserBC-SQL-01" -sourceschema "dbo" -sourcetable "tblTargets" -destinationserver "SQL-02" -destinationdatabase "ILRAnalyserNew2" -destinationschema "dbo" -destinationtable "tblTargets" -dt -et "Difference_tblTargets" -o "h:\SQL Server\TableDiff\Difference_tblTargets.txt" -f "h:\SQL Server\TableDiff\Update_tblTargets.sql"
rem "C:\Program Files\Microsoft SQL Server\90\COM\tablediff.exe" -sourceserver "SQL-02" -sourcedatabase "ILRAnalyserBC-SQL-01" -sourceschema "dbo" -sourcetable "tblTeachingGrades" -destinationserver "SQL-02" -destinationdatabase "ILRAnalyserNew2" -destinationschema "dbo" -destinationtable "tblTeachingGrades" -dt -et "Difference_tblTeachingGrades" -o "h:\SQL Server\TableDiff\Difference_tblTeachingGrades.txt" -f "h:\SQL Server\TableDiff\Update_tblTeachingGrades.sql"
rem "C:\Program Files\Microsoft SQL Server\90\COM\tablediff.exe" -sourceserver "SQL-02" -sourcedatabase "ILRAnalyserBC-SQL-01" -sourceschema "dbo" -sourcetable "trendtblDeptFunding" -destinationserver "SQL-02" -destinationdatabase "ILRAnalyserNew2" -destinationschema "dbo" -destinationtable "trendtblDeptFunding" -dt -et "Difference_trendtblDeptFunding" -o "h:\SQL Server\TableDiff\Difference_trendtblDeptFunding.txt" -f "h:\SQL Server\TableDiff\Update_trendtblDeptFunding.sql"