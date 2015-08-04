set define off;
INSERT INTO DASH_BOARD_MENU_ITEMS (DASH_BOARD_MENU_ITEM_ID, MENU_ITEM, MENU_ACTION, MENU_TYPE_FLAG, ACTIVE, UPDATE_TIMESTAMP, UPDATE_USER, VER_NBR, OBJ_ID)
VALUES (SEQ_DASH_BOARD_MENU_ITEM_ID.NEXTVAL, 'View S2S Submission List', '/kr-krad/lookup?methodToCall=start&viewId=AllNewDevelopmentProposals-LookupViewId', NULL, 'Y', sysdate, 'admin', 1, sys_guid())
/