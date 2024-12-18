-- table is empty
SELECT * FROM t4t_tadr;

-- fill the table
INSERT INTO t4t_tadr (ID, adr)
WITH tta AS (
SELECT LEVEL AS ID, LEVEL-1 AS aa, LEVEL AS ab, LEVEL+1 AS ac FROM dual CONNECT BY LEVEL<6
) -- SELECT * FROM tta;
SELECT ID, t4t_tp_adr('ADR'||ID||'_line1', 'ADR'||ID||'_line2', NULL, NULL) FROM tta;
;
COMMIT
;

MERGE INTO t4t_tadr USING (
WITH tta AS (
SELECT LEVEL AS ID, LEVEL-1 AS aa, LEVEL AS ab, LEVEL+1 AS ac FROM dual CONNECT BY LEVEL<6
) 
SELECT ID, t4t_tp_nums(aa,ab,ac) newnums, t4t_tp_varchars('string'||aa, 'string'||ab, 'string'||ac) newvars FROM tta
) tm ON (tm.ID=t4t_tadr.ID)
WHEN MATCHED THEN 
    UPDATE SET t4t_tadr.nums=tm.newnums, t4t_tadr.vars=tm.newvars;
;
COMMIT
;

WITH tta AS (
SELECT ID, LAG(ID) OVER (ORDER BY ID) AS lagid FROM t4t_tadr
)
SELECT tta.ID, tta.lagid, ta.nums, tb.nums AS lagnums
    , ta.nums MULTISET UNION tb.nums AS multi_a
    , ta.nums MULTISET UNION DISTINCT tb.nums AS multi_b
        FROM tta
            INNER JOIN t4t_tadr ta ON ta.ID=tta.ID
            INNER JOIN t4t_tadr tb ON tb.ID=tta.lagid
;
