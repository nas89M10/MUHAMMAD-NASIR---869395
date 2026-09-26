-- Window Functions
 
-- 7.1
 SELECT 
    product_id,
    product_name,
    category_id,
    list_price,

    ROW_NUMBER() OVER (ORDER BY list_price DESC) AS global_row_num,
    ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY list_price DESC) AS row_num_per_category

FROM Production.products
ORDER BY category_id, list_price DESC;

-- 7.2
SELECT 
    product_id,
    product_name,
    category_id,
    list_price,

    RANK() OVER (PARTITION BY category_id ORDER BY list_price DESC) AS rank_position,
    DENSE_RANK() OVER (PARTITION BY category_id ORDER BY list_price DESC) AS dense_rank_position,
    ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY list_price DESC) AS row_num
FROM Production.products
ORDER BY category_id, list_price DESC;
 
--7.3
SELECT 
  st.store_id,
  st.store_name,
  YEAR(o.order_date) AS year,
  MONTH(o.order_date) AS month,
  ROUND(SUM(oi.quantity * oi.list_price * (1 - oi.discount)), 2) AS current_month_revenue,
  ROUND(LAG(SUM(oi.quantity * oi.list_price * (1 - oi.discount))) 
    OVER (PARTITION BY st.store_id ORDER BY YEAR(o.order_date), MONTH(o.order_date)), 2) AS previous_month_revenue,
  ROUND(SUM(oi.quantity * oi.list_price * (1 - oi.discount)) - 
    LAG(SUM(oi.quantity * oi.list_price * (1 - oi.discount))) 
    OVER (PARTITION BY st.store_id ORDER BY YEAR(o.order_date), MONTH(o.order_date)), 2) AS revenue_change
FROM sales.stores st
LEFT JOIN sales.orders o ON st.store_id = o.store_id
LEFT JOIN sales.order_items oi ON o.order_id = oi.order_id
WHERE o.order_date IS NOT NULL
GROUP BY st.store_id, st.store_name, YEAR(o.order_date), MONTH(o.order_date)
ORDER BY st.store_id, YEAR(o.order_date), MONTH(o.order_date);

--7.4
SELECT 
  p.product_id,
  p.product_name,
  p.list_price,
  NTILE(5) OVER (ORDER BY p.list_price ASC) AS price_band
FROM production.products p
ORDER BY p.list_price ASC;

--7.5
WITH order_revenue AS (
  SELECT 
    o.order_id,
    o.order_date,
    o.customer_id,
    ROUND(SUM(oi.quantity * oi.list_price * (1 - oi.discount)), 2) AS order_revenue
  FROM sales.orders o
  LEFT JOIN sales.order_items oi ON o.order_id = oi.order_id
  GROUP BY o.order_id, o.order_date, o.customer_id
)
SELECT 
  order_id,
  order_date,
  customer_id,
  order_revenue,
ROUND(SUM(order_revenue) OVER (ORDER BY order_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW), 2) AS running_total_revenue
FROM order_revenue
ORDER BY order_date;

--7.6
SELECT 
  o.order_id,
  oi.item_id,
  oi.list_price,
  FIRST_VALUE(oi.list_price) OVER (
    PARTITION BY o.order_id 
    ORDER BY oi.item_id
  ) AS first_value_default,
  LAST_VALUE(oi.list_price) OVER (
    PARTITION BY o.order_id 
    ORDER BY oi.item_id
  ) AS last_value_default_WRONG,
  LAST_VALUE(oi.list_price) OVER (
    PARTITION BY o.order_id 
    ORDER BY oi.item_id
    ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
  ) AS last_value_explicit_CORRECT
FROM sales.orders o
LEFT JOIN sales.order_items oi ON o.order_id = oi.order_id
WHERE o.order_id IN (1, 2, 3, 4, 5)
ORDER BY o.order_id, oi.item_id;
 
 
