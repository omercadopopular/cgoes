# -*- coding: utf-8 -*-
"""
Created on Mon Jan 22 17:17:02 2018

@author: CarlosABG
"""

import pandas as pd

"""

Advogado
2410-05

Advogado (direito penal)

2410-25

Promotor de justiça 

2422-35

Procurador da república

2422-05

Defensor público estadual, Defensor público federal

2424-05

"""

# Função para realizar transformações necessárias no arquivo da RAIS

def rais_decoder(FILE,
                 CBO_PROMOTOR = [242235],
                 CBO_ADVOGADO_CRIMINALISTA = [241005],
                 CBO_DEFENSOR = [242405],
                 CBO_PROCURADOR = [242205],
                 MIN_ANO = 2003,
                 CHUNKSIZE = 250000):
          
    # Gravar estado e ano
    FILE_NAME = FILE.split("\\")[-1]
    ESTADO = FILE_NAME.split('.')[0][0:2]
    ANO = int(FILE_NAME.split('.')[0][-4:])
    
    if ANO < MIN_ANO:
        return pd.DataFrame(), pd.DataFrame(), pd.DataFrame(), pd.DataFrame()

    print('Processando: {}... \n'.format(FILE_NAME))

    # Importar arquivo, usando chunksize para evitar consumir muita memória
    READER = pd.read_csv(FILE, sep=';', decimal=',',
                         chunksize=CHUNKSIZE, encoding='latin1',
                         low_memory=False)
    
    COUNTER = 0    
    DF = pd.DataFrame()
    for frame in READER:
        frame = frame[ ['CBO Ocupação 2002', 'Vl Remun Média (SM)'] ]
        DF = DF.append(frame)
        COUNTER = COUNTER + 1
        print('Chunk número {} processado'.format(COUNTER))

    print('Dados importados...')
    
    # Exceção para anos em que CNAE vem como string
    try:
        DF['CBO Ocupação 2002'] = [item.replace('-', '') for item in DF['CBO Ocupação 2002']]
        DF['CBO Ocupação 2002'] = DF['CBO Ocupação 2002'].astype(int)
    except:
        pass

    # Excluir aqueles com remuneração zero
    DF = DF[DF['Vl Remun Média (SM)'] > 0]
    
    # Selecionar CBOs de interesse
    PROMOTOR = DF[ DF['CBO Ocupação 2002'].isin(CBO_PROMOTOR) ]
    CRIMINALISTA = DF[ DF['CBO Ocupação 2002'].isin(CBO_ADVOGADO_CRIMINALISTA) ]
    DEFENSOR = DF[ DF['CBO Ocupação 2002'].isin(CBO_DEFENSOR) ]
    PROCURADOR = DF[ DF['CBO Ocupação 2002'].isin(CBO_PROCURADOR) ]
       
    print('Transformações realizadas...')
    
    # Criar DataFrame de output
    PROMOTOR = pd.DataFrame.from_dict( data={ 
            'remuneracao_media': PROMOTOR['Vl Remun Média (SM)'].mean(),
            'numero_empregados': PROMOTOR['Vl Remun Média (SM)'].count(),
            'estado': ESTADO,
            'ano': ANO,
            }, orient='index').T

    CRIMINALISTA = pd.DataFrame.from_dict( data={ 
            'remuneracao_media': CRIMINALISTA['Vl Remun Média (SM)'].mean(),
            'numero_empregados': CRIMINALISTA['Vl Remun Média (SM)'].count(),
            'estado': ESTADO,
            'ano': ANO,
            }, orient='index').T

    DEFENSOR = pd.DataFrame.from_dict( data={ 
            'remuneracao_media': DEFENSOR['Vl Remun Média (SM)'].mean(),
            'numero_empregados': DEFENSOR['Vl Remun Média (SM)'].count(),
            'estado': ESTADO,
            'ano': ANO,
            }, orient='index').T

    PROCURADOR = pd.DataFrame.from_dict( data={ 
            'remuneracao_media': PROCURADOR['Vl Remun Média (SM)'].mean(),
            'numero_empregados': PROCURADOR['Vl Remun Média (SM)'].count(),
            'estado': ESTADO,
            'ano': ANO,
            }, orient='index').T
    
    
    print('Finalizado: {}... \n'.format(FILE_NAME))
    
    return PROMOTOR, CRIMINALISTA, DEFENSOR, PROCURADOR

# Buscar todos os arquivos de determinado diretório
import os

FILES = []
for root, dirs, files in os.walk("H:\\Notas Conceituais\\SegPub-Drogas\\Dados\\RAIS", topdown=False):
    for name in files:
          FILES.append(os.path.join(root, name))

# Criar um dataframe com os resultados 
PROMOTOR, CRIMINALISTA, DEFENSOR, PROCURADOR = (pd.DataFrame(), pd.DataFrame(),
                                                pd.DataFrame(), pd.DataFrame())
for file in FILES:
    promotor, criminalista, defensor, procurador = rais_decoder(file)
    if len(promotor) > 0:
        PROMOTOR = PROMOTOR.append(promotor)
    if len(criminalista) > 0:
        CRIMINALISTA = CRIMINALISTA.append(criminalista)
    if len(criminalista) > 0:
        DEFENSOR = DEFENSOR.append(defensor)
    if len(procurador) > 0:
        PROCURADOR = PROCURADOR.append(procurador)
        
# Salvar resultado
PROMOTOR.to_excel('H:\\Notas Conceituais\\SegPub-Drogas\\Dados\\results\\rais_promotor.xlsx', index=False)
CRIMINALISTA.to_excel('H:\\Notas Conceituais\\SegPub-Drogas\\Dados\\results\\rais_criminalista.xlsx', index=False)
DEFENSOR.to_excel('H:\\Notas Conceituais\\SegPub-Drogas\\Dados\\results\\rais_defensor.xlsx', index=False)
PROCURADOR.to_excel('H:\\Notas Conceituais\\SegPub-Drogas\\Dados\\results\\rais_procurador.xlsx', index=False)
