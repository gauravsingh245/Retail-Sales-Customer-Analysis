-- ============================================
-- RETAIL SALES & CUSTOMER ANALYSIS PROJECT
-- NORTHWIND DATABASE
-- ============================================

-- ============================================
-- 1. Total Customers
-- ============================================

SELECT COUNT(*) AS total_customers
FROM customers;


-- ============================================
-- 2. Total Orders
-- ============================================

SELECT COUNT(*) AS total_orders
FROM orders;


-- ============================================
-- 3. Total Products
-- ============================================

SELECT COUNT(*) AS total_products
FROM products;


-- ============================================
-- 4. Top 10 Products by Revenue
-- ============================================

SELECT
    p.product_name,
    ROUND(SUM(od.quantity * od.unit_price),2) AS revenue
FROM order_details od
JOIN products p
ON od.product_id = p.id
GROUP BY p.product_name
ORDER BY revenue DESC
LIMIT 10;


-- ============================================
-- 5. Top 10 Products by Quantity Sold
-- ============================================

SELECT
    p.product_name,
    SUM(od.quantity) AS units_sold
FROM order_details od
JOIN products p
ON od.product_id = p.id
GROUP BY p.product_name
ORDER BY units_sold DESC
LIMIT 10;


-- ============================================
-- 6. Revenue by Product Category
-- ============================================

SELECT
    p.category,
    ROUND(SUM(od.quantity * od.unit_price),2) AS revenue
FROM order_details od
JOIN products p
ON od.product_id = p.id
GROUP BY p.category
ORDER BY revenue DESC;


-- ============================================
-- 7. Monthly Revenue Trend
-- ============================================

SELECT
    YEAR(o.order_date) AS year,
    MONTH(o.order_date) AS month,
    ROUND(SUM(od.quantity * od.unit_price),2) AS revenue
FROM orders o
JOIN order_details od
ON o.id = od.order_id
GROUP BY year, month
ORDER BY year, month;


-- ============================================
-- 8. Top Customers by Spending
-- ============================================

SELECT
    CONCAT(c.first_name,' ',c.last_name) AS customer_name,
    ROUND(SUM(od.quantity * od.unit_price),2) AS total_spent
FROM customers c
JOIN orders o
ON c.id = o.customer_id
JOIN order_details od
ON o.id = od.order_id
GROUP BY c.id, customer_name
ORDER BY total_spent DESC
LIMIT 10;


-- ============================================
-- 9. Employee Sales Performance
-- ============================================

SELECT
    CONCAT(e.first_name,' ',e.last_name) AS employee_name,
    ROUND(SUM(od.quantity * od.unit_price),2) AS sales
FROM employees e
JOIN orders o
ON e.id = o.employee_id
JOIN order_details od
ON o.id = od.order_id
GROUP BY e.id, employee_name
ORDER BY sales DESC;


-- ============================================
-- 10. Average Order Value
-- ============================================

SELECT
    ROUND(AVG(order_total),2) AS average_order_value
FROM
(
    SELECT
        o.id,
        SUM(od.quantity * od.unit_price) AS order_total
    FROM orders o
    JOIN order_details od
    ON o.id = od.order_id
    GROUP BY o.id
) t;


-- ============================================
-- 11. Customers Spending Above Average
-- CTE Example
-- ============================================

WITH customer_spending AS
(
    SELECT
        c.id,
        CONCAT(c.first_name,' ',c.last_name) AS customer_name,
        SUM(od.quantity * od.unit_price) AS total_spent
    FROM customers c
    JOIN orders o
    ON c.id = o.customer_id
    JOIN order_details od
    ON o.id = od.order_id
    GROUP BY c.id, customer_name
)

SELECT *
FROM customer_spending
WHERE total_spent >
(
    SELECT AVG(total_spent)
    FROM customer_spending
)
ORDER BY total_spent DESC;


-- ============================================
-- 12. Product Ranking Within Category
-- Window Function
-- ============================================

SELECT *
FROM
(
    SELECT
        p.category,
        p.product_name,
        ROUND(SUM(od.quantity * od.unit_price),2) AS revenue,
        RANK() OVER
        (
            PARTITION BY p.category
            ORDER BY SUM(od.quantity * od.unit_price) DESC
        ) AS rank_num
    FROM order_details od
    JOIN products p
    ON od.product_id = p.id
    GROUP BY p.category, p.product_name
) ranked_products
WHERE rank_num <= 3;


-- ============================================
-- 13. Monthly Order Count
-- ============================================

SELECT
    YEAR(order_date) AS year,
    MONTH(order_date) AS month,
    COUNT(*) AS total_orders
FROM orders
GROUP BY year, month
ORDER BY year, month;


-- ============================================
-- 14. Revenue by Customer City
-- ============================================

SELECT
    c.city,
    ROUND(SUM(od.quantity * od.unit_price),2) AS revenue
FROM customers c
JOIN orders o
ON c.id = o.customer_id
JOIN order_details od
ON o.id = od.order_id
GROUP BY c.city
ORDER BY revenue DESC;


-- ============================================
-- 15. Highest Revenue Orders
-- ============================================

SELECT
    o.id AS order_id,
    ROUND(SUM(od.quantity * od.unit_price),2) AS order_revenue
FROM orders o
JOIN order_details od
ON o.id = od.order_id
GROUP BY o.id
ORDER BY order_revenue DESC
LIMIT 10;


-- ============================================
-- 16. Product Profit Analysis
-- ============================================

SELECT
    p.product_name,
    ROUND(
        SUM(
            od.quantity *
            (od.unit_price - p.standard_cost)
        ),2
    ) AS estimated_profit
FROM order_details od
JOIN products p
ON od.product_id = p.id
GROUP BY p.product_name
ORDER BY estimated_profit DESC;


-- ============================================
-- 17. Customer Frequency Analysis
-- ============================================

SELECT
    CONCAT(c.first_name,' ',c.last_name) AS customer_name,
    COUNT(o.id) AS total_orders
FROM customers c
JOIN orders o
ON c.id = o.customer_id
GROUP BY c.id, customer_name
ORDER BY total_orders DESC;


-- ============================================
-- 18. Shipping Cost Analysis
-- ============================================

SELECT
    ship_country_region,
    ROUND(AVG(shipping_fee),2) AS avg_shipping_fee
FROM orders
GROUP BY ship_country_region
ORDER BY avg_shipping_fee DESC;


-- ============================================
-- 19. Revenue by Employee
-- ============================================

SELECT
    CONCAT(e.first_name,' ',e.last_name) AS employee_name,
    COUNT(DISTINCT o.id) AS orders_handled,
    ROUND(SUM(od.quantity * od.unit_price),2) AS revenue_generated
FROM employees e
JOIN orders o
ON e.id = o.employee_id
JOIN order_details od
ON o.id = od.order_id
GROUP BY e.id, employee_name
ORDER BY revenue_generated DESC;


-- ============================================
-- 20. Customer Segmentation
-- ============================================

SELECT
    customer_name,
    total_spent,
    CASE
        WHEN total_spent >= 5000 THEN 'High Value'
        WHEN total_spent >= 2000 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS customer_segment
FROM
(
    SELECT
        CONCAT(c.first_name,' ',c.last_name) AS customer_name,
        SUM(od.quantity * od.unit_price) AS total_spent
    FROM customers c
    JOIN orders o
    ON c.id = o.customer_id
    JOIN order_details od
    ON o.id = od.order_id
    GROUP BY c.id, customer_name
) customer_value
ORDER BY total_spent DESC;