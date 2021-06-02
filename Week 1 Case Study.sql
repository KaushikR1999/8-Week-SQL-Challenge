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

-- 3. What was the first item from the menu purchased by each customer?

SELECT SALES.CUSTOMER_ID, MENU.PRODUCT_NAME, RANK() OVER(PARTITION BY SALES.CUSTOMER_ID ORDER BY SALES.ORDER_DATE DESC) AS RowNumber 
FROM SALES
JOIN MENU
ON SALES.PRODUCT_ID = MENU.PRODUCT_ID

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
-- 5. Which item was the most popular for each customer?
-- 6. Which item was purchased first by the customer after they became a member?
-- 7. Which item was purchased just before the customer became a member?
-- 8. What is the total items and amount spent for each member before they became a member?
-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
