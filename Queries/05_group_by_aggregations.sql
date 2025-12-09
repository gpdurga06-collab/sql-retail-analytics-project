USE retail_db;

-- =========================
-- 1) Revenue per product
-- =========================
-- Goal:
-- Show:
--   - product_name
--   - total_revenue
--   - total_quantity_sold
--   - number_of_orders (count distinct orders)

-- 👉 Your query here
SELECT  
    p.product_name,
    sum(oi.quantity * oi.unit_price) as total_revenue,
    SUM(oi.quantity) AS total_quantity_sold,
    COUNT(DISTINCT o.order_id) AS number_of_orders
from products p 
join order_items oi
 on p.product_id = oi.product_id
join orders o
  on oi.order_id = o.order_id
where o.order_status = "PAID"
group by 
      p.product_name;


-- =========================
-- 2) Revenue per category
-- =========================
-- Goal:
-- Show:
--   - category_name
--   - total_revenue
--   - total_items_sold

SELECT 
    pc.category_name,
    sum(oi.quantity * oi.unit_price) as total_revenue,
    SUM(oi.quantity) AS total_items_sold
from product_categories pc
join products p  
  on pc.category_id = p.category_id
join order_items oi 
  on p.product_id = oi.product_id
  JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'PAID'
group by pc.category_name;

-- =========================
-- 3) Daily revenue
-- =========================
-- Goal:
-- Show:
--   - order_date (DATE only)
--   - total_revenue_that_day
-- Only include PAID orders.

-- 👉 Your query here

SELECT 
    DATE(o.order_date) as Date_only,
    sum(oi.quantity * oi.unit_price) as total_revenue_that_day
from orders o 
join order_items oi 
   on o.order_id = oi.order_id
where o.order_status = "PAID"
group by Date_only;



-- =========================
-- 4) Customer Average Order Value (AOV)
-- =========================
-- Formula:
--   AOV = total_revenue / number_of_orders
--
-- Show:
--   - customer_name
--   - order_count
--   - total_revenue
--   - AOV

-- 👉 Your query here
SELECT
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    count(distinct o.order_id) as number_of_orders,
    sum(oi.quantity * oi.unit_price) as total_revenue,
    (sum(oi.quantity * oi.unit_price)/count(distinct o.order_id)) as AOV
from customers c
join orders o 
   on c.customer_id = o.customer_id
join order_items oi 
   on o.order_id = oi.order_id
where o.order_status = "PAID"
group by customer_name;

-- =========================
-- 5) Best-selling product each day
-- =========================
-- Goal:
-- For each DAY, return only the product with highest revenue that day.
-- (Hint: GROUP BY day + product, then use a subquery or window function)

-- 👉 Your query here

SELECT order_day, product_name, product_revenue
FROM (
    SELECT
        DATE(o.order_date) AS order_day,
        p.product_name,
        SUM(oi.quantity * oi.unit_price) AS product_revenue,
        RANK() OVER (
            PARTITION BY DATE(o.order_date)
            ORDER BY SUM(oi.quantity * oi.unit_price) DESC
        ) AS rnk
    FROM products p 
    JOIN order_items oi 
        ON p.product_id = oi.product_id
    JOIN orders o 
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'PAID'
    GROUP BY 
        DATE(o.order_date),
        p.product_name
) t
WHERE rnk = 1
ORDER BY order_day;