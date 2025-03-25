"""
Process the raw data in preparation for estimation

Key variables are constructed
Master and product files are combined
Certain sample restrictions are imposed
"""

#%%
import pandas as pd
import numpy as np
from pathlib import Path

work = Path(r'../../../data/work/TTBD')
admfull = pd.read_stata(work/'gadmaster.dta')
adpfull = pd.read_stata(work/'gadproducts.dta')
cvdmfull = pd.read_stata(work/'gcvdmaster.dta')
cvdpfull = pd.read_stata(work/'gcvdproducts.dta')

#%%
adm = admfull[(admfull['INIT_DATE']>='19900101')&
    (~admfull['INV_CTY_CODE'].isin(['TWN','FRO']))].copy()
# adm.loc[(adm['F_DUMP_DEC']=='A')&(adm['F_INJ_DEC']!='A'),'F_AD_DUTY'] is mostly empty

ndec = set(['N','W','T','.'])
adm['affirmative'] = -1
adm.loc[(adm['F_DUMP_DEC']=='A')&(adm['F_INJ_DEC']=='A')&(adm['F_AD_MEASURE']=='AVD'),
    'affirmative'] = 1
adm.loc[(adm['F_DUMP_DEC'].isin(ndec))|(adm['F_INJ_DEC'].isin(ndec)),'affirmative'] = 0

#%%
def parseduty(x):
    # Is a single number
    if x.replace('.','',1).isnumeric():
        return float(x)
    # Contains a range and use the median
    elif '-' in x:
        vs = x.split('-')
        if vs[0].replace('.','',1).isnumeric():
            l = float(vs[0])
        else:
            return np.NaN
        if vs[1].replace('.','',1).isnumeric():
            u = float(vs[1])
        elif ' ' in vs[1]:
            v2 = vs[1].split(' ')
            if v2[0].replace('.','',1).isnumeric():
                u = float(v2[0])
            else:
                return np.NaN
        else:
            return np.NaN
        return float((l+u)/2)
    # May end with extra info in parenthesis separated by space
    elif ' (' in x and x[-1]==')':
        vs = x.split(' ')
        if len(vs) > 2:
            return np.NaN
        if vs[0].replace('.','',1).isnumeric():
            return float(vs[0])
        else:
            return np.NaN
    else:
        return np.NaN

def parsewtomargin(l, u):
    if l.replace('.','',1).isnumeric() and u.replace('.','',1).isnumeric():
        return (float(l)+float(u))/2
    else:
        return np.NaN

#%%
adm['duty'] = adm['F_AD_DUTY'].map(parseduty)
adm['dutyconstructed'] = (adm['duty'] != adm['F_AD_DUTY']) & (~adm['duty'].isna()) & (adm['affirmative'] == 1)
adm['wto_f_margin'] = [parsewtomargin(l, u) for l, u in zip(adm['WTO_F_MARGIN_MIN'], adm['WTO_F_MARGIN_MAX'])]
adm['iwto'] = iwto = (adm['duty'].isna()) & (~adm['wto_f_margin'].isna()) & (adm['affirmative'] == 1)
adm.loc[iwto,'duty'] = adm.loc[iwto,'wto_f_margin']

#%%
cases = set(adm['CASE_ID'])
adp = adpfull[adpfull['CASE_ID'].isin(cases)].copy()
adp['hs'] = np.where(adp['HS_CODE'].str.isdigit(), adp['HS_CODE'].str[:6], '')
adp = adp[['CASE_ID','hs']].drop_duplicates()
adp = adp[adp['hs']!='']

#%%
ad = adm.merge(adp, on='CASE_ID', how='left')
ad['withdata'] = (ad['affirmative'] == 0 | ((ad['affirmative']==1) & (~ad['duty'].isna()))) & (~ad['hs'].isna())

# Determine first AD event among those with affirmative results
ad1 = ad[(ad['F_DUMP_DEC']=='A')&(ad['F_INJ_DEC']=='A')]
ad1 = ad1.groupby(['AD_CTY_CODE','INV_CTY_CODE','hs']).agg(init_date1=('INIT_DATE','min')).reset_index()
ad = ad.merge(ad1, on=['AD_CTY_CODE','INV_CTY_CODE','hs'], how='left')

#%%
ddate = {v:'td' for v in ad.columns if v[-4:] == 'DATE'}
ddate['init_date1'] = 'td'
ad.to_stata(work/'ad.dta', write_index=False, version=118, convert_dates=ddate)

#%%
cvdm = cvdmfull[(cvdmfull['INIT_DATE']>='19900101')&
    (~cvdmfull['INV_CTY_CODE'].isin(['TWN','FRO']))].copy()

ndec = set(['N','W','T','.'])
cvdm['affirmative'] = -1
cvdm.loc[(cvdm['F_SUB_DEC']=='A')&(cvdm['F_INJ_DEC']=='A')&(cvdm['F_CVD_MEASURE']=='AVD'),
    'affirmative'] = 1
cvdm.loc[(cvdm['F_SUB_DEC'].isin(ndec))|(cvdm['F_INJ_DEC'].isin(ndec)),'affirmative'] = 0

#%%
cvdm['duty'] = cvdm['F_CVD_DUTY'].map(parseduty)
cvdm['dutyconstructed'] = (cvdm['duty'] != cvdm['F_CVD_DUTY']) & (~cvdm['duty'].isna()) & (cvdm['affirmative'] == 1)
cvdm['wto_f_margin'] = [parsewtomargin(l, u) for l, u in zip(cvdm['WTO_F_MARGIN_MIN'], cvdm['WTO_F_MARGIN_MAX'])]
cvdm['iwto'] = iwto = (cvdm['duty'].isna()) & (~cvdm['wto_f_margin'].isna()) & (cvdm['affirmative'] == 1)
cvdm.loc[iwto,'duty'] = cvdm.loc[iwto,'wto_f_margin']

#%%
cases = set(cvdm['CASE_ID'])
cvdp = cvdpfull[cvdpfull['CASE_ID'].isin(cases)].copy()
cvdp['hs'] = np.where(cvdp['HS_CODE'].str.isdigit(), cvdp['HS_CODE'].str[:6], '')
cvdp = cvdp[['CASE_ID','hs']].drop_duplicates()
cvdp = cvdp[cvdp['hs']!='']

#%%
cvd = cvdm.merge(cvdp, on='CASE_ID', how='left')
cvd['withdata'] = (cvd['affirmative'] == 0 | ((cvd['affirmative']==1) & (~cvd['duty'].isna()))) & (~cvd['hs'].isna())

# Determine first AD event among those with affirmative results
cvd1 = cvd[(cvd['F_SUB_DEC']=='A')&(cvd['F_INJ_DEC']=='A')]
cvd1 = cvd1.groupby(['CVD_CTY_CODE','INV_CTY_CODE','hs']).agg(init_date1=('INIT_DATE','min')).reset_index()
cvd = cvd.merge(cvd1, on=['CVD_CTY_CODE','INV_CTY_CODE','hs'], how='left')

#%%
ddate = {v:'td' for v in cvd.columns if v[-4:] == 'DATE'}
ddate['init_date1'] = 'td'
cvd.to_stata(work/'cvd.dta', write_index=False, version=118, convert_dates=ddate)

#%%
# Combine AD and CVD data and only keep the valid ones for estimation
ad1 = ad.loc[(ad['withdata'])&((ad['init_date1']>'20000101')|(ad['init_date1'].isna())),
    ['AD_CTY_CODE','INV_CTY_CODE','hs','CASE_ID','INIT_DATE',
    'P_DUMP_DATE','P_INJ_DATE','P_AD_DATE','F_DUMP_DATE','F_INJ_DATE','F_AD_DATE',
    'affirmative','duty','dutyconstructed','wto_f_margin','iwto','init_date1','REVOKE_YEAR']]
ad1.rename(columns={'AD_CTY_CODE':'dest','INV_CTY_CODE':'sorc',
    'P_DUMP_DATE':'p_dumpsub_date','P_AD_DATE':'p_adcvd_date','P_INJ_DATE':'p_inj_date',
    'F_DUMP_DATE':'f_dumpsub_date','F_AD_DATE':'f_adcvd_date','F_INJ_DATE':'f_inj_date'},
    inplace=True)
ad1['isad'] = True
cvd1 = cvd.loc[(cvd['withdata'])&((cvd['init_date1']>'20000101')|(cvd['init_date1'].isna())),
    ['CVD_CTY_CODE','INV_CTY_CODE','hs','CASE_ID','INIT_DATE',
    'P_SUB_DATE','P_INJ_DATE','P_CVD_DATE','F_SUB_DATE','F_INJ_DATE','F_CVD_DATE',
    'affirmative','duty','dutyconstructed','wto_f_margin','iwto','init_date1','REVOKE_YEAR']]
cvd1.rename(columns={'CVD_CTY_CODE':'dest','INV_CTY_CODE':'sorc',
    'P_SUB_DATE':'p_dumpsub_date','P_CVD_DATE':'p_adcvd_date','P_INJ_DATE':'p_inj_date',
    'F_SUB_DATE':'f_dumpsub_date','F_CVD_DATE':'f_adcvd_date','F_INJ_DATE':'f_inj_date'},
    inplace=True)
cvd1['isad'] = False

df = pd.concat([ad1, cvd1], ignore_index=True)

#%%
for v in ['INIT_DATE', 'p_dumpsub_date', 'p_inj_date', 'p_adcvd_date',
          'f_dumpsub_date', 'f_inj_date', 'f_adcvd_date']:
    tag = v[:-4]
    df[tag.lower()+'quarter'] = df[v].dt.to_period('Q').dt.to_timestamp()
    # df[tag.lower()+'year'] = df[v].dt.year
df['cohort_year'] = df['INIT_DATE'].dt.year
# Adjust the cohort if INIT_DATE is toward the end of the year
df.loc[df['INIT_DATE'].dt.quarter==4,'cohort_year'] += 1
df['cohort_year1'] = df['init_date1'].dt.year
# Adjust the cohort if INIT_DATE is toward the end of the year
df.loc[df['init_date1'].dt.quarter==4,'cohort_year1'] += 1

dates = [col for col in df.columns if col[-4:].lower()=='date']
df.drop(columns=dates, inplace=True)
df = df[(df['cohort_year']>=2000)&(df['cohort_year']<=2015)]

#%%
# Replace EUN by individual countries for matching trade data
# These individual EU countries may have appeared as sorc already
# This expansion roughly doubles the total rows in df
eu15 = ["AUT","BEL","DNK","FIN","FRA","DEU","GRC","IRL","ITA","LUX","NLD","PRT","ESP","SWE","GBR"]
df['eundest'] = df['dest'] == 'EUN'
df['eunsorc'] = df['sorc'] == 'EUN'
dfeu= pd.DataFrame({'eun':eu15})
dfeu['reg'] = 'EUN'

df = df.merge(dfeu, how='outer', left_on='sorc', right_on='reg')
df.loc[df['eunsorc'],'sorc'] = df.loc[df['eunsorc'],'eun']
df.drop(columns=['eun','reg'], inplace=True)
df = df.merge(dfeu, how='outer', left_on='dest', right_on='reg')
df.loc[df['eundest'],'dest'] = df.loc[df['eundest'],'eun']
df.drop(columns=['eun','reg'], inplace=True)

#%%
# Count the number of affirmative cases for the same flow in a year
ncases = df[df['affirmative']==1].groupby(['dest','sorc','hs','cohort_year']).agg(ncase=('CASE_ID','nunique')).reset_index()
df = df.merge(ncases, on=['dest','sorc','hs','cohort_year'], how='left')
df.loc[df['ncase'].isna(), 'ncase'] = 0
# Count the number of affirmative cohort_year in sample
nrepeat = df[df['affirmative']==1].groupby(['dest','sorc','hs']).agg(nrepeat=('cohort_year','nunique')).reset_index()
df = df.merge(nrepeat, on=['dest','sorc','hs'], how='left')
df.loc[df['nrepeat'].isna(), 'nrepeat'] = 0

#%%
for col in ['cohort_year', 'ncase', 'nrepeat']:
    df[col] = df[col].astype('i2')
df.sort_values(['dest','sorc','hs','CASE_ID'], inplace=True)
ddate = {v:'td' for v in df.columns if v[-7:] == 'quarter'}
ddate['init_date1'] = 'td'
df.to_stata(work/'adcvdbase.dta', write_index=False, version=118, convert_dates=ddate)

#%%
