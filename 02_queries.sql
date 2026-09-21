-- Q1: INNER JOIN - full order detail
SELECT o.order_id,
       TO_CHAR(o.order_date, 'YYYY-MM-DD') AS order_date,
       c.customer_name,
       p.product_name,
       oi.quantity,
       p.price * oi.quantity AS line_total
FROM   orders o
JOIN   customers   c  ON c.customer_id = o.customer_id
JOIN   order_items oi ON oi.order_id   = o.order_id
JOIN   products    p  ON p.product_id  = oi.product_id
ORDER BY o.order_id, p.product_name;

-- Q2: LEFT JOIN - customers who never ordered
SELECT c.customer_id, c.customer_name, c.city
FROM   customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
WHERE  o.order_id IS NULL;

-- Q3: LEFT JOIN - products that never sold
SELECT p.product_id, p.product_name, p.category, p.price
FROM   products p
LEFT JOIN order_items oi ON oi.product_id = p.product_id
WHERE  oi.order_item_id IS NULL;

-- Q4: CTE - customer lifetime value and segment
WITH customer_spend AS (
  SELECT c.customer_id,
         c.customer_name,
         COUNT(DISTINCT o.order_id)     AS total_orders,
         SUM(p.price * oi.quantity)     AS total_spent
  FROM   customers c
  JOIN   orders o       ON o.customer_id = c.customer_id
  JOIN   order_items oi ON oi.order_id   = o.order_id
  JOIN   products p     ON p.product_id  = oi.product_id
  GROUP BY c.customer_id, c.customer_name
)
SELECT customer_name,
       total_orders,
       total_spent,
       CASE WHEN total_spent >= 30 THEN 'High value'
            WHEN total_spent >= 20 THEN 'Medium value'
            ELSE 'Low value' END AS segment
FROM   customer_spend
ORDER BY total_spent DESC;

-- Q5: CTE - monthly revenue
WITH monthly_sales AS (
  SELECT TO_CHAR(o.order_date, 'YYYY-MM') AS sales_month,
         COUNT(DISTINCT o.order_id)       AS orders_placed,
         SUM(p.price * oi.quantity)       AS revenue
  FROM   orders o
  JOIN   order_items oi ON oi.order_id  = o.order_id
  JOIN   products p     ON p.product_id = oi.product_id
  GROUP BY TO_CHAR(o.order_date, 'YYYY-MM')
)
SELECT sales_month, orders_placed, revenue
FROM   monthly_sales
ORDER BY sales_month;

-- Q6: Window - RANK products by revenue within each category
WITH product_revenue AS (
  SELECT p.category,
         p.product_name,
         SUM(oi.quantity)           AS units_sold,
         SUM(p.price * oi.quantity) AS revenue
  FROM   products p
  JOIN   order_items oi ON oi.product_id = p.product_id
  GROUP BY p.category, p.product_name
)
SELECT category,
       product_name,
       units_sold,
       revenue,
       RANK() OVER (PARTITION BY category ORDER BY revenue DESC) AS rank_in_category
FROM   product_revenue
ORDER BY category, rank_in_category;

-- Q7: Window - LAG for month-over-month growth
WITH monthly_sales AS (
  SELECT TO_CHAR(o.order_date, 'YYYY-MM') AS sales_month,
         SUM(p.price * oi.quantity)       AS revenue
  FROM   orders o
  JOIN   order_items oi ON oi.order_id  = o.order_id
  JOIN   products p     ON p.product_id = oi.product_id
  GROUP BY TO_CHAR(o.order_date, 'YYYY-MM')
)
SELECT sales_month,
       revenue,
       LAG(revenue) OVER (ORDER BY sales_month) AS prev_month_revenue,
       ROUND((revenue - LAG(revenue) OVER (ORDER BY sales_month))
             / LAG(revenue) OVER (ORDER BY sales_month) * 100, 1) AS growth_pct
FROM   monthly_sales
ORDER BY sales_month;

-- Q8: Window - running total of each customer's spend by order
WITH order_totals AS (
  SELECT o.order_id,
         o.customer_id,
         o.order_date,
         SUM(p.price * oi.quantity) AS order_total
  FROM   orders o
  JOIN   order_items oi ON oi.order_id  = o.order_id
  JOIN   products p     ON p.product_id = oi.product_id
  GROUP BY o.order_id, o.customer_id, o.order_date
)
SELECT c.customer_name,
       TO_CHAR(ot.order_date, 'YYYY-MM-DD') AS order_date,
       ot.order_total,
       SUM(ot.order_total) OVER (PARTITION BY ot.customer_id
                                 ORDER BY ot.order_date, ot.order_id) AS running_total,
       ROW_NUMBER() OVER (PARTITION BY ot.customer_id
                          ORDER BY ot.order_date, ot.order_id) AS order_number
FROM   order_totals ot
JOIN   customers c ON c.customer_id = ot.customer_id
ORDER BY c.customer_name, ot.order_date;

-- Q9: Window - each category's share of total revenue
WITH category_revenue AS (
  SELECT p.category, SUM(p.price * oi.quantity) AS revenue
  FROM   products p
  JOIN   order_items oi ON oi.product_id = p.product_id
  GROUP BY p.category
)
SELECT category,
       revenue,
       ROUND(revenue / SUM(revenue) OVER () * 100, 1) AS pct_of_total
FROM   category_revenue
ORDER BY revenue DESC;
