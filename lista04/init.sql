CREATE TABLE messages (
  id INTEGER NOT NULL PRIMARY KEY,
  date_message           TIMESTAMP,
  id_member_anonymous    TEXT,
  id_group_anonymous     TEXT,
  media                  TEXT,
  media_type             TEXT,
  media_url              TEXT,
  has_media              BOOLEAN,
  has_media_url          BOOLEAN,
  text_content_anonymous TEXT,
  dataset_info_id        INTEGER,
  date_system            TIMESTAMP,
  score_sentiment        REAL,
  score_misinformation   REAL,
  id_message             INTEGER,
  message_type           TEXT,
  messenger              TEXT,
  media_name             TEXT,
  media_md5              TEXT,
  text_no_stopwords      TEXT,
  word_count             INTEGER,
  viral                  TEXT,
  misinformation_category TEXT,
  sentiment              TEXT
);

COPY messages
FROM '/docker-entrypoint-initdb.d/fakeTelegramBR_2022_clean.csv'
DELIMITER ','
CSV HEADER;
