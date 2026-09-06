--Section 2 — Sorting & Top-N
--QUESTION 9
SELECT TOP 10 product_name, list_price
FROM production.products
ORDER BY list_price DESC;
--QUESTION 10
SELECT last_name FROM sales.customers
  ORDER BY last_name asc; 
 SELECT first_name FROM sales.customers
  ORDER BY first_name asc; 
--QUESTION 11
SELECT TOP 5 list_price, model_year 
FROM production.products 
WHERE model_year= 2018 
ORDER BY list_price ASC;





   