# Tilt

## [SOURCE](https://github.com/tilt-dev/tilt-example-python)
From the [official docs](https://docs.tilt.dev/example_python.html). Simplest deployment via Flask.

A more in-depth Django deployment is at [cs50w](https://github.com/pythoninthegrass/cs50w).

## Usage
Rename variables in [kubernetes.yml](kubernetes.yml), edit docker files, update dependencies in [requirements.txt](requirements.txt), and fill out [Tiltfile](Tiltfile) per official [KB articles](https://docs.tilt.dev/snippets.html).

Then run
```bash
# start minikube
minikube start --memory=2048 --cpus=3 -p minikube

# start tilt
tilt up
```

Any changes made to source files (cf. [Dockerfile](Dockerfile), [app.py](app.py)) will be immediately built and deployed in k8s.
