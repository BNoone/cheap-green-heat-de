-- Q6: How often does the cheapest heat hour differ from the cheapest power hour?
-- Answer: on ~20 % of heating days (58 of 295), saving ~0.10 ct per kWh of heat on those days.
WITH heating AS (
  SELECT DATE(hour_local) AS day, hour_of_day, price_ct_kwh, heat_cost_ct_kwh
  FROM `german-power-prices.energy_data.hourly_heat`
  WHERE heating_needed
),
ranked AS (
  SELECT *,
    ROW_NUMBER() OVER (PARTITION BY day ORDER BY price_ct_kwh) AS power_rank,
    ROW_NUMBER() OVER (PARTITION BY day ORDER BY heat_cost_ct_kwh) AS heat_rank
  FROM heating
),
best AS (
  SELECT
    day,
    MAX(IF(power_rank = 1, hour_of_day, NULL)) AS cheapest_power_hour,
    MAX(IF(heat_rank = 1, hour_of_day, NULL)) AS cheapest_heat_hour,
    MAX(IF(power_rank = 1, heat_cost_ct_kwh, NULL)) AS heat_cost_at_power_hour,
    MIN(heat_cost_ct_kwh) AS heat_cost_at_heat_hour
  FROM ranked
  GROUP BY day
)
SELECT
  COUNT(*) AS heating_days,
  COUNTIF(cheapest_power_hour != cheapest_heat_hour) AS days_different,
  ROUND(100 * COUNTIF(cheapest_power_hour != cheapest_heat_hour) / COUNT(*), 1) AS pct_days_different,
  ROUND(AVG(IF(cheapest_power_hour != cheapest_heat_hour,
               heat_cost_at_power_hour - heat_cost_at_heat_hour, NULL)), 3) AS avg_saving_ct_per_kwh_heat
FROM best;
