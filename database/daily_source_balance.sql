CREATE TABLE daily_source_balance (
  id SERIAL PRIMARY KEY,
  run_id INTEGER,
  source TEXT NOT NULL,
  balance NUMERIC(15, 2) NOT NULL,
  date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
)