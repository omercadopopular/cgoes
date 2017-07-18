# -*- coding: utf-8 -*-
"""

PROJETO: "Uma Estratégia De Antecipação Dos Impactos Regionais E Setoriais
Da Abertura Comercial Brasileira Sobre O Emprego E Requalificação Da População Afetada"

EQUIPE DO PROJETO: Carlos Góes (SAE), Eduardo Leoni (SAE),
Luís Montes (SAE) e Alexandre Messa (Núcleo Econômico da CAMEX).

OBJETIVO DESTE CÓDIGO: Calcular os equivalentes ad valorem paras as barreiras não-tarifárias brasileiras
para cada setor GTAP, ponderado pelas importações de 2011, utilizando a base de dados de
KEE, NICITA & OLARREAGA (2009). "Estimating Trade Restrictive Indices". The Economic Journal v. 119.

AUTOR DESTE CÓDIGO: Carlos Góes, SAE/Presidência da República

DATA: 18/07/2017

"""

import pandas as pd
import os
import numpy as np


#####################################
# 1. Retrieve Databases 
#####################################

data_ntb = "K://Notas Técnicas//Abertura//data//NTB//AVE_NTB.dta"
gtaphs_df = "K://Notas Técnicas//Abertura//data//NTB//gtaphs2.csv"

pwd = os.getcwd()
os.chdir(os.path.dirname(data_ntb))

ntb_df = pd.read_stata(os.path.basename(data_ntb))
gtaphs_df = pd.read_csv(os.path.basename(gtaphs_df), low_memory=False, sep=";")

os.chdir(pwd)

#####################################
# 2. Clean NTB database and merge with GTAP
#####################################

# Drop NA

ntb_df = ntb_df.dropna(axis=0, subset=["tariff"])

# Iterate through codes and convert them to integers

ntb_df['hscode'] = [int(i) for i in ntb_df['hscode']]

# Join GTAP database

ntb_df = (gtaphs_df
          .set_index("hscode")
          .join(
                ntb_df.set_index("hscode"),
                how="right")
          .reset_index(drop=False)
          )

# Create world simple average and save to CSV

ntb_df_ave = ntb_df.groupby("gtapcode").mean()
ntb_df_ave.to_csv("K://Notas Técnicas//Abertura//data//NTB//ntb_ave.csv", sep=";", decimal=",")
          
# Create a table for Brazil          
          
bra_df = ntb_df[ ntb_df['ccode'] == 'BRA' ]

#####################################
# 3. Retrieve UNCOMTRADE data
#####################################

# Download tinyapp for UNCOMTRADE

import urllib.request
urllib.request.urlretrieve("https://raw.githubusercontent.com/omercadopopular/cgoes/master/tinyapps/PyComtrade/pycomtrade.py", "pycomtrade.py")

# Import function

from pycomtrade import comtrade

# Run API

year = 2011
reporter = 'brazil'
partner = 'world'
freq = 'A'
ccode = 'ALL'

frame = comtrade(reporter, partner, year, freq, ccode)

# Trim result to important variables

frame = frame[['yr','rgDesc','cmdCode','cmdDescE','TradeValue']]

# Drop Total

frame = frame[ frame['cmdCode'] != "TOTAL" ]

# Iterate through codes and convert them to integers

frame['cmdCode'] = [int(i) for i in frame['cmdCode']]

# Select only imports

frame = frame[ frame['rgDesc'] == 'Import' ]

# Merge with Brazil data

bra_df_merge = pd.merge(bra_df, frame, left_on="hscode", right_on="cmdCode", how="left")


#####################################
# 4. Calculate weights
#####################################

# Set empty vector

vec = {}

# Iterate through GTAP codes

for gtapgroup in bra_df_merge['gtapcode'].unique():
    
    # create separate table for each GTAP
    table = bra_df_merge[ bra_df_merge['gtapcode'] == gtapgroup ].copy()
    
    # sum total trade value for that GTAP
    tsum = table['TradeValue'].sum()
    
    # create list with HS codes for that GTAP
    tlist = list(table['hscode'])  
    
    # set index
    table = table.set_index('hscode')
    
    # iterate through HS codes
    for hscode in tlist:
        
        # if trade value is missing, update vector with missing
        if (table.loc[hscode]['TradeValue'] == np.nan):
           vec.update({str(hscode): np.nan})
        
        # else, update it with the weight
        else:
           vec.update({str(hscode): ( table.loc[hscode]['TradeValue'] / tsum )})

# Transform vector into Pandas Series

weights = pd.Series(vec, name="weights").reset_index()

# Iterate through indices and transform them into integers

weights['index'] = [int(i) for i in weights['index']]

# Merge series into Brazil DF

bra_df_merge = pd.merge(bra_df_merge, weights, left_on="hscode", right_on="index", how="left")

# Calculate marginal factors for weighted averages

tlist = ['tariff', 'ave_core', 'ave_doms', 'ave_all']
for name in tlist:
    bra_df_merge[name + '_w'] = bra_df_merge[name] * bra_df_merge['weights']

#####################################
# 5. Consolidate rates
#####################################

# Sum to calculate weighted averages

bra_df_group = bra_df_merge.groupby("gtapcode").sum()
bra_df_group.to_csv("K://Notas Técnicas//Abertura//data//NTB//ntb.csv", sep=";", decimal=",")
