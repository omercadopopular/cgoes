# -*- coding: utf-8 -*-
"""
Created on Sat Jul  4 23:25:08 2020

@author: Carlos
"""

import matplotlib.pyplot as plt
import pandas as pd
import os

plt.rc('xtick',labelsize=14)
plt.rc('ytick',labelsize=14)


Path = r'C:\Users\Carlos\OneDrive - UC San Diego\UCSD\Research\cgoes\COVID'
File = r'daily-covid-cases-per-million-three-day-avg.csv'

DF = pd.read_csv(os.path.join(Path,File))
DF = DF.rename(columns={'Daily new confirmed cases of COVID-19 per million people (rolling 3-day average, right-aligned)': 'Cases_3day'} )
DF['Date'] = pd.to_datetime(DF.Date)
DF = DF.set_index(['Entity','Date'])

fig, ax = plt.subplots(1, figsize=(15,12))
ax.plot(DF.loc['Canada',:].Cases_3day, label='Canadá', color='black', marker='o')
ax.plot(DF.loc['United States',:].Cases_3day, label='Estados Unidos', color='gray', marker='*')
plt.legend(loc='upper left', fontsize=15)
plt.title('Casos diários de COVID-19 por milhão de habitantes, média-móvel de 7 dias', fontsize=18)
plt.savefig(os.path.join(Path,'casos.png'), bbox_inches='tight')
plt.show()



