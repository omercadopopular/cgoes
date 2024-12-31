import os
import pandas as pd
import requests

#infile = "c:/Users/Matteo Muendler/Documents/python-projects/Programs/Dad's Python Summer Assignment/UrlLib/output/xls/ds2_Documents_list_20_07_2021.xls"
#infile = "c:/Users/Matteo Muendler/Documents/python-projects/Programs/Dad's Python Summer Assignment/UrlLib/output/xls/ds507_Documents_list_21_07_2021.xls"
#infile = "c:/Users/Matteo Muendler/Documents/python-projects/Programs/Dad's Python Summer Assignment/UrlLib/output/xls/ds508_Documents_list_21_07_2021.xls"
infile = "c:/Users/Matteo Muendler/Documents/python-projects/Programs/Dad's Python Summer Assignment/UrlLib/output/xls/ds603_Documents_list_21_07_2021.xls"

#expected pdf file types at WTO DS web site
#https://docs.wto.org/dol2fe/Pages/SS/directdoc.aspx?filename=Q:/WT/DS/2-10.pdf&Open=True
#https://docs.wto.org/dol2fe/Pages/SS/directdoc.aspx?filename=Q:/WT/DS/2-10A1.pdf&Open=True
#https://docs.wto.org/dol2fe/Pages/SS/directdoc.aspx?filename=Q:/WT/DS/2-2A1C1.pdf&Open=True
#https://docs.wto.org/dol2fe/Pages/SS/directdoc.aspx?filename=Q:/WT/DS/2ABR.pdf&Open=True

dsrecord = infile.replace("c:/Users/Matteo Muendler/Documents/python-projects/Programs/Dad's Python Summer Assignment/UrlLib/output/xls/ds", '')
dsrecord = int(dsrecord[:dsrecord.index("_Documents_list_")])
outpath = "c:/users/Matteo Muendler/Documents/python-projects/Programs/Dad's Python Summer Assignment/UrlLib/output/pdf/ds" + str(dsrecord)
try:
    os.mkdir(outpath)
except:
    print("Note: subddirectory ./ds" + str(dsrecord) + " exists.")

pdflst = pd.read_excel(infile, index_col=None, na_values=[''], usecols = "B:F, H:J")
headers = pdflst.iloc[0]  # make first row header
pdflst = pdflst.drop([0]) # remove first row
pdflst.columns = [headers]
pd.set_option('display.max_columns', None)
pd.set_option('display.max_rows', None)
rownum = len(pdflst)

print(pdflst.iloc[0:,0])
#print(rownum)

urlleft = "https://docs.wto.org/dol2fe/Pages/SS/directdoc.aspx?filename=Q:/WT/DS"
urlright = ".pdf&Open=True"
for i in range(0,rownum):
    entry = pdflst.iloc[i,0]  # extract entry from pdf list
    entry = entry[entry.index("WT/DS")+5:]  # cut off early document references (to subcommittees, not WTO DS)
    entry = entry.replace("WT/DS", "")  # keep file reference
    dsnum = int(entry[:entry.index("/")])  # extract dispute number
    entry = entry.replace(str(dsnum)+"/", "-", 1)  # remove dispute number from entry to process, but only upon first occurence
    entry = entry.replace("/Add.","A")  # treat add documents with "Add." in name
    entry = entry.replace("/Corr.","C")  # treat correction documents with "Corr." in name
    entry = entry.replace("-AB/R","ABR")  # treat AB/R documents with "AB/R" in name
    if dsnum!=dsrecord:
        print("BREAK for error: DS records do not match")
        break
    urlfull = urlleft + "/" + str(dsnum) + entry + urlright
    filename = "ds" + str(dsnum) + entry + '.pdf'
    #print(entry, urlfull)
    dspdf = requests.get(urlfull, stream=True)
    with open(outpath + "/" + filename, 'wb') as f:
        f.write(dspdf.content)
