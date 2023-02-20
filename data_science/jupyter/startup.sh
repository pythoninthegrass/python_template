#!/usr/bin/env bash

# start jupyter lab
jupyter lab --ip=0.0.0.0 --port=${PORT:-8888} --no-browser
