/*============================================================================
	File:		01 - Blocked Process Report.sql

	Summary:	This script creates a XE Session which monitors the
				blocking report for locks which are hold longer than 10
				seconds!
								
				THIS SCRIPT IS PART OF THE TRACK: "SQL Server - Helpful XEvents"

	Date:		Januar 2025

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

IF EXISTS (SELECT * FROM sys.server_event_sessions WHERE name = N'db Blocking Report')
	DROP EVENT SESSION [db Blocking Report] ON SERVER;
	GO

-- Blocking Threshold in Seconds!
DECLARE	@block_threshold	INT				= 10
DECLARE	@db_name			NVARCHAR(64)	= N'ERP_Demo';

DECLARE @filepath			NVARCHAR(256)	= N'T:\TraceFiles\';
DECLARE	@stmt				NVARCHAR(4000)	= N'
CREATE EVENT SESSION [db Blocking Report]
ON SERVER
ADD EVENT sqlserver.blocked_process_report
(
	ACTION
	(
		sqlserver.client_hostname,
		sqlserver.session_id
	)
	WHERE [database_name] = ' + + QUOTENAME(@db_name, '''') + '
)
ADD TARGET package0.event_file
(
	SET FILENAME = N'''+ @filepath + N'db Blocking Report.xel'',
		METADATAFILE=N''' + @filepath + N'db Blocking Report.xem'',
		MAX_FILE_SIZE = 5120
)
WITH
(
	MAX_MEMORY = 4096 KB,
	EVENT_RETENTION_MODE= ALLOW_SINGLE_EVENT_LOSS,
	MAX_DISPATCH_LATENCY = 30 SECONDS,
	MAX_EVENT_SIZE = 0 KB,
	MEMORY_PARTITION_MODE = NONE,
	TRACK_CAUSALITY = OFF,
	STARTUP_STATE = OFF
);'

EXEC sp_executesql @stmt;

-- Activate the event session
ALTER EVENT SESSION [db Blocking Report] ON SERVER STATE = START;

-- Configure the blocked report threshold for the session
DECLARE	@show_advanced	INT = 0;

SELECT	@show_advanced = CAST(value_in_use AS INT)
FROM	sys.configurations
WHERE	name LIKE N'blocked process threshold (s)';

IF @show_advanced = 0
BEGIN
	EXEC sp_configure N'show advanced options', 1;
	RECONFIGURE WITH OVERRIDE;
END

EXEC sp_configure 'blocked process threshold (s)', @block_threshold;
RECONFIGURE WITH OVERRIDE;

EXEC sp_configure N'blocked process threshold';

EXEC sp_configure N'show advanced options', @show_advanced;
RECONFIGURE WITH OVERRIDE;
GO