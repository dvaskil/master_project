#!/bin/bash
'''
echo "Input coverage: "
read coverage

echo "Input start error range: "
read start_range

echo "Input max error range: "
read max_range

echo "Input error rate step: "
read err_step
'''
#Make file with rates

printf "Matching mapping accuracy with increasing error rate. Coverage: $coverage\nErrRate\tMatch\n" > error_match$coverage.txt
"""
for i in $(seq $start_range $err_step $max_range)
do
    numpy_alignments get_correct_rates truth_c${coverage}_e${i} bwa_c${coverage}_e${i} | awk 'FNR == 2 {print '$i' "\t" $2}' >> error_match$coverage.txt
done
"""

for files in .
do
    if [[ $files == *.npz ]]; then
	start_range=${files[1]} | grep
	max_range=${files[-1]} | grep
	err_step=${files[2]} - $start_range | grep
	for i in $(seq $start_range $err_step $max_range)
	do
	    numpy_alignments get_correct_rates truth_c${coverage}_e${i} bwa_c${coverage}_e${i} | awk 'FNR == 2 {print '$i' "\t" $2}' >> error_match$coverage.txt
	done
    fi
done

#Print rates on screen
clear
cat error_match$coverage.txt
