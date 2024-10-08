# sql repository

## changed_columns
show columns in query that changed values; useful when analyzing queries with many columns
### two files involved:
#### changed_columns_prepare.sql
create and populate table test_change_cols with data
also update some record(s) for testing purpose
#### changed_columns_run.sql
execute function to get change columns; function defined in anonymous block

https://dbfiddle.uk/qA2OWC5A

## reorder_columns
changes the order of columns in a table

https://dbfiddle.uk/GFjjDxr5
