use [AdventureWorks2014]

----=======================================================================================================================
-- https://www.essentialsql.com/recursive-ctes-explained/
--a simple recursive CTE that counts to 50
WITH   cte
AS     (SELECT 1 AS n -- anchor member
        UNION ALL
        SELECT n + 1 -- recursive member
        FROM   cte
        WHERE  n < 50 -- terminator
       )
SELECT n
FROM   cte;

--=======================================================================================================================

-------------------------------------------------------------------------------------------------------------------------
-- An incorrectly composed recursive CTE may cause an infinite loop!
-- When testing the results of a recursive query, you can limit the number of recursion levels allowed for a specific 
-- statement by using the MAXRECURSION hint and a value between 0 and 32,767 in the OPTION clause of the INSERT, UPDATE, 
-- DELETE, or SELECT statement.
-------------------------------------------------------------------------------------------------------------------------

--RECURSIVE CTE

-- Refs
-- https://technet.microsoft.com/en-us/library/ms186243(v=sql.105).aspx
-- https://technet.microsoft.com/en-us/library/ms190766(v=sql.105).aspx
-- https://www.codeproject.com/Articles/683011/How-to-use-recursive-CTE-calls-in-T-SQL
-- https://www.red-gate.com/simple-talk/sql/t-sql-programming/sql-server-cte-basics/
-- https://blog.sqlauthority.com/2008/07/28/sql-server-simple-example-of-recursive-cte/

-- http://odetocode.com/Articles/365.aspx
declare @Temp table(
 UserId int,
 UserName nvarchar(255),
 ManagerId int
)

insert into @Temp (UserId, UserName, ManagerId) values (1,'John',NULL)
insert into @Temp (UserId, UserName, ManagerId) values (2,'Charles',1)
insert into @Temp (UserId, UserName, ManagerId) values (3,'Nicolas',2)
insert into @Temp (UserId, UserName, ManagerId) values (4,'Neil',5)
insert into @Temp (UserId, UserName, ManagerId) values (5,'Lynn',1)
insert into @Temp (UserId, UserName, ManagerId) values (6,'Vince',5)
insert into @Temp (UserId, UserName, ManagerId) values (7,'Claire',6)

--select * from @Temp

--The simplest recursive CTE possible find the tree of all managers starting from one employee
;with UserCte1 (UserId, UserName, ManagerId, Step) as ( 
 --anchor: the first invocation to the DB which returns the set T0
 select UserId, UserName, ManagerId, 0 as Step from @Temp where UserId = 7
 UNION ALL
 --recursion: it references the same CTE definition it uses Ti as an input and produces T(i+1) as an output set
 --recursion is repeated until Tn = EMPTY SET
 select temp.UserId, temp.UserName, temp.ManagerId, usrt.Step + 1 as Step 
 from UserCte1 as usrt 
 inner join @Temp as temp 
 on usrt.ManagerId = temp.UserId
)
--Statement that executes the Cte
select * from UserCte1

----------------------------------------------------------------------------------------------------------

;with UserCte2 (TrackId, UserId, UserName, ManagerId, Step) as ( 

 select UserId as TrackId, UserId, UserName, ManagerId, 0 as Step from @Temp 
 --where UserId = 7 => we are going to walk the hierachy for all users
 --for each user in @Temp do what you didi before when the where UserId = 7 was specified
 
 UNION ALL
 
 select usrt.UserId as TrackId, temp.UserId, temp.UserName, temp.ManagerId, usrt.Step + 1 as Step 
 from UserCte2 as usrt 
 inner join @Temp as temp 
 on usrt.ManagerId = temp.UserId
)
select * from UserCte2 cte2
order by cte2.TrackId, cte2.Step

--==================================================================================================

use [AdventureWorks2014]

--SCENARIO 2
--parent product has one or more components and those components may, in turn, have subcomponents or 
--may be components of other parents.

-- https://www.essentialsql.com/recursive-ctes-explained/
--The BillOfMaterials table contains pairs of ProductID numbers
--Production.BillOfMaterials holds 
--FK ProductsAssemblyID to Production.Product.ProductID => The sub assembly containing the part (parent)
--FK ComponentID to Production.Product.ProductID =>  Part in the sub assembly (child)

--we want a list of a product's sub-assemblies and its constituent parts
--The products in BillOfMaterial with ID=NULL are teh top level parts
select * from Production.BillOfMaterials where ProductAssemblyID IS NULL

--better
select p.ProductID, p.Name, p.Color 
from Production.Product as p
inner join
Production.BillOfMaterials





--==================================================================================================

