# -*- coding: utf-8 -*-
"""
Created on Fri Jul 16 13:44:24 2021

@author: Carlos
"""

import os  
import bs4    
from bs4 import BeautifulSoup
import pandas as pd
import requests
import wget
        
# Working directory
InventoryPath = r'C:\Users\Carlos\OneDrive - UC San Diego\UCSD\Research\cgoes\TinyApps\WTODownloader\inventory'
PDFPath = r'C:\Users\Carlos\OneDrive - UC San Diego\UCSD\Research\cgoes\TinyApps\WTODownloader\inventory'

# Working directory
os.chdir(r'C:\Users\Carlos\OneDrive - UC San Diego\UCSD\Research\cgoes\TinyApps\WTODownloader\logs')

# Log File
log = open("..\\queryloop.txt","w")

## Set list of inventory files
log.write('Creating inventory list... \n')
Files = []
for Root, Dirs, List in os.walk(PDFPath):
    for Name in List:
          Files.append(os.path.join(PDFPath, Name))
          log.write('{} included in inventory \n'.format(Name))

# Create auxiliary function
DSBM = lambda x: 'https://docs.wto.org/dol2fe/Pages/FE_Search/FE_S_S006.aspx?Query=(@Symbol=' + str(x) + ')&Language=ENGLISH&Context=FomerScriptedSearch&languageUIChanged=true#'

# Loop over PDF files

for File in Files:
    Frame = pd.read_excel(File, skiprows=1, usecols='B:J')
    n = int(File.split('-')[-1].split('.')[0])
    
    # Retrieve Links
    for Code in Frame.Symbol:
        print('Processing document {}'.format(Code))
        log.write('Processing document {}'.format(Code) + ' \n')
        # Adjust for multiple named codes
        Code = Code.replace(' ', '').split(';')[0]
        # Retrieve Webpage
        Link = requests.get(DSBM(Code))
        # Parse webpage and extract links
        Txt = BeautifulSoup(Link.content, 'html.parser')
        LinkList = Txt.find_all("div", class_="hitEnFileLink")
        
        # Download all files in LinkList
        for File in LinkList:
            # Recover link object 
            nFile = File.a
            # Only download if appropriate object
            if (type(nFile) == bs4.element.Tag):           
                wget.download(nFile['href'], out='..\\pdfs\\')
                print('Downloaded {}'.format(nFile['href']))
                log.write('Downloaded {}'.format(nFile['href']) + ' \n')
            else:
                print('WARNING: Did not find a  file to download...')
                log.write('WARNING: Did not find a  file to download... \n')
                pass

log.close()