#!/bin/ksh

# $1 is the data file
# $2 is the control file
# $3 is the target machine

USAGE="ftp.sh data_file control_file target_machine"

# check for 3 arguments
if (( $# != 3 ))
then
        print $USAGE
        exit
fi

# check for file existence
if [[ -e $1 && -e $2 ]]
then # files there, ftp them to target_matchine
#       print "Files exist"
        ftp -i -v $3 << EOD |
                put $1
                put $2
                bye
EOD
        if grep "File receive OK." > /dev/null
        then
                exit 0;
        else
                exit 1;
        fi

else # print error
#       print "Files not there"
        exit 1;
fi
