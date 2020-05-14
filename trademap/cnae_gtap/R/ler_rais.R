library(dplyr)
source("~/reps/reps_sae/cnae_gtap/R/cnae20_gtap.R")
#####
clean <- function(x, more=FALSE, encoding=NULL, leave='') {
  ## x <- enc2utf8(x)
  x <- gsub(' +', ' ', x)
  if(is.null(encoding)) {
    enc <- rvest::guess_encoding(x)[,1]
    enc <- enc[!grepl('IBM424', enc)]
    enc <- enc[1]
  } else enc <- encoding
  y <- iconv(x, from=enc)
  ##print(y)
  y <- iconv(x, from=enc, to='ASCII//TRANSLIT')
  if (more) {
    y <- gsub(paste0("[^a-zA-Z0-9", leave, "]+"), "_", y)
    y <- gsub('_$', '', y)
  }
  return(y)
}

library(dplyr)




read_rais <- function(fnames, nmax=100) {
  require(dplyr)
  rais_names <- c("bairros_sp", "bairros_fortaleza", "bairros_rj", "causa_afastamento_1", "causa_afastamento_2", "causa_afastamento_3", "motivo_desligamento",  "cbo_ocupacao_2002", "cnae_2_0_classe", "cnae_95_classe", "distritos_sp",  "vinculo_ativo_31_12", "faixa_etaria", "faixa_hora_contrat",  "faixa_remun_dezem_sm", "faixa_remun_media_sm", "faixa_tempo_emprego", "escolaridade_apos_2005", "qtd_hora_contr", "idade", "ind_cei_vinculado",  "ind_simples", "mes_admissao", "mes_desligamento", "mun_trab", "municipio", "nacionalidade", "natureza_juridica", "ind_portador_defic",  "qtd_dias_afastamento", "raca_cor", "regioes_adm_df", "vl_remun_dezembro_nom", "vl_remun_dezembro_sm", "vl_remun_media_nom", "vl_remun_media_sm", "cnae_2_0_subclasse", "sexo_trabalhador", "tamanho_estabelecimento", "tempo_emprego", "tipo_admissao", "tipo_estab", "tipo_estab_1", "tipo_defic", "tipo_vinculo", "ibge_subsetor", "vl_rem_janeiro_cc", "vl_rem_fevereiro_cc", "vl_rem_marco_cc", "vl_rem_abril_cc", "vl_rem_maio_cc", "vl_rem_junho_cc", "vl_rem_julho_cc", "vl_rem_agosto_cc","vl_rem_setembro_cc", "vl_rem_outubro_cc", "vl_rem_novembro_cc")  
  rais_types <- "cccnnnnnnncnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnncnnnnnnnnnnnnnn"
  lapply(fnames, function(x) 
    readr::read_csv2(x, n_max=nmax, locale=readr::locale('pt', encoding='latin1', decimal_mark = ","), col_names = rais_names, col_types=rais_types, skip=1, na="{ñ c"
    ))%>%bind_rows
}

rais <- read_rais(dir("~/reps/reps_sae/cnae_gtap/data/RAIS/2015/", pattern='txt$', full.names = TRUE))

rais <- rais%>%mutate(gtap=cnae20_gtap(cnae_2_0_subclasse))

rais_mun_trab <- rais%>%count(mun_trab, gtap)


library(RSQLite)
con <- dbConnect(RSQLite::SQLite(), dbname = "sample_db")

# read csv file into sql database
dbWriteTable(con, name="sample_data", value="~/reps/reps_sae/cnae_gtap/data/RAIS/2015/SP2015.txt", row.names=FALSE, header=FALSE, skip=1, sep = ";")



stop()
# testa
stopifnot(all.equal(cnae20_gtap(sbcl_cnae_teste), c(46, 47, 46, 30, 47, 54, 54, 9, 47, 25, 46, 47, 54, 47, 46,
                                                    46, 54, 30, 34, 47, 34, 25, 47, 56, 47, 47, 47, 46, 22, 54, 54,
                                                    10, 34, 29, 19, 54, 32, 34, 47, 51, 37, 34, 11, 8, NA, 10, NA,
                                                    33, NA, 18, 47, 49, 54, 13, 9, 3, 3, 46, 47, 56, 46, 56, NA,
                                                    46, 47, 14, 57)
)






