use [AdventureWorks2014]

--OVER, PARTITION BY, HAVING

--Ref
-- https://www.postgresql.org/docs/8.4/static/tutorial-window.html
-- https://docs.microsoft.com/en-us/sql/t-sql/queries/select-over-clause-transact-sql
-- https://stackoverflow.com/questions/2404565/sql-server-difference-between-partition-by-and-group-by
-- https://stackoverflow.com/questions/6218902/the-sql-over-clause-when-and-why-is-it-useful
-- https://drill.apache.org/docs/sql-window-functions-introduction/

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





