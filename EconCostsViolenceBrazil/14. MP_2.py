# -*- coding: utf-8 -*-
"""

Este programa organiza os dados raspados do site do CNMP em séries temporais
nacionais e estaduais. 

Há uma classe com três funções:

* MP.walk() busca todos os arquivos de determinado diretório definido pelo usuário
e restringe a amostra aos arquivos de texto, retornando uma lista de arquivos.
* MP.type_retrieve() chama MP.walk(), restringindo a amostra à terminação especificada
pelo usuário, retornando uma lista de arquivos.
* MP.df_return() importa o arquivo bruto raspado, faz transformações de string para
float nos dados brutos, soma os tipos de movimentações em categorias distintas de processos,
adiciona ANO e ESTADO, retornando um DataFrame.

Escrito por Carlos Góes em 04 de abril de 2018.

"""

import pandas as pd
import numpy as np
import os
import re


path = r'H:\Notas Conceituais\SegPub-Drogas\Dados\MP\Atuacao Funcional'

class MP:
    
    def walk(path):
        FILES = []
        for root, dirs, files in os.walk(path, topdown=False):
            for name in files:
                if name[-4:] == '.csv':
                  FILES.append(os.path.join(root, name))
        return FILES
    
    def type_retrieve(path, ext):
        if isinstance(ext, str) == False:
            raise SyntaxError("ext precisa ser uma string")
        else:
            FILES = MP.walk(path)
            FILES_SUBSET = [item for item in FILES if item[-len(ext):] == ext]
            return FILES_SUBSET
               
    def df_return(file):
        LIST_FILE = os.path.basename(file).split('_')
        ESTADO, ANO = LIST_FILE[2], LIST_FILE[3]
        DF = pd.read_csv(file, encoding='utf8', na_values=['Não preenchível', ' - '], decimal=",")
        DF = DF.drop(['Ordem'], axis=1)
        
        DF['Indicador'] = [re.sub('  ',' ',item) for item in DF['Indicador']]
        
        vec = []
        for item in DF['Ocorrências']:
            if isinstance(item, str):
                TEMP_STR = re.sub('\.','',item)
                TEMP_STR = re.sub('\,','.',TEMP_STR)
                vec.append(float(TEMP_STR))
            elif isinstance(item, int):
                vec.append(item)
            elif isinstance(item, float):
                vec.append(float(item))
            else:
                vec.append(np.nan)

        DF['Ocorrências'] = vec
        
        DF_TRANSFORMED = DF.groupby('Indicador').sum().dropna().T
        DF_TRANSFORMED['ESTADO'] = [ESTADO]
        DF_TRANSFORMED['ANO'] = [int(ANO)]
        
        return DF_TRANSFORMED
        
    def df_merge(files):
        DF_MERGED = pd.DataFrame()
        for file in files:
            DF = MP.df_return(file)
            if len(DF) > 0:
                DF_MERGED = DF_MERGED.append(DF)
        DF_MERGED = DF_MERGED.sort_values(['ESTADO','ANO'])
        return DF_MERGED
    
PATHS = {
        'funcional': {
                'path': r'H:\Notas Conceituais\SegPub-Drogas\Dados\MP\Atuacao Funcional',
                'ext': ['PROCESSOS.csv', 'EXEC-PENAL.csv']
                },
        'admin': {
                'path': r'H:\Notas Conceituais\SegPub-Drogas\Dados\MP\Atuacao Administrativa',
                'ext': ['DADOS ORCAMENTARIOS.csv', 'GESTAO-PESSOAS.csv']
                },
        'funcional_novo': {
                'path': r'H:\Notas Conceituais\SegPub-Drogas\Dados\MP\Novos Dados Atuacao Funcional',
                'ext': ['CIVEL.csv', 'ELEITORAL.csv']
                }
        }
        
RESULT_PATH = r'H:\Notas Conceituais\SegPub-Drogas\Dados\MP\results'
        
for kind in PATHS:
    path = PATHS[kind]['path']
    for item in PATHS[kind]['ext']:
        files = MP.type_retrieve(path, item)
        df = MP.df_merge(files)
        df.to_csv(RESULT_PATH + '\consolidado_' + item, sep=";", decimal=",")
