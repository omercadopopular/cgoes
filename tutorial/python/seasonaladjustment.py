## Coded by Victoria Jalowitzki de Quadros

import math
import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
import statsmodels.api as sm
import matplotlib.pyplot as plt
import csv

# make a trended sine wave
s = [10 * math.sin(i * 2 * math.pi / 25) + i * i /100.0 for i in range(100)]

def grab_total(line):
  split = line.split(',')
try:
  return pd.to_datetime(split[0]), int((split[-2] + split[-1]).strip()[1:-1])
except:
  return None

lines = open('total.csv', 'r').readlines()
dates, totals = zip(*[grab_total(line) for line in lines if grab_total(line) != None])

df = pd.Series(totals, index=dates)

#dta = sm.datasets.co2.load_pandas().data.resample("M").fillna(method="ffill")

res = sm.tsa.seasonal_decompose(df)

with open('eggs.csv', 'wb') as csvfile:
  spamwriter = csv.writer(csvfile, delimiter=' ', quotechar='|', quoting=csv.QUOTE_MINIMAL)
  assert (len(res.resid) == len(res.seasonal) and len(res.resid) == len(res.trend))
  spamwriter.writerow(['Date', 'Total (src)', 'Trend', 'Residual', 'Seasonal'])
for i in range(len(res.resid)):
  spamwriter.writerow([dates[i], totals[i], res.trend[i], res.resid[i], res.seasonal[i]])

fig = res.plot()
fig.set_size_inches(10, 5)
plt.tight_layout()
plt.show()
