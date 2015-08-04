#!/bin/bash
echo "Script executed from: ${PWD}"
BASEDIR=${PWD}
scriptDir="${BASEDIR}/../kcmit-db/kcmit-db-sql/src/main/resources/edu/mit/kc/sql"
script60Dir="${BASEDIR}/../../kc/coeus-db/coeus-db-sql/src/main/resources/org/kuali/coeus/coeus-sql/current/6.0.0" 
script60XDir="${BASEDIR}/../../kc/coeus-db/coeus-db-sql/src/main/resources/co/kuali/coeus/data/migration/sql/oracle"
echo "Base dir: ${BASEDIR}"

if [ $# -lt 1 ]
then
	echo "Usage: $0 userid password SID" 
	exit
fi

tod=$(date +%Y%m%d%H%M)
usrid=$1
pswd=$2 
sid=$3

cd ${scriptDir}/5.2
mkdir -p logs
echo "spool sql52run-${tod}.log"
sqlplus ${usrid}/${pswd}@${sid} @all-sql-52.sql > logs/sql52run-${tod}.log
mail -s "sql52run-${tod}.log" geot@mit.edu < logs/sql52run-${tod}.log

cd ${script60Dir}
mkdir -p logs
echo "spool kc60run-${tod}.log"
sqlplus ${usrid}/${pswd}@${sid}  @all-kc60.sql > logs/kc60run-${tod}.log
mail -s "kc60run-${tod}.log" geot@mit.edu < logs/kc60run-${tod}.log

cd ${scriptDir}/6.0
mkdir -p logs
echo "spool sql60run-${tod}.log"
sqlplus ${usrid}/${pswd}@${sid}  @all-sql-60.sql > logs/sql60run-${tod}.log
mail -s "sql60run-${tod}.log" geot@mit.edu < logs/sql60run-${tod}.log

cd ${scriptDir}/notification
mkdir -p logs
echo "spool notifrun-${tod}.log"
sqlplus ${usrid}/${pswd}@${sid} @all-notification-snapshot.sql > logs/notifrun-${tod}.log
mail -s "notifrun-${tod}.log" geot@mit.edu < logs/notifrun-${tod}.log

cd ${scriptDir}/feed
mkdir -p logs
echo "spool feedrun-${tod}.log"
sqlplus ${usrid}/${pswd}@${sid}  @all-feed-snapshot.sql > logs/feedrun-${tod}.log
mail -s "feedrun-${tod}.log" geot@mit.edu < logs/feedrun-${tod}.log

cd ${script60XDir}
mkdir -p logs
echo "spool kc60Xrun-${tod}.log"
sqlplus ${usrid}/${pswd}@${sid}  @all-kc60X.sql > logs/kc60Xrun-${tod}.log
mail -s "kc60Xrun-${tod}.log" geot@mit.edu < logs/kc60Xrun-${tod}.log

cd ${scriptDir}/migration/Coeus_KCRoleRightsMigration
mkdir -p logs
echo "spool rolerefreshrun-${tod}.log"
sqlplus ${usrid}/${pswd}@${sid}  @all_role_rights.sql > logs/rolerefreshrun-${tod}.log
mail -s "rolerefreshrun-${tod}.log" geot@mit.edu < logs/rolerefreshrun-${tod}.log

cd ${scriptDir}/golive
mkdir -p logs
echo "spool golive-${tod}.log"
sqlplus ${usrid}/${pswd}@${sid}  @all_go_live.sql > logs/golive-${tod}.log
mail -s "rolerefreshrun-${tod}.log" geot@mit.edu < logs/golive-${tod}.log

exit;

