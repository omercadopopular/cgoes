# -*- coding: utf-8 -*-
"""
Created on Tue Jan 16 20:18:35 2024

@author: wb592068
"""

outPath = r'C:\Users\wb592068\OneDrive - WBG\Brazil\figs'
popPath = r'C:\Users\wb592068\OneDrive - WBG\Brazil\data\ibge-pop\state-pop.xlsx'
Path = r'C:\Users\wb592068\OneDrive - WBG\Brazil\data\trade-processed'


import matplotlib.pyplot as plt
import pandas as pd
import os
import numpy as np

FrameUFSum1digitrealpd = pd.read_excel(os.path.join(Path, 'UFISIC1Digitreal.xlsx'))

#FrameUFSum1digitrealpd['VL_FOBr'] = FrameUFSum1digitrealpd['VL_FOBr'] / 1000000000

Frame2002 = FrameUFSum1digitrealpd[ (FrameUFSum1digitrealpd['CO_ANO'] == 2002)  ] 
Frame2022 = FrameUFSum1digitrealpd[ (FrameUFSum1digitrealpd['CO_ANO'] == 2022)  ] 

Estados = ['AC', 'AL', 'AM', 'AP', 'BA', 'CE', 'DF', 'ES', 'GO', 'MA', 'MG',
       'MS', 'MT', 'PA', 'PB', 'PE', 'PI', 'PR', 'RJ',
       'RN', 'RO', 'RR', 'RS', 'SC', 'SE', 'SP', 'TO']

StateFrame = pd.read_excel(popPath, sheet_name='INDEX')

## Calculate Exports per person in 2002

Frame2002 = Frame2002[ Frame2002.SG_UF_NCM.isin(Estados) ]
Pop2002 = StateFrame[ StateFrame['CO_ANO'] == 2002 ]

Frame2002 = pd.merge(Frame2002 , Pop2002, on=['SG_UF_NCM','CO_ANO'], how='left')
Frame2002['VL_FOBrpc'] = Frame2002['VL_FOBr'] / Frame2002['POP']

RealUFTS = (Frame2002.set_index(['CO_ANO', 'SG_UF_NCM', 'NO_ISIC_SECAO_ING'])['VL_FOBrpc']
            .unstack()
            .reset_index(drop=False)
            .drop(columns=['CO_ANO'])
            .set_index('SG_UF_NCM')
            )

RealUFTS.plot(kind='bar', stacked=True, label="", width=0.8)
plt.legend(prop={'size': 8})

plt.xlabel("")
plt.ylabel("US$2022 per person")
plt.ylim(0,9000)

plt.tight_layout()
plt.savefig(os.path.join(outPath, 'UFExports2002.png'), dpi=320)
plt.savefig(os.path.join(outPath, 'UFExports2002.pdf'))
plt.savefig(os.path.join(outPath, 'UFExports2002.eps'))
plt.show()


## Calculate Exports per person in 2022

Frame2022 = Frame2022[ Frame2022.SG_UF_NCM.isin(Estados) ]
Pop2022 = StateFrame[ StateFrame['CO_ANO'] == 2022 ]

Frame2022 = pd.merge(Frame2022 , Pop2022, on=['SG_UF_NCM','CO_ANO'], how='left')
Frame2022['VL_FOBrpc'] = Frame2022['VL_FOBr'] / Frame2022['POP']

RealUFTS = (Frame2022.set_index(['CO_ANO', 'SG_UF_NCM', 'NO_ISIC_SECAO_ING'])['VL_FOBrpc']
            .unstack()
            .reset_index(drop=False)
            .drop(columns=['CO_ANO'])
            .set_index('SG_UF_NCM')
            )

RealUFTS.plot(kind='bar', stacked=True, label="", width=0.8)
plt.legend(prop={'size': 8})

plt.xlabel("")
plt.ylabel("US$2022 per person")
plt.ylim(0,9000)

plt.tight_layout()
plt.savefig(os.path.join(outPath, 'UFExports2022.png'), dpi=320)
plt.savefig(os.path.join(outPath, 'UFExports2022.pdf'))
plt.savefig(os.path.join(outPath, 'UFExports2022.eps'))
plt.show()
