# Coded by Carlos Góes
# Pesquisador-Chefe do IMP (www.mercadopopular.org)


# -*- coding: utf-8 -*-
"""
Created on Fri May 26 10:04:06 2017

@author: CarlosABG
"""

import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
from pandas_datareader import wb

path = "https://github.com/omercadopopular/cgoes/blob/master/tutorial/python/statatopython/PPI_DB_082316.dta?raw=true"
cpisauce = "https://github.com/omercadopopular/cgoes/blob/master/tutorial/python/statatopython/CPIAUCSL.xls?raw=true"
gdpsauce = "https://github.com/omercadopopular/cgoes/blob/master/tutorial/python/statatopython/gdp.xlsx?raw=true"

#####################################
# 1. Retrieve Databases #############
#####################################

## 1.1 Import GDP data from the World Bank

wbdata = (wb.download(indicator='NY.GDP.MKTP.CD', country='all', start=1994, end=2015)
            .dropna()
            .rename(columns={'NY.GDP.MKTP.CD': 'gdp'})
            )

## 1.2 Read file from STATA dta

ppidf = pd.read_stata(path)

## 1.3 Import CPI data from excel file
    ## Note you have to skip 9 rows

cpi = pd.read_excel(cpisauce, skiprows=9, header=1)

#####################################
# 2. Adjust Databases ###############
#####################################

## 2.1 Adjust WB data

# Reset index

wbdata = wbdata.reset_index()

# Set GDP data to billions

wbdata['gdp'] = wbdata['gdp'] / 10**9 

# Iterate through years to convert strings into integers

wbdata['year'] = [int(row) for row in wbdata['year']]

# Set Index

wbdata = wbdata.set_index(['country', 'year'])

## 2.2 Adjust PPI database

# Reduce dimensionality to exclude data with negative values and data prior to 1994

ppidf = (ppidf
         [ppidf['investment'] > 0]
         [ppidf['IY'] >= 1994]
         [ppidf['type'] == 'Greenfield project']
         )

# Organize sectors and years

countrieslist = ppidf['country'].unique().sort_values()
sectorslist = ppidf['sector'].unique().sort_values()
years = np.sort(ppidf['IY'].unique())

# Consolidate duplicates
    # We are doing this through loops because the dataset is large
    # and applying a groupby to the whole dataset will demand a lot
    # of RAM

for country in countrieslist:
    grouped = ppidf[ ppidf['country'] == country ]
    sectors = grouped['sector'].unique().sort_values()
    
    for sector in sectors:
        if ( (country == countrieslist[0]) and (sector == sectors[0]) ):
            sectored = grouped[ grouped['sector'] == sector ]
            sectored = sectored.groupby(['country','sector','ID','IY']).mean().dropna()['investment']
            consolidated = sectored
            
        else:
            sectored = grouped[ grouped['sector'] == sector ]
            sectored = sectored.groupby(['country','sector','ID','IY']).mean().dropna()['investment']
            consolidated = consolidated.append(sectored)

consolidated = consolidated.reset_index(drop=False)

# Adjust investments to billion USD

consolidated['investment'] = consolidated['investment'] / 1000

## 2.3 Adjust CPI data

# Extract years and set index

cpi['year'] = [row.year for row in cpi['observation_date']]
cpi = cpi.set_index('year')


#####################################
# 3. Brazil Time Series #############
#####################################

# Create a new dataset

brazildf = consolidated[ consolidated['country'] == 'Brazil' ]

# Collapse data by sector and fill na

brazilinvestment = (brazildf
                    .groupby(['sector','IY']).sum()
                    .fillna(0)
                    ['investment']
                    )


# Join CPI data

rbrazilinvestment = (
        cpi       
        .join(brazilinvestment.reset_index().set_index('IY'),
              how='inner')
        )
        
# Set Indices and Organize

rbrazilinvestment = (
        rbrazilinvestment
        .reset_index(drop=False)
        .set_index(['sector','index'])
        .sort_index()
        )

# Adjust for Inflation

## updated cpi frame with necessary data

cpi = (rbrazilinvestment
        .reset_index(drop=False)
        .groupby('index').mean()
        .drop(['investment'], axis=1)
        ['CPIAUCSL']
        )      

rbrazilinvestment['rinvestment'] = rbrazilinvestment['investment'] / rbrazilinvestment['CPIAUCSL']  * cpi[2014]

# Only keep real investment data

rbrazilinvestment = rbrazilinvestment['rinvestment']

# Plot chart

f, ax = plt.subplots(1, figsize=(10,5))
barw = 0.75
barl = [i+1 for i in range(len(years))]

ax.bar(barl, rbrazilinvestment['ICT'], barw, color='#c00000',
       alpha=0.75,
       label="Telecomunicações")

ax.bar(barl, rbrazilinvestment['Transport'], barw, color='#000000',
       bottom=rbrazilinvestment['ICT'],
       alpha=0.75,
       label="Transporte")

ax.bar(barl, rbrazilinvestment['Energy'], barw, color='#70ac47',
       bottom=[i+j for i,j in zip(rbrazilinvestment['ICT'],
                                  rbrazilinvestment['Transport']
                                  )],
       alpha=0.75,
       label="Energia")

ax.bar(barl, rbrazilinvestment['Water and sewerage'], barw, color='#7030a0',
       bottom=[i+j+k for i,j,k in zip(rbrazilinvestment['ICT'],
                                      rbrazilinvestment['Transport'],
                                      rbrazilinvestment['Energy']
                                      )],
       alpha=0.75,
       label="Água e saneamento")

ax.set_ylabel("Bilhões de dólares constantes de 2014")
plt.legend(loc='upper left')

plt.title('Brasil: Investimento Privado em Infraestrutura')

plt.xticks(barl, years, rotation=45)

plt.show()

##########################
##########################

# Share of GDP

brazilgdp = wbdata.loc['Brazil'].reset_index()

brazilinvestment = (brazilgdp.set_index('year')
                    .join(brazilinvestment
                          .reset_index()
                          .set_index('IY'),
                                    how='right')
                    )
                    
brazilinvestment = brazilinvestment.reset_index(drop=False).set_index(['sector','index'])
                    
brazilinvestment['investmentgdp'] = ( brazilinvestment['investment'] / ( brazilinvestment['gdp']  ) ) * 100

brazilinvestmentgdp = brazilinvestment['investmentgdp']

brazilinvestment.unstack().to_csv("K://Notas Técnicas//Produtividade//Databases//PPI World Bank//brazilinvestment.csv",
                        sep=";",
                        decimal=",")     

# Plot chart

f, ax = plt.subplots(1, figsize=(10,5))
barw = 0.75
barl = [i+1 for i in range(len(years))]

ax.bar(barl, brazilinvestmentgdp['ICT'], barw, color='#c00000',
       alpha=0.75,
       label="Telecomunicações")

ax.bar(barl, brazilinvestmentgdp['Transport'], barw, color='#000000',
       bottom=brazilinvestmentgdp['ICT'],
       alpha=0.75,
       label="Transporte")

ax.bar(barl, brazilinvestmentgdp['Energy'], barw, color='#70ac47',
       bottom=[i+j for i,j in zip(brazilinvestmentgdp['ICT'],
                                  brazilinvestmentgdp['Transport']
                                  )],
       alpha=0.75,
       label="Energia")

ax.bar(barl, brazilinvestmentgdp['Water and sewerage'], barw, color='#7030a0',
       bottom=[i+j+k for i,j,k in zip(brazilinvestmentgdp['ICT'],
                                      brazilinvestmentgdp['Transport'],
                                      brazilinvestmentgdp['Energy']
                                      )],
       alpha=0.75,
       label="Água e saneamento")

ax.set_ylabel("% GDP")
plt.legend(loc='upper left')

plt.title('Brasil: Investimento Privado em Infraestrutura')

plt.xticks(barl, years, rotation=45)

plt.show()                


# Consolidate 2010-2014 average

# Investment

average = consolidated[ (consolidated['IY'] > 2009) & (consolidated['IY'] < 2015) ].copy()
average = average.groupby(['country','IY']).sum()['investment']
average = average.reset_index(drop=False).groupby('country').mean().drop(['IY'], axis=1)

averagegdp = wbdata.reset_index().copy()
averagegdp = averagegdp[ (averagegdp['year'] > 2009) & (averagegdp['year'] < 2015) ]
averagegdp = averagegdp.groupby(['country']).mean()

average = average.join(averagegdp, how='inner')

average['investmentgdp'] = average['investment'] / ( average['gdp'] ) * 100
average['pctile'] = average['investmentgdp'].rank(pct=True) * 100

average.unstack().to_csv("K://Notas Técnicas//Produtividade//Databases//PPI World Bank//crosssection.csv", sep=";", decimal=",")     

# Plot Chart

f, ax = plt.subplots(1, figsize=(10,5))

ax.scatter(average['pctile'] , average['investmentgdp'])

plt.axis([0,100,0,5])

plt.show()
