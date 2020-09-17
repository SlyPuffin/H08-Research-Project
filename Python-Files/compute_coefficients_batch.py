#########################################################
# Created by: Daniel Voss, 2019-11-06
# Compute various coefficients on a set of input files
#########################################################
 
# standard imports
from sys import argv
import csv
import pandas as pd
import datetime
import scipy.stats as st
import numpy as np
import matplotlib.pyplot as plt
 
# credit: http://pydoc.net/ambhas/0.4.0/ambhas.errlib/
def filter_nan(s,o):
    """
    this functions removed the data  from simulated and observed data
    whereever the observed data contains nan
    
    this is used by all other functions, otherwise they will produce nan as 
    output
    """
    data = np.array([s.flatten(),o.flatten()])
    data = np.transpose(data)
    data = data[~np.isnan(data).any(1)]
    return data[:,0],data[:,1]
 
# credit: http://pydoc.net/ambhas/0.4.0/ambhas.errlib/
def NS(s,o):
    """
    Nash Sutcliffe efficiency coefficient
    input:
        s: simulated
        o: observed
    output:
        ns: Nash Sutcliffe efficient coefficient
    """
    s,o = filter_nan(s,o)
    return 1 - sum((o-s)**2)/sum((o-np.mean(o))**2)
 
# Function for computing the RSR value
def RSR(s,o):
    s,o = filter_nan(s,o)
    return np.sqrt(sum((o-s)**2))/np.sqrt(sum((o-np.mean(s))**2))
 
# Function for computing the PBIAS value
def PBIAS(s,o):
    s,o = filter_nan(s,o)
    return (100.0*sum(o-s))/sum(o)
 
# Clean input row of any unnecessary symbols
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
            app = app.replace("$","")
            if len(app) == 0:
                continue
            else:
                out.append(app)
                it += 1
    return out
 
# Compute the average discharge
def avg_discharge(row):
    it = 0
    out = []
    avg = []
    for i in row:
        if it == 0:
            out.append(i)
        else:
            avg.append(float(i))
        it += 1
    if len(avg) == 0:
        out.append("NA")
    else:
        out.append(sum(avg) / len(avg))
    return out
 
# read in from commandline
# observed_prefix simulated_prefix start_year year_range
# e.g. python compute_coefficients mushuu_obs_ mushuu_2nd_ 1995 12
script, observed, simulated, startyear, yrange = argv
 
# read in files to master lists
combinedObserved = []
combinedSimulated = []
monthlyObserved = []
monthlySimulated = []
 
# iterate over the defined date range
state_date = datetime.date(int(startyear),01,01)
for y in range(0,int(yrange)):
    for m in range(0,12):
        calcMonObs = 0.0
        calcMonSim = 0.0 
        calcMonCounter = 0.0
        year = int(startyear)+y
        month = 1+m
        # read in monthly files
        fileObs = observed + str(year) + "{:02d}".format(month) + ".csv"
        fileSim = simulated  + str(year) + "{:02d}".format(month) + ".txt"
        datObserved = [i.strip().split(",") for i in open(fileObs).readlines()]
        datSimulated = [i.strip().split(",") for i in open(fileSim).readlines()]
        # create list of files where data exists
        for obs in datObserved:
            for sim in datSimulated:
                if obs[0] == sim[0]:
                    if obs[1] != "NA":
                        combinedObserved.append(obs[1])
                        combinedSimulated.append(sim[1])
                        calcMonObs += float(obs[1])
                        calcMonSim += float(sim[1])
                        calcMonCounter += 1.0
        if calcMonCounter > 0:
            monthlyObserved.append(calcMonObs/calcMonCounter)
            monthlySimulated.append(calcMonSim/calcMonCounter)
# Create arrays of observed and simulated data
# (Daily and monthly and average)
floatObs = np.array(combinedObserved).astype(np.float)
floatSim = np.array(combinedSimulated).astype(np.float)
monFloatObs = np.array(monthlyObserved).astype(np.float)
monFloatSim = np.array(monthlySimulated).astype(np.float)
avgObsDis = np.mean(floatObs)
 
# run correlations
# Pearson R value
pR, pP = st.pearsonr(floatObs, floatSim)
# Spearman R value
sR, sP = st.spearmanr(floatObs, floatSim)
# Kendall Tau value
kT, kP = st.kendalltau(floatObs, floatSim)
# Linear regression
lS, lI, lR, lP, lE = st.linregress(floatObs, floatSim)
# Nash-Sutcliffe Model Efficiency Coefficient
nse = NS(floatSim, floatObs)
mnse = NS(monFloatSim, monFloatObs)
# RMSE-observations standard deviation ratio
rsr = RSR(floatSim, floatObs)
mrsr = RSR(monFloatSim, monFloatObs)
# Percent Bias
pbias = PBIAS(floatSim, floatObs)
mpbias = PBIAS(monFloatSim, monFloatObs)
 
# Bonus section
avgSimDis = np.mean(floatSim)
maxObsDis = np.max(floatObs)
maxSimDis = np.max(floatSim)
 
# Print out values for sorting into a spreadsheet
print(str(len(combinedObserved))+','+str(avgObsDis)+','+str(avgSimDis)+','+str(maxObsDis)+','+str(maxSimDis)+','+str(mrsr)+','+str(rsr)+','+str(mnse)+','+str(nse)+','+str(mpbias)+','+str(pbias))
 
# Optional code fr creating charts
# Sort data
#sortObs = np.sort(floatObs)[::-1]
#sortSim = np.sort(floatSim)[::-1]
#exceedence = np.arange(1.,len(floatObs)+1) / len(floatObs)
 
# Create X-Axis
#xaxis = np.arange(len(monFloatSim))
 
# Time series
#plt.plot(xaxis, monFloatObs, label='Observation')
#plt.plot(xaxis, monFloatSim, label='Predicted')
#plt.xlabel('Months since 199501')
#plt.ylabel('Flow m3/s')
#plt.legend()
 
# Scatter
#plt.scatter(floatObs, floatSim)
#plt.xlabel('Observed')
#plt.ylabel('Predicted')
 
# Flow Duration
#plt.plot(exceedence*100, sortObs, label='Observation')
#plt.plot(exceedence*100, sortSim, label='Predicted')
#plt.xlabel('Probability %')
#plt.ylabel('Daily Streamflow m3/s')
#plt.legend()
#plt.show()
