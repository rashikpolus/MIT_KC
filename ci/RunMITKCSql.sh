#!/bin/bash
#export ORACLE_HOME=/oracle/product/11.2.0/client
#export LD_LIBRARY_PATH=$ORACLE_HOME/lib
#export PATH=$PATH:$LD_LIBRARY_PATH:$ORACLE_HOME/bin:/usr/local/bin
#env=$ENV
DEV_CONNECT_STRING=`cat kcdevid`
QAWKLY_CONNECT_STRING=`cat kcqawklyid`
STAGE_CONNECT_STRING=`cat kcstageid`
TRAIN_CONNECT_STRING=`cat kctrainid`
scriptDir="../kcmit-db/kcmit-db-sql/src/main/resources/edu/mit/kc/sql"
cd $scriptDir
git pull --rebase origin master
tod=$(date +%Y%m%d%H%M)
cd 6.0
if [ -s all-ddl-snapshot.sql -o -s all-dml-snapshot.sql ] 
then
	echo "spool sqlrun-${tod}.log"
	sqlplus $DEV_CONNECT_STRING @all-sql-snapshot.sql > logs/sqlrun-dev-${tod}.log
	sqlplus $QAWKLY_CONNECT_STRING @all-sql-snapshot.sql > logs/sqlrun-qawkly-${tod}.log
	sqlplus $TRAIN_CONNECT_STRING @all-sql-snapshot.sql > logs/sqlrun-train-${tod}.log
	sqlplus $STAGE_CONNECT_STRING @all-sql-snapshot.sql > logs/sqlrun-stage-${tod}.log
	cat all-ddl-snapshot.sql > "all-ddl-$tod.sql"
	cat all-dml-snapshot.sql > "all-dml-$tod.sql"
	> all-ddl-snapshot.sql;
	> all-dml-snapshot.sql;
fi ;
cd ../migration
if [[ -s all-migration-snapshot.sql ]] ; then
	echo "spool migrun-${tod}.log"
	sqlplus $DEV_CONNECT_STRING @all-migration-run.sql > logs/migrun-${tod}-dev.log
	sqlplus $QAWKLY_CONNECT_STRING @all-migration-run.sql > logs/migrun-${tod}-qawkly.log
	sqlplus $TRAIN_CONNECT_STRING @all-migration-run.sql > logs/migrun-${tod}-train.log
	sqlplus $STAGE_CONNECT_STRING @all-migration-run.sql > logs/migrun-${tod}-stage.log
	cat all-migration-snapshot.sql > "all-migration-$tod.sql"
	> all-migration-snapshot.sql;
fi ;
cd ../
git add .
git commit -am 'reset all snapshots'
git push origin master
