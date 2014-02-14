#!/bin/bash
LEFT_LON=35
RIGHT_LON=40

UP_LAN=56.5
DOWN_LAN=54

#TODO: чтение параметров из файла
#TODO: запись в postgres
#TODO: кольцевой буфер заданной длины

declare -A convert_mb_to_ft
convert_mb_to_ft["1000 mb"]="364"
convert_mb_to_ft["925 mb"]="2498"
convert_mb_to_ft["850 mb"]="4781"
convert_mb_to_ft["700 mb"]="9882"
convert_mb_to_ft["500 mb"]="18289"
convert_mb_to_ft["400 mb"]="23574"
convert_mb_to_ft["300 mb"]="30065"
convert_mb_to_ft["250 mb"]="33999"
convert_mb_to_ft["200 mb"]="38662"


date_auto=`date -u +%Y%m%d`
time_auto=`date -u +%H`

levels="200_mb:400_mb:500_mb"
params="UGRD:VGRD:TMP"

cycle="00";
converted='temp.csv'
out='out.csv'
date_auto="$date_auto"00;

rm -f data.csv

perl get_gfs.pl data $date_auto 0 48 6 $params $levels . # запуск скрипта скачивания grib-файлов

for time in 06 12 18 24 30 36 42 48
do
    grib_filename=gfs.t"$cycle"z.mastergrb2f"$time"

    # декодирование grib-файла в csv формат
     ./wgrib2 $grib_filename -csv $converted 

    # фильтрация по координатам
     cat $converted | awk -F ',' -v LL="$LEFT_LON" -v RL="$RIGHT_LON" -v UL="$UP_LAN" -v DL="$DOWN_LAN" '$5 >= LL && $5 <= RL && $6 >= DL && $6 <=UL' > $out 
    
    #сформировать имя выходного файла == дате, на которую делается данный прогноз
    data_filename=`head -1 out.csv | awk -F "," '{ print $2 }' | sed 's/"//g'` 

    # далее группировка строк с различными параметрами но одной координатной ячейкой
    cat out.csv | awk -F "," '{ print $4 "," $5 "," $6}' | sort | uniq > coords.txt #получаем список координатных ячеек (широта, долгота, высота)
    while read coord; do #обходим все ячейки
        #Выводим данные в формате: Дата, долгота, широта, уровень, TMP, UGRD, VGRD
        cat out.csv | fgrep ",$coord," | sed 's/$/,/' | xargs | paste | awk -F "," '{ print $2 "," $5 "," $6 "," $4 "," $7 "," $14 "," $21 }' >> "$data_filename".csv

        #конвертация mb в ft
        for K in "${!convert_mb_to_ft[@]}";
        do
            sed -i "s/$K/${convert_mb_to_ft[$K]}/" "$data_filename".csv
        done;

    done < coords.txt


done



rm $converted
rm $out
rm coords.txt
rm gfs*

