SET SERVEROUTPUT ON;
DECLARE
vsql VARCHAR2(4000);
BEGIN

FOR rowx IN (
SELECT object_name, object_type, temporary FROM ALL_OBJECTS tob WHERE regexp_like(object_name, '^t4t', 'i') AND object_type IN ('TABLE', 'PACKAGE','TYPE')
            AND NOT EXISTS(SELECT 1 FROM all_tables WHERE nested='YES' AND table_name=tob.object_name)
    ORDER BY case when object_type='TYPE' THEN 'ZZZZ' ELSE object_type END, object_name
)
LOOP
    IF rowx.temporary='Y' THEN
        vsql := 'TRUNCATE ' || rowx.object_type || ' ' || rowx.object_name || ';';
        dbms_output.put_line(vsql);
    END IF;

    vsql := 'DROP ' || rowx.object_type || ' ' || rowx.object_name || ';';
    dbms_output.put_line(vsql);
END LOOP;

END;

