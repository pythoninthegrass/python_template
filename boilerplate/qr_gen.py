#!/usr/bin/env python3

import sys
from datetime import datetime
from pathlib import Path

try:
    from pyqrcode import QRCode
except ImportError:
    print("pyqrcode module not found. Install it with 'python -m pip install pyqrcode pypng'")
    sys.exit(1)

home = str(Path.home())
downloads = Path(f"{home}/Downloads")
timestamp = datetime.now().strftime("%Y%m%d%H%M%S")

if len(sys.argv) == 2 and sys.argv[1].startswith("http"):
    url = QRCode(sys.argv[1])
else:
    url = QRCode("https://github.com/pythoninthegrass/python_template")


def check_file():
    """
    Check if QR code already exists in ~/Downloads folder.
    If it does, rename it with a timestamp.
    """
    if Path(f"{home}/Downloads/qr.png").exists():
        print("QR code already exists in ~/Downloads")
        new_file_name = Path(f"{downloads}/qr_{timestamp}.png")
        Path(f"{downloads}/qr.png").rename(new_file_name)
        print(f"QR code copied to Downloads folder as 'qr_{timestamp}.png'")


def main():
    check_file()
    url.png(Path(f"{home}/Downloads/qr.png"), scale=8)
    print("QR code saved to Downloads folder as 'qr.png'")


if __name__ == "__main__":
    main()
