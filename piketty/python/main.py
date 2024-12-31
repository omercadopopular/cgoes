"""
Author: Gavin Xia (gx1@williams.edu)

Calculates VAR, SVAR, and panel SVAR. 
Panel SVAR methods are from Pedroni, P. (2013), Econometrics, 1(2), 180-206; https://doi.org/10.3390/econometrics1020180

Code still in development. Incorrect input could lead to incorrect output.

Your contribution is much appreciated!
Please contact the author to merge the repository.
"""

import os

os.chdir(r'C:\Users\andre\OneDrive\UCSD\Research\cgoes\piketty\python')

from SVAR import *
from panelSVAR import *
import warnings
import statsmodels.api as sm
warnings.filterwarnings("ignore", category=UserWarning, module="statsmodels")

def run_panel():
    # plot = False
    # savefig_path = ""
    # excel_path = "../data/test-run.xls"
    # excel_sheet_name = "Panel6_comm_all"
    # variables = {
    #     # 1 for unit root, 0 for stationary
    #     'CommodityIndex' : [1, 1],
    #     'Yreal' : [1, 1]
    # }
    # variable_order = ['CommodityIndex', 'Yreal']
    # shocks = ['Real', 'Nominal']
    # td_col = ["time"]
    # member_col = "country"
    # sr_constraint = []
    # lr_constraint = np.array([['.','0'],
    #                         ['.','.']])
    # sr_sign = np.array([['+','+'],
    #                     ['.','.']])
    # lr_sign = np.array([['.','.'],
    #                     ['.','.']])
    # maxlags = 4 # maximum lags to be considered for common shock responses
    # nsteps = 15   # desired number of steps for the impulse responses
    # lagmethod = 'aic'

    # bootstrap = False
    # ndraws = 2000
    # signif = 0.05 # significance level of bootstrap
    
    plot = False
    savefig_path = ""
    excel_path = "../raw-data/pedroni_ppp.xls"
    excel_sheet_name = "Sheet1"
    variables = {
        # 1 for unit root, 0 for stationary
        'Ereal' : [1, 1],
        'cpi' : [1, 1],
        'ae' : [1, 1]
    }
    variable_order = ['Ereal','ae','cpi']
    shocks = ['e1', 'e2', 'e3']
    td_col = ["Year", "Month"]
    member_col = "country"
    sr_constraint = np.array([])
    lr_constraint = np.array([['.','0','0'],
                            ['.','.','0'],
                            ['.','.','.']])
    sr_sign = np.array([['+','+','+'],
                        ['.','.','.'],
                        ['.','.','.']])
    maxlags = 18 # maximum lags to be considered for common shock responses
    nsteps = 20   # desired number of steps for the impulse responses
    lagmethod = 'aic'

    bootstrap = True
    ndraws = 2000
    signif = 0.05 # significance level of bootstrap
    
    # Run VAR
    panel_input = VAR_input(variables=variables, variable_order=variable_order, shocks=shocks, td_col=td_col, member_col=member_col, M=None,
                sr_constraint=sr_constraint, lr_constraint=lr_constraint, sr_sign=sr_sign,
                maxlags=maxlags, nsteps=nsteps, lagmethod=lagmethod, bootstrap=bootstrap, ndraws=ndraws, signif=signif,
                excel_path=excel_path, excel_sheet_name=excel_sheet_name, df=pd.DataFrame(), plot=plot, savefig_path=savefig_path)
    output2 = panelSVAR(panel_input)

def run_var():
    
    # # EXAMPLE IMPUT BELOW
    # plot = True
    # savefig_path = ""
    # excel_path = "../data/AustraliaData.xlsx"
    # excel_sheet_name = "Panel6_comm_all"
    # variables = {
    #     # 1 for unit root, 0 for stationary
    #     # First element in list for data input, second for output
    #     'Yreal' : [1, 1], # input in unit root form, output in unit root (steady-state) form
    #     'CPI' : [1, 0] # input in unit root form, output in stationary form (inflation rate)
    # }
    # variable_order = ['Yreal','CPI']
    # shocks = ['AS', 'AD']
    # td_col = ""
    # member_col = ""
    # sr_constraint = np.array([])
    # lr_constraint = np.array([['.','0'],
    #                         ['.','.']])
    # sr_sign = np.array([['.','.'],
    #                     ['.','+']])
    # lr_sign = np.array([['+','.'],
    #                     ['.','.']])
    # maxlags = 4 # maximum lags to be considered for common shock responses
    # nsteps = 15 # desired number of steps for the impulse responses
    # lagmethod = 'aic'

    # bootstrap = True
    # ndraws = 200
    # signif = 0.05 # significance level of bootstrap
    
    
    # INPUT SECTION
    plot = True
    savefig_path = ""
    excel_path = "../raw-data/bqdata.xlsx"
    excel_sheet_name = "econ471-bqdata"
    variables = {
        # 1 for unit root, 0 for stationary
        'dGDPADJUST' : [0, 1],
        'URADJUST' : [0, 0]
    }
    variable_order = ['dGDPADJUST','URADJUST']
    shocks = ['AS', 'AD']
    td_col = ""
    member_col = "" # Not a panel so no member column
    sr_constraint = np.array([])
    lr_constraint = np.array([['.','0'],
                            ['.','.']])
    sr_sign = np.array([['.','+'],
                        ['.','.']])
    lr_sign = np.array([['+','.'],
                        ['.','.']])
    maxlags = 8 # maximum lags to be considered for common shock responses
    nsteps = 20 # desired number of steps for the impulse responses
    lagmethod = 'aic'

    bootstrap = True
    ndraws = 200
    signif = 0.32 # significance level of bootstrap

    # Run VAR
    var_input = VAR_input(variables=variables, variable_order=variable_order, shocks=shocks, td_col=td_col, member_col=member_col, M=None,
                          lr_constraint=lr_constraint, sr_sign=sr_sign, lr_sign=lr_sign,
                        maxlags=maxlags, nsteps=nsteps, lagmethod=lagmethod, bootstrap=bootstrap, ndraws=ndraws, signif=signif,
                        excel_path=excel_path, excel_sheet_name=excel_sheet_name, df=pd.DataFrame(), plot=plot, savefig_path=savefig_path)
    output = SVAR(var_input)
    # print(output.ir)

if __name__ == "__main__":
    #run_var()
    run_panel()