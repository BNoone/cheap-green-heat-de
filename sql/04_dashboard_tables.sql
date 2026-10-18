-- PP3 · Dashboard tables: results stored in BigQuery for Data Studio
-- Data Studio cannot read Sheet-backed tables directly, so these are materialised.
-- Rebuilt daily by Make.com (see 05_daily_refresh.sql)

CREATE OR REPLACE TABLE `german-power-prices.energy_data.dash_q1_negative_hours` AS
SELECT FORMAT_DATETIME('%Y-%m', hour_local) AS month,
       COUNTIF(price_ct_kwh < 0) AS negative_price_hours
FROM `german-power-prices.energy_data.hourly_heat`
GROUP BY month;

CREATE OR REPLACE TABLE `german-power-prices.energy_data.dash_q2_price_by_hour` AS
SELECT hour_of_day,
  ROUND(AVG(CASE WHEN EXTRACT(DAYOFWEEK FROM hour_local) IN (1, 7) THEN NULL ELSE price_ct_kwh END), 2) AS weekday_ct_kwh,
  ROUND(AVG(CASE WHEN EXTRACT(DAYOFWEEK FROM hour_local) IN (1, 7) THEN price_ct_kwh END), 2) AS weekend_ct_kwh
FROM `german-power-prices.energy_data.hourly_heat`
GROUP BY hour_of_day;

CREATE OR REPLACE TABLE `german-power-prices.energy_data.dash_q4_renewables_vs_price` AS
SELECT CAST(FLOOR(ren_share_pct / 10) * 10 AS INT64) AS ren_share_from_pct,
       ROUND(AVG(price_ct_kwh), 2) AS avg_price_ct_kwh
FROM `german-power-prices.energy_data.hourly_heat`
GROUP BY ren_share_from_pct;

CREATE OR REPLACE TABLE `german-power-prices.energy_data.dash_q5_heat_cost_by_hour` AS
SELECT hour_of_day,
  ROUND(AVG(price_ct_kwh), 2) AS avg_power_ct_kwh,
  ROUND(AVG(heat_cost_ct_kwh), 2) AS avg_heat_ct_kwh
FROM `german-power-prices.energy_data.hourly_heat`
WHERE heating_needed
GROUP BY hour_of_day;
