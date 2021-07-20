# -*- coding: utf-8 -*-
"""
Created on Mon Jul 19 09:56:52 2021

@author: Bruno
"""


import urllib.request
from bs4 import BeautifulSoup
import re
import pandas as pd



#%%
def is_li_tag_announcement(tag):
    ret = False
    if not (tag is None) :
        if not (tag.get("id") is None) :
            ret = tag.get("id").startswith("link_ad_")
    return ret # & (tag.get("id")=="link_ad_89575195")



def is_li_tag_surface(tag):
    return ((not (re.search(r"\d+", str(tag.div)) is None)) & ("superficie" in str(tag)))



def is_li_tag_rooms(tag):
    return ((not (re.search(r"\d+", str(tag.div)) is None)) & ("locali" in str(tag)))



def get_municipality_from_li_tag(tag):
    a_tag = tag.find("a", "Card_in-card__title__234gH")
    
    
    p = [ li for li in tag.find_all("li") if not (re.search("€", li.text.strip()) is None) ]
    if(len(p)>0) :
        p = (re.split("€", p[0].text)[-1]).strip()[0]
    else :
        p = ""
        
    r = [ li.div for li in tag.find_all("li") if is_li_tag_rooms(li) ]
    if(len(r)>0) :
        r = re.findall(r"\d+\+?", r[0].text.strip())[0]
    else :
        r = ""
    
    s = [ li.div for li in tag.find_all("li") if is_li_tag_surface(li) ]
    if(len(s)>0) :
        s = re.findall(r"\d+", s[0].text.strip())[0]
    else :
        s = ""
    
    return {
        "id" : re.split("/", a_tag["href"])[-2]
        , "title" : a_tag.text.strip()
        , "price" : p
        , "surface" : s
        , "rooms" : r
    }



def get_page_count(tag) :
    # print(tag.find_all("div"))
    pages = tag.find_all("div", {"class" : "Pagination_in-pagination__item__1fF3O Pagination_hideOnMobile__TvjnS Pagination_in-pagination__item--disabled__3zi_j"})
    if not (pages is None) :
        # p2 = [int(re.findall(r"\d+$", p.text)) for p in pages if not (re.findall(r"\d+$", p.text) is None)]
        # print(p2)
        
        pages = [int(re.match(r"\d+", p.text)[0]) for p in pages if not (re.match(r"\d+", p.text) is None)]
        if(len(pages)>0) :
            pages = pages[0]
        else :
            pages = 1
    else :
        pages = 1
    return pages



def get_page_count_old(tag) :
    pages = tag.find("div", {"data-cy" : "pagination-next"})
    if not (pages is None) :
        pages = int(re.findall(
            r"\d+$",
            str(
                pages.find("use", {"xlink:href" : "#double-arrow-shadow-right"})
                    .parent
                    .parent
                    ["href"]
            )
        )[0])
    else :
        pages = 1
    return pages



#%%
URL = "https://www.immobiliare.it/vendita-case/acqui-terme/"
# URL = "https://www.immobiliare.it/vendita-case/aidone/"
pages = 0
with urllib.request.urlopen(URL) as fp:
    soup = BeautifulSoup(fp.read().decode("utf8"), 'lxml')
    
    pages = get_page_count(soup)
    



#%%
annoucements = list()
for i in range(pages):
    if i==0:
        url = URL 
    else:
        url = URL + "?pag=" + str(i+1)
    print(url)
    with urllib.request.urlopen(url) as fp:
        soup = BeautifulSoup(fp.read().decode("utf8"), 'lxml')
        
        annoucements.extend(
            [get_municipality_from_li_tag(tag) 
             for tag in soup.find_all("li", "List_nd-list__item__eE9EM results_in-realEstateResults__item__2SZwg") 
             if is_li_tag_announcement(tag)]
        )
    
    
    


#%%
ann = pd.DataFrame(annoucements)


#%%
# print(len(ann.id.unique()))
# print(len(ann.id))




