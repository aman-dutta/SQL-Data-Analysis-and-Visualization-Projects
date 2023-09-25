/*
		LinkedIn Power Creators (Part 2) [LinkedIn SQL Interview Question]
		https://datalemur.com/questions/linkedin-power-creators-part2

		personal_profiles Example Input:
				profile_id	name				followers
				1			Nick Singh			92,000
				2			Zach Wilson			199,000
				3			Daliana Liu			171,000
				4			Ravit Jain			107,000
				5			Vin Vashishta		139,000
				6			Susan Wojcicki		39,000
	
		
		employee_company Example Input:
		personal_profile_id	company_id
				1				4
				1				9
				2				2
				3				1
				4				3
				5				6
				6				5

		company_pages Example Input:
		company_id	name						followers
		1			The Data Science Podcast	8,000
		2			Airbnb						700,000
		3			The Ravit Show				6,000
		4			DataLemur					200
		5			YouTube						1,6000,000
		6			DataScience.Vin				4,500
		9			Ace The Data Science Interview	4479

Example Output:
		profile_id
			1
			3
			4
			5

*/

with cte as (
  SELECT a.personal_profile_id, b.followers, max(c.followers) as company_followers
  from employee_company a   
  INNER JOIN personal_profiles b on a.personal_profile_id = b.profile_id
  INNER JOIN company_pages c on a.company_id = c.company_id
  GROUP BY a.personal_profile_id, b.followers
)

SELECT personal_profile_id as profile_id
FROM cte  
WHERE followers > company_followers
ORDER BY personal_profile_id ASC