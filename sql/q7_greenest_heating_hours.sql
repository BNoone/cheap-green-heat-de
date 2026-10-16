-- Q7: When does heating run on the most renewables?
-- Answer: greenest heating hours 11:00 to 13:00 (~70 % renewables), dirtiest 18:00 to 20:00 (~46 %). Greenest = cheapest heat.
WITH heating AS (
  SELECT hour_of_day, ren_share_pct, heat_cost_ct_kwh
  FROM `german-power-prices.energy_data.hourly_heat`
  WHERE heating_needed
)
SELECT
  hour_of_day,
  ROUND(AVG(ren_share_pct), 1) AS avg_ren_share_pct,
  ROUND(AVG(heat_cost_ct_kwh), 2) AS avg_heat_ct_kwh
FROM heating
GROUP BY hour_of_day
ORDER BY avg_ren_share_pct DESC;
