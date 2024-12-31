# -*- coding: utf-8 -*-
"""
Created on Tue Oct 26 10:27:47 2021

@author: Carlos
"""

from scipy import random
from scipy import stats
import pandas as pd
import numpy as np
import statsmodels.formula.api as smf

def simulation():
    T = 1000
    sigmax1 = 10
    sigmax2 = 10
    sigmaepsilon = 1
    beta1 = 10
    beta2 = -10
    
    x1 = random.normal(0,sigmax1, T)
    x2 = random.normal(0,sigmax2, T)
    epsilon1 = random.normal(0,sigmaepsilon, T)
    epsilon2 = random.normal(0,sigmaepsilon, T)
    
    y1 = beta1 * x1 + epsilon1
    y2 = beta2 * x2 + epsilon2
    
    y = y1 - y2
    x = x1 - x2
    
    DictFrame = {
        'y': y,
        'x': x,
        'y1': y1,
        'x1': x1,
        'y2': y2,
        'x1': x1
        }
    
    Frame = pd.DataFrame.from_dict(DictFrame)
    model = smf.ols("y ~ x - 1", data=Frame).fit()
    return model

params = []
for tries in range(0,10000):
    model = simulation()
    params.append(model.params[0])
    
import matplotlib.pyplot as plt

fig = plt.figure()
plt.hist(params, bins=250)
plt.axvline(0, color='black')
plt.show()