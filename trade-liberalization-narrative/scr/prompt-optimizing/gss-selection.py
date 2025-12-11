# -*- coding: utf-8 -*-
"""
Created on Fri Nov 28 23:46:16 2025

@author: cbezerradegoes
"""

# Load required libraries
from pathlib import Path
import json
import pandas as pd

# Load manifest JSON file
base_dir = Path(__file__).resolve().parent.parent.parent
code_dir = base_dir / "scr/prompt-optimizing"
data_dir = base_dir / "data"
links_dir = data_dir / "wto-links"
manifest_path = links_dir / "global_tpr_manifest.json"

with manifest_path.open("r", encoding="utf-8") as f:
    manifest = json.load(f)

# Normalize manifest entries
manifest_df = pd.json_normalize(manifest)

# Group by country and get all TPR years
country_years = manifest_df.groupby("country")["year"].unique().reset_index()
country_years.columns = ["country", "available_tpr_years"]

# Create reform episode DataFrame based on Salinas & Aksoy (2006)
salinas_episodes = [
    {"country": "Argentina", "reform_year": 1991},
    {"country": "Bangladesh", "reform_year": 1989},
    {"country": "Chile", "reform_year": 1979},
    {"country": "Colombia", "reform_year": 1990},
    {"country": "Ghana", "reform_year": 1985},
    {"country": "India", "reform_year": 1991},
    {"country": "Indonesia", "reform_year": 1986},
    {"country": "Jamaica", "reform_year": 1984},
    {"country": "Kenya", "reform_year": 1993},
    {"country": "Mexico", "reform_year": 1985},
    {"country": "Morocco", "reform_year": 1984},
    {"country": "Peru", "reform_year": 1990},
    {"country": "Philippines", "reform_year": 1988},
    {"country": "Senegal", "reform_year": 1985},
    {"country": "Sri Lanka", "reform_year": 1977},
    {"country": "Tunisia", "reform_year": 1986},
    {"country": "Turkey", "reform_year": 1989},
    {"country": "Uruguay", "reform_year": 1990},
    {"country": "Zambia", "reform_year": 1992},
]
episodes_df = pd.DataFrame(salinas_episodes)

# Merge reform episodes with TPR availability
merged = pd.merge(episodes_df, country_years, on="country", how="inner")

# Calculate closest distance from reform year to TPR years
def closest_year_distance(row):
    return min(abs(y - row["reform_year"]) for y in row["available_tpr_years"])

merged["closest_tpr_distance"] = merged.apply(closest_year_distance, axis=1)

# Score countries based on proximity and document availability
merged["score"] = 0
merged.loc[merged["closest_tpr_distance"] <= 2, "score"] += 3
merged.loc[merged["closest_tpr_distance"] <= 5, "score"] += 2
merged["score"] += merged["available_tpr_years"].apply(lambda ys: min(len(ys), 2))

# Sort final output
gss_candidates = merged.sort_values("score", ascending=False).reset_index(drop=True)

# Filter manifest to only include the selected GSS countries
top_gss = gss_candidates.head(10).copy()
selected_countries = top_gss["country"].tolist()
gss_files = manifest_df[manifest_df["country"].isin(selected_countries)].copy()


# Sort and extract final table
gss_files_sorted = gss_files.sort_values(["country", "year"]).reset_index(drop=True)
final_gss_table = gss_files_sorted[["country", "year", "txt_filename", "doc_id"]]

# Export to JSON
final_gss_table.to_json(data_dir / "gss/final_gss_table.json", orient="records", indent=2)

# Display final result
print(final_gss_table)