cd "C:\Users\wb592068\OneDrive - WBG\Brazil"

global comtradepath = "data\comtrade"
global concpath = "data\conc"

global first_y = 1994
global last_y = 2020

do "code/%stata/hs-isic-nat-map/comtradeconc.do"
do "code/%stata/hs-isic-nat-map/conc.do"

