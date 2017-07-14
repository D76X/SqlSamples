use [AdventureWorks2014]

--OVER, PARTITION BY, HAVING

--Ref
-- https://www.postgresql.org/docs/8.4/static/tutorial-window.html
-- https://docs.microsoft.com/en-us/sql/t-sql/queries/select-over-clause-transact-sql
-- https://stackoverflow.com/questions/2404565/sql-server-difference-between-partition-by-and-group-by
-- https://drill.apache.org/docs/sql-window-functions-introduction/

--using OVER & PARTITION BY, WINDOW FUNCTIONs
--A. Using the OVER clause with the ROW_NUMBER function

-- select emp_name, dealer_id, sales, avg(sales) over() as avgsales from q1_sales;

-- find the the AVERAGE subtotal and the number of sales order headers per each salesperon
-- this repeats the row as many times as the order numbers per each sales person 
select SalesPersonID, 
avg(SubTotal) over(partition by SalesPersonID) 'AVG subtotal',
count(SalesPersonID) over(partition by SalesPersonID) 'Orders' 
from Sales.SalesOrderHeader 
where SalesPersonID IS NOT NULL

--to reduce the result of teh query above to a single row per salesperson
select SalesPersonID, 'AVGSUB', 'NOrders' from (
	
	select SalesPersonID, 
	avg(SubTotal) over(partition by SalesPersonID) 'AVGSUB',
	count(SalesPersonID) over(partition by SalesPersonID) 'NOrders' 
	from Sales.SalesOrderHeader 
	where SalesPersonID IS NOT NULL) as windowedquery
		
group by SalesPersonID--, 'AVG subtotal', 'Orders'


