# -*- coding: utf-8 -*-
"""
SINESP crime data processing with IBGE population merge and rate calculation
Author: andre
Date: Oct 2025
"""

import os
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import requests

# ---------------------------------------------------------------------
# CONFIGURATION
# ---------------------------------------------------------------------
path = r'C:\Users\andre\OneDrive\research\cgoes\sinesp'
os.makedirs(path, exist_ok=True)

url_template = (
    "https://www.gov.br/mj/pt-br/assuntos/sua-seguranca/seguranca-publica/"
    "estatistica/download/dnsp-base-de-dados/bancovde-{year}.xlsx/@@download/file"
)

region_map = {
    'AC': 'Norte', 'AP': 'Norte', 'AM': 'Norte', 'PA': 'Norte', 'RO': 'Norte', 'RR': 'Norte', 'TO': 'Norte',
    'AL': 'Nordeste', 'BA': 'Nordeste', 'CE': 'Nordeste', 'MA': 'Nordeste', 'PB': 'Nordeste', 'PE': 'Nordeste',
    'PI': 'Nordeste', 'RN': 'Nordeste', 'SE': 'Nordeste',
    'DF': 'Centro-Oeste', 'GO': 'Centro-Oeste', 'MT': 'Centro-Oeste', 'MS': 'Centro-Oeste',
    'ES': 'Sudeste', 'MG': 'Sudeste', 'RJ': 'Sudeste', 'SP': 'Sudeste',
    'PR': 'Sul', 'RS': 'Sul', 'SC': 'Sul'
}

# ---------------------------------------------------------------------
# DOWNLOAD SINESP FILES
# ---------------------------------------------------------------------
for year in range(2015, 2025):
    url = url_template.format(year=year)
    file_name = f"bancovde-{year}.xlsx"
    file_path = os.path.join(path, file_name)
    if os.path.exists(file_path):
        continue
    print(f"Downloading {file_name}...")
    try:
        r = requests.get(url, allow_redirects=True, timeout=60)
        if r.status_code == 200:
            with open(file_path, "wb") as f:
                f.write(r.content)
            print(f"✅ {file_name} downloaded.")
        else:
            print(f"⚠️ Could not download {file_name}: {r.status_code}")
    except Exception as e:
        print(f"❌ Error downloading {file_name}: {e}")

# ---------------------------------------------------------------------
# LOAD & CLEAN
# ---------------------------------------------------------------------
def load_excel_safely(file_path):
    df = pd.read_excel(file_path)
    df.columns = [c.lower().strip() for c in df.columns]
    date_col = next((c for c in ['data_referencia', 'data', 'datareferencia'] if c in df.columns), None)
    if date_col is None:
        raise ValueError(f"No date column in {file_path}")
    df['ano'] = pd.to_datetime(df[date_col], errors='coerce').dt.year
    keep_cols = ['uf', 'evento', 'total', 'total_vitima', 'ano']
    return df[[c for c in keep_cols if c in df.columns]]

all_years = []
for year in range(2015, 2025):
    fp = os.path.join(path, f"bancovde-{year}.xlsx")
    if not os.path.exists(fp):
        continue
    print(f"Processing {year}...")
    df_y = load_excel_safely(fp)
    all_years.append(df_y)

df_long = pd.concat(all_years, ignore_index=True)
df = df_long.groupby(['uf', 'evento', 'ano']).sum().reset_index()
df['regiao'] = df['uf'].map(region_map)

# ---------------------------------------------------------------------
# POPULATION DATA FROM IBGE (Agregado 6579, variável 9324 – multi-year query)
# ---------------------------------------------------------------------
print("📊 Downloading population data from IBGE (Agregado 6579, variável 9324)...")

try:
    url = (
        "https://servicodados.ibge.gov.br/api/v3/agregados/6579/periodos/"
        "2001|2002|2003|2004|2005|2006|2008|2009|2011|2012|2013|2014|2015|2016|2017|2018|2019|2020|2021|2024|2025/"
        "variaveis/9324?localidades=N3[all]"
    )
    resp = requests.get(url, timeout=60)
    resp.raise_for_status()
    data = resp.json()

    # Extract (UF, year, population)
    records = []
    for estado in data[0]['resultados'][0]['series']:
        uf_nome = estado['localidade']['nome']
        for ano, valor in estado['serie'].items():
            try:
                records.append({'uf_nome': uf_nome, 'ano': int(ano), 'pop': float(valor)})
            except ValueError:
                continue

    pop_df = pd.DataFrame(records)

    # Map full state names to abbreviations
    uf_map = {
        'Rondônia': 'RO', 'Acre': 'AC', 'Amazonas': 'AM', 'Roraima': 'RR', 'Pará': 'PA', 'Amapá': 'AP', 'Tocantins': 'TO',
        'Maranhão': 'MA', 'Piauí': 'PI', 'Ceará': 'CE', 'Rio Grande do Norte': 'RN', 'Paraíba': 'PB', 'Pernambuco': 'PE',
        'Alagoas': 'AL', 'Sergipe': 'SE', 'Bahia': 'BA', 'Minas Gerais': 'MG', 'Espírito Santo': 'ES', 'Rio de Janeiro': 'RJ',
        'São Paulo': 'SP', 'Paraná': 'PR', 'Santa Catarina': 'SC', 'Rio Grande do Sul': 'RS',
        'Mato Grosso do Sul': 'MS', 'Mato Grosso': 'MT', 'Goiás': 'GO', 'Distrito Federal': 'DF'
    }

    pop_df['uf'] = pop_df['uf_nome'].map(uf_map)
    pop_df = pop_df[['uf', 'ano', 'pop']].dropna()
    pop_df['ano'] = pop_df['ano'].astype(int)
    pop_df['pop'] = pop_df['pop'].astype(float)

    print(f"✅ Population data successfully downloaded ({pop_df['ano'].min()}–{pop_df['ano'].max()}).")
    print(f"   {len(pop_df)} records across {pop_df['uf'].nunique()} states.")
except Exception as e:
    print(f"⚠️ Error downloading population data: {e}")
    pop_df = pd.DataFrame(columns=['uf', 'ano', 'pop'])

# ---------------------------------------------------------------------
# MERGE POPULATION DATA AND INTERPOLATE MISSING YEARS
# ---------------------------------------------------------------------
print("🔗 Merging and interpolating population data...")

# 1. Remove existing 'pop' column if script re-run

# Reindex to ensure continuous years for each UF
years_full = np.arange(pop_df['ano'].min(), pop_df['ano'].max() + 1)
ufs = sorted(pop_df['uf'].unique())
panel_index = pd.MultiIndex.from_product([ufs, years_full], names=['uf', 'ano'])
panel = pop_df.set_index(['uf', 'ano']).reindex(panel_index).reset_index()

# Interpolate missing population values by UF (linear, filling both sides)
panel = panel.sort_values(['uf', 'ano'])
panel['pop'] = panel.groupby('uf')['pop'].transform(
    lambda x: x.interpolate(method='linear', limit_direction='both')
)

# Merge with original df
if 'pop' in df.columns:
    df = df.drop(columns=['pop'])
panel = pd.merge(panel, df, on=['uf','ano'], how='right')

# Recompute rates per 100k inhabitants
panel['total_rate'] = panel['total'] / panel['pop'] * 100000
panel['total_vitima_rate'] = panel['total_vitima'] / panel['pop'] * 100000

# Add region labels
panel['regiao'] = panel['uf'].map(region_map)

# Truncate post 2017
panel = panel[panel['ano'] >= 2017]

print(f"✅ Population merged and interpolated. ({panel['pop'].isna().sum()} missing values remaining.)")

# ---------------------------------------------------------------------
# AGGREGATE
# ---------------------------------------------------------------------
focus_events = {
    'Homicídio doloso': 'total_vitima',
    'Roubo seguido de morte (latrocínio)': 'total_vitima',
    'Tentativa de homicídio': 'total_vitima',
    'Lesão corporal seguida de morte': 'total_vitima',
    'Roubo a instituição financeira': 'total',
    'Roubo de carga': 'total',
    'Roubo de veículo':  'total',
    'Furto de veículo': 'total'
}

panel = (
    panel[panel['evento'].isin(focus_events)]
)

panel.to_csv(os.path.join(path, 'sinesp_panel_2015_2024.csv'), index=False)
print("✅ Aggregated panel saved with rates.")

# ---------------------------------------------------------------------
# PLOT BY STATE OVER TIME (WITH NATIONAL POP-WEIGHTED AVERAGE)
# ---------------------------------------------------------------------
sns.set_style("whitegrid")
region_colors = {
    'Norte': '#1f77b4',
    'Nordeste': '#ff7f0e',
    'Centro-Oeste': '#2ca02c',
    'Sudeste': '#d62728',
    'Sul': '#9467bd'
}

def plot_event_trends(panel, event_name, var):
    df_ev = panel[panel['evento'] == event_name]
    if var not in df_ev.columns:
        print(f"⚠️ {var} not found for {event_name}.")
        return

    # Compute population-weighted national rate
    base_df = panel[panel['evento'] == event_name]
    total_col = 'total' if 'total_rate' in var else 'total_vitima'
    nat = (
        base_df.groupby('ano', as_index=False)
        .agg({total_col: 'sum', 'pop': 'sum'})
    )
    nat['national_rate'] = nat[total_col] / nat['pop'] * 100000

    # Plot
    plt.figure(figsize=(12, 7))
    for uf, sub in df_ev.groupby('uf'):
        color = region_colors.get(sub['regiao'].iloc[0], 'gray')
        plt.plot(sub['ano'], sub[var], color=color, alpha=0.25, linewidth=1.5)
    plt.plot(nat['ano'], nat['national_rate'], color='black', linewidth=3.5, label='Média Nacional')

    for reg, col in region_colors.items():
        plt.plot([], [], color=col, label=reg, linewidth=3)

    plt.title(f"{event_name} — Taxa por 100 mil habitantes (SINESP 2015–2024)", fontsize=18, fontweight='bold')
    plt.xlabel("Ano")
    plt.ylabel("Taxa por 100 mil habitantes")
    plt.legend(title="Região", loc="upper left", frameon=True)
    plt.tight_layout()
    plt.savefig(os.path.join(path, f"{event_name.replace(' ', '_')}_rate_lines.png"), dpi=300)
    plt.savefig(os.path.join(path, f"{event_name.replace(' ', '_')}_rate_lines.pdf"))
    plt.close()

for ev, base_var in focus_events.items():
    rate_var = f"{base_var}_rate"
    print(f"Plotting {ev} using '{rate_var}'...")
    plot_event_trends(panel, ev, rate_var)

print("✅ All plots saved with population-weighted national averages.")

# ---------------------------------------------------------------------
# REGIONAL PLOTS: HOMICÍDIO DOLOSO PER CAPITA POR ESTADO (melhorado)
# ---------------------------------------------------------------------
print("📊 Plotting enhanced regional homicide rates per state...")

# Filter for Homicídio doloso only
homic = panel[panel['evento'] == 'Homicídio doloso'].copy()

# Define regions and corresponding states
region_states = {
    'Norte':     ['AC', 'AP', 'AM', 'PA', 'RO', 'RR', 'TO'],
    'Nordeste':  ['AL', 'BA', 'CE', 'MA', 'PB', 'PE', 'PI', 'RN', 'SE'],
    'Centro-Oeste': ['DF', 'GO', 'MT', 'MS'],
    'Sudeste':   ['ES', 'MG', 'RJ', 'SP'],
    'Sul':       ['PR', 'RS', 'SC']
}

# Define color palettes per region (balanced contrast)
region_palettes = {
    'Norte': sns.color_palette("Blues", 7),
    'Nordeste': sns.color_palette("Oranges", 9),
    'Centro-Oeste': sns.color_palette("Greens", 4),
    'Sudeste': sns.color_palette("Reds", 4),
    'Sul': sns.color_palette("Purples", 3)
}

# Define line styles to alternate (for extra distinction)
linestyles = ['-', '--', '-.', ':']

# Create subplots
regions = list(region_states.keys())
fig, axes = plt.subplots(3, 2, figsize=(17, 14), sharex=False, sharey=False)
axes = axes.flatten()

for i, region in enumerate(regions):
    ax = axes[i]
    sub = homic[homic['uf'].isin(region_states[region])]
    pal = region_palettes[region]
    states = region_states[region]

    # Assign each state a color and a line style
    for j, uf in enumerate(states):
        grp = sub[sub['uf'] == uf]
        if grp.empty:
            continue
        color = pal[j % len(pal)]
        style = linestyles[j % len(linestyles)]
        lw = 2.5

        # Highlight the state with the highest mean homicide rate
        mean_rate = grp['total_vitima_rate'].mean()
        if mean_rate == sub.groupby('uf')['total_vitima_rate'].mean().max():
            lw = 4
            alpha = 1.0
        else:
            alpha = 0.7

        ax.plot(
            grp['ano'], grp['total_vitima_rate'],
            label=uf, color=color, linestyle=style,
            linewidth=lw, alpha=alpha
        )

    ax.set_title(f"{region}", fontsize=16, fontweight='bold')
    ax.set_xlabel("Ano", fontsize=12)
    ax.set_ylabel("Taxa por 100 mil hab.", fontsize=12)
    ax.grid(True, linestyle='--', alpha=0.4)
    ax.legend(title="Estados", ncol=2, fontsize=9, frameon=True)

# Remove empty subplot if odd number
if len(regions) < len(axes):
    for j in range(len(regions), len(axes)):
        fig.delaxes(axes[j])

fig.suptitle(
    "Homicídios Dolosos por 100 mil habitantes — por Estado e Região (SINESP + IBGE 2015–2024) \n Elaboração: Carlos Góes (@goescarlos)",
    fontsize=20, fontweight='bold'
)
plt.tight_layout(rect=[0, 0, 1, 0.96])

# Save
plt.savefig(os.path.join(path, "homicidio_doloso_regional_enhanced.png"), dpi=300)
plt.savefig(os.path.join(path, "homicidio_doloso_regional_enhanced.pdf"))
plt.close()

print("✅ Enhanced regional homicide rate plots saved.")

# ---------------------------------------------------------------------
# VARIAÇÃO CUMULATIVA 2017–2024: HOMICÍDIO DOLOSO POR ESTADO
# ---------------------------------------------------------------------
print("📊 Calculando variação cumulativa de homicídios dolosos (2017–2024)...")

# Filtra homicídio doloso
homic = panel[panel['evento'] == 'Homicídio doloso'].copy()

# Seleciona apenas anos de interesse
homic_sub = homic[homic['ano'].isin([2017, 2024])]

# Garante que temos apenas uma observação por estado-ano
homic_agg = (
    homic_sub.groupby(['uf', 'ano'], as_index=False)['total_vitima']
    .mean()
    .pivot(index='uf', columns='ano', values='total_vitima')
)

# Calcula variação percentual cumulativa
homic_agg['var_pct_2017_2024'] = (homic_agg[2024] / homic_agg[2017] - 1) * 100

# Adiciona rótulos de região
homic_agg['regiao'] = homic_agg.index.map(region_map)

# Reordena colunas
homic_agg = homic_agg.reset_index()[['uf', 'regiao', 2017, 2024, 'var_pct_2017_2024']]

# Calcula médias regionais
region_summary = (
    homic_agg.groupby('regiao')['var_pct_2017_2024']
    .mean()
    .reset_index()
    .rename(columns={'var_pct_2017_2024': 'media_regional'})
)

# Junta para exibir na mesma tabela
homic_final = homic_agg.merge(region_summary, on='regiao', how='left')

# Ordena por maior variação
homic_final = homic_final.sort_values('var_pct_2017_2024', ascending=False)

# Mostra tabela resumida no console
print("\n📋 Variação percentual cumulativa de homicídios dolosos (2017–2024):")
print(homic_final.to_string(index=False, formatters={
    2017: lambda x: f"{x:,.1f}",
    2024: lambda x: f"{x:,.1f}",
    'var_pct_2017_2024': lambda x: f"{x:+.1f}%",
    'media_regional': lambda x: f"{x:+.1f}%"
}))

# Salva CSV
out_csv = os.path.join(path, "homicidio_doloso_var_2017_2024.csv")
homic_final.to_csv(out_csv, index=False, float_format="%.2f")
print(f"✅ Tabela salva em: {out_csv}")

# ---------------------------------------------------------------------
# GRÁFICO DE BARRAS: VARIAÇÃO CUMULATIVA 2017–2024
# ---------------------------------------------------------------------
print("📊 Plotando gráfico de barras da variação cumulativa (2017–2024)...")

# Paleta de cores por região
region_colors = {
    'Norte': '#1f77b4',
    'Nordeste': '#ff7f0e',
    'Centro-Oeste': '#2ca02c',
    'Sudeste': '#d62728',
    'Sul': '#9467bd'
}

# Reordena por variação
homic_final = homic_final.sort_values('var_pct_2017_2024', ascending=True)

# Figura
fig, ax = plt.subplots(figsize=(10, 12))

# Plot das barras
bars = ax.barh(
    homic_final['uf'],
    homic_final['var_pct_2017_2024'],
    color=[region_colors[r] for r in homic_final['regiao']],
    alpha=0.85
)

# Linha de referência em 0%
ax.axvline(0, color='black', linewidth=1.2)

# Rótulos nas barras
for bar in bars:
    width = bar.get_width()
    label_x = width + (0.75 if width >= 0 else -0.75)
    ax.text(label_x, bar.get_y() + bar.get_height()/2,
            f"{width:+.1f}%", va='center', ha='left' if width >= 0 else 'right',
            fontsize=10, fontweight='bold')

# Títulos e rótulos
ax.set_title(
    "Variação Percentual Cumulativa na Taxa de Homicídios Dolosos (2017–2024)",
    fontsize=16, fontweight='bold', pad=20
)
ax.set_xlabel("Variação percentual (%)", fontsize=13)
ax.set_ylabel("Estado", fontsize=13)

# Legenda de cores das regiões
handles = [plt.Line2D([0], [0], color=c, lw=6) for c in region_colors.values()]
labels = list(region_colors.keys())
ax.legend(handles, labels, title="Região", frameon=True, fontsize=10, title_fontsize=11, loc='lower right')

# Estilo geral
sns.despine(left=True, bottom=True)
ax.grid(axis='x', linestyle='--', alpha=0.5)
plt.tight_layout()

# Salva as figuras
plt.savefig(os.path.join(path, "homicidio_doloso_var_2017_2024_barras.png"), dpi=300)
plt.savefig(os.path.join(path, "homicidio_doloso_var_2017_2024_barras.pdf"))
plt.close()

print("✅ Gráfico de barras salvo com sucesso.")

