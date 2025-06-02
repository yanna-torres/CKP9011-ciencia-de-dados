# Lista 04 - Análise Exploratória de Dados (Metabase Queries)

>Yanna Torres Gonçalves
>
>Matrícula: 587299
>
>Mestrado em Ciências da Computação

---

## 1. As quantidades de grupos, usuários e mensagens

Quantidade de Grupos:

```sql
SELECT COUNT(DISTINCT id_group_anonymous) AS total_groups FROM messages
```

Quantidade de Usuários:

```sql
SELECT COUNT(DISTINCT id_member_anonymous) AS total_users FROM messages
```

Quantidade de Usuários:

```sql
SELECT COUNT(*) AS total_messages FROM messages
```

## 2. A quantidade de mensagens que possuem apenas texto X mídia

```sql
SELECT 'Only Text' AS type, COUNT(*) AS count
FROM messages
WHERE text_content_anonymous IS NOT NULL AND has_media = FALSE

UNION ALL

SELECT 'With Media' AS type, COUNT(*) AS count
FROM messages
WHERE text_content_anonymous IS NOT NULL AND has_media = TRUE
```

## 3. Quantidade de mensagens por tipo de mídia (jpg, mp4 etc)

```sql
SELECT media_type, COUNT(*) AS total_messages
FROM messages
WHERE has_media = True
GROUP BY media_type
ORDER BY total_messages DESC
LIMIT 10
```

## 4. A relação entre a quantidade de mensagens e a quantidade de palavras presente nas mensagens

```sql
SELECT
  CONCAT(
    FLOOR(word_count / 50) * 50,
    '–',
    FLOOR(word_count / 50) * 50 + 49
  ) AS word_count_range,
  COUNT(*) AS message_count
FROM
  messages
WHERE word_count IS NOT NULL
GROUP BY
  FLOOR(word_count / 50)
ORDER BY
  FLOOR(word_count / 50)
```

---

## Itens 5 a 9

Não existem dados relacionados ao local.

---

## 10. As 30 URLs que mais se repetem (mais compartilhadas)

```sql
SELECT
  media_url as url,
  COUNT(*) AS total
FROM
  messages
WHERE
  media_url IS NOT NULL
GROUP BY
  media_url
ORDER BY
  total DESC
LIMIT
  30
```

## 11.  Os 30 domínios que mais se repetem (mais compartilhados)

```sql
WITH domain_stats AS (
    SELECT
        LOWER(
            substring(
                regexp_replace(media_url, 'https?://(www\.)?', '', 'gi'),
                '^([^/]+)'
            )
        ) AS domain,
        COUNT(*) AS total
    FROM messages
    WHERE media_url IS NOT NULL
    GROUP BY domain
)
SELECT *
FROM domain_stats
ORDER BY total DESC
LIMIT 30
```

## 12. Os 30 usuários mais ativos

```sql
SELECT
  id_member_anonymous,
  COUNT(*) AS total
FROM
  messages
WHERE
  id_member_anonymous IS NOT NULL
GROUP BY
  id_member_anonymous
ORDER BY
  total DESC
LIMIT
  30
```

## 13. Relação entre quantidade de mensagens contendo somente texto e mensagens com tendo mídia dos usuários mais ativos

```sql
SELECT
  id_member_anonymous,
  COUNT(*) AS total_messages,
  SUM(
    CASE
      WHEN has_media THEN 1
      ELSE 0
    END
  ) AS media_messages,
  SUM(
    CASE
      WHEN has_media THEN 0
      ELSE 1
    END
  ) AS text_only_messages
FROM
  messages
WHERE
  id_member_anonymous IS NOT NULL
GROUP BY
  id_member_anonymous
ORDER BY
  total_messages DESC
LIMIT
  10
```

## 14. Os 30 usuários que mais compartilharam texto

```sql
SELECT
    id_member_anonymous,
    COUNT(*) AS text_only_messages,
	SUM(CASE WHEN has_media THEN 1 ELSE 0 END) AS media_messages
FROM messages
WHERE id_member_anonymous IS NOT NULL
GROUP BY id_member_anonymous
ORDER BY text_only_messages DESC
LIMIT 30
```

## 15. Os 30 usuários que mais compartilharam mídias

```sql
SELECT
  id_member_anonymous,
  COUNT(
    CASE
      WHEN has_media THEN 1
      ELSE NULL
    END
  ) AS media_count
FROM
  messages
WHERE
  id_member_anonymous IS NOT NULL
  AND has_media = TRUE
GROUP BY
  id_member_anonymous
ORDER BY
  media_count DESC
LIMIT
  30
```

## 16. As 30 mensagens mais compartilhadas

```sql
SELECT
  text_content_anonymous AS message,
  COUNT(*) AS total_shares
FROM
  messages
WHERE
  text_content_anonymous IS NOT NULL
  OR text_content_anonymous != ''
GROUP BY
  text_content_anonymous
ORDER BY
  total_shares DESC
LIMIT
  30
```

## 17. As 30 mensagens mais compartilhadas em grupos diferentes

```sql
SELECT
  text_content_anonymous AS message,
  COUNT(DISTINCT id_group_anonymous) AS total_groups
FROM
  messages
WHERE
  text_content_anonymous IS NOT NULL
  AND id_group_anonymous IS NOT NULL
  AND text_content_anonymous != ''
GROUP BY
  text_content_anonymous
ORDER BY
  total_groups DESC
LIMIT
  30
```

## 18. Mensagens idênticas compartilhadas pelo mesmo usuário (e suas quantidades)

```sql
SELECT
  id_member_anonymous,
  text_content_anonymous,
  COUNT(*) AS total,
  COUNT(DISTINCT id_group_anonymous) AS total_groups
FROM
  messages
WHERE
  text_content_anonymous IS NOT NULL
  AND text_content_anonymous != ''
  AND id_member_anonymous IS NOT NULL
GROUP BY
  id_member_anonymous,
  text_content_anonymous
HAVING
  COUNT(*) > 1
ORDER BY
  total DESC
LIMIT 10
```

## 19. Mensagens idênticas compartilhadas pelo mesmo usuário em grupos distintos (e suas quantidades)

```sql
SELECT
  id_member_anonymous,
  text_content_anonymous AS message,
  COUNT(DISTINCT id_group_anonymous) AS total_groups
FROM
  messages
WHERE
  text_content_anonymous IS NOT NULL
  AND text_content_anonymous != ''
  AND id_member_anonymous IS NOT NULL
  AND id_group_anonymous IS NOT NULL
GROUP BY
  id_member_anonymous,
  text_content_anonymous
HAVING
  COUNT(DISTINCT id_group_anonymous) > 1
ORDER BY
  total_groups DESC
LIMIT 10
```

## 20. Os 30 unigramas, bigramas e trigramas mais compartilhados (após a remoção de stop words)

### Unigramas

```sql
SELECT
  word AS ngram,
  COUNT(*) AS total
FROM (
  SELECT
    regexp_split_to_table(lower(text_no_stopwords), '[^[:alnum:]]+') AS word
  FROM
    messages
  WHERE
    text_no_stopwords IS NOT NULL
    AND text_no_stopwords != ''
) AS words
WHERE
  word NOT LIKE 'http%'
  AND word NOT LIKE 'www%'
  AND word NOT LIKE 'com%'
  AND word NOT LIKE 't.me%'
  AND word NOT LIKE 'youtu%'
  AND length(word) > 1
GROUP BY
  word
ORDER BY
  total DESC
LIMIT 30
```

### Bigramas

```sql
WITH
  tokens AS (
    SELECT
      word
    FROM
      (
        SELECT
          regexp_split_to_table(lower(text_no_stopwords), '[^[:alnum:]]+') AS word
        FROM
          messages
        WHERE
          text_no_stopwords IS NOT NULL
          AND text_no_stopwords != ''
      ) AS words
  ),
  ngrams AS (
    SELECT
      word || ' ' || lead(word, 1) OVER () AS two_gram
    FROM
      tokens
  )
SELECT
  two_gram AS "2gram",
  count(*) AS COUNT
FROM
  ngrams
WHERE
  two_gram NOT LIKE '% % %'
GROUP BY
  two_gram
ORDER BY
  COUNT DESC
LIMIT
  30
```

### Trigramas

```sql
WITH
  tokens AS (
    SELECT
      word
    FROM
      (
        SELECT
          regexp_split_to_table(lower(text_no_stopwords), '[^[:alnum:]]+') AS word
        FROM
          messages
        WHERE
          text_no_stopwords IS NOT NULL
          AND text_no_stopwords != ''
      ) AS words
  ),
  ngrams AS (
    SELECT
      word || ' ' || lead(word, 1) OVER () || ' ' || lead(word, 2) OVER () AS three_gram
    FROM
      tokens
  )
SELECT
  three_gram AS "3gram",
  count(*) AS COUNT
FROM
  ngrams
WHERE
  three_gram NOT LIKE '% % % %'
GROUP BY
  three_gram
ORDER BY
  COUNT DESC
LIMIT
  30
```

## 21.  As 30 mensagens mais positivas (distintas)

```sql
SELECT DISTINCT
  text_content_anonymous AS message,
  score_sentiment
FROM
  messages
WHERE
  text_content_anonymous IS NOT NULL
  AND text_content_anonymous != ''
  AND score_sentiment IS NOT NULL
  AND score_sentiment >= 0.05
ORDER BY
  score_sentiment DESC
LIMIT
  30
```

## 22. As 30 mensagens mais negativas (distintas)

```sql
SELECT DISTINCT
  text_content_anonymous,
  score_sentiment
FROM
  messages
WHERE
  text_content_anonymous IS NOT NULL
  AND text_content_anonymous != ''
  AND score_sentiment IS NOT NULL
  AND score_sentiment <= 0.05
ORDER BY
  score_sentiment ASC
LIMIT
  30
```

## 23. O usuário mais otimista

```sql
SELECT
  id_member_anonymous,
  AVG(score_sentiment) AS avg_sentiment,
  COUNT(*) AS total_messages
FROM
  messages
WHERE
  score_sentiment IS NOT NULL
  AND id_member_anonymous IS NOT NULL
GROUP BY
  id_member_anonymous
HAVING
  COUNT(*) >= 10
ORDER BY
  avg_sentiment DESC
LIMIT
  1
```

## 24. O usuário mais pessimista

```sql
SELECT
  id_member_anonymous,
  AVG(score_sentiment) AS avg_sentiment,
  COUNT(*) AS total_messages
FROM
  messages
WHERE
  score_sentiment IS NOT NULL
  AND id_member_anonymous IS NOT NULL
GROUP BY
  id_member_anonymous
HAVING
  COUNT(*) >= 10
ORDER BY
  avg_sentiment ASC
LIMIT
  1
```

## 25. As 30 maiores mensagens

```sql
SELECT DISTINCT
  text_content_anonymous,
  LENGTH(text_content_anonymous) AS message_length
FROM
  messages
WHERE
  text_content_anonymous IS NOT NULL
  AND text_content_anonymous != ''
ORDER BY
  message_length DESC
LIMIT
  30
```

## 26. As 30 menores mensagens

```sql
SELECT DISTINCT
  text_content_anonymous,
  LENGTH(text_content_anonymous) AS message_length
FROM
  messages
WHERE
  text_content_anonymous IS NOT NULL
  AND text_content_anonymous != ''
ORDER BY
  message_length ASC
LIMIT
  30
```

## 27. O dia em que foi publicado a maior quantidade de mensagens

```sql
SELECT
  CAST(date_message AS DATE) AS message_day,
  COUNT(*) AS total_messages
FROM
  messages
WHERE
  date_message IS NOT NULL
GROUP BY
  message_day
ORDER BY
  total_messages DESC
LIMIT
  1
```

## 28. As mensagens que possuem as palavras “INTERVENÇÃO” e “MILITAR”

```sql
SELECT
    COUNT(*) as messages_with_the_words
FROM messages
WHERE text_content_anonymous IS NOT NULL
  AND LOWER(text_content_anonymous) LIKE '%intervenção%'
  AND LOWER(text_content_anonymous) LIKE '%militar%'
```

## 29. Quantidade de mensagens por dia e hora

```sql
SELECT
  DATE_TRUNC('hour', date_message) AS message_hour,
  COUNT(*) AS total_messages
FROM
  messages
WHERE
  date_message IS NOT NULL
GROUP BY
  message_hour
ORDER BY
  message_hour;
```

## 30. Quantidade de mensagens por hora

```sql
SELECT
  EXTRACT(
    HOUR
    FROM
      date_message
  ) AS hour_of_day,
  COUNT(*) AS total_messages
FROM
  messages
WHERE
  date_message IS NOT NULL
GROUP BY
  hour_of_day
ORDER BY
  hour_of_day
```

---

## Itens 31 e 32

Não é possível fazer a nuvem de palavras nem a rede interativa no Metabase

---

## 33. Proporção de mensagens com e sem URL

```sql
SELECT 'Without URL' AS type, COUNT(*) AS total
FROM messages
WHERE text_content_anonymous IS NOT NULL
  AND has_media_url = FALSE

UNION ALL

SELECT 'With URL' AS type, COUNT(*) AS total
FROM messages
WHERE text_content_anonymous IS NOT NULL
  AND has_media_url = TRUE
```

## 34. Proporção de desinformação

```sql
SELECT 'Misinformation' AS type, COUNT(*) AS total
FROM messages
WHERE misinformation_category IS NOT NULL
  AND misinformation_category = 'Misinformation'

UNION ALL

SELECT 'Neutral' AS type, COUNT(*) AS total
FROM messages
WHERE misinformation_category IS NOT NULL
  AND misinformation_category = 'Neutral'

UNION ALL

SELECT 'Non-misinformation' AS type, COUNT(*) AS total
FROM messages
WHERE misinformation_category IS NOT NULL
  AND misinformation_category = 'Non-misinformation'
```

## 35. Proporção de mensagens contendo mídia e desinformação

```sql
SELECT 'With Media' AS type, COUNT(*) AS total
FROM messages
WHERE misinformation_category IS NOT NULL
  AND misinformation_category = 'Misinformation'
  AND has_media is true

UNION ALL

SELECT 'Without Media' AS type, COUNT(*) AS total
FROM messages
WHERE misinformation_category IS NOT NULL
  AND misinformation_category = 'Misinformation'
  AND has_media is FALSE

```

## 36. Distribuição de mensagens por score de desinformação

```sql
SELECT
  CONCAT(ROUND((bucket - 1) * 0.1, 1), '–', ROUND(bucket * 0.1, 1)) AS range,
  COUNT(*) AS total
FROM (
  SELECT width_bucket(LEAST(score_misinformation, 0.9999), 0, 1, 10) AS bucket
  FROM messages
  WHERE score_misinformation IS NOT NULL
) sub
GROUP BY bucket
ORDER BY bucket
```

## 37. Proporção de sentimentos

```sql
SELECT 'Neutral' AS type, COUNT(*) AS total
FROM messages
WHERE sentiment IS NOT NULL
  AND sentiment = 'Neutral'

UNION ALL

SELECT 'Positive' AS type, COUNT(*) AS total
FROM messages
WHERE sentiment IS NOT NULL
  AND sentiment = 'Positive'

UNION ALL

SELECT 'Negative' AS type, COUNT(*) AS total
FROM messages
WHERE sentiment IS NOT NULL
  AND sentiment = 'Negative'
```

## 38. Distribuição de mensagens por score de sentimentos

```sql
SELECT
  CONCAT(
    ROUND((bucket - 1) * 0.2 - 1, 1),
    '–',
    ROUND(bucket * 0.2 - 1, 1)
  ) AS range,
  COUNT(*) AS total
FROM (
  SELECT width_bucket(
    LEAST(GREATEST(score_sentiment, -0.9999), 0.9999),
    -1, 1, 10
  ) AS bucket
  FROM messages
  WHERE score_sentiment IS NOT NULL
) sub
GROUP BY bucket
ORDER BY bucket
```

## 39. Proporção entre mensagens virais e não virais

```sql
SELECT 'Viral' AS type, COUNT(*) AS total
FROM messages
WHERE viral IS NOT NULL
  AND viral = 'True'

UNION ALL

SELECT 'Not Viral' AS type, COUNT(*) AS total
FROM messages
WHERE viral IS NOT NULL
  AND viral = 'False'
```

## 40. Algo que você julga importante e que ainda não foi solicitado

> Atividade dos 10 usuários mais ativos

```sql
SELECT 
    DATE(CAST(date_message AS TIMESTAMP)) AS message_date,
    id_member_anonymous,
    COUNT(*) AS daily_messages
FROM messages
WHERE id_member_anonymous IN (
    SELECT id_member_anonymous
    FROM messages
    GROUP BY id_member_anonymous
    ORDER BY COUNT(*) DESC
    LIMIT 10
)
GROUP BY message_date, id_member_anonymous
ORDER BY message_date, id_member_anonymous
```