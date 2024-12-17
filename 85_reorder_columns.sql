DECLARE 
    vtable_name VARCHAR2(100) := 'T4T_TAB_REORDER';
    new_cols_order VARCHAR2(4000) := 'COL_F, COL_E' ; 
    str_imm VARCHAR2(4000);
    vcheck INTEGER;
    sinfo VARCHAR2(4000);
    
    cura SYS_REFCURSOR;
    vcolumn_name VARCHAR2(4000);
BEGIN

BEGIN
    str_imm := 'DROP TABLE ' || vtable_name;
    EXECUTE IMMEDIATE str_imm;
    EXCEPTION
        WHEN OTHERS THEN NULL;
END;

IF UPPER(vtable_name) = 'T4T_TAB_REORDER' THEN
    SELECT COUNT(1) INTO vcheck FROM user_tables WHERE table_name=vtable_name;
    IF vcheck = 0 THEN
        str_imm := 'CREATE TABLE T4T_TAB_REORDER ( col_a INT, col_b INT, col_c INT, col_d INT, col_e INT, col_f INT)';
        EXECUTE IMMEDIATE str_imm;
    END IF;
END IF;

str_imm := q'[SELECT LISTAGG(column_id || ': ' || column_name || '; ') WITHIN GROUP (ORDER BY column_id NULLS LAST) FROM all_tab_cols WHERE table_name=']';
str_imm := str_imm || vtable_name || '''';
EXECUTE IMMEDIATE str_imm INTO sinfo;
dbms_output.put_line('columns order before change: '|| sinfo);

BEGIN
    EXECUTE IMMEDIATE 'TRUNCATE TABLE t4t_temp_tabcols';             
    EXECUTE IMMEDIATE 'DROP TABLE t4t_temp_tabcols';             
    EXCEPTION
        WHEN OTHERS THEN NULL;
END;

str_imm := q'[
CREATE GLOBAL TEMPORARY TABLE t4t_temp_tabcols ON COMMIT PRESERVE ROWS AS 
    WITH tta as (
    SELECT ']' || new_cols_order || q'[' as new_cols_order FROM dual
    )
    SELECT 0 AS category, ']' || vtable_name || q'[' tab_name, level as ord_num, trim(regexp_substr(tta.new_cols_order, '[^,]+',1,level)) as col_name
    FROM tta
    CONNECT BY level <= length(tta.new_cols_order)-length(replace(tta.new_cols_order, ','))+1
    ORDER BY level
]';
EXECUTE IMMEDIATE str_imm;

EXECUTE IMMEDIATE 'SELECT col_name FROM t4t_temp_tabcols WHERE ord_num=1' INTO vcolumn_name; 
EXECUTE IMMEDIATE 'ALTER TABLE ' || vtable_name || ' MODIFY ' || vcolumn_name || ' VISIBLE';

BEGIN
    EXECUTE IMMEDIATE 'TRUNCATE TABLE t4t_temp_restofcols';             
    EXECUTE IMMEDIATE 'DROP TABLE t4t_temp_restofcols';             
    EXCEPTION
        WHEN OTHERS THEN NULL;
END;
str_imm := q'[
CREATE GLOBAL TEMPORARY TABLE t4t_temp_restofcols ON COMMIT PRESERVE ROWS AS 
select table_name, column_name, column_id, hidden_column 
    from all_tab_cols tta
    where table_name=']' || vtable_name || q'[' 
    AND NOT EXISTS(SELECT 1 FROM t4t_temp_tabcols ptt WHERE ptt.col_name=tta.column_name)
]';

EXECUTE IMMEDIATE str_imm;

OPEN cura FOR q'[SELECT column_name FROM t4t_temp_restofcols WHERE hidden_column='NO' ]';
LOOP 
    FETCH cura INTO vcolumn_name;
    EXIT WHEN cura%notfound;
    str_imm := 'ALTER TABLE ' || vtable_name || ' MODIFY ' || vcolumn_name || ' INVISIBLE';
    EXECUTE IMMEDIATE str_imm;
END LOOP;
CLOSE cura;

OPEN cura FOR 'SELECT col_name FROM t4t_temp_tabcols WHERE ord_num>1 ORDER BY ord_num';
LOOP
    FETCH cura INTO vcolumn_name;
    EXIT WHEN cura%notfound;
    str_imm := 'ALTER TABLE ' || vtable_name || ' MODIFY ' || vcolumn_name || ' INVISIBLE' ;
    EXECUTE IMMEDIATE str_imm;
    str_imm := regexp_replace(str_imm, 'INVISIBLE$', 'VISIBLE');    
    EXECUTE IMMEDIATE str_imm;
    EXECUTE IMMEDIATE 'commit';
END LOOP;
CLOSE cura;

OPEN cura FOR q'[SELECT column_name FROM t4t_temp_restofcols WHERE hidden_column='NO' ORDER BY column_id ]';
LOOP 
    FETCH cura INTO vcolumn_name;
    EXIT WHEN cura%notfound;
    str_imm := 'ALTER TABLE ' || vtable_name || ' MODIFY ' || vcolumn_name || ' VISIBLE';
    EXECUTE IMMEDIATE str_imm;
END LOOP;
CLOSE cura;

str_imm := q'[SELECT LISTAGG(column_id || ': ' || column_name || '; ') WITHIN GROUP (ORDER BY column_id NULLS LAST) FROM all_tab_cols WHERE table_name=']';
str_imm := str_imm || vtable_name || '''';
EXECUTE IMMEDIATE str_imm INTO sinfo;
dbms_output.put_line('columns order after change:  ' || sinfo);

END;
/