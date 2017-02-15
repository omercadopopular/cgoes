# Details

Repository for my ongoing project regarding "Past and Future of Inequality in Brazil: Distributional Implications of Macrostructural Policies", which uses a household survey (Pesquisa Nacional por Amostra de Domicílios - PNAD) microdata. 

# Files

## Code

- [PNAD2014.do](https://github.com/omercadopopular/cgoes/edit/master/inequalitybrazil/pnad2014.do) (STATA): Imports household data, adjusts income per capita data for purchasing power differences, creates state-wide and nation-wide percentiles of PPP ajusted family income per capita, uses such percentiles to plot income inequality patterns, and consumption-based inequality.
-- [2014.dct](https://github.com/omercadopopular/cgoes/edit/master/inequalitybrazil/2014.dct) (STATA): Dictionary for importing the HH data properly.

- [PES2014.do](https://github.com/omercadopopular/cgoes/edit/master/inequalitybrazil/pes2014.do) (STATA): Imports individual PNAD data, creates dummies for important characteristics (race, gender, state, etc.), runs mincerian regressions predicting income, calculates wage premium for public sector.
-- [PES2014.dct](https://github.com/omercadopopular/cgoes/edit/master/inequalitybrazil/pes2014.dct) (STATA): Dictionary for importing the individual data properly.

## Sourcefile

- The text files are too large to be uploaded to github, so you need to download the individual and household survey data from [IBGE](http://www.ibge.gov.br/home/estatistica/populacao/trabalhoerendimento/pnad2014/microdados.shtm).
