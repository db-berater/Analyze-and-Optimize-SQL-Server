/*============================================================================
	File:		099 - A90 - Demonstration of CXPACKET.sql

	Summary:	This script monitors / forces the 
				CXPACKET wait stats stat

				THIS SCRIPT IS PART OF THE TRACK: "SQL Server Wait Stats Analysis"

	Date:		April 2019

	SQL Server Version: 2012 / 2014 / 2016 / 2017^/ 2019
------------------------------------------------------------------------------
	Written by Uwe Ricken, db Berater GmbH

	This script is intended only as a supplement to demos and lectures
	given by Uwe Ricken.  
  
	THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
	ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
	TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
	PARTICULAR PURPOSE.
============================================================================*/
SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

USE ERP_Demo;
GO

/*
	We drop all indexes from any table in the demo database
*/
EXEC sp_drop_indexes @table_name = N'ALL';
EXEC sp_drop_statistics @table_name = N'ALL';
GO


/*
	... and make sure that we have the default settings
*/
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
GO

-- reconfigure the threshold for parallelism to default value!
EXEC sys.sp_configure N'cost threshold for parallelism', 5;
RECONFIGURE WITH OVERRIDE;
GO

EXEC sys.sp_configure N'max degree of parallelism', 0;
RECONFIGURE WITH OVERRIDE;
GO

SET STATISTICS IO, TIME ON;
GO

SELECT	c.c_name						AS	customer_name,
		YEAR(o.o_orderdate)				AS	order_year,
		COUNT_BIG(*)					AS	num_orders,
		SUM(o.o_totalprice)				AS	TotalAmount
FROM	ERP_Demo.dbo.customers AS c
		INNER JOIN ERP_Demo.dbo.orders AS o
		ON (c.c_custkey = o.o_custkey)
WHERE	c.c_custkey <= 10
GROUP BY
		c.c_name,
		YEAR(o.o_orderdate)
ORDER BY
		c.c_name,
		YEAR(o.o_orderdate)
OPTION (RECOMPILE, QUERYTRACEON 9130);
GO


-- Resolve parallelism in a professional way like Microsoft is doing it
-- with Sharepoint :)
EXEC sp_configure N'max degree of parallelism', 1;
RECONFIGURE WITH OVERRIDE;
GO

-- needs the data every morning
SELECT	c.c_name						AS	customer_name,
		YEAR(o.o_orderdate)				AS	order_year,
		COUNT_BIG(*)					AS	num_orders,
		SUM(o.o_totalprice)				AS	TotalAmount
FROM	ERP_Demo.dbo.customers AS c
		INNER JOIN ERP_Demo.dbo.orders AS o
		ON (c.c_custkey = o.o_custkey)
WHERE	c.c_custkey <= 10
GROUP BY
		c.c_name,
		YEAR(o.o_orderdate)
ORDER BY
		c.c_name,
		YEAR(o.o_orderdate)
OPTION (RECOMPILE, QUERYTRACEON 9130);
GO

-- or we increase the cost threshold for parallelism way to high
-- the query has an estimated cost value of 19.7632
EXEC sp_configure N'max degree of parallelism', 0;
RECONFIGURE WITH OVERRIDE;
GO

EXEC sp_configure N'cost threshold for parallelism', 400;
RECONFIGURE WITH OVERRIDE;
GO

SET STATISTICS IO, TIME ON;
GO

-- needs the data every morning
SELECT	c.c_name						AS	customer_name,
		YEAR(o.o_orderdate)				AS	order_year,
		COUNT_BIG(*)					AS	num_orders,
		SUM(o.o_totalprice)				AS	TotalAmount
FROM	ERP_Demo.dbo.customers AS c
		INNER JOIN ERP_Demo.dbo.orders AS o
		ON (c.c_custkey = o.o_custkey)
WHERE	c.c_custkey <= 10
GROUP BY
		c.c_name,
		YEAR(o.o_orderdate)
ORDER BY
		c.c_name,
		YEAR(o.o_orderdate)
OPTION (RECOMPILE, QUERYTRACEON 9130);
GO

EXEC sp_configure N'max degree of parallelism', 0;
RECONFIGURE WITH OVERRIDE;
GO

EXEC sp_configure N'cost threshold for parallelism', 5;
RECONFIGURE WITH OVERRIDE;
GO

-- How to resolve CXPACKET waits with indexing...
-- Create an index on dbo.Customers
ALTER TABLE dbo.customers ADD CONSTRAINT pk_customers
PRIMARY KEY CLUSTERED (c_custkey)
WITH (SORT_IN_TEMPDB = ON, DATA_COMPRESSION = PAGE);
GO

CREATE INDEX nix_orders_o_custkey_o_orderdate
ON dbo.orders (o_custkey, o_orderdate)
INCLUDE (o_totalprice)
WITH (SORT_IN_TEMPDB = ON, DATA_COMPRESSION = PAGE);
GO

SET STATISTICS IO ON;
GO

SELECT	c.c_name						AS	customer_name,
		YEAR(o.o_orderdate)				AS	order_year,
		COUNT_BIG(*)					AS	num_orders,
		SUM(o.o_totalprice)				AS	TotalAmount
FROM	ERP_Demo.dbo.customers AS c
		INNER JOIN ERP_Demo.dbo.orders AS o
		ON (c.c_custkey = o.o_custkey)
WHERE	c.c_custkey <= 10
GROUP BY
		c.c_name,
		YEAR(o.o_orderdate)
ORDER BY
		c.c_name,
		YEAR(o.o_orderdate)
OPTION (RECOMPILE, QUERYTRACEON 9130);
GO