"""
Convert raw TTBD data into Stata files

Master files and product files for different countries are combined together
All relevant information is maintained at this stage
"""

#%%
import pandas as pd
from pathlib import Path

gadraw = Path(r'../../../data/TTBD/download/240525/TTBD-2020/GAD (2020)')
work = Path(r'../../../data/work/TTBD')
gcvdraw = gadraw/'CVD (2020)'
gadexcluded = ['OTH','TWN']
gcvdexcluded = ['OTH']
# GAD-USA.xlsx is the only file with a .xlsx extension
gads = [p for p in gadraw.glob('GAD-*.*') if p.name[4:7] not in gadexcluded]
gcvds = [p for p in gcvdraw.glob('GCVD-*.*') if p.name[5:8] not in gcvdexcluded]

iso3fix = {'NWY':'NOR','POR':'PRT','QTR':'QAT','TRK':'TUR'}

#%%
def todate(x):
    return pd.to_datetime(x, errors='coerce')

#%%
def gadfile(gad, mastercols):
    dest = gad.name[4:7]
    masterdatecols = [v for v in mastercols if v[-4:] == 'DATE']
    prodcols = ['CASE_ID','HS_CODE']
    master = pd.read_excel(gad, sheet_name='AD-'+dest+'-Master',
        converters= {v: todate for v in masterdatecols},
        dtype={v:str for v in mastercols if v not in masterdatecols})
    # For some files, P_AD_DUTY and F_AD_DUTY do not exist
    cols = [v for v in master.columns if v in mastercols]
    master = master[cols]
    master.insert(0, 'AD_CTY_CODE', dest)
    master['INV_CTY_CODE'] = master['INV_CTY_CODE'].replace(iso3fix)
    prod = pd.read_excel(gad, sheet_name='AD-'+dest+'-Products', usecols=prodcols,
        dtype=str)
    return master, prod

#%%
def gcvdfile(gcvd, mastercols):
    dest = gcvd.name[5:8]
    masterdatecols = [v for v in mastercols if v[-4:] == 'DATE']
    prodcols = ['CASE_ID','HS_CODE']
    master = pd.read_excel(gcvd, sheet_name='CVD-'+dest+'-Master',
        converters= {v: todate for v in masterdatecols},
        dtype={v:str for v in mastercols if v not in masterdatecols})
    cols = [v for v in master.columns if v in mastercols]
    master = master[cols]
    master.insert(0, 'CVD_CTY_CODE', dest)
    master['INV_CTY_CODE'] = master['INV_CTY_CODE'].replace(iso3fix)
    prod = pd.read_excel(gcvd, sheet_name='CVD-'+dest+'-Products', usecols=prodcols,
        dtype=str)
    return master, prod

#%%
gadmastercols = ['AD_CTY_NAME','CASE_ID','CASE_REPCODE','INV_CTY_NAME','INV_CTY_CODE',
    'PRODUCT', 'INIT_DATE','P_DUMP_DATE','P_INJ_DATE','P_DUMP_DEC','P_INJ_DEC',
    'P_AD_DATE', 'P_AD_MEASURE','F_DUMP_DATE','F_INJ_DATE','F_DUMP_DEC',
    'F_INJ_DEC','F_AD_DATE','F_AD_MEASURE','REVOKE_DATE','REVOKE_YEAR',
    'P_AD_DUTY','F_AD_DUTY','WTO_F_AD_MEASURE','WTO_F_MARGIN_MIN','WTO_F_MARGIN_MAX']
# In GAD-RUS.xls, three date columns have days come before months:
# P_DUMP_DATE, P_INJ_DATE, P_AD_DATE
gadmasters = []
gadprods = []
for gad in gads:
    print("Processing", gad.name)
    master, prod = gadfile(gad, gadmastercols)
    gadmasters.append(master)
    gadprods.append(prod)

gadmaster = pd.concat(gadmasters, ignore_index=True)
gadprod = pd.concat(gadprods, ignore_index=True)
gadmaster = gadmaster.map(lambda x: x.strip() if isinstance(x, str) else x)
gadprod = gadprod.map(lambda x: x.strip() if isinstance(x, str) else x)

for col in ['AD_CTY_NAME','INV_CTY_NAME']:
    gadmaster[col] = gadmaster[col].astype('category')

#%%
gcvdmastercols = ['CVD_CTY_NAME','CASE_ID','CASE_REPCODE','INV_CTY_NAME','INV_CTY_CODE',
    'PRODUCT', 'INIT_DATE','P_SUB_DATE','P_INJ_DATE','P_SUB_DEC','P_INJ_DEC',
    'P_CVD_DATE', 'P_CVD_MEASURE','F_SUB_DATE','F_INJ_DATE','F_SUB_DEC',
    'F_INJ_DEC','F_CVD_DATE','F_CVD_MEASURE','REVOKE_DATE','REVOKE_YEAR',
    'P_CVD_DUTY','F_CVD_DUTY','WTO_F_CVD_MEASURE','WTO_F_MARGIN_MIN','WTO_F_MARGIN_MAX']
gcvdmasters = []
gcvdprods = []
for gcvd in gcvds:
    print("Processing", gcvd.name)
    master, prod = gcvdfile(gcvd, gcvdmastercols)
    gcvdmasters.append(master)
    gcvdprods.append(prod)

gcvdmaster = pd.concat(gcvdmasters, ignore_index=True)
gcvdprod = pd.concat(gcvdprods, ignore_index=True)
gcvdmaster = gcvdmaster.map(lambda x: x.strip() if isinstance(x, str) else x)
gcvdprod = gcvdprod.map(lambda x: x.strip() if isinstance(x, str) else x)

for col in ['CVD_CTY_NAME','INV_CTY_NAME']:
    gcvdmaster[col] = gcvdmaster[col].astype('category')

#%%
gadmaster.to_stata(work/'gadmaster.dta', write_index=False, version=118,
    convert_dates={v:'td' for v in gadmastercols if v[-4:] == 'DATE'})
gadprod.to_stata(work/'gadproducts.dta', write_index=False, version=118)
gcvdmaster.to_stata(work/'gcvdmaster.dta', write_index=False, version=118,
    convert_dates={v:'td' for v in gcvdmastercols if v[-4:] == 'DATE'})
gcvdprod.to_stata(work/'gcvdproducts.dta', write_index=False, version=118)

#%%
