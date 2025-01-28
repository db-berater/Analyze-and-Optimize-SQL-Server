/*
	============================================================================
	File:		006 - A03 - MEMORY and CPU - CPU consumption.sql

	Summary:	shows the cpu consumption over the last 256 minutes
				Courtesy of Glenn Berry
				https://glennsqlperformance.com/resources/

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

DECLARE @ts_now bigint = (SELECT ms_ticks FROM sys.dm_os_sys_info); 

SELECT	TOP(256)
		SQLProcessUtilization									AS [SQL Server Process CPU Utilization], 
        SystemIdle												AS [System Idle Process], 
        100 - SystemIdle - SQLProcessUtilization				AS [Other Process CPU Utilization], 
		DATEADD(ms, -1 * (@ts_now - [timestamp]), GETDATE())	AS [Event Time] 
FROM	(
			SELECT	record.value('(./Record/@id)[1]', 'int')													AS record_id, 
					record.value('(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int')			AS [SystemIdle], 
					record.value('(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 'int')	AS [SQLProcessUtilization], [timestamp] 
			FROM	(
						SELECT	[timestamp],
								CONVERT(xml, record) AS [record]
						FROM	sys.dm_os_ring_buffers
						WHERE	ring_buffer_type = N'RING_BUFFER_SCHEDULER_MONITOR' 
								AND record LIKE N'%<SystemHealth>%'
					) AS rb
		) AS y 
ORDER BY
		record_id DESC;
GO