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
# 3. Brazil Time Series, constant USD
#####################################

## 3.1 Create a new dataset

brazildf = consolidated[ consolidated['country'] == 'Brazil' ]

# Collapse data by sector and fill na

brazilinvestment = (brazildf
                    .groupby(['sector','IY']).sum()
                    .fillna(0)
                    ['investment']
                    )

## 3.2 Adjust for Inflation

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

## Update CPI frame with necessary data

cpi = (rbrazilinvestment
        .reset_index(drop=False)
        .groupby('index').mean()
        .drop(['investment'], axis=1)
        ['CPIAUCSL']
        )
   
# Adjust for Inflation

rbrazilinvestment['rinvestment'] = rbrazilinvestment['investment'] / rbrazilinvestment['CPIAUCSL']  * cpi[2014]

# Only keep real investment data

rbrazilinvestment = rbrazilinvestment['rinvestment']

## 3.2 Plot chart

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

plt.text(0,-0.25,'Fonte: Cálculos da SAE/PR com dados do Banco Mundial')

plt.xticks(barl, years, rotation=45)

plt.show()

#####################################
# 4. Brazil Time Series, share of GDP
#####################################

## 4.1 Import GDP data from World Bank Dataset

# Create new series with Brazil GDP data

brazilgdp = wbdata.loc['Brazil'].reset_index()

# Join both dataframes

brazilinvestment = (brazilgdp.set_index('year')
                    .join(brazilinvestment
                          .reset_index()
                          .set_index('IY'),
                                    how='right')
                    )
                    

# Set new indices

brazilinvestment = brazilinvestment.reset_index(drop=False).set_index(['sector','index'])

## 4.2 Calculate GDP shares
                    
brazilinvestment['investmentgdp'] = ( brazilinvestment['investment'] / ( brazilinvestment['gdp']  ) ) * 100

# Only keep investment to GDP Data

brazilinvestmentgdp = brazilinvestment['investmentgdp']

# Export to CSV

brazilinvestment.unstack().to_csv("K://Notas Técnicas//Produtividade//Databases//PPI World Bank//brazilinvestment.csv",
                        sep=";",
                        decimal=",")     

## 4.3 Plot chart

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

plt.text(0,-0.25,'Fonte: Cálculos da SAE/PR com dados do Banco Mundial')

plt.xticks(barl, years, rotation=45)

plt.show()                


#####################################
# 5. Cross Section, 2010-2014 avg ###
#####################################


## 5.1 Consolidate 2010-2014 investment average

average = consolidated[ (consolidated['IY'] > 2009) & (consolidated['IY'] < 2015) ].copy()

# Sum across investment types

average = average.groupby(['country','IY']).sum()['investment']

# Take period average

average = average.reset_index(drop=False).groupby('country').mean().drop(['IY'], axis=1)

## 5.2 Consolidate 2010-2014 GDP average

averagegdp = wbdata.reset_index().copy()
averagegdp = averagegdp[ (averagegdp['year'] > 2009) & (averagegdp['year'] < 2015) ]

# Take period average

averagegdp = averagegdp.groupby(['country']).mean()

## 5.3 Join both dataframes

average = average.join(averagegdp, how='inner')

## 5.4 Calculate shares of GDP

average['investmentgdp'] = average['investment'] / ( average['gdp'] ) * 100

## 5.5 Calculate percentiles

average['pctile'] = average['investmentgdp'].rank(pct=True) * 100

# Save to GDP

average.unstack().to_csv("K://Notas Técnicas//Produtividade//Databases//PPI World Bank//crosssection.csv", sep=";", decimal=",")     

## 5.6 Plot Charts

f, ax = plt.subplots(1, figsize=(10,5))
plt.axis([0,100,0,5])
plt.xticks(np.linspace(0,100,5), np.linspace(0,100,5))

ax.scatter(average['pctile'] , average['investmentgdp'], color='grey', label='Resto do Mundo', marker='x')

ax.scatter(average.loc['Brazil']['pctile'], average.loc['Brazil']['investmentgdp'], color='red', label='Brasil')

plt.axvline(average.loc['Brazil']['pctile'], color='red') 

plt.legend(loc='upper left')

ax.set_xlabel("Percentil na Distribuição de Países Emergentes")
ax.set_ylabel("Investimento privado em infraestrutura, % GDP")


plt.title('Países em Desenvolvimento: Investimento Privado em Infraestrutura (média 2010-2014)')

plt.text(0,-0.75,'Fonte: Cálculos da SAE/PR com dados do Banco Mundial')

plt.show()

