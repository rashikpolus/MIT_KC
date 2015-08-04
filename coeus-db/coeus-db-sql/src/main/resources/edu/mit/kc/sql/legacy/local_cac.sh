echo `date` 'Starting load.sh ** CAC Data load - Production'

cd /home/coeus/cac
rm -f /home/coeus/cac/cac_load.log

DST_FILE="/home/coeus/cac/archive/cac.tab"
SUFFIX=`date +%F.%k%M`

ORACLE_BASE=/oracle
export ORACLE_BASE

#ORACLE_HOME=$ORACLE_BASE/product/11.2.0.2/db
ORACLE_HOME=$ORACLE_BASE/product/11.2.0/db
export ORACLE_HOME

LD_LIBRARY_PATH=/usr/lib:/usr/shlib:$ORACLE_HOME/lib
export LD_LIBRARY_PATH

LIBHOME=$ORACLE_HOME/lib
export LIBHOME

PATH=$PATH:/usr/local/java/bin
export PATH

export CLASSPATH=$CLASSPATH:$ORACLE_HOME/jdbc/lib/ojdbc5.jar

echo 'before java'
java -cp CacDataLoad.jar cac.ReadCacContent
echo 'after java'

ORACLE_CONNECT_STRING=`cat /home/coeus/ospauser/id`


$ORACLE_HOME/bin/sqlplus $ORACLE_CONNECT_STRING @/home/coeus/cac/load.sql

echo $DST_FILE.$SUFFIX

mv /home/coeus/cac/CAC.tab $DST_FILE.$SUFFIX

mail -s "Load CAC Data - Production" coeus-test-email@mit.edu < /home/coeus/cac/cac_load.log

echo `date` 'End load.sh'

