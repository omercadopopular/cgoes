# -*- coding: utf-8 -*-
"""
Created on Thu Oct 17 21:10:48 2024

@author: andre
"""

# -*- coding: utf-8 -*-
"""
Created by Carlos Góes
cgoes@ucsd.edu
www.carlosgoes.com

Version 0.1
December 2022
"""

import os

# Base Paths
#folder = r'C:\Users\wb592068\OneDrive - UC San Diego\UCSD\Research\product-innovation-trade\data\wits'
folder = r'C:\Users\cbezerradegoes\OneDrive\UCSD\Research\cgoes\dynamic-adjustment-trade-shocks\eu-tariffs\'

os.chdir(folder)

# Import base packages
from src.wits import wits
import pandas as pd
import matplotlib.pyplot as plt

### User inputs
firstYear = 1995
fastYear = 2010

# Concordance Paths
ConcordancePath = folder + r'\concordance'

# Country Codes
storage_options = {'User-Agent': 'Mozilla/5.0'}
CountryCodes = r'https://wits.worldbank.org/wits/wits/witshelp/content/codes/country_codes.htm'
CountryCodesTable = pd.read_html(CountryCodes, storage_options=storage_options, header=1)[0]

NewISOCodes = ['CYP', 'CZE', 'EST', 
            'HUN', 'LVA', 'LTU', 'MLT', 'POL', 'SVK', 'SVN']
NewTable = CountryCodesTable[ CountryCodesTable.ISO3.isin(NewISOCodes) ]
NewCodes = NewTable.Code.unique()

def harmonizeHS(inFrame, folder):
    correlationsHS = pd.read_excel(os.path.join(folder,'concordance\\CompleteCorrelationsOfHS-SITC-BEC_20170606.xlsx') )

    outFrame = pd.DataFrame()
    
    vintages = set(inFrame.NomenCode)
    
    for vintage in vintages:
        
        tempFrame = inFrame[inFrame.NomenCode == vintage]
        
        if vintage == 'H3':
            tempFrame['ProductCodeH3'] = [int(x) for x in tempFrame.ProductCode]
        
        else:
            correlFrame = correlationsHS[[vintage, 'H3']]
            correlFrame = correlFrame.rename(columns={vintage: 'ProductCode',
                                                      'H3': 'ProductCodeH3'})
            
            correlFrame = correlFrame.dropna().astype(int)
            
            # select mode of each ProductCode as H3 code
            correlFrame = correlFrame.groupby('ProductCode')['ProductCodeH3'].agg(lambda x: pd.Series.mode(x)[0]).reset_index(drop=False)
            
            tempFrame = pd.merge(tempFrame, correlFrame, how='left', on='ProductCode')
            
        outFrame = pd.concat((outFrame,tempFrame))
    
    return outFrame

def concIsic():
    concFrame = pd.read_csv(os.path.join(folder,'concordance\\JobID-48_Concordance_H3_to_I3.CSV'), encoding='unicode_escape' )
    
    concFrame = concFrame.rename(columns=
                     {'HS 2007 Product Code': 'ProductCodeH3',
                      'ISIC Revision 3 Product Code': 'Isic3'})
    
    tempframe31 = pd.read_csv(os.path.join(folder,'concordance\\ISIC_Rev_31-ISIC_Rev_3_correspondence.txt'), encoding='unicode_escape' )
    tempframe31 = tempframe31.rename(columns=
                     {'Rev31': 'Isic31',
                      'Rev3': 'Isic3'})

    # select mode of each Rev3 as Rev31 code
    tempframe31 = tempframe31.groupby('Isic3')['Isic31'].agg(lambda x: pd.Series.mode(x)[0]).reset_index(drop=False)

    concFrame = pd.merge(concFrame, tempframe31[['Isic31','Isic3']], how='left', on='Isic3')

    tempframe4 = pd.read_csv(os.path.join(folder,'concordance\\ISIC31_ISIC4.txt'), encoding='unicode_escape')
    tempframe4 = tempframe4.rename(columns=
                     {'ISIC31code': 'Isic31',
                      'ISIC4code': 'Isic4'})

    # select mode of each Rev3 as Rev31 code
    tempframe4 = tempframe4.groupby('Isic31')['Isic4'].agg(lambda x: pd.Series.mode(x)[0]).reset_index(drop=False)

    concFrame = pd.merge(concFrame, tempframe4[['Isic31','Isic4']], how='left', on='Isic31')

    return concFrame.dropna()[['ProductCodeH3', 'Isic4']]

def retrieveIcioSector():
    
    # read file
    path = os.path.join(folder,'icio\\sectorlist.dta')
    icioFrame = pd.read_stata(path).set_index('code')
    
    # collect isic4 descriptors in a list
    icioFrame = icioFrame[ icioFrame['isic4'] != '' ]
    icioFrame['isic4List'] = [x.split(",") for x in icioFrame['isic4']]
    
    # retrieve labels
    outDict = dict()
    codeDict = pd.io.stata.StataReader(path).value_labels()['code']   
    retrieveCode = lambda value, mydict: list(mydict.keys())[list(mydict.values()).index(value)]
    
    for code in icioFrame.index:
        numCode = retrieveCode(code, codeDict)

        iterList = icioFrame.loc[code, 'isic4List']
        if 'to' in iterList[0]:
            start, end = int(iterList[0][:2]), int(iterList[0][-2:])
            iterList = [str(x) for x in list(range(start, end))]

        for item in iterList:
            item = item.replace(' ', '')
            outDict.update({item: numCode})
    
    return outDict
            
Query = wits(Year=0, Folder=folder)
bilateralFolder = Query.BilateralFolder
concIsic = concIsic()
isicDict = retrieveIcioSector()
longFrame = pd.DataFrame()

for cCode in NewCodes:
    isoCode = NewTable[NewTable.Code == cCode]['ISO3'].iloc[0]
    countryName = NewTable[NewTable.Code == cCode]['Country Name'].iloc[0]
    print('Processing {}...'.format(countryName))
    
    inFrame = pd.read_csv(os.path.join(bilateralFolder,'wits_bilateral_eu_' + str(cCode) + '.csv') )
    harmFrame = harmonizeHS(inFrame, folder)
    outFrame = pd.merge(harmFrame,concIsic, how='left', on='ProductCodeH3')
    outFrame = outFrame.groupby(['Reporter_ISO_N','Year', 'Partner', 'Isic4']).agg(
        {'Sum_Of_Rates': 'mean',
         'Min_Rate': 'mean',
         'Max_Rate': 'mean',
         'SimpleAverage': 'mean'
         }).reset_index(drop=False)
    
    outFrame['PartnerIsoCode'] = isoCode 
    
    outFrame['Isic4'] = outFrame['Isic4'].astype(int).astype(str)
    addZeros = lambda x: (4-len(x))*'0' + x
    outFrame['Isic4'] = [addZeros(x) for x in outFrame['Isic4']]

    # export 4digit    
    outFrame.to_csv(os.path.join(bilateralFolder, 'isic4digit_wits_bilateral_eu_' + str(cCode) + '.csv'), index=False)
    
    # merge with icio codes from 2 digit codes
    outFrame['Isic4_2d'] = [x[0:2] for x in outFrame['Isic4']]
    outFrame['icio'] = [isicDict[x] for x in outFrame['Isic4_2d']]
    
    icioFrame = outFrame.groupby(['Reporter_ISO_N','Year','Partner','PartnerIsoCode','icio']).agg(
        {'Sum_Of_Rates': 'mean',
         'Min_Rate': 'mean',
         'Max_Rate': 'mean',
         'SimpleAverage': 'mean'
         }).reset_index(drop=False)

    icioFrame.to_csv(os.path.join(bilateralFolder, 'icio_wits_bilateral_eu_' + str(cCode) + '.csv'), index=False)
    
    longFrame = pd.concat([longFrame,icioFrame])

longFrame.to_csv(os.path.join(bilateralFolder, 'icio_wits_bilateral_eu_all.csv'), index=False)

sectorFrame = longFrame.groupby(['Reporter_ISO_N', 'Year', 'icio']).agg(
            { 'SimpleAverage': 'mean'}
            ).reset_index(drop=False)

fig, axes = plt.subplots(figsize=(12, 6))
sCodes = set(sectorFrame['icio'])
for sCode in sCodes:
    plt.plot('Year', 'SimpleAverage', data=sectorFrame[sectorFrame.icio == sCode], color='grey')
plt.title('Bilateral tariffs, EU (Reporter) and 2004-NMS (Partner): Sectoral Averages')
plt.show()
FigPath = os.path.join(Query.ImgFolder, 'nms_eu_tariff_dist_avg_sec.pdf')
fig.savefig(FigPath)

