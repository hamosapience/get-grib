#!/bin/bash
echo 'WRITE '`date`
table_name='meteo."grib-forecast"'
columns="(fdate,lon,lat,level,tmp,ugrd,vgrd)"
user="meteo"
logfile="./"`date +%d%m%y`".write.log"

touch "$logfile"
for f in *.csv; do
    [[ -e $f ]] || continue
    val=""
    while read line; do
	    val=$val,$(echo "$line" | awk -F "," '{ print "(\x27" $1 "\x27,\x27" $2 "\x27,\x27" $3 "\x27,\x27" $4 "\x27,\x27" $5 "\x27,\x27" $6 "\x27,\x27" $7 "\x27)" }')
   	done < "$f"
   	val=${val:1}
   	query="INSERT INTO $table_name $columns VALUES $val;"
   	psql -U $user -c "$query" &>> $logfile
done

