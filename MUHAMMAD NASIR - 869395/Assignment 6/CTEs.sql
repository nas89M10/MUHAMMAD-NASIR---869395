--CTEs
-- Exercise
--6.1
WITH store_counts AS
(
    SELECT
        store_id,
        COUNT(*) AS order_count
    FROM sales.orders
    GROUP BY store_id
)
SELECT AVG(order_count) AS avg_orders
FROM store_counts;

--6.2
WITH cte_high_value_products AS
(
    SELECT
        product_id,
        product_name,
        category_id,
        list_price
    FROM production.products
    WHERE list_price > 2000
)
SELECT
    p.product_id,
    p.product_name,
    p.list_price,
    c.category_name
FROM cte_high_value_products p
JOIN production.categories c
    ON p.category_id = c.category_id
WHERE c.category_name = 'Mountain Bikes';

--6.3
WITH customer_orders AS
(
    SELECT
        customer_id,
        COUNT(*) AS order_count
    FROM sales.orders
    GROUP BY customer_id
),

customer_revenue AS
(
    SELECT
        o.customer_id,
        SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_revenue
    FROM sales.orders o
    JOIN sales.order_items oi
        ON o.order_id = oi.order_id
    GROUP BY o.customer_id
)

SELECT
    co.customer_id,
    co.order_count,
    cr.total_revenue
FROM customer_orders co
JOIN customer_revenue cr
    ON co.customer_id = cr.customer_id;

--6.4
WITH numbers AS
(
    -- Anchor
    SELECT 1 AS n

    UNION ALL

    -- Recursive part
    SELECT n + 1
    FROM numbers
    WHERE n < 10
)
SELECT
    n,
    n * n AS square
FROM numbers
OPTION (MAXRECURSION 10);

--6.5
WITH org_chart AS
(
    -- Top manager
    SELECT
        staff_id,
        first_name,
        last_name,
        manager_id,
        CAST(NULL AS VARCHAR(50)) AS manager_first_name,
        0 AS level
    FROM sales.staffs
    WHERE manager_id IS NULL

    UNION ALL

    -- Employees under each manager
    SELECT
        s.staff_id,
        s.first_name,
        s.last_name,
        s.manager_id,
        m.first_name AS manager_first_name,
        oc.level + 1 AS level
    FROM sales.staffs s
    JOIN org_chart oc
        ON s.manager_id = oc.staff_id
    JOIN sales.staffs m
        ON s.manager_id = m.staff_id
)
SELECT
    staff_id,
    first_name,
    last_name,
    manager_first_name,
    level
FROM org_chart
ORDER BY level, staff_id
OPTION (MAXRECURSION 100);

--6.6
-- ANSWER: No, this claim is not always accurate. A CTE does not automatically store or calculate its result only once.