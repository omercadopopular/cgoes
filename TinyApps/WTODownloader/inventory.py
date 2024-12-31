# -*- coding: utf-8 -*-
"""
Created on Thu Jul 22 12:31:21 2021

@author: Carlos
"""
from selenium import webdriver
import os
import datetime
import time

# Set Paths
DownloadsPath = r'C:\Users\Carlos\Downloads'
InventoryPath = r'C:\Users\Carlos\OneDrive - UC San Diego\UCSD\Research\cgoes\TinyApps\WTODownloader\inventory'

# Initialize Chrome Machine
driver = webdriver.Chrome(executable_path=r'C:\Program Files\ChromeDriver\chromedriver.exe')

# Define modifiable path
DSBM = lambda x: 'https://docs.wto.org/dol2fe/Pages/FE_Search/FE_S_S006.aspx?Query=(@Symbol=wt/ds' + str(x) + '/*)&Language=ENGLISH&Context=FomerScriptedSearch&languageUIChanged=true#'

# Retrieve date vars
day = str(datetime.date.today().day)
month = str(datetime.date.today().month)
year = str(datetime.date.today().year)

# Check lengths
day = (2-len(day))*'0' + day
month = (2-len(month))*'0' + month


# Initiate Loop
minn = 348
maxn = 603

for n in range(minn,maxn+1):

    # Load Website 
    driver.get(DSBM(n))
    
    # Download Inventory
    driver.find_element_by_xpath("//span[@id='ctl00_MasterLoginWUC_LoginView1_wpcAnonymousUserPanel_lblPrint']").click()
    time.sleep(0.5)   
    
    # Rename downloaded file
    
    FileName = 'Documents_list_{}_{}_{}.xls'.format(day,month,year)
    try:
        os.rename(os.path.join(DownloadsPath,FileName), os.path.join( InventoryPath, 'WS-DS-{}.xls'.format(n) ) )
    except:
        time.sleep(2)
        try:
            os.rename(os.path.join(DownloadsPath,FileName), os.path.join( InventoryPath, 'WS-DS-{}.xls'.format(n) ) )
        except:
            FileName = 'Documents_list_{}_{}_{} (1).xls'.format(day,month,year)
            os.rename(os.path.join(DownloadsPath,FileName), os.path.join( InventoryPath, 'WS-DS-{}.xls'.format(n) ) )

driver.quit()


