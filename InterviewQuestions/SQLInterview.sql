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

		/*
		create table people
		(id int primary key not null,
		 name varchar(20),
		 gender char(2));

		 create table relations
		(
			c_id int,
			p_id int,
			FOREIGN KEY (c_id) REFERENCES people(id),
			foreign key (p_id) references people(id)
		);

		insert into people (id, name, gender)
		values
			(107,'Days','F'),
			(145,'Hawbaker','M'),
			(155,'Hansel','F'),
			(202,'Blackston','M'),
			(227,'Criss','F'),
			(278,'Keffer','M'),
			(305,'Canty','M'),
			(329,'Mozingo','M'),
			(425,'Nolf','M'),
			(534,'Waugh','M'),
			(586,'Tong','M'),
			(618,'Dimartino','M'),
			(747,'Beane','M'),
			(878,'Chatmon','F'),
			(904,'Hansard','F');

			insert into relations(c_id, p_id)
		values
			(145, 202),
			(145, 107),
			(278,305),
			(278,155),
			(329, 425),
			(329,227),
			(534,586),
			(534,878),
			(618,747),
			(618,904);

			select *
			from people;

			select *
			from relations;

			Question: Write a query that prints the names of a child and his parents in individual columns respectively in order of the
			child.
*/

with cte as (
	SELECT c_id,
			name,
			gender
	FROM relations r
	INNER JOIN people p 
		on r.p_id = p.id
),

id_with_father_mother as (
	SELECT c_id,
		  max(case when gender = 'F' then name end) as 'Mother',
		  max(case when gender = 'M' then name end) as 'Father'
	FROM cte
	GROUP BY c_id
)

SELECT p.name as Child,
		Father,
		Mother
FROM id_with_father_mother a
INNER JOIN people p
	on a.c_id = p.id


/*
	employee_checkin_details:
		  employeeid ,entry_details, timestamp_details 
		  1000 , login , 2023-06-16 01:00:15.34
		  1000 , login , 2023-06-16 02:00:15.34
		  1000 , login , 2023-06-16 03:00:15.34
		  1000 , logout , 2023-06-16 12:00:15.34
		  1001 , login , 2023-06-16 01:00:15.34
		  1001 , login , 2023-06-16 02:00:15.34
		  1001 , login , 2023-06-16 03:00:15.34
		  1001 , logout , 2023-06-16 12:00:15.34

	employee_details:
		employeeid , phone_number , isdefault
		1001 ,9999 , false
		1001 ,1111 , false
		1001 ,2222 , true
		1003 ,3333 , false


		Write an sql code to find output table as below:
			employeeid, emplooyee_default_phone_number, total_entry, total_logout, latest_login, latest_logout


		SCRIPT: 

				CREATE TABLE employee_checkin_details(
			employeeid        INTEGER  NOT NULL  
			,entry_details     VARCHAR(8) NOT NULL
			,timestamp_details Datetime NOT NULL
			);
			INSERT INTO employee_checkin_details(employeeid,entry_details,timestamp_details) VALUES (1000,'login','2023-06-16 01:00:15.34');
			INSERT INTO employee_checkin_details(employeeid,entry_details,timestamp_details) VALUES (1000,'login','2023-06-16 02:00:15.34');
			INSERT INTO employee_checkin_details(employeeid,entry_details,timestamp_details) VALUES (1000,'login','2023-06-16 03:00:15.34');
			INSERT INTO employee_checkin_details(employeeid,entry_details,timestamp_details) VALUES (1000,'logout','2023-06-16 12:00:15.34');
			INSERT INTO employee_checkin_details(employeeid,entry_details,timestamp_details) VALUES (1001,'login','2023-06-16 01:00:15.34');
			INSERT INTO employee_checkin_details(employeeid,entry_details,timestamp_details) VALUES (1001,'login','2023-06-16 02:00:15.34');
			INSERT INTO employee_checkin_details(employeeid,entry_details,timestamp_details) VALUES (1001,'login','2023-06-16 03:00:15.34');
			INSERT INTO employee_checkin_details(employeeid,entry_details,timestamp_details) VALUES (1001,'logout','2023-06-16 12:00:15.34');

			CREATE TABLE employee_details(
			employeeid   INTEGER  NOT NULL
			,phone_number INTEGER 
			,isdefault    VARCHAR(6) 
			);

			INSERT INTO employee_details(employeeid,phone_number,isdefault) VALUES (1001,9999,'false');
			INSERT INTO employee_details(employeeid,phone_number,isdefault) VALUES (1001,1111,'false');
			INSERT INTO employee_details(employeeid,phone_number,isdefault) VALUES (1001,2222,'true');
			INSERT INTO employee_details(employeeid,phone_number,isdefault) VALUES (1003,3333,'false');

			SELECT *
			FROM employee_checkin_details;

			SELECT *
			FROM employee_details;

*/

with cte as (
	SELECT employeeid, count(*) as total_entry,
			sum(case when entry_details = 'login' then 1 end) as total_login,
			sum(case when entry_details = 'logout' then 1 end) as total_logout,
			max(case when entry_details = 'login' then timestamp_details end) as latest_login,
			max(case when entry_details = 'logout' then timestamp_details end) as latest_logout
	FROM employee_checkin_details
	GROUP BY employeeid
)

SELECT a.employeeid, phone_number as default_phone_number,
		total_entry,
		total_login,
		total_logout,
		latest_login,
		latest_logout
FROM cte a
LEFT JOIN employee_details b on a.employeeid  = b.employeeid
WHERE isdefault = 'true'



