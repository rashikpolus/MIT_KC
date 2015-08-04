echo `date` 'Starting get_and_load_file.sh ** citi load'

cd /home/coeus/citi

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
java citi.GetCitiContent
echo 'after java'

ORACLE_CONNECT_STRING=`cat /home/coeus/ospauser/id`


$ORACLE_HOME/bin/sqlplus $ORACLE_CONNECT_STRING @/home/coeus/citi/loadcoeus.sql
mail -s "citi feed log" citi-feed@mit.edu < /home/coeus/citi/citiout.log
echo `date` 'End get_and_load_file.sh'

