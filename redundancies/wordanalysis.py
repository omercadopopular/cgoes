"""
PROJETO: "Identificação de Redundâncias no Setor Público com Modelos de Espaços Vetoriais e
Análises de Componentes Principais: o Caso Brasileiro"

EQUIPE DO PROJETO: Carlos Góes (SAE) e Eduardo Leoni (SAE).

AUTOR DESTE CÓDIGO: Carlos Góes, SAE/Presidência da República

OBJETIVO DESTE CÓDIGO: Realizar análise de similaridade de agências, com base em um modelo de espaço vetoriais,
usando base de dados limpa anteriormente.

DATA: 16/06/2017
"""

import pandas as pd
import numpy as np
import math

# READ DATASET

workdata = pd.read_json(path_or_buf="K://Notas Técnicas//Redundacias no Setor Publico//results//workdata.json")

worddata = workdata['worddata']
totalwords = sum([len(row) for row in worddata])

#### BAG OF WORDS: WORD ANALYSIS

# Create vocabulary

def vocab(collection,threshold):
    vocab = set()
    for doc in collection:
        vocab.update([word for word in doc if len(word) >= threshold])
    return vocab

vocabulary = sorted(vocab(worddata, 3))

## Check if vocab words are present for each bureau
    
def freq(term, document):
    return document.count(term)

tf = []
for bureau in worddata:
    vec = [freq(word, bureau) for word in vocabulary]
    tf.append(vec)
    
## Count words per bureau

wordsperbureau = []
for bureau in tf:
    wordsperbureau.append(sum(vec))
    
## Document Frequency

def df(word, collection):
    count = 0
    for doc in collection:
        if freq(word, doc) > 0:
            count += 1
        else:
            continue
    return count
    
idf = [np.log(len(worddata) / df(word, worddata)) for word in vocabulary]

## IDF weighting

def weight(bureau):
    vec = []
    counter = 0
    for word in bureau:
        vec.append(bureau[counter] * idf[counter])
        counter += 1
    return vec

tfidf = []
for bureau in tf:
    tfidf.append(weight(bureau))
  
## Divide TF-IDF vector by norm 
  
def normed(vec):
    denom = np.sum([item**2 for item in vec])
    return [item / math.sqrt(denom) for item in vec]

normedtfidf = []
for vec in tfidf:   
    normedtfidf.append(normed(vec))
       
## Calculate Cosine-Similarity

def similarity(bureau1, collection):
    vec = []
    for bureau2 in collection:
        vec.append(np.dot(bureau1, bureau2))
    return vec

similarityscore = []
for bureau in normedtfidf:
    similarityscore.append(similarity(bureau, normedtfidf))
    
## Calculate redundancy score

redundancyscore =[]
for bureau in similarityscore:
    redundancyscore.append(np.mean(bureau))
