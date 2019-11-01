#!/bin/bash

folder=$1
file=()

: '
Alternatively:
for files in "$folder"/* #It will go through the files alphabetically, therefore the [1] element will always be one step after the first element.
do
    filelist="$(basename "$files")"
    if [[ $filelist == *.npz ]]; then
	file+=($filelist)
    fi
done

coverage=$(echo "${file[0]}" | awk -F "_c|_e" '{print $2}')
start_range=$(echo "${file[0]}" | awk -F "_e|.npz" '{print $2}')
max_range=$(echo "${file[-1]}" | awk -F "_e|.npz" '{print $2}')
err_step=$(echo "${file[1]}" | awk -F "_e|.npz" '{print $2}') #This works because the for loop adds the files to the array alphabetically 
'

foldername=$(echo "$folder" | awk -F "/" '{print $(NF-2)}')
echo $foldername

coverage=$(echo "$foldername" | awk -F "coverage|-" '{print $2}')
start_range=$(echo "$foldername" | awk -F "error|-" '{print $3}')
max_range=$(echo "$foldername" | awk -F "-|step" '{print $4}')
err_step=$(echo "$foldername" | awk -F "step" '{print $3}')

printf "Matching mapping accuracy with increasing error rate. Coverage: $coverage\nErrRate\tMatch\n" > error_match$coverage.txt

for i in $(seq $start_range $err_step $max_range)
do
    numpy_alignments get_correct_rates $folder/truth_c${coverage}_e${i} $folder/bwa_c${coverage}_e${i} | awk 'FNR == 2 {print '$i' "\t" $2}' >> error_match$coverage.txt
done

#Print rates on screen
clear
cat error_match$coverage.txt
