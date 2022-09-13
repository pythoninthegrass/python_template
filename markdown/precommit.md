### git pre-commit hooks

* Install
    ```bash
    # pip
    python -m pip install pre-commit

    # brew
    brew install pre-commit

    # install .pre-commit-config.yaml
    pre-commit install                  # install/uninstall
    ```
* Usage
    ```bash
    # skip pre-commit by ID
    SKIP=flake8 git commit -m "foo"

    # skip all pre-commit hooks (e.g., bypass false positives like comment preceding docstring)
    λ git commit -m "Formatting (WIP)" -m "Debugging  formatters" --no-verify
    [master d260d56] Formatting (WIP)
    1 file changed, 108 insertions(+), 34 deletions(-)

    # black dry-run
    black --check --diff file_name.py

    # skip code block
    # fmt: off

    import argparse
    # from icecream import ic
    from pathlib import Path

    # fmt: on

    # skip individual line (buggy)
    # from icecream import ic # fmt: skip

    # manually run commit hook against one file
    pre-commit run black --files email_it/email_it.py --verbose

    # manually run against repo (vs. during commit)
    λ pre-commit run --all-files
    [INFO] Initializing environment for https://github.com/zricethezav/gitleaks.
    <SNIP>
    Detect hardcoded secrets.................................................Passed

    # update hooks
    pre-commit autoupdate
    ```
