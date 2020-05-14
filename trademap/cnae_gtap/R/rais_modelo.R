library(dplyr)
library(readxl)


## modelo - matriz com gtap nas colunas e anos nas linhas
modelo <- readxl::read_excel("data/FS_10.xlsx", sheet = "PO", col_names=FALSE)[,-1]
names(modelo) <- 1:ncol(modelo)
## converte para Ano, gtap, Valor 
modelo <- reshape2::melt(modelo%>%as.matrix, varnames=c("Ano", "gtap"))
## adiciona gtap 0 para os CNAE sem correspondencia
modelo <- bind_rows(
  modelo,
  modelo%>%distinct(Ano)%>%mutate(gtap=0, value=0))



#rais por municipio e gtap
load("results/rais_mun.RData")

rais_mun <- rais_mun_all%>%
  ## se nao tem correspondencia rais->gtap, coloca como gtap 0
  mutate(gtap=if_else(is.na(gtap), 0, gtap))%>%
  ## junta com o modelo
  left_join(modelo%>%filter(Ano==20), by='gtap')%>%
  ## por municipio e ano
  group_by(mun_trab, Ano)%>%
  mutate(
    ## confirmar que a conta é essa mesmo
    nnew=n*(1+value/100))%>%
  summarise(
    ## o quantitativo original
    norig=sum(n),
    ## o quantitativo final
    nfinal=sum(nnew),
    ## a diferenca em numeros absolutos
    ndif=nfinal-norig,
    ## a diferenca em termos percentuais
    pdif=ndif/norig)


rais_uf <- rais_mun_all%>%
  mutate(gtap=if_else(is.na(gtap), 0, gtap))%>%
  left_join(modelo%>%filter(Ano==20), by='gtap')%>%
  group_by(uf=substr(mun_trab,1,2), Ano)%>%
  mutate(
    nnew=n*(1+value/100))%>%
  summarise(
    norig=sum(n),
    nfinal=sum(nnew),
    ndif=nfinal-norig,
    pdif=ndif/norig)


rais_reg <- rais_mun_all%>%
  mutate(gtap=if_else(is.na(gtap), 0, gtap))%>%
  left_join(modelo%>%filter(Ano==20), by='gtap')%>%
  group_by(regiao=substr(mun_trab,1,1), Ano)%>%
  mutate(
    nnew=n*(1+value/100))%>%
  summarise(
    norig=sum(n),
    nfinal=sum(nnew),
    ndif=nfinal-norig,
    pdif=ndif/norig)


rais_ano <- rais_mun_all%>%
  mutate(gtap=if_else(is.na(gtap), 0, gtap))%>%
  left_join(modelo, by='gtap')%>%
  group_by(Ano)%>%
  mutate(
    nnew=n*(1+value/100))%>%
  summarise(
    norig=sum(n),
    nfinal=sum(nnew),
    ndif=nfinal-norig,
    pdif=ndif/norig)

library(ggplot2)
qplot(Ano, pdif, data=rais_ano) 

qplot(pdif, data=rais_mun) 
