
CREATE DATABASE IF NOT EXISTS retail_db;
USE retail_db;

-- Customers
CREATE TABLE customers (
    customer_id      INT PRIMARY KEY AUTO_INCREMENT,
    first_name       VARCHAR(50) NOT NULL,
    last_name        VARCHAR(50) NOT NULL,
    email            VARCHAR(100) UNIQUE,
    phone            VARCHAR(20),
    country          VARCHAR(50),
    city             VARCHAR(50),
    signup_date      DATE NOT NULL
);

-- Product Categories
CREATE TABLE product_categories (
    category_id      INT PRIMARY KEY AUTO_INCREMENT,
    category_name    VARCHAR(100) NOT NULL
);

-- Products
CREATE TABLE products (
    product_id       INT PRIMARY KEY AUTO_INCREMENT,
    product_name     VARCHAR(150) NOT NULL,
    category_id      INT NOT NULL,
    unit_price       DECIMAL(10,2) NOT NULL,
    is_active        TINYINT(1) DEFAULT 1,
    FOREIGN KEY (category_id) REFERENCES product_categories(category_id)
);

-- Orders (header)
CREATE TABLE orders (
    order_id         INT PRIMARY KEY AUTO_INCREMENT,
    customer_id      INT NOT NULL,
    order_date       DATETIME NOT NULL,
    order_status     ENUM('PENDING','PAID','SHIPPED','CANCELLED','REFUNDED') NOT NULL,
    shipping_city    VARCHAR(50),
    shipping_country VARCHAR(50),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Order Items (line items)
CREATE TABLE order_items (
    order_item_id    INT PRIMARY KEY AUTO_INCREMENT,
    order_id         INT NOT NULL,
    product_id       INT NOT NULL,
    quantity         INT NOT NULL,
    unit_price       DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Payments
CREATE TABLE payments (
    payment_id       INT PRIMARY KEY AUTO_INCREMENT,
    order_id         INT NOT NULL,
    payment_date     DATETIME NOT NULL,
    payment_method   ENUM('CARD','UPI','NET_BANKING','CASH_ON_DELIVERY') NOT NULL,
    amount           DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);
