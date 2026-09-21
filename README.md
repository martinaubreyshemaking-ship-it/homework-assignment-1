# PLSQL Assignment One - Sunrise Supermarket

**Name:** Aubrey Shema
**Student ID:** YOUR_STUDENT_ID
**DBMS used:** Oracle (SQL*Plus / SQL Developer)

## Summary of what I did

I built the four Sunrise Supermarket tables (`customers`, `products`, `orders`, `order_items`) exactly as given, loaded sample data, and wrote nine analytical queries using JOINs, CTEs, and window functions to answer management's three questions: who the customers are, what they buy, and how sales trend over time.

**Sample data loaded:** 6 customers, 8 products across 3 categories (Dairy, Bakery, Beverages), 15 orders (July to September 2026), 27 order items.
Two things are on purpose: customer *Farid Hassan* has no orders and product *Greek Yogurt 500g* never sold, so the LEFT JOIN queries have something real to find.

## How to run it

1. Connect to Oracle and run `01_setup.sql` (creates the tables, inserts the data, commits).
2. Run `02_queries.sql` (or paste one query at a time) to reproduce the results below.

If you re-run setup, drop the tables first: `DROP TABLE order_items; DROP TABLE orders; DROP TABLE products; DROP TABLE customers;`

## Business scenario

Sunrise Supermarket sells products to customers, who place orders containing one or more items. Management wants to know who the customers are, what they buy, and how sales are trending. Revenue in every query = `price * quantity`. Total revenue in the sample data is **150.95**.

---

## Queries, results, and interpretation

### Q1. INNER JOIN: full order detail
Joins all four tables so each row is one product line on one order, with the customer and line total.

```sql
SELECT o.order_id,
       TO_CHAR(o.order_date, 'YYYY-MM-DD') AS order_date,
       c.customer_name, p.product_name, oi.quantity,
       p.price * oi.quantity AS line_total
FROM   orders o
JOIN   customers   c  ON c.customer_id = o.customer_id
JOIN   order_items oi ON oi.order_id   = o.order_id
JOIN   products    p  ON p.product_id  = oi.product_id
ORDER BY o.order_id, p.product_name;
```

**Result (27 rows, first 8 shown):**

| order_id | order_date | customer_name | product_name | quantity | line_total |
|---|---|---|---|---|---|
| 1001 | 2026-07-03 | Amina Yusuf | Sourdough Loaf | 1 | 2.80 |
| 1001 | 2026-07-03 | Amina Yusuf | Whole Milk 1L | 2 | 3.00 |
| 1002 | 2026-07-10 | Brian Okoye | Croissant 4-Pack | 2 | 7.00 |
| 1002 | 2026-07-10 | Brian Okoye | Ground Coffee 250g | 1 | 6.75 |
| 1003 | 2026-07-18 | Amina Yusuf | Orange Juice 1L | 3 | 7.20 |
| 1004 | 2026-07-25 | Chloe Martin | Cheddar Cheese 200g | 1 | 3.20 |
| 1004 | 2026-07-25 | Chloe Martin | Sparkling Water 6-Pack | 2 | 8.20 |
| 1005 | 2026-08-02 | David Kim | Sourdough Loaf | 2 | 5.60 |

**Business interpretation:** This is the base view every other report builds on. It confirms all 27 order lines link cleanly to a customer and product, and shows baskets are small (1 to 3 items per order).

### Q2. LEFT JOIN: customers who never ordered
Keeps every customer and filters to those with no matching order.

```sql
SELECT c.customer_id, c.customer_name, c.city
FROM   customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
WHERE  o.order_id IS NULL;
```

| customer_id | customer_name | city |
|---|---|---|
| 6 | Farid Hassan | Lakeside |

**Business interpretation:** One of six registered customers (about 17%) has never bought anything. This is a ready-made target for a welcome discount or reactivation email.

### Q3. LEFT JOIN: products that never sold
Same anti-join pattern, starting from products.

```sql
SELECT p.product_id, p.product_name, p.category, p.price
FROM   products p
LEFT JOIN order_items oi ON oi.product_id = p.product_id
WHERE  oi.order_item_id IS NULL;
```

| product_id | product_name | category | price |
|---|---|---|---|
| 108 | Greek Yogurt 500g | Dairy | 2.95 |

**Business interpretation:** Greek Yogurt has zero sales in three months. Management should check shelf placement or pricing, or consider dropping it. It also means Dairy's numbers come from only two products.

### Q4. CTE: customer lifetime value and segments
A CTE totals orders and spend per customer, then the outer query labels each one High (30+), Medium (20 to 30), or Low value using CASE.

```sql
WITH customer_spend AS (
  SELECT c.customer_id, c.customer_name,
         COUNT(DISTINCT o.order_id) AS total_orders,
         SUM(p.price * oi.quantity) AS total_spent
  FROM   customers c
  JOIN   orders o       ON o.customer_id = c.customer_id
  JOIN   order_items oi ON oi.order_id   = o.order_id
  JOIN   products p     ON p.product_id  = oi.product_id
  GROUP BY c.customer_id, c.customer_name
)
SELECT customer_name, total_orders, total_spent,
       CASE WHEN total_spent >= 30 THEN 'High value'
            WHEN total_spent >= 20 THEN 'Medium value'
            ELSE 'Low value' END AS segment
FROM   customer_spend
ORDER BY total_spent DESC;
```

| customer_name | total_orders | total_spent | segment |
|---|---|---|---|
| Brian Okoye | 3 | 39.95 | High value |
| Amina Yusuf | 4 | 35.90 | High value |
| David Kim | 3 | 31.85 | High value |
| Chloe Martin | 3 | 28.95 | Medium value |
| Elena Rossi | 2 | 14.30 | Low value |

**Business interpretation:** Three customers drive most of the money (107.70 of 150.95, about 71%). Amina orders most often but Brian spends the most, so Brian has the bigger baskets. Elena is the clear upsell target.

### Q5. CTE: monthly revenue
A CTE aggregates revenue and order count by month.

```sql
WITH monthly_sales AS (
  SELECT TO_CHAR(o.order_date, 'YYYY-MM') AS sales_month,
         COUNT(DISTINCT o.order_id) AS orders_placed,
         SUM(p.price * oi.quantity) AS revenue
  FROM   orders o
  JOIN   order_items oi ON oi.order_id  = o.order_id
  JOIN   products p     ON p.product_id = oi.product_id
  GROUP BY TO_CHAR(o.order_date, 'YYYY-MM')
)
SELECT sales_month, orders_placed, revenue
FROM   monthly_sales
ORDER BY sales_month;
```

| sales_month | orders_placed | revenue |
|---|---|---|
| 2026-07 | 4 | 38.15 |
| 2026-08 | 5 | 52.30 |
| 2026-09 | 6 | 60.50 |

**Business interpretation:** Orders and revenue rise every month. September has 6 orders vs 4 in July, so growth is coming from more orders, not just bigger ones. (September data runs only to the 18th, so the month is not complete.)

### Q6. Window function: RANK products within each category
`RANK() OVER (PARTITION BY category ORDER BY revenue DESC)` ranks products against others in the same category only.
 
```sql
WITH product_revenue AS (
  SELECT p.category, p.product_name,
         SUM(oi.quantity) AS units_sold,
         SUM(p.price * oi.quantity) AS revenue
  FROM   products p
  JOIN   order_items oi ON oi.product_id = p.product_id
  GROUP BY p.category, p.product_name
)
SELECT category, product_name, units_sold, revenue,
       RANK() OVER (PARTITION BY category ORDER BY revenue DESC) AS rank_in_category
FROM   product_revenue
ORDER BY category, rank_in_category;
```

| category | product_name | units_sold | revenue | rank_in_category |
|---|---|---|---|---|
| Bakery | Croissant 4-Pack | 7 | 24.50 | 1 |
| Bakery | Sourdough Loaf | 7 | 19.60 | 2 |
| Beverages | Ground Coffee 250g | 5 | 33.75 | 1 |
| Beverages | Sparkling Water 6-Pack | 6 | 24.60 | 2 |
| Beverages | Orange Juice 1L | 8 | 19.20 | 3 |
| Dairy | Whole Milk 1L | 11 | 16.50 | 1 |
| Dairy | Cheddar Cheese 200g | 4 | 12.80 | 2 |

**Business interpretation:** Units and revenue tell different stories. Whole Milk sells the most units (11) but is a low-price item, while Ground Coffee sells only 5 units and is the top earner (33.75). Orange Juice has the most units in Beverages but ranks last on revenue. Stock decisions should look at both.

### Q7. Window function: LAG for month-over-month growth
`LAG(revenue)` pulls the previous month's revenue onto the current row so growth can be calculated in one pass.

```sql
WITH monthly_sales AS (
  SELECT TO_CHAR(o.order_date, 'YYYY-MM') AS sales_month,
         SUM(p.price * oi.quantity) AS revenue
  FROM   orders o
  JOIN   order_items oi ON oi.order_id  = o.order_id
  JOIN   products p     ON p.product_id = oi.product_id
  GROUP BY TO_CHAR(o.order_date, 'YYYY-MM')
)
SELECT sales_month, revenue,
       LAG(revenue) OVER (ORDER BY sales_month) AS prev_month_revenue,
       ROUND((revenue - LAG(revenue) OVER (ORDER BY sales_month))
             / LAG(revenue) OVER (ORDER BY sales_month) * 100, 1) AS growth_pct
FROM   monthly_sales
ORDER BY sales_month;
```

| sales_month | revenue | prev_month_revenue | growth_pct |
|---|---|---|---|
| 2026-07 | 38.15 | NULL | NULL |
| 2026-08 | 52.30 | 38.15 | 37.1 |
| 2026-09 | 60.50 | 52.30 | 15.7 |

**Business interpretation:** Revenue grew 37.1% from July to August and another 15.7% in September, even with September unfinished. Growth is slowing in percentage terms but the trend is clearly upward. July has no previous month, so NULL is correct.

### Q8. Window functions: running total and order number per customer
`SUM() OVER (PARTITION BY customer ORDER BY date)` gives a cumulative spend, and `ROW_NUMBER()` numbers each customer's orders in sequence.

```sql
WITH order_totals AS (
  SELECT o.order_id, o.customer_id, o.order_date,
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
```

| customer_name | order_date | order_total | running_total | order_number |
|---|---|---|---|---|
| Amina Yusuf | 2026-07-03 | 5.80 | 5.80 | 1 |
| Amina Yusuf | 2026-07-18 | 7.20 | 13.00 | 2 |
| Amina Yusuf | 2026-08-21 | 10.50 | 23.50 | 3 |
| Amina Yusuf | 2026-09-05 | 12.40 | 35.90 | 4 |
| Brian Okoye | 2026-07-10 | 13.75 | 13.75 | 1 |
| Brian Okoye | 2026-08-09 | 13.50 | 27.25 | 2 |
| Brian Okoye | 2026-09-12 | 12.70 | 39.95 | 3 |
| Chloe Martin | 2026-07-25 | 11.40 | 11.40 | 1 |
| Chloe Martin | 2026-08-28 | 8.40 | 19.80 | 2 |
| Chloe Martin | 2026-09-15 | 9.15 | 28.95 | 3 |
| David Kim | 2026-08-02 | 11.60 | 11.60 | 1 |
| David Kim | 2026-09-01 | 9.75 | 21.35 | 2 |
| David Kim | 2026-09-18 | 10.50 | 31.85 | 3 |
| Elena Rossi | 2026-08-14 | 8.30 | 8.30 | 1 |
| Elena Rossi | 2026-09-09 | 6.00 | 14.30 | 2 |

**Business interpretation:** Amina's order sizes grow every time (5.80 to 12.40), a sign of a loyal customer who is trusting the store with more of her shopping. Elena's second order is smaller than her first (8.30 to 6.00), an early warning worth watching. The final running totals match Q4, which is a good consistency check.

### Q9. Window function: category share of total revenue
`SUM(revenue) OVER ()` puts the grand total on every row so each category's percentage can be calculated without a second query.

```sql
WITH category_revenue AS (
  SELECT p.category, SUM(p.price * oi.quantity) AS revenue
  FROM   products p
  JOIN   order_items oi ON oi.product_id = p.product_id
  GROUP BY p.category
)
SELECT category, revenue,
       ROUND(revenue / SUM(revenue) OVER () * 100, 1) AS pct_of_total
FROM   category_revenue
ORDER BY revenue DESC;
```

| category | revenue | pct_of_total |
|---|---|---|
| Beverages | 77.55 | 51.4 |
| Bakery | 44.10 | 29.2 |
| Dairy | 29.30 | 19.4 |

**Business interpretation:** Beverages bring in over half of all revenue, driven by Ground Coffee. Dairy is the weakest category, which fits with Greek Yogurt not selling at all (Q3). A Dairy promotion would be the obvious lever.

---

## Challenges and resolutions

1. **Inflated order counts after joining `order_items`.** Joining orders to items repeats each order once per item, so `COUNT(order_id)` overstated the number of orders. *Fix:* used `COUNT(DISTINCT o.order_id)` in Q4 and Q5.
2. **Finding rows with no match.** An INNER JOIN silently drops customers and products with no orders. *Fix:* used LEFT JOIN plus `WHERE ... IS NULL` on the right-hand key (Q2, Q3).
3. **Top-N per group without `LIMIT`.** Oracle has no `LIMIT`, and a plain `ORDER BY` can't rank inside each category. *Fix:* used `RANK() OVER (PARTITION BY category ...)` inside a CTE (Q6).
4. **Running total ties.** Ordering the window by `order_date` alone could give unstable results if a customer placed two orders on one day. *Fix:* added `order_id` as a tiebreaker in Q8.
5. **Repeating the monthly logic.** Q5 and Q7 need the same monthly totals. *Fix:* put the aggregation in a CTE so the window function in Q7 sits on top of clean, already-grouped data.
6. **Dates in Oracle.** Date values had to be inserted with `TO_DATE(..., 'YYYY-MM-DD')` to avoid depending on the session's default date format.

## Files

- `README.md` - this file
- `01_setup.sql` - table creation, sample data, COMMIT
- `02_queries.sql` - all nine queries
