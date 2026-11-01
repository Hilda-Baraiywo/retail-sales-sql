-- Retail Sales & Customer Intelligence Using PostgreSQL
-- Answers Q1-Q46. Run in DBeaver while connected to retail_analytics, after loading data.
-- Business rules: monetary measures use Completed orders only; order counts include all statuses.
-- Revenue = quantity * unit_price * (1 - discount / 100.0)
-- Cost = quantity * cost_price; Profit = revenue - cost.

-- SECTION A — SQL FUNDAMENTALS (Q1-Q10)

-- Q1: Retrieve all customer records
SELECT * FROM customers;

-- Q2: Display customer names, cities, and segments
SELECT customer_name, city, customer_segment
FROM customers;

-- Q3: Find customers living in Nairobi
SELECT *
FROM customers
WHERE city = 'Nairobi';

-- Q4: Find customers registered after January 1, 2025
SELECT *
FROM customers
WHERE registration_date > DATE '2025-01-01';

-- Q5: Display all unique customer cities
SELECT DISTINCT city
FROM customers
ORDER BY city;

-- Q6: Retrieve the 10 most recent orders
SELECT *
FROM orders
ORDER BY order_date DESC, order_id DESC
LIMIT 10;

-- Q7: Find orders with unit prices above KSh 10,000
SELECT *
FROM orders
WHERE unit_price > 10000
ORDER BY unit_price DESC;

-- Q8: Find customers whose names start with A
SELECT *
FROM customers
WHERE customer_name ILIKE 'A%';

-- Q9: Retrieve orders with quantities between 2 and 5 (inclusive)
SELECT *
FROM orders
WHERE quantity BETWEEN 2 AND 5
ORDER BY quantity, order_date;

-- Q10: Find orders paid through M-Pesa
SELECT *
FROM orders
WHERE payment_method = 'M-Pesa';

-- SECTION B — AGGREGATION AND GROUPING (Q11-Q20)

-- Q11: Count all customers
SELECT COUNT(*) AS total_customers
FROM customers;

-- Q12: Count all orders, regardless of status
SELECT COUNT(*) AS total_orders
FROM orders;

-- Q13: Calculate completed-order revenue
SELECT ROUND(
           SUM(quantity * unit_price * (1 - discount / 100.0)), 2
       ) AS completed_revenue
FROM orders
WHERE order_status = 'Completed';

-- Q14: Calculate the average completed-order value
-- First calculate each completed order's discounted total, then average the orders.
SELECT ROUND(AVG(order_value), 2) AS average_completed_order_value
FROM (
    SELECT order_id,
           SUM(quantity * unit_price * (1 - discount / 100.0)) AS order_value
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY order_id
) AS completed_order_values;

-- Q15: Find the highest and lowest product prices
SELECT MAX(unit_price) AS highest_unit_price,
       MIN(unit_price) AS lowest_unit_price
FROM orders;

-- Q16: Calculate revenue by product category
SELECT product_category,
       ROUND(SUM(quantity * unit_price * (1 - discount / 100.0)), 2) AS revenue
FROM orders
WHERE order_status = 'Completed'
GROUP BY product_category
ORDER BY revenue DESC;

-- Q17: Count customers by city
SELECT city, COUNT(DISTINCT customer_id) AS customer_count
FROM customers
GROUP BY city
ORDER BY customer_count DESC, city;

-- Q18: Calculate quantity sold by product (completed orders only)
SELECT product_name,
       SUM(quantity) AS units_sold
FROM orders
WHERE order_status = 'Completed'
GROUP BY product_name
ORDER BY units_sold DESC, product_name;

-- Q19: Find categories generating more than KSh 100,000 in revenue
SELECT product_category,
       ROUND(SUM(quantity * unit_price * (1 - discount / 100.0)), 2) AS revenue
FROM orders
WHERE order_status = 'Completed'
GROUP BY product_category
HAVING SUM(quantity * unit_price * (1 - discount / 100.0)) > 100000
ORDER BY revenue DESC;

-- Q20: Calculate the percentage of cancelled orders
SELECT ROUND(
           100.0 * COUNT(*) FILTER (WHERE order_status = 'Cancelled')
           / NULLIF(COUNT(*), 0), 2
       ) AS cancelled_order_percentage
FROM orders;

-- SECTION C — JOINS AND CUSTOMER ANALYTICS (Q21-Q28)

-- Q21: Display orders with customer names and cities
SELECT o.order_id, o.order_date, o.product_name, o.quantity,
       o.order_status, c.customer_name, c.city
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
ORDER BY o.order_date, o.order_id;

-- Q22: Calculate total completed-order spending by customer
SELECT c.customer_id, c.customer_name,
       ROUND(COALESCE(SUM(o.quantity * o.unit_price *
                         (1 - o.discount / 100.0)), 0), 2) AS total_spending
FROM customers c
LEFT JOIN orders o
       ON o.customer_id = c.customer_id
      AND o.order_status = 'Completed'
GROUP BY c.customer_id, c.customer_name
ORDER BY total_spending DESC, c.customer_id;

-- Q23: Identify customers who have never ordered (any status)
SELECT c.customer_id, c.customer_name, c.city
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
WHERE o.order_id IS NULL
ORDER BY c.customer_id;

-- Q24: Find the 10 highest-spending customers (completed orders only)
SELECT c.customer_id, c.customer_name,
       ROUND(SUM(o.quantity * o.unit_price *
                 (1 - o.discount / 100.0)), 2) AS total_spending
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
WHERE o.order_status = 'Completed'
GROUP BY c.customer_id, c.customer_name
ORDER BY total_spending DESC
LIMIT 10;

-- Q25: Calculate revenue by customer city
SELECT c.city,
       ROUND(SUM(o.quantity * o.unit_price *
                 (1 - o.discount / 100.0)), 2) AS revenue
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
WHERE o.order_status = 'Completed'
GROUP BY c.city
ORDER BY revenue DESC;

-- Q26: Identify customers with more than five orders (all statuses)
SELECT c.customer_id, c.customer_name,
       COUNT(o.order_id) AS order_count
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(o.order_id) > 5
ORDER BY order_count DESC, c.customer_id;

-- Q27: Calculate average customer spending by segment
-- Definition: average of each customer's completed-order total; customers with no
-- completed orders are included with spending of zero.
WITH customer_spending AS (
    SELECT c.customer_id, c.customer_segment,
           COALESCE(SUM(o.quantity * o.unit_price *
                        (1 - o.discount / 100.0)), 0) AS total_spending
    FROM customers c
    LEFT JOIN orders o
           ON o.customer_id = c.customer_id
          AND o.order_status = 'Completed'
    GROUP BY c.customer_id, c.customer_segment
)
SELECT customer_segment,
       ROUND(AVG(total_spending), 2) AS average_customer_spending
FROM customer_spending
GROUP BY customer_segment
ORDER BY average_customer_spending DESC;

-- Q28: Identify the most popular category among VIP customers
-- Popularity is defined as total units sold, not number of order rows.
-- RANK returns all categories if the highest unit total is tied.
WITH vip_category_units AS (
    SELECT o.product_category,
           SUM(o.quantity) AS units_sold
    FROM customers c
    JOIN orders o ON o.customer_id = c.customer_id
    WHERE c.customer_segment = 'VIP'
      AND o.order_status = 'Completed'
    GROUP BY o.product_category
),
ranked_vip_categories AS (
    SELECT product_category, units_sold,
           RANK() OVER (ORDER BY units_sold DESC) AS category_rank
    FROM vip_category_units
)
SELECT product_category, units_sold
FROM ranked_vip_categories
WHERE category_rank = 1
ORDER BY product_category;

-- SECTION D — SUBQUERIES AND CTEs (Q29-Q34)

-- Q29: Find customers spending above the average total spending per purchasing customer
WITH customer_totals AS (
    SELECT customer_id,
           SUM(quantity * unit_price * (1 - discount / 100.0)) AS total_spending
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY customer_id
)
SELECT c.customer_id, c.customer_name,
       ROUND(ct.total_spending, 2) AS total_spending
FROM customer_totals ct
JOIN customers c ON c.customer_id = ct.customer_id
WHERE ct.total_spending > (SELECT AVG(total_spending) FROM customer_totals)
ORDER BY ct.total_spending DESC;

-- Q30: Find products priced above the overall average unit price
SELECT product_name,
       MAX(unit_price) AS unit_price
FROM orders
GROUP BY product_name
HAVING MAX(unit_price) > (SELECT AVG(unit_price) FROM orders)
ORDER BY unit_price DESC, product_name;

-- Q31: Use a CTE to identify the three highest-revenue months
WITH monthly_revenue AS (
    SELECT DATE_TRUNC('month', order_date)::date AS sales_month,
           SUM(quantity * unit_price * (1 - discount / 100.0)) AS revenue
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY DATE_TRUNC('month', order_date)
)
SELECT sales_month, ROUND(revenue, 2) AS revenue
FROM monthly_revenue
ORDER BY revenue DESC
LIMIT 3;

-- Q32: Find customers purchasing from at least three categories
SELECT c.customer_id, c.customer_name,
       COUNT(DISTINCT o.product_category) AS category_count
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
WHERE o.order_status = 'Completed'
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(DISTINCT o.product_category) >= 3
ORDER BY category_count DESC, c.customer_id;

-- Q33: Use a CTE to calculate category revenue, cost, profit, and profit margin
WITH category_totals AS (
    SELECT product_category,
           SUM(quantity * unit_price * (1 - discount / 100.0)) AS revenue,
           SUM(quantity * cost_price) AS cost
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY product_category
)
SELECT product_category,
       ROUND(revenue, 2) AS revenue,
       ROUND(cost, 2) AS cost,
       ROUND(revenue - cost, 2) AS profit,
       ROUND(100.0 * (revenue - cost) / NULLIF(revenue, 0), 2) AS profit_margin_pct
FROM category_totals
ORDER BY profit DESC;

-- Q34: Find customers whose latest completed order is more than 90 days
-- before the latest order date anywhere in the dataset.
WITH latest_dataset_date AS (
    SELECT MAX(order_date) AS latest_date
    FROM orders
),
customer_last_completed AS (
    SELECT customer_id, MAX(order_date) AS last_completed_date
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY customer_id
)
SELECT c.customer_id, c.customer_name,
       cl.last_completed_date,
       d.latest_date,
       d.latest_date - cl.last_completed_date AS days_since_last_completed_order
FROM customer_last_completed cl
JOIN customers c ON c.customer_id = cl.customer_id
CROSS JOIN latest_dataset_date d
WHERE d.latest_date - cl.last_completed_date > 90
ORDER BY days_since_last_completed_order DESC;

-- SECTION E — WINDOW FUNCTIONS (Q35-Q42)

-- Q35: Rank customers by completed-order spending using RANK()
WITH customer_totals AS (
    SELECT c.customer_id, c.customer_name,
           COALESCE(SUM(o.quantity * o.unit_price *
                        (1 - o.discount / 100.0)), 0) AS total_spending
    FROM customers c
    LEFT JOIN orders o
           ON o.customer_id = c.customer_id
          AND o.order_status = 'Completed'
    GROUP BY c.customer_id, c.customer_name
)
SELECT customer_id, customer_name,
       ROUND(total_spending, 2) AS total_spending,
       RANK() OVER (ORDER BY total_spending DESC) AS spending_rank
FROM customer_totals
ORDER BY spending_rank, customer_id;

-- Q36: Number each customer's orders by recency using ROW_NUMBER()
SELECT customer_id, order_id, order_date, order_status,
       ROW_NUMBER() OVER (
           PARTITION BY customer_id
           ORDER BY order_date DESC, order_id DESC
       ) AS recency_number
FROM orders
ORDER BY customer_id, recency_number;

-- Q37: Rank products within categories using DENSE_RANK()
-- Ranking is based on completed-order revenue generated by each product.
WITH product_revenue AS (
    SELECT product_category, product_name,
           SUM(quantity * unit_price * (1 - discount / 100.0)) AS revenue
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY product_category, product_name
)
SELECT product_category, product_name,
       ROUND(revenue, 2) AS revenue,
       DENSE_RANK() OVER (
           PARTITION BY product_category
           ORDER BY revenue DESC
       ) AS category_rank
FROM product_revenue
ORDER BY product_category, category_rank, product_name;

-- Q38: Calculate cumulative monthly revenue
WITH monthly AS (
    SELECT DATE_TRUNC('month', order_date)::date AS sales_month,
           SUM(quantity * unit_price * (1 - discount / 100.0)) AS revenue
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY DATE_TRUNC('month', order_date)
)
SELECT sales_month,
       ROUND(revenue, 2) AS monthly_revenue,
       ROUND(SUM(revenue) OVER (ORDER BY sales_month), 2) AS cumulative_revenue
FROM monthly
ORDER BY sales_month;

-- Q39: Compare monthly revenue using LAG()
WITH monthly AS (
    SELECT DATE_TRUNC('month', order_date)::date AS sales_month,
           SUM(quantity * unit_price * (1 - discount / 100.0)) AS revenue
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY DATE_TRUNC('month', order_date)
)
SELECT sales_month,
       ROUND(revenue, 2) AS monthly_revenue,
       ROUND(LAG(revenue) OVER (ORDER BY sales_month), 2) AS previous_month_revenue
FROM monthly
ORDER BY sales_month;

-- Q40: Calculate month-over-month revenue growth (%)
WITH monthly AS (
    SELECT DATE_TRUNC('month', order_date)::date AS sales_month,
           SUM(quantity * unit_price * (1 - discount / 100.0)) AS revenue
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY DATE_TRUNC('month', order_date)
),
with_previous AS (
    SELECT sales_month, revenue,
           LAG(revenue) OVER (ORDER BY sales_month) AS previous_revenue
    FROM monthly
)
SELECT sales_month,
       ROUND(revenue, 2) AS monthly_revenue,
       ROUND(previous_revenue, 2) AS previous_month_revenue,
       ROUND(100.0 * (revenue - previous_revenue) /
             NULLIF(previous_revenue, 0), 2) AS month_over_month_growth_pct
FROM with_previous
ORDER BY sales_month;

-- Q41: Divide customers into four spending groups using NTILE(4)
WITH customer_totals AS (
    SELECT c.customer_id, c.customer_name,
           COALESCE(SUM(o.quantity * o.unit_price *
                        (1 - o.discount / 100.0)), 0) AS total_spending
    FROM customers c
    LEFT JOIN orders o
           ON o.customer_id = c.customer_id
          AND o.order_status = 'Completed'
    GROUP BY c.customer_id, c.customer_name
)
SELECT customer_id, customer_name,
       ROUND(total_spending, 2) AS total_spending,
       NTILE(4) OVER (ORDER BY total_spending DESC, customer_id) AS spending_quartile
FROM customer_totals
ORDER BY spending_quartile, total_spending DESC;

-- Q42: Calculate each category's share of total revenue using a window function
WITH category_revenue AS (
    SELECT product_category,
           SUM(quantity * unit_price * (1 - discount / 100.0)) AS revenue
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY product_category
)
SELECT product_category,
       ROUND(revenue, 2) AS revenue,
       ROUND(100.0 * revenue / NULLIF(SUM(revenue) OVER (), 0), 2) AS revenue_share_pct
FROM category_revenue
ORDER BY revenue DESC;

-- SECTION F — ADVANCED BUSINESS INTELLIGENCE (Q43-Q46)

-- Q43: Create and query the monthly_sales_summary view.
-- Order count includes every status; financial measures include Completed only.
CREATE OR REPLACE VIEW monthly_sales_summary AS
SELECT DATE_TRUNC('month', order_date)::date AS month,
       COUNT(*) AS orders,
       ROUND(COALESCE(SUM(quantity * unit_price *
             (1 - discount / 100.0)) FILTER (WHERE order_status = 'Completed'), 0), 2) AS revenue,
       ROUND(COALESCE(SUM(quantity * cost_price)
             FILTER (WHERE order_status = 'Completed'), 0), 2) AS cost,
       ROUND(COALESCE(SUM(quantity * unit_price * (1 - discount / 100.0)
                         - quantity * cost_price)
             FILTER (WHERE order_status = 'Completed'), 0), 2) AS profit
FROM orders
GROUP BY DATE_TRUNC('month', order_date);

SELECT *
FROM monthly_sales_summary
ORDER BY month;

-- Q44: Create a function returning completed-order revenue for a customer ID.
-- COALESCE ensures customers with no completed orders (or nonexistent IDs) return zero.
CREATE OR REPLACE FUNCTION customer_completed_revenue(p_customer_id INTEGER)
RETURNS NUMERIC(14,2)
LANGUAGE plpgsql
AS $$
DECLARE
    v_revenue NUMERIC(14,2);
BEGIN
    SELECT COALESCE(
               SUM(quantity * unit_price * (1 - discount / 100.0)), 0
           )
    INTO v_revenue
    FROM orders
    WHERE customer_id = p_customer_id
      AND order_status = 'Completed';

    RETURN v_revenue;
END;
$$;

-- Example: a real customer ID, and a nonexistent ID
SELECT customer_completed_revenue(1) AS customer_1_revenue;
SELECT customer_completed_revenue(-1) AS nonexistent_customer_revenue;

-- Q45: Segment customers into High, Medium and Low Value.
-- Thresholds are the 75th and 25th percentiles of customer completed-order spend.
-- All customers, including zero-spend customers, are included in the percentile population.
WITH customer_totals AS (
    SELECT c.customer_id, c.customer_name,
           COALESCE(SUM(o.quantity * o.unit_price *
                        (1 - o.discount / 100.0)), 0) AS total_spending
    FROM customers c
    LEFT JOIN orders o
           ON o.customer_id = c.customer_id
          AND o.order_status = 'Completed'
    GROUP BY c.customer_id, c.customer_name
),
thresholds AS (
    SELECT
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY total_spending) AS high_threshold,
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY total_spending) AS medium_threshold
    FROM customer_totals
)
SELECT ct.customer_id, ct.customer_name,
       ROUND(ct.total_spending, 2) AS total_spending,
       CASE
           WHEN ct.total_spending >= t.high_threshold THEN 'High Value'
           WHEN ct.total_spending >= t.medium_threshold THEN 'Medium Value'
           ELSE 'Low Value'
       END AS customer_value_segment
FROM customer_totals ct
CROSS JOIN thresholds t
ORDER BY ct.total_spending DESC;

-- Q46: Management report — top five customers, top five products,
-- most profitable category, and lowest-revenue month.
-- Result set 1: top five customers by completed-order revenue
SELECT c.customer_id, c.customer_name,
       ROUND(SUM(o.quantity * o.unit_price *
                 (1 - o.discount / 100.0)), 2) AS revenue
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
WHERE o.order_status = 'Completed'
GROUP BY c.customer_id, c.customer_name
ORDER BY revenue DESC
LIMIT 5;

-- Result set 2: top five products by completed-order revenue
SELECT product_name,
       ROUND(SUM(quantity * unit_price *
                 (1 - discount / 100.0)), 2) AS revenue,
       SUM(quantity) AS units_sold
FROM orders
WHERE order_status = 'Completed'
GROUP BY product_name
ORDER BY revenue DESC
LIMIT 5;

-- Result set 3: most profitable category
WITH category_profit AS (
    SELECT product_category,
           SUM(quantity * unit_price * (1 - discount / 100.0)) AS revenue,
           SUM(quantity * cost_price) AS cost
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY product_category
)
SELECT product_category,
       ROUND(revenue, 2) AS revenue,
       ROUND(cost, 2) AS cost,
       ROUND(revenue - cost, 2) AS profit
FROM category_profit
WHERE revenue - cost = (SELECT MAX(revenue - cost) FROM category_profit)
ORDER BY product_category;

-- Result set 4: lowest-revenue month
SELECT month, orders, revenue, cost, profit
FROM monthly_sales_summary
ORDER BY revenue ASC
LIMIT 1;
