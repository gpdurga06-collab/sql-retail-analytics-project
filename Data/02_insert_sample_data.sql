
USE retail_db;

INSERT INTO product_categories (category_name) VALUES
('Electronics'),
('Clothing'),
('Home & Kitchen'),
('Books');

INSERT INTO products (product_name, category_id, unit_price) VALUES
('Wireless Mouse', 1, 19.99),
('Mechanical Keyboard', 1, 79.99),
('T-Shirt', 2, 14.99),
('Jeans', 2, 39.99),
('Coffee Maker', 3, 49.99),
('Cookware Set', 3, 89.99),
('SQL for Beginners', 4, 24.99);

INSERT INTO customers (first_name, last_name, email, phone, country, city, signup_date) VALUES
('Alice', 'Johnson', 'alice@example.com', '111-111-1111', 'USA', 'New York', '2024-01-10'),
('Bob', 'Smith', 'bob@example.com', '222-222-2222', 'USA', 'Chicago', '2024-02-05'),
('Carlos', 'Diaz', 'carlos@example.com', '333-333-3333', 'Mexico', 'Monterrey', '2024-02-20'),
('Diana', 'Lee', 'diana@example.com', '444-444-4444', 'Canada', 'Toronto', '2024-03-01');

INSERT INTO orders (customer_id, order_date, order_status, shipping_city, shipping_country) VALUES
(1, '2024-03-10 14:23:00', 'PAID', 'New York', 'USA'),
(1, '2024-03-15 09:10:00', 'PAID', 'New York', 'USA'),
(2, '2024-03-16 18:45:00', 'PAID', 'Chicago', 'USA'),
(3, '2024-03-18 11:30:00', 'CANCELLED', 'Monterrey', 'Mexico'),
(4, '2024-03-19 16:05:00', 'PAID', 'Toronto', 'Canada');

INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 1, 19.99),
(1, 3, 2, 14.99),
(2, 2, 1, 79.99),
(2, 7, 1, 24.99),
(3, 5, 1, 49.99),
(4, 4, 1, 39.99),
(5, 6, 1, 89.99);

INSERT INTO payments (order_id, payment_date, payment_method, amount) VALUES
(1, '2024-03-10 14:25:00', 'CARD', 49.97),
(2, '2024-03-15 09:15:00', 'UPI', 104.98),
(3, '2024-03-16 18:50:00', 'CARD', 49.99),
(5, '2024-03-19 16:10:00', 'NET_BANKING', 89.99);

