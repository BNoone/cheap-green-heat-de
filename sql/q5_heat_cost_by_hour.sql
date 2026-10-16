-- Q5: What does 1 kWh of heat cost at each hour of the day (heating hours only)?
-- Builds on the 3-way join (price, temperature, COP lookup) in 03_hourly_heat_view.sql
-- Answer: cheapest heat ~12:00 (1.77 ct/kWh), most expensive ~18:00 (3.23 ct/kWh).
SELECT
  hour_of_day,
  COUNT(*) AS heating_hours,
  ROUND(AVG(price_ct_kwh), 2) AS avg_power_ct_kwh,
  ROUND(AVG(cop), 2) AS avg_cop,
  ROUND(AVG(heat_cost_ct_kwh), 2) AS avg_heat_ct_kwh
FROM `german-power-prices.energy_data.hourly_heat`
WHERE heating_needed
GROUP BY hour_of_day
ORDER BY hour_of_day;
