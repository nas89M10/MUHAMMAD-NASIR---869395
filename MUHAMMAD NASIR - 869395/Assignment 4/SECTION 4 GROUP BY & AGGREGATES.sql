-- SECTION 4: GROUP BY & AGGREGATES
 
-- Task 20
SELECT 
  c.category_name,
  COUNT(p.product_id) AS product_count
FROM production.categories c
LEFT JOIN production.products p ON c.category_id = p.category_id
GROUP BY c.category_id, c.category_name;
 
-- Task 21
SELECT 
  b.brand_name,
  AVG(p.list_price) AS average_price
FROM production.brands b
LEFT JOIN production.products p ON b.brand_id = p.brand_id
GROUP BY b.brand_id, b.brand_name;
 
-- Task 22
SELECT 
  st.store_id,
  st.store_name,
  COUNT(o.order_id) AS total_orders
FROM sales.stores st
LEFT JOIN sales.orders o ON st.store_id = o.store_id
GROUP BY st.store_id, st.store_name;
 
-- Task 23
SELECT 
  oi.order_id,
  SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_revenue
FROM sales.order_items oi
GROUP BY oi.order_id;
 
-- Task 24
SELECT 
  CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
  COUNT(o.order_id) AS order_count
FROM sales.customers c
LEFT JOIN sales.orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY order_count DESC;
 
-- Task 25
SELECT TOP 1
  b.brand_name,
  AVG(CAST(p.list_price AS FLOAT)) AS average_price
FROM production.brands b
JOIN production.products p ON b.brand_id = p.brand_id
GROUP BY b.brand_id, b.brand_name
ORDER BY average_price DESC;

-- Task 26
SELECT 
  c.category_name,
  COUNT(p.product_id) AS product_count
FROM production.categories c
LEFT JOIN production.products p ON c.category_id = p.category_id
GROUP BY c.category_id, c.category_name
HAVING COUNT(p.product_id) > 50;
 
-- Task 27
SELECT 
  st.store_id,
  st.store_name,
  SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_revenue
FROM sales.stores st
LEFT JOIN sales.orders o ON st.store_id = o.store_id
LEFT JOIN sales.order_items oi ON o.order_id = oi.order_id
GROUP BY st.store_id, st.store_name;
 
-- Task 28
SELECT 
  CONCAT(s.first_name, ' ', s.last_name) AS staff_name,
  COUNT(o.order_id) AS order_count
FROM sales.staffs s
LEFT JOIN sales.orders o ON s.staff_id = o.staff_id
GROUP BY s.staff_id, s.first_name, s.last_name
HAVING COUNT(o.order_id) > 50;

--SELF JOIN

-- Task 41: 

SELECT 
  CONCAT(s.first_name, ' ', s.last_name) AS staff_name,
  CONCAT(m.first_name, ' ', m.last_name) AS manager_name
FROM sales.staffs s
LEFT JOIN sales.staffs m ON s.manager_id = m.staff_id;
 
-- Task 42: 

SELECT 
  p1.product_name,
  p2.product_name,
  b.brand_name,
  p1.list_price
FROM production.products p1
JOIN production.products p2 ON p1.brand_id = p2.brand_id 
  AND p1.list_price = p2.list_price 
  AND p1.product_id < p2.product_id
JOIN production.brands b ON p1.brand_id = b.brand_id;
 
 --CROSS JOIN

-- Task 45:

SELECT 
  b.brand_name,
  c.category_name
FROM production.brands b
CROSS JOIN production.categories c;
 
-- Task 46: Cross Join
SELECT 
  b.brand_name,
  c.category_name
FROM production.brands b
CROSS JOIN production.categories c
LEFT JOIN production.products p ON b.brand_id = p.brand_id 
  AND c.category_id = p.category_id
WHERE p.product_id IS NULL;
 
 --Right Join

-- Task 49: 
SELECT 
  b.brand_name,
  p.product_name,
  p.list_price
FROM production.products p
RIGHT JOIN production.brands b ON p.brand_id = b.brand_id
ORDER BY b.brand_name, p.product_name;
 
-- Task 50: 
SELECT 
  st.store_name,
  o.order_id,
  o.order_date,
  o.order_status
FROM sales.orders o
RIGHT JOIN sales.stores st ON o.store_id = st.store_id
ORDER BY st.store_name, o.order_date;

 --Left Anti Join

-- Task 53: 
SELECT 
  c.customer_id,
  CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
  c.email
FROM sales.customers c
LEFT JOIN sales.orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;
 
-- Task 54: 
SELECT 
  p.product_id,
  p.product_name,
  b.brand_name
FROM production.products p
JOIN production.brands b ON p.brand_id = b.brand_id
LEFT JOIN production.stocks s ON p.product_id = s.product_id
WHERE s.store_id IS NULL;
 
-- Task 56: Left Anti Join - Products Never Ordered
SELECT 
  p.product_id,
  p.product_name,
  c.category_name,
  b.brand_name
FROM production.products p
JOIN production.categories c ON p.category_id = c.category_id
JOIN production.brands b ON p.brand_id = b.brand_id
LEFT JOIN sales.order_items oi ON p.product_id = oi.product_id
WHERE oi.order_id IS NULL;
 
-- Task 59: 
SELECT 
  c.category_id,
  c.category_name
FROM production.categories c
LEFT JOIN production.products p ON c.category_id = p.category_id 
  AND p.list_price > 2000
WHERE p.product_id IS NULL;
 
-- Task 60: 
SELECT DISTINCT
  CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
  c.email
FROM sales.customers c
JOIN sales.orders o ON c.customer_id = o.customer_id
LEFT JOIN sales.order_items oi ON o.order_id = oi.order_id
LEFT JOIN production.products p ON oi.product_id = p.product_id
LEFT JOIN production.brands b ON p.brand_id = b.brand_id 
  AND b.brand_name = 'Trek'
WHERE b.brand_id IS NULL
AND o.order_id IS NOT NULL;