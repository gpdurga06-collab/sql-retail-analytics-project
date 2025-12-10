
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


