# -*- coding: utf-8 -*-
"""
Created on Tue Aug 31 15:16:01 2021

@author: Carlos
"""

import os
import numpy as np
import textract

Path = r'C:\Users\Carlos\OneDrive - UC San Diego\UCSD\Research\cgoes\TinyApps\WTODownloader\pdf-dsb\dsb-minutes-Documents_list_31_08_2021'
SavePath = r'C:\Users\Carlos\OneDrive - UC San Diego\UCSD\Research\cgoes\TinyApps\WTODownloader\minutes-parsing'

Files = []
for Root, Dirs, List in os.walk(Path):
    for Name in List:
          Files.append(os.path.join(Path, Name))

for File in Files:
    Name = File.split('\\')[-1].split('.')[0]
    Ext = File.split('\\')[-1].split('.')[-1]
    
    print(File)
    
    if (Ext != 'pdf'):
        continue

    Text = textract.process(File, language='eng').decode()
    
    StringReplacement = {'(': '',
                         ')': '',
                         '.': '',
                         ',': '',
                         '\r': '',
                         '\x0c': '',
                         '\n': ' '                    
                            }
    
    for element in StringReplacement.keys():
        Text = Text.replace(element, StringReplacement[element])
    
    Vector = np.array(Text.split(' '))
    Mask = ['WT/DS' in x for x in Vector]
    Output = set(Vector[Mask])
    
    List = open(os.path.join(SavePath, Name + '.txt') ,"w")
    
    for element in Output:
        List.write('{} \n'.format(element))
    List.close()   

    
