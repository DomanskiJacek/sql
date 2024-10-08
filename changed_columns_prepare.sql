DECLARE
vsql VARCHAR2(4000);
BEGIN

BEGIN
EXECUTE IMMEDIATE 'DROP TABLE test_change_cols';
    EXCEPTION
        WHEN OTHERS THEN
            NULL;
END;

vsql := q'[
CREATE TABLE test_change_cols AS
WITH tta AS (
SELECT LEVEL AS lvl, trunc(add_months(sysdate,-1), 'MM') as cdate FROM dual CONNECT BY LEVEL<100
) 
SELECT lvl as record_id
, 'PRODUCT'||trunc((lvl-1)/10 +1 ) prod_id
, cdate + mod(lvl-1, 10) as cdate
, cast('CATEGORY_X' as varchar2(100)) AS categ_a
, cast('CATEGORY_X' as varchar2(100)) AS categ_b
, cast('CATEGORY_X' as varchar2(100)) AS categ_c
, cast('TYPE_X' as varchar2(100)) AS type_a
, cast('TYPE_X' as varchar2(100)) AS type_b
, cast('TYPE_X' as varchar2(100)) AS type_c
, 11.1 as value_a
, 11.1 as value_b
, 11.1 as value_c
FROM tta
]';

EXECUTE IMMEDIATE vsql;

vsql := q'[
UPDATE test_change_cols SET value_b=10, value_c=null WHERE prod_id='PRODUCT1' AND cdate=date'2024-09-03'
]';
-- UPDATE test_change_cols SET value_a=null WHERE prod_id='PRODUCT1' AND cdate<>date'2024-09-03'

EXECUTE IMMEDIATE vsql;
COMMIT;

END;
/
