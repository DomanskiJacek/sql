CREATE TABLE t4t_sales AS 
WITH tta AS (
SELECT LEVEL AS amonth FROM dual CONNECT BY LEVEL <=36
)  
, ttb AS (
SELECT 'Y202' || floor((amonth-1)/12) AS byear
    , MOD(amonth-1,12)+1 AS nummonth, 'M'||substr('00'|| (MOD(amonth-1,12)+1), -2) AS bmonth 
    , 'Q' || substr('00' || to_char(MOD(floor((amonth-1)/3),4)+1),-1) AS bquarter
    , 1000 + amonth + MOD(amonth,5)*100 AS bsale
    , CAST('' AS VARCHAR2(4000)) description
FROM tta
)   SELECT * FROM ttb ORDER BY byear, bmonth;
