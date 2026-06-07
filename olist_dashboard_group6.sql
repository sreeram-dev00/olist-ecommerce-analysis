-- =============================================================
-- Olist E-Commerce Analytics Dashboard | Group 6 | MySQL
-- =============================================================
-- Dataset: Brazilian E-Commerce Public Dataset by Olist
-- Course: Data Analytics Bootcamp | ExcelR
-- =============================================================


-- =============================================================
-- SECTION 1: DATABASE SETUP
-- =============================================================

CREATE DATABASE IF NOT EXISTS olist_ecommerce;
USE olist_ecommerce;


-- =============================================================
-- SECTION 2: KPI QUERIES (Mandatory)
-- =============================================================

-- KPI 1: Weekday vs Weekend Payment Statistics
-- Compare total orders, total payment value, and avg payment value
-- between weekdays (Mon–Fri) and weekends (Sat–Sun)
SELECT
    CASE
        WHEN DAYOFWEEK(o.order_purchase_timestamp) IN (1, 7) THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,
    COUNT(DISTINCT o.order_id)         AS total_orders,
    ROUND(SUM(p.payment_value), 2)     AS total_payment_value,
    ROUND(AVG(p.payment_value), 2)     AS avg_payment_value
FROM olist_orders_dataset o
JOIN olist_order_payments_dataset p
    ON o.order_id = p.order_id
GROUP BY day_type
ORDER BY day_type;


-- KPI 2: Orders with Review Score 5 and Credit Card Payment
-- Count of distinct orders where review_score = 5 AND payment_type = 'credit_card'
SELECT
    COUNT(DISTINCT o.order_id) AS five_star_credit_card_orders
FROM olist_orders_dataset o
JOIN olist_order_reviews_dataset r
    ON o.order_id = r.order_id
JOIN olist_order_payments_dataset p
    ON o.order_id = p.order_id
WHERE r.review_score = 5
  AND p.payment_type = 'credit_card';


-- KPI 3: Average Delivery Days for Pet Shop Category
-- Average days between purchase and delivery for 'pet_shop' category
SELECT
    ROUND(AVG(DATEDIFF(
        o.order_delivered_customer_date,
        o.order_purchase_timestamp
    )), 2) AS avg_delivery_days_pet_shop
FROM olist_orders_dataset o
JOIN olist_order_items_dataset oi
    ON o.order_id = oi.order_id
JOIN olist_products_dataset pr
    ON oi.product_id = pr.product_id
JOIN product_category_name_translation t
    ON pr.product_category_name = t.product_category_name
WHERE t.product_category_name_english = 'pet_shop'
  AND o.order_delivered_customer_date IS NOT NULL
  AND o.order_purchase_timestamp IS NOT NULL;


-- KPI 4: Average Price and Payment Value from São Paulo Customers
-- For customers in Sao Paulo city
SELECT
    ROUND(AVG(oi.price), 2)          AS avg_price,
    ROUND(AVG(p.payment_value), 2)   AS avg_payment_value
FROM olist_orders_dataset o
JOIN olist_customers_dataset c
    ON o.customer_id = c.customer_id
JOIN olist_order_items_dataset oi
    ON o.order_id = oi.order_id
JOIN olist_order_payments_dataset p
    ON o.order_id = p.order_id
WHERE LOWER(c.customer_city) = 'sao paulo';


-- KPI 5: Average Shipping Days vs Review Score
-- For each review score (1–5), calculate average shipping days
SELECT
    r.review_score,
    ROUND(AVG(DATEDIFF(
        o.order_delivered_customer_date,
        o.order_purchase_timestamp
    )), 2) AS avg_shipping_days
FROM olist_orders_dataset o
JOIN olist_order_reviews_dataset r
    ON o.order_id = r.order_id
WHERE o.order_delivered_customer_date IS NOT NULL
  AND o.order_purchase_timestamp IS NOT NULL
GROUP BY r.review_score
ORDER BY r.review_score ASC;


-- =============================================================
-- SECTION 3: ADDITIONAL DASHBOARD QUERIES
-- =============================================================

-- Total Orders Count (KPI Card)
SELECT
    COUNT(DISTINCT order_id) AS total_orders
FROM olist_orders_dataset;


-- Total Sales (Sum of all payment values)
SELECT
    ROUND(SUM(payment_value), 2) AS total_sales
FROM olist_order_payments_dataset;


-- Average Review Score (KPI Card)
SELECT
    ROUND(AVG(review_score), 2) AS avg_review_score
FROM olist_order_reviews_dataset;


-- Average Delivery Days – Overall
SELECT
    ROUND(AVG(DATEDIFF(
        order_delivered_customer_date,
        order_purchase_timestamp
    )), 2) AS avg_delivery_days
FROM olist_orders_dataset
WHERE order_delivered_customer_date IS NOT NULL
  AND order_purchase_timestamp IS NOT NULL;


-- Monthly Sales Trend
-- Revenue grouped by year and month
SELECT
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS order_month,
    ROUND(SUM(p.payment_value), 2)                   AS monthly_sales
FROM olist_orders_dataset o
JOIN olist_order_payments_dataset p
    ON o.order_id = p.order_id
GROUP BY order_month
ORDER BY order_month ASC;


-- Sales by Customer State
-- Total revenue per Brazilian state
SELECT
    c.customer_state,
    ROUND(SUM(p.payment_value), 2) AS total_sales
FROM olist_orders_dataset o
JOIN olist_customers_dataset c
    ON o.customer_id = c.customer_id
JOIN olist_order_payments_dataset p
    ON o.order_id = p.order_id
GROUP BY c.customer_state
ORDER BY total_sales DESC;


-- Top 10 Product Categories by Revenue
SELECT
    t.product_category_name_english AS category,
    ROUND(SUM(oi.price), 2)         AS total_revenue
FROM olist_order_items_dataset oi
JOIN olist_products_dataset pr
    ON oi.product_id = pr.product_id
JOIN product_category_name_translation t
    ON pr.product_category_name = t.product_category_name
GROUP BY category
ORDER BY total_revenue DESC
LIMIT 10;


-- Payment Type Breakdown
-- Count of orders per payment method
SELECT
    payment_type,
    COUNT(DISTINCT order_id) AS order_count
FROM olist_order_payments_dataset
GROUP BY payment_type
ORDER BY order_count DESC;


-- 5-Star Order Count (KPI Card)
SELECT
    COUNT(DISTINCT order_id) AS five_star_orders
FROM olist_order_reviews_dataset
WHERE review_score = 5;


-- =============================================================
-- END OF FILE | Group 6 | Olist E-Commerce Analytics Dashboard
-- =============================================================
