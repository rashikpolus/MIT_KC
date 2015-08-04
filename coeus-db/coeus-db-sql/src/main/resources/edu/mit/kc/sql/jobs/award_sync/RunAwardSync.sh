echo `date` 'Starting award sync from COEUS QA ***KCDEV***'

ORACLE_SID=KCDEV
export ORACLE_SID

ORACLE_HOME=/oracle/product/11.2.0.4/db
export ORACLE_HOME
tod=$(date +%Y%m%d%H%M)

ORACLE_CONNECT_STRING=`cat /opt/kc/dbcred/dbcred`
$ORACLE_HOME/bin/sqlplus  $ORACLE_CONNECT_STRING @/opt/kc/jobs/award_sync/start_sync.sql > logs/award_sync_qawkly-${tod}.log

echo `date` 'End award_sync.sh'
mail -s 'Award sync from COEUS QA - KCDEV' kc-mit-dev@mit.edu < /opt/kc/jobs/logs/award_sync_qawkly-${tod}.log
