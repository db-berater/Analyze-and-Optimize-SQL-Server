/*
	============================================================================
	07 - Table configuration.sql

	Summary:	This script checks all tables for the mandatory configuration settings

	Date:		August 2025
	Session:	Analysis of a Microsoft SQL Server

	SQL Server Version: 2008 / 2012 / 2014 /2016 / 2017 / 2019
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
USE master;
GO

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
GO

USE dbCustomer;
GO

SELECT	SCHEMA_NAME(t.schema_id)    AS  schema_name,
		t.name                      AS  table_name,
		p.partition_numbers,
		p.row_numbers,
		i.num_indexes,
        t.lock_on_bulk_load,
        t.lock_escalation_desc,
		CASE
			WHEN p.partition_numbers > 1 AND t.lock_escalation_desc = N'TABLE' THEN 'use AUTO as lock escalation!'
			WHEN t.lock_escalation_desc = N'NONE' THEN 'WARNING! There is no lock escalation defined!'
			ELSE 'o.k.'
		END							AS	information
FROM	sys.tables AS t
		CROSS APPLY
		(
			SELECT	COUNT_BIG(*)		AS	partition_numbers,
					SUM(p.rows)			AS	row_numbers
			FROM	sys.partitions AS p
			WHERE	p.object_id = t.object_id
					AND p.index_id <= 1
		) AS p
		OUTER APPLY
		(
			SELECT	COUNT_BIG(DISTINCT index_id)	AS	num_indexes
			FROM	sys.indexes AS i
			WHERE	i.object_id = t.object_id
					AND i.index_id > 0
		) AS i
					
WHERE	t.is_ms_shipped = 0;