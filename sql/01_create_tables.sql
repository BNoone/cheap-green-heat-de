-- PP3 · External tables: BigQuery reads the Google Sheet live (never writes)
-- Rebuild: replace YOUR_SHEET_ID (4x) with the Sheet ID, then run this whole file once in BigQuery

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
