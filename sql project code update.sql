-- data base created
CREATE DATABASE grocery_store;
USE grocery_store;

-- 1. Supplier Table
CREATE TABLE supplier (
    sup_id TINYINT AUTO_INCREMENT PRIMARY KEY,
    sup_name VARCHAR(255),
    address TEXT
);

-- 2. Categories Table
CREATE TABLE categories (
    cat_id TINYINT AUTO_INCREMENT PRIMARY KEY,
    cat_name VARCHAR(255)
);

-- 3. Employees Table
CREATE TABLE employees (
    emp_id TINYINT AUTO_INCREMENT PRIMARY KEY,
    emp_name VARCHAR(255),
    hire_date VARCHAR(255)
);

-- 4. Customers Table
CREATE TABLE customers (
    cust_id SMALLINT AUTO_INCREMENT PRIMARY KEY,
    cust_name VARCHAR(255),
    address TEXT
);

-- 5. Products Table
CREATE TABLE products (
    prod_id TINYINT AUTO_INCREMENT PRIMARY KEY,
    prod_name VARCHAR(255),
    sup_id TINYINT,
    cat_id TINYINT,
    price DECIMAL(10,2),
    FOREIGN KEY (sup_id) REFERENCES supplier(sup_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (cat_id) REFERENCES categories(cat_id)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- 6. Orders Table
CREATE TABLE orders (
    ord_id SMALLINT AUTO_INCREMENT PRIMARY KEY,
    cust_id SMALLINT,
    emp_id TINYINT,
    order_date VARCHAR(255),
    FOREIGN KEY (cust_id) REFERENCES customers(cust_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (emp_id) REFERENCES employees(emp_id)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- 7. Order_Details Table
CREATE TABLE order_details (
    ord_detID SMALLINT AUTO_INCREMENT PRIMARY KEY,
    ord_id SMALLINT,
    prod_id TINYINT,
    quantity TINYINT,
    each_price DECIMAL(10,2),
    total_price DECIMAL(10,2),
    FOREIGN KEY (ord_id) REFERENCES orders(ord_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (prod_id) REFERENCES products(prod_id)
        ON UPDATE CASCADE ON DELETE CASCADE
);
select * from categories;
select * from customers;
select * from employees;
select * from order_details;
select * from orders;
select * from products;
select * from supplier;
-- sql query--
-- CUSTOMER INSIGHTS --
-- unique customers have placed orders--  
SELECT COUNT(DISTINCT cust_id) AS total_customers
FROM orders;
-- which customers have placed the highest  number of orders--
SELECT cust_id, COUNT(*) AS total_orders
FROM orders
GROUP BY cust_id
ORDER BY total_orders DESC;
-- total and average purchase value per customer  --
SELECT 
    o.cust_id, 
    SUM(od.total_price) AS total_spent,       -- Total purchase value
    AVG(od.total_price) AS avg_purchase       -- Average purchase per order
FROM orders o
JOIN order_details od 
    ON o.ord_id = od.ord_id
GROUP BY o.cust_id
ORDER BY total_spent DESC;
-- top 5 customers by total purchasee amount--
SELECT 
c.cust_id,
c.cust_name,
SUM(od.total_price) AS total_spent
FROM customers c
JOIN orders o ON c.cust_id = o.cust_id
JOIN order_details od ON o.ord_id = od.ord_id
GROUP BY c.cust_id, c.cust_name
ORDER BY total_spent DESC
LIMIT 5;

-- PRODUCT PERFORMANCE --
-- how many products exist in each category --
SELECT cat_id, COUNT(*) AS total_products
FROM products
GROUP BY cat_id;
-- average price of products by category --
SELECT cat_id, AVG(price) AS avg_price
FROM products
GROUP BY cat_id;
-- which products  have highest total sales volume(by quantity)
-- top 5 products which product haveing  more sales --
SELECT prod_id, SUM(quantity) AS total_qty
FROM order_details
GROUP BY prod_id
ORDER BY total_qty DESC
LIMIT 5;
-- product total revenue --
SELECT prod_id, SUM(total_price) AS revenue
FROM order_details
GROUP BY prod_id
ORDER BY revenue DESC;
-- which product sales vary by category and supplier --
SELECT 
p.cat_id,
p.sup_id,
SUM(od.quantity) AS total_quantity,
SUM(od.total_price) AS total_sales
FROM products p
JOIN order_details od 
ON p.prod_id = od.prod_id
GROUP BY p.cat_id, p.sup_id
ORDER BY total_sales DESC;
-- SALES AND ORDER TRENDS --
-- How many orders have been placed in total--
-- query1 total orders count --
SELECT COUNT(*) AS total_orders
FROM orders;
-- Average order value --
-- FOR ORDER AVERAGE HOW MUCH MONEY WILL GET --
SELECT AVG(total_price) AS avg_order_value
FROM order_details;
-- which date the orders are high--
-- identify busiest day ---
SELECT order_date, COUNT(*) AS total_orders
FROM orders
GROUP BY order_date
ORDER BY total_orders DESC;
-- Monthly trend --
-- each month orders pattern--
SELECT MONTH(STR_TO_DATE(order_date,'%Y-%m-%d')) AS month,
COUNT(*) AS total_orders
FROM orders
GROUP BY month;
SELECT order_date FROM orders LIMIT 10;
SELECT 
MONTH(STR_TO_DATE(order_date,'%m/%d/%Y')) AS month,
COUNT(*) AS total_orders
FROM orders
GROUP BY month
ORDER BY month;
-- order patterns vary across weekdays and weekends --
SELECT 
CASE 
    WHEN DAYOFWEEK(STR_TO_DATE(order_date,'%m/%d/%Y')) IN (1,7) 
    THEN 'Weekend'
    ELSE 'Weekday'
END AS day_type,
COUNT(*) AS total_orders
FROM orders
GROUP BY day_type;

-- SUPPLIER ANALYSIS --
-- Total suppliers count --
SELECT COUNT(*) AS total_suppliers
FROM supplier;
-- which supplier PROVIDES THE most products ---
SELECT sup_id, COUNT(*) AS total_products
FROM products
GROUP BY sup_id
ORDER BY total_products DESC;
-- supplier-wise average price of products from each supplier --
SELECT sup_id, AVG(price) AS avg_price
FROM products
GROUP BY sup_id;
-- supplier revenue --
-- which supplier products are earning more money --
SELECT p.sup_id, SUM(od.total_price) AS total_revenue
FROM products p
JOIN order_details od 
ON p.prod_id = od.prod_id
GROUP BY p.sup_id
ORDER BY total_revenue DESC;

-- Employee Performance --
-- how many employees handleing orders --
SELECT COUNT(DISTINCT emp_id) AS total_employees
FROM orders;
-- which employee handleing  more orders --
-- who is busiest employee --
SELECT emp_id, COUNT(*) AS total_orders
FROM orders
GROUP BY emp_id
ORDER BY total_orders DESC;
-- employee sales--
-- total sales value processed by each employee  --
SELECT o.emp_id, SUM(od.total_price) AS total_sales
FROM orders o
JOIN order_details od 
ON o.ord_id = od.ord_id
GROUP BY o.emp_id
ORDER BY total_sales DESC;
-- Average order value  handled per employee--
SELECT o.emp_id, AVG(od.total_price) AS avg_order_value
FROM orders o
JOIN order_details od 
ON o.ord_id = od.ord_id
GROUP BY o.emp_id;

-- order details--
-- relationship between quantity ordered and total price--
SELECT 
    quantity,
    SUM(total_price) AS total_sales,
    AVG(total_price) AS avg_sales_per_order
FROM order_details
GROUP BY quantity
ORDER BY quantity;
-- average quantity ordered per product --
SELECT 
    prod_id,
    AVG(quantity) AS avg_quantity_ordered
FROM order_details
GROUP BY prod_id
ORDER BY avg_quantity_ordered DESC;
-- unit price vary across products  and orders --
SELECT 
    prod_id,
    MIN(each_price) AS min_unit_price,
    MAX(each_price) AS max_unit_price,
    AVG(each_price) AS avg_unit_price
FROM order_details
GROUP BY prod_id
ORDER BY avg_unit_price DESC;

SELECT 
    od.prod_id,
    od.each_price,
    o.order_date
FROM order_details od
JOIN orders o ON od.ord_id = o.ord_id
ORDER BY od.prod_id, o.order_date;

