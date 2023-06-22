#!/usr/bin/env python3

from pathlib import Path
from pyqrcode import QRCode

home = str(Path.home())

url = QRCode("https://github.com/pythoninthegrass/python_template")
url.png(Path(f"{home}/Downloads/repo.png"), scale=8)
