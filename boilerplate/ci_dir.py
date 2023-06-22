#!/usr/bin/env python3

import subprocess
from pathlib import Path

"""
Over-engineered python solution to local directory for GitHub Actions.

cf. bash:
    w=$(basename $(echo $PWD)); echo "./${w}" > ../BASE_DIR

USAGE
    cd <dir>
    python ../ci_dir.py
"""

# get path of working directory
cwd = Path.cwd()

# basename of working directory
cwd_bn = cwd.name

# add './' prefix to cwd_bn
rel = "./" + cwd_bn

# add 'CWD=' prefix to rel
cwd_str = "CWD=" + rel

# call git via subprocess to find name of repo
abs = subprocess.check_output(["git", "rev-parse", "--show-toplevel"]).decode("utf-8").strip()

# split at last '/' and assign last element to repo
raw = abs.split("/")
repo = raw[-1]

# path to relative directory
up = str(Path(f"{repo}/{rel}"))

# dot path to working directory
dot = f"{rel}"

# list locations right aligned up to n chars (needed for absolute path)
# print(f"abs: {abs:>30}")
# print(f"cwd: {up:>30}")
# print(f"dot: {dot:>30}")
# print(f"tld: {repo:>30}")

# write dot to "{abs}/WORKDIR"
with open(f"{abs}/BASE_DIR", "w") as f:
    f.write(dot)
