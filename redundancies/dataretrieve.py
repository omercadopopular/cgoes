# -*- coding: utf-8 -*-
"""
Created on Tue Jun 13 15:47:00 2017

@author: CarlosABG
"""

import json
import urllib
import pandas as pd
import ssl
import numpy as np
import re
import nltk
import math

#### DATA IMPORT

#Import JSON from dados.gov.br

url = "http://estruturaorganizacional.dados.gov.br/doc/estrutura-organizacional/completa.json"
ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE
urlopen = urllib.request.urlopen(url, context=ctx)
data = json.loads(urlopen.read())

# Transform JSON file into pandas dataframe

data = pd.io.json.json_normalize(data['unidades'])

#### DROP IRRELEVANT OUT OF SCOPE OF ANALYSIS

# Set missing values

data['competencia'] = data['competencia'].replace(to_replace=["",".",".\n\n"], value=np.nan)
data['finalidade'] = data['finalidade'].replace(to_replace=["",".",".\n\n"], value=np.nan)
data['missao'] = data['missao'].replace(to_replace=["",".",".\n\n"], value=np.nan)

# Build concatenated column

data['texto'] = data['competencia'] + " " + data['finalidade'] 
data['texto'] = data['texto'].replace(to_replace="", value=np.nan)

# Drop missing valuables

data = data.dropna(subset=["texto"])

# Keep only bureaus in Brasilia

data = data.dropna(subset=["endereco"])
data['uf'] = [row[0]['uf'] for row in data['endereco']]
workdata = data[ data['uf'] == 'DF'].copy()

# Drop columns which are not relevant

workdata = workdata.drop([
       'competencia', 'contato',
       'dataFinalVersaoConsulta', 'dataInicialVersaoConsulta',
       'descricaoAtoNormativo', 'endereco', 'finalidade', 'missao',
       'nivelNormatizacao', 'versaoConsulta', 'operacao'
       ], axis=1)

# Drop duplicates

workdata = workdata.drop_duplicates(subset='nome', keep='first')

# Reset index

workdata = workdata.reset_index()

#### CLEAN WORD DATASET

# Iterate through relevant text data and trim irrelevant words

trimmed = []
for row in workdata['texto']:
    text = row
    text = re.sub(r'\xa0\xa0\xa0\xa0\xa0', ' ', text)
    text = re.sub(r'\r\n', ' ', text)
    text = re.sub(r"\d", ' ', text)    
    text = re.sub(r'-', ' ', text)
    text = re.sub(r'\tI', ' ', text)
    text = re.sub(r'I\t', ' ', text)
    text = re.sub(r'I ', ' ', text)
    text = re.sub(r'II', ' ', text)
    text = re.sub(r'III', ' ', text)    
    text = re.sub(r'IV', ' ', text)    
    text = re.sub(r'V', ' ', text)    
    text = re.sub(r'VI', ' ', text)    
    text = re.sub(r'VII', ' ', text)    
    text = re.sub(r'VIII', ' ', text)    
    text = re.sub(r'IX', ' ', text)    
    text = re.sub(r'X', ' ', text)    
    text = re.sub(r'XI', ' ', text)    
    text = re.sub(r'XII', ' ', text)    
    text = re.sub(r'XIII', ' ', text)    
    text = re.sub(r'XIV', ' ', text)    
    text = re.sub(r'XV', ' ', text)    
    text = re.sub(r'XVI', ' ', text)    
    text = re.sub(r'XVII', ' ', text)    
    text = re.sub(r'XVIII', ' ', text)    
    text = re.sub(r'XIX', ' ', text)    
    text = re.sub(r"a\)", ' ', text)    
    text = re.sub(r"b\)", ' ', text)    
    text = re.sub(r"c\)", ' ', text)    
    text = re.sub(r"d\)", ' ', text)    
    text = re.sub(r"e\)", ' ', text)    
    text = re.sub(r"f\)", ' ', text)    
    text = re.sub(r"g\)", ' ', text)    
    text = re.sub(r"h\)", ' ', text)    
    text = re.sub(r"i\)", ' ', text)    
    text = re.sub(r"j\)", ' ', text)    
    text = re.sub(r"k\)", ' ', text)    
    text = re.sub(r"l\)", ' ', text)    
    text = re.sub(r"m\)", ' ', text)    
    text = re.sub(r"n\)", ' ', text)    
    text = re.sub(r"o\)", ' ', text)    
    text = re.sub(r"p\)", ' ', text)    
    text = re.sub(r"q\)", ' ', text)    
    text = re.sub(r"r\)", ' ', text)    
    text = re.sub(r"s\)", ' ', text)    
    text = re.sub(r"t\)", ' ', text)    
    text = re.sub(r"u\)", ' ', text)    
    text = re.sub(r"v\)", ' ', text)    
    text = re.sub(r"x\)", ' ', text)    
    text = re.sub(r"z\)", ' ', text)    
    text = re.sub(r"janeiro ", ' ', text)    
    text = re.sub(r"fevereiro ", ' ', text)    
    text = re.sub(r"março ", ' ', text)    
    text = re.sub(r"abril ", ' ', text)    
    text = re.sub(r"maio ", ' ', text)    
    text = re.sub(r"junho ", ' ', text)    
    text = re.sub(r"julho ", ' ', text)    
    text = re.sub(r"agosto ", ' ', text)    
    text = re.sub(r"setembro ", ' ', text)    
    text = re.sub(r"outubro ", ' ', text)    
    text = re.sub(r"novembro ", ' ', text)    
    text = re.sub(r"dezembro ", ' ', text)    
    text = re.sub(r"1º    ", ' ', text)    
    text = re.sub(r"2º    ", ' ', text)    
    text = re.sub(r"3º    ", ' ', text)    
    text = re.sub(r"4º    ", ' ', text)    
    text = re.sub(r"5º    ", ' ', text)    
    text = re.sub(r"6º    ", ' ', text)    
    text = re.sub(r"7º    ", ' ', text)    
    text = re.sub(r"8º    ", ' ', text)    
    text = re.sub(r"9º    ", ' ', text)    
    text = re.sub(r"9º    ", ' ', text)    
    text = re.sub(r"Art.", ' ', text)    
    text = re.sub(r"artigo ", ' ', text)    
    text = re.sub(r"art ", ' ', text)    
    text = re.sub(r"parágrafo ", ' ', text)    
    text = re.sub(r'nº', ' ', text)
    text = re.sub(r'º', ' ', text)
    text = re.sub(r'Dec ', ' ', text)
    text = re.sub(r'decreto ', ' ', text)
    text = re.sub(r'Lei ', ' ', text)
    text = re.sub(r'lei ', ' ', text)
    text = re.sub(r'\/', ' ', text)
    text = re.sub(r'\(', ' ', text)
    text = re.sub(r'\)', ' ', text)
    text = re.sub(r'\u201d', '', text)
    text = re.sub(r'\u201c', '', text)
    text = re.sub(r'\.', ' ', text)
    text = re.sub(r'\;', ' ', text)
    text = re.sub(r'\:', ' ', text)
    text = re.sub(r'\,', ' ', text)
    text = re.sub(r'\n', ' ', text)
#    text = re.sub(r'nstituto', 'Instituto', text)
#    text = re.sub(r'nspet', 'Inspet', text)
#    text = re.sub(r'nfo', 'Info', text)
    trimmed.append(text)

workdata['trimmed'] = trimmed

# Import stopwords

stopwords = nltk.corpus.stopwords.words('portuguese')
stopwords.append(['n','i'])

# Trim stopwords

worddata = []
for row in workdata['trimmed']:
    rowvector = []
    for word in row.split():
        wordlower = word.lower()
        if wordlower not in stopwords:
            rowvector.append(wordlower)
        else:
            continue      
    worddata.append(rowvector)

workdata['worddata'] = worddata

totalwords = sum([len(row) for row in worddata])

#### WORD ANALYSIS

def lexicon(corpus):
    lexicon = set()
    for doc in corpus:
        lexicon.update([word for word in doc])
    return lexicon

vocabulary = sorted(lexicon(worddata))

## Verificar se cada palavra do vocabulário está presente
    
def freq(term, document):
    return document.count(term)

doc_term_matrix = []
for doc in worddata:
    tf_vector = [freq(word, doc) for word in vocabulary]
    doc_term_matrix.append(tf_vector)
    
## Contar frequência percentual a cada vetor 

def freq_counter(vec):
    denom = np.sum([item for item in vec])
    return [item / denom for item in vec]

freq_term_matrix = []
for vec in doc_term_matrix:   
    freq_term_matrix.append(freq_counter(vec))
    
## Contar frequência normalizada
  
def normalizer(vec):
    denom = np.sum([item**2 for item in vec])
    return [item / math.sqrt(denom) for item in vec]

normalized_term_matrix = []
for vec in doc_term_matrix:   
    normalized_term_matrix.append(normalizer(vec))
