# Retail Sales & Customer Intelligence Using PostgreSQL

A SQL portfolio project that explores retail sales and customer behaviour using PostgreSQL. The project uses two related tables — `customers` and `orders` — and answers 46 business questions, progressing from basic filtering to joins, CTEs, window functions, views, PL/pgSQL and management reporting.

## Project objectives

- Create a PostgreSQL database and relational tables with primary keys, a foreign key and CHECK constraints.
- Filter, sort, group and summarise retail data.
- Use INNER JOIN and LEFT JOIN for customer and order analysis.
- Solve multi-step questions with subqueries and Common Table Expressions (CTEs).
- Apply `RANK`, `ROW_NUMBER`, `DENSE_RANK`, `LAG` and `NTILE`.
- Create a monthly reporting view and a PL/pgSQL customer-revenue function.
- Translate query results into practical business insights.

## Repository structure

```text
retail-sales-sql-complete/
├── README.md
├── schema.sql
├── queries.sql
├── insights.md
└── screenshots/
```

## Database design

The project uses the default PostgreSQL `public` schema; a separate custom schema is not required.

### `customers`

| Column | Type | Description |
|---|---|---|
| `customer_id` | INTEGER, primary key | Unique customer number |
| `customer_name` | VARCHAR(100), NOT NULL | Customer's fictional full name |
| `gender` | VARCHAR(10) | Male or Female |
| `city` | VARCHAR(50) | Kenyan town |
| `registration_date` | DATE | Customer registration date |
| `customer_segment` | VARCHAR(20) | Retail, Corporate or VIP |

### `orders`

| Column | Type | Description |
|---|---|---|
| `order_id` | INTEGER, primary key | Unique order number |
| `customer_id` | INTEGER, foreign key | References `customers.customer_id` |
| `order_date` | DATE | Order date |
| `product_name` | VARCHAR(100) | Product name |
| `product_category` | VARCHAR(50) | Product category |
| `quantity` | INTEGER | Number of units; greater than zero |
| `unit_price` | NUMERIC(12,2) | Selling price per unit before discount, KSh |
| `cost_price` | NUMERIC(12,2) | Company cost per unit, KSh |
| `discount` | NUMERIC(5,2) | Discount percentage from 0 to 100 |
| `payment_method` | VARCHAR(30) | M-Pesa, Cash, Card or Bank Transfer |
| `order_status` | VARCHAR(20) | Completed, Pending or Cancelled |

The relationship is one customer to many orders. `orders.customer_id` references `customers.customer_id`.

## Business rules used in every answer

| Measure / rule | Definition |
|---|---|
| Revenue | `quantity * unit_price * (1 - discount / 100)` |
| Cost | `quantity * cost_price` |
| Profit | `revenue - cost` |
| Profit margin % | `profit / NULLIF(revenue, 0) * 100` |
| Money calculations | Completed orders only, unless a question says otherwise |
| Order counts | Include all orders, regardless of status |
| Customer counts | Count distinct customers |
| Today | Latest `order_date` in the data (`MAX(order_date)`), not the computer's date |
| Month | Calendar year and month using `DATE_TRUNC('month', order_date)` |
| Discount | A percentage: `10` means 10% off |

## Requirements

- PostgreSQL (the project was written for PostgreSQL).
- DBeaver Community or another PostgreSQL client.
- The supplied project data-loading scripts for local data population. They are not part of this submission repository.

## Set up using DBeaver

These steps assume PostgreSQL is already installed and your PostgreSQL connection is configured in DBeaver.

### 1. Create the project database

1. Open DBeaver and connect to your PostgreSQL server.
2. In Database Navigator, select the connection that currently connects to the `postgres` maintenance database.
3. Open **SQL Editor → New SQL Script**.
4. Run this statement once:

   ```sql
   CREATE DATABASE retail_analytics;
   ```

5. Refresh the connection. In DBeaver, create or edit a connection to the same server and set **Database** to `retail_analytics`, or use a separate connection for that database.
6. Connect to `retail_analytics` before continuing.

If the database already exists, do not create it again; simply connect to it.

### 2. Create the tables

1. With the `retail_analytics` connection selected, open `schema.sql`.
2. Execute the complete SQL script in DBeaver (the **Execute SQL Script** action).
3. Refresh the database navigator.
4. Expand **Schemas → public → Tables**. You should see `customers` and `orders`.

The schema file creates the tables and indexes. It does not insert customer or order data.

### 3. Load the supplied data locally

The project brief provides separate data-loading scripts. Keep these files locally; they do not need to be committed to this repository.

Run them in this order, connected to `retail_analytics`:

1. `03_insert_customers.sql`
2. `04_insert_orders.sql`

The customer rows must be loaded before the order rows because `orders.customer_id` has a foreign-key relationship to `customers.customer_id`.

If you have the project's `05_verify_data.sql`, run it after loading the data. The supplied project describes 150 customers and 800 orders, with order dates from January 2025 through September 2026. Confirm these checks against your loaded database before relying on the insights.

### 4. Run the analysis queries

1. Open `queries.sql` in DBeaver.
2. Confirm the active connection is `retail_analytics`.
3. Use **Execute SQL Script** to run the file. For a single selected statement, use DBeaver's **Execute SQL Statement** action.
4. The file is organised into Sections A–F and labels every answer from `-- Q1` through `-- Q46`.
5. Q43 creates the `monthly_sales_summary` view. Q44 creates the `customer_completed_revenue(integer)` function. Q45 performs percentile-based customer segmentation. Q46 contains four management-report result sets.

## Questions covered

| Section | Questions | Topics |
|---|---:|---|
| A — SQL fundamentals | Q1–Q10 | SELECT, WHERE, DISTINCT, ORDER BY, LIMIT, pattern matching |
| B — Aggregation and grouping | Q11–Q20 | COUNT, SUM, AVG, MIN, MAX, GROUP BY, HAVING |
| C — Joins and customer analytics | Q21–Q28 | INNER JOIN, LEFT JOIN, customer spending and segments |
| D — Subqueries and CTEs | Q29–Q34 | Nested queries, WITH, date calculations |
| E — Window functions | Q35–Q42 | RANK, ROW_NUMBER, DENSE_RANK, SUM OVER, LAG, NTILE |
| F — Advanced business intelligence | Q43–Q46 | Views, PL/pgSQL, CASE, reporting |

## Business insights

The `insights.md` file contains seven management-oriented findings. Each includes:
- The finding and its query reference.
- Why it matters to the business.
- A practical recommendation.

The insights are based on the supplied project INSERT data. Re-run the referenced queries in your own database to verify that the figures match before submission.

## Troubleshooting

| Problem | What to check |
|---|---|
| `database "retail_analytics" does not exist` | Create the database while connected to `postgres`, then connect to `retail_analytics`. |
| `relation "customers" does not exist` | Confirm you are connected to `retail_analytics` and have run `schema.sql`. |
| Foreign-key error while inserting orders | Run the customer insert script before the order insert script. |
| `database` or `schema` confusion | `retail_analytics` is the database; `public` is its default schema; `customers` and `orders` are tables. |
| Revenue differs from another result | Check that only Completed orders are used and discount is treated as a percentage. |
| Percentage is unexpectedly zero | Use decimal arithmetic such as `100.0`, not integer division. |
| DBeaver runs only one statement | Use **Execute SQL Script** for the full file, or select one statement and execute that statement. |

## Notes

- The SQL in this repository is written for PostgreSQL.
- The queries have been prepared from the supplied project schema, rules and dataset description. They should be executed against your local database and checked before submission.
- The `screenshots/` directory is not populated by these files; add your own DBeaver screenshots.
