###################################################
# Created by: Daniel Voss, 2019-06-06
# Parse average daily discharge for a monthly file
###################################################
# standard imports
from sys import argv
import csv
import pandas as pd
 
# Clean rows of unnecessary characters and missing data values
def clean_up(row):
    it = 0
    out = []
    for i in row:
        if i == ',-9999.00,$,':
            continue
        else:
            app = i.replace(" ","")
            app = app.replace(",","")
            app = app.replace("-9999.00","")
            app = app.replace("-9999.99","")
            app = app.replace("-","")
            app = app.replace("$","")
            if len(app) == 0:
                continue
            else:
                out.append(app)
                it += 1
    return out
 
# Compute avereage discharge across 24 hours
def avg_discharge(row):
    it = 0
    out = []
    avg = []
    for i in row:
        if it == 0:
            out.append(i.replace("/",""))
        else:
            avg.append(float(i))
        it += 1
    if len(avg) == 0:
        out.append("NA")
    else:
        out.append(sum(avg) / len(avg))
    return out
 
# Read in from commandline
# e.g. python extract_means.py INPUT.txt OUTPUT.txt
script, filename, output = argv
print filename
print output
 
# Read in file to a list of lists
datContent = [i.strip().split() for i in open(filename).readlines()]
 
# Compute average over file
header_counter = 0
cal = 0
dischargeArray = []
for x in datContent:
    if header_counter > 9:
        dischargeArray.append(avg_discharge(clean_up(x)))
        print dischargeArray[cal]
        cal += 1
    header_counter += 1
 
# Write as csv
with open (output, "wb") as f:
    writer = csv.writer(f)
    writer.writerows(dischargeArray)
