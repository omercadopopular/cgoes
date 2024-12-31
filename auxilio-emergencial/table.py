# -*- coding: utf-8 -*-
"""
Spyder Editor

This is a temporary script file.
"""

ReadPath = r'C:\Users\goes\Downloads\AuxilioEmergencial'
WritePath = r'C:\Users\goes\OneDrive - UC San Diego\UCSD\Research\cgoes\auxilio-emergencial\outfiles'

import os
import pandas as pd

col = {
       'MÊS DISPONIBILIZAÇÃO': 'mes',
       'UF': 'uf',
       'CÓDIGO MUNICÍPIO IBGE': 'codigo_ibge',
       'NOME MUNICÍPIO': 'nome_mun',
       'NIS BENEFICIÁRIO': 'nis',
       'CPF BENEFICIÁRIO': 'cpf',
       'NOME BENEFICIÁRIO': 'nome_beneficiario',
       'NIS RESPONSÁVEL': 'nis_resp',
       'CPF RESPONSÁVEL': 'cpf_resp',
       'NOME RESPONSÁVEL': 'nome_resp',
       'ENQUADRAMENTO': 'enquadramento',
       'PARCELA': 'parcela',
       'OBSERVAÇÃO': 'obs',
       'VALOR BENEFÍCIO': 'valor'
       }


Files = []
for root, dirs, files in os.walk(ReadPath, topdown=False):
    for name in files:
          Files.append(os.path.join(root, name))

for File in Files:
    print('Processing {}...'.format(File))
    Complete = pd.DataFrame()
    Chunks = pd.read_csv(File, encoding='iso-8859-1', sep=';', dtype={'CÓDIGO MUNICÍPIO IBGE': str}, chunksize=1000000)
    for Chunk in Chunks:
        Frame = Chunk.rename(columns=col)
        Frame = Frame[ (Frame.obs != 'Pagamento bloqueado ou cancelado') &
                         (Frame.obs != 'Valor devolvido à União.') ]
        Frame['valor'] = Frame['valor'].map(lambda x: float(x.replace(',','.')))
        Frame = Frame[ ['mes','uf','codigo_ibge','nome_mun','valor'] ]
        Complete = Complete.append(Frame.groupby(['mes','uf','codigo_ibge','nome_mun']).sum())
    Complete = Complete.groupby(['mes','uf','codigo_ibge','nome_mun']).sum()
    Complete.to_csv(os.path.join(WritePath,File.split("\\")[-1]))
            
    
