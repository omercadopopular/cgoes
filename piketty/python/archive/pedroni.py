# -*- coding: utf-8 -*-
"""
Created on Mon Oct 28 20:45:42 2024

@author: andre
"""

class pedroniSVAR:
    import numpy as np
    import pandas as pd
    import statsmodels.api as sm
    from statsmodels.tsa.api import VAR
    from statsmodels.tsa.api import SVAR
#    from statsmodels.tsa.vector_ar.svar_model import SVAR

    def __init__(self,
                 filePath, panelId, timeId, # Panel options
                 choleskyOrder, maxLags=3, lagLengthCrit='aic', irfHorizon=10, # Vector Autoregression options
                 fixedEffects=False, # data transformation options
                 cumulativeResponse=False, runBootstrap=False, bootReps=500, confInt=1.96, # IRF settings
                 ):
        
        self.filePath, self.panelId, self.timeId = filePath, panelId, timeId;
        self.choleskyOrder, self.maxLags, self.lagLengthCrit, self.irfHorizon = choleskyOrder, maxLags, lagLengthCrit, irfHorizon;
        self.fixedEffects = fixedEffects;
        self.cumulativeResponse, self.runBootstrap, self.bootReps, self.confInt = cumulativeResponse, runBootstrap, bootReps, confInt;
        self.endVars = choleskyOrder
        
        self.readFile()
        self.dataTransform()
        self.timeEffects()

    def readFile(self):
        filePath = self.filePath
        fileExt = filePath.split('.')[-1]
        
        if fileExt.upper() == 'CSV':
            self.baseFrame = pd.read_csv(filePath)
        
        elif (fileExt.upper() == 'XLSX') or (fileExt.upper() == 'XLS'):
            self.baseFrame = pd.read_excel(filePath)
        
        if fileExt.upper() == 'DTA':
            self.baseFrame = pd.read_stata(filePath)
        
        else:
            return ValueError("Filetype not supported. Data can be in CSV, XLS/XLSX or DTA format.")
    
    def dataTransform(self):
        baseFrame, panelId, timeId, choleskyOrder = self.baseFrame, self.panelId, self.timeId, self.choleskyOrder
        
        if self.fixedEffects:
            
            # update endogenous variables
            self.endVars = [variable + '_fe' for variable in self.endVars]
                        
            mergeFrame = pd.DataFrame()       
            for group in set(baseFrame[panelId]):
                miniFrame = baseFrame[ baseFrame[panelId] == group ]
                miniFrame = miniFrame[[panelId, timeId, *choleskyOrder]]
            
                for variable in choleskyOrder:
                    miniFrame.loc[:, variable + '_fe'] = miniFrame.loc[:,variable] - miniFrame.loc[:,variable].mean()
                    variable = variable + '_fe'
                
                miniFrame = miniFrame.drop(choleskyOrder, axis=1)
            
                mergeFrame = pd.concat([mergeFrame, miniFrame])
              
            self.baseFrame = pd.merge(baseFrame, mergeFrame, on=[panelId, timeId], how='left')    
            
    def timeEffects(self):
        panelId, timeId, endVars, irfHorizon, maxLags, lagLengthCrit = self.panelId, self.timeId, self.endVars, self.irfHorizon, self.maxLags, self.lagLengthCrit
        
        timeFrame = pd.DataFrame({timeId: pd.Series(baseFrame[timeId].unique())})
        for variable in endVars:
            timeEffect = baseFrame.groupby([timeId]).agg({variable: 'mean'})
            timeFrame = pd.merge(timeFrame, timeEffect, how='left', on=timeId)
        
        timeFrame = timeFrame.dropna().set_index(timeId)

        timeVAR =VAR(timeFrame)  

        timeResults = timeVAR.fit(maxlags=maxLags, ic=lagLengthCrit)
        timeResid = np.matrix(results.resid).T
        timeVarCov = timeResid * timeResid.T
        timeCholesky = np.linalg.cholesky(timeVarCov)
        timeResidStr = timeCholesky * timeResid
 
#        timeIrf = results.irf(irfHorizon)
 #       self.teIrfs = timeIrf.irfs
 #       self.teCirfs = irftimeIrf.cum_effects


        results = model.fit(maxlags=3, ic='aic')
        
        
        
        



        
        
        
            
        
        
    

import pandas as pd
import numpy as np
import os

basePath = r'C:\Users\andre\OneDrive\UCSD\Research\cgoes\piketty';
fileName = 'fkdatabasetax.csv';
filePath = os.path.join(basePath, fileName);

cholesKyOrder = ['rg2', 'kshare']
# lLength = ['aic’' 'fpe', 'hqic', 'bic']
obj = pedroniSVAR(filePath, 'country', 'year', cholesKyOrder, fixedEffects=True)

baseFrame = obj.baseFrame


import statsmodels.api as sm
from statsmodels.tsa.api import VAR
mdata = sm.datasets.macrodata.load_pandas().data
dates = mdata[['year', 'quarter']].astype(int).astype(str)
quarterly = dates["year"] + "Q" + dates["quarter"]

from statsmodels.tsa.base.datetools import dates_from_str
quarterly = dates_from_str(quarterly)
mdata = mdata[['realgdp','realcons','realinv']]
mdata.index = pd.DatetimeIndex(quarterly)

data = np.log(mdata).diff().dropna()

# make a VAR model
model = VAR(data)
results = model.fit(maxlags=15, ic='aic')

irf = results.irf(10)

