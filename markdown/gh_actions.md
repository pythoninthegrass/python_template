### GitHub Actions

#### Update submodules recursively
* Add the submodule to the downstream repo
    ```bash
    git submodule add https://github.com/pythoninthegrass/automate_boring_stuff.git
    git commit -m "automate_boring_stuff submodule"
    git push
    ```
* Create a personal access token called `PRIVATE_TOKEN_GITHUB` with `repo` permissions on the downstream repo
    * `repo:status`
    * `repo_deployment`
    * `public_repo`
* Add that key to the original repo
    * Settings > Security > Secrets > Actions
    * New repository secret
* Setup a new Action workflow
    * Actions > New Workflow
    * Choose a workflow > set up a workflow yourself
    ```bash
    # main.yml
    # SOURCE: https://stackoverflow.com/a/68213855
    name: Send submodule updates to parent repo

    on:
    push:
        branches:
        - main
        - master

    jobs:
    update:
        runs-on: ubuntu-latest

        steps:
        - uses: actions/checkout@v2
            with:
            repository: username/repo_name
            token: ${{ secrets.PRIVATE_TOKEN_GITHUB }}

        - name: Pull & update submodules recursively
            run: |
            git submodule update --init --recursive
            git submodule update --recursive --remote
        - name: Commit
            run: |
            git config user.email "actions@github.com"
            git config user.name "GitHub Actions - update submodules"
            git add --all
            git commit -m "Update submodules" || echo "No changes to commit"
            git push
    ```
