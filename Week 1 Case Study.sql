-- 1. What is the total amount each customer spent at the restaurant?

SELECT sales.customer_id, SUM(menu.price)
FROM sales
INNER JOIN menu
ON sales.product_id = menu.product_id
GROUP BY sales.customer_id;

-- 2. How many days has each customer visited the restaurant?

SELECT customer_id, COUNT(DISTINCT order_date)
FROM sales
GROUP BY customer_id;

-- 3. What was the first item from the menu purchased by each customer?

SELECT customer_id, product_name
FROM (SELECT sales.customer_id, menu.product_name, DENSE_RANK () OVER (PARTITION BY sales.customer_id ORDER BY sales.order_date) AS rownumber
FROM sales
JOIN menu
ON sales.product_id = menu.product_id) AS tab
WHERE rownumber = 1;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT menu.product_name, COUNT(*)
FROM sales
JOIN menu
ON sales.product_id = menu.product_id
GROUP BY menu.product_name
ORDER BY COUNT(*) DESC
LIMIT 1;

-- 5. Which item was the most popular for each customer?

SELECT customer_id, product_name
FROM (
SELECT customer_id, product_name, RANK () OVER (PARTITION BY customer_id ORDER BY pdtCount) AS rownumber
FROM (
SELECT customer_id, product_name, COUNT(product_name) AS pdtCount
FROM menu
JOIN sales
ON menu.product_id = sales.product_id
GROUP BY customer_id, product_name
ORDER BY customer_id, pdtCount DESC) AS rank) AS tab
WHERE rownumber = 1;

-- 6. Which item was purchased first by the customer after they became a member?

SELECT customer_id, product_name
FROM
(SELECT customer_id, product_name, RANK () OVER (PARTITION BY customer_id ORDER BY order_date) AS rownumber
FROM
(SELECT tab.customer_id, order_date, product_name, join_date
FROM
(SELECT customer_id, order_date, product_name
FROM sales
JOIN menu
ON sales.product_id = menu.product_id) AS tab
JOIN members
ON tab.customer_id = members.customer_id
WHERE order_date >= join_date
ORDER BY tab.customer_id, order_date) AS tab1) AS tab2
WHERE rownumber = 1;

-- 7. Which item was purchased just before the customer became a member?

SELECT customer_id, product_name
FROM
(SELECT customer_id, product_name, RANK () OVER (PARTITION BY customer_id ORDER BY order_date DESC) AS rownumber
FROM
(SELECT tab.customer_id, order_date, product_name, join_date
FROM
(SELECT customer_id, order_date, product_name
FROM sales
JOIN menu
ON sales.product_id = menu.product_id) AS tab
JOIN members
ON tab.customer_id = members.customer_id
WHERE order_date < join_date
ORDER BY tab.customer_id, order_date) AS tab1) AS tab2
WHERE rownumber = 1;

-- 8. What is the total items and amount spent for each member before they became a member?

SELECT tab.customer_id, COUNT(product_name), SUM(price)
FROM
(SELECT customer_id, order_date, product_name, price
FROM sales
JOIN menu
ON sales.product_id = menu.product_id) AS tab
JOIN members
ON tab.customer_id = members.customer_id
WHERE order_date < join_date
GROUP BY tab.customer_id
ORDER BY tab.customer_id;

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

SELECT customer_id, SUM(points) AS total
FROM
(SELECT customer_id, sales.product_id,
CASE
    WHEN product_name = 'sushi' THEN price * 10 * 2
    ELSE price * 10
END AS points
FROM sales
JOIN menu
ON sales.product_id = menu.product_id) as tab
GROUP BY customer_id
ORDER BY customer_id;

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

SELECT tab.customer_id, SUM(points)
FROM
(SELECT customer_id, order_date, price * 10 * 2 AS points
FROM sales
JOIN menu
ON sales.product_id = menu.product_id) AS tab
JOIN members
ON tab.customer_id = members.customer_id
WHERE order_date >= join_date AND order_date <= join_date + 7 * INTERVAL '1 day' AND order_date <= '2021-01-31'
GROUP BY tab.customer_id
ORDER BY tab.customer_id;

-- Bonus Question

-- Join All The Things

SELECT tab.customer_id, order_date, product_name, price,
	CASE 
    	WHEN join_date <= order_date THEN 'Y'
        ELSE 'N'
    END AS member   
FROM
(SELECT customer_id, order_date, product_name, price
FROM sales
JOIN menu
ON sales.product_id = menu.product_id) AS tab
LEFT JOIN members
ON tab.customer_id = members.customer_id
ORDER BY tab.customer_id, order_date, price DESC
