/*============================================================================
	File:		06 - CPU analysis.sql

	Summary:	This script gives you an overview of all databases and their
				related resource consumption CPU!

	Date:		August 2025
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
============================================================================*/
USE master;
GO

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
GO

WITH db_cpu_stats
AS
(
	SELECT	f_db.database_id,
			DB_NAME(f_db.database_id)	AS database_name,
			SUM(qs.total_worker_time)	AS cpu_time_ms
	FROM	sys.dm_exec_query_stats AS qs
			CROSS APPLY
			(
				SELECT	CAST(value AS INT) AS database_id
				FROM	sys.dm_exec_plan_attributes(qs.plan_handle)
				WHERE	attribute = N'dbid'
			) AS F_DB
	GROUP BY
			f_db.database_id
)
SELECT	ROW_NUMBER() OVER(ORDER BY dcs.cpu_time_ms DESC)	AS cpu_rank,
		dcs.database_name,
		dcs.cpu_time_ms, 
		CAST
		(
			dcs.cpu_time_ms * 1.0 / SUM([CPU_Time_Ms]) OVER() * 100.0
			AS DECIMAL(5, 2)
		) AS [CPU Percent]
FROM	db_cpu_stats AS dcs
WHERE	dcs.database_id <> 32767
ORDER BY
		cpu_rank
OPTION (RECOMPILE);
GO

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
GO