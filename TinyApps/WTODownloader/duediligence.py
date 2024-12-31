# -*- coding: utf-8 -*-
"""
Created on Sat Jul 24 11:04:01 2021

@author: Carlos
"""

import os
import pandas as pd
import datetime

# Working directory
WD = r'C:\Users\Carlos\OneDrive - UC San Diego\UCSD\Research\cgoes\TinyApps\WTODownloader'
os.chdir(WD)

# Paths
InventoryPath = 'inventory'
PDFPath = 'pdf'

# Log File
log = open("logs\\duediligence.txt","w")
Date = datetime.datetime.now().strftime("%d/%m/%Y %H:%M:%S")
print('Script executed at {}'.format(Date))
log.write('Script executed at {} \n'.format(Date))

## Set list of inventory files
log.write('Creating inventory list... \n')
minn = 1
maxn = 603
Files = [os.path.join(WD,InventoryPath + '\\WS-DS-{}.xls'.format(n)) for n in range(minn, maxn+1)]

Names = []
CountExcel = []
CountPDF = []
# Loop over Excel files
for File in Files:
    Frame = pd.read_excel(File, skiprows=1, usecols='B:J', na_values=' ')

    Name = File.split('\\')[-1].split('.xls')[0]
    Names.append(Name)
    
    print('Processing file {}...'.format(Name))
    log.write('Processing file {}... \n'.format(Name))

    Excel = sum(~Frame['E'].isna())
    CountExcel.append(Excel)
    print('Excel count: {}'.format(Excel))
    log.write('Excel count: {} \n'.format(Excel))
    
    SubPath = os.path.join(PDFPath,Name)

    PDFs = len(next(os.walk(SubPath))[2])
    CountPDF.append(PDFs)
    print('PDF count: {}'.format(PDFs))
    log.write('PDF  count: {} \n'.format(PDFs))
    
Dict = {'Code': Names,
        'CountExcel': CountExcel,
        'CountPDF': CountPDF}

FrameDiligence = pd.DataFrame.from_dict(Dict)
FrameDiligence['Match'] = (FrameDiligence['CountExcel'] == FrameDiligence['CountPDF'] )
FrameDiligence['Gap'] = (FrameDiligence['CountExcel'] - FrameDiligence['CountPDF'] )

print('FINAL RESULT...')
log.write('FINAL RESULT... \n')

print('Total Excel Count: {}'.format(sum(FrameDiligence['CountExcel'])))
log.write('Total Excel Count: {} \n'.format(sum(FrameDiligence['CountExcel'])))

print('Total PDF Count: {}'.format(sum(FrameDiligence['CountPDF'])))
log.write('Total PDF Count: {} \n'.format(sum(FrameDiligence['CountPDF'])))

print('Excel - PDF Gap: {}'.format(sum(FrameDiligence['Gap'])))
log.write('Excel - PDF Gap: {} \n'.format(sum(FrameDiligence['Gap'])))

print('Excel and PDF match in {} out of {} instances'.format(sum(FrameDiligence['Match']), len(FrameDiligence)))
log.write('Excel and PDF match in {} out of {} instances \n'.format(sum(FrameDiligence['Match']), len(FrameDiligence)))

MisMatches = FrameDiligence[ FrameDiligence['Match'] == False ]
print(MisMatches)
MisMatches.to_csv('docs/Mismatches.csv')
   
log.close()

    
