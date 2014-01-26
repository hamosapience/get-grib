#!/bin/sh
LEFT_LON=35
RIGHT_LON=40

UP_LAN=56.5
DOWN_LAN=54

date_auto=`date -u +%Y%m%d`
time_auto=`date -u +%H`

if [ $time_auto -le 6 ]
then
    time="00";
fi

if [ $time_auto -gt 6 ] && [ $time_auto -lt 12 ];
then 
    time="06";
fi

if [ $time_auto -gt 12 ] && [ $time_auto -lt 18 ];
then
    time="12";
fi

if [ $time_auto -gt 18 ];
then
    time="18";
fi

echo $time;

levels="200_mb:400_mb:500_mb"

#date=`date +%Y%m%d00`
filename='gfs.t18z.pgrb2f00';
converted='temp.csv'
out='out.csv'
date_auto=$date_auto$time;

rm -f data.csv

perl get_gfs.pl data $date_auto 0 12 24 UGRD:VGRD $levels .

./wgrib2 $filename -csv $converted

cat $converted | awk -F ',' -v LL="$LEFT_LON" -v RL="$RIGHT_LON" -v UL="$UP_LAN" -v DL="$DOWN_LAN" '$5 >= LL && $5 <= RL && $6 >= DL && $6 <=UL' > $out
cat out.csv | awk -F "," '{ print $5","$6 }' | sort | uniq > coords.txt

while read line; do
    #echo $line
    #cat out.csv | fgrep ,$line, | sed '$!N;s/\n/,/' | awk -F "," '{ print;}'
    #Дата, долгота, широта, уровень, UGRD, VGRD 
    cat out.csv | fgrep ,$line, | sed '$!N;s/\n/,/' | awk -F "," '{ print $1 "," $5 "," $6 "," $4 "," $7 "," $14 }' >> data.csv  
done < coords.txt


rm $converted
rm $out

