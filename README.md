# python_template

!["It's dangerous to go alone! Take this."](img/zelda.jpg)
<!-- <img src="https://user-images.githubusercontent.com/4097471/144654508-823c6e31-5e10-404c-9f9f-0d6b9d6ce617.jpg" width="300"> -->

## Summary
Oftentimes the initial setup of a Python repo can take a few minutes to a couple hours.
By laying the foundation to rapidly implement an idea, can focus on the good bits instead of
DevOps drudgery.

### Caveat Emptor
Very little of this gets tested on Windows hosts. Windows Subsystem for Linux (WSL) is used where necessary with the default Ubuntu LTS install. Moved bulk of document to the [markdown](markdown/) directory to opt-in vs. opt-out of documentation.

Be the change et al if Windows is your main and you wanna [raise a PR](CONTRIBUTING.md) with broad instructions on getting tooling working under Windows (e.g., docker, poetry, playwright.)

**Table of Contents**
* [python_template](#python_template)
  * [Summary](#summary)
    * [Caveat Emptor](#caveat-emptor)
  * [Setup](#setup)
  * [Usage](#usage)
    * [Mac and Linux users](#mac-and-linux-users)
  * [Pushing to Docker Hub with CI](#pushing-to-docker-hub-with-ci)
  * [TODO](#todo)

## Setup
* Install
    * [editorconfig](https://editorconfig.org/)
    * [wsl](https://docs.microsoft.com/en-us/windows/wsl/setup/environment)
    * [asdf](https://asdf-vm.com/guide/getting-started.html#_2-download-asdf)
    * [poetry](https://python-poetry.org/docs/)
    * [docker-compose](https://docs.docker.com/compose/install/)
    * [playwright](https://playwright.dev/python/docs/intro#installation)
    * [Kubernetes (k8s)](markdown/kubernetes.md)
    * [justfile](https://just.systems/man/en/)

## Usage
### Mac and Linux users
Development environments and tooling are first-class citizens on macOS and *nix. For Windows faithfuls, please setup [WSL](markdown/wsl.md).

## Pushing to Docker Hub with CI
Docker Hub is a cloud-based repository in which Docker users and partners create, test, store and distribute container images. Docker images are pushed to Docker Hub through the docker push command. A single Docker Hub repository can hold many Docker images (stored as tags).

Automated CI is implemented via GitHub Actions to build and push this repository's image to Docker Hub in `/.github/workflows/push.yml`.

### What you need to modify in this file

* Look for `images: your-username/your-image-name` and change to your respective Docker Hub username and image name.
* Add repository secrets for `DOCKERHUB_TOKEN` and `DOCKERHUB_USERNAME` on this repository on GitHub.
  * Here are the [instructions to create a token](https://docs.docker.com/docker-hub/access-tokens/#create-an-access-token).

Here are the [instructions to disable this action](https://docs.github.com/en/actions/managing-workflow-runs/disabling-and-enabling-a-workflow) if you don't want this feature.

## TODO
* [Open Issues](https://github.com/pythoninthegrass/python_template/issues)
* Markdown automation
  * Look for an extension similar to [Markdown All in One](https://marketplace.visualstudio.com/items?itemName=yzhang.markdown-all-in-one) that updates file/directory links when they move
* Webdev
  * Django
      * Merge with [docker_python](https://github.com/pythoninthegrass/docker_python) and put the latter on an ice float
      * [Django Ninja](https://realpython.com/courses/rest-apis-with-django-ninja/)
  * Flask
      * Bonus points for [Svelte](https://svelte.dev/blog/the-easiest-way-to-get-started) front-end ❤️
  * FastAPI
* [SQL](https://realpython.com/python-sql-libraries/)
  * MySQL
  * PostgreSQL
  * SQLite
* NoSQL
  * MongoDB
    * Switch to `docker-compose`
    * Fix unique index deleting too many keys
  * [Redis](https://realpython.com/python-redis/)
* DevOps
  * [Cloud Native](https://www.cncf.io/about/faq/#what-is-cloud-native)
    * AWS
    * Azure
    * GCP
    * [k8s](markdown/kubernetes.md)
      * `~/.kubeconfig`
      * Kompose
      * Helm
      * minikube
        * Expand usage and syntax
    * [Argo](https://argoproj.github.io/)
    * [Flux](https://fluxcd.io/)
    * [DevSpace](https://www.devspace.sh/)
  * [Ansible](https://realpython.com/automating-django-deployments-with-fabric-and-ansible/)
  * [Heroku](https://realpython.com/courses/deploying-a-flask-application-using-heroku/)
  * [justfile](https://just.systems/man/en/)
  * [Windows Subsystem for Linux (WSL)](markdown/wsl.md)
    * VSCode
        * Remote WSL install and usage
          * Or at least further reading nods
* Debugging
   * Dependencies
   * script itself via [icecream](https://github.com/gruns/icecream)
