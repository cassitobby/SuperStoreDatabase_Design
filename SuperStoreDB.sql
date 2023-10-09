-- Database: SuperStoreDB

DROP DATABASE IF EXISTS "SuperStoreDB";

CREATE DATABASE "SuperStoreDB"

DROP TABLE IF EXISTS orders;

CREATE TABLE orders(
	order_id CHAR(14),
	order_date DATE,
	ship_date DATE,
	ship_mode VARCHAR(100),
	customer_id CHAR(8),
	customer_name VARCHAR(50),
	segment VARCHAR(100),
	sales_rep VARCHAR(100),
	sales_team VARCHAR(100),
	sales_team_manager VARCHAR(100),
	location_id VARCHAR(225),
	city VARCHAR(100),
	state VARCHAR(100),
	postal_code CHAR(5),
	region VARCHAR(100),
	product_id CHAR(15),
	category VARCHAR(225),
	sub_category VARCHAR(225),
	product_name VARCHAR(225),
	sales DECIMAL (10,2),
	quantity INT,
	discount DECIMAL(10,2),
	profit DECIMAL(10, 2)
);

COPY orders
FROM 'C:\Users\user\Desktop\Portfolio\SuperStoreDB\SuperStoreData.csv'
DELIMITER ',' 
CSV HEADER;

SELECT *
FROM orders
LIMIT 10;

DROP TABLE IF EXISTS customers;

CREATE TABLE customers AS
SELECT 
	DISTINCT customer_id, 
	customer_name, 
	segment
FROM orders;

select * from customers

DROP TABLE IF EXISTS product;

CREATE TABLE product AS
SELECT
	DISTINCT product_id,
	product_name,
	category,
	sub_category
FROM orders

select * from product

DROP TABLE IF EXISTS sales_team;

CREATE TABLE sales_team AS
SELECT
	DISTINCT sales_rep,
	sales_team,
	sales_team_manager
FROM orders

select * from sales_team

DROP TABLE IF EXISTS location;

CREATE TABLE location AS
SELECT
	DISTINCT location_id,
	city,
	state,
	postal_code,
	region
FROM orders

select * from location

ALTER TABLE orders
DROP COLUMN customer_name,
            DROP COLUMN segment,
            DROP COLUMN sales_team,
            DROP COLUMN sales_team_manager,
            DROP COLUMN city,
            DROP COLUMN state,
            DROP COLUMN postal_code,
            DROP COLUMN region,
            DROP COLUMN category,
            DROP COLUMN sub_category,
            DROP COLUMN product_name;

SELECT * FROM orders

-- Adding primary key to each Table
ALTER TABLE customers
ADD CONSTRAINT customers_id PRIMARY KEY (customer_id),
ALTER COLUMN customer_id SET NOT NULL;

ALTER TABLE location
ADD CONSTRAINT location_id PRIMARY KEY (location_id),
ALTER COLUMN location_id SET NOT NULL

-- Set product_id as the primary key
ALTER TABLE product
ADD CONSTRAINT product_id PRIMARY KEY (product_id),
ALTER COLUMN product_id SET NOT NULL

ALTER TABLE sales_team
ADD CONSTRAINT sales_rep_pk PRIMARY KEY (sales_rep),
ALTER COLUMN sales_rep SET NOT NULL

ALTER TABLE orders
ADD COLUMN order_serial_id SERIAL PRIMARY KEY,
ADD CONSTRAINT fk_customer_id
FOREIGN KEY (customer_id)
REFERENCES customers (customer_id),
ADD CONSTRAINT fk_product_id
FOREIGN KEY (product_id)
REFERENCES product (product_id),
ADD CONSTRAINT fk_location_id
FOREIGN KEY (location_id)
REFERENCES location (location_id),
ADD CONSTRAINT fk_sales_rep
FOREIGN KEY (sales_rep)
REFERENCES sales_team (sales_rep);

SELECT * FROM customers
SELECT * FROM location
SELECT * FROM product
SELECT * FROM orders
SELECT * FROM sales_team


/* Create a view that categorize customers based on the amount spent. - amount_spent < 5000, Silver,
<= 10000 then Gold, >10000 - Diamond */

CREATE VIEW customer_category AS 
WITH AmountSpent AS (
SELECT 
	c.customer_name,
	COALESCE(SUM(o.sales * o.quantity), 0) AS amount_spent
FROM orders AS o
LEFT JOIN customers AS c
USING(customer_id)
GROUP BY customer_name
ORDER BY amount_spent DESC
)
SELECT 
	customer_name, 
	amount_spent,
	CASE 
		WHEN amount_spent < 5000 THEN 'Silver Customer'
		WHEN amount_spent <= 10000 THEN 'Gold Customer' ELSE 'Diamond Customer'
		END AS customer_category
FROM AmountSpent;

select * from customer_category
/*Please create two roles: 'Intern' and 'Data Engineer.' Assign the 'Intern' role with SELECT privileges only. 
For the 'Data Engineer' role, grant privileges to CreateDB and Createrole. Additionally, set 
the 'Intern' role to expire on October 10, 2024*/

-- Creating the intern role

CREATE ROLE intern WITH 
	LOGIN 
	PASSWORD '##intern2024'
	VALID UNTIL '10/10/2024';
	
--	Granting the select role to the intern
GRANT SELECT ON ALL TABLES IN SCHEMA public TO intern;

-- Creating the Data Engineer role

CREATE ROLE Data_engineer WITH
	LOGIN
	PASSWORD '##data_engineer'
	
ALTER ROLE Data_engineer WITH CREATEDB CREATEROLE;
