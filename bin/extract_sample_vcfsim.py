import random

sample = open('sample_1.vcf', 'w')

with open ('sim_vcfy_chr1-5')as vcf:
    for line in vcf:
        if line.startswith('#'):
            sample.write(line)
        else:
            ra = random.randint(1, 10)
            if ra == 1:
                sample.write(line)
            else:
                continue
sample.close
