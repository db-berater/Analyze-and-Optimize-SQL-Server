/*
	============================================================================
	File:		006 - A01 - MEMORY and CPU - top memory clerks.sql

	Summary:	Memory Clerk Usage for instance

				MEMORYCLERK_SQLBUFFERPOOL	Bufferpool (Data)
				CACHESTORE_SQLCP			Ad hoc query plans

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

SELECT	TOP (10)
		mc.[type] AS [Memory Clerk Type],
		CAST((SUM(mc.pages_kb) / 1024.0) AS DECIMAL(15, 2)) AS [Memory Usage (MB)]
FROM	sys.dm_os_memory_clerks AS mc
GROUP BY
		mc.[type]
ORDER BY
		SUM(mc.pages_kb) DESC
OPTION (RECOMPILE);