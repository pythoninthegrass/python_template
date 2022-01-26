import pandas as pd
import re
import requests
from bs4 import BeautifulSoup, Comment
from datetime import timedelta
# from icecream import ic
from pathlib import Path
from requests_cache import CachedSession

base_url = 'https://app.cloud-logon.com/dev/'
calc_url = base_url + "calculator"
hint_url = base_url + "easy_mode"

session = CachedSession(
    'pages_cache',
    use_cache_dir=False,               # Save files in the default user cache dir
    cache_control=True,                # Use Cache-Control headers for expiration, if available
    expire_after=timedelta(days=1),    # Otherwise expire responses after one day
    allowable_methods=['GET', 'POST'], # Cache POST requests to avoid sending the same data twice
    allowable_codes=[200, 400],        # Cache 400 responses as a solemn reminder of your failures
    ignored_parameters=['api_key'],    # Don't match this param or save it in the cache
    match_headers=True,                # Match all request headers
    stale_if_error=True,               # In case of request errors, use stale cache data if possible
)
main_page = requests.get(calc_url)

page_soup = BeautifulSoup(main_page.text, 'html.parser')
print(f"MAIN PAGE\n{page_soup}")

comments = page_soup.find_all(string=lambda text: isinstance(text, Comment))
print("COMMENTS")
for comment in comments:
    print(comment.strip())

comment_regex = re.compile(r'\d{12}')
raw = comment_regex.search(str(comments))
aws_account_number = raw.group(0)
print(f"AWS ACCOUNT NUMBER: {aws_account_number}")

# TODO: missing auth token
hint_page = requests.get(hint_url)
hint_page_soup = BeautifulSoup(hint_page.text, 'html.parser')
print(f"\nHINT PAGE\n{hint_page_soup}")
print(hint_page.text)
