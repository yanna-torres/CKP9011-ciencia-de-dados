CREATE TABLE my_table (
  id SERIAL PRIMARY KEY,
  name TEXT,
  age INTEGER
);

COPY my_table(name, age)
FROM '/docker-entrypoint-initdb.d/fakeTelegramBR_2022_clean.csv'
DELIMITER ','
CSV HEADER;
