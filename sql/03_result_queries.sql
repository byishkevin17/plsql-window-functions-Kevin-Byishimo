-- =============================================================================
-- 1. RANKING FUNCTIONS - Top N Customers by Revenue
-- =============================================================================

-- Basic ranking functions comparison

SELECT 
    c.name,
    c.region,
    SUM(t.amount) as total_revenue,
    -- ROW_NUMBER: Unique sequential numbering (1,2,3,4...)
    ROW_NUMBER() OVER (ORDER BY SUM(t.amount) DESC) as row_num,
    -- RANK: Same values get same rank, next rank skips (1,2,2,4...)
    RANK() OVER (ORDER BY SUM(t.amount) DESC) as rank_pos,
    -- DENSE_RANK: Same values get same rank, next rank continues (1,2,2,3...)
    DENSE_RANK() OVER (ORDER BY SUM(t.amount) DESC) as dense_rank_pos,
    -- PERCENT_RANK: Relative rank as percentage (0 to 1)
    PERCENT_RANK() OVER (ORDER BY SUM(t.amount) DESC) as percent_rank
FROM customers c
JOIN transactions t ON c.customer_id = t.customer_id
GROUP BY c.customer_id, c.name, c.region
ORDER BY total_revenue DESC;

-- Interpretation: 
--

-- =============================================================================
-- 2. AGGREGATE FUNCTIONS - Running Totals & Trends
-- =============================================================================

-- Running totals with different frame specifications

SELECT 
    t.sale_date,
    c.name as customer_name,
    t.amount,
    -- Running total (ROWS frame - physical rows)
    SUM(t.amount) OVER (ORDER BY t.sale_date ROWS UNBOUNDED PRECEDING) as running_total_rows,
    -- Running total (RANGE frame - logical range, handles ties differently)
    SUM(t.amount) OVER (ORDER BY t.sale_date RANGE UNBOUNDED PRECEDING) as running_total_range,
    -- Moving average (last 3 transactions)
    AVG(t.amount) OVER (ORDER BY t.sale_date ROWS 2 PRECEDING) as moving_avg_3,
    -- Running minimum and maximum
    MIN(t.amount) OVER (ORDER BY t.sale_date ROWS UNBOUNDED PRECEDING) as running_min,
    MAX(t.amount) OVER (ORDER BY t.sale_date ROWS UNBOUNDED PRECEDING) as running_max
FROM transactions t
JOIN customers c ON t.customer_id = c.customer_id
ORDER BY t.sale_date;

-- interpretation:
--

-- =============================================================================
-- 3. NAVIGATION FUNCTIONS - Period-to-Period Analysis
-- =============================================================================

-- Customer purchase patterns with LAG/LEAD
SELECT 
    c.name,
    t.sale_date,
    t.amount,
    -- Previous purchase date and amount
    LAG(t.sale_date) OVER (PARTITION BY c.customer_id ORDER BY t.sale_date) as prev_purchase_date,
    LAG(t.amount) OVER (PARTITION BY c.customer_id ORDER BY t.sale_date) as prev_amount,
    -- Next purchase date and amount
    LEAD(t.sale_date) OVER (PARTITION BY c.customer_id ORDER BY t.sale_date) as next_purchase_date,
    LEAD(t.amount) OVER (PARTITION BY c.customer_id ORDER BY t.sale_date) as next_amount,
    -- Days between purchases
    DATEDIFF(t.sale_date, LAG(t.sale_date) OVER (PARTITION BY c.customer_id ORDER BY t.sale_date)) as days_since_last_purchase,
    -- Growth percentage calculation
    ROUND(
        ((t.amount - LAG(t.amount) OVER (PARTITION BY c.customer_id ORDER BY t.sale_date)) / 
         LAG(t.amount) OVER (PARTITION BY c.customer_id ORDER BY t.sale_date)) * 100, 2
    ) as purchase_growth_pct
FROM customers c
JOIN transactions t ON c.customer_id = t.customer_id
ORDER BY c.name, t.sale_date;

-- interpretation:
-- 

-- =============================================================================
-- 4. DISTRIBUTION FUNCTIONS - Customer Segmentation
-- =============================================================================

-- Customer segmentation using NTILE and CUME_DIST
WITH customer_revenue AS (
    SELECT 
        c.customer_id,
        c.name,
        c.region,
        SUM(t.amount) as total_revenue,
        COUNT(t.transaction_id) as transaction_count,
        AVG(t.amount) as avg_transaction_value
    FROM customers c
    JOIN transactions t ON c.customer_id = t.customer_id
    GROUP BY c.customer_id, c.name, c.region
)
SELECT 
    name,
    region,
    total_revenue,
    transaction_count,
    avg_transaction_value,
    -- Quartile segmentation (1=bottom 25%, 4=top 25%)
    NTILE(4) OVER (ORDER BY total_revenue) as revenue_quartile,
    -- Cumulative distribution (percentile rank)
    ROUND(CUME_DIST() OVER (ORDER BY total_revenue) * 100, 1) as revenue_percentile,
    -- Customer segments based on quartiles
    CASE 
        WHEN NTILE(4) OVER (ORDER BY total_revenue) = 4 THEN 'Premium'
        WHEN NTILE(4) OVER (ORDER BY total_revenue) = 3 THEN 'Gold'
        WHEN NTILE(4) OVER (ORDER BY total_revenue) = 2 THEN 'Silver'
        ELSE 'Bronze'
    END as customer_segment
FROM customer_revenue
ORDER BY total_revenue DESC;
-- interpretation:
--
