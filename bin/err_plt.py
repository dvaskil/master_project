#!/usr/bin/python3

import matplotlib.pyplot as plt
from matplotlib.pyplot import figure
import sys
import re

#Plot function
def plotme(filelist):
    plt.figure(figsize=(24,12))
    for files in filelist:
        #splitting filename, used as label
        filename = files.split('/')
        labelname = (filename[-1].split('_'))[0]
        with open(files,"r") as f:
            lines = f.readlines()[2:]
            error = [float(line.split('\t')[0]) for line in lines]
            mapped_rate = [float(line.split('\t')[1]) for line in lines]
            percent = [i * 100 for i in mapped_rate]
            f.close()
            
            #Making plot
            plt.plot(error, percent, label=labelname)
            plt.legend(loc='upper right')
            
    #Titles and labels
#   print ('Coverage amount: ')
#   coverage = input()
    coverage = (re.split('_c|.tsv', filename[-1]))[1]

    print('Give plot name: ')
    plotname = input()
    plt.suptitle('Mapping simulated reads with bwa', y=0.92, fontweight='semibold')
    plt.title('Coverage: %s' % coverage, fontsize=10)
    plt.xlabel('Error rate')
    plt.ylabel('% of reads mapped')
    plt.savefig(plotname, bbox_inches='tight')

#Input from arguments or prompt from program
if len(sys.argv) == 1:
    print('input filename: ')
    filelist = input()
    plotme(filelist)
else:
    filelist = sys.argv[1:]
    plotme(filelist)

