
/*
	1- write a query to print top 5 cities with highest spends and their percentage contribution of total credit card spends 
*/

with total_spend as (
	select sum(cast(amount as bigint)) as total_credit_card_spend
	from credit_card_transcations
), 

top_5_city as (
	select top 5 city, sum(cast(amount as bigint)) as total_city_spend
	from credit_card_transcations
	group by city
	order by sum(cast(amount as bigint)) desc
)

SELECT *, round((total_city_spend*1.0/total_credit_card_spend*1.0)*100,2) as percentage_contribution
FROM top_5_city, total_spend

/*
	2- write a query to print highest spend month and amount spent in that month for each card type
*/

with month_wise_sum as (
	select FORMAT(transaction_date, 'yyyy-MM') as dateCol, card_type, sum(amount) as amountSum
	from credit_card_transcations
	group by FORMAT(transaction_date, 'yyyy-MM'), card_type
),

card_with_rank as (
	select *, rank() over (partition by card_type order by amountSum desc) as rnk
	from month_wise_sum
)

select *
from card_with_rank
where rnk = 1

/*
	3- write a query to print the transaction details(all columns from the table) for each card type when
	it reaches a cumulative of 1000000 total spends(We should have 4 rows in the o/p one for each card type)
*/

with cummulative_sum as (
	select *, sum(amount) over (partition by card_type order by transaction_date rows between unbounded preceding and current row) as cummulativeSum
	from credit_card_transcations
), 

greater_than as (
	select *
	from cummulative_sum
	where cummulativeSum >= 1000000
), 

rank_card as (
	select *, rank() over (partition by card_type order by cummulativeSum) as rnk
	from greater_than
)

select *
from rank_card
where rnk = 1

/*
	4- write a query to find city which had lowest percentage spend for gold card type
*/

with city_total_spent as (
	select city, sum(amount) as total_spent
	from credit_card_transcations
	group by city
), 

city_card_total_spent as (
	select city,card_type, sum(amount) as total_spent_card
	from credit_card_transcations
	group by city, card_type
),


gold_contribution as (
	select c1.city, card_type, total_spent, total_spent_card, round((total_spent_card*1.0/total_spent*1.0)*100,2) as gold_percentage
	from city_total_spent c1
	inner join city_card_total_spent c2 on c1.city = c2.city
	where card_type = 'Gold'
)

select top 1 *
from gold_contribution
order by gold_percentage


/*
	5- write a query to print 3 columns:  city, highest_expense_type , lowest_expense_type (example format : Delhi , bills, Fuel)
*/

with city_expense as (
	select city,exp_type, sum(amount) as amount_spent
	from credit_card_transcations
	group by city, exp_type
),

rank_exp as (
	select *, rank() over (partition by city order by amount_spent) as rnk1,
				rank() over (partition by city order by amount_spent desc) as rnk2
	from city_expense
),

highest_spend as (
	select city, exp_type as highest_spend
	from rank_exp
	where rnk1 = 1 
),

lowest_spend as (
	select city, exp_type as lowest_spend
	from rank_exp
	where rnk2 = 1 
)

select l.city, lowest_spend, highest_spend
from lowest_spend l
inner join highest_spend h on l.city = h.city;

/*
	6- write a query to find percentage contribution of spends by females for each expense type
*/

with cte as (
	select exp_type, sum(amount) as total_spend , sum(case when gender = 'F' then amount else 0 end) as female_spend
	from credit_card_transcations
	group by exp_type
)

select *, round((female_spend*1.0/total_spend*1.0)*100,2) as percentage_by_female
from cte
order by round((female_spend*1.0/total_spend*1.0)*100,2) desc

/*
	7- which card and expense type combination saw highest month over month growth in Jan-2014
*/

with cte as (
	select format(transaction_date, 'yyyy-MM') as transaction_date, card_type, exp_type,amount
	from credit_card_transcations
),

sum_amount as (
	select transaction_date, card_type, exp_type, sum(amount) as amount
	from cte
	group by transaction_date, card_type, exp_type
), 

lead_lag as (
	select transaction_date, card_type, exp_type, amount, lag(amount) over (partition by card_type,
						exp_type order by transaction_date) as prev_amount
	from sum_amount
)

select top 1 *, (amount - prev_amount)
from lead_lag
where transaction_date = '2014-01'
order by (amount - prev_amount) desc

/*
	8- during weekends which city has highest total spend to total no of transcations ratio 
*/


select top 1 city, sum(amount), count(*), sum(amount)*1.0/count(*)*1.0 as ratio
from credit_card_transcations
where DATENAME(WEEKDAY, transaction_date) in ('Saturday', 'Sunday')
group by city
order by sum(amount)*1.0/count(*)*1.0 desc


/*
	9- which city took least number of days to reach its 500th transaction after the first transaction in that city
*/

with cte as (
	select *, row_number() over (partition by city order by transaction_date,transaction_id ) as rnk
	from credit_card_transcations
), 

first_transaction as (
	select city, transaction_date 
	from cte 
	where rnk = 1
),

fiveHundred_transaction as (
	select city, transaction_date 
	from cte 
	where rnk = 500
)

select top 1 a.city, b.transaction_date, DATEDIFF(day,b.transaction_date, a.transaction_date) as difference_days
from fiveHundred_transaction a
inner join first_transaction b on a.city = b.city
order by DATEDIFF(day,b.transaction_date, a.transaction_date)
