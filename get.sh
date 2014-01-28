#!/bin/sh
LEFT_LON=35
RIGHT_LON=40

UP_LAN=56.5
DOWN_LAN=54


date_auto=`date -u +%Y%m%d`
time_auto=`date -u +%H`

echo 'TimeAuto: '$time_auto

if [ $time_auto -le 6 ]
then
    time_man="0";
    filename_time="00";
fi

if [ $time_auto -gt 6 ] && [ $time_auto -le 12 ];
then 
    time_man="6";
    filename_time="06";
fi

if [ $time_auto -gt 12 ] && [ $time_auto -le 18 ];
then
    time_man="12";
    filename_time="12";
fi

if [ $time_auto -gt 18 ];
then
    time_man="18";
    filename_time="18";
fi

echo $time_man;



levels="200_mb:400_mb:500_mb"
params="UGRD:VGRD:TMP"

#date=`date +%Y%m%d00`
cycle="00";
filename="gfs.t00z.pgrb2f"$;
converted='temp.csv'
out='out.csv'
date_auto="$date_auto"00;

rm -f data.csv

perl get_gfs.pl data $date_auto 0 24 6 $params $levels . #запуск скрипта скачивания grib-файлов

for time in 00 06 12 18 24
do
    filename=gfs.t"$cycle"z.mastergrb2f"$time"
    ./wgrib2 $filename -csv $converted
    
done


# cat $converted | awk -F ',' -v LL="$LEFT_LON" -v RL="$RIGHT_LON" -v UL="$UP_LAN" -v DL="$DOWN_LAN" '$5 >= LL && $5 <= RL && $6 >= DL && $6 <=UL' > $out
# cat out.csv | awk -F "," '{ print $5","$6 }' | sort | uniq > coords.txt

# while read line; do
#     #echo $line
#     #cat out.csv | fgrep ,$line, | sed '$!N;s/\n/,/' | awk -F "," '{ print;}'
#     #Дата, долгота, широта, уровень, UGRD, VGRD 
#     cat out.csv | fgrep ,$line, | sed '$!N;s/\n/,/' | awk -F "," '{ print $1 "," $5 "," $6 "," $4 "," $7 "," $14 }' >> data.csv  
# done < coords.txt


# rm $converted
# rm $out

