import pandas as pd

prefeito = pd.read_csv(r'https://raw.githubusercontent.com/omercadopopular/eleicoes2016/master/prefeito.csv')

partidos_lista = ['PMDB','PT','PSDB','DEM']

resposta_a = [len(prefeito[ prefeito['partido'] == i ]) for i in partidos_lista]

print(resposta_a)

resposta_b = [len(prefeito[ prefeito['candidaturas_mun'] == i].groupby("municipio_codigo")) for i in range(2,6)]

print(resposta_b)

resposta_c = prefeito[ prefeito['candidaturas_mun'] == max(prefeito['candidaturas_mun'])]['municipio']

print(resposta_c)

resposta_d = prefeito[ prefeito['municipio'] == 'SÃO PAULO']['partido']

print(resposta_d)
