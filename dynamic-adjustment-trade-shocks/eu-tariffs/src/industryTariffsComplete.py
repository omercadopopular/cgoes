"""
Industry Tariffs Calculation Tool

This class provides methods to harmonize data across different classification standards,
calculate sectoral averages for tariffs, and produce visualizations of tariff trends.
"""

import os

os.chdir(r'C:\Users\andre\OneDrive\UCSD\Research\cgoes\dynamic-adjustment-trade-shocks\eu-tariffs')

import pandas as pd
import matplotlib.pyplot as plt

class IndustryTariffs:
    def __init__(self, folder, first_year=1995, last_year=2010):
        self.folder = folder
        self.first_year = first_year
        self.last_year = last_year+1
        self.new_iso_codes = ['CYP', 'CZE', 'EST', 'HUN', 'LVA', 'LTU', 'MLT', 'POL', 'SVK', 'SVN']
        self.concordance_path = os.path.join(self.folder, 'concordance')
        self.mfn_folder = os.path.join(self.folder, 'data\\AVMFN')
        self.pref_folder = os.path.join(self.folder, 'data\\AVPREF')
        self.temp_folder = os.path.join(self.folder, 'data\\wits-out\\temp')
        self.bilateral_folder = os.path.join(self.folder, 'data\\wits-out\\bilateral')
        self.img_folder = os.path.join(self.folder, 'data\\img-out')
        self.comtrade_folder = os.path.join(self.folder, 'data\\comtrade-out')
        
        for folder in [self.temp_folder, self.bilateral_folder, self.img_folder, self.comtrade_folder]:
            if not os.path.exists(folder):
                os.makedirs(folder)        

    def get_country_codes(self):
        storage_options = {'User-Agent': 'Mozilla/5.0'}
        url = r'https://wits.worldbank.org/wits/wits/witshelp/content/codes/country_codes.htm'
        country_codes_table = pd.read_html(url, storage_options=storage_options, header=1)[0]
        new_table = country_codes_table[country_codes_table.ISO3.isin(self.new_iso_codes)]
        return new_table
    
    def folder_walker(self, year, walk_folder='', year_check=True):
        base_path = os.path.join(self.folder, walk_folder)
        out_files = []
        for root, dirs, files in os.walk(base_path, topdown=False):
            for name in files:
                if name[-3:] == 'CSV' or name[-3:] == 'csv':
                    if name.split('.')[0][-4:] == str(year):
                        out_files.append(os.path.join(root, name))
                    elif name.split('_U2')[0][-4:] == str(year):
                        out_files.append(os.path.join(root, name))                       
                    else:
                        continue
                else:
                    continue
        
        return out_files
    
    def mfn_annual(self, year):
        input_list = self.folder_walker(year, walk_folder=self.mfn_folder)
            
        frame = pd.DataFrame()
        for file_path in input_list:
            frame = pd.concat([frame,pd.read_csv(file_path)])            
        frame.to_csv(os.path.join(self.temp_folder, 'wits_mfn_' + str(year) + '.csv'), index=False)
        
        return frame            
            
    def pref_annual(self, year):
        input_list = self.folder_walker(year, walk_folder=self.pref_folder)
            
        frame = pd.DataFrame()
        for file_path in input_list:
            frame = pd.concat([frame,pd.read_csv(file_path)])            
        frame.to_csv(os.path.join(self.temp_folder, 'wits_pref_' + str(year) + '.csv'), index=False)
        
        return frame            

    def set_of_countries(self):
        first_year = self.first_year
        last_year = self.last_year
        
        setc = set()
        for year in range(first_year, last_year):
            print('Set of countries, processing year {}'.format(year))

            # check if annual file exists
            path = os.path.join(self.temp_folder, 'wits_mfn_' + str(year) + '.csv')
            if not os.path.isfile(path):
                frame = self.mfn_annual(year)
            else:
                frame = pd.read_csv(path)
                
            setc = setc.union( set(frame['Reporter_ISO_N']) )
            
        self.setc = setc
            
    def harmonize_hs(self, in_frame, nomen_code='NomenCode', product_code='ProductCode'):
        correlations_hs = pd.read_excel(os.path.join(self.concordance_path, 
                                                     'CompleteCorrelationsOfHS-SITC-BEC_20170606.xlsx'))
        out_frame = pd.DataFrame()
        
        for vintage in set(in_frame[nomen_code]):
            temp_frame = in_frame[in_frame[nomen_code] == vintage]
            if vintage == 'H3':
                temp_frame['ProductCodeH3'] = temp_frame.ProductCode.astype(int)
            else:
                correl_frame = correlations_hs[[vintage, 'H3']].dropna().astype(int)
                correl_frame = correl_frame.rename(columns={vintage: product_code, 'H3': product_code + 'H3'})
                correl_frame = correl_frame.groupby(product_code)[product_code + 'H3'].agg(lambda x: pd.Series.mode(x)[0]).reset_index()
                temp_frame = pd.merge(temp_frame, correl_frame, how='left', on=product_code)
            out_frame = pd.concat((out_frame, temp_frame))
        
        return out_frame

    def bilateral_mfn_panel(self, reporter):
        first_year = self.first_year
        last_year = self.last_year
        
        if not hasattr(self, 'setc'):
            self.set_of_countries()
        
        setc = self.setc
        
        rframe = pd.DataFrame()
        for year in range(first_year, last_year):
            path = os.path.join(self.temp_folder, 'wits_mfn_' + str(year) + '.csv')
            frame = pd.read_csv(path)
            subframe = frame.query("Reporter_ISO_N == " + str(reporter))
            
            yearframe = pd.DataFrame()
            for partner in setc:
                partnerframe = subframe.copy()
                
                if partner == reporter:
                    columns = [ 'Sum_Of_Rates', 'Min_Rate', 'Max_Rate', 'SimpleAverage']
                    for column in columns:
                        partnerframe.loc[partnerframe.index, column] = [0.0 for x in partnerframe[column]]
         
                partnerframe['Partner_ISO_N'] = partner
                yearframe = pd.concat([yearframe, partnerframe])
            
            rframe = pd.concat([rframe, yearframe])
        
        hframe = self.harmonize_hs(rframe)
        hframe.to_csv(os.path.join(self.temp_folder, 'bilateral_mfn_' + str(reporter) + '.csv'), index=False)

        return hframe
            

    def process_bilateral_full_panel(self):
        first_year = self.first_year
        last_year = self.last_year
        
        if not hasattr(self, 'setc'):
            self.set_of_countries()
        
        setc = self.setc
        
        for reporter in setc:
            print('Bilateral Panel, processing {}'.format(reporter))
            
            path = os.path.join(self.temp_folder, 'bilateral_mfn_' + str(reporter) + '.csv')

            if not os.path.isfile(path):
                self.process_bilateral_mfn_panel()
            
            bframe = pd.read_csv(path)
            
            pframe = pd.DataFrame()
            
            for partner in setc:
                
                # Search for which areas have the country as the beneficiary
                bpath = os.path.join(self.concordance_path, r'TRAINSPreferenceBenficiaries.xls')
                beniframe = pd.read_excel(bpath)
                beniframe = beniframe.query("Partner ==" + str(partner))
                beneflist = list(beniframe.RegionCode.unique())
                
                ppframe = pd.DataFrame()
                
                for year in range(first_year, last_year):
                    
                    ypath = os.path.join(self.temp_folder, 'wits_pref_'  + str(year) + '.csv')
                    if not os.path.isfile(ypath):
                        self.pref_annual(year)
                    
                    pframe = pd.read_csv(ypath)
                    subpframe = pframe.query("Reporter_ISO_N !=" + str(reporter))
                    subpframe = subpframe[ subpframe['Partner'].isin(beneflist) ]
                    subpframe['Partner_ISO_N'] = [partner for x in subpframe['Partner']]
                    
                    # harmonize tariffs
                    hsubpframe = self.harmonize_hs(subpframe)
                
                    # stack reporter-partner preferential tariff
                    ppframe = pd.concat([ppframe, hsubpframe])
                
                # stack reporter preferential tariff
                pframe = pd.concat([pframe, ppframe])
                    
            # merge datasets
            mergeconditions = ['NomenCode','Reporter_ISO_N', 'Year', 'Partner_ISO_N', 'ProductCodeH3']
            fullframe = bframe.merge(pframe, how='left', on=mergeconditions, suffixes=['_mfn','_pref'])
            
            # flag preferential tariffs
            fullframe['PrefFlag'] = ~fullframe.SimpleAverage_pref.isna()
            tempframe = fullframe[ fullframe['PrefFlag'] == True ]
                
            # create merged columns
            cols =  ['Sum_Of_Rates', 'Min_Rate', 'Max_Rate', 'SimpleAverage']
            for col in cols:
                fullframe[col] = fullframe[col + '_mfn']
                fullframe.loc[tempframe.index, col] = tempframe.loc[tempframe.index, col + '_pref']
                
            # Create consolidated dataset
            cols.append('PrefFlag')
            consolidatedframe = fullframe[ mergeconditions + cols ]
    
            spath = os.path.join(self.bilateral_folder, 'bilateral_' + str(reporter) + '.csv')
            consolidatedframe.to_csv(spath, index=False)
        
    def load_concordance_isic(self):
        conc_frame = pd.read_csv(os.path.join(self.concordance_path, 'JobID-48_Concordance_H3_to_I3.CSV'), encoding='unicode_escape')
        conc_frame = conc_frame.rename(columns={'HS 2007 Product Code': 'ProductCodeH3', 'ISIC Revision 3 Product Code': 'Isic3'})
        
        # ISIC Rev 3 to Rev 3.1 concordance
        tempframe31 = pd.read_csv(os.path.join(self.concordance_path, 'ISIC_Rev_31-ISIC_Rev_3_correspondence.txt'), encoding='unicode_escape')
        tempframe31 = tempframe31.rename(columns={'Rev31': 'Isic31', 'Rev3': 'Isic3'}).groupby('Isic3')['Isic31'].agg(lambda x: pd.Series.mode(x)[0]).reset_index()
        conc_frame = pd.merge(conc_frame, tempframe31[['Isic31', 'Isic3']], how='left', on='Isic3')
        
        # ISIC Rev 3.1 to Rev 4 concordance
        tempframe4 = pd.read_csv(os.path.join(self.concordance_path, 'ISIC31_ISIC4.txt'), encoding='unicode_escape')
        tempframe4 = tempframe4.rename(columns={'ISIC31code': 'Isic31', 'ISIC4code': 'Isic4'}).groupby('Isic31')['Isic4'].agg(lambda x: pd.Series.mode(x)[0]).reset_index()
        conc_frame = pd.merge(conc_frame, tempframe4[['Isic31', 'Isic4']], how='left', on='Isic31')
        
        return conc_frame.dropna()[['ProductCodeH3', 'Isic4']]

    def retrieve_icio_sector(self):
        path = os.path.join(self.concordance_path, 'sectorlist.dta')
        icio_frame = pd.read_stata(path).set_index('code')
        icio_frame = icio_frame[icio_frame['isic4'] != '']
        icio_frame['isic4List'] = icio_frame['isic4'].apply(lambda x: x.split(","))
        
        code_dict = pd.io.stata.StataReader(path).value_labels()['code']
        retrieve_code = lambda value: list(code_dict.keys())[list(code_dict.values()).index(value)]
        
        out_dict = {}
        for code in icio_frame.index:
            num_code = retrieve_code(code)
            iter_list = icio_frame.loc[code, 'isic4List']
            if 'to' in iter_list[0]:
                start, end = int(iter_list[0][:2]), int(iter_list[0][-2:])
                iter_list = [str(x) for x in range(start, end)]
            
            for item in iter_list:
                out_dict[item.replace(' ', '')] = num_code
        return out_dict
    
    def weights(self, iso_code, year):
        input_path = os.path.join(self.comtrade_folder, f"consolidated_{iso_code}_{year}.csv")
        input_frame = pd.read_csv(input_path)
        
        total_sum = input_frame.sum(axis=0)['Trade Value (US$)']
        
        input_frame['weight'] = input_frame['Trade Value (US$)'] / total_sum
        
        input_frame = input_frame.rename(columns={'Classification': 'NomenCode', 'Commodity Code': 'ProductCode'})
               
        weights = input_frame[['NomenCode', 'ProductCode', 'weight']]
        
        weights.loc[:,'ProductCode'] = pd.to_numeric(weights['ProductCode'], errors='coerce')
        
        out_frame = self.harmonize_hs(weights)
        
        return out_frame[['ProductCodeH3', 'weight']]
    
    def norm_weights(self, in_frame, group='icio'):
        
        sum_isic = in_frame.groupby(['Reporter_ISO_N', 'Year', 'Partner', group]).agg(group_weight = ('weight', 'sum')).reset_index()
            
        new_frame = pd.merge(in_frame, sum_isic, how='left', on=['Reporter_ISO_N', 'Year', 'Partner', group] )

        new_frame['adj_weight'] = new_frame['weight'] / new_frame['group_weight']
                
        return new_frame.sort_values(['Reporter_ISO_N', 'Year', 'Partner', group, 'ProductCode'])

    
    def process_tariff_data(self):
        new_table = self.get_country_codes()
        conc_isic = self.load_concordance_isic()
        isic_dict = self.retrieve_icio_sector()
        long_frame = pd.DataFrame()
        
        for c_code in new_table.Code.unique():
            iso_code = new_table[new_table.Code == c_code]['ISO3'].iloc[0]
            country_name = new_table[new_table.Code == c_code]['Country Name'].iloc[0]
            print(f'Processing {country_name}...')
            
            # import frame, harmonize HS codes
            in_frame = pd.read_csv(os.path.join(self.bilateral_folder, f'wits_bilateral_eu_{c_code}.csv'))
            harm_frame = tariffs.harmonize_hs(in_frame)

            # import weights
            w = tariffs.weights(iso_code, tariffs.first_year)
            harm_frame = pd.merge(w, harm_frame, how='left', on='ProductCodeH3')
            
            # merge with concordance 
            out_frame = pd.merge(harm_frame, conc_isic, how='left', on='ProductCodeH3')
            
            # make icio groups
            out_frame['PartnerIsoCode'] = iso_code
            out_frame['Isic4'] = out_frame['Isic4'].dropna().astype(int).astype(str).str.zfill(4)
            out_frame['Isic4_2d'] = out_frame['Isic4'].str[:2]
            out_frame['icio'] = out_frame['Isic4_2d'].apply(lambda x: isic_dict.get(x, ''))
            
            # normalize weights, multiply tariffs
            out_frame = self.norm_weights(out_frame)            
            out_frame['Tariff'] = out_frame['SimpleAverage'] * out_frame['adj_weight']
                       
            icio_frame = out_frame.groupby(['Reporter_ISO_N', 'Year', 'Partner', 'PartnerIsoCode', 'icio']).agg({
                'Tariff': 'sum',
            }).reset_index()
            
            icio_frame.to_csv(os.path.join(self.bilateral_folder, f'icio_wits_bilateral_eu_{c_code}.csv'), index=False)
            long_frame = pd.concat([long_frame, icio_frame])
        
        long_frame.to_csv(os.path.join(self.bilateral_folder, 'icio_wits_bilateral_eu_all.csv'), index=False)
        return long_frame

    def plot_tariffs(self, long_frame):
        sector_frame = long_frame.groupby(['Reporter_ISO_N', 'Year', 'icio']).agg({'Tariff': 'mean'}).reset_index()
        fig, ax = plt.subplots(figsize=(12, 6))
        
        for s_code in set(sector_frame['icio']):
            ax.plot('Year', 'Tariff', data=sector_frame[sector_frame['icio'] == s_code])
        
        ax.set_title('Bilateral tariffs, EU (Reporter) and 2004-NMS (Partner): Sectoral Averages')
        plt.show()
        
        os.makedirs(self.img_folder, exist_ok=True)
        
        fig_path = os.path.join(self.img_folder, 'nms_eu_tariff_dist_avg_sec.pdf')
        fig.savefig(fig_path)



# Usage
folder = r'C:\Users\andre\OneDrive\UCSD\Research\cgoes\dynamic-adjustment-trade-shocks\eu-tariffs'
tariffs = IndustryTariffs(folder)

long_frame = tariffs.process_tariff_data()
tariffs.plot_tariffs(long_frame)
