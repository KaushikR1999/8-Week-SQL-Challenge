-- 1. What is the total amount each customer spent at the restaurant?

SELECT SALES.CUSTOMER_ID, SUM(PRICE)
FROM SALES
INNER JOIN MENU
ON SALES.PRODUCT_ID = MENU.PRODUCT_ID
GROUP BY SALES.CUSTOMER_ID

-- 2. How many days has each customer visited the restaurant?

SELECT CUSTOMER_ID, COUNT(DISTINCT ORDER_DATE)
FROM SALES
GROUP BY CUSTOMER_ID
