import matplotlib.pyplot as plt
import sys

def plotme(filename):
    with open(filename,"r") as f:
        lines = f.readlines()[2:]
        error = [float(line.split('\t')[0]) for line in lines]
        percent = [float(line.split('\t')[1]) for line in lines]

        plt.suptitle("Mapping simulated reads with bwa")    
        plt.xlabel('Error rate')
        plt.ylabel('% of reads mapped')

        plt.plot(error, percent)
        print('Give plot name: ')
        plotname = input()
        plt.savefig(plotname)

if len(sys.argv) == 1:
    print('input filename: ')
    infile = input()
    plotme(infile)
else:
    filename = sys.argv[1]
    plotme(filename)



