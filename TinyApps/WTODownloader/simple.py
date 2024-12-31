# -*- coding: utf-8 -*-
"""
Created on Wed Jun 30 20:28:13 2021

@author: Carlos
"""

import wget
import os

os.chdir(r'C:\Users\Carlos\OneDrive - UC San Diego\UCSD\Research\cgoes\TinyApps\WTODownloader')

DSBM = lambda x: 'https://docs.wto.org/dol2fe/Pages/SS/directdoc.aspx?filename=q:/WT/DSB/M' + str(x) + '.pdf'

minn = 248
maxn = 453

for n in range(minn,maxn+1):
    file = wget.download(DSBM(n))
    if file == 'error.txt':
        os.remove(file)
        print('File M{}.pdf'.format(n) + ' does not exist. Break loop.')
        break
    else:
        print('Downloaded file M{}.pdf'.format(n))