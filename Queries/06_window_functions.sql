
USE retail_db;

-- =========================
-- 1) Rank customers by total revenue (global)
-- =========================
-- Goal:
-- For each customer, show:
--   - customer_id
--   - customer_name
--   - total_revenue (only PAID orders)
--   - revenue_rank (1 = highest spender overall)

-- 👉 Your query here

SELECT 
   customer_id,
   customer_name,
   total_revenue,
   Rank() over (order by total_revenue desc) as revenue_rank
From (
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    SUM(oi.quantity * oi.unit_price) AS total_revenue
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'PAID'
GROUP BY 
    c.customer_id,
    customer_name
)t;



-- =========================
-- 2) Rank customers by revenue within each country
-- =========================
-- Goal:
-- For each customer, show:
--   - customer_name
--   - country
--   - total_revenue
--   - country_rank (1 = top spender inside that country)

-- 👉 Your query here
SELECT 
   customer_name,
   country,
   total_revenue,
   Rank() over ( PARTITION by country order by total_revenue desc) as revenue_country
From (
SELECT
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.country,
    SUM(oi.quantity * oi.unit_price) AS total_revenue
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'PAID'
GROUP BY 
    customer_name,
    c.country
)t;

#WITH CTE 
#=================

with customer_country_revenue as (
    SELECT
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.country,
    SUM(oi.quantity * oi.unit_price) AS total_revenue
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'PAID'
GROUP BY 
    customer_name,
    c.country
)
select 
    customer_name,
    country,
    total_revenue,
    rank() over(partition by country order by total_revenue desc) as country_rank
from customer_country_revenue
order by country, country_rank;



-- =========================
-- 3) Running total revenue by order date
-- =========================
-- Goal:
-- For each day, show:
--   - order_day
--   - daily_revenue
--   - running_total_revenue (sum of all previous days + current)

-- 👉 Your query here

SELECT
    order_day,
    daily_revenue,
    SUM(daily_revenue) OVER (ORDER BY order_day) AS running_total_revenue
FROM (
    SELECT
        DATE(o.order_date) AS order_day,
        SUM(oi.quantity * oi.unit_price) AS daily_revenue
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'PAID'
    GROUP BY DATE(o.order_date)
) t
ORDER BY order_day;



-- =========================
-- 4) Compare each day's revenue to previous day (LAG)
-- =========================
-- Goal:
-- For each day, show:
--   - order_day
--   - daily_revenue
--   - previous_day_revenue
--   - difference_from_prev_day

-- 👉 Your query here
SELECT
    order_day,
    daily_revenue,
    lag(daily_revenue) over(order by order_day) as previous_day_revenue,
    daily_revenue -  lag(daily_revenue) over(order by order_day) as difference_from_prev_day
 FROM (   
SELECT 
    DATE(o.order_date) AS order_day,
    SUM(oi.quantity * oi.unit_price) AS daily_revenue
FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'PAID'
    GROUP BY DATE(o.order_date)
 ) t 
 order by order_day;


-- =========================
-- 5) Classify orders as HIGH / MEDIUM / LOW vs customer average
-- =========================
-- Goal:
-- For each order, show:
--   - order_id
--   - customer_name
--   - order_amount
--   - avg_order_amount_for_customer
--   - category: 'HIGH' if > avg, 'LOW' if < avg, 'EQUAL' if = avg

-- 👉 Your query here
WITH order_amounts AS (
    SELECT
        o.order_id,
        o.customer_id,
        SUM(oi.quantity * oi.unit_price) AS order_amount
    FROM orders o
    JOIN order_items oi 
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'PAID'
    GROUP BY 
        o.order_id,
        o.customer_id
),
order_with_avg AS (
    SELECT
        oa.order_id,
        oa.customer_id,
        oa.order_amount,
        AVG(oa.order_amount) OVER (
            PARTITION BY oa.customer_id
        ) AS avg_order_amount_for_customer
    FROM order_amounts oa
)
SELECT
    owa.order_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    owa.order_amount,
    owa.avg_order_amount_for_customer,
    CASE 
        WHEN owa.order_amount > owa.avg_order_amount_for_customer THEN 'HIGH'
        WHEN owa.order_amount < owa.avg_order_amount_for_customer THEN 'LOW'
        ELSE 'EQUAL'
    END AS category
FROM order_with_avg owa
JOIN customers c
    ON owa.customer_id = c.customer_id
ORDER BY 
    customer_name,
    owa.order_id;


- =========================
-- EXTRA PRACTICE QUESTIONS
-- =========================

-- Q1: Top 2 products by revenue within each category
-- 👉 Write your solution here

select 
   category,
   product,
   Revenue,
    highest_revenue AS product_rank_in_category
from
(
select 
   category,
   product,
   Revenue,
   Rank() over (partition by category order by revenue desc) as highest_revenue
From(
 SELECT 
   pc.category_id,
   pc.category_name as category,
   p.product_id,
   p.product_name as product,
   SUM(oi.quantity * oi.unit_price) AS revenue
from product_categories pc 
join products p
  on pc.category_id = p.category_id
join order_items oi 
   on p.product_id = oi.product_id
group by  
   pc.category_id,
   pc.category_name,
   p.product_id
) as base
) as ranked
where highest_revenue <= 2
order by category desc;


-- Q2: Order amount vs previous order amount per customer (LAG)
-- 👉 Write your solution here

SELECT
    customer_id,
    order_id,
    order_day,
    order_amount,
    previous_order_amount,
    order_amount - previous_order_amount AS difference_from_prev_order
FROM (
    SELECT
        customer_id,
        order_id,
        order_day,
        order_amount,
        LAG(order_amount) OVER (
            PARTITION BY customer_id
            ORDER BY order_day
        ) AS previous_order_amount
    FROM (
        SELECT 
            c.customer_id AS customer_id,
            o.order_id AS order_id,
            DATE(o.order_date) AS order_day,
            SUM(oi.quantity * oi.unit_price) AS order_amount
        FROM orders o
        JOIN order_items oi
            ON o.order_id = oi.order_id
        JOIN customers c
            ON o.customer_id = c.customer_id
        WHERE o.order_status = 'PAID'
        GROUP BY 
            c.customer_id,
            o.order_id,
            order_day
    ) base
) x
ORDER BY 
    customer_id,
    order_day;




-- Q3: Customers who spent more than average customer revenue
-- 👉 Write your solution here

with customer_revenue as 
  ( 
    select 
       c.customer_id as customer_id,
       CONCAT(c.first_name, '', c.last_name) as customer_name,
       sum(oi.quantity * oi.unit_price) as revenue
    from customers c 
    join orders o
       on c.customer_id = o.customer_id
    join order_items oi 
       on o.order_id = oi.order_id
     WHERE o.order_status = 'PAID'
    GROUP BY 
        customer_name,
        c.customer_id
  ),
  overall_avg_revenue as 
  (
    select 
       avg(revenue)  as avg_revenue
       from 
           customer_revenue
        
  )

select 
   cr.customer_id as customer_id,
   cr.customer_name as cust_name,
   cr.revenue,
   ovr.avg_revenue
from customer_revenue cr
join overall_avg_revenue ovr 
    on cr.customer_id = ovr.customer_id
where cr.revenue > ovr.avg_revenue;

with window function
=======================

WITH customer_revenue AS (
    SELECT 
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        SUM(oi.quantity * oi.unit_price) AS total_revenue
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'PAID'
    GROUP BY 
        c.customer_id,
        customer_name
),
customer_with_avg AS (
    SELECT
        customer_id,
        customer_name,
        total_revenue,
        AVG(total_revenue) OVER () AS avg_revenue
    FROM customer_revenue
)
SELECT 
    customer_id,
    customer_name,
    total_revenue,
    avg_revenue
FROM customer_with_avg
WHERE total_revenue > avg_revenue
ORDER BY total_revenue DESC;




-- Q4: Products with revenue higher than average product revenue
-- 👉 Write your solution here

WITH product_revenue AS (
    SELECT 
        p.product_id as product_id,
        p.product_name as product_name,
        SUM(oi.quantity * oi.unit_price) AS product_revenue
    FROM products  p
    JOIN order_items oi 
    ON p.product_id = oi.product_id
    GROUP BY 
         p.product_id,
        p.product_name
),
product_with_avg AS (
    SELECT
        product_id,
        product_name,
        product_revenue,
        AVG(product_revenue) OVER () AS avg_product_revenue
    FROM product_revenue
)
SELECT 
     product_id,
        product_name,
        product_revenue,
    avg_product_revenue
FROM product_with_avg
WHERE product_revenue > avg_product_revenue
ORDER BY product_revenue DESC;



