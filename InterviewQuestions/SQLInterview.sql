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



/*
	UBER - SQL Interview Question (https://www.youtube.com/watch?v=QSwHIi11434&ab_channel=E-LearningBridge)
	Script: 
			create table marks_data(student_id int, subject varchar(50), marks int);
			insert into marks_data values(1001, 'English', 88);
			insert into marks_data values(1001, 'Science', 90);
			insert into marks_data values(1001, 'Maths', 85);
			insert into marks_data values(1002, 'English', 70);
			insert into marks_data values(1002, 'Science', 80);
			insert into marks_data values(1002, 'Maths', 83);

			Output: 
					student_id English Science	Maths
						1001	88		90		85
						1002	70		80		83
*/

SELECT student_id, 
			max(case when subject = 'English' then marks end) as 'English',
			max(case when subject = 'Science' then marks end) as 'Science',
			max(case when subject = 'Maths' then marks end) as 'Maths'
from marks_data
GROUP BY student_id


/*
	GOOGLE - SQL Interview Question (https://www.youtube.com/watch?v=HZtUxYdnbhw&ab_channel=E-LearningBridge)
	Script: 
			create table user_activity(date date,user_id int,activity varchar(50));

			insert into user_activity values('2022-02-20',1,'abc');
			insert into user_activity values('2022-02-20',2,'xyz');
			insert into user_activity values('2022-02-22',1,'xyz');
			insert into user_activity values('2022-02-22',3,'klm');
			insert into user_activity values('2022-02-24',1,'abc');
			insert into user_activity values('2022-02-24',2,'abc');
			insert into user_activity values('2022-02-24',3,'abc');

			Output: 
					date		unique_user_count
					2022-02-20		2
					2022-02-22		1
					2022-02-24		0
*/

WITH cte AS (
	SELECT *,
		rank() over (partition by activity order by date asc) as rnk
	FROM user_activity
),

unique_user_count as (
	SELECT date,
			count(*) as unique_user_count
	FROM cte
	where rnk = 1
	GROUP BY date
), 

distinct_table as (
	SELECT DISTINCT date
	FROM cte
)

SELECT a.date,
		coalesce(unique_user_count,0) as unique_user_count
FROM distinct_table a
LEFT JOIN unique_user_count b
	ON a.date = b.date  


/*
	SQL Question in AMAZON (https://www.youtube.com/watch?v=LJuGi0VRCA0&list=PLYUFWNUuw0fm89ZIcYHhNRTsB7RJzM1tX&index=1&ab_channel=E-LearningBridge)
	Script: 
			create table number_pairs(A int, B int);
			insert into number_pairs values(1,2);
			insert into number_pairs values(3,2);
			insert into number_pairs values(2,4);
			insert into number_pairs values(2,1);
			insert into number_pairs values(5,6);
			insert into number_pairs values(4,2);

			Problem Statement: Remove all reverse number pairs from given table, keep pnly one (random) if exists
			Output: 
					A		B
					1		2
					3		2
					2		4
					5		6
*/


-- Approach -1 
SELECT a.*
FROM number_pairs a 
LEFT JOIN number_pairs b 
		on a.B = b.A and a.A = b.B
WHERE b.a is NULL or a.A < a.B



/*
	SQL Question in AMAZON Interview - https://www.youtube.com/watch?v=odTg-nGIfwE&list=PLYUFWNUuw0fm89ZIcYHhNRTsB7RJzM1tX&index=3&ab_channel=E-LearningBridge

	Script: 
		create table SALE (merchant varchar(10), amount int, pay_mode varchar(10));

		insert into SALE values('merchant_1',150,'cash');
		insert into SALE values('merchant_1',500,'online');
		insert into SALE values('merchant_2',450,'online');
		insert into SALE values('merchant_1',100,'cash');
		insert into SALE values('merchant_3',600,'cash');
		insert into SALE values('merchant_5',200,'online');
		insert into SALE values('merchant_2',100,'online');

		merchant	cash_amount		online_amount
		merchant-1		250				500
		merchant-2		 0				550
		merchant-3		600				 0
		merchant-5		0				200
*/

SELECT merchant, coalesce(sum(case when pay_mode = 'cash' then amount end ),0) as 'cash_amount',
			coalesce(sum(case when pay_mode = 'online' then amount end),0) as 'online_amount'
FROM SALE
GROUP BY merchant

/*
	SQL Question in MMT Interview - https://www.youtube.com/watch?v=XsbqEx_3GiM&ab_channel=AnkitBansal
	Script: 
		CREATE TABLE booking_table(
   Booking_id       VARCHAR(3) NOT NULL 
  ,Booking_date     date NOT NULL
  ,User_id          VARCHAR(2) NOT NULL
  ,Line_of_business VARCHAR(6) NOT NULL
);

INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b1','2022-03-23','u1','Flight');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b2','2022-03-27','u2','Flight');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b3','2022-03-28','u1','Hotel');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b4','2022-03-31','u4','Flight');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b5','2022-04-02','u1','Hotel');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b6','2022-04-02','u2','Flight');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b7','2022-04-06','u5','Flight');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b8','2022-04-06','u6','Hotel');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b9','2022-04-06','u2','Flight');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b10','2022-04-10','u1','Flight');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b11','2022-04-12','u4','Flight');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b12','2022-04-16','u1','Flight');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b13','2022-04-19','u2','Flight');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b14','2022-04-20','u5','Hotel');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b15','2022-04-22','u6','Flight');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b16','2022-04-26','u4','Hotel');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b17','2022-04-28','u2','Hotel');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b18','2022-04-30','u1','Hotel');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b19','2022-05-04','u4','Hotel');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b20','2022-05-06','u1','Flight');

CREATE TABLE user_table(
   User_id VARCHAR(3) NOT NULL
  ,Segment VARCHAR(2) NOT NULL
);

INSERT INTO user_table(User_id,Segment) VALUES ('u1','s1');
INSERT INTO user_table(User_id,Segment) VALUES ('u2','s1');
INSERT INTO user_table(User_id,Segment) VALUES ('u3','s1');
INSERT INTO user_table(User_id,Segment) VALUES ('u4','s2');
INSERT INTO user_table(User_id,Segment) VALUES ('u5','s2');
INSERT INTO user_table(User_id,Segment) VALUES ('u6','s3');
INSERT INTO user_table(User_id,Segment) VALUES ('u7','s3');
INSERT INTO user_table(User_id,Segment) VALUES ('u8','s3');
INSERT INTO user_table(User_id,Segment) VALUES ('u9','s3');
INSERT INTO user_table(User_id,Segment) VALUES ('u10','s3');

Q1) Write a sql query that gives below output:
		segment		total_user_count		user_who_booked_flight_in_apr2022
		  s1			3								2
		  s2			2								2
		  s3			5								1
*/

WITH segment_with_total_user_count as (
	SELECT segment,
			count(*) as total_user_count
	FROM user_table
	GROUP BY segment
),

segment_with_user_who_booked_flight as (
	SELECT Segment,
			count(distinct u.user_id) as user_who_booked_flight_in_apr2022
	FROM user_table u
	inner join booking_table b
		on u.User_id = b.User_id
	WHERE DATEPART(MONTH,Booking_date) = 4
			and Line_of_business = 'Flight'
	GROUP BY Segment
)

SELECT a.segment,
		total_user_count,
		user_who_booked_flight_in_apr2022
FROM segment_with_total_user_count a
INNER JOIN segment_with_user_who_booked_flight b
		on a.segment = b.segment



/*
		Q2) Write a sql query to identify users whose first booking was a hotel booking
*/

WITH cte as (
	SELECT  *, rank() over (partition by user_id order by Booking_date) as rn
	FROM booking_table
)

SELECT User_id
FROM cte
WHERE rn = 1 and Line_of_business = 'Hotel'


/*
		Q3) Write a sql query to calculate the days between first and last booking of each user
*/


SELECT User_id,
		min(Booking_date) as first_date,
		max(Booking_date) as last_date,
		DATEDIFF(day,min(Booking_date), max(Booking_date)) as number_of_days
FROM booking_table
GROUP BY User_id


/*
	Q4) Write a sql query to count the number of flight and hotel bookings in each of the user segments for the year 2022
*/

WITH cte as (
	SELECT a.*,
			b.Segment
	FROM booking_table a
	inner join user_table b
		on a.User_id = b.User_id
	Where DATEPART(year,Booking_date) = 2022
)

SELECT segment,
			sum(case when Line_of_business = 'Flight' then 1 end) as flight_count,
			sum(case when Line_of_business = 'Hotel' then 1 end) as hotel_count
FROM cte
GROUP BY segment


