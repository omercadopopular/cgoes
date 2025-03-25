import requests
import zipfile
import os
from time import sleep

cdir = r'C:\Users\cbezerradegoes\OneDrive\UCSD\Research\cgoes\inflation-trump'

# extract zip file to this folder
zipextractdir = '/data/cex/'

# set download agent for BLS website
# this may need to be updated, otherwise the website may block the download
session = requests.Session()
header = {
    'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.1 Safari/605.1.15',
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
    'Accept-Encoding': 'zip, gzip',
    'Accept-Language': 'en-US,en;q=0.9',
    'Connection': 'keep-alive',
    'referer': 'https://www.bls.gov/cex/pumd_data.htm',
}

session.headers.update(header)

first_year = 2014
last_year = 2023
years_to_download = range(first_year, last_year+1)

# this loop downloads the data from the BLS starting with CEX_startdate from 
# the yaml file and ending with CEX_enddate
for year in years_to_download:

    # last two digits of number
    yy2 = abs(year) % 100 
    
    prefixes = ["intrvw", "diary"]
    
    for prefix in prefixes:
        
        # filename
        filename = prefix + str(yy2).zfill(2) + ".zip"
        
        if yy2 < 22:
            slash = 'comma/'
        else:
            slash = 'csv/'
    
        # construct URL (can change data format by replacing stata with comma)
        url = "https://www.bls.gov/cex/pumd/data/" + slash + filename
    
        # construct directory
        zippath = cdir + r'\data\cex'
        zipfilepath = os.path.join(zippath, filename)
    
        # download data
        print(url + '\n')
        # wget.download(url, zipfilepath)
        response = session.get(url)
        with open(zipfilepath, mode='wb') as localfile:     
            localfile.write(response.content)
            sleep(1)
#            sleep(randint(10,100))
    
        # unzip all files then zip them together again. this makes it easier to track
        # the downloaded file with make
        with zipfile.ZipFile(zipfilepath, 'r') as zip_ref:
            zip_ref.extractall(zippath)
    