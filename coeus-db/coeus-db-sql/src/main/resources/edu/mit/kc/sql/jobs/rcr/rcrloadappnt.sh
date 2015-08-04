echo `date` 'Starting rcrloadappnt.sh ** RCR load appointments KCDEV **'

export ORACLE_HOME=/oracle/product/11.2.0.4/db/
export LD_LIBRARY_PATH=$ORACLE_HOME/lib
export PATH=$PATH:$LD_LIBRARY_PATH:$ORACLE_HOME/bin:/usr/local/bin
export TNS_ADMIN=/oracle/network/admin/
scriptDir="/opt/kc/jobs/rcr"
cd $scriptDir
tod=$(date +%Y%m%d%H%M)
echo $tod
echo "spool rcr_appntload-${tod}.log"
ORACLE_CONNECT_STRING=`cat /opt/kc/dbcreds/kcdevid`

$ORACLE_HOME/bin/sqlplus $ORACLE_CONNECT_STRING @'$scriptDir'/rcr_loadappnt.sql > logs/rcr_appntload-${tod}.log

mail -s "KCQA - RCR data load log" kc-mit-dev@mit.edu < '$scriptDir'/logs/rcr_appntload-${tod}.log
echo `date` 'End RCR Data rcrloadappnt.sh'
