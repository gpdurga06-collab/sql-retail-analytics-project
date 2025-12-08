USE retail_db;

-- =========================
-- 1) Example: Orders with customer name
-- =========================
-- Goal:
-- Show each order with:
--   - order_id
--   - order_date
--   - order_status
--   - customer full name
--   - customer city, country

SELECT 
    o.order_id,
    o.order_date,
    o.order_status,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.city,
    c.country
FROM orders o
JOIN customers c 
    ON o.customer_id = c.customer_id;

-- =========================
-- 2) TODO: Order items with product & category
-- =========================
-- Goal:
-- Show each line item with:
--   - order_id
--   - product_name
--   - category_name
--   - quantity
--   - unit_price
--   - line_total (quantity * unit_price)

SELECT 
    oi.order_id,
    p.product_name,
    pc.category_name,
    oi.quantity,
    oi.unit_price,
    (oi.quantity * oi.unit_price) as line_total
from order_items oi
join products p
    on oi.product_id = p.product_id
join product_categories pc 
    on p.category_id = pc.category_id;



-- =========================
-- 3) TODO: All PAID orders with total amount (using JOIN)
-- =========================
-- Goal:
-- For each PAID order, show:
--   - order_id
--   - order_date
--   - customer_name
--   - total_order_amount (sum of quantity * unit_price for that order)
-- Only include orders where order_status = 'PAID'.

SELECT
     o.order_id,
     o.order_date,
     CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
     SUM(oi.quantity * oi.unit_price) AS total_order_amount
FROM orders o 
JOIN order_items oi
    ON o.order_id = oi.order_id
JOIN customers c 
     ON o.customer_id = c.customer_id
WHERE o.order_status = 'PAID'
GROUP BY 
     o.order_id,
     o.order_date,
     customer_name;


-- =========================
-- 4) TODO: Customer-level summary (joining multiple tables)
-- =========================
-- Goal:
-- For each customer, show:
--   - customer_id
--   - customer_name
--   - country
--   - how many orders they placed (order_count)
--   - total revenue from that customer (only PAID orders)
--
-- Hints:
--   - JOIN customers -> orders -> order_items
--   - Use SUM(quantity * unit_price)
--   - Use GROUP BY at customer level

SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.country,
    count(distinct o.order_id),
    SUM(oi.quantity * oi.unit_price) AS total_revenue_customer
from 
   customers c
join 
    orders o 
on 
  c.customer_id = o.customer_id
join
    order_items oi
on 
  o.order_id = oi.order_id
where o.order_status = "PAID"
group by 
      c.customer_id,
      customer_name,
      c.country ;




