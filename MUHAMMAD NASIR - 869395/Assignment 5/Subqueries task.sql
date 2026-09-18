--Subqueries Task

--EXSERCISE

--5.1

SELECT 
  p.product_id,
  p.product_name,
  b.brand_name,
  p.list_price,
  (SELECT AVG(list_price) FROM production.products WHERE brand_id = p.brand_id) AS avg_price_in_brand
FROM production.products p
JOIN production.brands b ON p.brand_id = b.brand_id
WHERE p.list_price > (
  SELECT AVG(list_price)
  FROM production.products
  WHERE brand_id = p.brand_id
)
ORDER BY b.brand_name, p.list_price DESC;

--5.2

SELECT 
  o.order_id,
  o.order_date,
  CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
  c.state,
  o.order_status
FROM sales.orders o
JOIN sales.customers c ON o.customer_id = c.customer_id
WHERE c.customer_id IN (
  SELECT customer_id
  FROM sales.customers
  WHERE state IN ('NY', 'CA')
)
ORDER BY o.order_date DESC;

--5.3

SELECT 
  c.customer_id,
  CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
  c.email
FROM sales.customers c
WHERE NOT EXISTS (
  SELECT 1
  FROM sales.orders o
  WHERE o.customer_id = c.customer_id
);

--5.4

SELECT 
  AVG(item_count) AS avg_items_per_order
FROM (
  SELECT 
    o.order_id,
    COUNT(oi.item_id) AS item_count
  FROM sales.orders o
  LEFT JOIN sales.order_items oi ON o.order_id = oi.order_id
  GROUP BY o.order_id
) AS order_item_counts;

--5.5

SELECT 
  c.customer_id,
  CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
  c.email
FROM sales.customers c
WHERE EXISTS (
  SELECT 1
  FROM sales.orders o
  WHERE o.customer_id = c.customer_id
)
ORDER BY c.first_name;

--5.6

SELECT 
  c.customer_id,
  c.first_name,
  recent_orders.order_id,
  recent_orders.order_date
FROM sales.customers c
CROSS APPLY (
  SELECT TOP 3
    o.order_id,
    o.order_date
  FROM sales.orders o
  WHERE o.customer_id = c.customer_id
  ORDER BY o.order_date DESC
) AS recent_orders
ORDER BY c.customer_id, recent_orders.order_date DESC;

--5.7

-- USE OF ANY
--These are useful when you need comparisons other than equality
SELECT 
  p.product_id,
  p.product_name,
  p.list_price
FROM production.products p
WHERE p.list_price < ANY (
  SELECT list_price
  FROM production.products
  WHERE list_price > 1500
);

--USE OF ALL
-- USE FOR COMPARISION OF EVERY VALUE IN OUR DATA AND GIVE GIVE US KEY INSIGHTS FROM IT.
SELECT 
  s.staff_id,
  CONCAT(s.first_name, ' ', s.last_name) AS staff_name,
  COUNT(o.order_id) AS total_orders
FROM sales.staffs s
LEFT JOIN sales.orders o ON s.staff_id = o.staff_id
GROUP BY s.staff_id, s.first_name, s.last_name
HAVING COUNT(o.order_id) > ALL (
  SELECT COUNT(o2.order_id)
  FROM sales.staffs s2
  LEFT JOIN sales.orders o2 ON s2.staff_id = o2.staff_id
  WHERE s2.staff_id != s.staff_id
  GROUP BY s2.staff_id
);
 
