Introduction
This is a pipeline used to compare mapping accuracies with increasing error introtuced in simulated reads.

Usage
simread_npmap.sh will first simulate reads with the graph_read_simulator from Ivar Grytten. Then map the simulated reads using numpy alignments.
The program takes a file containing all running parameters , and loops over increasing error rates and different coverage. Example:

Error_rate_start_range:	0.101
Error_rate_max_range:	0.30
Error_rate_step:	0.001
Coverage_start_range:	2.0
Coverage_max_range:	2.0
Coverage_step_value:	2.0

compare_mapping.sh is the script comparing the mapping accuracy of the simulated reads generated by simread_npmap.sh to error-free reads.
The output is the amount of simulated reads map to the reference with increasing error rate. Example:

Matching mapping accuracy with increasing error rate. Coverage: 5.0
ErrRate	Match
0	0.9921133065022831
0.1	0.9666097792887404
0.2	0.5694007153840456
0.3	0.08741889852700763
0.4	0.003919059112034946
0.5	9.353003000352849e-05

Finally a simple python program err_plt.py plot the mapping accuracies found by compare_mapping.sh by error rate

