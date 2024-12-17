-- merge to manipulate t4t_sales; discount for every september
MERGE INTO t4t_sales ts USING
(
    with tta as
    (
        SELECT 9 as discount_month FROM dual 
    )
    SELECT byear, nummonth , round(bsale*0.97, 2) as newsale, 'DISCOUNT' as newdescription FROM t4t_sales 
        INNER JOIN tta ON tta.discount_month=t4t_sales.nummonth
) tnew ON (tnew.byear=ts.byear AND tnew.nummonth=ts.nummonth)
WHEN MATCHED THEN 
    UPDATE SET ts.bsale=tnew.newsale, ts.description=ts.description || '; ' || tnew.newdescription WHERE ts.description IS NULL;
    
COMMIT;

-- listagg with overflow
WITH tta AS (
SELECT level as lvl , LEVEL || ' Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec convallis est mollis dui pretium accumsan quis eget dui. Maecenas auctor ac ex et luctus. Integer vitae interdum lectus. Morbi ut feugiat nulla, sit amet facilisis tellus'
    as longline
    FROM dual CONNECT BY level<100
)
SELECT listagg(longline, ';' ON OVERFLOW TRUNCATE) within group (order by lvl) FROM tta;

-- regexp_substr to get words from sentence
WITH tta AS (
    SELECT 1 AS word_id, 'to jest przykladowe zdanie' word FROM dual
)
SELECT word_id, regexp_substr (word, '[^ ]+', 1, rn) val
FROM   tta
CROSS  JOIN LATERAL (
  SELECT LEVEL rn FROM dual
  CONNECT BY LEVEL <=   
    LENGTH ( word ) - LENGTH ( REPLACE ( word, ' ' ) ) + 1
    )
;

-- contacenate words
with tta as 
(
SELECT column_value FROM sys.odcivarchar2list ('This', 'function', 'takes', 'an', 'optional', 'PARTITION', 'BY', 'clause', 'followed', 'by', 'a', 'mandatory', 'ORDER', 'BY', '...', 'DESC', 'clause.', 'The', 'PARTITION', 'BY', 'key', 'must', 'be', 'a', 'subset', 'of', 'the', 'GROUP', 'BY', 'key.', 'The', 'ORDER', 'BY', 'clause', 'must', 'include', 'either')
)  
SELECT listagg(column_value, ' ') within group (order by 1) as colname FROM tta 
WHERE 1=1
	AND regexp_like(column_value, 'a', 'i')
;

-- compare current sale with previous 3 months
WITH tta AS (
SELECT byear, nummonth, bmonth, bquarter, bsale, description, round(AVG(bsale) OVER (ORDER BY byear, nummonth ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING),2) AS prev_bsale   FROM t4t_sales
)
SELECT byear, nummonth, bmonth, bquarter, bsale, description, prev_bsale, 
    CASE WHEN NVL(prev_bsale, bsale)<bsale THEN 'incease_in_sale' ELSE 'no increase' END AS trendx FROM tta
;