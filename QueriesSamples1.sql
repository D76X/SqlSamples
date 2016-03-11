--AdventureWorks Queries 

--References
--https://msdn.microsoft.com/en-us/library/cc546519.aspx
--https://www.simple-talk.com/sql/t-sql-programming/sql-server-cte-basics/

use AdventureWorks2014
go

--level 2
--simple group by
--find all the values that employees can have for their marital staus 
select  MaritalStatus from AdventureWorks2014.HumanResources.Employee group by MaritalStatus

--level 1
--simple join between two related tables with where clause and order by
--find title, name, surname, birthdate, gender, job title of all the married employees
--order by birthdate ascending
select  p.Title, p.FirstName, p.LastName, e.BirthDate, e.JobTitle, e.MaritalStatus 
from  AdventureWorks2014.HumanResources.Employee as e
join AdventureWorks2014.Person.Person as p
on p.BusinessEntityID = e.BusinessEntityID
where e.MaritalStatus like('M')
order by e.BirthDate asc

--level 1
--simple INNER join between two table with no where clause
--INNER is implicit!
--find all the person data for all employees
--notice the Person.Person table might hold more records than the 
select COUNT(*) AS 'Number of Persons' from AdventureWorks2014.Person.Person
select COUNT(*) AS 'Number of Employees' from AdventureWorks2014.HumanResources.Employee
select p.FirstName, p.LastName, e.JobTitle 
from  AdventureWorks2014.HumanResources.Employee as e
join AdventureWorks2014.Person.Person as p
on p.BusinessEntityID = e.BusinessEntityID

--level 2
--multiple joins
--for every employee find the address or addresses
--notice that every employee might have 0, 1 or more addresses!
--use a left join to make sure that ALL employees are listed
select p.FirstName, p.LastName, e.JobTitle, a.AddressLine1, a.AddressLine2, a.City, a.PostalCode
from  AdventureWorks2014.HumanResources.Employee as e
join AdventureWorks2014.Person.Person as p
on p.BusinessEntityID = e.BusinessEntityID
left join AdventureWorks2014.Person.BusinessEntityAddress bea
on bea.BusinessEntityID = p.BusinessEntityID
left join AdventureWorks2014.Person.[Address] a
on a.AddressID = bea.AddressID

--level 2
--simple group by
--find all the possible job titkes for employees
select JobTitle from AdventureWorks2014.HumanResources.Employee group by JobTitle
 

--level 3 (CTE and in-memory table)
--for each job title find the employee with the max annual pay



--simple join level 2
--find title, name, surname, gender, job title of all the unmarried employees over the age of thirty