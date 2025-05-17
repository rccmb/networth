CREATE TABLE transactions (
  id SERIAL PRIMARY KEY,
  name TEXT DEFAULT 'Transaction',
  description TEXT DEFAULT '',
  amount NUMERIC NOT NULL,
  date DATE NOT NULL
);
