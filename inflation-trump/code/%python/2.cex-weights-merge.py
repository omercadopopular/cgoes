import pandas as pd
import numpy as np
import os
from pathlib import Path

class CEXAnalysis:
    def __init__(self, year, data_path):
        """
        Initialize CEX Analysis with year and data path
        
        Parameters:
        year (int): The year to analyze
        data_path (str): Path to the CEX data files
        """
        self.year = year
        self.data_path = data_path
        self.yr1 = str(year)[2:4]
        self.yr2 = str(year + 1)[2:4]
        
    def read_stub_file(self, stub_file_path):
        """Read and process the stub parameter file"""
        # Read stub file
        columns = ['type', 'level', 'title', 'ucc', 'survey', 'group']
        positions = [(0,1), (3,4), (6,66), (69,75), (82,83), (88,95)]
        
        stub_data = pd.read_fwf(
            stub_file_path,
            colspecs=positions,
            names=columns,
            converters={col: str.strip for col in columns}
        )
        
        # Filter and process
        stub_data = stub_data[
            (stub_data['type'] == '1') & 
            (stub_data['group'].isin(['CUCHARS', 'FOOD', 'EXPEND', 'INCOME']))
        ].copy()
        
        # Create line numbers
        stub_data['count'] = range(9999, 9999 + len(stub_data))
        stub_data['line'] = stub_data['count'].astype(str) + stub_data['level']
        stub_data.columns = [x.upper() for x in stub_data.columns]

        return stub_data
    
    def create_aggregation_format(self, stub_data):
        """Create aggregation format mapping"""
        # Initialize with basic structure
        agg_data = stub_data[['ucc', 'line']].copy()
        
        # Create hierarchical mapping
        agg_format = {}
        for _, row in agg_data.iterrows():
            if row['ucc'] > 'A':
                level = int(row['line'][5:6])
                if row['ucc'] not in agg_format:
                    agg_format[row['ucc']] = []
                agg_format[row['ucc']].append(row['line'])
        
        return agg_format
    
    def read_family_data(self):
        """Read and process family (FMLY) files"""
        fmly_files = [
            f'FMLI{self.yr1}1X',
            f'FMLI{self.yr1}2',
            f'FMLI{self.yr1}3',
            f'FMLI{self.yr1}4',
            f'FMLI{self.yr2}1'
        ]
        
        dfs = []
        for file in fmly_files:
            df = pd.read_csv(f'{self.data_path}\\data\\cex\\intrvw{self.yr1}\\' + file + '.csv')
            
            # for this part, check https://www.bls.gov/cex/pumd-getting-started-guide.htm#section6.3
            if file == f'FMLI{self.yr2}1':
                df.loc[df['QINTRVMO'] == 1, 'MO_SCOPE'] = 3
                df.loc[df['QINTRVMO'] == 2, 'MO_SCOPE'] = 2
                df.loc[df['QINTRVMO'] == 3, 'MO_SCOPE'] = 1
                                    
            else:
                df.loc[df['QINTRVMO'] <= 3, 'MO_SCOPE'] = df['QINTRVMO'] - 1
                df.loc[df['QINTRVMO'] > 3, 'MO_SCOPE'] = 3
                
            dfs.append(df)
        
        fmly_data = pd.concat(dfs, axis=0)
        
        income_bins = [
            0, 40000, 50000, 70000, 100000,  150000, 200000, 400000, float("inf")
        ]

        """            
        income_bins = [
            0, 15000, 30000, 40000, 50000, 70000, 100000, 150000, 200000, 400000, float("inf")
        ]


#        income_bins = [
#           0, 50000, 100000, 200000, float("inf")
#        ]
        
       # income_labels = [
        #    "<15,000", "15,000-29,999", "30,000-39,999", "40,000-49,999",
        #    "50,000-69,999", "70,000-99,999", "100,000-149,999", "150,000-199,999", "200,000+"
        #]
        """

        inc_format = [f'{str(i).zfill(2)}' for i in range(1,len(income_bins))]
        
        fmly_data["INCLASS"] = pd.cut(
            fmly_data["FINCBTXM"], bins=income_bins, labels=inc_format, right=False
        )
        
        fmly_data = fmly_data.copy()
        # Adjust weights

        weight_cols = ['WTREP' + str(i).zfill(2) for i in range(1,45)] + ['FINLWT21']
        rep_cols = ['REPWT' + str(i).zfill(2) for i in range(1,46)]
        
        for old_col, new_col in zip(weight_cols, rep_cols):
            fmly_data[new_col] = 0.0
            bol = fmly_data[old_col] > 0
            fmly_data.loc[bol, new_col] = fmly_data.loc[bol, old_col]  * fmly_data.loc[bol, 'MO_SCOPE'] / 12
        
        fmly_data = fmly_data[['NEWID', 'INCLASS'] + weight_cols + rep_cols]
        return fmly_data
    
    def read_expenditure_data(self):
        """Read and process expenditure (MTAB/ITAB) files"""
        mtab_files = [
            f'MTBI{self.yr1}1X',
            f'MTBI{self.yr1}2',
            f'MTBI{self.yr1}3',
            f'MTBI{self.yr1}4',
            f'MTBI{self.yr2}1'
        ]

        itab_files = [
            f'ITBI{self.yr1}1X',
            f'ITBI{self.yr1}2',
            f'ITBI{self.yr1}3',
            f'ITBI{self.yr1}4',
            f'ITBI{self.yr2}1'
        ]

        dfs = []        
        # Read MTAB files
        for file in mtab_files:
            df = pd.read_csv(f'{self.data_path}\\data\\cex\\intrvw{self.yr1}\\' + file + '.csv')
            df = df[df['REF_YR'] == self.year]
            dfs.append(df)
        """
        # Read ITAB files
        for file in itab_files:
            df = pd.read_csv(f'{self.data_path}\\data\\cex\\intrvw{self.yr1}\\' + file + '.csv')
            df = df[df['REFYR'] == self.year]
            df = df.rename(columns={'VALUE': 'COST', 'REFYR': 'REF_YR'})
            dfs.append(df[['NEWID', 'UCC', 'COST']])
        """
        expend_data = pd.concat(dfs, axis=0)
        
        # Adjust UCC 710110
        expend_data.loc[expend_data['UCC'] == 710110, 'COST'] *= 4
        
        # double check against https://download.bls.gov/pub/time.series/cx/, item.cx to see what should be included        

        ELIUCC = [ '800861', '800860', '00851', '800850', '800841', '800840', '800831', '800830', '800821', '800820', '800811', '800810', '800804',
                  '800802', '800801', '800710', '850300', '860100', '860200', '860301', '860302', '860500', '860600', '860800', '910050', '910104', '910105', '910106', '910107', '950024']
        bol = (expend_data['UCC'] > 800700) & (~expend_data['UCC'].isin(ELIUCC))
        expend_data = expend_data.loc[~bol]

        return expend_data

    def calculate_weighted_stats_multi(self, df, agg_vars, expenditure_vars, pop_vars, weight_vars):

        results = []
        for exp_var in expenditure_vars:
            for num_w, den_w in zip(weight_vars, pop_vars):
                
                # Define auxiliary function to return weighted average
                def weighted_stats(group):
                    weights = group[num_w]                   
                    pop = group[den_w].sum()
                    values = group[exp_var].sum()
                    total_w = group[num_w].sum()
        
                    # Calculate weighted mean
                    weighted_mean = (values * weights).sum() / pop
        
                    return pd.Series({
                        'pop': pop,
                        'total_w': total_w,
                        'w_mean': weighted_mean,
                        'values': values
                        })
        
                # Apply the weighted_stats function
                result = (
                        df.groupby(agg_vars)
                        .apply(weighted_stats, include_groups=False)
                        .reset_index()
                        .assign(exp_var=exp_var, w_var=num_w)
                    )
                results.append(result)

            # Combine results for all variables and weights
            final_result = pd.concat(results, ignore_index=True)
            return final_result

    
    def ucc_means(self, fmly_data, expend_data):
        # Merge family and expenditure data
        merged_data = pd.merge(
            expend_data, 
            fmly_data,
            on='NEWID',
            how='left'
        ).sort_values('NEWID')
        
        
        agg_vars, expenditure_vars, pop_vars, weight_vars = ['INCLASS','UCC'], ['COST'], ['REPWT21'], ['FINLWT21']
        result = self.calculate_weighted_stats_multi(merged_data, agg_vars, expenditure_vars, pop_vars, weight_vars)
                
        return result
        
    def newid_means(self, fmly_data, expend_data):

        merged_data = pd.merge(
            expend_data, 
            fmly_data,
            on='NEWID',
            how='left'
        ).sort_values('NEWID')

        weight_cols = ['WTREP' + str(i).zfill(2) for i in range(1,45)] + ['FINLWT21']
        pop_cols = ['REPWT' + str(i).zfill(2) for i in range(1,46)]
        cols = {x: 'first' for x in weight_cols + pop_cols}
        cols.update({'COST': 'sum','INCLASS': 'first'})
        merged_data = merged_data.groupby(['NEWID'], as_index=False).agg(cols)
        
        agg_vars, expenditure_vars, pop_vars, weight_vars = ['INCLASS'], ['COST'], pop_cols, weight_cols
        result = self.calculate_weighted_stats_multi(merged_data, agg_vars, expenditure_vars, pop_vars, weight_vars)
        
        return result       
    """    
    def create_final_table(self, mean_data, stub_data):
        # Reshape means for final format
        
        addZeros = lambda x: '0'*(6-len(str(int(x)))) + str(int(x))
        mean_data['UCC'] = [addZeros(x) for x in mean_data['UCC']]
        
        bol = (stub_data['SURVEY'] == 'S') & (stub_data['LINE'] != '100001')
        stub_data = stub_data[~bol]
        stub_data.loc[]

        # Add labels from stub file
        final_table = pd.merge(
            mean_data,
            stub_data[['UCC','LINE', 'TITLE']],
            on='UCC',
            how='inner'
        )
        
        # Format income class labels
        income_labels = {
            '01': 'LESS THAN $15,000',
            '02': '$15,000 TO $29,999',
            '03': '$30,000 TO $39,999',
            '04': '$40,000 TO $49,999',
            '05': '$50,000 TO $69,999',
            '06': '$70,000 TO $99,999',
            '07': '$100,000 TO $149,999',
            '08': '$150,000 TO $199,999',
            '09': '$200,000 AND OVER',
            '10': 'ALL CONSUMER UNITS'
        }
        
        final_table.columns = [income_labels.get(col, col) for col in final_table.columns]
        
        return final_table
    """
# Example usage
year = 2018
#path=r"C:\Users\andre\OneDrive\research\cgoes\inflation-trump"
path = r'C:\Users\cbezerradegoes\OneDrive\research\cgoes\inflation-trump'

analyzer = CEXAnalysis(year, path)
    
# Read and process data
stub_file_path = f"{path}\\conc\\cex\\stubs\\CE-HG-Inter-{year}.TXT"
stub_data = analyzer.read_stub_file(stub_file_path)
fmly_data = analyzer.read_family_data()
expend_data = analyzer.read_expenditure_data()
    
# Calculate means and standard errors
means = analyzer.newid_means(fmly_data, expend_data)
final_table = means.loc[means['w_var'] == 'FINLWT21', ['INCLASS','w_mean','pop']]

# Calculate UCC means
ucc_means = analyzer.ucc_means(fmly_data, expend_data)

# Import shocks at UCC level
df_merge = pd.read_feather(os.path.join(path, r'data\temp_files\shock-ucc.feather'))

# Merge
ucc_means = ucc_means.merge(df_merge, how='left', on='UCC')

# Heterogeneous inflation
het_inflation = ucc_means[~ucc_means['cumulative_pct_change'].isnull()]

# calculate weights
het_inflation['values_total'] = het_inflation.groupby('INCLASS')['values'].transform('sum')
het_inflation['values_w'] = het_inflation['values'] / het_inflation['values_total']

# calculate marginal inflation
het_inflation['marginal'] = het_inflation['cumulative_pct_change'] * het_inflation['values_w']
group_inflation = het_inflation.groupby('INCLASS')['marginal'].sum()

#income_bins = [0, 15000, 30000, 40000, 50000, 70000, 100000, 150000, 200000, 400000, float("inf")]
income_bins = [0, 40000, 50000, 70000, 100000, 150000, 200000, 400000, float("inf")]

import matplotlib.pyplot as plt
plt.plot(income_bins[:-1], group_inflation)
plt.ylabel('CPI inflation 2018-24 (2018 exp. weights)')
plt.xlabel('Annual household income')
