#!/bin/bash

dir=$1
#Test for commandline arguments
if [ $# -eq 0 ]; then
    printf "No arguments provided, input path to directory containing numpy alignment files (.npz): \n"
    read -e dir
fi

while true; do
    #Assigning variables
    dirname=$(echo "$dir" | awk -F "/" '{print $(NF-2)}')
    coverage=$(echo "$dirname" | awk -F "coverage|-" '{print $2}')
    start_range=$(echo "$dirname" | awk -F "error|-" '{print $3}')
    max_range=$(echo "$dirname" | awk -F "-|step" '{print $4}')
    err_step=$(echo "$dirname" | awk -F "step" '{print $3}')

    printf "\nRunning program with these parameters:\nError start:\t$start_range\nError max:\t$max_range\nError step:\t${err_step} \
    	    \nCoverage:\t$coverage\n\nDo you want to continue?     [y/n]\nOr to use another directory? [d]\n"
    read ynd
    case $ynd in
	[Yy] )	    
	    printf "Matching mapping accuracy with increasing error rate. Coverage: $coverage\nErrRate\tMatch\n" > error_match$coverage.txt
	    for i in $(seq $start_range $err_step $max_range)
	    do
		numpy_alignments get_correct_rates $dir/truth_c${coverage}_e${i} $dir/bwa_c${coverage}_e${i} | awk 'FNR == 2 {print '$i' "\t" $2}' >> error_match$coverage.txt
	    done
	    exit
	    ;;
	[Nn] )
	    echo "EXITING PROGRAM"
	    exit
	    ;;
	[Dd] )
	    printf "Input path to directory containing numpy alignment files (.npz): \n"
	    read -e dir
	    continue 1 #starts over from the outmost loop (the while loop)
	    ;;
	* )
	    echo "ERROR:Invalid input... try again"
	    ;;
    esac

    #Print rates on screen
clear
cat error_match$coverage.txt
done
