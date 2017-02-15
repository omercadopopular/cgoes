#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////// ESCRITO POR /////////////////////////////////
#///////////////////////////////// CARLOS GÓES /////////////////////////////////
#////////////////////////////////////// E //////////////////////////////////////
#//////////////////////////////// RADUAN MEIRA /////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////
#///////////////////////// INSTITUTO MERCADO POPULAR ///////////////////////////
#/////////////////////////// www.mercadopopular.org ////////////////////////////
#///////////////////////////////////////////////////////////////////////////////

#///////////////////////////////////////////////////////////////////////////////
#////////////////////////////////// LEIA-ME ////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////
  
  /*
  
  Descrição do projeto

Usa dados do arquivo resultados19962012.txt,
organizado com dados brutos do TSE sobre resultados eleitorais,
para detalhar a distribuicao de prefeituras entre blocos de alianças
eleitorais distintas (tucanos, petistas e outros) e o papel do PMDB nos outros.

Calcula o número efetivo de partidos em cada eleição.

*/
  

#

setwd("U:/Research/partidos/basededados/")

library(ggplot2)
library(ggmap)
library(maps)
library(mapproj)

baseline <- read.csv(file="U:/Research/partidos/basededados/prefeito.csv",head=TRUE,sep=",")

partidos = 6

brazilmap <-  get_map(
  "Brazil",
  zoom = 4,
  color="bw",
  maptype ="hybrid"
)

lista <- names(baseline[,1:partidos])


pmdbmapa <- ggmap(brazilmap, extent = "device") + 
 geom_point(
    aes(x = longitude, y = latitude),
    color = 'blue',
    data = baseline[baseline[,"PMDB"] == 1 & baseline[,"PSDB"] == 1,],
    size = 1,
    alpha = 1) +
  geom_point(
    aes(x = longitude, y = latitude),
    color = 'red',
    data = baseline[baseline[,"PMDB"] == 1 & baseline[,"PT"] == 1,],
    size = 1,
    alpha = 1) +
geom_point(
  aes(x = longitude, y = latitude),
  color = 'white',
  data = baseline[baseline[,"PMDB"] == 1 & baseline[,"PSDB"] == 1 & baseline[,"PT"] == 1,],
  size = 1,
  alpha = 1)
  
ggsave(pmdbmapa,   filename = "pmdbmapa.pdf")       

if (1==0) {
  for (legenda1 in lista) {
    for (legenda2 in lista) {
      #    assign(paste(legenda1,legenda2, sep = "") , 
      assign(
        paste("m",legenda1,legenda2, sep = ""),
        ggmap(brazilmap, extent = "device") +
          geom_point(
            aes(x = longitude, y = latitude),
            color = 'red',
            data = baseline[baseline[,legenda1] == 1 & baseline[,legenda2] == 1,],
            size = 1)
      )
      ggsave(
        get(paste("m",legenda1,legenda2, sep = "")),
        filename = paste("m",legenda1,legenda2,".pdf",sep = ""))     
    }
  }  
} 