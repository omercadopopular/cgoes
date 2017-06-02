"""
This script scrapes the data on
PATENT COUNTS BY ORIGIN AND TYPE
CALENDAR YEAR 2015
available on the website of the
U.S. PATENT AND TRADEMARK OFFICE
as a html table and organizes it in
Pandas DataFrame
Author: Carlos Góes
www.carlosgoes.com
"""

from bs4 import BeautifulSoup
import requests
import pandas as pd

def uspto(url):
    # Request the URL
    r  = requests.get(url)

    # Parse it through BeautifulSoup        
    soup = BeautifulSoup(r.content, "html.parser")

    # Find the tables in the website         
    table=soup.find('table')
    
    # Loops through all the rows
    for row in table.find_all('tr'):
        
        # Identify headers, store them in a list
            # build DataFrame as wide as the number
            # of headers
        headers = row.find_all('th')
        if len(headers) > 0:
            labels = []
            for header in headers:
                labels.append(header.get_text().rstrip().strip().lower())
            new_table = pd.DataFrame(
                    columns=range(0,len(labels)),
                                 index = [0])

        # If row are not headers, proceed with the following
        else:
            
            # Identify columns
            columns = row.find_all('td')
            
            # Skip row if columns are merged
            if len(columns) != len(labels):
                continue
            
            # Loop through columns, store data in a list,
                # transform it into a Pandas series,
                # and append it to the Pandas DataFrame
            else:
                list = []
                for column in columns:
                    list.append(column.get_text().rstrip().strip().lower())
                list = pd.Series(list)
                new_table = new_table.append(list, ignore_index=True)
       
    new_table.columns = labels
    new_table = new_table.dropna()
    
    return new_table

years = ['02',
         '03',
         '04',
         '05',
         '06',
         '07',
         '08',
         '09',
         '10',
         '11',
         '12',
         '13',
         '14',
         '15']

for year in years:    
    total = uspto("https://www.uspto.gov/web/offices/ac/ido/oeip/taf/st_co_" +
                  year + ".htm")
    total['year'] = year

    if year == years[0]:
        complete = total.copy()
        
    else:
        complete = complete.append(total, ignore_index=True)   

# drop unecessary rows
        
complete = complete[complete['code'] != 'ALL']
complete = complete[complete['code'] != '']

# consolidate columns (different labeling for different years)

complete['state, territory, or country'] = (complete['state, territory, or country']
                                            .fillna(value=complete['state/country *']))

complete['statutory invention registration (sir)'] = (complete['statutory invention registration (sir)']
                                                      .fillna(value=complete['statutoryinventionregistration (sir)'])
                                                      .fillna(value=complete['statutoryinventorregistration(sir)']))
        
complete['total'] = (complete['total']
                    .fillna(value=complete['total (less sirs)'])
                    .fillna(value=complete['totals(less sirs)']))

complete = complete.drop(['state/country *',
                          'statutoryinventionregistration (sir)',
                          'statutoryinventorregistration(sir)',
                          'total (less sirs)',
                          'totals(less sirs)'], axis=1)

# transform year into integers

complete['year'] = [int('20'+ str(row)) for row in complete['year']]

complete = complete.fillna(0)
    
# transform other variables into integers

vars = ['design',
        'plant',
        'reissue',
        'utility',
        'total',
        'statutory invention registration (sir)']

for var in vars:
    complete[var] = [int(str(row)) for row in complete[var]]
    
# set aside Brazil
        
brazil = complete[ complete['state, territory, or country'] == 'brazil' ]

brazil.to_csv("K:\\Notas Técnicas\\Produtividade\\Databases\\patentes\\brazilustpo.csv")

# Plot

import matplotlib.pyplot as plt

plt.plot(brazil['year'],
         brazil['total'])
plt.axis([2001,2016,0,400])

plt.title('Brasil: Patentes Registradas no USTPO')
plt.show()
