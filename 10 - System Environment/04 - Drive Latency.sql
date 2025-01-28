/*============================================================================
	File:		001 - A03 - Sytem Environment - Drive Latency.sql

	Summary:	Ths script returns the privileges of the system account
				which will be used by the SQL Server Database Engine

	Date:		May 2024
	Session:	Analysis of a Microsoft SQL Server

	SQL Server Version: >= 2016

------------------------------------------------------------------------------
	Written by Uwe Ricken, db Berater GmbH
	-- Based on code from Jimmy May!!!

	This script is intended only as a supplement to demos and lectures
	given by Uwe Ricken.  
  
	THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
	ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
	TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
	PARTICULAR PURPOSE.
============================================================================*/
USE master;
GO

WITH database_storage
AS
(
	SELECT	LEFT(MF.physical_name, 2)	AS Drive,
			SUM(num_of_reads)			AS num_of_reads,
			SUM(io_stall_read_ms)		AS io_stall_read_ms,
			SUM(num_of_writes)			AS num_of_writes,
			SUM(io_stall_write_ms)		AS io_stall_write_ms,
			SUM(num_of_bytes_read)		AS num_of_bytes_read,
			SUM(num_of_bytes_written)	AS num_of_bytes_written,
			SUM(io_stall)				AS io_stall
	FROM	sys.master_files AS MF
			CROSS APPLY sys.dm_io_virtual_file_stats(MF.database_id, MF.file_id) AS vfs
	GROUP BY
			LEFT(MF.physical_name, 2)
)
SELECT	[Drive],
		CASE WHEN num_of_reads = 0
			THEN 0 
			ELSE io_stall_read_ms / num_of_reads 
		END AS [Read Latency],
		CASE 
			WHEN io_stall_write_ms = 0 THEN 0 
			ELSE (io_stall_write_ms/num_of_writes) 
		END AS [Write Latency],
		CASE 
			WHEN (num_of_reads = 0 AND num_of_writes = 0) THEN 0 
			ELSE (io_stall/(num_of_reads + num_of_writes)) 
		END AS [Overall Latency],
		CASE 
			WHEN num_of_reads = 0 THEN 0 
			ELSE (num_of_bytes_read/num_of_reads) 
		END AS [Avg Bytes/Read],
		CASE 
			WHEN io_stall_write_ms = 0 THEN 0 
			ELSE (num_of_bytes_written/num_of_writes) 
		END AS [Avg Bytes/Write],
		CASE 
			WHEN (num_of_reads = 0 AND num_of_writes = 0) THEN 0 
			ELSE ((num_of_bytes_read + num_of_bytes_written)/(num_of_reads + num_of_writes)) 
		END AS [Avg Bytes/Transfer]
FROM	database_storage
ORDER BY
		[Drive];
GO