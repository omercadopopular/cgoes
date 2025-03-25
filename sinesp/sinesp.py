path = r'C:\Users\cbezerradegoes\OneDrive\research\cgoes\sinesp'

import os
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np
import requests

## download files

# URL template for the files
url_template = "https://www.gov.br/mj/pt-br/assuntos/sua-seguranca/seguranca-publica/estatistica/download/dnsp-base-de-dados/bancovde-{year}.xlsx/@@download/file"

# Loop over the years from 2015 to 2024
for year in range(2015, 2025):
    url = url_template.format(year=year)
    file_name = f"bancovde-{year}.xlsx"
    file_path = os.path.join(path, file_name)
    
    print(f"Downloading {file_name}...")

    # Download the file
    try:
        response = requests.get(url)
        response.raise_for_status()  # Check if the request was successful
        with open(file_path, 'wb') as f:
            f.write(response.content)
        print(f"File {file_name} downloaded successfully!")
    except requests.exceptions.RequestException as e:
        print(f"Error downloading {file_name}: {e}")


## process data

years = range(2015,2024 + 1)
file = lambda y: f'bancovde-{y}.xlsx'

vitima, roubo = [], []
for year in years:
    print(f'processing year {year}...')
    file_path = os.path.join(path, file(year))
    df = pd.read_excel(file_path)
    df['ano'] = [x.year for x in df.data_referencia]
    vitimas = df.loc[df['total_vitima'] > 0].groupby('evento').agg({'total_vitima': 'sum', 'ano': 'first'})
    roubos = df.loc[df['total'] > 0].groupby('evento').agg({'total': 'sum', 'ano': 'first'})
    vitima.append(vitimas)
    roubo.append(roubos)

vitimas = pd.concat(vitima).reset_index().pivot(index='evento', columns='ano', values='total_vitima')
roubos = pd.concat(roubo).reset_index().pivot(index='evento', columns='ano', values='total')
frame = pd.concat([vitimas, roubos])

def plot_figure(frame, file_name):
    # Plot settings
    fig, axes = plt.subplots(2, 2, figsize=(15, 12), constrained_layout=True)
    fig.suptitle("Ocorrências no Sinesp (Ministério da Justiça). Elaborado por @goescarlos", fontsize=22, fontweight='bold')
    colors = ["#1f77b4", "#ff7f0e"]  # Consistent colors for both years
    bar_width = 0.8

    # Plot each category in a separate subplot
    for ax, (category, values) in zip(axes.flat, frame.iterrows()):
        x = np.arange(len(values))  # Ordered x placement
        bars1 = ax.bar(x, values, width=bar_width, color=colors[0])
        ax.set_title(category, fontsize=18, fontweight='bold')
        ax.set_ylim(0, np.max(values) * 1.5)
        
        for bar in bars1:
            ax.text(bar.get_x() + bar_width / 2, bar.get_height() * 1.1, 
                    str(int(bar.get_height())), ha='center', fontsize=14, fontweight='bold')
        
        ax.set_xticks(x)
        ax.set_yticks([])
        ax.set_xticklabels(years, fontsize=14)

    fig.savefig(os.path.join(path, f'{file_name}.pdf'))
    fig.savefig(os.path.join(path, f'{file_name}.png'))

    plt.close()

filters = [
['Homicídio doloso',
'Roubo seguido de morte (latrocínio)',
'Tentativa de homicídio',
'Furto de veículo'],
['Arma de Fogo Apreendida',
'Roubo a instituição financeira',
'Roubo de carga',
'Roubo de veículo'],
['Tráfico de drogas',
'Estupro',
'Estupro de vulnerável',
'Feminicídio']
]

frame = pd.concat([vitimas, roubos])

counter = 0
for filter in filters:
    counter += 1
    frame_filter = frame[frame.index.isin(filter)]
    plot_figure(frame_filter, f'sinesp{counter}')
