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
