# -*- coding: utf-8 -*-

import urllib.request
from bs4 import BeautifulSoup
import re


#%%
def is_a_tag_province_url(tag: BeautifulSoup):
    """
    Checks if <tag> contains a link to a province page
    
    Parameters
    ----------
        tag : BeautifulSoup
            it should be an anchor tag <a>
    
    Returns
    -------
        True if <tag> contains a link to a province page
    """
    return not (
        re.search(
                r"/\w+-\w+/comuni"
                , tag.a["href"]
            ) is None
    )



def get_province_from_a_tag(tag: BeautifulSoup):
    """
    Extracts the name of the province page linked by <tag>
    
    Parameters
    ----------
        tag : BeautifulSoup 
            it should be an anchor tag <a>
    
    Returns
    -------
        Province name as string
    """
    return re.split(
            "-"
            , re.split(
                "/"
                , re.search(
                    r"/\w+-\w+/comuni"
                    , tag.a["href"]
                )[0]
            )[1]
        )[0]




def get_province_url(province: str, url_class: str):
    """
    Returns the province url
    
    Parameters
    ----------
        province : str
            province name
        url_class : str
            currently unused
    
    Returns
    -------
        Province "vendita-case" url
    """
    return "https://www.immobiliare.it/vendita-case/" + province + "-provincia/comuni/"




def get_municipality_from_li_tag(tag):
    """
    Parses an anchor tag <a> getting municipality name and announcement count

    Parameters
    ----------
    tag : BeautifulSoup
        it should be an anchor tag <a>

    Returns
    -------
        A dictionary containing municipality name and announcement count

    """
    name = tag.a["href"].split("/")[-2]
    cnt = tag.span.text.strip()
    return { "municipality" : name , "cnt" : cnt }



def get_municipalities_from_province(province):
    """
    Scrapes a provice pages retrieving municipality list.
    Each municipality is a dictionary containing province name, municipality name and announcement count
    
    Parameters
    ----------
    province : str
            province name

    Returns
    -------
    municipalities : dictionary list 
        Each dictionary contains province name, municipality name and announcement count.
    """
    municipalities = {}
    
    with urllib.request.urlopen(get_province_url(province, "")) as fp:
        soup = BeautifulSoup(fp.read().decode("utf8"), 'lxml')
    
        municipalities = [get_municipality_from_li_tag(tag) for tag in soup.find_all("li", "nd-listMeta__item nd-listMeta__item--meta")]
        for m in municipalities: m.update( {"province": province} )
        
    return municipalities
    


def get_municipality_url(municipality, url_class):
    """
    Returns the municipality url
    
    Parameters:
        municipality: province name
        url_class: currently unused
    
    Returns: 
        Municipality "vendita-case" url
    """
    return "https://www.immobiliare.it/vendita-case/" + municipality + "/"