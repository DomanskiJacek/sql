SET SERVEROUTPUT ON;
DECLARE
    sql_1 VARCHAR2(4000);
    int_1 INTEGER;
    TYPE tpa IS TABLE OF t4t_sales%rowtype INDEX BY BINARY_INTEGER;
    rows_a tpa;
    rec_cnt INTEGER :=0; 
    sum_of_rec NUMBER(12,2) :=0;
BEGIN

SELECT * BULK COLLECT INTO rows_a FROM t4t_sales ORDER BY byear, nummonth;

FOR ii IN rows_a.FIRST .. rows_a.LAST
LOOP
    IF MOD(ii, 2)=1 THEN
        rec_cnt := rec_cnt+1; 
        sum_of_rec := sum_of_rec+rows_a(ii).bsale;
    END IF;
END LOOP;

dbms_output.put_line('rec_cnt: ' || rec_cnt || '; sum_of_rec: ' || to_char(sum_of_rec, 'FM99999990D00'));

dbms_output.put_line('============= the same using plain sql:');

-- the same result using sql

WITH tta AS (
SELECT bsale, row_number() OVER (ORDER BY byear, nummonth) AS rown FROM t4t_sales ORDER BY byear, nummonth
)
SELECT COUNT(*), SUM(bsale) INTO rec_cnt, sum_of_rec FROM tta WHERE MOD(rown,2) = 1;

dbms_output.put_line('rec_cnt: ' || rec_cnt || '; sum_of_rec: ' || to_char(sum_of_rec, 'FM99999990D00'));

END;