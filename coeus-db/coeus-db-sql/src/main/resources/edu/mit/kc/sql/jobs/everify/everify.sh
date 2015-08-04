echo `date` 'Starting E-Verify Notifications ** KCDEV **'

export ORACLE_HOME=/oracle/product/11.2.0.4/db/
export LD_LIBRARY_PATH=$ORACLE_HOME/lib
export PATH=$PATH:$LD_LIBRARY_PATH:$ORACLE_HOME/bin:/usr/local/bin
export TNS_ADMIN=/oracle/network/admin/
scriptDir="/opt/kc/jobs/everify"
cd $scriptDir
tod=$(date +%Y%m%d%H%M)
echo $tod
echo "spool everify-${tod}.log"
ORACLE_CONNECT_STRING=`cat /opt/kc/dbcreds/kcdevid`
$ORACLE_HOME/bin/sqlplus $ORACLE_CONNECT_STRING @notify_everify.sql > logs/everify-${tod}.log

mail -s "E-Verify Notification log" kc-mit-dev@mit.edu < /opt/kc/jobs/everify/logs/everify-${tod}.log
echo `date` 'End E-Verify Notification.sh ** KCDEV **'
