/*
	1. Find the company whose revenue is increasing every year. If any year the revenue is less than the previous year, then that
		company should not be present in the output list.

			Script:
				create table company_revenue (
					company varchar(100),
					year int,
					revenue int
				)

			insert into company_revenue values 
					('ABC1',2000,100),('ABC1',2001,110),('ABC1',2002,120),('ABC2',2000,100),('ABC2',2001,90),('ABC2',2002,120)
				,('ABC3',2000,500),('ABC3',2001,400),('ABC3',2002,600),('ABC3',2003,800);

*/

WITH cte as (
	SELECT *, 
		lag(revenue,1) over (partition by company order by year) as prev_year_revenue
	FROM company_revenue
)

SELECT company 
FROM cte
WHERE company not in (
	SELECT company
	FROM cte
	WHERE prev_year_revenue > revenue
)
GROUP BY company


/*
	1. An organization is looking to hire employees/candidates for their junior and senior positions. They have a limit of 50000$
		in all, they have to first fill up the senior positions and then fill up the junior positions. There are 3 test cases,
		write a SQL euery to satisfy all the testcases. 

			Script:
				Create table candidates(
					id int primary key,
					positions varchar(10) not null,
					salary int not null
				);

			test case 1:
			insert into candidates values(1,'junior',5000);
			insert into candidates values(2,'junior',7000);
			insert into candidates values(3,'junior',7000);
			insert into candidates values(4,'senior',10000);
			insert into candidates values(5,'senior',30000);
			insert into candidates values(6,'senior',20000);

			test case 2:
			insert into candidates values(20,'junior',10000);
			insert into candidates values(30,'senior',15000);
			insert into candidates values(40,'senior',30000);

			test case 3:
			insert into candidates values(1,'junior',15000);
			insert into candidates values(2,'junior',15000);
			insert into candidates values(3,'junior',20000);
			insert into candidates values(4,'senior',60000);

			test case 4:
			insert into candidates values(10,'junior',10000);
			insert into candidates values(40,'junior',10000);
			insert into candidates values(20,'senior',15000);
			insert into candidates values(30,'senior',30000);
			insert into candidates values(50,'senior',15000);


			delete from candidates;
			SELECT *
			from candidates
*/

with cte as (
	SELECT *,
		sum(salary) over (partition by positions order by salary,id asc) as cummulative_sum
	FROM candidates
), 

seniors_hired as (
	SELECT count(*) as seniors,
			isnull(sum(salary),0) as seniors_salary
	FROM cte
	WHERE positions = 'senior' and cummulative_sum <= 50000
),

juniors_hired as (
	SELECT count(*) as juniors
	FROM cte
	WHERE positions = 'junior' and cummulative_sum <= 50000 - (SELECT seniors_salary FROM seniors_hired)
)

select juniors,
		seniors
from juniors_hired,
		seniors_hired







