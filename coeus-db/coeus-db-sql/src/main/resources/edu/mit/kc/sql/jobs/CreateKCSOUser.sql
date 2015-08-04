drop user kcso cascade;
/
CREATE USER KCSO
 IDENTIFIED BY dev50kc
      DEFAULT TABLESPACE KCSO_DATA_TS01
 TEMPORARY TABLESPACE TEMP
 PROFILE DEFAULT
 ACCOUNT UNLOCK;
/
GRANT DBA TO KCSO;
/
GRANT CONNECT TO KCSO;
/
GRANT RESOURCE TO KCSO;
/
ALTER USER KCSO DEFAULT ROLE ALL;
/
GRANT UNLIMITED TABLESPACE TO KCSO;
/
ALTER USER KCSO QUOTA UNLIMITED ON KCSO_DATA_TS01;
/
SELECT   A.tablespace_name tablespace, D.mb_total,
         SUM (A.used_blocks * D.block_size) / 1024 / 1024 mb_used,
         D.mb_total - SUM (A.used_blocks * D.block_size) / 1024 / 1024 mb_free
FROM     v$sort_segment A,
         (
         SELECT   B.name, C.block_size, SUM (C.bytes) / 1024 / 1024 mb_total
         FROM     v$tablespace B, v$tempfile C
         WHERE    B.ts#= C.ts#
         GROUP BY B.name, C.block_size
         ) D
WHERE    A.tablespace_name = D.name
GROUP by A.tablespace_name, D.mb_total;
/