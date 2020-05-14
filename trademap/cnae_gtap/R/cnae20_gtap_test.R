## codigos cnae pra testar
sbcl_cnae_teste <- c("0111302", "0111399", "0139399", "0151201")
stopifnot(all.equal(cnae20_gtap(sbcl_cnae_teste), c(3,3, 8, 9 )))

## todos os cnaes

cnae_no_gtap <- attr(cnae20_gtap, 'srcref')%>%as.character%>%grep("'[0-9]+'", ., value=TRUE)%>%stringr::str_extract_all("'[0-9]+'")%>%unlist%>%gsub("'", "", .)%>%sort

fname <- '~/reps/reps_sae/cnae_gtap/data/CNAE20_Subclasses_EstruturaDetalhada.xls'
#download.file("http://concla.ibge.gov.br/images/concla/downloads/revisao2007/PropCNAE20/CNAE20_Subclasses_EstruturaDetalhada.xls", fname)

cnae20subclasses <- (readxl::read_excel(fname, skip = 4)$Subclasse)%>%
  unique%>%
  na.omit%>%
  gsub("[^0-9]", "", .)
cnae20subclasses <- cnae20subclasses[cnae20subclasses!=""]
stopifnot(all(nchar(cnae20subclasses)==7))

## verificar se todos os CNAES do GTAP estão na CNAE 2.0
stopifnot((sapply(cnae_no_gtap, function(x) !any(grepl(paste0("^", x), cnae20subclasses)))%>%sum)==0)







