-- Retail Sales & Customer Intelligence
-- schema.sql
-- Run this file while connected to the retail_analytics database.
-- PostgreSQL's default schema is public; no separate schema needs to be created.

CREATE TABLE IF NOT EXISTS public.customers (
    customer_id        INTEGER PRIMARY KEY,
    customer_name      VARCHAR(100) NOT NULL,
    gender             VARCHAR(10) CHECK (gender IN ('Male', 'Female')),
    city               VARCHAR(50),
    registration_date  DATE,
    customer_segment   VARCHAR(20)
                       CHECK (customer_segment IN ('Retail', 'Corporate', 'VIP'))
);

CREATE TABLE IF NOT EXISTS public.orders (
    order_id          INTEGER PRIMARY KEY,
    customer_id       INTEGER NOT NULL,
    order_date        DATE NOT NULL,
    product_name      VARCHAR(100),
    product_category  VARCHAR(50),
    quantity          INTEGER NOT NULL CHECK (quantity > 0),
    unit_price        NUMERIC(12,2) NOT NULL CHECK (unit_price >= 0),
    cost_price        NUMERIC(12,2) NOT NULL CHECK (cost_price >= 0),
    discount          NUMERIC(5,2) NOT NULL DEFAULT 0 CHECK (discount BETWEEN 0 AND 100),
    payment_method    VARCHAR(30) CHECK (payment_method IN ('M-Pesa', 'Cash', 'Card', 'Bank Transfer')),
    order_status      VARCHAR(20) CHECK (order_status IN ('Completed', 'Pending', 'Cancelled')),
    CONSTRAINT fk_orders_customer
        FOREIGN KEY (customer_id)
        REFERENCES public.customers (customer_id)
);

-- Helpful indexes for joins and date-based analysis.
CREATE INDEX IF NOT EXISTS idx_orders_customer
    ON public.orders (customer_id);

CREATE INDEX IF NOT EXISTS idx_orders_date
    ON public.orders (order_date);
