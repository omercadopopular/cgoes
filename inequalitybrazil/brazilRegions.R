libs <- c("ggplot2", "dismo", "maptools", "raster", "sp", "rgdal","ggmap","maps", "mapproj")
lapply(libs, library, character.only=TRUE)

direc <- "D:\\Inequality\\All figures"
direcmaps <- "D:\\Inequality\\All figures\\RMaps"
setwd(direc)

adm<-readShapeSpatial("RMaps\\BRA_adm_shp2\\BRA_adm1.shp")
norte <- c("BR.AC", "BR.AP", "BR.AM", "BR.PA", "BR.RO", "BR.RR", "BR.TO")
nordeste <- c("BR.AL", "BR.BA", "BR.CE", "BR.MA", "BR.PB", "BR.PE", "BR.PI","BR.RN", "BR.SE")
centrooeste <- c("BR.DF", "BR.GO", "BR.MT", "BR.MS")
sudeste <- c("BR.ES", "BR.MG", "BR.RJ", "BR.SP")
sul <- c("BR.PR", "BR.RS", "BR.SC")


admnorte <- adm[adm$HASC_1%in%norte,]
admnordeste <- adm[adm$HASC_1%in%nordeste,]
admcentrooeste <- adm[adm$HASC_1%in%centrooeste,]
admsudeste <- adm[adm$HASC_1%in%sudeste,]
admsul <- adm[adm$HASC_1%in%sul,]

win.metafile("brazil.wmf", width=8, height=8, res=72)

plot(admnorte, col="lightcoral", ylim=c(-35,5), xlim=c(-70,-30))
plot(admnordeste, col="lightblue", add=TRUE)
plot(admcentrooeste,col="peachpuff2", add=TRUE)
plot(admsudeste,col="slategrey", add=TRUE)
plot(admsul, col="orange", add=TRUE)

legend(-40,-25, c("North", "Northeast", "Midwest", "Southeast", "South"),
            fill=c("lightcoral", "lightblue", "peachpuff2", "slategrey", "orange"),
            cex=1)

adm$NAME_1<-gsub("ô", "o", adm$NAME_1)
adm$NAME_1<-gsub("ã", "a", adm$NAME_1)
adm$NAME_1<-gsub("á", "a", adm$NAME_1)
adm$NAME_1<-gsub("�", "i", adm$NAME_1)
adm$NAME_1<-gsub(intToUtf8(173), "", adm$NAME_1)


adm$uf <- substr(adm$HASC_1,4,5)


text(adm, labels=adm$uf, cex= 0.8, font=2)

dev.off()
