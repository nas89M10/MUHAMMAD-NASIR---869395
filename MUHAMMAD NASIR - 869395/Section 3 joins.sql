--Section 3 — JOINs

-- Task 12
SELECT 
  p.product_id,
  p.product_name,
  b.brand_name,
  c.category_name
FROM production.products p
JOIN production.brands b ON p.brand_id = b.brand_id
JOIN production.categories c ON p.category_id = c.category_id;
 
-- Task 13
SELECT 
  o.order_id,
  CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
  o.order_date,
  o.order_status
FROM sales.orders o
JOIN sales.customers c ON o.customer_id = c.customer_id;
 
-- Task 14
SELECT 
  oi.order_id,
  oi.item_id,
  p.product_name,
  oi.quantity,
  oi.list_price,
  oi.discount
FROM sales.order_items oi
JOIN production.products p ON oi.product_id = p.product_id;
 
-- Task 15
SELECT 
  CONCAT(s.first_name, ' ', s.last_name) AS staff_name,
  st.store_name
FROM sales.staffs s
JOIN sales.stores st ON s.store_id = st.store_id;
 
-- Task 16
SELECT 
  CONCAT(s.first_name, ' ', s.last_name) AS staff_name,
  CONCAT(m.first_name, ' ', m.last_name) AS manager_name
FROM sales.staffs s
LEFT JOIN sales.staffs m ON s.manager_id = m.staff_id;
 
-- Task 17 
SELECT 
  st.store_name,
  p.product_name,
  stock.quantity
FROM sales.stores st
JOIN production.stocks stock ON st.store_id = stock.store_id
JOIN production.products p ON stock.product_id = p.product_id
WHERE stock.quantity > 0
ORDER BY st.store_name, p.product_name;
 
-- Task 18
SELECT DISTINCT
  CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
  o.order_date
FROM sales.customers c
INNER JOIN sales.orders o ON c.customer_id = o.customer_id;
 
-- Task 19
SELECT 
  CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
  o.order_date
FROM sales.customers c
LEFT JOIN sales.orders o ON c.customer_id = o.customer_id;
