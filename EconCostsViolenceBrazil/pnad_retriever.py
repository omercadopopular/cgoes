# -*- coding: utf-8 -*-
"""
Created on Mon Oct  9 15:00:36 2017

@author: JonasCCS
"""

## PNAD Anual

from ftplib import FTP

pnad_micro = {}

#Acesso ao servidor ftp

server = 'ftp.ibge.gov.br'
ftp = FTP(server)
ftp.login()

#Ir para o diretório desejado

directory = 'Trabalho_e_Rendimento/Pesquisa_Nacional_por_Amostra_de_Domicilios_anual/microdados'
ftp.cwd(directory)

#Vai para cada sub-diretório do diretório acima e resgata os links dos zips
#correspondentes aos Dados e ao input

for i in ftp.nlst():
    ftp.cwd(i)
    
    try:
        year = int(ftp.pwd().split(directory)[1].split('/')[1])
        
        if year >= 1992 and year <= 1999:
            pnad_micro[year] = {'Dados' : server + ftp.pwd() + '/Dados.zip',
                                'Input' : server + ftp.pwd() + '/Layout.zip'}
            
        elif year >=2011 and year <= 2015:
            names = ftp.nlst()
            for k in names:
                if 'Dicionario' in k:
                    dic = '/' + i
                    pnad_micro[year] = {'Dados' : server + ftp.pwd() + '/Dados.zip',
                                        'Input' : server + ftp.pwd() + dic}
        else:
            pass
        
    except:
        pass
    
    ftp.cwd('..')
    

## PNAD Contínua
    
from ftplib import FTP

pnadc_micro = {}

#Acesso ao servidor ftp

server = 'ftp.ibge.gov.br'
ftp = FTP(server)
ftp.login()

#Ir para o diretório desejado

directory = 'Trabalho_e_Rendimento/Pesquisa_Nacional_por_Amostra_de_Domicilios_continua/Trimestral/Microdados/'
ftp.cwd(directory)

ftp.cwd('Documentacao')
for k in ftp.nlst():
    if 'Dicionario' in k:
        dic = '/' + k
ftp.cwd('..')
        
for directory in ftp.nlst():

    try:
        year = int(ftp.pwd().split(directory)[1].split('/')[1])
        
        ftp.cwd(directory)
        names = ftp.nlst()
        address = list()
               
        for k in names:
            address.append(server + ftp.pwd() + '/' + k)
            
        pnadc_micro.update({year: address})
        
        ftp.cwd('..')
        
    except:
        pass       

