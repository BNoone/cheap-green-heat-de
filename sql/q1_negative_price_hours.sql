-- Q1: How many negative-price hours per month?
-- Answer: 523 hours in the year, almost all March to September, peak April 2026 (123 h, 17 %). None in Nov and Dec.
SELECT
  FORMAT_DATETIME('%Y-%m', hour_local) AS month,
  COUNTIF(price_ct_kwh < 0) AS negative_price_hours,
  COUNT(*) AS total_hours,
  ROUND(100 * COUNTIF(price_ct_kwh < 0) / COUNT(*), 1) AS pct_negative
FROM `german-power-prices.energy_data.hourly_heat`
GROUP BY month
ORDER BY month;
