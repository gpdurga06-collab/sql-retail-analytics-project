
USE retail_db;

-- 1) See all customers
SELECT * FROM customers;

-- 2) See only customer names and cities
SELECT 
    first_name,
    last_name,
    city,
    country
FROM customers;

-- 3) List all products with their price
SELECT 
    product_id,
    product_name,
    unit_price
FROM products;

-- 4) Products cheaper than 30, sorted by price (low to high)
SELECT 
    product_name,
    unit_price
FROM products
WHERE unit_price < 30
ORDER BY unit_price ASC;

-- 5) All orders (just to see raw data)
SELECT * FROM orders;

-- 6) Only PAID orders
SELECT *
FROM orders
WHERE order_status = 'PAID';

-- 7) PAID orders after 2024-03-14
SELECT *
FROM orders
WHERE order_status = 'PAID'
  AND order_date >= '2024-03-15';

-- 8) Simple check: join orders with customers (just ID + name for now)
SELECT 
    o.order_id,
    o.order_date,
    o.order_status,
    c.first_name,
    c.last_name,
    c.city,
    c.country
FROM orders o
JOIN customers c 
    ON o.customer_id = c.customer_id;
