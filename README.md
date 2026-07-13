# RedFlag — The Fraud Files

> *"Build a fraud detection engine using pure SQL. No ML. No Python. No excuses."*

A pure SQL fraud detection engine that identifies 12 distinct fraud patterns hidden in 196,594 transactions from a simulated Indian payment aggregator. Every query mirrors real fraud detection work done daily at Razorpay, Cred, Slice, Jupiter, and PhonePe.

**No Python. No ML. No pandas. Just SQL.**

---

## 📸 Output Preview
---

## 🎯 Mission

You have just joined PayFast, a fictional Indian payment aggregator processing UPI, card, netbanking, and wallet transactions across 20 Indian cities. Buried in 196,594 transactions are 12 distinct fraud patterns being run by suspected fraudsters.

Your job: catch every single one using only SQL.

---

## 🔍 The 12 Fraud Patterns Detected

### Tier 1 — Week 3 SQL (GROUP BY, HAVING, CASE WHEN)

| Pattern | Description | Suspects Found | Expected |
|---|---|---|---|
| P1 · Velocity Fraud | Users with 30+ transactions in a single day | 47 | 45-55 |
| P2 · Round-Amount Clustering | Users with 15+ exactly round-number transactions | 25 | 25 |
| P3 · Card Testing | Users with 30+ sub-₹10 transactions in one day | 18 | ~20 |
| P4 · Failed-Then-Succeeded | Users with 20+ failed transactions | 23 | ~25 |
| P5 · Odd-Hour Concentration | Users with 80%+ transactions between 2AM-5AM | 20 | 20 |

### Tier 2 — Week 4 SQL (Joins, Subqueries, EXISTS)

| Pattern | Description | Suspects Found | Expected |
|---|---|---|---|
| P6 · Mule Accounts | Users with 8+ credit transactions (fast in/out) | 30 | 30 |
| P7 · Refund Abuse | Users with 40%+ refund ratio across 20+ transactions | 25 | 24-25 |
| P8 · Merchant Collusion | Merchants where top 5 users = 99%+ of revenue | 15 | 15 |
| P9 · Just-Under-Threshold | Users with 10+ transactions at exactly ₹9,999 | 19 | ~20 |
| P10 · Dormant-Then-Active | Accounts inactive 90+ days then 15+ sudden transactions | 27 | 25-27 |

### Tier 3 — Window Functions (LAG, ROW_NUMBER, CTEs)

| Pattern | Description | Suspects Found | Expected |
|---|---|---|---|
| P11 · Velocity Spike | Users whose peak month is 3x+ their average month | 44 | 35-45 |
| P12 · Geographic Impossibility | Users transacting in 2 different cities within 60 minutes | 15 | 15 |

---

## 💡 Most Interesting Findings

1. **P12 — Geographic Impossibility**: User 14750 transacted in Delhi and Visakhapatnam just **1 minute apart** — physically impossible across 1,200+ km. Classic account takeover syndicate.

2. **P8 — Merchant Collusion**: Merchants 1-15 had top 5 users accounting for **99.7-99.9%** of all revenue — these are pure shell merchants with no legitimate customers.

3. **P10 — Dormant-Then-Active**: User 14708 was inactive for **165 days** then suddenly burst with 31 transactions — textbook SIM swap attack.

4. **Cross-pattern overlap**: User 14526 appears in both P1 (velocity fraud) and P10 (dormant-then-active) — account takeover immediately followed by automated transaction burst.

5. **P5 — Bot ring**: 20 users had 80-94% of all activity between 2AM-5AM — automated scripts running from foreign timezones, exploiting off-hours.

---

## 🗄️ Dataset

| Property | Value |
|---|---|
| File | `redflag_transactions.sql` |
| Table | `redflag.transactions` |
| Rows | 196,594 transactions |
| Period | 01 January 2024 to 28 June 2024 |
| Unique users | 14,755 |
| Unique merchants | 800 |
| Cities | 20 Indian cities |
| Fraud suspects seeded | 255+ across 12 patterns |
| Type | Synthetic (generated, not real data) |

**Columns:**
`txn_id`, `user_id`, `merchant_id`, `amount`, `txn_time`, `status`, `payment_mode`, `city`, `txn_type`

> Note: `redflag_transactions.sql` (18MB) is not pushed to this repo. Request via email or download from the course portal.

---

## 🛠️ Tech Stack

| Tool | Purpose |
|---|---|
| MySQL 8.x | Database engine |
| MySQL Workbench | Query editor |
| Pure SQL | Everything — no Python, no ML, no pandas |

**SQL concepts used:**
- `GROUP BY`, `HAVING`, `COUNT`, `SUM`, `WHERE` — Tier 1
- Subqueries, correlated subqueries, `EXISTS` — Tier 2
- `LAG()`, `ROW_NUMBER()`, `OVER PARTITION BY`, CTEs — Tier 3
- `DATE()`, `HOUR()`, `DATE_FORMAT()`, `TIMESTAMPDIFF()` — throughout

---

## ▶️ How to Run

**Step 1 — Increase MySQL Workbench timeout:**
- Edit → Preferences → SQL Editor
- Set DBMS connection read timeout to `600`
- Restart Workbench

**Step 2 — Import the dataset:**
- File → Open SQL Script → select `redflag_transactions.sql`
- Press `Ctrl + Shift + Enter`
- Wait 60-90 seconds

**Step 3 — Verify import:**
```sql
SELECT COUNT(*) FROM redflag.transactions;
-- Expected: ~196,594

SELECT COUNT(DISTINCT user_id) FROM redflag.transactions;
-- Expected: ~14,755

SELECT MIN(txn_time), MAX(txn_time) FROM redflag.transactions;
-- Expected: 2024-01-01 to 2024-06-28
```

**Step 4 — Run the fraud detection queries:**
- Open `RedFlag_YourName.sql`
- Run each pattern query individually
- Compare suspect counts to expected ranges in the table above

---

## 📁 Repository Structure

```
RedFlag/
├── RedFlag_<YourName>.sql    ← All 12 fraud detection queries
├── README.md                 ← This file
└── screenshots/              ← Query output screenshots
    ├── p8_merchant_collusion.png
    ├── p12_geographic_impossibility.png
    └── p11_velocity_spike.png
```

---

## 📅 7-Day Build Log

| Day | Goal | Status |
|---|---|---|
| Day 1 | Import dataset, run exploration queries, understand data distribution | ✅ Done |
| Day 2 | P1 Velocity Fraud, P2 Round-Amount, P3 Card Testing | ✅ Done |
| Day 3 | P4 Failed-Then-Succeeded, P5 Odd-Hour Concentration | ✅ Done |
| Day 4 | P6 Mule Accounts, P7 Refund Abuse, P8 Merchant Collusion | ✅ Done |
| Day 5 | P9 Just-Under-Threshold, P10 Dormant-Then-Active | ✅ Done |
| Day 6 | P11 Velocity Spike, P12 Geographic Impossibility | ✅ Done |
| Day 7 | Polish SQL file, verify all counts, push to GitHub, submit | ✅ Done |

---

## 🏫 About

Built as a Week 3-4 Minor Project for the **Data Science with Business Analytics** course at [The Unlox Academy](https://unlox.com).

This project mirrors real fraud analytics work at Indian fintech companies. Fraud detection is one of the fastest-growing analyst roles in India — and it does not require ML. It requires exactly this: structured SQL queries that catch patterns at scale.

> *"I wrote twelve SQL queries that caught fraudsters hiding in 196,594 transactions. No Python. No machine learning. Just SQL."*

---

## 🔗 Related Projects

- [GroupDNA](https://github.com/yourusername/GroupDNA) — WhatsApp group chat analytics using Python fundamentals
- [SpendDNA](https://github.com/yourusername/SpendDNA) — UPI transaction analytics using Pandas + NumPy
