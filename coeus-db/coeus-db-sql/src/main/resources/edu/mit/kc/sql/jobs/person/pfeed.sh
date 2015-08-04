echo `date` 'Starting person_feed.sql ***KCDEV***'
export ORACLE_HOME=/oracle/product/11.2.0.4/db/
export LD_LIBRARY_PATH=$ORACLE_HOME/lib
export PATH=$PATH:$LD_LIBRARY_PATH:$ORACLE_HOME/bin:/usr/local/bin
export TNS_ADMIN=/oracle/network/admin/
scriptDir="/opt/kc/feeds/person/"
cd $scriptDir
tod=$(date +%Y%m%d%H%M)
echo $tod
echo "spool pfeed-${tod}.log"
ORACLE_CONNECT_STRING=`cat /opt/kc/dbcreds/kcdevid`
sqlplus $ORACLE_CONNECT_STRING @person_feed.sql > logs/pfeed-${tod}.log

echo `date` 'End pfeed.sh'

mail -s 'Person Feed - KCDEV - KCSO' kc-notifications@mit.edu < /opt/kc/feeds/person/logs/pfeed-${tod}.log
