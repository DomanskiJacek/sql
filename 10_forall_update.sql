DECLARE
    TYPE t4t_tptab_sales IS TABLE OF t4t_sales%rowtype;
    vsales t4t_tptab_sales := new t4t_tptab_sales();
    vsales2 t4t_tptab_sales := new t4t_tptab_sales();
    vsales3 t4t_tptab_sales := new t4t_tptab_sales();

BEGIN
    SELECT * BULK COLLECT INTO vsales2 FROM t4t_test.getsales(7) WHERE byear='Y2020';
    SELECT * BULK COLLECT INTO vsales3 FROM t4t_test.getsales(5) WHERE byear='Y2020';
    
    vsales := vsales2 MULTISET UNION vsales3;     -- INTERSECT DISTINCT 

    FOR ii IN vsales.first .. vsales.last
    LOOP
        IF ii=7 THEN
            vsales(ii).description := vsales(ii).description || '; SOME LOGIC';
        END IF;
    END LOOP;

    FORALL ii IN 1..vsales.count
        UPDATE t4t_sales SET description=description || '; ' || vsales(ii).description
            WHERE byear=vsales(ii).byear AND nummonth=vsales(ii).nummonth
        ;
commit;
END;
