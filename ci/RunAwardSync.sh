#!/bin/bash
export ORACLE_HOME=/oracle/product/11.2.0/client
export LD_LIBRARY_PATH=$ORACLE_HOME/lib
export PATH=$PATH:$LD_LIBRARY_PATH:$ORACLE_HOME/bin:/usr/local/bin
env=$ENV
#scriptDir="../kcmit-db/kcmit-db-sql/src/main/resources/edu/mit/kc/sql/award_sync"
scriptDir="kcmit-db/kcmit-db-sql/src/main/resources/edu/mit/kc/sql/award_sync"
cd $scriptDir
tod=$(date +%Y%m%d%H%M)
echo $tod
echo "spool sqlrun-${tod}.log"
#sqlplus kcso/qawkly50kc@KCQAWKLY @start_sync.sql > logs/award_sync_qawkly-${tod}.log
sqlplus kcso/dev50kc@KCDEV @start_sync.sql > logs/award_sync-${tod}.log
#git add .
#git commit -am 'award sync ran on ${tod}'
#git push origin master
