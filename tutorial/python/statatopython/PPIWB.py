# Coded by Carlos Góes
# Pesquisador-Chefe do IMP (www.mercadopopular.org)


import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

path = "https://github.com/omercadopopular/cgoes/blob/master/tutorial/python/statatopython/PPI_DB_082316.dta?raw=true"
cpisauce = "https://github.com/omercadopopular/cgoes/blob/master/tutorial/python/statatopython/CPIAUCSL.xls?raw=true"

#Read file from STATA dta

ppidf = pd.read_stata(path)

# Reduce dimensionality to exclude data with negative values and data prior to 1994

ppidf = (ppidf
         [ppidf['investment'] > 0]
         [ppidf['IY'] >= 1994])

#Organize sectors and years

sectorslist = ppidf['sector'].unique()
years = np.sort(ppidf['IY'].unique())


# Identify Brazilian data

brazildf = ppidf[ ppidf['country'] == 'Brazil' ]

# Collapse data by sector and fill na

brazilinvestment = (brazildf
                    .groupby(['sector','IY']).sum()
                    .fillna(0)
                    ['investment']
                    )

print(brazilinvestment)

# Import CPI data from excel file
    # Note you have to skip 9 rows

cpi = pd.read_excel(cpisauce, skiprows=list(range(9)), header=1)

# Extract years and set index

cpi['year'] = [row.year for row in cpi['observation_date']]

cpi = cpi.set_index('year')

# Join both dataframes

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

ax.set_ylabel("Milhares de dólares constantes de 2014")
plt.legend(loc='upper left')

plt.xticks(barl, years, rotation=45)

plt.show()

