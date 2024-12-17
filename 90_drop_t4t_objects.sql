SET SERVEROUTPUT ON;
DECLARE
vsql VARCHAR2(4000);
BEGIN

FOR rowx IN (
SELECT object_name, object_type, temporary FROM ALL_OBJECTS WHERE regexp_like(object_name, '^t4t', 'i') AND object_type IN ('TABLE', 'PACKAGE')
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

