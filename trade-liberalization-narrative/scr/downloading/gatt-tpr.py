# -*- coding: utf-8 -*-
"""
Scrape WTO GATT document index pages (1986–1995) to extract entries
whose Symbol matches pattern 'C/RM/*'. Output JSON with symbol, title,
date, and URL.

@author: cbezerradegoes
"""

import requests
from bs4 import BeautifulSoup
import re
import json
from urllib.parse import urljoin
from pathlib import Path

# ---------------------------------------------------------------------
# Input dictionary of period URLs
data = {
    '1986-1990': 'https://docs.wto.org/gattdocs/q/1986_90.HTM',
    '1991-1995': 'https://docs.wto.org/gattdocs/q/1991_95.HTM'
}

# Regex pattern for symbols like C/RM/123 or C/RM/USA/1
pattern = re.compile(r'^C/RM/.*', re.IGNORECASE)

# Output list
results = []

# ---------------------------------------------------------------------
for period, url in data.items():
    print(f"Fetching {period} → {url}")
    try:
        resp = requests.get(url, timeout=30)
        resp.raise_for_status()
    except requests.RequestException as e:
        print(f"⚠️ Error fetching {url}: {e}")
        continue

    soup = BeautifulSoup(resp.text, "html.parser")

    # Each document appears in <tr> rows
    rows = soup.find_all("tr")

    for row in rows:
        cols = row.find_all("td")
        if len(cols) < 3:
            continue

        # Extract symbol text and hyperlink
        symbol_tag = cols[0].find("a")
        if not symbol_tag:
            continue

        symbol_text = symbol_tag.text.strip()
        if not pattern.match(symbol_text):
            continue

        symbol_url = urljoin(url, symbol_tag.get("href"))
        title = cols[1].get_text(strip=True)
        date = cols[2].get_text(strip=True)

        results.append({
            "period": period,
            "symbol": symbol_text,
            "title": title,
            "date": date,
            "url": symbol_url
        })

# Save results to JSON
base_dir = Path(__file__).resolve().parent.parent.parent # Assuming `/code` is one level below the root directory
data_dir = base_dir / "data"
data_dir.mkdir(exist_ok=True)
output_file = data_dir / "wto-links" / "gatt_tpr_document_source.json"
with open(output_file, "w", encoding="utf-8") as f:
    json.dump(results, f, ensure_ascii=False, indent=2)

print(f"✅ Extracted {len(results)} C/RM/* documents")
print(f"Saved to {output_file}")
