# -*- coding: utf-8 -*-
"""
Created on Wed Jul 30 16:50:01 2025

@author: cbezerradegoes
"""

import requests, pandas as pd, re
from bs4 import BeautifulSoup

### ------------------------------------------------------------------
### 1. Download 2024 imports from Brazil, HS‑10 level
### ------------------------------------------------------------------
base = "https://api.census.gov/data/timeseries/intltrade/imports/hs"
params = {
    "get": "I_COMMODITY,GEN_VAL_YR",
    "COMM_LVL": "HS10",
    "CTY_CODE": "3510",        # Brazil – Schedule‑C confirmation :contentReference[oaicite:1]{index=1}
    "time": "2024-12",         # only December’s year‑to‑date figure
    "key": "a7cc7c5443a0a67a6acea950b0c8a8d65f124606"     # optional once you exceed 500 calls/day
}
r = requests.get(base, params=params, timeout=60)
r.raise_for_status()

imports = pd.DataFrame(r.json()[1:], columns=r.json()[0])
imports["value"] = pd.to_numeric(imports["GEN_VAL_YR"])
imports["hs8"]   = imports["I_COMMODITY"].str.slice(0, 8)  # trim to HS‑8
total_us_imports = imports["value"].sum()
imports_hs8 = imports.groupby('hs8')['value'].sum().reset_index()

### ------------------------------------------------------------------
### 2. Grab Annex I from the Executive‑Order web page
### ------------------------------------------------------------------
eo_url = "https://www.whitehouse.gov/presidential-actions/2025/07/addressing-threats-to-the-us/"
html = requests.get(eo_url, timeout=60).text
soup = BeautifulSoup(html, "lxml")

# Pull every string that looks like 0000.00.00
code_pattern = re.compile(r"\d{4}\.\d{2}\.\d{2}")
codes = set(m.group() for m in code_pattern.finditer(soup.get_text()))

annex = pd.DataFrame({"hs8": [c.replace(".", "") for c in codes]})   # strip dots

### ------------------------------------------------------------------
### 3. Merge and aggregate
### ------------------------------------------------------------------
covered   = imports_hs8.merge(annex, on="hs8", how="inner")
covered_val = covered["value"].sum()
share_exempt = covered_val / total_us_imports

print(f"US imports from Brazil, 2024 (Census basis): ${total_us_imports:,.0f}")
print(f"Value explicitly *excluded* in Annex I:         ${covered_val:,.0f}")
print(f"Share excluded:                                {share_exempt:.2%}")
print(f"Share subject to 40 % surcharge:               {(1-share_exempt):.2%}")
