UPDATE BUDGET SET BUDGET_NAME='budget-'||version_number WHERE BUDGET_NAME is null
/
UPDATE BUDGET SET CREATE_TIMESTAMP=UPDATE_TIMESTAMP WHERE CREATE_TIMESTAMP is null
/
UPDATE BUDGET SET CREATE_USER=UPDATE_USER WHERE CREATE_USER is null
/
commit
/