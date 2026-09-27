--PAPER-2 Scenario Based SQL - BikeStores

--Task 1 — Build the Sales Detail Dataset (6 marks)
SELECT
    o.order_id,
    o.order_date,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_full_name,
    s.store_name,
    CONCAT(st.first_name, ' ', st.last_name) AS staff_full_name,
    p.product_name,
    cat.category_name,
    b.brand_name,
    oi.quantity,
    oi.list_price,
    oi.discount,
    oi.quantity * oi.list_price * (1 - oi.discount) AS net_line_revenue
FROM sales.orders AS o
INNER JOIN sales.customers AS c
    ON o.customer_id = c.customer_id
INNER JOIN sales.stores AS s
    ON o.store_id = s.store_id
INNER JOIN sales.staffs AS st
    ON o.staff_id = st.staff_id
INNER JOIN sales.order_items AS oi
    ON o.order_id = oi.order_id
INNER JOIN production.products AS p
    ON oi.product_id = p.product_id
INNER JOIN production.categories AS cat
    ON p.category_id = cat.category_id
INNER JOIN production.brands AS b
    ON p.brand_id = b.brand_id
WHERE o.order_status = 4
ORDER BY o.order_date DESC;

--Task 2 — Store Performance Summary (5 marks)
SELECT
    s.store_name,
    COUNT(DISTINCT o.order_id) AS number_of_orders,
    SUM(oi.quantity) AS total_units_sold,
    SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_net_revenue,
    SUM(oi.quantity * oi.list_price * (1 - oi.discount))
        / COUNT(DISTINCT o.order_id) AS average_order_value
FROM sales.stores AS s
INNER JOIN sales.orders AS o
    ON s.store_id = o.store_id
INNER JOIN sales.order_items AS oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 4
GROUP BY s.store_id, s.store_name
ORDER BY total_net_revenue DESC;

--Task 3 — High-Value Customers (5 marks)
WITH CustomerSpending AS
(
    SELECT
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        COUNT(DISTINCT o.order_id) AS completed_order_count,
        SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_spending
    FROM sales.customers AS c
    INNER JOIN sales.orders AS o
        ON c.customer_id = o.customer_id
    INNER JOIN sales.order_items AS oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 4
    GROUP BY
        c.customer_id,
        c.first_name,
        c.last_name
)
SELECT
    customer_id,
    customer_name,
    completed_order_count,
    total_spending
FROM CustomerSpending
WHERE total_spending >
(
    SELECT AVG(total_spending)
    FROM CustomerSpending
)
ORDER BY total_spending DESC;

--Task 4 — Inventory Risk Report (5 marks)
SELECT
    p.product_name,
    s.store_name,
    st.quantity AS current_quantity,
    c.category_name,
    b.brand_name
FROM production.stocks AS st
INNER JOIN production.products AS p
    ON st.product_id = p.product_id
INNER JOIN sales.stores AS s
    ON st.store_id = s.store_id
INNER JOIN production.categories AS c
    ON p.category_id = c.category_id
INNER JOIN production.brands AS b
    ON p.brand_id = b.brand_id
WHERE st.quantity < 5
ORDER BY
    st.quantity ASC,
    p.product_name;

--Task 5 — Top Products Within Each Category (6 marks)
WITH ProductSales AS
(
    SELECT
        c.category_name,
        p.product_name,
        SUM(oi.quantity) AS total_units_sold,
        SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_net_revenue
    FROM production.categories AS c
    INNER JOIN production.products AS p
        ON c.category_id = p.category_id
    INNER JOIN sales.order_items AS oi
        ON p.product_id = oi.product_id
    INNER JOIN sales.orders AS o
        ON oi.order_id = o.order_id
    WHERE o.order_status = 4
    GROUP BY
        c.category_name,
        p.product_name
),
RankedProducts AS
(
    SELECT
        category_name,
        product_name,
        total_units_sold,
        total_net_revenue,
        DENSE_RANK() OVER
        (
            PARTITION BY category_name
            ORDER BY total_net_revenue DESC
        ) AS product_position
    FROM ProductSales
)
SELECT
    category_name,
    product_name,
    total_units_sold,
    total_net_revenue,
    product_position
FROM RankedProducts
WHERE product_position <= 3
ORDER BY
    category_name,
    product_position;

--Task 6 — Monthly Sales Trend (6 marks)
WITH MonthlySales AS
(
    SELECT
        YEAR(o.order_date) AS sales_year,
        MONTH(o.order_date) AS sales_month,
        SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_net_revenue
    FROM sales.orders AS o
    INNER JOIN sales.order_items AS oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 4
    GROUP BY
        YEAR(o.order_date),
        MONTH(o.order_date)
),
SalesWithPrevious AS
(
    SELECT
        sales_year,
        sales_month,
        total_net_revenue,
        LAG(total_net_revenue) OVER
        (
            ORDER BY sales_year, sales_month
        ) AS previous_month_revenue
    FROM MonthlySales
)
SELECT
    sales_year AS year,
    sales_month AS month,
    total_net_revenue,
    previous_month_revenue,
    total_net_revenue - previous_month_revenue AS revenue_change
FROM SalesWithPrevious
ORDER BY
    sales_year,
    sales_month;

--Task 7 — Reusable Reporting View (4 marks)
 VIEW sales.customer
AS
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_full_name,
    COUNT(DISTINCT o.order_id) AS total_completed_orders,
    COALESCE(SUM(oi.quantity), 0) AS total_units_purchased,
    COALESCE(
        SUM(oi.quantity * oi.list_price * (1 - oi.discount)),
        0
    ) AS total_net_revenue,
    MAX(o.order_date) AS most_recent_completed_order_date
FROM sales.customers AS c
LEFT JOIN sales.orders AS o
    ON c.customer_id = o.customer_id
    AND o.order_status = 4
LEFT JOIN sales.order_items AS oi
    ON o.order_id = oi.order_id
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name;

--Task 8 — Safe Data Modification (4 marks)
BEGIN TRANSACTION;

UPDATE sales.customers
SET phone = '(999) 555-0101'
WHERE customer_id = 1

SELECT
    customer_id,
    first_name,
    last_name,
    phone
FROM sales.customers
WHERE customer_id = 1;

ROLLBACK TRANSACTION;


-- Task 9 - Store Sales Procedure (6 marks)

GO

CREATE PROCEDURE sales.usp_store_sales_report
    @store_id INT,
    @start_date DATE,
    @end_date DATE
AS
BEGIN
    SET NOCOUNT ON;

    IF @start_date > @end_date
    BEGIN
        RAISERROR(
            'Start date cannot be later than end date.',
            16,
            1
        );
        RETURN;
    END;

    SELECT
        p.product_name,
        SUM(oi.quantity) AS total_units_sold,
        SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_net_revenue
    FROM sales.orders AS o
    INNER JOIN sales.order_items AS oi
        ON o.order_id = oi.order_id
    INNER JOIN production.products AS p
        ON oi.product_id = p.product_id
    WHERE o.store_id = @store_id
      AND o.order_status = 4
      AND o.order_date >= @start_date
      AND o.order_date < DATEADD(DAY, 1, @end_date)
    GROUP BY
        p.product_id,
        p.product_name
    ORDER BY
        total_net_revenue DESC;
END;

GO

EXEC sales.usp_store_sales_report
    @store_id = 1,
    @start_date = '2016-01-01',
    @end_date = '2016-12-31';

--Task 10 — Management Insight Query (3 marks)
SELECT
    s.store_name,
    COUNT(DISTINCT o.order_id) AS completed_orders,
    SUM(oi.quantity) AS total_units_sold,
    SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_net_revenue
FROM sales.stores AS s
INNER JOIN sales.orders AS o
    ON s.store_id = o.store_id
INNER JOIN sales.order_items AS oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 4
GROUP BY s.store_id, s.store_name
ORDER BY total_net_revenue DESC;

-- Business question: Which stores generate the most completed-order revenue?
-- Measures: Completed orders, units sold, and net revenue by store.
-- Why it matters: Management can compare store-level sales performance.