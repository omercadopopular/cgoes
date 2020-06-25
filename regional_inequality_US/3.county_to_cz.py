def irs_walker(FOLDER):
        
        import os
        import pandas as pd
        
        # crawl through folder    
        NAMES = []
        for root, dirs, files in os.walk(FOLDER, topdown=False):
            for name in files:
                if name[-9:] == 'final.csv':
                  NAMES.append(name)
                else:
                    continue
    
        return NAMES, root

def cz_consolidation(FILE, CZFILE):
    DS = pd.read_stata(CZFILE)
    DS['county'] = DS.geofips.astype(int)
    DS = DS.drop('geofips', axis=1)

    DF = pd.read_csv(FILE, index_col=0)
    CZDF = DF.merge(DS).groupby(['CZ','bracket_label']).agg({
        'agi': 'sum',
        'returns': 'sum',
        'bracket_min': 'mean',
        'bracket_max': 'mean',
        'year': 'mean',
        'state': 'first'
        })

    return CZDF

#####
        
import os
import pandas as pd

FOLDER = r'C:\Users\Carlos\OneDrive - UC San Diego\IRS\outfiles'
CZFILE = r'C:\Users\Carlos\OneDrive - UC San Diego\IRS\outfiles\Reg_Rec_Dorn_Crosswalk_Modified.dta'

NAMES, ROOT = irs_walker(FOLDER)

CZDF = pd.DataFrame()
for NAME in NAMES:
    print(NAME)
    DF = cz_consolidation(os.path.join(ROOT, NAME), CZFILE)
    CZDF = CZDF.append(DF)

frame = CZDF.reset_index().groupby(['CZ','year']).sum().reset_index()
frame = frame.drop(['bracket_label','bracket_min', 'bracket_max'], axis=1).rename(columns={'agi': 'agi_sum', 'returns': 'returns_sum'})

CZDF = CZDF.merge(frame, how='left', on=['CZ','year'])

CZDF.to_csv(FOLDER + '\cz_1998-2005.csv', sep=',')
