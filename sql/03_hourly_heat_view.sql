-- PP3 · One row per hour: price, temperature, COP, heat cost, renewable share
-- Note: no rounding here on purpose. Round only in the final answers.
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
