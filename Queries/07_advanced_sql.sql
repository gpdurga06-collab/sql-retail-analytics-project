USE retail_db;

-- =========================
-- A) MORE WINDOW FUNCTIONS
-- =========================

-- Q1: Segment customers into 4 revenue tiers using NTILE(4)
--     (1 = top spenders, 4 = lowest)
-- 👉 Your solution here

select
   customer_id,
   customer_name,
   revenue,
   ntile(4) over( order by revenue desc) as quartile
From(
select 
    c.customer_id as customer_id,
    concat(c.first_name, '', c.last_name) as customer_name,
    sum(oi.quantity * oi.unit_price) as revenue
from customers C
join orders o
    on c.customer_id = o.customer_id
join order_items oi 
    on o.order_id = oi.order_id
group by 
c.customer_id,
customer_name
) t
;


-- Q2: For each customer, show their first and latest order date
--     using MIN/MAX or FIRST_VALUE/LAST_VALUE
-- 👉 Your solution here

select 
   c.customer_id as customer_id,
   concat(c.first_name, '', c.last_name) as customer_name,
   FIRST_VALUE(o.order_date) over ( PARTITION by c.customer_id  order by order_date) as first_order,
   LAST_VALUE(o.order_date) over ( PARTITION by c.customer_id  order by order_date) as last_order
from customers c 
join orders o 
   on c.customer_id = o.customer_id
group by 
     c.customer_id,
     customer_name,
     o.order_date
;


SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    MIN(o.order_date) AS first_order,
    MAX(o.order_date) AS last_order
FROM customers c
JOIN orders o 
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name;



-- Q3: For each day, show revenue and % of total revenue across all days
-- 👉 Your solution here

with revenue_each_day as 
(
    select 
       o.order_id as order_id,
       DATE(o.order_date) as order_day,
       sum(oi.quantity * oi.unit_price) as revenue
    from orders o 
    join order_items oi 
         on o.order_id = oi.order_id
    group by 
           o.order_id,
            DATE(o.order_date)
)
    
select 
    order_id,
    order_day,
    revenue,
    percent_rank() over(order by order_day) as perc_rank
from revenue_each_day;



with revenue_each_day as 
(
    select 
       o.order_id as order_id,
       DATE(o.order_date) as order_day,
       sum(oi.quantity * oi.unit_price) as revenue
    from orders o 
    join order_items oi 
         on o.order_id = oi.order_id
    group by 
           o.order_id,
            DATE(o.order_date)
)

SELECT 
    order_day,
    revenue,
    ROUND(
        revenue * 100.0 / SUM(revenue) OVER(), 
        2
    ) AS pct_of_total
FROM revenue_each_day
ORDER BY order_day;


-- =========================
-- B) MORE SUBQUERIES
-- =========================

-- Q4: Find products whose revenue is higher than the average product revenue
-- 👉 Your solution here

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



-- Q5: Find days where daily revenue is higher than the average daily revenue
-- 👉 Your solution here

select 
   order_id,
   order_day,
   revenue,
   avg_revenue
from (
   select
      order_id,
      order_day,
      revenue,
      avg(revenue) over () as avg_revenue
   from(
    select 
       o.order_id as order_id,
       DATE(o.order_date) as order_day,
       sum(oi.quantity * oi.unit_price) as revenue
    from orders o 
    join order_items oi 
         on o.order_id = oi.order_id
    group by 
           o.order_id,
            DATE(o.order_date)
) as base
)as avg_r
where revenue > avg_revenue
;


WITH daily_revenue AS (
    SELECT 
        DATE(o.order_date) AS order_day,
        SUM(oi.quantity * oi.unit_price) AS revenue
    FROM orders o
    JOIN order_items oi 
        ON o.order_id = oi.order_id
    GROUP BY DATE(o.order_date)
)
SELECT 
    order_day,
    revenue,
    AVG(revenue) OVER () AS avg_daily_revenue
FROM daily_revenue
WHERE revenue > (SELECT AVG(revenue) FROM daily_revenue)
ORDER BY revenue DESC;

    



-- =========================
-- C) RECURSIVE CTEs
-- =========================

-- Q6: Generate a continuous date series from the MIN to MAX order_date
-- 👉 Your solution here

with  RECURSIVE date_series as (
     select 
         order_id,
         DATE(min(order_date)) as order_day
    from Orders 
    group by order_id

    union all

    
    SELECT DATE_ADD(order_day, INTERVAL 1 DAY)
    FROM date_series
    WHERE order_day < (SELECT MAX(DATE(order_date)) FROM orders)         
) 
SELECT order_day
FROM date_series
ORDER BY order_day;


-- Q7: For each date in that series, show:
--     - date
--     - daily_revenue (0 if no orders)
--     - cumulative_revenue up to that date
-- 👉 Your solution here



-- Step 1: Generate continuous date series
WITH RECURSIVE date_series AS (
    SELECT MIN(DATE(order_date)) AS order_day
    FROM orders
    UNION ALL
    SELECT DATE_ADD(order_day, INTERVAL 1 DAY)
    FROM date_series
    WHERE order_day < (SELECT MAX(DATE(order_date)) FROM orders)
),
-- Step 2: Calculate daily revenue
daily_revenue AS (
    SELECT 
        DATE(o.order_date) AS order_day,
        SUM(oi.quantity * oi.unit_price) AS revenue
    FROM orders o
    JOIN order_items oi 
        ON o.order_id = oi.order_id
    GROUP BY DATE(o.order_date)
)
-- Step 3: Join date series with daily revenue
SELECT 
    ds.order_day,
    COALESCE(dr.revenue, 0) AS revenue,
    SUM(dr.revenue) OVER (
        ORDER BY order_day
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_revenue
FROM date_series ds
LEFT JOIN daily_revenue dr
    ON ds.order_day = dr.order_day
ORDER BY ds.order_day;

-- =========================
-- D) STORED PROCEDURES
-- =========================

-- Q8: Stored procedure: get all orders + amounts for a given customer_id
-- 👉 Your procedure definition here


DELIMITER $$

CREATE PROCEDURE GetCustomerOrders(IN p_customer_id INT)
BEGIN
    SELECT 
        o.order_id,
        o.order_date,
        SUM(oi.quantity * oi.unit_price) AS order_amount
    FROM orders o
    JOIN order_items oi 
        ON o.order_id = oi.order_id
    WHERE o.customer_id = p_customer_id
    GROUP BY o.order_id, o.order_date
    ORDER BY o.order_date;
END $$

DELIMITER ;

CALL GetCustomerOrders(101);

-- Q9: Stored procedure: return daily revenue between two given dates
-- 👉 Your procedure definition here

DELIMITER $$

CREATE PROCEDURE GetDailyRevenue(IN p_start_date DATE, IN p_end_date DATE)
BEGIN
    SELECT 
        DATE(o.order_date) AS order_day,
        SUM(oi.quantity * oi.unit_price) AS daily_revenue
    FROM orders o
    JOIN order_items oi 
        ON o.order_id = oi.order_id
    WHERE DATE(o.order_date) BETWEEN p_start_date AND p_end_date
    GROUP BY DATE(o.order_date)
    ORDER BY order_day;
END $$

DELIMITER ;

CALL GetDailyRevenue('2025-12-01', '2025-12-10');