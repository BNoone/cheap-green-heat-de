-- PP3 · COP lookup: air-source heat pump with radiators, 1 °C bands
-- Source: When2Heat (Ruhnau et al. 2019), COP and heating curves
-- COP = 6.08 - 0.09*dT + 0.0005*dT^2, dT = sink - outdoor, sink = 40 - 1.0*outdoor
-- Range -20 to +45 °C covers last summer's heatwave; heating_needed flags hours below 15 °C
CREATE OR REPLACE TABLE `german-power-prices.energy_data.cop_lookup` AS
SELECT
  temp_c,
  ROUND(6.08 - 0.09 * ((40 - temp_c) - temp_c)
             + 0.0005 * POW((40 - temp_c) - temp_c, 2), 2) AS cop,
  temp_c < 15 AS heating_needed
FROM UNNEST(GENERATE_ARRAY(-20, 45)) AS temp_c;
