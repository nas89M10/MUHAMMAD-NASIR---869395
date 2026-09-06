--Section 1 — Basic SELECT & Filtering

--QUESTION 1
SELECT * FROM production.products;
--QUESTION 2
SELECT * FROM production.products where list_price >1000
--QUESTION 3
SELECT * FROM sales.customers where  state = 'NY' 
--QUESTION 4
SELECT * FROM sales.orders where YEAR(order_date) = 2017;
--QUESTION 5
SELECT * FROM production.products where product_name like ('Trek') ;
--QUESTION 6
SELECT * FROM production.products where list_price BETWEEN 500 AND 1500;
--QUESTION 7
SELECT DISTINCT * FROM sales.customers;  --SELECT DISTINCT
--QUESTION 8
SELECT* FROM sales.orders where shipped_date IS NULL;
