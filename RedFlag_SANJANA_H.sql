-- =====================================================================
-- RedFlag — Fraud Detection Submission
-- Student: SANJANA H | Batch: DATA ANALYTICS
-- =====================================================================
USE redflag;

-- =====================================================================
-- PATTERN 1 · VELOCITY FRAUD
-- Expected suspects: 45-55 user-days
-- =====================================================================

SELECT user_id,DATE(txn_time) AS attack_date, COUNT(*) AS daily_txn_count
FROM transactions
GROUP BY user_id, DATE(txn_time)
HAVING COUNT(*) >= 30
ORDER BY daily_txn_count DESC;

-- My findings: 47 suspect user-days flagged.
-- Top 3 fraudsters: user 14569 (60 txns on 2024-04-03),

-- =====================================================================
-- PATTERN 2 · ROUND-AMOUNT CLUSTERING
-- Expected suspects: exactly 25
-- =====================================================================

SELECT user_id, COUNT(*) AS round_txn_count
FROM transactions
WHERE amount IN (100, 200, 500, 1000, 2000, 5000, 10000)
GROUP BY user_id
HAVING COUNT(*) >= 15
ORDER BY round_txn_count DESC;

-- My findings: exactly 25 suspects flagged.
-- Top 3: user 14534 (30 txns), user 14535 (30 txns), user 14533 (29 txns).

-- =====================================================================
-- PATTERN 3 · CARD TESTING
-- Expected suspects: exactly 20
-- =====================================================================

SELECT user_id, DATE(txn_time) AS test_date, COUNT(*) AS tiny_txn_count
FROM transactions
WHERE amount < 10
GROUP BY user_id, DATE(txn_time)
HAVING COUNT(*) >= 30
ORDER BY tiny_txn_count DESC;

-- My findings: 18 suspect user-days flagged 
-- Top 3: user 14569 (60 txns on 2024-04-03),

-- =====================================================================
-- PATTERN 4 · FAILED-THEN-SUCCEEDED
-- Expected suspects: exactly 25
-- =====================================================================

SELECT user_id, COUNT(*) AS failed_txn_count
FROM transactions
WHERE status = 'FAILED'
GROUP BY user_id
HAVING COUNT(*) >= 20
ORDER BY failed_txn_count DESC;

-- My findings: 23 suspects flagged 

-- =====================================================================
-- PATTERN 5 · ODD-HOUR CONCENTRATION
-- Expected suspects: exactly 20
-- =====================================================================

SELECT user_id,COUNT(*) AS total_txns,
    SUM(CASE WHEN HOUR(txn_time) BETWEEN 2 AND 4 THEN 1 ELSE 0 END) AS odd_hour_txns,
    ROUND( SUM(CASE WHEN HOUR(txn_time) BETWEEN 2 AND 4 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) AS odd_hour_pct
FROM transactions
GROUP BY user_id
HAVING total_txns >= 30 AND odd_hour_pct >= 80
ORDER BY odd_hour_pct DESC;

-- My findings: exactly 20 suspects flagged 
-- Top 3: user 14606 (94.1% odd-hour), user 14609 (93.8%), user 14619 (93.5%).
-- All suspects distinct from P1-P4 — automated scripts running from foreign timezone.

-- =====================================================================
-- PATTERN 6 · MULE ACCOUNTS
-- Expected suspects: exactly 30
-- =====================================================================

SELECT user_id, COUNT(*) AS credit_txn_count, ROUND(SUM(amount), 2) AS total_credited
FROM transactions
WHERE txn_type = 'CREDIT'
GROUP BY user_id
HAVING COUNT(*) >= 8
ORDER BY credit_txn_count DESC;

-- My findings: exactly 30 suspects flagged 

-- =====================================================================
-- PATTERN 7 · REFUND ABUSE
-- Expected suspects: 24-25
-- =====================================================================

SELECT user_id, COUNT(*) AS total_txns, SUM(CASE WHEN txn_type = 'REFUND' THEN 1 ELSE 0 END) AS refund_count,
    ROUND( SUM(CASE WHEN txn_type = 'REFUND' THEN 1 ELSE 0 END) / COUNT(*) * 100, 1 ) AS refund_pct
FROM transactions
GROUP BY user_id
HAVING total_txns >= 20 AND refund_pct >= 40
ORDER BY refund_pct DESC;

-- My findings: 25 suspects flagged 
-- Top 3: user 14660 (65.5% refund rate), user 14670 (65.3%), user 14662 (64.1%).

-- =====================================================================
-- PATTERN 9 · JUST-UNDER-THRESHOLD (STRUCTURING)
-- Expected suspects: exactly 20
-- =====================================================================

SELECT user_id, COUNT(*) AS threshold_txn_count, ROUND(SUM(amount), 2) AS total_amount
FROM transactions
WHERE amount = 9999.00
GROUP BY user_id
HAVING COUNT(*) >= 10
ORDER BY threshold_txn_count DESC;

-- My findings: 19 suspects flagged (expected ~20, one short — acceptable).
-- Top 3: user 14680 (25 txns, Rs.2.49L), user 14690 (24 txns, Rs.2.39L),

-- =====================================================================
-- PATTERN 8 · MERCHANT COLLUSION
-- Expected suspects: exactly 15 merchants (IDs 1-15)
-- =====================================================================

SELECT 
    merchant_id, ROUND(top5_amount / total_amount * 100, 1) AS top5_pct,
    ROUND(total_amount, 2) AS total_amount, ROUND(top5_amount, 2) AS top5_amount
FROM ( SELECT merchant_id, SUM(amount) AS total_amount,
	(SELECT SUM(user_total)
		FROM (SELECT SUM(amount) AS user_total
		FROM transactions t2
		WHERE t2.merchant_id = t1.merchant_id
		GROUP BY user_id
		ORDER BY user_total DESC
		LIMIT 5 ) AS top5 ) AS top5_amount
    FROM transactions t1
    GROUP BY merchant_id
) AS merchant_stats
WHERE top5_amount / total_amount > 0.60
ORDER BY top5_pct DESC;

-- My findings: exactly 15 merchants flagged 
-- Largest: merchant 5 (Rs.21L total, 99.7% concentrated in top 5 users).

-- =====================================================================
-- PATTERN 10 · DORMANT-THEN-ACTIVE
-- Expected suspects: 25-27
-- =====================================================================

SELECT user_id, gap_days, revival_date, post_gap_txns
FROM ( SELECT user_id, txn_time AS revival_date,
        TIMESTAMPDIFF(DAY, LAG(txn_time) OVER (PARTITION BY user_id ORDER BY txn_time), txn_time)
        AS gap_days,
        COUNT(*) OVER ( PARTITION BY user_id) 
	    AS post_gap_txns
    FROM transactions
) AS gap_data
WHERE gap_days >= 90 AND post_gap_txns >= 15
ORDER BY gap_days DESC;

-- My findings: 27 suspects flagged 
-- Revival dates cluster May-June 2024 suggesting coordinated attack wave.

WITH monthly_counts AS (
    SELECT user_id, DATE_FORMAT(txn_time, '%Y-%m') AS txn_month,COUNT(*) AS monthly_txn_count
    FROM transactions
    GROUP BY user_id, DATE_FORMAT(txn_time, '%Y-%m')
),
user_stats AS (
    SELECT user_id, ROUND(AVG(monthly_txn_count), 2) AS avg_monthly, MAX(monthly_txn_count) AS peak_monthly
    FROM monthly_counts
    GROUP BY user_id
)
SELECT user_id, avg_monthly, peak_monthly, ROUND(peak_monthly / avg_monthly, 1) AS spike_ratio
FROM user_stats
WHERE peak_monthly >= 20
    AND peak_monthly / avg_monthly >= 3
ORDER BY spike_ratio DESC;

-- My findings: 44 suspects flagged 


-- =====================================================================
-- PATTERN 12 · GEOGRAPHIC IMPOSSIBILITY
-- Expected suspects: exactly 15
-- =====================================================================

SELECT DISTINCT user_id, city, prev_city, txn_time, prev_time,
    TIMESTAMPDIFF(MINUTE, prev_time, txn_time) AS minutes_apart
FROM (
    SELECT user_id, city, txn_time,
        LAG(city) OVER (PARTITION BY user_id ORDER BY txn_time) AS prev_city,
        LAG(txn_time) OVER (PARTITION BY user_id ORDER BY txn_time) AS prev_time
    FROM transactions
) AS city_gaps
WHERE city != prev_city
    AND TIMESTAMPDIFF(MINUTE, prev_time, txn_time) <= 60
    AND prev_city IS NOT NULL
ORDER BY minutes_apart ASC;

-- My findings: exactly 15 distinct suspects flagged 
-- Classic account takeover syndicate operating across multiple cities.