-- PP3 · Daily rebuild, run by Make.com every morning after the data load
-- Renews every BigQuery object, so none hits the sandbox's 60-day expiry
-- Order: 1) Sheet windows  2) COP lookup  3) hourly view  4) dashboard tables
-- Replace YOUR_SHEET_ID (4x) with the Sheet ID before running

CREATE OR REPLACE EXTERNAL TABLE `german-power-prices.energy_data.price` (
  timestamp_utc INT64,
  price_eur_mwh FLOAT64,
  loaded_at STRING
)
OPTIONS (
  format = 'GOOGLE_SHEETS',
  uris = ['https://docs.google.com/spreadsheets/d/YOUR_SHEET_ID'],
  sheet_range = 'price!A:C',
  skip_leading_rows = 1
);

CREATE OR REPLACE EXTERNAL TABLE `german-power-prices.energy_data.temperature` (
  timestamp_utc INT64,
  temp_c FLOAT64,
  loaded_at STRING
)
OPTIONS (
  format = 'GOOGLE_SHEETS',
  uris = ['https://docs.google.com/spreadsheets/d/YOUR_SHEET_ID'],
  sheet_range = 'temperature!A:C',
  skip_leading_rows = 1
);

CREATE OR REPLACE EXTERNAL TABLE `german-power-prices.energy_data.renewable_share` (
  timestamp_utc INT64,
  ren_share_pct FLOAT64,
  loaded_at STRING
)
OPTIONS (
  format = 'GOOGLE_SHEETS',
  uris = ['https://docs.google.com/spreadsheets/d/YOUR_SHEET_ID'],
  sheet_range = 'renewable_share!A:C',
  skip_leading_rows = 1
);

CREATE OR REPLACE EXTERNAL TABLE `german-power-prices.energy_data.run_log` (
  run_at STRING,
  status STRING,
  rows_added INT64,
  note STRING
)
OPTIONS (
  format = 'GOOGLE_SHEETS',
  uris = ['https://docs.google.com/spreadsheets/d/YOUR_SHEET_ID'],
  sheet_range = 'run_log!A:D',
  skip_leading_rows = 1
);

CREATE OR REPLACE TABLE `german-power-prices.energy_data.cop_lookup` AS
SELECT
  temp_c,
  ROUND(6.08 - 0.09 * ((40 - temp_c) - temp_c)
             + 0.0005 * POW((40 - temp_c) - temp_c, 2), 2) AS cop,
  temp_c < 15 AS heating_needed
FROM UNNEST(GENERATE_ARRAY(-20, 45)) AS temp_c;

CREATE OR REPLACE VIEW `german-power-prices.energy_data.hourly_heat` AS
WITH price_h AS (
  SELECT DIV(timestamp_utc, 3600) * 3600 AS hour_utc,
         AVG(price_eur_mwh) AS price_eur_mwh
  FROM (SELECT DISTINCT timestamp_utc, price_eur_mwh
        FROM `german-power-prices.energy_data.price`)
  GROUP BY hour_utc
),
ren_h AS (
  SELECT DIV(timestamp_utc, 3600) * 3600 AS hour_utc,
         AVG(ren_share_pct) AS ren_share_pct
  FROM (SELECT DISTINCT timestamp_utc, ren_share_pct
        FROM `german-power-prices.energy_data.renewable_share`)
  GROUP BY hour_utc
),
temp_h AS (
  SELECT DISTINCT timestamp_utc AS hour_utc, temp_c
  FROM `german-power-prices.energy_data.temperature`
)
SELECT
  t.hour_utc,
  DATETIME(TIMESTAMP_SECONDS(t.hour_utc), 'Europe/Berlin') AS hour_local,
  EXTRACT(HOUR FROM DATETIME(TIMESTAMP_SECONDS(t.hour_utc), 'Europe/Berlin')) AS hour_of_day,
  t.temp_c,
  c.cop,
  c.heating_needed,
  p.price_eur_mwh / 10 AS price_ct_kwh,
  p.price_eur_mwh / 10 / c.cop AS heat_cost_ct_kwh,
  r.ren_share_pct AS ren_share_pct
FROM temp_h t
LEFT JOIN price_h p ON p.hour_utc = t.hour_utc
LEFT JOIN ren_h r ON r.hour_utc = t.hour_utc
LEFT JOIN `german-power-prices.energy_data.cop_lookup` c
  ON c.temp_c = CAST(ROUND(t.temp_c) AS INT64);

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
