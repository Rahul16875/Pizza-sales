create database pizzahut;
use pizzahut;
  
create table orders(
	order_id int primary key not null,
    order_date date not null,
    order_time time not null);

create table order_details(
	order_details_id int primary key not null,
    order_id int not null,
    pizza_id text not null,
    quantity int not null);

select * from pizzas;
select * from pizza_types;
select * from orders;
select * from order_details;

-- Retrieve the total number of orders placed

select count(order_id) as total_orders from orders;

-- Calculate the total revenue generated from pizza sales;
-- without sum function it will give indiviaul pizzas sales as we want all so we have used sum then for doing round of upto 2 digits we have used round function.

SELECT 
    ROUND(SUM(o.quantity * p.price), 2) AS total_revenue
FROM
    order_details AS o
        JOIN
    pizzas AS p ON p.pizza_id = o.pizza_id;
    

-- Identify highest priced pizza
-- we use order By for sorting

SELECT 
    pt.name AS Name, p.price AS Price
FROM
    pizza_types AS pt
        JOIN
    pizzas AS p ON pt.pizza_type_id = p.pizza_type_id
ORDER BY p.price DESC
LIMIT 1;


-- Identify the most common pizza size ordered

SELECT 
    p.size, COUNT(o.order_details_id) AS order_count
FROM
    pizzas AS p
        JOIN
    order_details AS o ON p.pizza_id = o.pizza_id
GROUP BY p.size
ORDER BY order_count DESC
LIMIT 1;

-- List the top 5 most ordered pizza types along with their quantities

SELECT 
    pt.name, SUM(o.quantity) AS quantity
FROM
    pizzas AS p
        JOIN
    pizza_types AS pt ON p.pizza_type_id = pt.pizza_type_id
        JOIN
    order_details AS o ON o.pizza_id = p.pizza_id
GROUP BY pt.name
ORDER BY quantity DESC
LIMIT 5;


-- join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    pt.category, SUM(o.quantity) AS quantity
FROM
    pizzas AS p
        JOIN
    pizza_types AS pt ON p.pizza_type_id = pt.pizza_type_id
        JOIN
    order_details AS o ON o.pizza_id = p.pizza_id
GROUP BY pt.category;


-- determine the distributiuon of orders by hour of the day.

select hour(order_time) as hour, count(order_id) as id from orders
group by hour order by hour ;


-- join relevent tables to find the category-wise distribution of pizzas means count howmany pizzas are available in each categ.

select category, count(name) from pizza_types
group by category;


-- Group the orders by date and calculate the avg numbers of pizzas ordered per day.

select round(avg(quantity),0) as avg_pizzas_ordered_per_day from (select o.order_date as date, sum(od.quantity) as quantity
from orders as o
join order_details as od
on o.order_id = od.order_id
group by o.order_date) as orderData ;


-- Determine the top 3 most ordered pizza types based on revenue.

select pt.name as Name, round(sum(o.quantity * p.price),2) as Revenue 
from pizzas as p 
join pizza_types as pt
on p.pizza_type_id = pt.pizza_type_id
join order_details as o
on o.pizza_id = p.pizza_id
group by Name order by Revenue desc limit 3;


-- Calculate the percentage contribution of each pizza type of total revenue 

SELECT 
    pt.category AS Categ,
    ROUND(SUM(o.quantity * p.price) / (SELECT 
                    ROUND(SUM(o.quantity * p.price), 2)
                FROM
                    order_details AS o
                        JOIN
                    pizzas AS p ON p.pizza_id = o.pizza_id) * 100,
            2) AS Revenue
FROM
    pizzas AS p
        JOIN
    pizza_types AS pt ON p.pizza_type_id = pt.pizza_type_id
        JOIN
    order_details AS o ON o.pizza_id = p.pizza_id
GROUP BY Categ
ORDER BY Revenue DESC;


-- Alternative method 

WITH TotalRevenue AS (
    SELECT ROUND(SUM(o.quantity * p.price), 2) AS TotalRevenueAmount
    FROM order_details AS o
    JOIN pizzas AS p ON p.pizza_id = o.pizza_id
)

SELECT 
    pt.category AS Categ, 
    ROUND(
        (SUM(o.quantity * p.price) / tr.TotalRevenueAmount) * 100, 
        2
    ) AS Revenue
FROM 
    pizzas AS p
JOIN 
    pizza_types AS pt ON p.pizza_type_id = pt.pizza_type_id
JOIN 
    order_details AS o ON o.pizza_id = p.pizza_id
CROSS JOIN 
    TotalRevenue AS tr
GROUP BY 
    pt.category, tr.TotalRevenueAmount
ORDER BY 
    Revenue DESC;
    
    

-- Analyze the cumulative revenue generated over time means based on date. 

select date, ROUND(sum(revenue) over (order by date) ,2) as CumulativeRevenue from (select o.order_date as date, round(sum(od.quantity * p.price),2) as revenue
from order_details as od
join pizzas as p
on p.pizza_id = od.pizza_id
join orders as o
on o.order_id = od.order_id
group by date ) as sales;


-- Determine the top most ordered pizza types based on revenue for each pizza category.

select name,category, Revenue from (select category , name, Revenue , rank() over(partition by category order by Revenue DESC) as rn from  (select pt.category as category, pt.name as name, round(sum(o.quantity * p.price),2) as Revenue 
from pizzas as p 
join pizza_types as pt
on p.pizza_type_id = pt.pizza_type_id
join order_details as o
on o.pizza_id = p.pizza_id
group by pt.category, pt.name) as data) as data1
where rn <= 1;




