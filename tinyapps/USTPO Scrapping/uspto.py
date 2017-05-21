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
                labels.append(header.get_text())
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
                    max = len(column.get_text())
                    list.append(column.get_text()[:max])
                list = pd.Series(list)
                new_table = new_table.append(list, ignore_index=True)
       
    new_table.columns = labels
    new_table = new_table.dropna()
    
    return new_table

years = ['06',
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
        
brazil = complete[ complete['Code'] == 'BRX' ]