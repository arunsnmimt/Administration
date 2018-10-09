-- Clearing Cache for SQL Server Performance Testing

/*
When conducting performance testing and tuning on a new system, most of the time a number of options are outlined to potentially correct the performance problem.  To determine the best overall solution, each option is tested and the results are recorded.  As lessons are learned options may be combine for a better end result and often as data is cached the overall query performance improves.  Unfortunately, with the data in cache testing each subsequent option may lend itself to an apples to oranges comparison.  How can I ensure during each execution of a new set of code that the data is not cached?

NOT recomemmended for production systems just for the sake of testing.  These commands could have detrimental results to your environment.

*/


USE <YOURDATABASENAME>;
GO
/*
Writes all dirty pages for the current database to disk. Dirty pages are data pages that have been entered into the buffer cache and modified, but not yet written to disk. Checkpoints save time during a later recovery by creating a point at which all dirty pages are guaranteed to have been written to disk.
*/
CHECKPOINT;
GO

/*
Removes all clean buffers from the buffer pool.
*/
DBCC DROPCLEANBUFFERS;
GO