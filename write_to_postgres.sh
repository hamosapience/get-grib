#!/bin/bash
table_name='meteo."grib-forecast"'
columns="(fdate,lon,lat,level,tmp,ugrd,vgrd)"
for f in *.csv; do
    [[ -e $f ]] || continue
    val=""
    while read line; do
	    val=$val,$(echo "$line" | awk -F "," '{ print "(\x27" $1 "\x27,\x27" $2 "\x27,\x27" $3 "\x27,\x27" $4 "\x27,\x27" $5 "\x27,\x27" $6 "\x27,\x27" $7 "\x27)" }')
   	done < "$f"
   	val=${val:1}
   	query="INSERT INTO $table_name $columns VALUES $val;"
   	sudo -u postgres psql -U postgres -c "$query"
done

clean_query='DELETE FROM meteo."grib-forecast" WHERE fdate IN (SELECT fdate FROM meteo."grib-forecast" GROUP BY fdate ORDER BY fdate LIMIT 4);'