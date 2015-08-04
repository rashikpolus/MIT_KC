echo `date` 'Starting PI Expenditure Feed ***KCDEV***'

ORACLE_SID=KCDEV
export ORACLE_SID

ORACLE_HOME=/oracle/product/11.2.0.4/db
export ORACLE_HOME
tod=$(date +%Y%m%d%H%M)

ORACLE_CONNECT_STRING=`cat /opt/kc/dbcred/dbcred`
cd /opt/kc/feeds/piexpenditure
$ORACLE_HOME/bin/sqlplus  $ORACLE_CONNECT_STRING @/opt/kc/feeds/piexpenditure/load_dashboard_exp.sql > logs/load_dashboard_exp-${tod}.log

echo `date` 'End award_sync.sh'
mail -s 'PI Expenditure Loaded - KCDEV' kc-notifications@mit.edu < /opt/kc/feeds/logs/load_dashboard_exp-${tod}.log
