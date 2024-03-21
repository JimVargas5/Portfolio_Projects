import pandas as pd
import matplotlib.pyplot as plt
import requests
import numpy as np

from os import path, getcwd
from PIL import Image

from bs4 import BeautifulSoup
from bs4.dammit import EncodingDetector

from nltk.corpus import stopwords
from nltk.tokenize import word_tokenize
from wordcloud import WordCloud, ImageColorGenerator, STOPWORDS



HEADER = {
  "User-Agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.75 Safari/537.36",
  "X-Requested-With": "XMLHttpRequest"
}



def get_soup(html):
    resp = requests.get(html, headers=HEADER)
    http_encoding = resp.encoding if 'charset' in resp.headers.get('contenttype', '').lower() else None
    html_encoding = EncodingDetector.find_declared_encoding(resp.content, is_html=True)
    encoding = html_encoding or http_encoding
    soup = BeautifulSoup(resp.content, from_encoding=encoding, features='lxml')

    return soup



def get_links(soup):
    links = []
    for link in soup.find_all('a', href=True):
        if "www.econtalk.org" in link['href'] and link['href'] != "https://www.econtalk.org/":
            links.append(link['href'].strip("'"))

    return links



def get_divs(soup):
    links = []
    for link in soup.find_all('div', {"class": "audio-highlight"}):
        links.append(link.get_text())

    return links



def get_text(text_array):
    return " ".join(text_array)



def episode_transcript(episode_link):
    transcript = []
    soup = get_soup(episode_link)
    text_array = get_divs(soup)
    full_text = get_text(text_array)
    transcript.append(full_text)

    return transcript



def punctuation_stop(text):
    filtered = []
    stop_words = set(stopwords.words('english'))
    word_tokens = word_tokenize(text)

    for w in word_tokens:
        if w not in stop_words and w.isalpha():
            filtered.append(w.lower())

    return filtered


