-- Q4: How does renewable share relate to price?
-- Answer: ~21 ct/kWh at 10-20 % renewables, ~11 ct at 50 %, ~2 ct at 100 %, below zero above 120 %. Green hours are cheap hours.
SELECT
  CAST(FLOOR(r.ren_share_pct / 10) * 10 AS INT64) AS ren_share_from_pct,
  COUNT(*) AS quarter_hours,
  ROUND(AVG(p.price_eur_mwh) / 10, 2) AS avg_price_ct_kwh
FROM (SELECT DISTINCT timestamp_utc, price_eur_mwh
      FROM `german-power-prices.energy_data.price`) AS p
JOIN (SELECT DISTINCT timestamp_utc, ren_share_pct
      FROM `german-power-prices.energy_data.renewable_share`) AS r
  ON p.timestamp_utc = r.timestamp_utc
GROUP BY ren_share_from_pct
ORDER BY ren_share_from_pct;
