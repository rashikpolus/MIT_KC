update narrative set module_title = 'migrated module title'
where module_title is null
/
commit
/
update narrative set comments = 'migrated comments'
where comments is null
/
commit
/