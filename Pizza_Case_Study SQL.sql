

                                        -- SQL CASE STUDY PROJECT --

USE pizza_case_study;

-- let's  import the csv files
-- Now understand each table (all columns)


SELECT * FROM order_details;  -- order_details_id	order_id	pizza_id	quantity

SELECT * FROM pizzas; -- pizza_id, pizza_type_id, size, price

SELECT * FROM orders;  -- order_id, date, time

SELECT * FROM pizza_types;  -- pizza_type_id, name, category, ingredients 

/*
Retrieve the total number of orders placed.
Calculate the total revenue generated from pizza sales.
Identify the highest-priced pizza.
Identify the most common pizza size ordered.
List the top 5 most ordered pizza types along with their quantities.  
*/

-- Retrieve the total number of orders placed


SELECT COUNT(DISTINCT order_id) AS Total_orders_placed
FROM  orders;


-- Calculate the total revenue generated from pizza sales.

SELECT od.order_details_id,p.pizza_id,od.quantity,p.price    -- To see the details 
FROM order_details od   
JOIN pizzas p
ON od.pizza_id = p.pizza_id;

SELECT CAST(SUM(od.quantity*p.price) AS DECIMAL (10,2)) AS Total_Revenue  -- Revenue Genrated
FROM order_details od
JOIN pizzas p
ON od.pizza_id = p.pizza_id;


-- Identify the highest-priced pizza.


SELECT pizza_type_id,MAX(price) AS price  -- Using Single Table  without Much Details 
FROM pizzas
GROUP BY pizza_type_id
ORDER BY MAX(price) DESC
LIMIT 1;

SELECT p.name,pi.price,pi.size,pi.pizza_type_id -- Using Joins With Much More Details
FROM pizza_types p
JOIN pizzas pi
ON p.pizza_type_id = pi.pizza_type_id
ORDER BY pi.price DESC
LIMIT 1;


-- Identify the most common pizza size ordered.


SELECT p.size, COUNT(DISTINCT order_id) AS 'No of Orders', SUM(quantity) AS 'Total Quantity Ordered' 
FROM order_details od
JOIN pizzas p
ON od.pizza_id = p.pizza_id
-- join pizza_types on pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY p.size
ORDER BY COUNT(DISTINCT order_id) DESC;


-- List the top 5 most ordered pizza types along with their quantities.



SELECT pi.name, SUM(od.quantity) AS Quantity_Ordered
FROM order_details od
JOIN pizzas p
ON od.pizza_id = p.pizza_id
JOIN pizza_types pi
ON pi.pizza_type_id = p.pizza_type_id
GROUP BY pi.name
ORDER BY Quantity_Ordered DESC
LIMIT 5;



/*
Join the necessary tables to find the total quantity of each pizza category ordered.
Determine the distribution of orders by hour of the day.
Join relevant tables to find the category-wise distribution of pizzas.
Group the orders by date and calculate the average number of pizzas ordered per day.
Determine the top 3 most ordered pizza types based on revenue.
*/


-- Join the necessary tables to find the total quantity of each pizza category ordered.


SELECT  pizza_types.category, SUM(quantity) AS 'Total Quantity Ordered'
FROM order_details
JOIN pizzas ON pizzas.pizza_id = order_details.pizza_id
JOIN pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY pizza_types.category 
ORDER BY sum(quantity)  DESC
LIMIT 5;


-- Determine the distribution of orders by hour of the day.


SELECT HOUR(time),COUNT(DISTINCT order_id) AS total_orders
FROM orders
GROUP BY HOUR(time);


-- Join relevant tables to find the category-wise distribution of pizzas.



SELECT category,COUNT(DISTINCT pizza_type_id) AS No_of_pizzas
FROM pizza_types
GROUP BY category;



-- Group the orders by date and calculate the average number of pizzas ordered per day.



SELECT AVG('Total_Pizza') AS 'Avg Number of pizzas ordered per day'  FROM
(
SELECT o.date AS 'Date', sum(od.quantity) AS 'Total_Pizza'
FROM order_details od
JOIN orders o
ON od.order_id = o.order_id
GROUP BY o.date) t;



-- Determine the top 3 most ordered pizza types based on revenue.



SELECT pt.name,SUM(od.quantity * p.price) AS Revenue
FROM order_details od
JOIN  pizzas p 
ON p.pizza_id = od.pizza_id
JOIN pizza_types pt 
ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.name
ORDER BY Revenue DESC
LIMIT 3;



-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

WITH cte1 AS
(
SELECT pt.category,pt.name,
SUM(od.quantity*p.price)AS Revenue
FROM order_details od
JOIN pizzas p
ON p.pizza_id = od.pizza_id
JOIN pizza_types pt
ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.category,pt.name 
ORDER BY Revenue DESC
),
cte2 AS
(
SELECT category,name,Revenue,
RANK()OVER(PARTITION BY category ORDER BY revenue DESC) AS Rank_of_revenue
FROM cte1
)

SELECT *
FROM cte2
WHERE Rank_of_revenue IN(1,2,3);

