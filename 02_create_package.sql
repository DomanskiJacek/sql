CREATE OR REPLACE PACKAGE t4t_test AS

TYPE t4t_tab_sales IS TABLE OF t4t_sales%rowtype;

FUNCTION getsales(num_of_m INTEGER) RETURN t4t_tab_sales PIPELINED;

END t4t_test;
/
CREATE OR REPLACE PACKAGE BODY t4t_test AS

FUNCTION getsales(num_of_m INTEGER) RETURN t4t_tab_sales PIPELINED
IS 
vsales t4t_tab_sales;
BEGIN
SELECT * BULK COLLECT INTO vsales FROM t4t_sales WHERE nummonth = num_of_m;

FOR I IN vsales.FIRST .. vsales.LAST
LOOP
vsales(I).DESCRIPTION := 'SOME LOGIC PERFORMED IN FUNCTION';
    PIPE ROW (vsales(I));
END LOOP;

END getsales;


END;
/