-- Q8: Which hours are both freezing and expensive (cold-snap stress)?
-- Answer: only ~10 hours last winter (mild in Duesseldorf), but then heat costs ~6 ct/kWh, about 3x the average.
WITH threshold AS (
  SELECT APPROX_QUANTILES(price_ct_kwh, 100)[OFFSET(90)] AS p90_ct_kwh
  FROM `german-power-prices.energy_data.hourly_heat`
)
SELECT
  FORMAT_DATETIME('%Y-%m', h.hour_local) AS month,
  COUNT(*) AS stress_hours,
  ROUND(AVG(h.temp_c), 1) AS avg_temp_c,
  ROUND(AVG(h.price_ct_kwh), 2) AS avg_power_ct_kwh,
  ROUND(AVG(h.heat_cost_ct_kwh), 2) AS avg_heat_ct_kwh
FROM `german-power-prices.energy_data.hourly_heat` AS h
CROSS JOIN threshold AS t
WHERE h.temp_c < 0
  AND h.price_ct_kwh > t.p90_ct_kwh
GROUP BY month
ORDER BY month;
