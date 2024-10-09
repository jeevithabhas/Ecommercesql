-- Create the database and tables

DROP DATABASE ecommerce;
CREATE DATABASE ecommerce;
USE ecommerce;

CREATE TABLE customers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100),
    address VARCHAR(255)
);


CREATE TABLE orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    total_amount DECIMAL(10, 2),
    FOREIGN KEY (customer_id) REFERENCES customers(id)
);

CREATE TABLE products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    price DECIMAL(10, 2),
    description TEXT
);

-- Insert sample data into the tables

INSERT INTO customers (name, email, address) 
VALUES 
('John Doe', 'john@example.com', '123 Elm St'),
('Jane Smith', 'jane@example.com', '456 Oak St'),
('Alice Johnson', 'alice@example.com', '789 Maple St');

INSERT INTO products (name, price, description) 
VALUES 
('Product A', 30.00, 'Description of Product A'),
('Product B', 25.00, 'Description of Product B'),
('Product C', 50.00, 'Description of Product C');

INSERT INTO orders (customer_id, order_date, total_amount) 
VALUES 
(1, '2024-09-20', 80.00),
(2, '2024-10-01', 50.00),
(3, '2024-09-25', 45.00);

-- Temporary table for orders and products before normalization

CREATE TABLE orders_products (
    order_id INT,
    product_id INT,
    quantity INT DEFAULT 1,
    FOREIGN KEY (order_id) REFERENCES orders(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);

INSERT INTO orders_products (order_id, product_id, quantity)
VALUES 
(1, 1, 2),
(2, 2, 1),
(3, 1, 1);

-- Queries

SELECT c.* 
FROM customers c 
JOIN orders o ON c.id = o.customer_id 
WHERE o.order_date >= CURDATE() - INTERVAL 30 DAY;

SELECT c.name, SUM(o.total_amount) AS total_spent
FROM customers c
JOIN orders o ON c.id = o.customer_id
GROUP BY c.id;


SET SQL_SAFE_UPDATES = 0;
UPDATE products 
SET price = 45.00 
WHERE name = 'Product C';


ALTER TABLE products 
ADD discount DECIMAL(5, 2) DEFAULT 0;

SELECT name, price 
FROM products 
ORDER BY price DESC 
LIMIT 3;

SELECT DISTINCT c.name
FROM customers c
JOIN orders o ON c.id = o.customer_id
JOIN orders_products op ON o.id = op.order_id
JOIN products p ON op.product_id = p.id
WHERE p.name = 'Product A';

SELECT c.name, o.order_date 
FROM customers c 
JOIN orders o ON c.id = o.customer_id;

SELECT * 
FROM orders 
WHERE total_amount > 150.00;

-- Normalize the database by creating order_items table

CREATE TABLE order_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    FOREIGN KEY (order_id) REFERENCES orders(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);

INSERT INTO order_items (order_id, product_id, quantity)
SELECT order_id, product_id, quantity FROM orders_products;

DROP TABLE orders_products;

SELECT AVG(total_amount) AS average_order_total 
FROM orders;
