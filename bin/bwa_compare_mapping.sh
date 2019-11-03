#!/bin/bash

simdir=$1
#Test for commandline arguments
if [ $# -eq 0 ]; then
    printf "No arguments provided, input path to directory containing simulated reads: \n"
    read -e simdir
fi

while true; do
    #Assigning variables
    coveragetmp=$(echo "$simdir" | awk -F "coverage" '{print $2}')
    coverage=$(echo "$coveragetmp" | awk -F "_" '{print $1}')
    start_range=$(echo "$simdir" | awk -F "error|-" '{print $2}')
    max_range=$(echo "$simdir" | awk -F "-|step" '{print $2}')
    err_steptmp=$(echo "$simdir" | awk -F "step" '{print $2}')
    err_step=$(echo "$err_steptmp" | awk -F "/" '{print $1}')
    outfile=/data/graphs/human_21_and_22/output/bwa/mapping_accuracy/bwamap_e${start_range}-${max_range}_c$coverage.tsv

    #Setting directory names and path
    dirnametmp="coverage"$(echo "$simdir" | awk -F "coverage" '{print $2}')
    dirname=$(echo "$dirnametmp" | awk -F "/" '{print $1}')
    aligndir=/data/graphs/human_21_and_22/output/bwa/np_align/$dirname

    printf "\nRunning program with these parameters:\nError start:\t$start_range\nError max:\t$max_range\nError step:\t${err_step} \
    	    \nCoverage:\t$coverage\n\nDo you want to continue?     [y/n]\nOr to use another directory? [d]\n"
    read ynd
    case $ynd in
	[Yy] )
	    mkdir -p $aligndir
	    printf "Matching mapping accuracy with increasing error rate. Coverage: $coverage\nErrRate\tMatch\n" > $outfile
	    for i in $(seq $start_range $err_step $max_range)
	    do
		#Finding number of reads using wc
		a=($(wc -l $simdir/positions_c${coverage}_e${i}.tsv))
		reads=${a[0]}

		printf "\nBWA MAPPING, PIPING TO NUMPY\nNumber of Reads: $reads\n\n"
		bwa mem ref.fa $simdir/simulated_reads_c${coverage}_e${i}.fa | numpy_alignments store sam $aligndir/bwa_c${coverage}_e${i} $reads
		printf "\nSTORING TRUTH\n\n"
		cat $simdir/positions_c${coverage}_e${i}.tsv | numpy_alignments store truth $aligndir/truth_c${coverage}_e${i} $reads
		printf "\nGETTING CORRECT RATES\n"
		numpy_alignments get_correct_rates $aligndir/truth_c${coverage}_e${i} $aligndir/bwa_c${coverage}_e${i} | awk 'FNR == 2 {print '$i' "\t" $2}' >> $outfile
	    done
	    printf "\nDONE!\n\n"
	    exit
	    ;;
	[Nn] )
	    echo "EXITING PROGRAM"
	    exit
	    ;;
	[Dd] )
	    printf "Input path to directory containing simulated reads: \n"
	    read -e dir
	    continue 1 #starts over from the outmost loop (the while loop)
	    ;;
	* )
	    echo "ERROR:Invalid input... try again"
	    ;;
    esac
done
