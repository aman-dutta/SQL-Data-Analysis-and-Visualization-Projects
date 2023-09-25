/*

	1) 3-Topping Pizzas [McKinsey SQL Interview Question]
		https://datalemur.com/questions/pizzas-topping-cost

	pizza_toppings Table:
		Column Name	Type
		topping_name	varchar(255)
		ingredient_cost	decimal(10,2)

	pizza_toppings Example Input:
		topping_name	ingredient_cost
		Pepperoni		0.50
		Sausage			0.70
		Chicken			0.55
		Extra Cheese	0.40


		Example Output:
			pizza							total_cost
			Chicken,Pepperoni,Sausage		1.75
			Chicken,Extra Cheese,Sausage	1.65
			Extra Cheese,Pepperoni,Sausage	1.60
			Chicken,Extra Cheese,Pepperoni	1.45

*/	


with cte as (
  SELECT concat(a.topping_name,',',b.topping_name,',', c.topping_name) as pizza,
        a.ingredient_cost + b.ingredient_cost + c.ingredient_cost as total_cost
  FROM pizza_toppings a, 
        pizza_toppings b,
          pizza_toppings c 
  WHERE 
      a.topping_name < b.topping_name and b.topping_name < c.topping_name
)

select *
from cte
order by total_cost DESC, pizza