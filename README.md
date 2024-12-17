# sql repository

### all objects created in this example are named t4t* so can be easily found and droped

## drop objects
ora$ptt_test, t4t_sales, t4t_test, t4t_change_cols, t4t_tab_reorder, t4t_change_cols

## 01_create_table.sql
created table t4t_sales used in samples below

## 02_create_package.sql
created package: t4t_test, function getsales pipelined within

## 10_forall_update.sql
forall update

## 20_merge_and_others.sql
used: merge, listagg overflow, regexp_substr, sys.odcivarchar2list, window clause

## 30_bulk_collect.sql
anonymous block using bulk collect
the same logic performed in plain sql

## changed_columns
show columns in query that changed values; useful when analyzing queries with many columns
### two files involved:
#### 80_changed_columns_prepare.sql
create and populate table test_change_cols with data
also update some record(s) for testing purpose
#### 81_changed_columns_run.sql
execute function to get change columns; function defined in anonymous block

## 85_reorder_columns.sql
must be run with no sys priviledge otherwise: 54053. 0000 -  "The visibility of a column from a table owned by a SYS user cannot be changed."
changes the order of columns in a table

## 90_drop_t4t_objects.sql
generates script to DROP all objects with the name: t4t
script must be run manually