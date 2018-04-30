# -*- coding: utf-8 -*-
"""
Created on Thu Jan 25 13:19:52 2018

@author: CarlosABG
"""

import pandas as pd

FILE = r"H:\\Notas Conceituais\\SegPub-Drogas\\Dados\\Susepe\\Ses_seguros.csv"
FILE_UFs = r"H:\\Notas Conceituais\\SegPub-Drogas\\Dados\\Susepe\\SES_UF2.csv"

######### CÓDIGOS DE RESTRIÇÃO

COD_PATRIMONIAL = [ 111, 112, 113, 114, 115,
                   116, 117, 118, 141, 142,
                   143, 167, 171, 173, 176,
                   195, 196 ]
                  
COD_AUTO = [ 520, 523, 524, 525,
            526, 531, 542, 544,
            553, # Excluir DPVAT --> 583, 588, 589, 
            621, 622, 623, 627, 628,
            632, 638, 644, 652, 654,
            655, 656, 658 ]

COD_CARGA = [ 621 , 622, 623, 627, 628,
             632, 638, 644, 652, 654,
             655, 656, 658 ]



######### IMPORTAR BASE DADOS

DF = pd.read_csv(FILE, sep=";", decimal=",", low_memory=False)
DF['ano'] = [int(str(data)[0:4]) for data in DF['damesano']]

# DF['damesano'] = pd.to_datetime(DF['damesano'], format='%Y%m')
# DF['ano'] = [data.year for data in DF['damesano']]

UF = pd.read_csv(FILE_UFs, sep=";", decimal=",", low_memory=False, encoding='latin1')
UF['ano'] = [int(str(data)[0:4]) for data in UF['damesano']]
UF = UF[ UF['ano'] == 2015]
UF = UF.groupby('UF').sum()

DF['sinistro'] = DF['sinistro_retido'] + DF['sinistro_ocorrido']

######### RESTRINGIR AMOSTRA

PATRIMONIAL = DF[ DF['coramo'].isin(COD_PATRIMONIAL) ]
AUTO = DF[ DF['coramo'].isin(COD_AUTO) ]
CARGA = DF[ DF['coramo'].isin(COD_CARGA) ]

######### CONSOLIDAR ANOS

AUTO_ANO = AUTO.groupby('ano').sum()
PATRIMONIAL_ANO = PATRIMONIAL.groupby('ano').sum()
CARGA_ANO = CARGA.groupby('ano').sum() 

######### EXPORTAR

EXPORT = pd.DataFrame( data={'auto': AUTO_ANO['premio_de_seguros'],
                             'patrimonial': PATRIMONIAL_ANO['premio_de_seguros'],
                             'carga': CARGA_ANO['premio_de_seguros']})

EXPORT.to_csv(r"H:\\Notas Conceituais\\SegPub-Drogas\\Dados\\Susepe\\consolidado2000-2015.csv",
              sep=";", decimal=",")

SINISTRO = pd.DataFrame( data={'auto': AUTO_ANO['sinistro'],
                             'patrimonial': PATRIMONIAL_ANO['sinistro'],
                             'carga': CARGA_ANO['sinistro']})

SINISTRO.to_csv(r"H:\\Notas Conceituais\\SegPub-Drogas\\Dados\\Susepe\\sinistro2000-2015.csv",
              sep=";", decimal=",")

