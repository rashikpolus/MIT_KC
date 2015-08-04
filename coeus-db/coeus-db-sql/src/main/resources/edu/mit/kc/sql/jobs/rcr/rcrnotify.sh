echo `date` 'Starting RCR Notifications ** KCDEV **'

export ORACLE_HOME=/oracle/product/11.2.0.4/db/
export LD_LIBRARY_PATH=$ORACLE_HOME/lib
export PATH=$PATH:$LD_LIBRARY_PATH:$ORACLE_HOME/bin:/usr/local/bin
export TNS_ADMIN=/oracle/network/admin/
scriptDir="/opt/kc/jobs/rcr"
cd $scriptDir
tod=$(date +%Y%m%d%H%M)
echo $tod
echo "spool rcr_notifiy-${tod}.log"
ORACLE_CONNECT_STRING=`cat /opt/kc/dbcreds/kcdevid`

$ORACLE_HOME/bin/sqlplus $ORACLE_CONNECT_STRING @'$scriptDir'/notify_rcr.sql > logs/rcr_notifiy-${tod}.log
mail -s "RCR Notifications - KCDEV" kc-mit-dev@mit.edu < '$scriptDir'/logs/notifiy_rcr-${tod}.log
echo `date` 'End RCR rcr_notify.sh'