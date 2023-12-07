
--- SQL Project_1 ---------------------
--- By SM. Hasinur Rahman --------------


-- create Database----
CREATE DATABASE CompanySalesData;

-- select Database--
use companysalesdata;

-- create Table-----
CREATE TABLE sales (
  customer_id VARCHAR(5) NOT NULL,
  order_date DATE NOT NULL,
  product_id INT NOT NULL
);

-- insert data----
INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
  
CREATE TABLE menu (
  product_id INTEGER NOT NULL,
  product_name VARCHAR(5) NOT NULL,
  price INTEGER NOT NULL
);

INSERT INTO menu
(product_id, product_name, price)
VALUES
  ('1', 'Rice', '10'),
  ('2', 'curry', '15'),
  ('3', 'Sweet', '12');
  
CREATE TABLE members (
  customer_id VARCHAR(5) not null,
  join_date DATE
);

INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
---------- Solved the following questions:
-- 1)--What is the total amount each customer spent at the restaurant?
-- 2)--How many days has each customer visited the restaurant?
-- 3)--What was the first item from the menu purchased by each customer?
-- 4) --What is the most purchased item on the menu and how many times was
-- it purchased by all customers?
-- 5) --Which item was the most popular for each customer?

-- 6)--Which item was purchased first by the customer after they became 
-- a member?

-- 7)--Which item was purchased just before the customer became a member?

-- 8)--What is the total items and amount spent for each member before
--- they became a member?

---------------------- Question solve part------------------------------

-- 1)--What is the total amount each customer spent at the restaurant?

SELECT
	s.customer_id,
	SUM(m.price) as total_amount_spent
FROM
	companysalesdata.sales as s
		JOIN
	companysalesdata.menu as m 
		ON s.product_id = m.product_id
GROUP BY
  s.customer_id;
  
-- 2)--How many days has each customer visited the restaurant?

SELECT
	customer_id,
    count(distinct order_date) as Total_Day_of_visiting
FROM
	companysalesdata.sales 
GROUP BY
	customer_id;

-- 3)--What was the first item from the menu purchased by each customer?

with ranked as (
SELECT
	s.customer_id,
    m.product_name,
    s.order_date,
    row_number() over(partition by customer_id order by order_date) as serial_no
FROM
	companysalesdata.sales as s
    join
    companysalesdata.menu as m
    on s.product_id=m.product_id)
    
SELECT
	customer_id, product_name
FROM ranked
WHERE
	serial_no=1;
    
-- 4) --What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT
  m.product_name AS most_purchased_item,
  COUNT(product_name) AS purchase_count
FROM
	companysalesdata.sales as s
		JOIN
	companysalesdata.menu as m 
		ON s.product_id = m.product_id
GROUP BY
  m.product_name
ORDER BY
  purchase_count DESC
LIMIT 1;


-- 5) --Which item was the most popular for each customer?

with ranked as(
select
	s.customer_id,
    m.product_name,
    count(m.product_name) as total_purchase_quantity,
    rank() over(partition by customer_id order by count(m.product_name) desc) as ranks
from
	companysalesdata.sales as s
	join
	companysalesdata.menu as m
	on s.product_id=m.product_id
group by
	1, 2)
    
select 
	customer_id,
    product_name as most_popolar_Item,
    total_purchase_quantity
FROM
	ranked 
where ranks=1;

-- 6)--Which item was purchased first by the customer after they became a member?

WITH FirstItemMember AS (
  SELECT
    s.customer_id,
    m.product_name,
    s.order_date,
    RANK() OVER (PARTITION BY s.customer_id ORDER BY s.order_date) AS rank_num
  FROM
    companysalesdata.sales as s
		JOIN
    companysalesdata.menu as m 
		ON s.product_id = m.product_id
  JOIN
    companysalesdata.members as mem 
		ON s.customer_id = mem.customer_id
  WHERE
    s.order_date >= mem.join_date
)

SELECT
  customer_id,
  product_name AS first_purchase_after_membership
FROM
  FirstItemMember
WHERE
  rank_num = 1;

-- 7)--Which item was purchased just before the customer became a member?

WITH BeforeMember as (
  SELECT
    s.customer_id,
    m.product_name,
    s.order_date,
    ROW_NUMBER() OVER (PARTITION BY s.customer_id ORDER BY s.order_date DESC) AS row_num
  FROM
    companysalesdata.sales as s
		JOIN
    companysalesdata.menu as m 
		ON s.product_id = m.product_id
		JOIN
    companysalesdata.members as mem 
		ON s.customer_id = mem.customer_id
  WHERE
    s.order_date < mem.join_date
)

SELECT
  customer_id,
  product_name AS last_purchase_before_membership
FROM
  BeforeMember
WHERE
  row_num = 1;
  
-- 8)-- What is the total items and amount spent for each member before they became a member?

WITH BeforeMember as (
  SELECT
    s.customer_id,
    m.product_name,
    m.price,
    COUNT(m.product_name) AS item_count_before_member,
    SUM(m.price) AS total_amount_spent_before_member
  FROM
    companysalesdata.sales as s
		JOIN
    companysalesdata.menu as m 
		ON s.product_id = m.product_id
		JOIN
    companysalesdata.members as mem 
		ON s.customer_id = mem.customer_id
  WHERE
    s.order_date < mem.join_date
  GROUP BY
    s.customer_id, m.product_name, m.price
)

SELECT
  customer_id,
  product_name,
  item_count_before_member,
  total_amount_spent_before_member
FROM
  BeforeMember;
  
  ------------------------ PROJECT END! THANK YOU --------------------
