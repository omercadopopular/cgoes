# -*- coding: utf-8 -*-

"""
This script uses the UNCOMTRADE
API to retrieve international trade
data into a Pandas DataFrame
Author: Carlos Góes
www.carlosgoes.com
"""



class pycomtrade:
    
    def comtrade(reporter, partner, year, freq, flow, commoditycode, token, mmax=250000):       
        # import libraries
        import json
        import ssl
        import urllib
        import pandas as pd
        import logging
        
        #Import the index of countries
        partnerurl = 'https://comtrade.un.org/data/cache/partnerAreas.json'
        ctx = ssl.create_default_context()
        ctx.check_hostname = False
        ctx.verify_mode = ssl.CERT_NONE
        areas = urllib.request.urlopen(partnerurl, context=ctx)
        data = json.loads(areas.read())
        data = data['results']
        index = {}
        for i in range(len(data)):
            upper = data[i]['text']
            lower = upper.lower()
            index.update({lower: data[i]['id']})
        
        #Retrieve numeric codes for reporter and partner
        reporter = index[str(reporter)]
        partner =  index[str(partner)]

        url = 'http://comtrade.un.org/api/get?' + \
            'max=' + str(mmax) + '&' + \
            'type=C&' + \
            'freq=' + str(freq) + '&' + \
            'px=HS&' + \
            'ps=' + str(year) + '&' + \
            'r=' + str(reporter) + '&' + \
            'p=' + str(partner) + '&' + \
            'rg=' + str(flow) + '&' + \
            'cc=' + str(commoditycode) + '&' + \
            'head=M&' + \
            'fmt=csv&' + \
            'token=' + str(token)
        
        #Import data with the API, transform JSON into a frame
        urlopen = urllib.request.urlopen(url)
        data = pd.read_table(urlopen, sep=',')
        
        if (len(data) == 1): # If frame has only one line, it is empty
            logging.info("Year: {}, Country: {}, Flow: {}, Empty Frame".format(year, reporter, flow, len(data))) 
            return pd.DataFrame()
        
        else:
            logging.info("Frame retrieved from UNCOMTRADE. Year: {}, Country: {}, Flow: {}, Size: {}".format(year, reporter, flow, len(data))) 
            return data
    
    def code_retriever():
        # import libraries
        import pandas as pd
        
        frame = pd.read_json('https://comtrade.un.org/data/cache/partnerAreas.json')
        countries = [i['text'].lower() for i in frame['results']]
        return countries[2:]
    
    def year_retriever(path, partner, year, freq, flow, commoditycode, token='', wait_time=0):
        # import libraries
        import pandas as pd
        import time
        import os
        import logging

        print('Processing year: {}'.format(year))
        logging.info('Processing year: {}'.format(year)) 

        # Retrieve countries
        countries = pycomtrade.code_retriever()
        
        # Loop over countries
        for country in countries:

            print('Processing country: {}'.format(country))
            logging.info('Processing country: {}'.format(country)) 
            filename = str(country) + '_' + str(year) + '.csv'
            filepath = os.path.join(path,str(year),filename)
            try:
                # Check if there is a file in the database, if so, skip
                frame = pd.read_csv(filepath, sep=';')
                logging.info('{} dataframe already stored, do not download again'.format(country)) 
            except:
                # If there is no recorded file, retrieve it from comtrade
                try:
                    print('Downloading: {}'.format(country))
                    logging.info('Downloading: {}'.format(country)) 
                    frame = pycomtrade.comtrade(country, partner, year, freq, flow, commoditycode, token)
                except:
                    frame = pd.DataFrame()
            
                if (frame.size == 0):
                    logging.info('{}, empty frame'.format(country)) 
                    time.sleep(wait_time)
                    pass
                
                else:
                    frame.reset_index().drop('index', axis=1).to_csv(filepath, sep=';')
                    logging.info('{}, retrieved lines: {}'.format(country, len(frame))) 
                    time.sleep(wait_time)
        return None
    
    def size_checker(path, year, threshold):
        # import libraries
        import pandas as pd
        import os
        
        # Retrieve countries
        countries = pycomtrade.code_retriever()
        
        # Create empty dictionary
        check = dict()
        
        # Loop over countries:
        for country in countries:
            filename = str(country) + '_' + str(year) + '.csv'
            filepath = os.path.join(path,str(year),filename)
            try:
                # load data
                DF = pd.read_csv(filepath, sep=';')
                # check if data hits the threshold
                if len(DF) < threshold: # if not, pass
                    pass
                else:  # if so, store
                    check.update({ str(country): 1 })
            except: # if there is no underlying datafile, pass
                pass
            
        return check
        
    def size_updater(path, countries, partner, year, freq, commoditycode, threshold, token='', wait_time=0):
        # import libraries
        import pandas as pd
        import time
        import os
        import logging

        # Loop over countries:
        for country in countries:
            print('Processing {}'.format(country))
            logging.info('Processing {}'.format(country)) 

            filename = str(country) + '_' + str(year) + '.csv'
            filepath = os.path.join(path,str(year),filename)
            try:
                frame = pycomtrade.comtrade(country, partner, year, freq, 1, commoditycode, token)
                print('{} import lines {}'.format(country, len(frame)))
                logging.info('{} import lines {}'.format(country, len(frame))) 
            except:
                frame = pd.DataFrame()
                
            if (frame.size == 0):
                time.sleep(wait_time)
                pass
                    
            else:
                frame2 = pycomtrade.comtrade(country, partner, year, freq, 2, commoditycode, token)
                print('{} export lines {}'.format(country, len(frame2)))
                logging.info('{} export lines {}'.format(country, len(frame2))) 
                frame = frame.append(frame2)
                
                frame2 = pycomtrade.comtrade(country, partner, year, freq, 3, commoditycode, token)
                print('{} re-export lines {}'.format(country, len(frame2)))
                logging.info('{} re-export lines {}'.format(country, len(frame2))) 
                frame = frame.append(frame2)
                                
                frame2 = pycomtrade.comtrade(country, partner, year, freq, 4, commoditycode, token)
                print('{} re-import lines {}'.format(country, len(frame2)))
                logging.info('{} re-import lines {}'.format(country, len(frame2))) 
                frame = frame.append(frame2)

                frame.reset_index().drop('index', axis=1).to_csv(filepath, sep=';')
                time.sleep(wait_time)
        return None
        
    def product_number(frame, agglevel, rgcode, threshold):
        frame = frame[ frame['aggrLevel'] == agglevel ] #6-digit HS codes
        frame = frame[ frame['rgCode'] == rgcode ] # exports
        return (frame['TradeValue'] > threshold).size    
    
    def us_updater(path, partner, years, freq, commoditycode, threshold, token='', wait_time=0):
        # import libraries
        import pandas as pd
        import time
        import os
        
        import_dict = dict()
        export_dict = dict()

        # Loop over countries:
        for year in years:
            country = 'usa'
            print('Processing {}'.format(country))
            filename = str(country) + '_' + str(year) + '.csv'
            filepath = os.path.join(path,str(year),filename)
            try:
                frame = pycomtrade.comtrade(country, partner, year, freq, 1, commoditycode, token)
                print('{} export lines {}'.format(country, len(frame)))
            except:
                frame = pd.DataFrame()
                
            if (frame.size == 0):
                time.sleep(wait_time)
                pass
                    
            else:
                frame2 = pycomtrade.comtrade(country, partner, year, freq, 2, commoditycode, token)
                print('{} import lines {}'.format(country, len(frame)))
                frame.append(frame2).reset_index().drop('index', axis=1).to_csv(filepath, sep=";")
                time.sleep(wait_time)
            
        import_dict.update({year: len(frame)})
        export_dict.update({year: len(frame2)})
        return import_dict, export_dict
    
