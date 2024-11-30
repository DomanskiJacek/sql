SET SERVEROUTPUT ON;
DECLARE
    vsql VARCHAR2(4000);
    verrinfo VARCHAR2(4000);
    vcols VARCHAR2(4000);

FUNCTION show_changed_columns(ssql IN VARCHAR2, errinfo OUT VARCHAR2) 
    RETURN VARCHAR2
IS
    cursor_id          NUMBER;
    cursor_execute     NUMBER;
    TYPE tp_v2_table IS TABLE OF dbms_sql.varchar2_table;
    vall tp_v2_table ;
    
    vfirst dbms_sql.varchar2_table;
    vnext dbms_sql.varchar2_table;
    vchanged dbms_sql.number_table;
    cols_tab DBMS_SQL.DESC_TAB;
    cols_num INTEGER;
    iter INTEGER;
    vsep VARCHAR2(100);     
    vcolval VARCHAR(4000);
    rowcnt INTEGER :=1 ;
    ret_columns VARCHAR2(4000);
    
BEGIN
    BEGIN
        cursor_id := dbms_sql.open_cursor;
        dbms_sql.parse(cursor_id, ssql, dbms_sql.NATIVE);
        dbms_sql.describe_columns(cursor_id, cols_num, cols_tab);
        EXCEPTION
            WHEN OTHERS THEN 
                errinfo := 'invalid sql statement';
                RETURN '';
    END;
    
    vall := new tp_v2_table();
    vall.extend(cols_tab.LAST);
    FOR iter IN 1..vall.LAST LOOP
        vall(iter) := new dbms_sql.varchar2_table();
    END LOOP;
    FOR iter IN 1..cols_tab.LAST LOOP
        dbms_sql.define_array(cursor_id, iter, vall(iter), 10, 3);
    END LOOP;

    FOR iter IN 1..cols_tab.LAST LOOP
        dbms_sql.define_column(cursor_id, iter, vcolval, 4000);
    END LOOP;

    cursor_execute := dbms_sql.execute(cursor_id);

    rowcnt := 0;
    WHILE (dbms_sql.fetch_rows(cursor_id))>0 LOOP
        rowcnt := rowcnt + 1;
        IF rowcnt = 1 THEN
            FOR iter IN 1..cols_tab.LAST
            LOOP
                dbms_sql.column_value(cursor_id, iter, vfirst(iter));
                vchanged(iter) := 0;
            END LOOP;
        END IF;

        IF rowcnt > 1 THEN
            FOR iter IN 1..cols_tab.LAST
            LOOP
                dbms_sql.column_value(cursor_id, iter, vnext(iter));
                IF (vfirst(iter) <> vnext(iter) OR vfirst(iter) IS NULL OR vnext(iter) IS NULL) AND NOT (vfirst(iter) IS NULL AND vnext(iter) IS NULL) THEN
                    vchanged(iter) := 1;
                END IF;
            END LOOP;
        
        END IF;

    END LOOP;
    IF rowcnt = 0 THEN
        errinfo := 'no records to analyze';
        RETURN '';
    END IF;
    
    IF vchanged.count <=0 then
        RETURN '';
    END IF;
        
    vsep := '';
    FOR iter IN 1..cols_tab.LAST LOOP
        IF vchanged(iter) > 0 THEN
            ret_columns := ret_columns || vsep || cols_tab(iter).col_name;
            vsep := ', ';
        END IF;
    END LOOP;

    dbms_sql.close_cursor(cursor_id);
    
    RETURN ret_columns;
END;

BEGIN
    -- another statement:  SELECT * FROM test_change_cols WHERE prod_id='PRODUCT1' 
    vsql := q'[
        SELECT 1 as cola, 2 as colb, 3 as colc FROM dual
        UNION ALL
        SELECT 1, 2, 33 FROM dual
    ]';
    
    vcols := show_changed_columns(vsql, verrinfo);
    
    IF verrinfo IS NOT NULL THEN
        dbms_output.put_line(verrinfo);
    ELSIF vcols IS NULL THEN
        dbms_output.put_line('no column changed');
    ELSE
        dbms_output.put_line('changed columns: ' || vcols);
    END IF;
END;
/
