
CREATE OR REPLACE TYPE t4t_tp_nums AS TABLE OF NUMBER;
/
CREATE OR REPLACE TYPE t4t_tp_varchars AS TABLE OF VARCHAR2(4000);
/
CREATE OR REPLACE TYPE t4t_tp_adr AS OBJECT (
    line1 VARCHAR2(4000), 
    line2 VARCHAR2(4000),
    date_from DATE,
    date_to DATE,
    MEMBER FUNCTION test_a RETURN NUMBER,
    MEMBER FUNCTION to_string RETURN VARCHAR2
    );
/
CREATE OR REPLACE TYPE BODY t4t_tp_adr AS 
MEMBER FUNCTION test_a RETURN NUMBER IS
    BEGIN
        RETURN 1;
    END;

MEMBER FUNCTION to_string RETURN VARCHAR2 IS
    stmp VARCHAR2(4000);
    BEGIN
        stmp := 'object TYPE t4t_tp_adr: ';
        stmp := stmp || ' line1: ' || line1;
        stmp := stmp || '; line2: ' || line2;
        stmp := stmp || '; date_from: ' || CASE WHEN date_from IS NULL THEN 'NULL' ELSE to_char(date_from, 'YYYY-MM-DD') END;
        stmp := stmp || '; date_to: ' || CASE WHEN date_to IS NULL THEN 'NULL' ELSE to_char(date_to, 'YYYY-MM-DD') END;
        RETURN stmp;
    END;
END;
/
CREATE TABLE t4t_tadr (
    ID INTEGER,
    adr t4t_tp_adr,
    nums t4t_tp_nums,
    vars t4t_tp_varchars
)
NESTED TABLE nums STORE AS t4t_tp_nums_nested
NESTED TABLE vars STORE AS t4t_tp_varchars_nested
;
/