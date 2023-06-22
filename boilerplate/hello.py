#!/usr/bin/env python3

# flake8: noqa

# fmt: off
# import argparse
import arrow
# import git
# import numpy as np
# import os
import pandas as pd
# import re
# import requests
# import requests_cache
# import subprocess
# import time
# from bs4 import BeautifulSoup, Comment
from datetime import timedelta
from decouple import config
# from functools import wraps
# from icecream import ic
# from <local.py_module> import *
from pathlib import Path
# from playwright.async_api import async_playwright
# from playwright.sync_api import sync_playwright
# from prettytable import PrettyTable
# from requests_cache import CachedSession
# fmt: on

"""
The commented out section is boilerplate for common operations.
Feel free to uncomment and/or delete after first commit.
"""

# env
home = Path.home()
cwd = Path.cwd()
now = arrow.now().format("YYYYMMDD_HHmmss")
out = f"{cwd}/formatted/results_{now}.csv"

# env vars (hierarchy: args, env, .env)
HOST = config("HOST", default="localhost")
USER = config("USER")
PASS = config("PASS")

## verbose icecream
# ic.configureOutput(includeContext=True)


# def timeit(func):
#     @wraps(func)
#     def timeit_wrapper(*args, **kwargs):
#         start_time = time.perf_counter()
#         result = func(*args, **kwargs)
#         end_time = time.perf_counter()
#         total_time = end_time - start_time
#         print(f"Function {func.__name__}{args} {kwargs} Took {total_time:.4f} seconds")
#         return result

#     return timeit_wrapper


# @timeit
# def sub_get_url(id):
#     cmd = f"mas info {id} | awk '/https/ {{print $NF}}'"

#     return subprocess.check_output(cmd, stderr=subprocess.STDOUT, shell=True)


# # 0.1730, 1.7148 seconds
# sub_get_url(490179405)


# # clone substrapunks repo
# if not Path(cwd/'substrapunks').exists():
#     print("Cloning substrapunks repo...")
#     git.Repo.clone_from('https://github.com/UniqueNetwork/substrapunks.git', cwd/'substrapunks')
# else:
#     print("Pulling latest changes from substrapunks repo")
#     git.Repo(cwd/'substrapunks').git.pull()

# # face directory
# for p in cwd.rglob('**/substra*/scripts/*'):
#     if p.is_dir() and p.name == 'face_parts':
#         print(f"found {p}")
#         face_parts = p
#         break

# # check if images directory is empty, if not, user input to continue
# if len(list(cwd.rglob('**/images/*'))) > 0:
#     print("Images directory is not empty, overwrite? (y/n)")
#     if input() == 'y':
#         print("Continuing...")
#     else:
#         print("Exiting...")
#         exit()

# folders = ['logs', 'user_data']

# for folder in folders:
#     if not Path(folder).exists():
#         os.mkdir(os.path.join(cwd, folder))

## mkdir -p ./csv && cd $_
# if Path('csv').exists():
#     os.chdir('./csv')
#     print("Changed to the folder: " + os.getcwd())
# else:
#     try:
#         os.makedirs('./csv')
#     except FileExistsError as exists:
#         print('Folder already exists')
#     finally:
#         os.chdir('./csv')
#         print("Changed to the folder: " + os.getcwd())

# base_url = 'https://app.cloud-logon.com/dev/'
# calc_url = base_url + "calculator"
# hint_url = base_url + "easy_mode"

# requests_cache.install_cache("api_cache")

# main_page = requests.get(calc_url)

# page_soup = BeautifulSoup(main_page.text, 'html.parser')
# print(f"MAIN PAGE\n{page_soup}")

# comments = page_soup.find_all(string=lambda text: isinstance(text, Comment))
# print("COMMENTS")
# for comment in comments:
#     print(comment.strip())

# comment_regex = re.compile(r'\d{12}')
# raw = comment_regex.search(str(comments))
# aws_account_number = raw.group(0)
# print(f"AWS ACCOUNT NUMBER: {aws_account_number}")

# # TODO: missing auth token
# hint_page = requests.get(hint_url)
# hint_page_soup = BeautifulSoup(hint_page.text, 'html.parser')
# print(f"\nHINT PAGE\n{hint_page_soup}")
# print(hint_page.text)
