import sys

sim_file_name = sys.argv[1]
pos_file_name = sys.argv[2]

# Paramater variables for output file naming
s = sim_file_name.split("_")[-3] # Sample
c = sim_file_name.split("_")[-2] # Coverage
e = sim_file_name.split("_")[-1] # Error rate
e = e.split(".fa")[0]

print(s)
print(c)
print(e)

sim_file = open(sim_file_name, "r")
pos_file = open(pos_file_name, "r")

# Masked and repeat simulation out files
ms = open("masked_simulated_reads_%s_%s_%s.fa" % (s, c, e), "a+") # masked
rs = open("repeats_simulated_reads_%s_%s_%s.fa" % (s, c, e), "a+") # Repeats
xs = open("mixed_simulated_reads_%s_%s_%s.fa" % (s, c, e), "a+") # Mixed

# Masked and repeat positions out files
mp = open("masked_positions_%s_%s_%s.tsv" % (s, c, e), "a+")
rp = open("repeats_positions_%s_%s_%s.tsv" % (s, c, e), "a+")
xp = open("mixed_positions_%s_%s_%s.tsv" % (s, c, e), "a+")

# Two counters for simulation and position files
i = 0
j = 0
k = 0

# Read in positions file
for line in pos_file:
     # Read lines in simulation fasta-file 
     simulated_reads_line_header = sim_file.readline()
     assert simulated_reads_line_header.startswith(">")
     simulated_reads_line_sequence = sim_file.readline()
     
     # Check if uppercase which are the normal regions,
     # this will yield reads containing ONLY normal sequences
     if simulated_reads_line_sequence.isupper():
          ms.write(">%09d\n%s" % (i, simulated_reads_line_sequence))
          mp.write("%09d%s" % (i, line[9:]))
          i += 1

     # Check if lowercase which are repeats
     if simulated_reads_line_sequence.islower():
          rs.write(">%09d\n%s" % (j, simulated_reads_line_sequence))
          rp.write("%09d%s" % (j, line[9:]))
          j += 1

     # The rest are a mix of softmasked repeats and normal sequences
     else:
          xs.write(">%09d\n%s" % (k, simulated_reads_line_sequence))
          xp.write("%09d%s" % (k, line[9:]))
          k += 1

