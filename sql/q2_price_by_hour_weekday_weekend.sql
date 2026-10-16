-- Q2: Average price by hour of day, weekday vs weekend
-- Answer: weekdays cheapest ~13:00 (~6 ct/kWh), priciest ~19:00 (~17 ct/kWh). Weekends cheaper all day, midday ~2 ct/kWh.
SELECT
  hour_of_day,
  ROUND(AVG(CASE WHEN EXTRACT(DAYOFWEEK FROM hour_local) IN (1, 7)
                 THEN NULL ELSE price_ct_kwh END), 2) AS weekday_ct_kwh,
  ROUND(AVG(CASE WHEN EXTRACT(DAYOFWEEK FROM hour_local) IN (1, 7)
                 THEN price_ct_kwh END), 2) AS weekend_ct_kwh
FROM `german-power-prices.energy_data.hourly_heat`
GROUP BY hour_of_day
ORDER BY hour_of_day;
