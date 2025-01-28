/*
	============================================================================
	File:		006 - A02 - MEMORY and CPU - scheduler consumption.sql

	Summary:	scheduler usage for instance

				Sustained values above 10 suggest further investigation in that area
				- High Avg Task Counts are often caused by resource contention
				- High Avg Runnable Task Counts are a sign of CPU pressure
				- High Avg Pending DiskIO Counts are a sign of disk pressure

	Date:		June 2024
	Session:	Analysis of a Microsoft SQL Server

	SQL Server Version: >= 2016
	------------------------------------------------------------------------------
	Written by Uwe Ricken, db Berater GmbH

	This script is intended only as a supplement to demos and lectures
	given by Uwe Ricken.  
  
	THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
	ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
	TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
	PARTICULAR PURPOSE.
	============================================================================
*/
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
GO

SELECT * FROM	sys.dm_os_schedulers
WHERE	status = N'VISIBLE ONLINE' OPTION (RECOMPILE);
GO

SELECT	AVG(current_tasks_count)		AS [average task count], 
		AVG(work_queue_count)			AS [average work queue count],
		AVG(runnable_tasks_count)		AS [average runnable task count],
		AVG(pending_disk_io_count)		AS [average pending diskIO count],
		GETDATE() AS [System Time]
FROM	sys.dm_os_schedulers
WHERE	status = N'VISIBLE ONLINE' OPTION (RECOMPILE);
