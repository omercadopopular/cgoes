"""
PROJETO: "Identificação de Redundâncias no Setor Público com Modelos de Espaços Vetoriais e
Análises de Componentes Principais: o Caso Brasileiro"

EQUIPE DO PROJETO: Carlos Góes (SAE) e Eduardo Leoni (SAE).

AUTOR DESTE CÓDIGO: Carlos Góes, SAE/Presidência da República

OBJETIVO DESTE CÓDIGO: Realizar análise de similaridade de agências, com base em um modelo de espaço vetoriais,
usando base de dados limpa anteriormente.

DATA: 22/06/2017
"""

import pandas as pd
import numpy as np
from sklearn.metrics.pairwise import cosine_similarity
from tabulate import tabulate

#####################################
# 1. Read Data 
#####################################

workdata = pd.read_json(path_or_buf="K://Notas Técnicas//Redundacias no Setor Publico//results//workdata.json")
worddata = workdata['worddata']

#####################################
# 2. Create vocabulary
#####################################

def vocab(collection,threshold):
    vocab = set()
    for doc in collection:
        vocab.update([word for word in doc if len(word) >= threshold])
    return vocab

vocabulary = sorted(vocab(worddata, 3))

#####################################
# 3. Create Bag of Words
# Calculate term frequency, for each term in vocabulary, for each bureau.
#####################################
    
def freq(term, document):
    return document.count(term)

tf = []
for bureau in worddata:
    vec = [freq(word, bureau) for word in vocabulary]
    tf.append(vec)

matrix_tf = np.reshape(tf, (len(vocabulary), len(worddata))) 
    
#####################################
# 4. Count the number of words per bureau
#####################################

# Words per bureau

wordsperbureau = [sum(bureau) for bureau in tf]
uniquewordsperbureau = [sum(item > 0 for item in bureau) for bureau in tf]

"""
for bureau in tf:
    wordsperbureau.append(sum(bureau))
    uniquewordsperbureau.append(sum(item > 0 for item in bureau))
"""
    
workdata['wordsperbureau'] = wordsperbureau
workdata['uniquewordsperbureau'] = uniquewordsperbureau   
    
# Counts per word

vocabfreq = matrix_tf.sum(axis=1)
       
#####################################
# 5. Create df-idf weights
#####################################
    
## Compute document frequency for each word in vocab

def df(word, collection):
    count = 0
    for doc in collection:
        if freq(word, doc) > 0:
            count += 1
        else:
            continue
    return count

## Compute inverse document frequency for each word in vocab
    
idf = [np.log(len(worddata) / df(word, worddata)) for word in vocabulary]

## Assing weights for each bureau
    
def weight(bureau):
    vec = []
    counter = 0
    for word in bureau:
        vec.append(bureau[counter] * idf[counter])
        counter += 1
    return vec

tfidf = [weight(bureau) for bureau in tf]
    
# Reshape matrix

matrix_tfidf = np.reshape(tfidf, (len(vocabulary), len(worddata))) 

#####################################
# 6. Calculate cosine similarity
#####################################

matrix_cosine = cosine_similarity(matrix_tfidf.T, matrix_tfidf.T)

matrix_cosine_df = pd.DataFrame(data=matrix_cosine, index=workdata['nome'], columns=workdata['nome'])

#####################################
# 7. Calculate redundancy score
#####################################
   
rawredundancyscore = [sum(bureau) for bureau in matrix_cosine]

m_mean = sum(rawredundancyscore) / len(rawredundancyscore)
m_std = np.std(rawredundancyscore)
    
redundancyscore = [( score -  m_mean ) / m_std for score in rawredundancyscore]

workdata['redundancy'] = redundancyscore

#####################################
# 8. Calculate descriptive statistics table
#####################################

wordsperbureau = workdata['wordsperbureau']
uniquewordsperbureau = workdata['uniquewordsperbureau'] 
 

ds_totalwords = sum(wordsperbureau)
ds_medianwords = np.median(wordsperbureau)
ds_meanwords = np.mean(wordsperbureau)
ds_std = np.std(wordsperbureau)
ds_totalwords_u = len(vocabulary)
ds_medianwords_u = np.median(uniquewordsperbureau)
ds_meanwords_u = np.mean(uniquewordsperbureau)
ds_std_u = np.std(uniquewordsperbureau)
ds_nobs = len(worddata)

## Organize Table

table = [["Total stems:", ds_totalwords, ds_medianwords, ds_meanwords, ds_std],
        ["Unique stems:", ds_totalwords_u, ds_medianwords_u, ds_meanwords_u, ds_std_u]]

header = ["Whole sample", "Median per bureau", "Mean per bureau", "St.Dev. per bureau"]

print( "Table. Descriptive Statistics: Brazilian Government Bureaus Stems. n = {0}".format(ds_nobs)
     , tabulate(table, header, tablefmt="fancy_grid") )

file = open("K://Notas Técnicas//Redundacias no Setor Publico//results//table1.txt", 'w')
file.write("Table. Descriptive Statistics: Brazilian Government Bureaus Stems. n = {0}".format(ds_nobs))
file.write("\n")
file.write(tabulate(table, header, tablefmt="latex"))
file.close()

#####################################
# 9. Save Final Data
#####################################

workdata.to_json("K://Notas Técnicas//Redundacias no Setor Publico//results//finaldata.json")
matrix_cosine_df.to_json("K://Notas Técnicas//Redundacias no Setor Publico//results//matrix_cosine_df.json")



  

