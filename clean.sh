#/bin/bash
ls *.csv -tr | head -4 | sed -e "s/^/rm '/" -e "s/$/'/" | sh
clean_query='DELETE FROM meteo."grib-forecast" WHERE fdate IN (SELECT fdate FROM meteo."grib-forecast" GROUP BY fdate ORDER BY fdate LIMIT 4);'

sudo -u postgres psql -U postgres -c "$clean_query"
