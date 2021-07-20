# -*- coding: utf-8 -*-
"""
Created on Wed Jul 14 14:46:45 2021

@author: Bruno
"""

#%%
import urllib.request
from bs4 import BeautifulSoup
import pandas as pd


import immo_utils as iu



#%%
provinces = list()
with urllib.request.urlopen("https://www.immobiliare.it/") as fp:
    soup = BeautifulSoup(fp.read().decode("utf8"), 'lxml')
    
    provinces = [iu.get_province_from_a_tag(tag) for tag in soup.find_all("li", "nd-listMeta__item nd-listMeta__item--meta") if iu.is_a_tag_province_url(tag)]






#%%
municipalities = list()
for p in (provinces[1:3]) : 
    municipalities.extend(iu.get_municipalities_from_province(p))

municipalities = pd.DataFrame(municipalities)
municipalities['url'] = municipalities.apply (lambda row: iu.get_municipality_url(row["municipality"], ""), axis=1)



#%%
# from datetime import datetime, timezone
# from loguru import logger
# from postgis.psycopg import register
# from psycopg2.sql import Identifier, SQL
# from pydantic import BaseSettings
# from typing import Any, List, Dict, NamedTuple, Optional, Sequence, Tuple, Union

# import os
# import psycopg2



class Settings(BaseSettings):
    host: str
    database: str
    user: str
    password: str
    port: int = 5432


settings = Settings()

try:
    connection = psycopg2.connect(
        host=settings.host,
        database=settings.database,
        user=settings.user,
        password=settings.password,
        port=settings.port,
    )
    register(connection)
    # connection.set_session(autocommit=True)
except Exception as e:
    logger.exception(e)


"""

"""
def persist_provinces(province_list: list, ref_date: str):
    sql = "INSERT INTO immobiliare_provincia (ref_date, provincia) VALUES(to_date(%s, 'yyyymmdd'), %s);"
    
    with connection.cursor() as cursor:
        for p in province_list :
            cursor.execute(sql, [ref_date, p])
        
        connection.commit()



persist_provinces(provinces)









