/*============================================================================
	File:		002 - A02 - Database analysis - Database size and consumption.sql

	Summary:	Ths script returns properties of all databases in the current
				instance of Microsoft SQL Server for performance perspectives!

	Date:		May 2015

	SQL Server Version: 2008 / 2012
------------------------------------------------------------------------------
	Written by Uwe Ricken, db Berater GmbH

	This script is intended only as a supplement to demos and lectures
	given by Uwe Ricken.  
  
	THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
	ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
	TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
	PARTICULAR PURPOSE.
============================================================================*/
USE master;
GO

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
GO

-- define a table variable to store information about all databases
DECLARE	@result TABLE
(
	database_id			SMALLINT		NOT NULL,
	database_name		sysname			NOT NULL,
	file_id				SMALLINT		NOT NULL,
	logical_name		sysname			NOT NULL,
	type_desc			VARCHAR(10)		NOT NULL,
	physical_name		VARCHAR(255)	NOT NULL,
	size_MB				DECIMAL(18)		NULL		DEFAULT (0),
	growth_MB			DECIMAL(18)		NULL		DEFAULT (0),
	used_MB				DECIMAL(18)		NULL		DEFAULT (0),
	max_size			DECIMAL(18)		NULL		DEFAULT (0),
	is_percent_growth	TINYINT			NULL		DEFAULT (0),
	
	PRIMARY KEY CLUSTERED
	(
		database_name,
		logical_name
	),
	
	UNIQUE (physical_name)	
);

INSERT INTO @Result
EXEC	sys.sp_MSforeachdb @command1 = N'USE [?];
SELECT	d.database_id,
		DB_NAME(d.database_id)							AS [Database Name],
		mf.file_id,
		mf.name,
		mf.type_desc,
		mf.physical_name,
		mf.size / 128.0									AS	[size_MB],
		CASE WHEN mf.[is_percent_growth] = 1
			THEN mf.[size] * (mf.[growth] / 100.0)
			ELSE mf.[growth]
		END	/ 128.0										AS	[growth_MB],
		FILEPROPERTY(mf.name, ''spaceused'') / 128.0	AS	[used_MB],
		CASE WHEN mf.max_size = -1
			 THEN 0
			 ELSE mf.max_size / 128.0
		END												AS	[max_size],
		mf.[is_percent_growth]
FROM	sys.databases AS d INNER JOIN sys.master_files AS mf
		ON	(d.database_id = mf.database_id)
WHERE	d.database_id = DB_ID();';

SELECT	r.database_id,
        r.database_name,
        r.file_id,
        r.logical_name,
        r.type_desc,
        r.physical_name,
        r.size_MB,
        r.growth_MB,
        r.used_MB,
		r.used_MB / r.size_MB	AS	filled_percentage,
        r.max_size,
        r.is_percent_growth
FROM	@result AS r
ORDER BY
		r.database_name,
		r.type_desc DESC,
		r.file_id;

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
GO