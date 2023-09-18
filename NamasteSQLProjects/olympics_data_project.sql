SELECT *
FROM athletes;

SELECT *
FROM athlete_events;

/*
	1. which team has won the maximum gold medals over the years.
*/

SELECT team, 
		count(distinct event) as Gold_amount
FROM athlete_events a
INNER JOIN athletes b 
	on a.athlete_id = b.id
WHERE medal = 'Gold'
GROUP BY team
ORDER BY count(distinct event) desc

/*
	2. For each team print total silver medals and year in which they won maximum silver medal..output 3 columns
		team,total_silver_medals, year_of_max_silver
*/

with cte as (
	SELECT team,
			year,
			count(distinct event) as silver_medals_won,
			rank() over (partition by team order by count(distinct event) desc) as rn
	FROM athlete_events a
	INNER JOIN athletes b 
		on a.athlete_id = b.id
	WHERE medal = 'Silver'
	GROUP BY team, year 
)

SELECT team, 
		sum(silver_medals_won) as total_silver_won, 
		max(case when rn =1 then year end) as year_of_max_silver
FROM cte
GROUP BY team


/*
	3. Which player has won maximum gold medals  amongst the players 
		which have won only gold medal (never won silver or bronze) over the years
*/

with cte as (
	SELECT athlete_id, 
			count(distinct event) as count_gold
	FROM athlete_events
	WHERE medal = 'Gold'
	GROUP BY athlete_id
),

bronze_and_silver as (
	SELECT athlete_id
	FROM athlete_events
	WHERE medal = 'Bronze' or medal = 'Silver'
	GROUP BY athlete_id
), 

max_gold_winner as (
	SELECT *
	FROM cte 
	WHERE athlete_id not in (
		SELECT athlete_id
		FROM bronze_and_silver
	)
)

SELECT *
FROM max_gold_winner
INNER JOIN athletes
	on athlete_id = id
order by count_gold desc


/*
	4. Each year which player has won maximum gold medal . Write a query to print year,player name 
		and no of golds won in that year . In case of a tie print comma separated player names.
*/


with cte as (
	SELECT year, athlete_id,
			count(distinct event) as gold_count,
			rank() over (partition by year order by count(distinct event) desc) as rnk
	FROM athlete_events
	WHERE medal = 'Gold'
	group by year, athlete_id
)

SELECT year, 
		gold_count, 
		STRING_AGG(name, ',') as Player_name
FROM cte a
INNER JOIN athletes b 
	on a.athlete_id = b.id
WHERE rnk = 1
group by year, gold_count

/*
	5. In which event and year India has won its first gold medal,first silver medal and first bronze medal
		print 3 columns medal,year,sport
*/

with cte as (
	SELECT *
	FROM athlete_events a 
	INNER JOIN athletes b 
		on a.athlete_id = b.id
	WHERE team = 'India' and medal in ('Gold', 'Silver', 'Bronze')
), 

min_year as (
	SELECT medal,
			min(year) as year
	FROM cte
	group by medal
)

SELECT a.medal,
		a.year,
		sport
FROM min_year as a
INNER JOIN cte b 
	on a.medal = b.medal 
		and 
	a.year = b.year
GROUP BY a.medal, a.year, sport


/*
	Another method
*/

with cte as (
	SELECT *,
			rank() over (partition by medal order by year) as rnk
	FROM athlete_events a 
	INNER JOIN athletes b
			on a.athlete_id = b.id
	WHERE team = 'India' and medal in ('Gold', 'Silver', 'Bronze')
)

SELECT medal,
		year,
		event
FROM cte
WHERE rnk = 1
GROUP BY medal,year,event
	


/*
	6. Find players who won gold medal in summer and winter olympics both.
*/

with cte as (
	SELECT athlete_id,
			count(distinct season) as coun
	FROM athlete_events
	WHERE medal = 'Gold'
	GROUP BY athlete_id
	HAVING count(distinct season) = 2
)

SELECT *
FROM cte a
INNER JOIN athletes b on a.athlete_id = b.id

/*
	7. Find players who won gold, silver and bronze medal in a single olympics. print player name along with year.
*/

with cte as (
	SELECT year,
			athlete_id,
			count(distinct medal) as coun
	FROM athlete_events
	GROUP BY year,
			athlete_id
	HAVING count(distinct medal) =3
)

SELECT b.name,
		a.year
FROM cte a 
INNER JOIN athletes b 
	on a.athlete_id = b.id


/*
	8. Find players who have won gold medals in consecutive 3 summer olympics in the same event . Consider only olympics 2000 onwards. 
		Assume summer olympics happens every 4 year starting 2000. print player name and event name.
*/

with cte as (
	SELECT name,year,event
	FROM athlete_events ae
	INNER JOIN athletes a 
		on ae.athlete_id=a.id
	WHERE	year >=2000 
		and 
			season='Summer'
		and 
			medal = 'Gold'
	GROUP BY name,year,event
),

cte_with_next_prev as (
	SELECT *, 
		  lag(year,1) over (partition by name, event order by year) as prev_year,
		  lead(year,1) over (partition by name, event order by year) as next_year
	FROM cte
)

SELECT *
FROM cte_with_next_prev
WHERE year = prev_year +4 
	and year = next_year-4

