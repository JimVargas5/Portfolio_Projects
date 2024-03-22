# Helper functions for the EconTalk word cloud project

import requests

from bs4 import BeautifulSoup
from bs4.dammit import EncodingDetector

from nltk.corpus import stopwords
from nltk.tokenize import word_tokenize



# The EconTalk website is protected by CloudFlare, which made scraping difficult
# at first. Using this 'HEADER' allows the website to be scraped.
HEADER = {
  "User-Agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.75 Safari/537.36",
  "X-Requested-With": "XMLHttpRequest"
}

def get_soup(html):
    '''Input an html address as type str, and scrapes the text.
    Returns BeautifulSoup object.'''

    resp = requests.get(html, headers=HEADER)
    http_encoding = resp.encoding if 'charset' in resp.headers.get('contenttype', '').lower() else None
    html_encoding = EncodingDetector.find_declared_encoding(resp.content, is_html=True)
    encoding = html_encoding or http_encoding
    soup = BeautifulSoup(resp.content, from_encoding=encoding, features='lxml')

    return soup




def get_links(soup):
    '''Input a BeatuifulSoup object and finds all links (hrefs) in the html.
    Returns a list of html link strings.'''

    links = []
    for link in soup.find_all('a', href=True):
        if "www.econtalk.org" in link['href'] and link['href'] != "https://www.econtalk.org/":
            links.append(link['href'].strip("'"))

    return links




def get_divs(soup):
    '''Input a BeautifulSoup object and locates the text within the "transcript"
    section of the web page.
    This section was found by using the "Inspect" tool in browser.
    Returns a list containg the transcript text as a string.'''

    links = []
    for link in soup.find_all('div', {"class": "audio-highlight"}):
        links.append(link.get_text())

    return links




def get_text(text_array):
    '''Converts a list of strings into a single string.'''
    return " ".join(text_array)




def episode_transcript(episode_link):
    '''Converts an html link for an episode into a string of that episode's transcript.'''

    transcript = ""
    soup = get_soup(episode_link)
    text_array = get_divs(soup)
    full_text = get_text(text_array)
    transcript += full_text

    return transcript




def punctuation_stop(text):
    '''Filters a string for punctuation, symbols, and unwanted words from
    nltk.corpus.stopwords (e.g. "the", "and" "it").
    
    Run the following commands on the terminal for dependencies:
    >>>python -m nltk.downloader stopwords
    >>>python -m nltk.downloader punkt'''

    filtered = []
    stop_words = stopwords.words('english')
    word_tokens = word_tokenize(text)

    for w in word_tokens:
        if w.lower() not in stop_words and w.isalpha():
            filtered.append(w.lower())

    return filtered


