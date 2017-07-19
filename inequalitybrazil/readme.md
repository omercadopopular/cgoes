# Details

Code and Sourcefile for Góes, C.; and I. Karpowicz. (2017) "Inequality in Brazil: A Micro-Data Analysis". IMF Working Paper.

Abstract: In this study, we document the decline in income inequality and a convergence in consumption patterns in Brazilian states in a new database constructed from micro micro-data from the national households’ survey. We adjust the state Gini coefficients for spatial price differences using information on households’ rental prices available in the survey. In a panel regression framework, we find that labor income growth, formalization, and schooling contributed to the decline in inequality during 2004−14, but redistributive policies, such as Bolsa Família, have also played a positive role. Going forward, it will be important to phase out untargeted subsidies, such as public spending on tertiary education, and contain growth of public sector wages, to improve budgetary efficiency and protect gains in equality.

# Files

## Code

### Household Questionnaire 

- [PNAD2014.do](https://github.com/omercadopopular/cgoes/edit/master/inequalitybrazil/pnad2014.do) (STATA): Imports household data, adjusts income per capita data for purchasing power differences, creates state-wide and nation-wide percentiles of PPP ajusted family income per capita, uses such percentiles to plot income inequality patterns, and consumption-based inequality.
- [2014.dct](https://github.com/omercadopopular/cgoes/edit/master/inequalitybrazil/2014.dct) (STATA): Dictionary for importing the HH data properly.

### Individual Questionnaire 

- [PES2014.do](https://github.com/omercadopopular/cgoes/edit/master/inequalitybrazil/pes2014.do) (STATA): Imports individual PNAD data, creates dummies for important characteristics (race, gender, state, etc.), runs mincerian regressions predicting income, calculates wage premium for public sector.
- [PES2014.dct](https://github.com/omercadopopular/cgoes/edit/master/inequalitybrazil/pes2014.dct) (STATA): Dictionary for importing the individual data properly.

## Sourcefile

- The text files are too large to be uploaded to github, so you need to download the individual and household survey data from [IBGE](http://www.ibge.gov.br/home/estatistica/populacao/trabalhoerendimento/pnad2014/microdados.shtm).
