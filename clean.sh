#!/bin/bash
CUT_TAIL=4
TAIL_LENGTH=8
logfile="./"`date +%d%m%y`".clean.log"
echo "CLEAN "`date`
c=`ls | grep csv | wc -l`
if [ $c -lt $TAIL_LENGTH ] 
then
    echo "Not sufficient data" &>> $logfile
else
    ls *.csv -tr | head -4 | sed -e "s/^/rm '/" -e "s/$/'/" | sh &>> $logfile
    clean_query='DELETE FROM meteo."grib-forecast" WHERE fdate IN (SELECT fdate FROM meteo."grib-forecast" GROUP BY fdate ORDER BY fdate LIMIT 4);'
    psql -U meteo -c "$clean_query" &>> $logfile
fi
find *.log -mtime +5 -exec rm {} \;
