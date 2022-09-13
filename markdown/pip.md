### pip

If a basic virtual environment (`venv`) and `requirements.txt` are all that's needed, can use built-in tools.
```bash
# create a virtual environment via python
## built-in
python3 -m venv .venv

## faster
python3 -m pip install virtualenv # _or_ pipx install virtualenv
virtualenv .venv

# activate virtual environment
source .venv/bin/activate

# install dependencies
python3 -m pip install requests inquirer

# generate requirements.txt
python3 -m pip freeze > requirements.txt

# exit virtual environment
deactivate
```
