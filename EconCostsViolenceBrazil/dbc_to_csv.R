
### Convert DATASUS/SIM .DBC files to CSV for Python Analysis

setwd("H:/Notas Conceituais/SegPub-Drogas/Dados/Datasus/Arq_936829632/")

# install.packages('read.dbc')

library(read.dbc)

lista <- 0

for(i in 1:15) {
  if(i < 10) {
    lista[i] <- paste("DOEXT0", toString(i), ".DBC", sep="")
  }
  else {
    lista[i] <- paste("DOEXT", toString(i), ".DBC", sep="")
  }
}

read.convert <- function(file) {
  df <- read.dbc(file)
  write.csv(df, paste(substring(file, 1, nchar(file)-4), ".csv", sep=""))
}


for(element in lista) {
  read.convert(element)
}