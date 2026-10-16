-- Q3: Cheapest 3-hour window per day: when does it usually start?
-- Answer: usually 12:00 or 13:00 (solar), but in winter (Nov to Feb) at night 01:00 to 03:00. Avg 4.3 ct/kWh.
WITH rolling AS (
  SELECT
    DATE(hour_local) AS day,
    hour_of_day AS window_start,
    AVG(price_ct_kwh) OVER (
      PARTITION BY DATE(hour_local)
      ORDER BY hour_local
      ROWS BETWEEN CURRENT ROW AND 2 FOLLOWING
    ) AS avg_3h_ct,
    COUNT(*) OVER (
      PARTITION BY DATE(hour_local)
      ORDER BY hour_local
      ROWS BETWEEN CURRENT ROW AND 2 FOLLOWING
    ) AS hours_in_window
  FROM `german-power-prices.energy_data.hourly_heat`
),
ranked AS (
  SELECT *,
    ROW_NUMBER() OVER (PARTITION BY day ORDER BY avg_3h_ct) AS rank_in_day
  FROM rolling
  WHERE hours_in_window = 3
)
SELECT
  window_start AS cheapest_window_starts_at,
  COUNT(*) AS days,
  ROUND(AVG(avg_3h_ct), 2) AS avg_price_in_window_ct_kwh
FROM ranked
WHERE rank_in_day = 1
GROUP BY window_start
ORDER BY days DESC;
