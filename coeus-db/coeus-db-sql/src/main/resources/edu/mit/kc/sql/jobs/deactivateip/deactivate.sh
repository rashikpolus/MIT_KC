echo `date` 'Starting Deactivate IPs ** KCDEV **'

export ORACLE_HOME=/oracle/product/11.2.0.4/db/
export LD_LIBRARY_PATH=$ORACLE_HOME/lib
export PATH=$PATH:$LD_LIBRARY_PATH:$ORACLE_HOME/bin:/usr/local/bin
export TNS_ADMIN=/oracle/network/admin/
scriptDir="/opt/kc/jobs/deactivateip"
cd $scriptDir
tod=$(date +%Y%m%d%H%M)
echo $tod
echo "spool deactivateip-${tod}.log"
ORACLE_CONNECT_STRING=`cat /opt/kc/dbcreds/kcdevid`
$ORACLE_HOME/bin/sqlplus  $ORACLE_CONNECT_STRING @deactivate_inst_proposal.sql > logs/deactivateip-${tod}.log

echo `date` 'Deactivate IPs deactivate.sh ** KCDEV **'

mail -s "Deactivate IPs log - KCDEV" kc-mit-dev@mit.edu < /opt/kc/jobs/deactivateip/logs/deactivateip-${tod}.log
