#!/bin/sh
LEFT_LON=35
RIGHT_LON=40

UP_LAN=56.5
DOWN_LAN=54


date_auto=`date -u +%Y%m%d`
time_auto=`date -u +%H`

levels="200_mb:400_mb:500_mb"
params="UGRD:VGRD:TMP"

cycle="00";
converted='temp.csv'
out='out.csv'
date_auto="$date_auto"00;

rm -f data.csv

perl get_gfs.pl data $date_auto 0 24 6 $params $levels . # запуск скрипта скачивания grib-файлов

for time in 06
do
    grib_filename=gfs.t"$cycle"z.mastergrb2f"$time"
    ./wgrib2 $grib_filename -csv $converted # декодирование grib-файла в csv формат
    # фильтрация по координатам
    cat $converted | awk -F ',' -v LL="$LEFT_LON" -v RL="$RIGHT_LON" -v UL="$UP_LAN" -v DL="$DOWN_LAN" '$5 >= LL && $5 <= RL && $6 >= DL && $6 <=UL' > $out 
    
    data_filename=`head -1 out.csv | awk -F "," '{ print $2 }' | sed 's/"//g'` 

    # далее для группировки строк с различными параметрами но одной координатной ячейкой
    cat out.csv | awk -F "," '{ print $4 "," $5 "," $6}' | sort | uniq > coords.txt #получаем список координатных ячеек
    while read coord; do #обходим все ячейки
        #Дата, долгота, широта, уровень, TMP, UGRD, VGRD
        cat out.csv | fgrep ",$coord," | sed 's/$/,/' | xargs | paste -d , | awk -F "," '{ print $2 "," $5 "," $6 "," $4 "," $7 "," $14 "," $21 }' >> $data_filename.csv
    done < coords.txt


done



rm $converted
rm $out
rm coords.txt
rm gfs*

