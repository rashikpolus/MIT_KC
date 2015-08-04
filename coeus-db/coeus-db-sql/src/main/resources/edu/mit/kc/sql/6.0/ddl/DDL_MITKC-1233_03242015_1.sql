
ALTER TABLE DASH_BOARD_MENU_ITEMS
RENAME COLUMN OSP_ONLY_FLAG to MENU_TYPE_FLAG
/

ALTER TABLE DASH_BOARD_MENU_ITEMS
MODIFY MENU_TYPE_FLAG NULL
/

ALTER TABLE DASH_BOARD_MENU_ITEMS
ADD CONSTRAINT UQ_DASH_BOARD_MENU
UNIQUE (MENU_ITEM)
/
