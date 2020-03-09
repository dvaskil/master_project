import sys
from pyfaidx import Fasta
import numpy as np

ref = sys.argv[1]

# Walk through string, replacing upper case to 1 and pasting the number 
# to the empty nparray which is the same length as the reference genome
for chromosome in range(1, 6):
    genome = str(Fasta(ref)["%d" % (chromosome)]) # Or could it just be "chromosome"
    rep = np.zeros(len(genome))
    print(len(rep))
    for i, base in enumerate(genome):
        if base.isupper():
            rep[i] = 1
    np.save("rep_chr%d.npy" % (chromosome), rep) # Saving as a numpy array file
