# -*- coding: utf-8 -*-
"""
Created on Mon Jan 22 17:17:02 2018

@author: CarlosABG
"""

import pandas as pd

"""
        CNAE 2    
        80.11-1	Atividades de vigilância e segurança privada
        80.12-9	Atividades de transporte de valores
        80.20-0	Atividades de monitoramento de sistemas de segurança
        80.30-7	Atividades de investigação particular
        
        CNAE 1
        74.60-8	*	Atividades de investigação, vigilância e segurança
        74.60-8	*	Atividades de investigação, vigilância e segurança
        74.60-8	*	Atividades de investigação, vigilância e segurança
        74.60-8	*	Atividades de investigação, vigilância e segurança
"""

# Função para realizar transformações necessárias no arquivo da RAIS

def rais_decoder(FILE,
                 CNAE_TYPE = 1,
                 CNAE_2 = [80111, 80129, 80200, 80307],
                 CNAE_1 = [74608],
                 CHUNKSIZE = 500000):
       
    # Gravar estado e ano
    FILE_NAME = FILE.split("\\")[-1]
    ESTADO = FILE_NAME.split('.')[0][0:2]
    ANO = int(FILE_NAME.split('.')[0][-4:])

    print('Processando: {}... \n'.format(FILE_NAME))

    # Importar arquivo, usando chunksize para evitar consumir muita memória
    READER = pd.read_csv(FILE, sep=';', decimal=',',
                         chunksize=CHUNKSIZE, encoding='latin1',
                         low_memory=False)
    
    COUNTER = 0    
    DF = pd.DataFrame()
    for frame in READER:
        frame = frame[ ['CNAE 95 Classe', 'Vl Remun Média (SM)'] ]

        # Excluir aqueles com remuneração média          
        frame = frame[frame['Vl Remun Média (SM)'] > 0]

        # Exceção para anos em que CNAE vem como string
        try:
            frame['CNAE 95 Classe'] = [item.replace('-', '') for item in frame['CNAE 95 Classe']]
            frame['CNAE 95 Classe'] = frame['CNAE 95 Classe'].astype(int)
        except:
            pass
        
        # Selecionar CNAEs de interesse
        if CNAE_TYPE == 1:
            frame = frame[ frame['CNAE 95 Classe'].isin(CNAE_1) ]
        elif CNAE_TYPE == 2:
            frame = frame[ frame['CNAE 2.0 Classe'].isin(CNAE_2) ]
        else:
            print('Selecionar CNAE 1.0 ou 2.0 e reiniciar rotina!')
            raise KeyboardInterrupt
        
        DF = DF.append(frame)
        COUNTER = COUNTER + 1
        print('Chunk número {} processado'.format(COUNTER))

    print('Dados importados...')
       
    # Criar DataFrame de output
    RESULT = pd.DataFrame.from_dict( data={ 
            'remuneracao_media': DF['Vl Remun Média (SM)'].mean(),
            'numero_empregados': DF['Vl Remun Média (SM)'].count(),
            'estado': ESTADO,
            'ano': ANO,
            }, orient='index').T

    print('Finalizado: {}... \n'.format(FILE_NAME))
    
    return RESULT

# Buscar todos os arquivos de determinado diretório
import os

FILES = []
for root, dirs, files in os.walk("C:\\Users\\CarlosABG\\Desktop\\rais_sp\\", topdown=False):
    for name in files:
          FILES.append(os.path.join(root, name))

# Criar um dataframe com os resultados 
df = pd.DataFrame()
for file in FILES:
    result = rais_decoder(file)
    print(result)
    if len(result) > 0:
        df = df.append(result)
    else:
        pass
    
# Salvar resultado
df.to_csv('H:\\Notas Conceituais\\SegPub-Drogas\\Dados\\results\\rais_consolidado_sp.csv',
          sep=";", decimal=",")
df.to_excel('H:\\Notas Conceituais\\SegPub-Drogas\\Dados\\results\\rais_consolidado_sp.xlsx')