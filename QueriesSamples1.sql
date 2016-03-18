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
--find all the possible job titles for employees
select JobTitle from AdventureWorks2014.HumanResources.Employee group by JobTitle;

--level1
--convert the group by query above into a CTE
--notice the ; on the end of the preceeding query!
--a ; must preceed the WITH keyword
--this is a quirk of SSMS syntax highlighting
with 
	Job_Titles(Job_title)
	as
	(
	select JobTitle 
	from AdventureWorks2014.HumanResources.Employee 
	group by JobTitle
	)
select Job_title
from Job_Titles;

--level 3 (use a CTE)
--for each job title find the MAX number of Vacation Hours
with 
	Job_Titles(Job_title)
	as
	(
	select JobTitle 
	from AdventureWorks2014.HumanResources.Employee 
	group by JobTitle
	)
select e.JobTitle, MAX(e.VacationHours)
from AdventureWorks2014.HumanResources.Employee as e
join Job_Titles on e.JobTitle like Job_title 
group by e.JobTitle;

--level 3 (use a CTE)
--for each job title find the employee with the max annual pay
--1)find the annual pay of all employees and place it in a CTE
--2)join to the table that gives all the grouped job roles
--3)pick the employee that foe each job role has the max pay

--PART1 find the annual pay of all employees
-------------------------------------------------------------------
--This table holds the ID of the employee the rate and the frequency
--we are goimg to assume the frequency is in hours
select * from AdventureWorks2014.HumanResources.EmployeePayHistory

--we are going to assume a flat base base of 40h/week for 52 weeks/year = 2080h/year
select 
p.FirstName + ' ' + p.LastName as 'Full Name',
e.JobTitle,
h.Rate*2080/h.PayFrequency 'Flat Annual Pay'
from AdventureWorks2014.HumanResources.Employee e
join AdventureWorks2014.HumanResources.EmployeePayHistory h 
on e.BusinessEntityID = h.BusinessEntityID
join AdventureWorks2014.Person.Person as p
on p.BusinessEntityID = e.BusinessEntityID 
order by [Flat Annual Pay] desc;

--now piece the two together using the CTE syntax
--notice the ; terminating the preceeding line to keep the SSMS editor happy
--notice that in the first CTE the order by has been left out as it is no longer necessary
--notica that two CTEs are also chained otgether separated bu a comma 
with 
 MaxAnnualSalary(ID,FullName, JobTitle, FlatAnnualPay)
 as
 (
 	select 
	p.BusinessEntityID,
	p.FirstName + ' ' + p.LastName as 'Full Name',
	e.JobTitle,
	h.Rate*2080/h.PayFrequency 'Flat Annual Pay'
	from AdventureWorks2014.HumanResources.Employee e
	join AdventureWorks2014.HumanResources.EmployeePayHistory h 
	on e.BusinessEntityID = h.BusinessEntityID
	join AdventureWorks2014.Person.Person as p
	on p.BusinessEntityID = e.BusinessEntityID 
 ),  
 Job_Titles(Job_title)
 as
 (
	select JobTitle 
	from AdventureWorks2014.HumanResources.Employee 
	group by JobTitle
  )
select mas.ID, mas.FullName, mas.JobTitle , MAX(mas.FlatAnnualPay) as MaxAnnualPay
from MaxAnnualSalary mas
join Job_Titles jbts
on jbts.Job_title = mas.JobTitle
group by mas.ID, mas.FullName, mas.JobTitle, 




--simple join level 2
--find title, name, surname, gender, job title of all the unmarried employees over the age of thirty

--use an in-memory table instead of a CTE