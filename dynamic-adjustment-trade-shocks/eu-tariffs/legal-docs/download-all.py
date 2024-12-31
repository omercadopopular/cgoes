# -*- coding: utf-8 -*-
"""
Created on Thu Oct 24 13:18:21 2024

@author: andre
"""

import pandas as pd
import requests
import os

def download_pdfs_from_excel(excelPath, pdfColumn, savePath):
    # Create the save directory if it doesn't exist
    os.makedirs(savePath, exist_ok=True)

    # Read the Excel file
    df = pd.read_excel(excelPath)

    # Check if the specified column exists
    if pdfColumn not in df.columns:
        print(f"Column '{pdfColumn}' does not exist in the Excel file.")
        return

    # Iterate over the URLs in the specified column
    for index, url in df[pdfColumn].items():
        try:
            name = str(df.loc[index,'Description']) + '-' + str(df.loc[index,'Published']) 
            # Get the file name from the URL
            file_name = os.path.join(savePath, name + r'.pdf')
            
            # Download the PDF
            response = requests.get(url)
            response.raise_for_status()  # Raise an error for bad responses

            # Save the PDF to the specified directory
            with open(file_name, 'wb') as f:
                f.write(response.content)

            print(f"Downloaded: {file_name}")

        except requests.exceptions.RequestException as e:
            print(f"Failed to download {url}: {e}")

# Example usage
basePath = r'C:\Users\andre\OneDrive\UCSD\Research\cgoes\dynamic-adjustment-trade-shocks\eu-tariffs\legal-docs'
savePath = basePath
excelPath = os.path.join(basePath, 'search_results_export_2024-10-24 19_08_54.xlsx')  # Update with your Excel file path
pdfColumn = 'Link to the document (PDF, DOC, etc.)'  # Update with the actual column name containing URLs

download_pdfs_from_excel(excelPath, pdfColumn, basePath)
