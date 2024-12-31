# -*- coding: utf-8 -*-
"""
Created on Tue Jan 16 20:18:35 2024

@author: wb592068
"""

outPath = r'C:\Users\wb592068\OneDrive - WBG\Brazil\figs'
Path = r'C:\Users\wb592068\OneDrive - WBG\Brazil\data\trade-processed'


import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np
import pandas as pd

firstYear = 1997
lastYear = 2023
maxRange = lastYear - firstYear

FrameSum1digitrealpd = pd.read_excel(os.path.join(Path, 'ISIC1Digitreal.xlsx')).set_index(['CO_ANO', 'NO_ISIC_SECAO_ING'])

FrameSum1digitrealpd['VL_FOBr'] = FrameSum1digitrealpd['VL_FOBr'] / 1000000000

RealTS = FrameSum1digitrealpd['VL_FOBr'].unstack()

RealTS.plot(kind='bar', stacked=True, label="", width=0.8)
plt.legend(prop={'size': 8})

plt.xlabel("")
plt.ylabel("US$2022 (billion)")
plt.ylim(0,600)

plt.tight_layout()
plt.savefig(os.path.join(outPath, 'timeSeriesReal.png'), dpi=240)
plt.savefig(os.path.join(outPath, 'timeSeriesReal.pdf'))
plt.savefig(os.path.join(outPath, 'timeSeriesReal.eps'))
plt.show()

plt.show()