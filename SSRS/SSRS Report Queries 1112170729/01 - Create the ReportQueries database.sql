-- =============================================================================
-- 01 - Create the ReportQueries Database
-- =============================================================================
-- Many of the scripts in this project create objects (Views, Stored Procedures,
-- and Functions) that need to be stored in a database.  You could place those
-- objects directly in your application database, but because I don't know what
-- that database is, I will create my own database to store these objects.
--
-- The other scripts in this project assume the ReportQueries database exists,
-- and all objects will be created / referenced there.  If you prefer NOT to 
-- use the ReportQueries database, you will need to modify the scripts in the
-- project to reference your desired database.
--
-- To run this script on your server you will need Create Database permissions 
-- on the server.
--
-- -----------------------------------------------------------------------------
-- History (most recent at top)
-- -----------------------------------------------------------------------------
-- 11/30/2011 - BStateham - Original Script
-- =============================================================================
USE master;
GO
IF DB_ID('ReportQueries') IS NOT NULL
  BEGIN
    PRINT 'The ReportQueries database already exists. No changes were made.';
    RETURN;
  END
ELSE
  BEGIN
    PRINT 'Creating the ReportQueires Database...';
    CREATE DATABASE ReportQueries;
  END
