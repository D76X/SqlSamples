use [AdventureWorks2014]

--------------------------------------------------------------------------------------------------------
-- https://www.red-gate.com/simple-talk/sql/t-sql-programming/sql-server-2012-window-function-basics/
--SQL Server 2012 now includes three types of window functions: ranking, aggregate, and analytic. 
--1 Ranking functions return a ranking value for each row in a partition
--2 Aggregate functions perform a calculation on a column’s values within a partition
-- https://docs.microsoft.com/en-us/sql/t-sql/functions/analytic-functions-transact-sql
--3 Analytic function computes an aggregate value based on the values in a column within a partition
--  beyond simple aggregate i.e. moving average, running totals, percentages, etc.
--  unlike aggregate functions, they can return multiple rows for each group

--4 specila analytic function : NEXT VALUE FOR https://docs.microsoft.com/en-us/sql/t-sql/functions/next-value-for-transact-sql
--------------------------------------------------------------------------------------------------------

-- SYNTAX

--<window function> OVER
--  (
--    [ PARTITION BY <expression> [, ... n] ]
--    [ ORDER BY <expression> [ASC|DESC] [, ... n] ]
--    [ ROWS|RANGE <window frame> ]
--  )

--------------------------------------------------------------------------------------------------------

--OVER, PARTITION BY, HAVING

--Ref
-- https://www.postgresql.org/docs/8.4/static/tutorial-window.html
-- https://docs.microsoft.com/en-us/sql/t-sql/queries/select-over-clause-transact-sql
-- https://stackoverflow.com/questions/2404565/sql-server-difference-between-partition-by-and-group-by
-- https://stackoverflow.com/questions/6218902/the-sql-over-clause-when-and-why-is-it-useful
-- https://drill.apache.org/docs/sql-window-functions-introduction/
-- https://www.red-gate.com/simple-talk/sql/t-sql-programming/sql-server-2012-window-function-basics/

--using OVER & PARTITION BY, WINDOW FUNCTIONs
--A. Using the OVER clause with the ROW_NUMBER function

-- select emp_name, dealer_id, sales, avg(sales) over() as avgsales from q1_sales;

-- find the the AVERAGE subtotal and the number of sales order headers per each salesperon
select distinct SalesPersonID, 
cast(avg(SubTotal) over(partition by SalesPersonID) as decimal(10,2)) 'AVG subtotal',
count(SalesPersonID) over(partition by SalesPersonID) 'Orders' 
from Sales.SalesOrderHeader 
where SalesPersonID IS NOT NULL 
order by SalesPersonID asc

--the query above can be translate into another one which does not use windowing via OVER PARTITION BY
-- https://stackoverflow.com/questions/6218902/the-sql-over-clause-when-and-why-is-it-useful
-- using an inner join between two selections

--use a group by to create the partitions and the aggregate values
--notice that the aggregate values are not in the goup by list
-------------------------------------------------------------------------------------------------------
--select SalesPersonID, cast(sum(SubTotal) as decimal(10,2)) 'Total', count(*) 'Orders'
--from Sales.SalesOrderHeader 
--where SalesPersonID IS NOT NULL 
--group by SalesPersonID
-------------------------------------------------------------------------------------------------------

--the query above can now be used with an inner join to the same table to replicate the effect of the window
select distinct agg.SalesPersonID, cast(agg.Total/agg.Orders as decimal(10,2)) 'AVG subtotal', agg.Orders 'Orders'
from Sales.SalesOrderHeader soh 
inner join (
	-------------------------------------------------------------------------------------------------------
	select SalesPersonID, cast(sum(SubTotal) as decimal(10,2)) 'Total', count(*) 'Orders'
	from Sales.SalesOrderHeader 
	where SalesPersonID IS NOT NULL 
	group by SalesPersonID
	-------------------------------------------------------------------------------------------------------
	) agg
	on agg.SalesPersonID = soh.SalesPersonID
order by SalesPersonID asc
 

--================================================================================================================

-- https://stackoverflow.com/questions/7747327/sql-rank-versus-row-number
--Ranking and Row_Number with partitions
--Notive that in this example we also use the ORBER BY clause in the OVER PARTITION BY to detemine the ranking weight

--For each territory and shipping method count the orders   
select distinct TerritoryID, ShipMethodID, 
count(*) over (partition by TerritoryID, ShipMethodID order by ShipMethodID) 'Orders'
from Sales.SalesOrderHeader
order by TerritoryID, ShipMethodID

--rank the results using either RANK() or ROW_NUMEBR() per aach TerritotyID-ShippingMethodID combination
select q.TerritoryID, q.ShipMethodID, q.Orders, 
    ROW_NUMBER() over (partition by q.TerritoryID order by q.ShipMethodID) 'RANK'
	from (
	select distinct TerritoryID, ShipMethodID, 
	count(*) over (partition by TerritoryID, ShipMethodID order by ShipMethodID) 'Orders'
	from Sales.SalesOrderHeader	
	) as q
order by TerritoryID, ShipMethodID

--================================================================================================================


