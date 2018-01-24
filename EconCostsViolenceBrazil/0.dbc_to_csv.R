
### Convert DATASUS/SIM .DBC files to CSV for Python Analysis

setwd("H:/Notas Conceituais/SegPub-Drogas/Dados/Datasus/Arq_936829632/")

# install.packages('read.dbc')

library(read.dbc)

n <- c(1:15,79:99)
lista <- 0

counter <- 0
for(i in n) {
  counter <- counter +1
  
  if(i < 10) {
    lista[counter] <- paste("DOEXT0", toString(i), ".DBC", sep="")
  }
  
  else {
    lista[counter] <- paste("DOEXT", toString(i), ".DBC", sep="")
  }
  
}

read.convert <- function(file) {
  print(paste("Processando ", file, sep=""))
  df <- read.dbc(file)
  write.csv(df, paste(substring(file, 1, nchar(file)-4), ".csv", sep=""))
}


for(element in lista) {
  read.convert(element)
}


