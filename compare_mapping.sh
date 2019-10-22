#!/bin/bash

echo "Input start range: "
read start_range

echo "Input max range: "
read max_range

echo "Input coverage: "
read coverage

echo "Input error rate step: "
read err_step

printf "Matching mapping accuracy with increasing error rate. Coverage: $coverage\nErrRate\tMatch\n" > error_match$coverage.txt
for i in $(seq $start_range $err_step $max_range)
do
    numpy_alignments get_correct_rates truth_c${coverage}_e${i} bwa_c${coverage}_e${i} | awk 'FNR == 2 {print '$i' "\t" $2}' >> error_match$coverage.txt
done
clear
cat error_match$coverage.txt
