#!/bin/bash

infile=$1

#Test for commandline arguments
if [ $# -eq 0 ]; then
    printf "No arguments provided, input parameter file: \n"
    read -e infile
fi

while true; do
    #Setting parameter values
    start_range=$(awk 'FNR == 1 {print $2}' $infile)
    max_range=$(awk 'FNR == 2 {print $2}' $infile)
    error_step=$(awk 'FNR == 3 {print $2}' $infile)
    coverage=$(awk 'FNR == 4 {print $2}' $infile)

    dirname="coverage${coverage}_error${start_range}-${max_range}step${error_step}"
    simdir=~/data/human_21_and_22/output/simulated_reads/$dirname
    infilen=$(echo "$infile" | awk -F "/" '{print $(NF)}') 
    printf "\nRun with these parameters\nError start:\t$start_range\nError max:\t$max_range\nError step:\t${error_step}\nCoverage:\t$coverage\n \
       	    \nDo you want to continue? [y/n] Or do you want to use another file [f]\n"

    read ynf
    case $ynf in
	[Yy] )
	    printf "RUN START $start\n" > log_$infilen
	    mkdir -p $simdir
	    for i in $(seq $start_range $error_step $max_range)
	    do
		printf "\nSIMULATING READS \nCoverage:   $coverage\nError rate: $i/$max_range\n\n"
		cat haplotypes.txt | parallel --line-buffer -j 4 "graph_read_simulator simulate_reads -s $i {} $coverage" | \
		graph_read_simulator assign_ids $simdir/positions_c${coverage}_e${i}.tsv $simdir/simulated_reads_c${coverage}_e${i}.fa
	    done
	    printf "\nDONE!\n" >> log_$infilen
	    exit
	    ;;
	[Nn] )
	    echo "\nEXITING PROGRAM\n"
	    exit
	    ;;
	[Ff] )
    	    printf "Input parameter file name: \n"
	    read -e infile
	    continue 1 #starts over from the outmost loop (the while loop)
	    ;;
	* )
	    echo "Invalid input... try again"
	    ;;
    esac
done
